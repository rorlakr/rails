
Ruby on Rails 4.2 릴리스 노트
===============================

Rails 4.2 주요 변경점

* Active Job
* 메일 비동기 처리
* Adequate Record
* Web Console
* 외래키 지원

이 릴리스 노트는 주요한 변경점만을 설명합니다. 자잘한 버그 수정이나 변경에 대해서는 CHANGELOG를 참고하거나, GitHub의 Rails 저장소에 있는 [커밋 목록](https://github.com/rails/rails/commits/master)을 참조해주세요.

--------------------------------------------------------------------------------

Rails 4.2로 업그레이드
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것은 좋은 생각입니다. 애플리케이션이 Rails 4.0까지 업그레이드되지 않았을 경우에는 이부터 시작하고, 애플리케이션이 정상적으로 동작하는 것을 충분히 확인한 뒤에 Rails 4.1으로 업데이트 해주세요. 업그레이드의 주의점에 대해서는 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#rails-4-1에서-Rails-4-2로-업그레이드)를 참고해주세요.


주요 변경점
--------------

### Active Job

Active Job란 Rails 4.2에서 채용된 새로운 프레임워크입니다. Active Job이란 [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) 등 다양한 쿼리 시스템의 상단에 위치하는 것입니다.

Active Job API를 사용하여 작성된 잡은 Active Job이 지원하는 어떤 쿼리 시스템에서도 어뎁터를 통하여 실행할 수 있습니다. Active Job은 처음에 잡을 바로 실행하는 인라인 러너(inline runner)로 구성되어 있습니다.

잡의 인수에 Active Record 객체를 넘기고 싶을 수도 있습니다. Active Job에서는 객체 참조를 URI(uniform resource identifiers)로서 넘깁니다. 객체 자신을 마셜링하지는 않습니다. 이 URI는 Rails에 새롭게 도입된 [Global ID](https://github.com/rails/globalid) 라이브러리로 생성되며 잡은 이를 통해서 원래의 객체를 참조합니다. Active Record 객체를 잡의 인수로 넘기게 되면 내부적으로는 단순히 Global ID가 넘겨집니다.

예를 들어, `trashable`이라는 Active Record 객체가 있다고 가정하면 다음과 같이 직렬화를 하지 않고 잡에게 넘길 수 있습니다.

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

자세한 설명은 [Active Job](active_job_basics.html)을 참고해주세요.

### 메일의 비동기 처리

이번 릴리스로 Action Mailer는 Active Job의 위에 배치되었으며 `deliver_later` 메소드를 사용해서 잡 큐로부터 메일을 전송할 수 있게되었습니다. 이를 통해서 큐를 비동기(asynchronous)로 설정하면 컨트롤러나 모델의 동작이 큐에 의해서 블록되지 않게 됩니다(단, 기본으로 사용되는 인라인 큐에서는 컨트롤러나 모델의 동작이 블록됩니다).

`deliver_now` 메소드를 사용하면 메일을 바로 전송할 수 있습니다.

### Adequate Record

Adequate Record란 Active Record의 성능을 향상시키기 위한 다양한 개량들의 총칭이며 이른바 `find`나 `find_by`의 호출, 그리고 일부 Association 관련 쿼리의 동작 속도를 최대 2배 향상시킵니다.

이 개선은 자주 사용되는 SQL 쿼리를 준비된 SQL문(prepared statement)으로서 캐싱하고 동일한 호출이 발생한 경우에 그것을 재활용합니다. 이를 통해 두번째 이후의 호출에서는 쿼리 생성작업시간을 대부분 생략할 수 있게 됩니다. 자세한 설명은 [Aaron Patterson의 글](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html)을 참조해주세요.

Active Record는 지원되는 동작에 대해서 이 Adequate Record를 자동적으로 적용하므로, 개발자가 코드나 설정을 변경할 필요가 없습니다. Adequate Record에서 지원되는 동작의 예시를 아래에서 보입니다.

```ruby
Post.find(1)  # 최초의 호출에서 준비된 SQL문을 생성 및 캐시합니다
Post.find(2)  # 캐시된 SQL문을 나중에 재활용합니다

Post.find_by_title('first post')
Post.find_by_title('second post')

post.comments
post.comments(true)
```

이 예제에서 메소드 호출에 넘기는 값 자체는 준비된 SQL문의 캐시에 포함되지 않는다는 점에 주목하세요. 전체를 캐싱하는 것이 아닌, 캐싱된 SQL문이 값의 플레이스홀더가 되며 값만을 변경할 수 있다는 점이 중요합니다.

아래와 같은 경우에는 캐시가 적용되지 않습니다.

- 모델에 기본 스코프가 설정되어있는 경우
- 모델에 단일 테이블 상속(STI)가 사용되는 경우
- `find`에서 (단일 id가 아닌) id 목록을 탐색하는 경우

```ruby
  # 캐싱되지 않습니다
  Post.find(1, 2, 3)
  Post.find([1,2])
  ```

- `find_by`에서 SQL 조각을 사용하고 있음

```ruby
  Post.find_by('published_at < ?', 2.weeks.ago)
  ```

### Web Console gem

Rails 4.2에서 새로 생성한 애플리케이션에는 기본으로 [Web Console](https://github.com/rails/web-console) gem이 포함됩니다. Web Console gem은 모두 에러 페이지에 인터랙티브하게 조작 가능한 Ruby 콘솔을 추가하며, `console` 뷰와 컨트롤러 헬퍼 메소드를 제공합니다.

에러 페이지에 대화형 콘솔을 사용할 수 있게 되ㅕㄴ서 에러가 발생한 컨텍스트에서 자유롭게 코드를 실행할 수 있게 되었습니다. `console` 헬퍼는 화면 출력이 완료된 최종적인 상태의 컨텍스트에서 대화형 콘솔을 실행합니다. 이 헬퍼는 어떤 뷰나 컨트롤러에서도 자유롭게 호출할 수 있습니다.

### 외래키 지원

마이그레이션용 DSL에서 외래키의 추가/삭제가 지원됩니다. 앞으로는 외래키도 `schema.rb`에 덤프됩니다. 현 시점에서는 외래키가 지원되는 것은 `mysql`, `mysql2`, 그리고 `postgresql` 어댑터입니다.

```ruby
# `authors.id`를 참조하는 `articles.author_id`에 대한 외래키를 추가합니다
add_foreign_key :articles, :authors

# `users.lng_id`를 참조하는 `articles.author_id`에 대한 외래키를 추가합니다
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# `accounts.branch_id`의 외래키를 삭제합니다
remove_foreign_key :accounts, :branches

# `accounts.owner_id`의 외래키를 삭제합니다
remove_foreign_key :accounts, column: :owner_id
```

완전한 설명은 API 문서의 [add_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)와 [remove_foreign_key](http://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)를 참고해주세요.


비호환성
-----------------

이전 버전에서 Deprecated되었던 기능이 삭제되었습니다. 이번 릴리스에서 새롭게 Deprecated된 기능에 대해서는 각 컴포넌트의 정보를 참고해주세요.

다음 변경에 대해서는 업그레이드 전에 대응을 해야합니다.

### `render`에 문자열 인수를 넘기는 경우의 동작 변경

이전에는 컨트롤러의 액션에서 `render "foo/bar"`를 호출한다는 것은 `render file: "foo/bar"`를 호출하는 것과 동드했습니다. 이 동작은 Rails 4.2에서 변경되어서 `render template: "foo/bar"`와 동등해졌습니다. 파일을 지정하고 싶은 경우에는 명시적으로 (`render file: "foo/bar"`)라고 작성해주세요.

### `respond_with`와 클래스 레벨의 `respond_to`에 대해서

`respond_with`와 여기에 대응하는 클래스 레벨의 `respond_to`는 [responders](https://github.com/plataformatec/responders) gem으로 분리되었습니다. 이 기능을 사용하고 싶은 경우에는 Gemfile에 `gem 'responders', '~> 2.0'`를 추가해주세요.

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

인스턴스 레벨의 `respond_to`는 영향을 받지 않습니다.

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### `rails server`의 기본 호스트

[Rack의 변경](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc)에 의해서 `rails server` 명령을 실행할 때에 기본 호스트가 `0.0.0.0`에서 `localhost`로 변경되었습니다. 이 변경은 표준적인 로컬에서의 개발 작업에 영향을 주지는 않습니다. http://127.0.0.1:3000 과 http://localhost:3000 의 동작은 어느 것이든 동일하기 때문입니다.

다만 이번 변경을 통해 다른 PC에서 Rails 서버에 접근할 수는 없게 되었습니다. 예를 들어 development 환경이 가상 머신 위에 있으며, 호스트 머신으로부터 development 환경에 접근하는 경우 등이 그렇습니다. 이러한 경우 서버를 켤 때에 `rails server -b 0.0.0.0`로 설정하여 이전과 동일한 동작을 재현할 수 있습니다.

이전의 동작으로 되돌리고 싶은 경우에는 반드시 방화벽을 적절하게 설정하고, 신뢰할 수 있는 PC만이 개발용 서버에 접근할 수 있도록 해주세요.

### HTML Sanitizer

HTML Sanitizer는 [Loofah](https://github.com/flavorjones/loofah)와 [Nokogiri](https://github.com/sparklemotion/nokogiri)를 기반으로 하는 새로운 구현으로 변경되었습니다. 새로운 Sanitizer는 보다 안전하며, 강력하고 유연합니다.

새로운 알고리즘이 채용되어서 몇몇 오염된 입력을 정제한 결과가 이전과 다를 경우가 있습니다.

이전의 Sanitizer와 완전히 동일한 결과를 얻고 싶은 경우에는 [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) gem을 `Gemfile`에 추가하면 됩니다. 이 gem은 옵트인이므로 Deprecated 경고는 출력되지 않습니다.

`rails-deprecated_sanitizer`의 지원은 Rails 4.2까지만 된다는 점을 주의해주세요. Rails5.0에서는 지원하지 않을 예정입니다.

새로운 Sanitizer의 더 자세한 변경점에 대해서는 [이 블로그의 글](http://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)을 참고해주세요.

### `assert_select`

`assert_select`는 [Nokogiri](https://github.com/sparklemotion/nokogiri)를 기반으로 구현되었습니다.
이로 인해, 이전에는 유효했던 셀렉터의 일부가 지원되지 않습니다. 애플리케이션에서 이를 사용하고 있는 경우에는, 애플리케이션을 변경해야합니다.

*   속성 셀렉터의 값이 영문 이외의 문자가 포함되어 있는 경우에는 값을 인용부호로 감싸야 합니다.

    ```
    # 이전의 동작
    a[href=/]
    a[href$=/]

    # 현재의 동작
    a[href="/"]
    a[href$="/"]
    ```

*   요소의 중첩이 올바르지 않은 HTML을 포함하는 HTML 소스로부터 생성된 DOM에서는 결과가 다를 수 있습니다.

    예시: 

    ``` ruby
    # content: <div><i><p></i></div>

    # 이전의 동작
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # 현재의 동작
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   선택한 데이터에 이스케이프를 해야하는 문자가 포함되어 있지 않은 경우, 비교를 위해 선택된 값은 이스케이프 된 문자(`AT&amp;T` 등)입니다만, 현재는 실제 이스케이프 문자를 쓰지 않고 비교할 수 있게 되었습니다(`AT&T` 등).

    ``` ruby
    # <p>AT&amp;T</p>의 내용의 차이

    # 이전의 동작
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # 현재의 동작
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```


Railties
--------

자세한 변경사항은 [Changelog][railties]를 참조해주세요.

### 삭제된 것들

*   애플리케이션의 제너레이터로부터 `--skip-action-view` 옵션이 삭제되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/17042))

*   `rails application` 명령은 삭제되었습니다. 다른 명령으로 대체되지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/11616))

### Deprecated

*   production 환경에서 `config.log_level`을 미설정한 상태로 두는 것이 Deprecated되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16622))

*   `rake test:all`가 Deprecated되었습니다. 현재는 `rake test`가 추천됩니다(이를 통해 `test` 폴더에 있는 모든 테스트가 실행됩니다).
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   `rake test:all:db`가 Deprecated되었습니다. 현재는 `rake test:db`가 추천됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   `Rails::Rack::LogTailer`가 Deprecated되었습니다.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### 주요 변경점

*   `web-console`이 기본으로 애플리케이션의 Gemfile에 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   모델의 관계를 설정하기 위한 제너레이터에 `required` 옵션이 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   커스텀 설정 옵션을 정의할 때에 사용하는 `x` 네임스페이스가 도입되었습니다.

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    이러한 옵션은 다음과 같이 configuration 객체 전체에서 사용할 수 있습니다.

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   현재의 환경설정을 로딩하기 위한 `Rails::Application.config_for`가 도입되었습니다.

    ```ruby
    # config/exception_notification.yml:
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
development:
      url: http://localhost:3001
      namespace: my_app_development

    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   애플리케이션의 제너레이터에 `--skip-turbolinks` 옵션이 도입되었습니다. 이것은 생성할 때에 Turbolinks를 사용하지 않기 위한 옵션입니다.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   `bin/setup` 스크립트가 도입되었습니다. 이는 애플리케이션의 초기 설정시에 설정을 자동화하기 위한 코드를 작성하는 위치입니다.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   development 환경에서 `config.assets.digest`의 기본값이 `true`으로 변경되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   `rake notes`에 새로운 확장자를 등록하기 위한 API가 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Rails 템플릿에서 사용하는 `after_bundle` 콜백이 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   `Rails.gem_version` 메소드가 도입되었습니다. 이는 `Gem::Version.new(Rails.version)`을 간단히 가져오기 위해서 사용합니다.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

자세한 변경사항은 [Changelog][action-pack]를 참고해주세요.

### 삭제된 것들

*   `respond_with`와 클래스 레벨에서 `respond_to`가 Rails에서 분리되어 `responders` gem(version 2.0)으로 옮겨졌습니다. 이 기능을 계속 사용하고 싶다면 Gemfile에 `gem 'responders', '~> 2.0'`를 추가해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/16526), [자세한 설명](upgrading_ruby_on_rails.html#responders-gem))

*   Deprecated된 `AbstractController::Helpers::ClassMethods::MissingHelperError`가 삭제되었습니다. 앞으로는 `AbstractController::Helpers::MissingHelperError`를 사용해주세요.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Deprecated

*   `*_path` 헬퍼에서 `only_path` 옵션이 Deprecated되었습니다.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   `assert_tag`, `assert_no_tag`, `find_tag`, `find_all_tag`가 Deprecated되었습니다. 앞으로는 `assert_select`를 사용해주세요.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   라우팅의 `:to` 옵션에서, `#`와 같은 문자를 포함하지 않는 심볼이나 문자열의 지원이 Deprecated되었습니다.

    ```ruby
    get '/posts', to: MyRackApp    => (변경할 필요 없음)
    get '/posts', to: 'post#index' => (변경할 필요 없음)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   URL 헬퍼에서 해시의 키에 문자열을 사용하는 것이 Deprecated되었습니다.

    ```ruby
    # 좋지 않은 예시
    root_path('controller' => 'posts', 'action' => 'index')

    # 좋은 예시
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### 주요 변경점

*   `*_filter`에 관련된 메소드들을 문서에서 삭제했습니다. 이 메소드들을 사용하지 말아주세요. 앞으로는 `*_action`을 사용해주세요.

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    애플리케이션이 이러한 메소드에 의존하는 경우에는, `*_action`로 변경해주세요. 이 메소드들은 앞으로 Deprecated될 것이며, 최종적으로 Rails에서 제거될 예정입니다.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de), 
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true`, 그리고 body를 `nil`로 랜더링하는 경우에 응답의 body에 포함되던 공백문자 하나가 삭제되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14883))

*   템플릿의 다이제스트를 자동적으로 ETags에 포함하게 되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   URL 헬퍼에 넘겨지는 세그먼트가 자동적으로 이스케이프됩니다. ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   전역으로 사용해도 좋은 파라미터를 지정하기 위한 `always_permitted_parameters`가 도입되었습니다. 이 설정의 기본값은 `['controller', 'action']`입니다.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   [RFC 4791](https://tools.ietf.org/html/rfc4791)에 기반하여 `MKCALENDAR`라는 HTTP 메소드가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   `*_fragment.action_controller` 통지에 페이로드 상의 컨트롤러 이름과 액션 이름이 포함됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   라우팅 탐색이 애매하게 일치하는 경우 Routing Error 페이지가 개선되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   CSRF에 의한 실패 시 로그 출력을 무효화하는 옵션이 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Rails가 정적인 애셋을 전송하도록 설정되어있는 경우, 브라우저가 gzip 압축을 지원하고 gzip파일이 서버에 존재한다면 애셋의 gzip이 사용되게 됩니다. 애셋 파이프라인은 압축가능한 모든 애셋에서 `.gz` 파일을 기본으로 생성하게 됩니다. gzip 압축된 파일을 전송하여서 애셋에 대한 요청을 고속화할 수 있습니다. Rails가 production 환경에서 애셋을 제공하는 경우 반드시 [CDN](http://guides.rubyonrails.org/asset_pipeline.html#cdns)을 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   통합 테스트 중에 `process` 헬퍼를 호출했을 때, 경로에 '/'를 요구하도록 변경되었습니다. 이전에는 생략할 수 있었습니다만, 이것은 내부 구현의 사이드 이펙트이며, 의도된 기능이 아닙니다.

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end 
    ```

Action View
-----------

자세한 변경사항은 [Changelog][action-view]를 참조해주세요.

### Deprecated

*   `AbstractController::Base.parent_prefixes`는 Deprecated되었습니다. 뷰의 검색 대상을 변경하고 싶은 경우에는 `AbstractController::Base.local_prefixes`를 재정의해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   `ActionView::Digestor#digest(name, format, finder, options = {})`는 Deprecated되었습니다.
   앞으로 인수는 하나의 해시로 넘겨야 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### 주요 변경점

*   `render "foo/bar"`가 확장되어, `render file: "foo/bar"`가 아닌, `render template: "foo/bar"`를 실행하도록 변경되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   폼 헬퍼가 변경되어 인라인 CSS를 가지는 숨겨진 필드를 감싸던 `<div>`요소가 생성되지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   `#{partial_name}_iteration`라는 특수한 지역 변수가 도입되었습니다. 이 지역 변수는 컬렉션의 랜더링할 때에 파셜을 사용합니다. 이를 통해, `#index`나 `#size`, `#first?`나 `last?` 메소드를 사용해 현재의 반복 상태에 접근할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   플레이스 홀더의 국제화(I18n)가 `label`의 국제화와 동일한 규칙을 따릅니다.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

자세한 변경사항은 [Changelog][action-mailer]를 참고해주세요.

### Deprecated

*   Action Mailer의 `*_path` 헬퍼가 Deprecated되었습니다. 앞으로는 반드시 `*_url` 헬퍼를 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   `deliver`와 `deliver!`가 Deprecated되었습니다. 앞으로는 `deliver_now`나 `deliver_now!`를 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### 주요 변경점

*   `link_to`나 `url_for`를 사용하여 절대경로 URL을 생성할 수 있으며, `only_path: false`를 넘길 필요가 없어졌습니다.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   `deliver_later`가 도입되었습니다. 이는 애플리케이션의 큐에 잡으로 넘겨주며, 메일을 비동기적으로 전송합니다.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   `show_previews` 설정 옵션이 추가되었습니다. 이것은 development 환경의 바깥에서 메일러의 프리뷰를 보기 위해서 입니다.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

자세한 변경사항은 [Changelog][active-record]를 참고해주세요.

### 삭제된 것들

*   `cache_attributes`와 비슷한 메소드들이 제거되었습니다. 모든 속성은 앞으로 항상 캐싱됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Deprecated된 `ActiveRecord::Base.quoted_locking_column` 메소드가 삭제되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Deprecated된 `ActiveRecord::Migrator.proper_table_name`가 삭제되었습니다. 앞으로는 `ActiveRecord::Migration`의 `proper_table_name` 인스턴스 메소드를 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   사용되지 않는 `:timestamp` 타입이 삭제되었습니다. 아으로는 항상 투명하게 `:datetime`이 사용됩니다. 이를 통해 XML 직렬화등에서 컬럼의 종류가 Active Record의 외부에서 전송된 경우에 발생하던 부정합이 수정됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### Deprecated

*   `after_commit`와 `after_rollback`에서 에러의 제어하는 것이 Deprecated되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   `has_many :through` Association에서 카운터 캐시 자동 검출이 Deprecated되었습니다(원래부터 정상적으로 동작하지 않았습니다). 앞으로는 `has_many`나 `belongs_to`를 통해서 레코드 전체를 수동으로 카운터 캐싱해야합니다.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   `.find`나 `.exists?`에 Active Record 객체를 넘기는 것이 Deprecated되었습니다. 처음에 객체의 `id`를 호출해야합니다.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270), [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   PostgreSQL에서 시작값을 제외하는 범위값에 대한 (불충분한) 지원이 Deprecated되었습니다. 현재는 PostgreSQL의 Range를 Ruby의 Range 클래스에 사상됩니다. 단, Ruby의 Range 클래스에서는 시작값을 제외할 수 없으므로 이 방법은 완전하게는 실현할 수 없습니다.

    현 시점에서 시작값을 증분(increment)하는 해결방법은 올바르지 않으므로, Deprecated되었습니다. 증분의 방법이 명확하지 않은 서브타입(예: `#succ`는 증분 방법을 정의하지 않음)에 대해서는 시작값을 제외하는 범위 지정에 의해서 `ArgumentError`가 발생합니다.
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   접속이 이루어지지 않은 상태에서의 `DatabaseTasks.load_schema`의 호출이 Deprecated되었습니다. 앞으로는 `DatabaseTasks.load_schema_current`를 사용해주세요.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Replacement를 사용하지 않고 `sanitize_sql_hash_for_conditions`를 사용하는 것이 Deprecated되었습니다. 쿼리를 전송하거나 갱신하는 경우에는 `Relation`를 사용하여주세요.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   `:null`옵션을 건네지 않고 `add_timestamps`나 `t.timestamps`를 사용하는 것이 Deprecated되었습니다. 현재의 초기 값은 `null: true`입니다만,  Rails 5에서는 `null: false`로 변경될 예정입니다.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   `Reflection#source_macro`가 Deprecated되었습니다. 앞으로는 Active Record에서 사용할 필요가 없어졌으므로, 대체안은 없습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   `serialized_attributes`는 Deprecated되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   컬럼이 없는 경우 `column_for_attribute`가 `nil`을 돌려주는 동작이 Deprecated되었습니다. Rails 5.0dptjsms null 객체를 반환할 예정입니다.
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Replacement를 사용하지 않고 인스턴스의 상태에 의존하는 Association(예: 인수를 받는 스코프와 함께 정의되어있는 경우)에서 `.joins`나 `.preload`, `.eager_load`를 사용하는 것이 Deprecated되었습니다.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### 주요 변경점

*   `create_table`가 실행될 때, `SchemaDumper`가 `force: :cascade`를 사용하게 됩니다. 이를 통해 외래키가 적절하다면 스키마가 다시 로딩할 수 있게 됩니다.

*   일대일 관계에서 `:required` 옵션이 추가되었습니다. 이는 관계에서의 존재 확인 검증(validation)을 정의합니다.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty`의 동작이 변경되어, 변경 가능한 값(mutable value)에 대하여 적절한 변경을 검출하게 되었습니다.
    아무것도 변경되지 않았을 경우에는 Active Record 모델에 직렬화된 요소가 저장되지 않습니다. 이러한 변경은 PostgreSQL의 string 컬럼이나 json 컬럼에서도 마찬가지로 동작합니다.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674), [2](https://github.com/rails/rails/pull/15786), [3](https://github.com/rails/rails/pull/15788))

*   현재의 환경의 데이터베이스를 비우는 `db:purge`라는 Rake 태스크가 도입되었습니다.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   레코드가 올바르지 않은 경우에 `ActiveRecord::RecordInvalid`를 반환하는 `ActiveRecord::Base#validate!`가 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   `valid?`의 별칭으로 `validate`가 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch`가 복수의 속성을 한번에 다룰 수 있게 되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   PostgreSQL 어댑터에 PostgreSQL 9.4+의 `jsonb` 데이터 형식이 지원됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   PostgreSQL와 SQLite 어댑터에서 String 형의 기본 255 문자 제한이 사라졌습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   PostgreSQL 어댑터의 컬럼 형 `citext`이 지원됩니다.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   PostgreSQL 어댑터의 사용자 정의 Range 형식이 지원됩니다.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path`와 같은 경로는 앞으로 절대 시스템 경로로 처리되지 않습니다. 절대 경로가 필요한 경우에는 `sqlite3:some/path`와 같은 표기를 사용해주세요
(이전의 `sqlite3:///some/path`는 `some/path`와 같은 상대 경로로 처리됩니다만 이는 Rails 4.1에서 Deprecated되었습니다).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   MySQL 5.6 이상에서 소수점 이하의 초에 대한 지원이 추가되었습니다.
    (Pull Request [1](https://github.com/rails/rails/pull/8240), [2](https://github.com/rails/rails/pull/14359))

*   모델을 출력하는 `ActiveRecord::Base#pretty_print`가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload`의 동작이 `m = Model.find(m.id)`와 동일해졌습니다. 이는 커스터마이즈 된 `SELECT`에 포함된 여분의 속성이 앞으로는 유지되지 않는다는 의미입니다.
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections`이 반환하는 해시의 키가 심볼에서 문자열로 변경되었습니다. ([Pull Request](https://github.com/rails/rails/pull/17718))

*   마이그레이션의 `references` 메소드에서 `type` 옵션이 지원됩니다. 외래키의 종류(`:uuid` 등)을 지정할 수 있습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

자세한 변경 사항은 [Changelog][active-model]을 참조해주세요.

### 삭제된 것들

*   Deprecated된 `Validator#setup`이 삭제되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### Deprecated

*   `reset_#{attribute}`가 Deprecated되었습니다. 앞으로는 `restore_#{attribute}`를 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   `ActiveModel::Dirty#reset_changes`가 Deprecated되었습니다. 앞으로는 `clear_changes_information`을 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### 주요 변경점

*   `valid?`의 별칭으로 `#validate`가 추가되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `ActiveModel::Dirty`에 `restore_attributes` 메소드가 도입되었습니다. 이는 변경되었지만 저장되지 않은 (dirty) 속성을 이전의 값으로 되돌립니다.
    (Pull Request [1](https://github.com/rails/rails/pull/14861), [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password`이 기본으로 공백의 비밀번호를 허용합니다(예: 공백 문자로 구성된 비밀번호).
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   `has_secure_password`로 검증이 활성화된 경우에는 주어진 비밀번호가 72자보다 짧은지를 검증합니다.
    ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

자세한 변경사항은 [Changelog][active-support]를 참고해주세요.

### 삭제된 것들

*   Deprecated된 `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now`가 삭제되었습니다.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Deprecated된 `ActiveSupport::Callbacks`에서 문자열 기반의 종단지정자(terminator)가 삭제되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### Deprecated

*   `Kernel#silence_stderr`, `Kernel#capture`, `Kernel#quietly`가 Deprecated되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   `Class#superclass_delegating_accessor`Deprecated되었습니다. 앞으로는 `Class#class_attribute`를 사용해주세요.
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   `ActiveSupport::SafeBuffer#prepend!`Deprecated되었습니다. 지금은 `ActiveSupport::SafeBuffer#prepend`와 동일한 동작을 합니다.
    ([Pull Request](https://github.com/rails/rails/pull/14529))

### 주요 변경점

*   순서에 의존하는 테스트를 명기하기 위해서 `active_support.test_order` 옵션이 도입되었습니다. 현재, 이 옵션의 기본값은 `:sorted`입니다만, Rails 5.0에서는 `:random`으로 변경될 예정입니다.
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   블럭에서 명시적으로 리시버를 쓰지 않더라도 `Object#try`나 `Object#try!`를 사용할 수 있게 되었습니다.
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830), [Pull Request](https://github.com/rails/rails/pull/17361))

*   `travel_to` 테스트 헬퍼가 `usec` 컴포넌트를 0으로 만듭니다.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   객체 자신을 반환하는 항등 함수로서 `Object#itself`가 도입되었습니다.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810), [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   블럭에서 명시적으로 리시버를 쓰지 않더라도 `Object#with_options`를 사용할 수 있게 되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   단어수를 지정하여 문자열을 자르는 `String#truncate_words`가 도입되었습니다.
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   해시의 값을 변경할 때의 공통 패턴을 간결하게 만들기 위해서, `Hash#transform_values`와 `Hash#transform_values!`가 추가되었습니다. 단, 해시의 키는 변경되지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   언더스코어를 포함하는 함수명을 영어 단어처럼 만드는 `humanize` 헬퍼 메소드가 앞부분의 언더스코어를 제거하게 되었습니다.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   `Concern#class_methods`가 도입되었습니다. `Kernel#concern`와 동일하게 `module ClassMethods`를 대신하는 것이며, `module Foo; extend ActiveSupport::Concern; end`와 같은 코드를 피하기 위한 것입니다.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   자동 로딩이나 리로딩에 대한 [새로운 가이드](constant_autoloading_and_reloading.html)가 추가되었습니다.

크레딧 표기
-------

Rails를 견고하고 안정적인 프레임워크로 만들기 위해 많은 시간을 사용해주신 많은 개발자들에 대해서는 [Rails 기여자 목록](http://contributors.rubyonrails.org/)을 참고해주세요. 이 분들에게 경의를 표합니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
