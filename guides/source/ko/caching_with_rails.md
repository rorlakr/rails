레일스 캐시
===============================

여기에서는 캐시를 도입하여 레일스 애플리케이션을 빠르게 만드는 방법을 소개합니다.

캐싱이란 요청과 응답 주기에서 생성된 내용을 저장해두고 다음에 같은 요청이 발생하였을 때 응답에서
그 내용을 재활용하는 방법을 가리킵니다.

대부분의 경우 캐시는 애플리케이션의 성능을 효과적으로 높이는 데에 좋은 방법입니다. 캐시를 도입하면
단일 서버, 단일 데이터베이스를 사용하는 웹사이트에서도 수천 명의 동시접속에도 견딜 수 있습니다.

레일스에서는 귀찮은 설정 없이도 곧바로 사용할 수 있는 캐싱 기능이 준비되어 있습니다. 이 가이드에서는
각각의 기능의 목적과 범위에 관해서 설명합니다. 레일스의 캐시 기능을 사용하면 응답 속도의 저하나 값비싼
서버 비용을 걱정하지 않고 레일스 애플리케이션으로 수백만 접속을 처리할 수 있게 됩니다.

이 가이드의 내용:

* 조각(Fragment) 캐싱과 러시아 인형 캐싱
* 캐시의 의존성 관리
* 캐시 저장소
* 조건부 GET 지원

--------------------------------------------------------------------------------

캐싱 기본
-------------

여기에서는 페이지 캐싱, 액션 캐싱, 조각 캐싱을 소개합니다. 레일스의 조각 캐싱은 프레임워크에
포함되어 있으므로 곧장 사용할 수 있습니다.
페이지 캐싱이나 액션 캐싱을 사용하려면 Gemfile에 `actionpack-page_caching` 잼이나
`actionpack-action_caching` 잼을 추가해야 합니다.

캐시는 기본으로 Production 환경에서만 활성화됩니다. 다른 환경에서 캐시를 사용하고 싶은 경우에는
그 환경에 맞는 `config/environments/*.rb`파일에 `config.action_controller.perform_caching`을
`true`로 설정합니다.

```ruby
config.action_controller.perform_caching = true
```

NOTE: `config.action_controller.perform_caching` 값은 액션 컨트롤러의 컴포넌트에서 제공하는 캐시에만 적용됩니다. 다시 말해 뒤에서 설명할 [저레벨 캐시](#저레벨-캐시)에는 영향을 주지 않습니다.

### 페이지 캐싱

레일스의 페이지 캐싱은 Apache나 NGINX와 같은 웹 서버에서 생성되는 페이지 요청을 (레일스 스택 전체를
거치지 않고) 캐싱하는 방식입니다. 페이지 캐싱은 무척 빠릅니다만, 항상 유용하다고는 말할 수 없습니다.
예를 들어, 인증에서는 페이지 캐싱을 사용할 수 없습니다. 그리고 웹 서버는 파일 시스템에서 직접 파일을
읽어오기 때문에 캐시의 유효기간을 설정할 필요가 있습니다.

INFO: 페이지 캐싱은 레일스 4에서 프레임워크로부터 분리되어 잼으로 추출되었습니다. [actionpack-page_caching 잼](https://github.com/rails/actionpack-page_caching)을 확인해주세요.

### 액션 캐싱

페이지 캐싱은 before_filter를 사용하는 액션(인증을 필요로 하는 페이지 등)에는 사용할 수 없습니다.
이럴 때에 액션 캐싱을 사용합니다. 액션 캐시의 동작은 페이지 캐시와 닮아있습니다만, 웹 서버의 요청이
레일스 스택에 도착할 때마다, before_filter를 실행한 뒤에 캐시를 반환한다는 점이 다릅니다.
이에 따라, 인증 등의 제한을 사용하면서 캐시의 장점을 살릴 수 있습니다.

INFO: 액션 캐싱은 레일스 4에서 프레임워크로부터 분리되어 잼으로 추출되었습니다. [actionpack-action_caching 잼](https://github.com/rails/actionpack-action_caching)을 확인해주세요. 권장되는 새 메소드에 대해서는 [DHH의 키 기반 캐시의 만료는 어떻게 동작하는가?](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)를 읽어주세요.

### 조각 캐싱

일반적으로 동적인 웹 애플리케이션에서의 페이지는 서로 다른 캐시 특성을 가지는 다양한 컴포넌트에 의해서
구성됩니다. 페이지 내의 컴포넌트에 대해 캐싱이나 만료 기간을 개별로 설정하고 싶은 경우에 조각 캐싱을 사용합니다.

조각 캐싱에서는 뷰의 로직 부분을 캐싱 블록으로 감싸고, 다음 호출에서 그것을 캐시 저장소에서 가져와 전송합니다.

예를 들어, 페이지에서 표시할 제품을 각각 캐싱하고 싶은 경우 다음과 같이 작성할 수 있습니다.

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

애플리케이션이 처음 요청을 받을 때, 레일스는 유일한 식별자를 사용하여 새로운 캐시를 저장합니다.
생성된 식별자는 다음과 같은 모양입니다.

```
views/products/1-201505056193031061005000/bea67108094918eeba42cd4a6e786901
```

식별자 중간의 긴 문자열은 `product_id`와 product 레코드의 `updated_at` 속성의 타임스탬프입니다.
타임스탬프는 오래된 데이터를 반환하지 않기 위해서 사용됩니다. `updated_at`이 갱신되면 새로운 식별자가
생성되어 그 식별자로 새로운 캐시를 저장합니다. 이전의 식별자로 저장된 캐시는 더이상 사용하지 않게 됩니다.
이 방법을 '키 기반 유효기간'이라고 부릅니다.

캐싱된 조각은 뷰의 조각이 변경된 경우(뷰의 HTML이 변경된 경우 등)에도 만료됩니다. 식별자 뒷부분의
문자열은 '템플릿 트리 다이제스트'입니다. 이것은 캐싱된 뷰 조각의 내용으로부터 계산된 MD5 해시값입니다.
뷰 조각이 변경되면 MD5 해시값도 변경되므로 기존의 캐시가 만료됩니다.

TIP: Memcached 등의 캐시 저장소에서는 오래된 캐시 파일을 자동으로 삭제합니다.

특정 조건을 만족할 때에만 조각을 캐싱하고 싶은 경우에는 `cache_if`나 `cache_unless`를 사용하세요.

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### 컬렉션 캐싱

`render` 헬퍼는 컬렉션의 개별 템플릿을 그릴 때도 캐싱을 사용할 수 있습니다. 위의 예제에서 `each`
를 사용한 코드에서 각각을 가져오는 대신 한 번에 모든 캐시 템플릿을 가져올 수도 있습니다.
콜렉션을 랜더링 하는 경우에 `cached: true`를 지정해주세요.

```erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

이 코드는 이전까지 사용되었던 모든 캐시 템플릿이 한 번에 가져오며, 극적으로 속도가 향상됩니다.
나아가 지금까지 캐시되지 않았던 템플릿도 캐시에 추가되어 다음 랜더링 시에 한 번에 읽어올 수 있게 됩니다.


### 러시아 인형 캐싱

조각 캐시의 내부에서 다시 캐싱하고 싶을 때가 있습니다. 이러한 방식으로 캐싱을 중첩하는 방법을
마트료시카 인형의 이미지로부터 '러시아 인형 캐싱'이라고 부릅니다.

러시아 인형 캐싱을 사용하면, 내부의 조각에서 한 제품만 갱신된 경우에 내부의 다른 조각 캐시를 재활용하고,
외부의 캐시만을 재생성할 수 있습니다.

앞에서 설명했듯, 캐싱된 파일은 그 파일이 직접 의존하고 있는 레코드의 `updated_at`의 값이 변경되면
만료됩니다만 그 조각 내부에 중첩된 캐시는 만료되지 않습니다.

다음의 예시를 보시죠.

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

이 뷰를 랜더링하기 위해, 다음의 뷰를 랜더링합니다.

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

game의 속성이 변경되면, `updated_at`이 현재 시각으로 변경되어 캐시가 만료됩니다.
하지만 product 객체의 `updated_at`은 변경되지 않으므로 product의 캐시도 만료되지 않아 오래된
데이터를 반환합니다. 이를 피하고 싶은 경우에는 다음과 같이 `touch` 메소드로 모델을 연결하세요.

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end 
```

`touch`를 `true`로 지정하면 game 레코드의 `updated_at`을 변경하는 동작이 실행되면,
관계로 연결된 product의 `updated_at`도 함께 갱신되어 캐시가 만료됩니다.

### 의존성 관리

캐시를 올바르게 만료하려면 캐시의 의존성을 적절하게 정의할 필요가 있습니다.
대부분의 경우, 레일스에서는 의존성이 잘 관리되므로 특별하게 해야 할 일은 없습니다. 그러나, 커스텀 헬퍼에서
캐시를 다룰 때는 명시적으로 의존성을 정의해야 합니다.

#### 암묵적인 의존성

대부분의 경우, 템플릿의 의존성은 템플릿 자신이 호출하는 `render`에 의해서 발생합니다.
다음 예제에서는 디코딩하는 방법을 다루는 `ActionView::Digestor`를 사용하는 `render` 호출 예제입니다.

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render "comments/comments"
render("comments/comments")

render "header"        => render("comments/header")

render(@topic)         => render("topics/topic")
render(topics)         => render("topics/topic")
render(message.topics) => render("topics/topic")
```

한편 일부는 호출할 때에 캐시가 적절하게 동작하도록 변경해야 합니다.
예를 들어, 커스텀 컬렉션을 넘기는 경우에는,

```ruby
render @project.documents.where(published: true)
```

이 코드를 다음과 같이 변경합니다.

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### 명시적인 의존성

템플릿에서 생각지 못한 의존성이 발생하는 경우가 있습니다. 보통 이런 경우는 핼퍼에서 랜더링할 때 발생합니다.
다음은 예시입니다.

```erb
<%= render_sortable_todolists @project.todolists %>
```

이러한 호출은 다음과 같은 특별한 주석으로 명시적으로 의존성을 표시해야 합니다.

```erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

단일 테이블 상속과 같은 특별한 상황에서는 이런 명시적인 의존성을 여러 개 포함할 수 있습니다.
이럴 때 각각의 템플릿을 명시하는 대신, 폴더 내의 모든 템플릿을 와일드 카드로 지정할 수도 있습니다.

```erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

컬렉션의 캐시에서 부분(파셜) 템플릿의 맨 위에서 깨끗한 캐시를 사용하지 않는 경우,
다음의 특별한 주석 형식을 템플릿에 추가하여 컬렉션 캐시를 사용하도록 만들 수 있습니다.

```erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```

#### 외부 의존성

예를 들어, 캐싱된 블록 내에서 헬퍼 메소드가 있다고 가정합시다. 이 헬퍼를 변경한 뒤에 캐시가 사용되지 않도록,
템플릿 파일의 MD5가 어떤 방식으로든 변경되게 만들 필요가 있습니다. 권장하는 방법중 하나는, 다음과 같이
주석을 통해 명시적으로 변경하는 것입니다.

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### 저레벨 캐시

뷰의 조각을 캐싱하는 것이 아니라 특정 값이나 쿼리의 결과만을 캐싱하고 싶은 경우가 있습니다.
레일스의 캐싱 기법으로는 어떤 정보라도 캐시에 저장할 수 있습니다.

저레벨 캐시의 가장 효과적인 구현 방법은 `Rails.cache.fetch` 메소드를 사용하는 것입니다.
이 메소드는 캐시 저장/읽기 모두에 대응합니다. 인수가 하나일 경우 키를 사용해 캐시로부터 값을 반환합니다.
블록을 인수로 넘기면 해당 키의 캐시가 없는 경우, 블록을 실행하고 결과를 캐싱한 뒤 그 값을 반환합니다.
해당하는 키의 캐시가 있는 경우, 블록은 실행되지 않습니다.

다음 예시를 보죠. 애플리케이션에 `Product` 모델이 있고, 여러 웹사이트의 제품 가격을 검색하는 인스턴스
메소드가 구현되어 있다고 합시다. 저레벨 캐시를 사용하는 경우 이 메소드로부터 완벽한 데이터를 반환할 수
있습니다.

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

NOTE: 이 예제에서는 `cache_key` 메소드를 사용하고 있으므로 캐시의 키는 `products/233-20140225082222765838000/competing_price`와 같은 모습이 됩니다. `cache_key`에서 생성된 문자열은 모델의 `id`와 `updated_at` 속성을 사용합니다. 이 생성 규칙은 일반적으로 사용되고 있으며, product가 갱신될 때마다 캐시를 만료시킬 수 있습니다. 일반적으로 인스턴스 레벨의 정보에 저레벨 캐시를 사용하는 경우, 캐시 키를 생성해야 합니다.

### SQL 캐싱

레일스의 쿼리 캐싱은 각 쿼리에 따라 반환되는 결과를 캐싱하는 기능입니다. 요청에서 이전과 동일한 쿼리가
생성되면, 데이터베이스에 쿼리를 전송하는 대신, 캐싱된 결과를 사용합니다.

다음은 예시입니다.

```ruby
class ProductsController < ApplicationController

  def index
    # 검색 쿼리를 실행
    @products = Product.all

    ... 

    # 같은 쿼리를 재실행
    @products = Product.all
  end 

end
```

데이터베이스에 대해서 같은 쿼리를 2번 실행하는 경우, 실제로는 데이터베이스에 접근하지 않습니다. 첫 번째 쿼리에서 결과를 메모리상의 쿼리 캐시에 저장하고, 두 번째 쿼리에서는 메모리에서 결과를 가져옵니다.

단, 쿼리 캐싱은 액션을 시작할 때에 생성되며 액션이 종료되는 시점에 파기됩니다.
따라서 캐시는 액션을 실행하는 동안에만 유지됩니다. 캐시를 장기간 유지하고 싶은 경우에는 저레벨 캐시를 사용하세요.

캐시 저장소
------------

레일스에서는 캐시 데이터를 저장하기 위한 장소를 몇 가지 준비하고 있습니다.
SQL 캐싱이나 페이지 캐싱은 여기에 포함되지 않습니다.

### 설정

애플리케이션의 기본 캐시 저장소는 `config.cache_store` 옵션으로 지정할 수 있습니다.
캐시 저장소의 생성자에는 다른 인수도 넘길 수 있습니다.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

NOTE: 또는 블록 외부에서 `ActionController::Base.cache_store`를 호출할 수도 있습니다.

캐시에 접근하려면 `Rails.cache`를 사용합니다.

### ActiveSupport::Cache::Store

이 클래스는 레일스의 캐시에 접근하기 위한 토대를 제공합니다. 추상 클래스이므로 직접 사용할 수는 없습니다.
클래스를 사용하려면 저장소 엔진에 연결된 구체 클래스를 사용해야 합니다. 레일스에는 다음 구현이 포함되어 있습니다.

주요 메소드로는 `read`, `write`, `delete`, `exist?`, `fetch`가 있습니다.
`fetch` 메소드는 블록을 하나 받으며, 캐시의 값이나 블록의 평가값을 반환합니다.
기존의 값이 캐시에 없는 경우에는 결과를 캐시에 저장합니다.

몇몇 옵션에 대해서는 캐시의 모든 구현에서 공통으로 사용할 수 있습니다.
이러한 옵션은 생성자에 넘기거나, 엔트리에 접근하는 다양한 메소드에 넘길 수 있습니다.

* `:namespace` - 캐시 저장소에 이름 공간을 만듭니다. 다른 애플리케이션과 같은 저장소를 사용하는 경우에 유용합니다.

* `:compress` - 캐시 내에서 압축을 활성화합니다. 저속 네트워크에서 거대한 캐시 엔트리를 전송하는 경우에 도움이 됩니다.

* `:compress_threshold` - `:compress` 옵션과 함께 사용합니다. 캐시의 사이즈가 지정된 크기보다 작은 경우 압축하지 않습니다. 기본값은 16KB입니다.

* `:expires_in` - 설정된 초를 지나면 캐시를 자동으로 삭제합니다.

* `:race_condition_ttl` - `:expires_in` 옵션과 함께 사용합니다. 멀티 프로세스에 의해 같은 엔트리가 동시에 재생성되는 경합 상태(dog pile 효과라고도 불립니다)를 방지하기 위함입니다. 이 옵션에서는 새로운 값의 재생성이 완료되지 않은 상태에서 만료된 엔트리를 재사용해도 괜찮은 시간을 초로 지정합니다. `:expires_in` 옵션을 사용하는 경우에는 이 옵션도 값을 설정하는 것을 권장합니다.

#### 커스텀 캐시 저장소

캐시 저장소를 만들려면 `ActiveSupport::Cache::Store`를 확장하여 필요한 메소드를 구현합니다.
이를 통해서 레일스 애플리케이션에서 다양한 캐싱 기능을 원하는 방식으로 사용할 수 있습니다.

직접 만든 캐시 저장소를 사용하려면, 클래스의 새로운 인스턴스를 새 캐시 저장소로 지정합니다.

```ruby
config.cache_store = MyCacheStore.new
```

### ActiveSupport::Cache::MemoryStore

이 캐시 저장소는 같은 루비 프로세스 내의 메모리에 저장됩니다. 캐시 저장소의 크기를 제한하려면
initializer에 `:size` 옵션을 지정합니다(기본값은 32MB). 캐시가 이 크기를 초과하면 정리가
시작되며, 가장 오래된 엔트리부터 순서대로 삭제됩니다.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

레일스 서버 프로세스를 복수 실행한다면(mongrel_cluster나 Phusion Passenger를 사용하는 경우),
캐시 데이터는 프로세스 간에 공유되지 않습니다. 이 캐시 저장소는 대규모로 배포되는 애플리케이션에는
적당하지 않습니다. 단, 작은 규모의 트래픽이 적은 사이트에서 서버 프로세스를 몇 개 정도만 사용한다면
문제 없이 동작합니다. 물론 개발 환경이나 테스트 환경에서도 동작합니다.

### ActiveSupport::Cache::FileStore

이 캐시 저장소는 엔트리를 파일 시스템에 저장합니다. 파일 저장 장소의 경로는 캐시를 초기화할 때에 지정해야 합니다.

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

여기에서는 복수의 서버 프로세스 간에 캐시를 공유할 수 있습니다. 트래픽이 중간 규모인 사이트를 1, 2개
정도를 서비스하는 경우에 유용합니다. 서로 다른 호스트에서 실행하는 서버 프로세스 간에 파일 시스템을
사용하는 캐시를 공유하는 것은 가능합니다만 권장하지 않습니다.

디스크 용량이 가득 찰 정도로 캐시가 증가하는 경우에는 오래된 캐시부터 정기적으로 삭제하는 것을 권장합니다.

더불어 기본으로 포함되는 캐시 저장소 구현입니다.

### ActiveSupport::Cache::MemCacheStore

이 캐시 저장소에서는 Danga의 `memcached` 서버에 애플리케이션 캐시를 일괄적으로 저장합니다.
레일스에서는 프레임워크에 포함된 `dalli` 잼을 사용합니다. 현시점에서 가장 폭넓게 사용되고 있는
캐시 저장소입니다. 이는 공유 가능한 단일 고성능 캐시 클러스터를 안정적으로 제공합니다.

캐시를 초기화할 때에 클러스터 내부의 모든 memcached 서버 주소를 지정해야합니다.
지정하지 않는 경우, memcached는 로컬의 기본 포트에서 동작하고 있을 거라고 가정합니다만,
이는 대규모 사이트에는 적당하지 않습니다.

이 캐시의 `write` 메소드나 `fetch` 메소드에서는 memcached 고유의 기능을 이용하는 두 가지 옵션을
지정할 수 있습니다. 직렬화를 사용하지 않고 직접 서버에 전송하는 `:raw`를 사용할 수 있습니다. 값은
문자열이나 숫자만을 사용할 수 있습니다. 이 형식일 경우, memcached에서 제공하는 `increment`나
`decrement`와 같은 조작을 사용할 수 있습니다. memcached에서 기존의 캐시를 덮어쓰는 것을 허용하지
않으려면 `:unless_exist`를 사용하세요.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

### ActiveSupport::Cache::NullStore

이 캐시 저장소 구현은 개발 환경이나 테스트 환경에서만 사용되며, 실제로는 캐시를 전혀 저장하지 않습니다.
이는 예를 들어 `Rails.cache`에 직접 접근하는 코드의 효과가 캐시 때문에 확인하기 어려운 경우에
편리합니다. 이 캐시 저장소를 사용하면 `fetch`나 `read`가 항상 캐시를 찾지 못하게 됩니다.

```ruby
config.cache_store = :null_store
```

캐시의 키
----------

캐시의 키는 `cache_key`나 `to_param` 중 하나에 대응하는 객체입니다. 커스텀 키를 생성하고 싶다면
`cache_key` 메소드를 구현해주세요. 액티브 레코드에서는 클래스 이름과 레코드 ID를 사용하여 키를 생성합니다.

캐시의 키로서 값의 해시나, 값의 배열을 지정할 수 있습니다.

```ruby
# 정상적인 캐시 키
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

`Rails.cache`의 키는 저장소 엔진에서 실제로 사용되는 키와 다릅니다. 실제 키는 이름 공간에 의해서
수식되거나, 백엔드의 기술적인 제약에 맞추어 변경될 가능성이 있습니다. 다시 말해, `Rails.cache`에
값을 저장하고 `dalli` 잼으로 값을 꺼낼 수는 없습니다. 그 대신에 memcached의 크기 제한이나,
구문 규칙 위반에 대해서는 걱정할 필요가 없습니다.

조건부 GET 지원
-----------------------

조건부 GET은 HTTP 사양에 규정된 기능입니다. GET 요청에 돌려주어야 할 응답이 이전 요청으로부터 전혀
변경되지 않은 경우에는 웹 서버에서 브라우저에게 브라우저 내부의 캐시를 사용해도 좋다고 알려줍니다.

이 기능에서는 `HTTP_IF_NONE_MATCH` 헤더와 `HTTP_IF_MODIFIED_SINCE` 헤더를 사용하여,
유일한 콘텐츠 ID나 마지막으로 변경된 시간 정보를 주고받습니다. 콘텐츠 ID(etag)나 마지막으로 변경된
시간이 서버가 관리하는 버전과 일치하는 경우, 서버로부터 '변경 없음'이라는 정보를 포함하는
빈 응답을 돌려줍니다.

마지막으로 변경된 시간이나 if-none-match 헤더의 유무를 확인하고, 완전한 응답을 돌려줄 필요가 있는지
없는지를 결정하는 것은 서버 측(다시 말해, 개발자)의 책임입니다. 레일스에서는 다음과 같이 조건부 GET을
간단하게 사용할 수 있습니다.

```ruby
class ProductsController < ApplicationController

  def show
    @product = Product.find(params[:id])

    # 어떤 타임스탬프나 etag에 의해서 요청이 오래되었다는 것을 알게 된 경우
    # (i.e. 재처리가 필요한 경우) 이 블록을 실행
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key)
      respond_to do |wants|
        # ...일반적인 응답 처리
      end
    end

    # 요청이 새로운(저번 요청과 동일) 경우 처리를 할 필요가 없음.
    # 기본 랜더링은 이전 번의 `stale?` 호출 결과에 기반해 처리가 필요한지 아닌지를 판단하여
    # :not_modified를 전송.
  end
end
```

옵션 해시 대신에 모델을 넘길 수도 있습니다. 레일스는 `last_modified`와 `etag`를 설정하기 위해,
`updated_at`와 `cache_key` 메소드를 사용합니다.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ...일반적인 응답 처리
      end
    end
  end
end
```

특수한 응답 처리를 하지 않고 기본의 랜더링 방식을 사용하는 경우(i.e. `respond_to`를 사용하지 않거나,
직접 `render`를 호출하지 않을 때), `fresh_when` 헬퍼로 간단하게 처리할 수 있습니다.

```ruby
class ProductsController < ApplicationController

  # 요청에 변경이 없다면 자동으로 :not_modified를 반환
  # 만료된 경우에는 기본 템플릿(product.*)을 반환.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

### 강한 ETag와 약한 ETag

레일스에서는 기본으로 약한 ETag를 사용합니다. 약한 ETag에서는 응답의 본문이 미묘하게 다른 경우에도 같은 ETag를 부여하므로,
사실상 같은 응답인 것처럼 다룹니다. 응답 본문의 극히 일부가 변경된 경우, 페이지의 재생성을 피하고 싶은 경우에 편리합니다.

약한 Etag에는 `W/`가 앞에 추가되며, 이를 통해 강한 ETag와 구별할 수 있습니다.

```
  W/"618bbc92e2d35ea1945008b42799b0e7" → 약한 ETag
  "618bbc92e2d35ea1945008b42799b0e7" → 강한 ETag
```

강한 ETag는 약한 ETag와는 다르게 바이트 레벨에서 응답이 완전히 일치할 것을 요구합니다.
큰 영상이나 PDF 파일 내부에서 Range 요청을 하는 경우에 편리합니다. Akamai 등 일부 CDN에서는
강한 ETag만을 지원하고 있습니다. 강한 ETag가 필요한 경우에는 다음과 같이 설정해주세요.

```ruby
  class ProductsController < ApplicationController
    def show
      @product = Product.find(params[:id])
      fresh_when last_modified: @product.published_at.utc, strong_etag: @product
    end
  end
```

다음과 같이 응답에 강한 ETag를 직접 설정할 수도 있습니다.

```ruby
  response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

참고자료
----------

* [DHH: 키 기반 캐시의 만료는 어떻게 동작하는가?](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Bates Railscast: 캐시 다이제스트](http://railscasts.com/episodes/387-cache-digests)
