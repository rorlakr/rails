
액션 컨트롤러 개요
==========================

이 가이드에서는 컨트롤러의 동작과 애플리케이션의 요청 사이클에서 컨트롤러가 어떻게 사용되는지 설명합니다.

이 가이드의 내용:

* 컨트롤러를 거치는 요청의 흐름을 이해햐기
* 컨트롤러로 넘기는 매개 변수를 제한하는 방법
* 세션이나 쿠키에 데이터를 저장하는 이유와 방법
* 요청을 처리하는 도중, 필터를 사용하여 코드를 실행하는 방법
* 액션 컨트롤러에 내장되어 있는 HTTP인증을 사용하는 방법
* 사용자의 브라우저에 데이터를 직접 스트리밍하는 방법
* 민감한 매개 변수를 로그로 출력하지 않는 방법
* 요청 처리중에 발생하는 예외를 다루는 방법

--------------------------------------------------------------------------------

컨트롤러의 역할
--------------------------

액션 컨트롤러는 MVC모델의 C에 해당합니다. 라우팅가 요청을 처리할 컨트롤러를 결정하면, 컨트롤러는 요청을
해석하고, 적절한 응답을 돌려줄 책임을 집니다. 다행히 이러한 처리의 기본적인 부분은 대부분 액션 컨트롤러가
수행하며, 이러한 처리를 가능한 간단하게 만들기 위해 영리한 방식을 사용합니다.

종래의 일반적인 [RESTful](http://ko.wikipedia.org/wiki/REST)한 애플리케이션에서 컨트롤러는
요청을 받아(이 부분은 개발자가 볼 수 없게 되어 있습니다) 데이터를 모델에서 받아오거나 저장하는 작업을 수행하고,
마지막으로 뷰를 사용하여 HTML 출력을 생성합니다. 본인의 컨트롤러를 만드는 방식이 이것과는 좀 다를 수
있습니다만, 신경 쓸 필요는 없습니다. 이것은 컨트롤러를 사용하는 가장 일반적인 방법을 설명한 것이기 때문입니다.

컨트롤러가 모델과 뷰의 사이를 중개한다는 관점도 있습니다. 컨트롤러는 모델의 데이터를 뷰에서 사용할 수 있도록
가공하여, 데이터를 뷰에서 출력하거나, 사용자로부터 입력받은 데이터로 모델을 갱신하거나 합니다.

NOTE: 좀 더 자세한 라우팅 과정에 대해서는 이 가이드의 [Rails 라우팅](routing.html)을 참조하세요.

컨트롤러의 명명 규칙
----------------------------

Rails의 컨트롤러 이름은 기본적으로 이름의 마지막에 '복수형'을 사용합니다. 단, 이것은 반드시 지켜야 하는
것은 아닙니다(e.g. `ApplicationController`). 예를 들어 `ClientsController`가
`ClientController`보다는 선호되며, `SiteAdminsController`는 `SiteAdminController`나
`SitesAdminsController`보다 선호되는 식입니다.

그러나 일반적으로 이 규칙을 따를 것을 추천합니다. 그 이유는 `resources`같은 기본 라우팅 생성자를
있는 그대로 사용할 수 있다는 점, 애플리케이션 전체에서 URL이나 패스 헬퍼의 사용법을 일관되게 만들 수
있다는 장점이 있습니다. 자세한 설명은 [레이아웃과 랜더링](layouts_and_rendering.html)에서
확인해주세요.

NOTE: 모델의 명명 규칙은 '단수형'으로, 컨트롤러의 명명 규칙과는 다릅니다.


메소드와 액션
-------------------

Rails의 컨트롤러는 `ApplicationController`를 상속한 루비 클래스이며, 다른 클래스와 마찬가지로
메소드를 사용할 수 있습니다. 애플리케이션이 브라우저로부터 요청을 받으면 라우팅에 의해서 실행할 컨트롤러와
액션이 결정되고, Rails는 그 컨트롤러의 인스턴스를 생성하여 액션명과 동일한 이름을 가지는 메소드를 실행합니다.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

예를 들어 클라이언트를 한명 추가하기 위해 브라우저에서 `/clients/new`에 접속하게 되면,
Rails는 `ClientsController`의 인스턴스를 생성하고 `new`라는 메소드를 실행합니다. 여기서
주목해야 할 부분은 `new` 메소드의 내용이 비어있음에도 불구하고 정상적으로 동작한다는 점입니다.
Rails에서는 따로 지정한 것이 없을 경우, `new.html.erb` 뷰를 랜더링하기 때문입니다.
뷰에서 `@client` 인스턴스 변수에 접근하기 위해서 `new` 메소드에서 `Client`를 하나 생성하고,
`@client`에 저장해보죠.

```ruby
def new
  @client = Client.new
end
```

더 자세한 내용은 [레이아웃과 랜더링](layouts_and_rendering.html)에 설명되어 있습니다.

`ApplicationController`는 편리한 메소드가 많이 정의되어 있는 `ActionController::Base`를
상속합니다. 이 가이드에서는 그 중 일부에 대해서 설명합니다만, 더 자세히 알고 싶은 경우에는 API 문서나
Rails의 소스 코드를 확인해주세요.

public 메소드일 경우에만 액션으로써 사용할 수 있습니다. 보조 메소드나 필터처럼 액션으로 사용되지 않는
메소드를 `private`나 `protected`로 지정하는 것이 일반적입니다.

매개 변수
----------

컨트롤러의 액션에서는 사용자로부터 전송된 데이터나 그 이외의 매개 변수를 사용하여 어떤 작업을 하는 경우가
많습니다. 일반적인 웹 애플리케이션에서는 2종류의 매개 변수를 사용할 수 있습니다. 첫번째는 URL의 일부로서
전송되는 매개 변수로, '쿼리 문자열 매개 변수'라고 부릅니다. 쿼리 문자열은 URL의 "?"의 뒤에 위치합니다.
두번째는 'POST 데이터'라고 불리는 것입니다. POST 데이터는 보통 사용자가 기입한 HTML 폼으로부터
전송됩니다. 이는 HTTP POST 요청의 일부로 전송되기 때문에 POST 데이터라고 불립니다. Rails는 쿼리
문자열 매개 변수와 POST 데이터를 동일하게 다루며, 어느 쪽도 컨트롤러 내부에서는 `params`라는 이름의
해시를 통해 접근할 수 있습니다.

```ruby
class ClientsController < ApplicationController
  # 이 액션에서는 쿼리 문자열 매개 변수가 사용됩니다.
  # 전송측에서 HTTP GET 요청을 사용하기 때문입니다.
  # 단 매개 변수에 접근하는 방법은 아래의 방식과 다르지 않습니다.
  # 유효한 고객 목록을 얻기 위해 이 액션의 URL은 다음과 같이 되어 있습니다.
  # clients: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # 이 액션에서는 POST 데이터를 사용하고 있습니다.
  # 이 매개 변수는 일반적으로 사용자가 전송한 HTML 폼으로부터 생성됩니다.
  # 이것은 RESTful한 접근이며, URL은 "/clients"가 됩니다.
  # 데이터는 URL이 아닌 요청의 body에 포함되어 전송됩니다.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # 아래 줄에서는 기본 랜더링 동작을 덮어씁니다.
      # 기본으로는 "create" 뷰가 랜더링됩니다.
      render "new"
    end
  end
end
```

### 해시와 배열 매개 변수

`params` 해시는 1차원의 키-값 쌍만 저장할 수 있는 것이 아닙니다. 배열이나 중첩된 해시를 가질 수도
있습니다. 값의 배열을 전송하고 싶은 경우에는 아래와 같이 키의 이름에 빈 대괄호를 추가해주세요.

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

NOTE: "["와 "]"는 URL에서는 사용불가능한 문자이므로, 이 예시의 실제 URL은
"/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3"처럼 구성됩니다. 이는 브라우저가 자동으로
변환해주며 나아가 Rails가 매개 변수를 가져올 때 자동으로 복원해주므로, 평소에는 신경쓸 필요가 없습니다.
단, 어떤 이유로 서버에 직접 요청을 해야하는 경우에는 이를 주의해야 합니다.

받은 `params[:ids]`의 값은 `["1", "2", "3"]`이 됩니다. 매개 변수의 값은 모두 '문자열'이라는
점을 기억하세요. Rails는 매개 변수의 타입을 추측하지 않으며, 타입 변환도 해주지 않습니다.

NOTE: `params`에 `[nil]`, `[nil, nil, ...]` 같은 값이 있으면 모두 자동적으로
`[]`로 변환됩니다. 이 동작은 보안 상의 이유 때문이며 자세한 설명은
[보안 가이드](security.html#안전하지_않은_쿼리_생성)을 참조해주세요.

해시를 전송하기 위해서는 대괄호에 키 이름을 넣어 전송하면 됩니다.

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

이 폼을 전송하면 `params[:client]`의 값은
`{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`가
됩니다. `params[:client][:address]`처럼 해시가 중첩되어 있는 부분을 주목해주세요.

이 `params` 객체는 해시처럼 동작합니다만, 키로 심볼이나 문자열, 어느 쪽을 사용할 수 있다는 점이 다릅니다.

### JSON 매개 변수

웹 애플리케이션을 개발하다 보면, 매개 변수를 JSON 형식으로 받는다면 편리할텐데, 라고 생각할 때가 종종
있습니다. Rails에서는 요청의 "Content-Type"에 "application/json"가 지정되어 있으면,
자동적으로 매개 변수를 `params` 해시로 변환해줍니다. 그 이후로는 일반적인 `params` 해시를 조작하듯
사용할 수 있습니다.

예를 들어 아래의 JSON 데이터를 전송한다고 가정합시다.

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

`params[:company]`가 넘겨받는 값은
`{ "name" => "acme", "address" => "123 Carrot Street" }`가 됩니다.

마찬가지로 initializer에서 `config.wrap_parameters`를 활성화했거나, 컨트롤러에서
`wrap_parameters`를 호출했을 경우, JSON 매개 변수의 루트 요소를 안전하게 제거할 수 있습니다.
이 경우, 매개 변수는 복사되고, 컨트롤러의 이름에 맞는 키로 감싸지게 됩니다.
따라서 위의 JSON 요청은 아래와 같이 처리됩니다.

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

데이터를 전송한 곳이 `CompaniesController`라고 가정하면,
아래와 같이 `:company`라는 키로 감싸집니다.

```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

키의 이름을 변경하거나, 특정 매개 변수를 감싸고 싶은 경우에는
[API 문서](http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)를
참조해주세요.

NOTE: XML 매개 변수 해석을 도와주던 코드는 `actionpack-xml_parser`라는 잼으로 분리되었습니다.

### 라우팅 매개 변수

`params` 해시는 `:controller`와 `:action`를 반드시 포함합니다. 단, 이 값에는 직접 사용하는 대신,
`controller_name`과 `action_name`이라는 전용 메소드를 사용해주세요. 라우팅에 정의된
다른 값(`id` 등)에도 접근할 수 있습니다. 예를 들어, "유효" 또는 "무효"로 표기되는 고객 리스트를
생각해봅시다. "보기 좋은" URL에 포함되는 `:status` 매개 변수를 가져오기 위해 다음과 같은 라우트를
하나 추가합시다.

```ruby
get '/clients/:status' => 'clients#index', foo: 'bar'
```

이 경우, 브라우저에서 `/clients/active`라는 URL에 접근하면, `params[:status]`가
"active"(유효)로 설정됩니다. 이 라우팅을 사용하면 넘겨진 쿼리 문자열은 당연히 `params[:foo]`에
"bar"로 설정됩니다. 마찬가지로 `params[:action]`에는 "index"가,
그리고 `params[:controller]`에는 "clients"가 포함됩니다.

### `default_url_options`

컨트롤러에서 `default_url_options`라는 이름의 메소드를 정의하면, URL 생성용 전역 기본 매개 변수를
설정할 수 있습니다. 이러한 메소드는 필요한 기본값을 가지는 해시를 반환해야 하며, 키로 심볼을 사용해야 합니다.

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

이런 옵션은 URL 생성의 시작점으로 사용할 수 있으며, `url_for` 호출에 넘겨지는 옵션으로
덮어쓸 수 있습니다.

`ApplicationController`에서 `default_url_options`을 정의하면 위의 예시에서 볼 수 있듯
모든 URL 생성시에 사용하게 됩니다. 이 메소드를 특정 컨트롤러에서 정의하면 그 컨트롤러에서 생성되는
URL에만 영향을 미치게 됩니다.

주어진 요청에서 이 메소드는 생성된 모든 URL에서 각각 호출되지는 않습니다. 성능 상의 이유로 반환되는 해시는
캐싱되어 있으며, 요청당 많아야 한번 호출됩니다.

### Strong Parameters

Strong parameters를 사용하면 액션 컨트롤러가 받은 매개 변수를 화이트리스트로 검증하기 전에는
Active Model에 통째로 넘길 수 없게 됩니다. 이것은 여러 속성을 한번에 갱신하고 싶을 때에 어떤 속성의
갱신을 허가하고, 또다른 속성의 갱신을 금지할 지 명시적으로 결정해야 한다는 의미입니다. 이는 사용자가
보안 상의 이유로 변경해서는 안되는 속성을 실수로 변경할 수 없게끔 방지하기 위한 방책입니다.

나아가 매개 변수의 속성에는 '필수(required)'를 지정할 수 있으며, 사전에 정의해둔 raise/rescue를
실행하여 400 Bad Request를 돌려줄 수도 있습니다.

```ruby
class PeopleController < ActionController::Base
  # 이 코드는 ActiveModel::ForbiddenAttributesError 예외를 던집니다.
  # 명시적으로 검증을 하지 않고 매개 변수를 그냥 통째로 넘기고 있기 때문입니다.
  def create
    Person.create(params[:person])
  end

  # 이 코드는 매개 변수에 person이라는 키가 존재하는 경우에만 성공합니다.
  # person이라는 키가 없는 경우에는 ActionController::ParameterMissing 예외를 던집니다.
  # 이 예외는 ActionController::Base가 잡아 400 Bad Request로 반환합니다.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # private 메소드를 사용해서 매개 변수 검증을 캡슐화합니다.
    # 이를 통해 create와 update에서 같은 검증을 쉽게 재사용할 수 있습니다.
    # 또한 허가할 속성을 사용자마다 다르게 만들 수도 있습니다.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### 허가된 값

다음의 예제에서는,

```ruby
params.permit(:id)
```

`:id` 키가 `params`에 들어있으며 허가된 형식의 값이 들어있다면 화이트리스트 검증을 통과할 수
있습니다. 그렇지 않으면 그 값은 필터에 의해 제거됩니다. 따라서 배열이나 해시, 그 이외의 객체를
외부에서 주입할 수 없게 됩니다.

허가된 형식은 `String`, `Symbol`, `NilClass`, `Numeric`, `TrueClass`,
`FalseClass`, `Date`, `Time`, `DateTime`, `StringIO`, `IO`,
`ActionDispatch::Http::UploadedFile`, `Rack::Test::UploadedFile`입니다.

`params`의 값이 허가된 형식의 배열이어야 한다고 선언하려면, 아래와 같이 빈 배열을 매핑하면 됩니다.

```ruby
params.permit(id: [])
```

매개 변수 해시 전체를 화이트리스트로 만들고 싶은 경우에는 `permit!` 메소드를 사용할 수 있습니다.

```ruby
params.require(:log_entry).permit!
```

이렇게 작성하면, `:log_entry` 매개 변수 해시와 그 내부의 모든 값들을 허가하게 됩니다. 단,
`permit!`은 가진 속성을 모두 허가하게 되므로, 신중하게 사용해주세요. 현재 모델은 물론, 나중에
속성이 추가되더라도 일괄 할당되기 때문입니다.

#### 중첩된 매개 변수

중첩된 매개 변수에 대해서도 아래와 같이 검증할 수 있습니다.

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

이 선언에서는 `name`, `emails`, `friends` 속성이 화이트리스트에 포함됩니다. 여기에서는
`emails`는 허가된 형식들을 포함하는 배열이기를, `friends`는 특정 속성을 가지는 리소스의
배열이길 요구하고, 어느 쪽이든 `name` 속성(사용 가능한 형식일 경우에만)을 가져야 합니다. 또한
`hobbies`와 `family`를 요구합니다.

#### 추가 예제

이번에는 `new` 액션에서 검증된 속성을 사용해봅시다. 하지만 `new`를 호출하는 시점에서는 이를
사용할 객체가 존재하지 않으므로 `require`를 사용할 대상이 없다는 문제가 있습니다.

```ruby
# `fetch`를 사용해서 기본 값을 제공하여
# Strong Parameters API를 사용할 수 있습니다.
params.fetch(:blog, {}).permit(:title, :author)
```

`accepts_nested_attributes_for` 메소드를 사용하면, 관계가 맺어진 레코드를 갱신하거나 삭제할
수 있습니다. 이 동작은 `id`와 `_destroy` 매개 변수를 사용합니다.

```ruby
# :id와 :_destroy를 허가합니다.
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

정수 키를 가지는 해시는 다른 방식으로 처리됩니다. 이것들은 자식 객체를 가지고 있는 것처럼 선언할
수 있습니다. 이러한 종류의 매개 변수는 `has_many` 관계와 함께
`accepts_nested_attributes_for` 메소드를 사용할 때 가져올 수 있습니다.

```ruby
# 아래의 데이터를 화이트리스트로 만들기
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

#### Strong Parameters의 스코프 외부

strong parameter API는 가장 일반적인 사용 상황을 고려하여 설계되어 있습니다. 다시 말해,
화이트리스트를 사용하는 모든 문제를 다룰 수 있을 정도로 만능은 아니라는 의미입니다. 그러나
이 API를 사용하여 상황에 대응하기 쉬워질 수는 있을 것입니다.

다음과 같은 상황을 가정해봅시다. 제품명과 그 제품명에 관련된 임의의 데이터를 표현하는 매개 변수가 있으며,
그 모두를 화이트리스트로 만들고 싶습니다. strong parameter API는 임의의 키를 가지는 중첩된 해시
전체를 직접 화이트리스트로 만들 수는 없습니다만, 중첩된 해시의 키를 사용해서 화이트리스트로 만들 대상을
선언할 수 있습니다.

```ruby
def product_params
  params.require(:product).permit(:name, data: params[:product][:data].try(:keys))
end
```

세션
-------

Rails 애플리케이션에서는 사용자마다 이전 요청의 정보를 다음의 요청에서도 사용하기 위해서 세션에 소량의 데이터를 저장합니다. 세션은 컨트롤러와 뷰에서만 사용 가능하며 아래처럼 복수의 저장소 중에서 하나를 선택하여 사용할 수 있습니다.

* `ActionDispatch::Session::CookieStore` - 모든 세션을 클라이언트 측의 쿠키에 저장
* `ActionDispatch::Session::CacheStore` - 데이터를 Rails의 캐시에 저장
* `ActionDispatch::Session::ActiveRecordStore` - 액티브 레코드를 사용해서 데이터베이스에 저장(`activerecord-session_store` gem이 필요)
* `ActionDispatch::Session::MemCacheStore` - 데이터를 memcached 클러스터에 저장(이 방식은 오래되었으므로 이보다는 CacheStore를 검토하길 권장)

모든 방식은, 세션의 식별자를 쿠키에 보존합니다(주의: Rails에서는 보안상의 위험이 있으므로 세션ID를 URL로 넘기는 행동을 허락하지 않습니다. 세션 ID는 쿠키로 넘겨야합니다).

많은 세션 저장소에서는 이 ID는 단순히 서버의 세션 데이터(데이터베이스 테이블 등)을 검색하기 위해서
사용됩니다. 단 CookieStore는 예외적으로 쿠키에 모든 세션 정보를 저장합니다(세션 ID도 필요하다면
사용할 수 있습니다). 그리고 Rails에서는 CookieStore가 기본으로 사용되며, 또한 이것이 Rails에서
추천하는 저장소이기도 합니다. CookieStore의 이점은 무척 가볍다는 점과 새로운 웹 애플리케이션에서
세션을 사용할 때에 추가 요구사항이 없다는 점입니다. 쿠키 데이터는 변경 방지를 위해 암호화 서명이 추가되어
있습니다. 또한 쿠키 자신도 암호화 되어있으므로 다른 사람이 읽을 수 없도록 되어있습니다(쿠키가 외부에 의해서 변경될 경우 Rails는 그 쿠키를 거부합니다).

CookieStore에는 약 4KB의 데이터를 저장할 수 있습니다. 다른 세션 저장소에 비해서는 작습니다만,
보통 이것으로 충분합니다. 세션에 대량의 데이터를 저장하는 방법은 저장소의 종류에 관계없이 권장하지
않습니다. 특히, 세션에 복잡한 객체(모델 인스턴스 등 기본 루비 객체가 아닌 것들)을 저장하는 것도
권장하지 않습니다. 이러한 객체를 저장하는 경우, 서버가 리퀘스트마다 세션을 재구성하지 못하고 에러를
발생시키는 경우가 있습니다.

사용자 세션에 중요한 정보가 포함되어 있지 않은 경우, 또는 사용자 세션을 장기 저장해야할 필요가 없는
경우(flash 메시지를 저장하기 위한 용도로만 사용할 경우)는
`ActionDispatch::Session::CacheStore`를 검토해주세요. 이 방식은 웹 애플리케이션에
설정되어있는 캐시 저장소를 이용하여 세션을 저장합니다. 이 방법의 좋은 점은 기존에 존재하는 환경을
그대로 사용하여 세션을 저장할 수 있다는 점과 관리용 설정을 추가할 필요가 없다는 점입니다. 반면,
이 방법의 단점은 세션의 수명이 짧아질 수 있다는 점입니다. 세션이 언제라도 사라질 가능성이 생깁니다.

세션 저장소에 대한 더 자세한 설명은 [보안 가이드](security.html)를 참조해주세요.

다른 세션 저장 방식이 필요한 경우에는 initializer를 통해 변경할 수 있습니다.

```ruby
# 기본으로 사용하는 쿠키 기반 세션 대신에 데이터베이스 세션을 사용하는 경우에는,
# 중요한 정보를 저장하지 말 것.
# (세션 테이블의 생성은 "rails g active_record:session_migration"으로 가능함)
# Rails.application.config.session_store :active_record_store
```

Rails는 세션 데이터에 서명할 때에 세션 키(쿠키의 이름)를 생성합니다. 이 동작도 initializer에서 변경 가능합니다.

```ruby
# 이 파일을 수정한 뒤에는 서버를 재시작해주세요.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

`:domain` 키를 넘겨서, 쿠키에서 사용할 도메인 이름을 지정할 수도 있습니다.

```ruby
# 이 파일을 수정한 뒤에는 서버를 재시작해주세요.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails는 세션 데이터에 서명으로 사용할 비밀키를 (CookieStore용으로) 설정합니다.이 비밀키는
`config/secrets.yml`에서 변경 가능합니다.

```ruby
# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rails secret` to generate a secure secret key.

# Make sure the secrets in this file are kept private
# if you're sharing your code publicly.

development:
  secret_key_base: a75d...

test:
  secret_key_base: 492f...

# Do not keep production secrets in the repository,
# instead read values from the environment.
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
```

NOTE: `CookieStore`를 사용중에 비밀키를 변경하면 기존의 세션이 모두 무효가 됩니다.

### 세션에 접근하기

컨트롤러에서는 `session` 메소드를 사용해서 세션에 접근할 수 있습니다.

NOTE: 세션은 지연 로딩됩니다. 액션에서 세션을 사용하지 않았을 경우, 세션은 로드되지 않습니다.
따라서 접근하지 않았다면 세션을 무효화할 필요가 없습니다. 그저 사용하지 않으면 됩니다.

세션의 값은 해시와 비슷하게 키-값 쌍을 사용해서 저장합니다.

```ruby
class ApplicationController < ActionController::Base

  private

  # 세션에 저장되어 있는 id로 사용자를 검색합니다.
  # :current_user_id는 Rails 애플리케이션에서 사용자 로그인 정보를 다루는 일반적인 방법입니다.
  # 로그인하면 세션 값을 저장하고, 로그아웃 하면 세션 값을 삭제합니다.
  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end
end
```

세션을 사용해서 무언가를 하고 싶다면, 해시와 비슷한 방식으로 사용하면 됩니다.

```ruby
class LoginsController < ApplicationController
  # "Create" a login, aka "log the user in"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # 세션에 사용자 ID를 저장하여, 다음 요청에서 사용할 수 있게 합니다.
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

세션에서 데이터의 일부를 제거하고 싶은 경우에는 키에 `nil`을 할당하면 됩니다.

```ruby
class LoginsController < ApplicationController
  # 로그인을 해제합니다(=로그아웃)
  def destroy
    # 세션 id로부터 user id를 제거
    @_current_user = session[:current_user_id] = nil
    redirect_to root_url
  end
end
```

세션 전체를 초기화하기 위해서는 `reset_session`을 사용해주세요.

### Flash

flash는 세션의 특수한 형태로, 요청마다 내용물이 삭제 됩니다. 이 특징때문에 flash는 직후의 요청에서만
참조 가능합니다. 이것은 에러 메시지를 건네는 경우에 특히 편리합니다.

flash를 사용하는 방법은 세션과 거의 동일하며, 해시라고 생각하고 사용할 수
있습니다([FlashHash](http://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html) 인스턴스입니다).

예를 들어 로그아웃하는 동작을 구현한다고 생각해보죠. 컨트롤러에서 flash를 사용하여 다음 요청에서
표시할 메시지를 전송할 수 있습니다.

```ruby
class LoginsController < ApplicationController
  def destroy
    session[:current_user_id] = nil
    flash[:notice] = "You have successfully logged out."
    redirect_to root_url
  end
end
```

flash메시지는 리다이렉션에도 사용할 수 있다는 점에 주목해주세요. 옵션으로 `:notice`, `:alert`
이외에도 일반적인 `:flash`를 사용할 수도 있습니다.

```ruby
redirect_to root_url, notice: "You have successfully logged out."
redirect_to root_url, alert: "You're stuck here!"
redirect_to root_url, flash: { referral_code: 1234 }
```

이 `destroy` 액션에서는 애플리케이션의 `root_url`로 리다이렉션 되며, 거기에서 메시지를 표시합니다.
flash 메시지는 직전의 액션에서 어떠한 메시지가 저장되어 있는지에 관계없이 다음에 이루어지는 액션에 대해서만
사용된다는 점을 주의해주세요. Rails 애플리케이션의 레이아웃에서는 flash를 사용해서 경고나 안내문을
표시하는 것이 일반적입니다.

```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- 이하 생략 -->
  </body>
</html>
```

이와 같이, 액션에서 통지나 알림 메시지를 넘겨주면 레이아웃 쪽에서 자동적으로 메시지를 표시합니다.

flash에는 통지나 경고 문자열 뿐만 아니라, 세션에서 보존 가능한 것이라면 무엇이든 저장 가능합니다.

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Welcome to our site!</p>
<% end %>
```

flash의 값을 다른 요청에서도 계속해서 사용하고 싶은 경우에는 `keep` 메소드를 사용하세요.

```ruby
class MainController < ApplicationController
  # 이 액션은 root_url에 대응하며, 이에 대응하는 모든 요청을
  # UsersController#index로 리다이렉션하고 싶다고 합시다.
  # 어떤 액션에서 flash를 설정하여 이 index 액션에 리다이렉션하고, 이 곳에서
  # 다른 리다이렉션이 발생한 경우에 flash값이 사라지고 맙니다.
  # 이 때 'keep'을 사용하면 다음 요청에서 flash가 남아있게 됩니다.
  def index
    # 모든 flash값을 유지
    flash.keep

    # 키를 지정해서 값을 유지할 수도 있음
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```

#### `flash.now`

기본적으로 flash에 값을 추가하면 그 다음 요청에서 그 값을 사용할 수 있습니다만 상황에 따라서 다음 요청
전에 같은 요청 내에서 이 flash 값을 참조하고 싶을 때가 있습니다. 예를 들어 `create` 액션에 실패해서
리소스가 저장되지 않았을 경우에, `new` 템플릿을 직접 랜더링하게 됩니다. 이 때 새로운 요청은 발생하지
않습니다만, 이러한 경우에도 flash를 사용해서 메시지를 넘기고 싶을 수 있습니다. 이러한 경우에는
`flash.now`를 사용하면 `flash`와 같은 요령으로 메시지를 사용할 수 있습니다.

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(params[:client])
    if @client.save
      # ...
    else
      flash.now[:error] = "Could not save client"
      render action: "new"
    end
  end
end
```

Cookies
-------

웹 애플리케이션에서는 cookie라고 불리는 소량의 데이터를 클라이언트의 브라우저에 저장할 수 있습니다.
HTTP에서는 기본적으로 요청과 요청 사이에 아무런 관련이 없습니다만, cookie를 사용하는 것으로 요청 간에
(또는 세션 간에) 데이터를 유지할 수 있습니다. Rails에서는 `cookies` 메소드를 사용해서 cookie에
간단하게 접근할 수 있습니다. 접근 방법은 세션과 무척 비슷해서, 해시처럼 동작합니다.

```ruby
class CommentsController < ApplicationController
  def new
    # cookie에 덧글 작성자의 이름이 남아 있다면 필드에 자동으로 입력한다.
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # 덧글 작성자의 이름을 저장
        cookies[:commenter_name] = @comment.author
      else
        # 덧글 작성자의 이름이 쿠키에 남아있다면 삭제
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

세션을 삭제할 때에는 키에 `nil`을 대입했습니다만, cookie를 삭제하는 경우에는
`cookies.delete(:key)`를 사용해주세요.

Rails에서는 비밀 데이터를 저장하기 위해서 서명이 된 cookie jar와 암호화 cookie jar를 사용할 수
있습니다. 서명이 된 cookie jar에서는 암호화한 서명을 cookie값에 추가하는 것으로 cookie의 변조를
막습니다. 암호화 cookie jar에서는 서명을 추가할 뿐 아니라 값 자체를 암호화하여 사용자들이 읽을 수 없도록
만듭니다. 더 자세한 설명은 [API 문서](http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)를 참조해주세요.

이런 특수한 cookie는 시리얼라이저를 사용해 값을 문자열로 직렬화하여 저장하고, 읽어들일 때 다시 역직렬화를
수행하여 루비 객체로 되돌립니다.

사용할 시리얼라이저를 지정할 수도 있습니다.

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :json
```

새 애플리케이션의 기본 시리얼라이저는 `:json`입니다. 기존의 cookie가 남아있는 옛 애플리케이션과의
호환성을 위해 `serializer` 옵션으로 아무것도 지정되지 않은 경우에는 `:marshal`을 사용합니다.

시리얼라이저의 옵션으로 `:hybrid`를 지정할 수도 있습니다. 이 값을 지정하면 기존의 cookie를 읽을 때에는
`Marshal`로 역직렬화를 하며, 저장할 때에는 `JSON` 형식을 사용합니다. 이것은 기존 애플리케이션에서
`:json` 시리얼라이저로 넘어갈 때 유용합니다.

또는 `load` 메소드와 `dump` 메소드에 응답하는 커스텀 시리얼라이저를 지정할 수도 있습니다.

```ruby
Rails.application.config.action_dispatch.cookies_serializer = MyCustomSerializer
```

`:json` 또는 `:hybrid` 시리얼라이저를 사용하는 경우, 일부 루비 객체는 JSON으로 직렬화할 수 없다는
점을 주의해주세요. 예를 들어, `Date` 객체나 `Time` 객체는 문자열로 직렬화되며 `Hash`는 키만을
문자열로 변환합니다.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

cookie에는 문자열이나 숫자 등의 단순한 데이터만을 저장하는 것을 권장합니다.
cookie에 복잡한 객체를 저장해야하는 경우에는 이후 요청에서 cookie로부터 값을 읽어들일 때에 역직렬화
과정에 직접 관여를 해야 합니다.

cookie 세션 저장소를 사용하는 경우 `session`나 `flash`에도 적용됩니다.셔

XML과 JSON 데이터를 랜더링하기
---------------------------

ActionController 덕분에 `XML` 데이터나 `JSON` 데이터의 출력(랜더링)을 무척 간단하게 처리할 수
있습니다. scaffold를 사용해서 생성된 컨트롤러는 아래와 같이 되어 있을 것입니다.

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users}
      format.json { render json: @users}
    end
  end
end
```

이 코드에서는 `render xml: @users.to_xml`이 아닌 `render xml: @users`처럼 되어있다는 점에
주목해주세요. Rails는 객체가 문자열 형식이 아닌 경우에 자동적으로 `to_xml`을 호출해줍니다.

필터
-------

필터는 액션의 직전(before), 직후(after), 또는 그 둘 다(around)에 실행되는 메소드입니다.

필터는 상속이 가능하기 때문에 `ApplicationController`에 필터를 설정하면 애플리케이션의 모든 컨트롤러에 적용됩니다.

"before" 필터는 요청 처리를 도중에 중지시킬 수 있으므로 주의해주세요. 자주 사용되는 "before" 필터의
사용법으로 사용자가 액션을 실행하기 전에 로그인을 요구하는 것이 있습니다. 이 필터 메소드는 아래와 같이 될
겁니다.

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url # 처리를 중지한다
    end
  end
end
```

이 메소드는 에러 메시지를 flash에 저장하고 사용자가 로그인하지 않았을 경우에 로그인 페이지로 돌려 보내는
간단한 코드입니다. "before" 필터에 의해서 출력 또는 리다이렉션이 발생하면, 이 액션은 실행되지 않습니다.
필터의 실행 후에 실행될 예정이었던 다른 필터가 있다면, 이 역시 실행이 취소됩니다.

이 예시에서는 필터를 `ApplicationController`에 추가했으므로, 이를 상속하는 모든 컨트롤러에 영향을
주게 됩니다. 다시 말해, 애플리케이션의 모든 기능에 대해서 로그인을 요구하게 됩니다. 당연하지만
애플리케이션의 모든 화면에서 인증을 요구하게 되면, 인증에 필요한 로그인 화면까지 출력할 수 없게 되는
곤란한 상황이 됩니다. 따라서 이렇게 모든 컨트롤러나 액션에 대해서 로그인을 요구해서는 안됩니다.
`skip_before_action`을 사용하면 특정 액션에서 필터의 사용을 막을 수 있습니다.

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

이렇게 작성하는 것으로 `LoginsController`의 `new` 액션과 `create` 액션을 지금까지처럼 인증을
요구하지 않도록 만들 수 있습니다. 특정 액션에서만 필터를 무효화하고 싶은 경우에는 `:only` 옵션을
사용하세요. 반대로 특정 액션에서만 필터를 쓰고 싶은 경우에는 `:except` 옵션을 사용합니다.
이러한 옵션은 필터를 추가할 때에도 사용할 수 있으므로, 처음 선언할 때에 선택된 액션에 대해서만 필터가
실행되도록 만들 수도 있습니다.

### after 필터와 around 필터

"before" 필터 이외에도 액션 실행후에 실행되는 필터나 실행 전후 모두에 실행되는 필터를 사용할 수 있습니다.

"after" 필터는 "before" 필터와 비슷합니다만, "after" 필터의 경우에는 액션이 이미 실행된 상태이며,
클라이언트에 전송할 데이터에 접근할 수 있다는 점이 다릅니다. 당연하지만 "after" 필터를 어떻게
작성하더라도 액션의 실행을 중단할 수는 없습니다.

"around" 필터를 사용하는 경우에는 필터 내부의 어딘가에서 반드시 `yield` 를 실행해서 액션을
실행시켜줘야할 의무가 있습니다. 이것은 Rack 미들웨어의 동작과 비슷합니다.

예를 들어 어떤 변경에 대해서 승인 처리를 하는 웹사이트를 생각해 봅시다. 관리자는 간단하게 이 변경 내용을
미리 확인하고, 트랜잭션 내에서 승인처리를 한다고 합시다.

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private

  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      begin
        yield
      ensure
        raise ActiveRecord::Rollback
      end
    end
  end
end
```

"around" 필터의 경우 화면 출력(랜더링)도 yield에 포함된다는 점에 주의해주세요. 특히 위의 예시로
말하자면 뷰 자신이 데이터베이스로부터 (스코프 등을 통해) 읽기 작업을 하게 되면, 그 작업 역시 트랜잭션에
포함되므로 프리뷰에서 볼 수 있게 됩니다.

일부러 yield를 실행하지 않고 직접 응답을 생성한다는 방법도 존재합니다. 이 경우 액션은 실행되지 않습니다.

### 그 이외의 필터 사용법

가장 일반적인 필터 사용 방법은 private 메소드를 작성하고, *_action을 사용해서 그 메소드를 추가하는
것입니다만, 같은 결과를 얻을 수 있는 방법이 2가지 더 존재합니다.

첫번째는 *_action 메소드에 직접 블록을 넘겨주는 방법입니다. 이 블록은 컨트롤러를 가인수로 가집니다. 위의 `require_login` 필터를 재작성해보죠.

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url
    end
  end
end
```

필터에서 `send` 메소드를 사용하고 있는 점에 주목해주세요. `logged_in?` 메소드는 private이기 때문에
컨트롤러의 스코프에서는 필터가 동작하지 않기 때문입니다(역주: `send` 메소드를 사용하면 private 메소드를
호출할 수 있습니다). 이 방법은 특정 필터를 구현하는 방법으로서는 권장되지 않습니다만, 간결하게 작성하고
싶은 경우에는 도움이 될 수도 있습니다.

두번째 방법은 클래스를 사용해서 필터를 구현하는 것입니다(실제로는 특정 메소드에 올바르게 응답하는 객체라면
무엇이든 괜찮습니다). 다른 두가지 방법으로 구현하면 읽기도 어렵고, 재사용하기도 힘든 경우에 유용합니다.
예를 들어 로그인 필터를 클래스를 사용하는 방식으로 변경해봅시다.

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

반복하지만, 이 예시는 필터로서는 이상적인 구현이 아닙니다. 왜냐하면 이 필터는 컨트롤러가 인자로서 넘겨받을
뿐 아니라, 컨트롤러의 스코프에서 동작하지 않습니다. 이 필터 클래스에는 필터와 같은 이름의 메소드가 구현될
필요가 있습니다. 따라서 `before_action` 필터의 경우, 클래스에 `before` 메소드를 구현할 필요가
있습니다. `around` 메소드에서는 `yield`로 액션을 실행해야 한다는 것도 잊지 마세요.

Request Forgery 방어
--------------------------

CSRF(Cross Site Request Forgery)는 악의있는 웹사이트가 사용자를 속이고, 공격 목표 웹사이트에
위험한 요청을 몰래 전송하는 공격방법 중 한가지 입니다. 공격자는 대상에 대한 지식이나 권한을 가지고 있지
않더라도, 목표 사이트에 대해서 데이터를 추가/변경/삭제를 할 수 있습니다.

이 공격을 방어하기 위해서 필요한 첫번째 방법은, 절대로 GET 요청을 통해서
'create/update/destroy'와 같은 파괴적인 조작을 하지 않는 것입니다. 웹 애플리케이션이
RESTful 규칙을 따르고 있다면 이미 이 기준을 통과합니다. 그러나 악의적인 웹사이트는 GET 이외의 요청을
목표 사이트에 전송하는 것도 간단히 해낼 수 있습니다. Request Forgery 방어는 바로 그것을 막기 위한
것입니다. 말 그대로 요청을 위조(forgery)로 부터 보호합니다.

구체적으로는 추측 불가능한 토큰을 서버에 들어오는 모든 요청에 추가합니다. 요청이 포함하고 있는 토큰이
올바르지 않다면 접근을 거부합니다.

아래와 같은 폼을 생성해보죠.

```erb
<%= form_for @user do |f| %>
  <%= f.text_field :username %>
  <%= f.text_field :password %>
<% end %>
```

이와 같이 토큰이 보이지 않는 필드로 추가되어있는 것을 알 수 있습니다.

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- 필드 목록 -->
</form>
```

Rails에서는 [Form 헬퍼](form_helpers.html)를 사용해서 생성된 모든 폼에 토큰을 추가합니다.
Form 헬퍼를 사용하지 않고 직접 작성한 경우나, 다른 이유로 토큰이 필요한 경우에는
`form_authenticity_token` 메소드를 통해 토큰을 생성할 수 있습니다.

`form_authenticity_token`메소드는 유효한 인증 토큰을 생성합니다. 이 메소드는 커스텀 Ajax 호출
등, Rails가 자동으로 토큰을 생성해주지 않는 장소에서 사용할 때에 유용합니다.

이 가이드의 [보안 가이드](security.html)에서는 이 주제를 포함한 많은 보안 문제에 대해서 언급하고
있으며, 그 모두는 웹 애플리케이션 개발할 때에 반드시 읽어야 하는 것입니다.

요청 객체와 응답 객체
--------------------------------

모든 컨트롤러에는 현재 실행중인 요청과 관련된 요청 객체와 응답 객체를 가리키는 2개의 접근 메소드가
있습니다. `request` 메소드는 `ActionDispatch::Request` 클래스의 인스턴스를 포함하고,
`response` 메소드는 현재 클라이언트에게 돌려줄 내용을 가지고 있는 응답 객체를 돌려줍니다.

### `request` 객체

요청 객체에는 브라우저로부터 전송된 요청에 대한 유용한 정보가 다수 포함되어 있습니다. 사용 가능한 메소드를
모두 알고 싶은 경우에는 [Rails API 문서](http://api.rubyonrails.org/classes/ActionDispatch/Request.html)와
[Rack 문서](http://www.rubydoc.info/github/rack/rack/Rack/Request)를
참조해주세요. 여기에서는 그 중에서 몇 가지를 소개합니다.

| `request`의 속성                            | 목적                                                                              |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| host                                      | 요청에 사용된 호스트 이름                                                              |
| domain(n=2)                               | 호스트의 이름(TLD)의 우측으로부터 `n`번째 세그먼트                                          |
| format                                    | 클라이언트로부터 요청받은 Content-Type                                                  |
| method                                    | 요청에서 사용된 HTTP 메소드                                                            |
| get?, post?, patch?, put?, delete?, head? | HTTP메소드가 GET/POST/PATCH/PUT/DELETE/HEAD 중 각각 맞는 메소드에 해당하는 경우 true를 돌려줌 |
| headers                                   | 요청에 포함되어있는 헤더를 포함하는 해시를 돌려줌                                            |
| port                                      | 요청에 사용된 포트 번호(정수)                                                          |
| protocol                                  | 사용된 프로토콜을 포함한 주소 문자열을 돌려줌(예를 들어, "http://....." 이런 형태)               |
| query_string                              | URL에서 사용된 쿼리 문자열("?" 뒷 부분)                                                 |
| remote_ip                                 | 클라이언트의 ip 주소                                                                 |
| url                                       | 요청에서 사용된 URL 전체                                                              |

#### `path_parameters`, `query_parameters`, `request_parameters`

Rails는 요청 시에 받은 쿼리 문자열, 또는 POST로 받은 값 등을 모두 `params` 해시에 모아줍니다.
Request 객체에는 3개의 접근자가 있으며 매개 변수의 출처에 따라 접근할 수도 있습니다.
`query_parameters` 해시에는 쿼리 문자열로 전송된 매개 변수가 포함됩니다. `request_parameters`
해시에는 POST 본문에 포함된 매개 변수가 들어있습니다. `path_parameters`에는 라우팅에 따라 특정
컨트롤러와 액션에 대한 경로로 인식된 매개 변수가 포함됩니다.

### `response` 객체

response 객체는 액션이 실행 될 때에 생성되며, 클라이언트에 돌려줄 데이터를 랜더링하기 위한 것이므로,
response 객체를 직접 사용할 일은 그다지 없습니다. 하지만 때때로 (예를 들자면, after filter에서)
response 객체를 직접 조작할 수 있다면 편리할 겁니다. response 객체의 접근 메소드들은
세터(setter)도 가지고 있으므로, 이를 사용해서 response 객체의 값들을 직접 변경할 수 있습니다.
사용 가능한 전체 메소드 목록을 확인하고 싶다면 [Rails API 문서](http://api.rubyonrails.org/classes/ActionDispatch/Response.html)와
[Rack 문서](http://www.rubydoc.info/github/rack/rack/Rack/Response)를
참조해주세요.

| `response`의 속성        | 목적                                              |
| ---------------------- | ------------------------------------------------ |
| body                   | 클라이언트에 돌려줄 데이터의 문자열. 대부분의 경우 HTML       |
| status                 | 응답의 HTTP 상태 코드(200 OK, 404 file not found 등)  |
| location               | 리다이렉션을 할 URL                                  |
| content_type           | 응답의 Content-Type                                |
| charset                | 응답에 사용될 문자셋. 기본은 "utf-8"                    |
| headers                | 응답에 사용될 헤더들                                  |

#### 커스텀 헤더 설정하기

응답에서 커스텀 헤더를 사용하고 싶은 경우에는 `response.headers`를 사용할 수 있습니다.
이 헤더 속성은 해시이며, 헤더명과 값이 그 내부에 들어있으며, 이미 몇몇 값들이 Rails에 의해 자동으로
저장되어 있습니다. 헤더를 추가, 변경하고 싶은 경우에는 아래와 같이 `response.headers`에 할당하면
됩니다.

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTE: 이렇게 하고 싶은 경우에는 `content_type` 세터를 직접 사용하는 것이 바람직합니다.

HTTP 인증
--------------------

Rails에는 2가지의 HTTP인증 기능이 내장되어 있습니다.

* BASIC 인증
* 다이제스트 인증

### HTTP BASIC 인증

HTTP BASIC 인증은 인증 방식의 일종으로, 많은 브라우저 및 HTTP 클라이언트에서 지원되고 있습니다.
예를 들어 웹 애플리케이션에는 관리 화면이 있고, 브라우저의 HTTP BASIC 인증 창에서 사용자의 이름과
비밀번호를 입력하지 않으면 접근할 수 없도록 만들고 싶다고 해봅시다. 이 내장 인증 기능은 무척 간단하게
사용할 수 있습니다. 필요한 것은 `http_basic_authenticate_with` 뿐입니다.

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

이 때 `AdminsController`를 상속한 컨트롤러를 만들어도 좋습니다. 이 필터는 해당하는 컨트롤러의
모든 액션에서 실행되므로, 그 HTTP BASIC인증을 통해 보호할 수 있습니다.

### HTTP 다이제스트 인증

HTTP 다이제스트 인증은 BASIC 인증 보다도 고도의 인증 시스템으로 암호화지 않은 평문 패스워드를
네트워크를 통해 전송하지 않아도 된다는 장점이 있습니다(BASIC인증도 HTTPS를 통하면 안전해집니다).
Rails에서는 다이제스트 인증 역시 간단하게 사용할 수 있습니다. 
authenticate_or_request_with_http_digest` 메소드를 사용하세요.

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private

    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

위의 예제에서 볼 수 있듯, `authenticate_or_request_with_http_digest`의 블록 내에서는
가인수를 하나(사용자 이름)밖에 받을 수가 없습니다. 그리고 블록에서는 패스워드가 반환됩니다.
`authenticate_or_request_with_http_digest`에서 `nil` 또는 `false`가 반환된 경우에는
인증이 실패합니다.

스트리밍과 파일 다운로드
----------------------------

HTML을 출력하지 않고, 사용자에게 파일을 직접 전송하고 싶은 경우가 있습니다. `send_data` 메소드와
`send_file` 메소드는 Rails의 모든 컨트롤러에서 사용 가능하며, 둘 다 스트림 데이터를 클라이언트에게
전송하기 위해서 사용됩니다. `send_file`은 디스크 상의 파일명을 얻거나, 파일의 내용을 스트리밍하는 등
편리한 메소드입니다.

클라이언트에 데이터를 전송하고 싶은 경우에는 `send_data`를 사용합니다.

```ruby
require "prawn"
class ClientsController < ApplicationController
  # 클라이언트에 대한 정보를 포함한 PDF를 생성해 돌려줍니다.
  # 사용자는 PDF를 파일 다운로드로 얻을 수 있습니다.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private

    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Address: #{client.address}"
        text "Email: #{client.email}"
      end.render
    end
end
```

위의 예제에서 `download_pdf` 액션에서 private 메소드가 호출되어 실제 PDF 생성은 private
메소드에서 실행됩니다. PDF는 문자열의 형태로 반환됩니다. 이어서, 이 문자열은 클라이언트에 대해서 파일
다운로드 형태로 전송됩니다. 이때 저장용 파일명 역시 클라이언트에 표시됩니다. 스트리밍 전송할 파일을
클라이언트에 파일로서 다운로드하지 못하게 하고 싶은(파일로 저장하지 못하게 하고 싶은) 경우가 있습니다.
때때로 HTML 페이지에 삽입 가능한 이미지 파일을 촬영했다고 가정합시다. 이때 브라우저에 대해서 이 파일이
저장용이 아니라는 것을 알리기 위해서 `:disposition` 옵션에 "inline"을 지정합니다. 반대의 옵션은
"attachment"로 이것은 전송시의 기본 설정입니다.

### 파일 전송하기

서버에 있는 파일을 전송하기 위해서는 `send_file` 메소드를 사용합니다.

```ruby
class ClientsController < ApplicationController
  # 디스크에 생성, 저장된 파일을 전송
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

파일은 4KB씩 나누어서 스트리밍으로 전송됩니다. 이것은 커다란 파일을 한번에 메모리에 읽지 않게 하기
위함입니다. 이 나눠 읽기는 `:stream` 옵션에서 끌 수 있습니다. `:buffer_size` 옵션에 이 블럭
사이즈를 지정할 수도 있습니다.

`:type` 옵션이 미지정인 경우 `:filename`으로 넘겨받은 파일을 보고 추측합니다. 확장자에 해당하는
Content-Type이 Rails에 등록되어있지 않은 경우, `application/octet-stream`가 사용됩니다.

WARNING: (params나 cookie 등의) 클라이언트에서 전송된 데이터를 사용해 서버에 있는 파일을 지정할
경우, 충분한 주의해주세요. 클라이언트에서 악의있는 파일 경로를 넘겨받아 개발자가 의도하지 않은 파일에
접근하여 보안 상의 위험을 초래할 수 있다는 것을 염두해주세요.

TIP: 정적으로 제공되는 파일을 일부러 Rails를 통해서 전송하는 것은 권장하지 않습니다. 대부분의 경우,
웹서버의 public 폴더에 두고, 다운로드하도록 하면 됩니다. Rails를 경유해서 다운로드하는 것보다도
Apache 등의 웹서버로부터 직접 다운로드하도록 두는 것이 훨씬 효율적이며, 나아가 Rails 전체를 경유하는
불필요한 요청을 받지 않아도 되기 때문입니다.

### RESTful한 다운로드

`send_data`만으로도 문제없이 사용할 수 있습니다만, 제대로 된 RESTful의 애플리케이션을 만들고 싶다면,
파일 다운로드용 액션을 추가할 필요는 없습니다. REST라는 용어에는 위의 예제에서 사용된 PDF 파일와 같은
것들은 클라이언트 리소스를 다른 형태로 표현했을 뿐으로 보기 때문입니다. Rails에는 이에 기반한
"RESTful 다운로드"를 간단하게 실현하기 위해서 세련된 방법을 준비해두고 있습니다. PDF 다운로드를
스트리밍으로 다루지 않고, `show` 액션의 일부로 다루도록 하면 됩니다.

```ruby
class ClientsController < ApplicationController
  # 사용자는 리소스를 전송받을 때에 HTML 또는 PDF를 요청할 수 있음
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

또한 이 예제가 실제로 동작하기 위해서는 Rails의 MIME type에 PDF를 추가해야 합니다. 이를 위해서는
`config/initializers/mime_types.rb`에 다음의 코드를 추가합니다.

```ruby
Mime::Type.register "application/pdf", :pdf
```

NOTE: Rails의 설정 파일은 처음 기동할 때에만 읽힙니다('app/' 이하의 파일들처럼 요청때마다 다시
읽히지 않습니다). 추가한 설정을 반영하기 위해서는 서버를 다시 시작할 필요가 있습니다.

이것으로 아래와 같이 URL에 ".pdf"를 추가하는 것으로 PDF 파일을 다운로드 받을 수 있습니다.

```bash
GET /clients/1.pdf
```

### 임의의 데이터를 라이브 스트리밍하기

Rails는 파일 이외의 것을 전송할 수도 있습니다. 실제로 response 객체에 포함 가능한 것이라면 무엇이든
전송할 수 있습니다. `ActionController::Live` 모듈을 사용하면, 브라우저와 영속적인 연결을 생성할
수 있습니다. 이를 통해 언제라도 원하는 타이밍에 임의의 데이터를 브라우저에 전송할 수 있습니다.

#### 라이브 스트리밍을 사용하기

컨트롤러 클래스에 `ActionController::Live`를 추가하면, 그 컨트롤러의 모든 액션에서 데이터를
스트리밍할 수 있게 됩니다. 이 모듈을 아래와 같이 믹스인합니다.

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

이 코드에서는 브라우저와에 영속적인 연결을 확립하고, 1초마다 `"hello world\n"`를 100번 전송합니다.

단, 주의해야할 점이 몇가지 있습니다. 응답은 스트림이 확실히 닫히도록 해야합니다. 스트림을 닫지 않게 되면,
소켓이 영원히 열려있는 상태로 방치됩니다. 응답 스트림에 데이터를 전송하기 전에 Content-Type을
`text/event-stream`으로 설정할 필요가 있습니다. 그 이유는 응답을 확정해버리면(`response.committed`이
true를 돌려줄 때), 이후에 헤더 값을 변경할 수 없기 때문입니다. 이것은 응답 스트림에 대해서 `write`
또는 `commit`을 호출했을 경우에 발생합니다.

#### 사용 예시

지금 당신은 노래방 기계를 개발중입니다. 사용자는 곡의 가사를 보고 싶어합니다. 각각의 `Song`에는 몇몇의
행(行)이 있으며, 각 행마다 '곡이 끝날때까지 몇 박자가 남았는가'를 가리키는 `num_beats`가 저장되어
있습니다.

가사를 '노래방 스타일'로 사용자에게 보여주고 싶기 때문에, 직전의 가사를 다 부르고 난 뒤에 다음 가사를
보여주어야 합니다. 이 때 아래와 같이 `ActionController::Live`를 사용할 수 있습니다.

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

이 코드에서는 고객이 직전에 가사를 다 부르고 난 뒤에 그 다음 가사를 전송하게 됩니다.

#### 스트리밍을 하는 경우 고려해야할 부분

임의의 데이터를 스트리밍할 수 전송할 수 있다는 것은 무척 강력한 도구입니다. 지금까지 예제에서 소개했듯이,
필요할 때에 필요한 응답을 스트림을 통해 전송할 수 있습니다. 단, 아래의 항목들을 조심해주세요.

* 응답 스트림을 하나 만들 때마다 새로운 스레드가 생성되고, 원래의 스레드로부터 스레드 지역 변수가 복사됩니다. 스레드 지역 변수가 증가하게 되면 성능에 영향을 미칠 수 있습니다. 또한 스레드 자체가 너무 많아도 마찬가지로 성능 저하의 요인이 될 수 있습니다.
* 응답 스트림을 닫지 못하면, 대응하는 소켓을 영원히 열어둔 채로 방치되게 됩니다. 응다 스트림을 사용하는 경우에는 반드시 `close`를 호출해주세요.
* WEBrick 서버는 모든 응답을 버퍼링하기 때문에 `ActionController::Live`를 사용할 수 없습니다. 그러므로 자동적으로 버퍼링을 하지 않는 웹 서버를 사용할 필요가 있습니다.

로그 필터링
-------------

Rails의 로그파일은 `log` 폴더 밑에 환경마다 하나씩 생성됩니다. 디버그 시에 애플리케이션에서 무슨 일이
발생하기 있는지 확인할 때에 무척 편리합니다만, 실제 애플리케이션에서 고객의 비밀번호와 같은 중요한 정보를
로그 파일에 출력하고 싶지 않을 때도 있습니다.

### 매개 변수를 필터링하기

Rails 애플리케이션의 설정 파일 config.filter_parameters을 통해 특정 요청 매개 변수의 값을
로그에 저장하지 않도록 설정할 수 있습니다. 필터링된 매개 변수는 로그에서 [FILTERED]라는 문자열로
변환됩니다.

```ruby
config.filter_parameters << :password
```

NOTE: 제공된 매개 변수들은 부분 매칭 정규 식으로 처리됩니다. Rails는 기본으로 `:password`를 적당한
      initializer(`initializers/filter_parameter_logging.rb`)에서 제공하여 일반적인
      애플리케이션에서 많이 사용하는 `password`와 `password_confirmation`를 처리해줍니다.

### 리다이렉션을 필터링하기

애플리케이선에서 발생하는 리다이렉션 URL중 몇가지는 상황에 따라 로그를 출력하지 않는 것이 좋을 경우도
있습니다. 이럴 때는 설정의 `config.filter_redirect` 옵션을 사용해서 리다이렉션 정보를 로그에
출력하지 않도록 만들 수 있습니다.

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

필터링하고 싶은 리다이렉션의 URL은 문자열, 정규표현, 또는 둘다를 포함하는 배열을 통해 지정할 수 있습니다.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

매칭되는 URL은 로그에서 '[FILTERED]'로 변환됩니다.

Rescue
------

어떤 애플리케이션에도 어딘가에 버그가 존재하며, 이를 적절한 처리를 통해 에러를 던질 필요저장 있습니다.
예를 들어 사용자가 데이터베이스에 이미 존재하지 않은 리소스에 접근하는 경우, 액티브 레코드는
`ActiveRecord::RecordNotFound` 예외를 던집니다.

Rails의 기본 예외 처리에서는 예외의 종류에 관계없이 "500 Server Error"를 표시합니다. 요청이
로컬 환경의 브라우저에서 이루어진 경우에는 상세한 추적 정보가 표시되므로 문제를 파악하고, 대응할 수 있게
됩니다. 요청이 원격 브라우저에서 왔을 경우 Rails는 "500 Server Error"라는 메시지만을 사용자에게
필요하고, 라우팅이나 코드가 없는 경우 "404 Not Found"를 표시하거나 합니다. 이대로라면 너무 매정한
느낌이 들기 때문에 에러를 잡고, 사용자에게 보여주는 방법을 커스터마이즈 하고 싶습니다. Rails
애플리케이션에서는 예외 처리를 다양한 레벨에서 할 수 있습니다.

### 기본 500, 404 템플릿

배포 환경의 Rails 애플리케이션은 기본으로 404 또는 500 에러 메시지를 출력합니다. 이 메시지는
`public` 폴더에 존재하는 HTML 파일입니다. 각각 `404.html`와 `500.html`라는 이름입니다.
이러한 파일을 커스터마이즈해서 정보를 추가하거나, 레이아웃을 변경할 수 있습니다. 단, 이것은 어디까지나
정적인 HTML파일이므로 RHTML이나 ERB는 사용할 수 없습니다.

### `rescue_from`

에러를 처리하는 동작을 좀 더 세련되게 만들고 싶은 경우에는 `rescue_from`를 사용할 수 있습니다.
이것은 특정 종류의, 또는 여러 종류의 예외를 하나의 컨트롤러 전체 또는 그 자식 클래스에서 다룰 수 있도록
해줍니다.

`rescue_from`로 잡을 수 있는 예외가 발생하면, 핸들러에 예외 객체를 넘길 수 있습니다. 이 핸들러는
메소드나, `:with`  옵션을 사용해 Proc 객체를 직접 넘길 수 있습니다. Proc 객체 대신에 블럭을 직접
넘길 수도 있습니다.

`rescue_from`를 사용하여 모든 `ActiveRecord::RecordNotFound` 에러를 잡아 처리를 하는 예제를
아래에 소개합니다.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

이전보다 조금 더 구조적이 되었습니다만, 이대로라면 기본 에러 처리보다 나아진 점이 없습니다. 하지만
이런식으로 모든 예외를 잡아서 처리하게 된다면 원하는 대로 커스터마이즈할 수 있게 됩니다. 예를 들어
커스텀 예외 클래스를 선언하고, 사용자가 접속 권한을 가지고 있지 않은 컨트롤러에 접근하려고 했을 경우에
예외를 던질 수도 있습니다.

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private

    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      redirect_to :back
    end
end

class ClientsController < ApplicationController
  # 사용자가 클라이언트에 접근할 수 있는 권한을 가지고 있는지 여부를 확인
  before_action :check_authorization

  # 이 액션 내부에서 인증에 대한 부분을 걱정하지 않아도 됩니다.
  def edit
    @client = Client.find(params[:id])
  end

  private

    # 사용자가 인증되지 않은 경우에는 예외를 던집니다.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

WARNING: 특별한 이유 없이 `rescue_from Exception`나 `rescue_from StandardError`를
         사용해서는 안됩니다. 이는 커다란 영향을 미치기 때문입니다(e.g. 개발 환경에서 자세한 에러
         정보를 볼 수 없게 됩니다).

NOTE: Production환경에서 모든 `ActiveRecord::RecordNotFound` 에러는 404 에러 페이지를
      랜더링합니다. 별도의 동작을 실행하고 싶은 것이 아니라면 굳이 처리하지 않아도 됩니다.

NOTE: `ApplicationController` 클래스에서만 처리 가능한 예외가 몇 가지 있습니다. 이는 컨트롤러가
초기화되어 액션이 실행되기 전에 발생하는 예외가 있기 때문입니다.

HTTPS 프로토콜을 강제하기
--------------------

보안상의 이유로, 특정 컨트롤러에 대해서 HTTPS 접속만 사용하도록 강제하고 싶을 때가 있습니다.
컨트롤러에서 `force_ssl` 메소드를 사용하는 것으로 SSL을 강제할 수 있습니다.

```ruby
class DinnerController
  force_ssl
end
```

필터와 마찬가지로 `:only` 옵션이나 `:except` 옵션을 사용해서 컨트롤러 내의 특정 액션에만 보안 접속을
강제할 수 있습니다.

```ruby
class DinnerController
  force_ssl only: :cheeseburger
  # 또는
  force_ssl except: :cheeseburger
end
```

`force_ssl`을 여러 컨트롤러에서 사용하고 싶다면, 애플리케이션 전체에서 HTTPS 접속을 요구하는 편이
좋습니다. 이를 위해서는 환경 파일에서 `config.force_ssl`을 설정하세요.
