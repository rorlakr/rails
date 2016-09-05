
레일스 업그레이드 가이드
===================================

여기에서는 애플리케이션에서 사용되는 Ruby on Rails의 버전을 새로운 버전으로 업그레이드하는 순서에 대해서 설명합니다. 업그레이드의 순서는 레일스의 버전마다 각각 다르게 되어 있습니다.

--------------------------------------------------------------------------------

일반적인 조언
--------------

언급할 필요도 없습니다만, 기존의 애플리케이션을 업그레이드할 때에는 어째서 업그레이드를 해야하는지 이유를
확실히 해야 합니다. 새로운 버전에서 어떤 기능이 필요한지, 기존의 코드를 관리하는 것이 얼마나 곤란한지, 업그레이드에 시간이나 능력은 어느 정도 필요한지, 등 많은 것들을 고려해야 할 필요가 있습니다.

### 테스트의 커버리지

업그레이드 후에 애플리케이션이 정상적으로 동작한다는 것을 확인할 방법으로 좋은 테스트 커버리지를 업그레이드 전에 확보해두는 것이 최선입니다. 애플리케이션을 한번에 확인할 수 있는 자동 테스트가 없다면, 변경점을 모두 손으로 확인해야하므로 막대한 시간이 걸리게 됩니다. 레일스와 같은 애플리케이션의 경우, 이것은 애플리케이션의 수많은 기능을 모두 확인하지 않으면 안된다는 의미입니다. 업그레이드를 하는 경우에는 테스트 커버리지를 충분히 확보해두길 바랍니다.

### 루비 버전

레일스는 그 버전이 릴리스 된 시점의 최신 버전 Ruby에 의존합니다.

* 레일스 5에서는 2.2.2이후의 버전이 필요합니다.
* 레일스 4에서는 루비 2.0가 권장됩니다. 루비 1.9.3 이상이 필요합니다.
* 레일스 3.2.x는 루비 1.8.7이 지원하는 마지막 버전입니다.
* 레일스 3 이상은 루비 1.8.7 이후의 버전이 필요합니다. 이보다 오래된 루비 버전에 대한 지원은 공식적으로 중지되어 있습니다. 가능한 빠르게 업그레이드하시기를 바랍니다.

TIP: 루비 1.8.7 p248과 p249에는 레일스의 작동을 중단시키는 치명적인 마셜링 버그가 있습니다. 루비 Enterprise Edition에서는 1.8.7-2010.02 이후에 이 버그가 수정되었습니다. 루비 1.9 계열을 사용하는 경우 루비 1.9.1는 이미 명백한 세그먼테이션 위반이 발생하므로 사용할 수 없습니다. 1.9.3을 사용해주세요.

### Rake 태스크

Rails에는 `app:update`라는 태스크(4.2 버전 이하라면 `rake rails:update`)가 있습니다. Gemfile에 기재된 레일스의 버전을 변경한 뒤, 이 태스크를 실행해주세요.
이를 통해서, 새로운 버전에 필요한 파일 생성이나, 기존의 파일을 변경하는 것을 인터랙티브하게 진행할 수 있습니다.

```bash
$ bin/rails app:update
   identical  config/boot.rb
       exist  config
    conflict  config/routes.rb
Overwrite /myapp/config/routes.rb? (enter "h" for help) [Ynaqdh]
       force  config/routes.rb
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
    conflict  config/environment.rb
...
```

예상치 않은 변경이 없도록, 반드시 차분을 확인해주세요.

레일스 4.2에서 레일스 5.0으로 업그레이드
-------------------------------------

### 액티브레코드 모델은 기본값으로 ApplicationRecord에서 상속

레일스 4.2에서는 액티브레코드 모델은 `ActiveRecord::Base`로부터 상속한다. 레일스 5.0에서는 모든 모델이 `ApplicationRecord`로부터 상속한다.

새로 도입한 `ApplicationRecord` 클래스가 애플리케이션 안에 있는 모든 모델의 상위클래스(superclass)가 되어서 모든 콘트롤러의 상위클래스가 `ActionController::Base`가 아닌 `ApplicationController`인 것과 일관성을 갖게 되었다. 또한 한군데에서 전체 애플리케이션 모델의 동작을 설정할 수 있다.

레일스 4.2로부터 레일스 5.0으로 업그레이드하는 경우에는 `app/models/` 안에 `application_record.rb`을 만들어서 다음의 내용을 넣을 필요가 있다.

```
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

### 콜백 체인은 `throw(:abort)`로 중단

레일스 4.2에서는 액티브레코드 및 액티브모델 안에서 'before' 콜백이 `false`를 되돌리면, 전체 콜백 체인이 중단되었다. 다른 말로 하면, 따라오는 모든 'before' 콜백과 그 안의 액션은 실행되지 않았다.

레일스 5.0에서는 체인을 중단하고 싶을 때에는 `false`를 반환하는 대신에 반드시 명시적으로 `throw(:abort)` 를 내야 한다.

레일스 4.2로부터 레일스 5.0으로 업그레이드하는 경우에는 이와 같은 콜백이 여전히 콜백 체인이 중단할 것이지만 사용중단 경고(deprecation warning)이 나와서 변경이 발생함을 알린다.

준비가 되었으면 `config/application.rb` 파일에 다음 설정을 추가해 새로운 기능을 사용하고 사용중단 경고를 없앨 수 있다.

    ActiveSupport.halt_callback_chains_on_return_false = false

이 옵션은 액티브서포트 안의 다른 콜백에는 영향을 주지 않는다. 'before' 콜백이 아닌 것은 리턴값으로 연쇄가 중단된 적이 없다.

자세한 설명은 [#17227](https://github.com/rails/rails/pull/17227)을 참고해주세요.

### 액티브잡이 ApplicationJob을 상속

레일스 4.2에서는 ActiveJob이 `ActiveJob::Base`로부터 상속하며, 레일스 5.0에서는 바뀌어서 `ApplicationJob`으로부터 상속한다.

레일스 4.2로부터 레일스 5.0으로 업그레이드하는 경우에는 `app/jobs/`안에 `application_job.rb` 파일을 만들어서 다음의 내용을 넣을 필요가 있다.

```
class ApplicationJob < ActiveJob::Base
end
```

그리고 나서 모든 잡 클래스가 이를 상속하도록 한다.

자세한 설명은 [#19034](https://github.com/rails/rails/pull/19034)을 참고해주세요.

레일스 4.1에서 레일스 4.2로 업그레이드
-------------------------------------

### Web Console gem

우선 Gemfile의 `development` 그룹에 `gem 'web-console', '~> 2.0'`를 추가하고 `bundle install`을 실행해주세요(이 레일스를 과거 버전으로부터 업그레이드하는 경우에는 포함되지 않으므로 수동으로 추가해야합니다). gem 설치가 끝난 후, `<%= console %>`등의 콘솔 헬퍼에 대한 참조를 뷰에 추가하는 것으로 어떤 뷰에서도 콘솔을 사용할 수 있게 됩니다. 이 콘솔은 development 환경의 뷰에서 출력되는 모든 에러 페이지에도 포함됩니다.

### Responders gem

`respond_with`와 클래스 레벨의 `respond_to` 메소드는 `responders` gem으로 추출되었습니다. 이러한 메소드를 사용하고 싶은 경우에는 Gemfile에 `gem 'responders', '~> 2.0'`를 추가해주세요. 이후, `respond_with` 호출, 그리고 클래스 레벨의 `respond_to` 호출은 `responders` gem 없이는 동작하지 않습니다.

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

인스턴스 레벨의 `respond_to`는 이번 업그레이드의 영향을 받지 않으므로, gem을 추가할 필요는 없습니다.

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

자세한 설명은 [#16526](https://github.com/rails/rails/pull/16526)을 참고해주세요.

### 트랜젝션 콜백 에러의 처리

현재, 액티브레코드에서는 `after_rollback`이나 `after_commit` 콜백에서 에러를 다루고 있으며, 예외가 발생한 경우에는 로그 출력만 발생합니다. 다음 버전부터는 이러한 에러를 잡아주지 않게 되므로 주의해주세요.
앞으로는 다른 액티브레코드 콜백과 동일한 에러 처리를 하게 됩니다.

`after_rollback` 콜백이나 `after_commit` 콜백을 정의하면 이 변경에 대한 사용중단 안내가 출력됩니다. 이 변경 내용을 잘 이해하고, 이에 대한 대비가 되었다면 `config/application.rb`에 다음의 설정을 통해서 사용중단 안내가 출력되지 않도록 변경할 수 있습니다.

    config.active_record.raise_in_transactional_callbacks = true

자세한 설명은 [#14488](https://github.com/rails/rails/pull/14488) 또는 [#16537](https://github.com/rails/rails/pull/16537)를 참조해주세요.

### 테스트 케이스의 실행 순서

Rails 5.0의 테스트 케이스는 임의의 순서로 실행될 예정입니다. 이 변경에 대비해서 테스트 실행순서를 명시적으로 지정하는 `active_support.test_order`라는 새로운 설정이 Rails 4.2에서 도입되었습니다. 이 옵션을 사용하여 테스트의 실행 순서를 지금 그대로 하고 싶은 경우에는 `:sorted`를 지정하고, 임의 순서대로 실행하는 것을 지금 도입하고 싶은 경우에는 `:random`를 지정할 수 있습니다.

이 옵션에 값을 주지 않으면 사용중단 안내가 출력됩니다. 사용중단 안내가 출력되지 않게 하려면 test 환경에 다음을 추가하세요.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # `:random`으로 해도 좋습니다.
end
```

### 직렬화된 속성

`serialize :metadata, JSON`등의 임의의 인코더를 사용하는 경우에 직렬화 속성(serialized attribute)에 `nil`를 대입하면, 인코더에서 `nil` 값을 넘기는 것이 아닌 데이터베이스에 `NULL`을 사용하여 저장되도록 변경되었습니다(`JSON` 인코더를 사용하고 잇는 경우에는 `"null"` 등).

### Production 로그 레벨

레일스 5의 production 환경에서는 기본으로 로그 레벨이 `:info`에서 `:debug`로 변경될 예정입니다. 현재 로그 레벨을 변경하고 싶지 않은 경우에는 `production.rb`에 다음의 코드를 추가해주세요.

```ruby
# `:info`를 지정하면 현재의 기본 설정이 사용되며,
# `:debug`를 지정하면 이후의 기본 설정이 사용됩니다
config.log_level = :info
```

### 레일스 템플릿의 `after_bundle`

레일스 템플릿을 사용하고 모든 파일을 (Git 등으로) 버전을 관리하고 있는 경우, 생성된 binstub을 버전 관리 시스템에 추가할 수 없습니다. 이것은 binstub의 생성이 Bundler의 실행 전에 이루어지기 때문입니다.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
$ rake db:migrate

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

이 문제를 피하기 위해서 `git` 호출을 `after_bundle` 블록에서 할 수 있게 되었습니다. 이를 통해서 binstub의 생성이 끝난 뒤 번들러를 실행할 수 있습니다.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### 레일스의 HTML Sanitizer

애플리케이션에서 HTML 조각을 검증하는 새로운 방법이 추가되었습니다. 기존의 일반적인 HTML 스캔에 의한 검증은 이제 Deprecated로 변경되었습니다. 현재 권장되는 방법은 [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer)입니다.

이를 통해, `sanitize`, `sanitize_css`, `strip_tags`, 그리고 `strip_links` 메소드는 새로운 구현을 통해 동작합니다.

새로운 Sanitizer는 내부에서 [Loofah](https://github.com/flavorjones/loofah)를 사용합니다. 그리고 Loofah는 Nokogiri를 사용하고 있습니다. Nokogiri에서 사용하고 있는 XML 파서는 C와 Java 양쪽으로 작성되어 있으므로, 사용하고 있는 Ruby 버전에 관계 없이 작업을 고속화할 수 있습니다.

새로운 Rails에는 `sanitize` 메소드가 변경되었으며 `Loofah::Scrubber`를 사용하는 강력한 검증을 할 수 있게 되었습니다.
[검증의 사용 예시는 여기를 참조하세요](https://github.com/flavorjones/loofah#loofahscrubber)。

`PermitScrubber` 그리고 `TargetScrubber`라는 2개의 처리기가 추가되었습니다.
자세한 설명은 [gem의 Readme](https://github.com/rails/rails-html-sanitizer)를 참조해주세요.

`PermitScrubber`, 그리고 `TargetScrubber`의 문서에는 어떤 요소를 어느 타이밍에 제거할지를 완전히 제어하는 방법이 설명되어 있습니다.

기본의 검증자가 필요한 경우에는 애플리케이션의 Gemfile에 `rails-deprecated_sanitizer`를 추가해주세요.

```ruby
gem 'rails-deprecated_sanitizer'
```

### 레일스의 DOM 테스트

`assert_tag`를 포함하는 [`TagAssertions` 모듈](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/TagAssertions.html)은 [Deprecated](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb)되었습니다. 이후 권장되는 것은 ActionView로부터 [rails-dom-testing gem](https://github.com/rails/rails-dom-testing)로 추출된 `SelectorAssertions` 모듈의 `assert_select` 메소드입니다.


### 필터링된 인증 토큰

SSL 공격을 완화하기 위해서 `form_authenticity_token`이 필터링됩니다. 이를 통해서, 이 토큰은 요청마다 변경됩니다. 토큰 검증은 마스크를 삭제(unmasking)와 그에 이은 복호화(decrypting)에 의해서 이루어집니다. 이 변경으로 rails 애플리케이션 이외의 폼에서 전송되는 정적인 세션 CSRF 토큰에 의존하는 요청을 검증할 때에는 이 필터링된 인증 토큰을 고려할 필요가 있으므로 주의해주세요.

### Action Mailer

기존에는 메일러 클래스에서 메일러 메소드를 호출하면 해당하는 인스턴스 메소드가 직접 실행되었습니다. Active Job과 `#deliver_later` 메소드가 도입됨으로 인해, 이 동작이 변경되었습니다. Rails 4.2에서는 이러한 인스턴스 메소드 호출은 `deliver_now` 또는 `deliver_later`가 호출될 때까지 실행이 지연됩니다. 다음은 예시입니다.

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end

mail = Notifier.notify(user, ...) # Notifier#notify는 이 시점에서 호출되지 않습니다.
mail = mail.deliver_now           # "Called"를 출력합니다.
```

이 변경을 통해서 실행 결과가 크게 달라지는 애플리케이션은 그렇게 많지 않을 것이라고 생각합니다. 단, 메일러 이외의 메소드를 동기적으로 실행하고 싶은 경우, 그리고 기존의 동기적인 프록시 동작에 의존하고 있는 경우에는 이 메소드를 메일러 클래스에 클래스 메소드로서 직접 정의할 필요가 있습니다.

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Foreign Key 지원
마이그레이션 DSL이 외래키 정의를 지원하기 위해서 확장되었습니다. 만약 Foreigner gem을 사용하고 있다면, 이를 제거하는 것을 고려할 수 있습니다. Rails에서 새로 지원하는 외래키 지원은 Foreigner의 일부분입니다. 이는 모든 Foreigner의 정의가 새로운 Rails 마이그레이션 DSL로 완전히 대체될 수 없다는 의미입니다.

변경하는 과정은 다음과 같습니다.

* "foreigner" gem을 Gemfile에서 제거합니다.
* `bundle install`을 실행합니다.
* `bin/rake db:schema:dump`를 실행합니다.
* `db/schema.rb`에 모든 외래키 정의가 필요한 옵션과 함께 포함되어 있는지 확인하세요.

Rails 4.0에서 Rails 4.1로 업그레이드
-------------------------------------

### 리모트 `<script>` 태그에 CSRF 보호를 적용

이를 변경하지 않으면 '어째서인지 테스트를 통과할 수 없어...OTL' 같은 상황이 발생할 수도 있습니다.

JavaScript 응답을 동반하는 GET 요청도 크로스 사이트 리퀘스트 포저리(CSRF) 보호 대상이 되었습니다. 이 보호에 의해서 제3자의 사이트가 중요한 데이터를 탈취할 목적으로 자신의 사이트에 JavaScript URL을 참조하여 실행하려는 시도를 저지할 수 있습니다.

다시 말해, 다음을 사용하는 기능 테스트와 통합 테스트는,

```ruby
get :index, format: :js
```

CSRF 보호를 사용하도록 변경되었습니다. 다음과 같이 변경하여,

```ruby
xhr :get, :index, format: :js
``` 

`XmlHttpRequest`를 명시적으로 테스트해주세요.

JavaScript를 원격의 `<script>` 태그로부터 읽어와야 한다면, 그 액션에서는 CSRF 보호를 꺼주세요.

### Spring

애플리케이션의 프리 로더로서 Spring을 사용하는 경우에는 다음을 실행해야합니다.

1. `gem 'spring', group: :development`를 `Gemfile`를 추가합니다.
2. `bundle install`를 실행해서 Spring을 설치합니다.
3. `bundle exec spring binstub --all`를 실행해서 binstub을 Spring화합니다.

NOTE: 사용자가 정의한 Rake 태스크는 기본으로 development 환경에서 동작하게 됩니다. 이러한 Rake 태스크를 다른 환경에서도 사용하고 싶은 경우에는 [Spring README](https://github.com/rails/spring#rake)를 참고해주세요.

### `config/secrets.yml`

새로운 `secrets.yml`에 비밀키를 저장하고 싶은 경우에는 다음의 순서대로 실행합니다.

1. `secrets.yml`파일을 `config` 폴더에 생성하고, 다음의 내용을 추가합니다.

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. `secret_token.rb` initializer에 작성된 기존의 `secret_key_base`의 비밀키를 꺼내서 SECRET_KEY_BASE 환경변수를 설정하여 Rails 애플리케이션을 production 모드에서 실행하는 모든 사용자가 비밀키를 사용할 수 있게 됩니다. 또는 기존의 `secret_key_base`를 `secret_token.rb` initializer로부터 `secrets.yml`의 production 부분에 복사하고, '<%= ENV["SECRET_KEY_BASE"] %>'를 변경할 수도 있습니다.

3. `secret_token.rb` initializer를 삭제합니다.

4. `rake secret`를 실행해서, `development`와 `test`에서 사용할 키를 새로 생성합니다.

5. 서버를 다시 켭니다.

### 테스트 헬퍼의 변경

테스트 헬퍼에 `ActiveRecord::Migration.check_pending!` 호출이 있는 경우, 이를 삭제할 수 있습니다. 이 확인은 `require 'rails/test_help'`에서 자동으로 이루어지도록 변경되었습니다. 이 호출을 삭제하지 않더라도 악영향을 주지 않습니다.

### Cookies 직렬화

레일스 4.1부터 이전에 생성된 애플리케이션에서는 `Marshal`을 사용하여 cookie값을 서명된, 또는 암호화된 cookies jar로 직렬화되었습니다. 애플리케이션에서 새로운 `JSON` 기반의 형식을 사용하고 싶은 경우에는 다음의 내용을 포함하는 initializer를 추가하세요.

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

이를 통해 `Marshal`에서 직렬화된 기존의 cookies를 새로운 `JSON` 기반의 형식으로 투명하게 넘어갈 수 있습니다.

`:json`또는 `:hybrid` 직렬화를 사용하는 경우, 일부의 Ruby 객체가 JSON으로서 직렬화되지 않을 가능성이 있다는 점에 주의해주세요. 예를 들면, `Date` 객체나 `Time` 객체는 문자열로 직렬화되며, `Hash`의 키도 직렬화됩니다.

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

cookie에는 문자열이나 숫자등의 단순한 데이터만을 저장하기를 권장합니다. cookie에 복잡한 객체를 저장해야하는 경우에는 이후의 요청에서 cookies로부터 값을 가져올 때에 변환에서 귀찮은 문제를 발생시킬 수 있습니다.

cookie 세션 스토어를 사용하는 경우, `session`는 `flash` 해시에 대해서도 이 내용이 해당됩니다.

### Flash 구조 변경

Flash 메시지의 키가 [문자열로 정규화](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1)되었습니다. 심볼 또는 문자열, 어느 것이든 사용할 수 있습니다. Flash의 키를 꺼내면 언제나 문자열이 됩니다.

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# 레일스 < 4.1
flash.keys # => ["string", :symbol]

# 레일스 >= 4.1
flash.keys # => ["string", "symbol"]
```

Flash 메시지의 키는 문자열과 비교해주세요.

### JSON 취급 방식의 변경점

레일스 4.1에서는 JSON를 다루는 방식이 크게 네 가지가 변경되었습니다.

#### MultiJSON의 폐기

MultiJSON는 [그 역할을 다하고](https://github.com/rails/rails/pull/10576) 레일스에서 제거되었습니다.

애플리케이션이 MultiJSON에 직접 의존하고 있는 경우, 다음과 같이 대응할 수 있습니다.

1. 'multi_json'을 Gemfile에 추가합니다. 단, 이 gem은 장래에 사용할 수 없을 수도 있습니다.

2. `obj.to_json`와 `JSON.parse(str)`를 사용해서 MultiJSON을 의존하지 않게 변경합니다.

WARNING: `MultiJson.dump`와 `MultiJson.load`를 각각 `JSON.dump`과 `JSON.load`로 단순히 변환해서는 '안됩니다'. 이러한 JSON gem들의 API는 임의의 Ruby 객체를 직렬화 그리고 역직렬화하기 위한 것이며, 일반적으로 [안전하지 않습니다](http://www.ruby-doc.org/stdlib-2.0.0/libdoc/json/rdoc/JSON.html#method-i-load).

#### JSON gem의 호환성

지금까지의 레일스에서는 JSON gem과의 호환성 문제가 있었습니다. 레일스 애플리케이션에서 `JSON.generate`와 `JSON.dump`를 사용하면 예기치 않은 에러를 발생시키곤 했습니다.

레일스 4.1에서는 레일스 자신의 인코더를 JSON gem으로부터 분리하는 것으로 이러한 문제를 수정했습니다. JSON gem은 앞으로도 정상적으로 동작합니다만, 대신에 JSON gem API으로부터 레일스 특유의 기능에 접근 할 수 없게 되었습니다. 다음은 예시입니다.

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end

>> FooBar.new.to_json # => "{\"foo\":\"bar\"}"
>> JSON.generate(FooBar.new, quirks_mode: true) # => "\"#<FooBar:0x007fa80a481610>\""
```

#### 새 JSON 인코더

레일스 4.1의 JSON 인코더는 JSON gem을 사용하도록 변경되었습니다. 이 변경에 의해 애플리케이션이 받는 영향은 거의 없습니다. 단, 인코더가 재작성되면서 다음의 기능이 삭제되었습니다.

1. 데이터 구조의 순환 검출
2. `encode_json` 훅의 지원
3. `BigDecimal` 객체를 문자가 아닌 숫자로 인코딩하는 옵션

애플리케이션이 이러한 기능에 의존하고 있는 경우에는 [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) gem을 Gemfile에 추가하여 이전의 상태로 되돌릴 수 있습니다.

#### Time 객체의 JSON 형식 표현

일시에 관련된 컴포넌트(`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)를 가지는 객체에 대해서 `#as_json`을 실행하면 기본으로 밀리초 단위의 값이 돌아오도록 변경되었습니다. 밀리초보다 정밀도가 낮은 이전의 방식으로 동작을 되돌리고 싶은 경우에는 initialzer에 다음을 추가해주세요.

```
ActiveSupport::JSON::Encoding.time_precision = 0
```

### 인라인 콜백 블록에서 `return` 사용법

이전의 레일스에서는 인라인 콜백 블록에서 다음과 같이 `return`을 사용하는 것이 허용되었습니다.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # 좋지 않음
end
```

이 동작은 절대 의도된 것이 아닙니다. `ActiveSupport::Callbacks`이 재작성되어, 위와 같은 동작을 레일스 4.1에서는 허용하지 않게 되었습니다. 인라인 콜백 블록에 `return` 문을 작성하면, 콜백 실행시에 `LocalJumpError`가 발생하게 되었습니다.

인라인 콜백 블록에서 `return`을 사용하고 있는 경우, 다음과 같이 리팩토링해서 반환하는 값으로서 평가하도록 해주세요.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # 좋은 코드
end
```

`return`를 사용하고 싶은 경우라면 명시적으로 메소드를 정의하기를 추천합니다.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # 좋은 코드

  private
    def before_save_callback
      return false
    end
end
```

이 변경은 레일스에서 콜백을 사용하고 있는 많은 장소에서 적용됩니다. 이에는 Active Record와 Active Model의 콜백이나 Action Controller의 필터(`before_action` 등)이 포함됩니다.

자세한 설명은 [이 풀 리퀘스트](https://github.com/rails/rails/pull/13271)를 참고해주세요.

### Active Record 픽스쳐에 정의된 메소드

레일스 4.1에서는 각 픽스쳐의 ERB는 독립된 컨텍스트에서 평가됩니다. 이 때문에, 어떤 픽스쳐에서 정의된 헬퍼 메소드는 다른 픽스쳐에서 사용할 수 없습니다.

헬퍼 메소드를 여러 픽스쳐에서 사용하고 싶은 경우에는 4.1에서 새롭게 도입된 `ActiveRecord::FixtureSet.context_class`(`test_helper.rb`)에 포함되는 모듈에 정의해야합니다.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    Digest::SHA2.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end
ActiveRecord::FixtureSet.context_class.send :include, FixtureFileHelpers
```

### I18n 옵션으로 available_locales 목록 사용을 강제

레일스 4.1부터는 I18n 옵션 `enforce_available_locales`의 기본값이 `true`로 변경되었습니다. 이 설정을 통해 I18n에 넘겨지는 모든 로케일은 available_locales 목록에 선언되어 있지 않다면 사용할 수 없습니다.

이 기능을 끄고 I18n에서 모든 종류릐 로케일 옵션을 사용할 수 있게 하려면 다음과 같이 변경하세요.

```ruby
config.i18n.enforce_available_locales = false
``` 

available_locales의 강제는 보안을 위한 것입니다. 다시 말해, 애플리케이션이 파악하지 못한 로케일을 가지는 사용자의 입력이 로케일 정보로서 사용되지 않도록 하는 것입니다. 따라서, 어쩔 수 없는 이유가 존재하지 않는다면 이 옵션을 false로 변경하지 말아주세요.

### 관계에 대한 mutator 메소드 호출

`Relation`에 `#map!`나 `#delete_if` 등의 변경 메소드(mutator method)가 포함되지 않게 되었습니다. 이러한 메소드를 사용하고 싶은 경우에는 `#to_a`를 호출하여 `Array`로 변환한 뒤에 사용해주세요.

이 변경은 `Relation`에 대한 직접적인 변경 메소드를 호출하는 것으로 발생하는 기묘한 버그나 혼란을 막기 위해 이루어졌습니다.

```ruby
# 이전의 호출 방법
Author.where(name: 'Hank Moody').compact!

# 앞으로의 호출 방법
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
``` 

### 기본 스코프의 변경

기본 스코프는 조건을 연결하여 사용하는 경우에 재정의할 수 없게 되었습니다.

이전에서는 모델에 `default_scope`를 정의하면, 동일한 필드로 연쇄된 조건에 의해서 덮어쓸 수 있었습니다. 현재는 다른 스코프와 마찬가지로 병합됩니다.

변경전:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

변경후:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

이전과 동일한 동작으로 되돌리고 싶은 경우에는 `unscoped`, `unscope`, `rewhere`, 그리고 `except`를 사용하여 `default_scope`의 조건을 명시적으로 제거해줄 필요가 있습니다.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### 문자열에서 컨텐츠 추출하기

레일스 4.1의 `render`에 `:plain`, `:html`, `:body` 옵션이 도입되었습니다. 아래와 같이 컨텐츠 형식을 지정할 수 있으므로, 문자열 기반의 컨텐츠 출력에는 이 옵션을 사용하는 것을 추천됩니다.

* `render :plain`를 실행하면 content type은 `text/plain`로 설정됩니다.
* `render :html`를 실행하면 content type은 `text/html`로 설정됩니다.
* `render :body`를 실행한 경우 content type 헤더는 '설정되지 않습니다'.

보안 상의 관점에서 응답의 body에 마크업을 포함하지 않는 경우에는 `render :plain`를 사용해야 합니다. 이를 통해 많은 브라우저가 안전하지 않은 컨텐츠를 이스케이프할 수 있기 때문입니다.

앞으로는 `render :text`가 Deprecated될 예정입니다. 미리 `:plain`, `:html`, `:body` 옵션을 사용하도록 변경해주세요.
`render :text`를 사용하면 `text/html`으로 전송되기 때문에 보안 상의 위험이 발생할 가능성이 있습니다.

### PostgreSQL의 데이터 형식 'json'과 'hstore'에 대해서

레일스 4.1에서는 PostgreSQL의 `json` 컬럼과 `hstore` 컬럼을 문자열을 키로 하는 Ruby의 `Hash`에 대응할 수 있게 되었습니다.
그리고 이전의 버전에서는 `HashWithIndifferentAccess`가 사용되었습니다. 이 변경은 레일스 4.1 이후에는 심볼을 사용하여 이러한 데이터 형식에 접근할 수 없게 된다는 점을 의미합니다. `store_accessors` 메소드는 `json` 컬럼이나 `hstore` 컬럼에 의존하고 있으므로 마찬가지로 심볼로 접근할 수 없게 됩니다. 앞으로는 문자열을 키로서 사용해주세요.

### `ActiveSupport::Callbacks`에서 명시적으로 블록을 사용하기

레일스 4.1부터 `ActiveSupport::Callbacks.set_callback`을 호출할 경우에는 명시적으로 블록을 넘겨야합니다. 이는 `ActiveSupport::Callbacks`이 레일스 4.1 릴리스에 대폭 변경된 것에 따른 것입니다.

```ruby
# 레일스 4.0의 경우
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# 레일스 4.1의 경우
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

레일스 3.2에서 레일스 4.0로 업그레이드
-------------------------------------

레일스 애플리케이션의 버전을 3.2보다 이전인 경우, 우선 3.2로 업그레이드 한 뒤에 레일스 4.0으로 업그레이드를 시작해주세요.

이하의 설명은 애플리케이션을 레일스 4.0으로 업그레이드하기 위한 것들입니다.

### HTTP PATCH

레일스 4에서는 `config/routes.rb`에서 RESTful한 리소스를 선언할 때에, 변경을 위한 HTTP 동사로 `PATCH`가 적용되었습니다. `update` 액션은 이전대로 사용할 수 있으며 `PUT` 요청은 앞으로도 `update` 액션으로 라우팅됩니다.
표준적인 RESTful만을 사용하고 있다면 이에 대한 변경을 할 필요가 없습니다.

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # 변경 불필요: PATCH가 좋지만 PUT 역시 사용할 수 있음
  end
end
```

단, `form_for`를 사용하여 리소스를 변경하고, `PUT` HTTP 메소드를 사용하는 라우팅과 연동하고 있다면 변경해야할 필요가 있습니다.

```ruby
resources :users, do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # 변경이 필요: form_for는 존재하지 않는 PATCH 경로를 찾으려고 시도함
  end
end
```

이 액션이 공개 API에는 사용되고 있지 않고, HTTP 메소드를 자유롭게 변경할 수 있다면, 라우팅을 변경하여 `patch`를 `put` 대신에 사용할 수 있습니다.

Rails 4에서는 `PUT` 요청을 `/users/:id`에 전송하면, 기존과 마찬가지로 `update`에 라우팅됩니다. 이를 위해, 실제의 PUT 요청을 받는 API는 앞으로도 사용할 수 있습니다. 이 경우, `PATCH` 요청도 `/users/:id` 경유로 `update` 액션에 라우팅됩니다.

```ruby
resources :users do
  patch :update_name, on: :member
end
```

이 액션이 공개된 API에서 사용되고 있어서 HTTP 메소드를 자유롭게 변경할 수 없다면, 폼을 분석하여 `PUT`을 대신에 사용할 수 있습니다.

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

PATCH와 이 변경이 이루어진 이유에 대해서는 레일스 블로그의 [이 글](http://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)을 참고해주세요.

#### 미디어 타입에 관한 메모

`PATCH` 동사에 관련된 추가 정보로 [`PATCH`에서는 다른 미디어 형식을 사용할 필요가 있습니다](http://www.rfc-editor.org/errata_search.php?rfc=5789). [JSON Patch](http://tools.ietf.org/html/rfc6902)등이 해당됩니다. 레일스는 JSON Patch를 기본으로 지원하지는 않습니다만, 추가하는 것은 간단합니다.

```
# 컨트롤러에 다음을 추가합니다.
def update
  respond_to do |format|
    format.json do
      # 부분적으로 변경합니다.
      @article.update params[:article]
    end

    format.json_patch do
      # 필요한 변경 작업을 합니다.
    end
  end
end

# config/initializers/json_patch.rb에 다음을 추가
Mime::Type.register 'application/json-patch+json', :json_patch
```

JSON Patch는 최근 RFC에 올라갔으므로 루비 라이브러리는 많지 않습니다. Aaron Patterson의 [hana](https://github.com/tenderlove/hana) gem이 대표적입니다만, 최신의 사양 변경을 모두 지원하는 것은 아닙니다.

### Gemfile

레일스 4.0에서는 `assets` 그룹이 Gemfile에서 삭제되었습니다. 업그레이드를 할 때에는 이 내용을 Gemfile로부터 제거할 필요가 있습니다.  애플리케이션의 `config/application.rb` 파일에 다음을 추가할 필요가 있습니다.

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
``` 

### vendor/plugins

레일스 4.0에서는 `vendor/plugins`을 불러오지 않게 되었습니다. 사용하는 플러그인은 모두 gem으로 만들어서 Gemfile에 추가해야합니다. 이유가 있어서 플러그인을 gem으로 만들 수 없다면, 플러그인을 `lib/my_plugin/*`에 옮기고, 적절한 초기화 작업을 `config/initializers/my_plugin.rb`에서 수행해주세요.

### Active Record

* [관계에 관한 부정합](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6)때문에 레일스 4.0에서는 Active Record에서 identity map이 삭제되었습니다. 이 기능을 애플리케이션에서 사용하고 싶은 경우에는 지금은 영향을 주지 않는 `config.active_record.identity_map`을 삭제할 필요가 있습니다.

* 컬렉션 관계에서의 `delete` 메소드는 인수로 레코드ID를 `Fixnum`나 `String`로 받게 되었습니다. 이를 통해 `destroy` 메소드의 동작과 비슷해졌습니다. 이전에는 이러한 인수를 사용하면 `ActiveRecord::AssociationTypeMismatch` 예외가 발생했습니다. Rails4.0부터는 `delete` 메소드를 사용하면 주어진 ID에 매칭하는 레코드를 자동적으로 찾게 되었습니다.

* 레일스 4.0에서는 컬럼이나 테이블의 이름을 변경하면 관계된 인덱스도 자동적으로 이름이 변경되도록 바뀌었습니다. 인덱스 이름만을 변경하는 마이그레이션을 추가로 작성할 필요가 없어졌습니다.

* 레일스 4.0의 `serialized_attributes` 메소드와 `attr_readonly` 메소드는 클래스 메소드로서만 사용할 수 있도록 변경되었습니다. 이러한 메소드를 인스턴스 메소드로서 사용하는 것은 Deprecated되었으므로 사용하지 말아주세요. 예를 들어, `self.serialized_attributes`는 `self.class.serialized_attributes`처럼 클래스 메소드로서 사용해주세요.

* 기본 인코더를 사용하는 경우 직렬화 속성에 `nil`를 넘기면 YAML 전체에 걸쳐서(`nil` 값을 넘기는 대신에) `NULL`로서 데이터베이스에 저장됩니다(`"--- \n...\n"`).

* 레일스 4.0에서는 Strong Parameters가 도입되면서 `attr_accessible`과 `attr_protected`가 제거되었습니다. 이를 계속해서 사용하고 싶은 경우에는 [Protected Attributes gem](https://github.com/rails/protected_attributes)를 도입하여 부드럽게 업그레이드를 할 수 있습니다.

* Protected Attributes를 사용하지 않는다면 `whitelist_attributes`나 `mass_assignment_sanitizer` 옵션 등, 이 gem에 관련된 모든 옵션을 제거할 수 있습니다.

* 레일스 4.0의 스코프에서는 Proc이나 lambda 등의 호출 가능한 객체를 사용하는 것이 의무가 되었습니다.

```ruby
  scope :active, where(active: true)

  # 이 코드는 다음과 같이 변경해야합니다
  scope :active, -> { where active: true }
```

* `ActiveRecord::FixtureSet`의 도입에 따라, 레일스 4.0에서는 `ActiveRecord::Fixtures` Deprecated 되었습니다.

* `ActiveSupport::TestCase`의 도입에 따라, 레일스 4.0에서는 `ActiveRecord::TestCase`Deprecated 되었습니다.

* 레일스 4.0에서는 해시를 사용하는 기존의 finder API가 Deprecated 되었습니다. 지금까지 finder 옵션을 받고 있던 메소드는 이러한 옵션을 받을 수 없게 됩니다. 예를 들어, `Book.find(:all, conditions: { name: '1984' })`은 권장되지 않습니다. 앞으로는 `Book.where(name: '1984')`을 사용해주세요.

* 동적인 메소드는 `find_by_...`와 `find_by_...!`를 제외하고 모두 Deprecated 되었습니다. 다음으로 변경해주세요.

      * `find_all_by_...`           대신에 `where(...)`를 사용
      * `find_last_by_...`          대신에 `where(...).last`를 사용
      * `scoped_by_...`             대신에 `where(...)`를 사용
      * `find_or_initialize_by_...` 대신에 `find_or_initialize_by(...)`를 사용
      * `find_or_create_by_...`     대신에 `find_or_create_by(...)`를 사용

* 이전의 finder가 배열을 돌려줬던 반면, `where(...)`은 Relation을 돌려줍니다. `Array`가 필요한 경우에는 `where(...).to_a`를 사용해주세요.

* 이와 동등한 메소드가 실행하는 SQL은 이전의 구현과 동일하지 않습니다.

* 이전의 finder를 다시 사용하고 싶은 경우에는 [activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)를 사용할 수 있습니다.

### 액티브리소스

레일스 4.0에서는 Active Resource가 gem으로 추출되었습니다. 이 기능이 필요한 경우에는 [Active Resource gem](https://github.com/rails/activeresource)을 Gemfile에 추가하세요.

### Active Model

* 레일스 4.0에서는 `ActiveModel::Validations::ConfirmationValidator`에 에러가 추가되는 방법이 변경되었습니다. 확인(Confirmation) 검증이 실패한 경우 `attribute`가 아닌 `:#{attribute}_confirmation`에 추가되도록 변경되었습니다.

* 레일스 4.0의 `ActiveModel::Serializers::JSON.include_root_in_json`의 기본값이 `false`로 변경되었습니다. 이로 인해, Active Model Serializers와 Active Record 객체의 기본 동작이 동일해졌습니다. 덕분에 `config/initializers/wrap_parameters.rb` 파일의 다음 옵션을 주석 처리하거나 삭제할 수 있습니다.

```ruby
# Disable root element in JSON by default.
# ActiveSupport.on_load(:active_record) do
#   self.include_root_in_json = false
# end
```

### 액션팩

* 레일스 4.0부터는 `ActiveSupport::KeyGenerator`가 도입되어 서명이 추가된 cookies의 생성과 대조에 사용됩니다. 레일스 3.x로 생성된 기존의 서명된 cookies는 이전의 `secret_token`은 그대로 두고 `secret_key_base`를 새로 추가하여 투명하게 업그레이드할 수 있습니다.

```ruby
  # config/initializers/secret_token.rb
  Myapp::Application.config.secret_token = 'existing secret token'
  Myapp::Application.config.secret_key_base = 'new secret key base'
```

`secret_key_base`를 설정하는 작업은 레일스 4.x로 이전이 100% 완료되어, 레일스 3.x로 롤백할 필요가 완전히 없어졌을 때에 진행해주세요. 이는 레일스 4.x의 새로운 `secret_key_base`를 사용해서 서명된 cookies에는 레일스 3.x의 cookies와의 후방 호환성이 없기 때문입니다. 다른 업그레이드 작업이 완전히 완료되기 전까지는 기존의 `secret_token`를 그대로 두고 `secret_key_base`를 설정하지 않은 채로 Deprecated 경고를 무시하는 선택지도 있습니다.

외부 애플리케이션이나 JavaScript로부터의 레일스 애플리케이션의 서명된 세션 cookies(또는 일반적인 서명된 cookies)를 읽어올 필요가 있는 경우에는 이러한 문제를 해결할 때까지 `secret_key_base`를 설정하지 말아주세요.

* 레일스 4.0에는 `secret_key_base`가 설정되어 있으면 cookie 기반의 세션의 내용이 암호화됩니다. 레일스 3.x에서는 cookies 기반의 세션에는 서명이 되지만, 암호화는 되지 않았습니다. 서명된 cookies는 그 레일스 애플리케이션에서 생성된 것을 확인할 수 있으며, 악의있는 변경을 막는다는 의미에서는 안전합니다. 하지만 세션의 내용은 최종 사용자에게 노출됩니다. 내용을 암호화하는 것으로 이러한 걱정을 제거할 수 있으며, 이에 따른 성능의 저하는 거의 없습니다.

세션 cookies를 암호화하는 방법에 대해서는 [Pull Request #9978](https://github.com/rails/rails/pull/9978)를 참조해주세요.

* 레일스 4.0에서는 `ActionController::Base.asset_path` 옵션이 제거되었습니다. 대신에 애셋 파이프라인 기능을 사용해주세요.

* 레일스 4.0에서는 `ActionController::Base.page_cache_extension` 옵션이 Deprecated되었습니다. 대신에 `ActionController::Base.default_static_extension`를 사용해주세요.

* 레일스 4.0의 Action Pack으로부터 Action과 Page의 캐시 기능이 제거되었습니다. 컨트롤러에서 `caches_action`를 사용하고 싶은 경우에는 `actionpack-action_caching` gem을, `caches_pages`를 사용하고 싶은 경우에는 `actionpack-page_caching` gem을 각각 Gemfile에 추가해주세요.

* 레일스 4.0에서 XML 파라미터 파서가 제거되었습니다. 이 기능이 필요한 경우에는 `actionpack-xml_parser` gem을 Gemfile에 추가해주세요.

* 레일스 4.0의 기본 memcached 클라이언트가 `memcache-client`에서 `dalli`로 변경되었습니다. 업그레이드를 하기 위해서는 `gem 'dalli'`를 `Gemfile`에 추가하세요.

* 레일스 4.0에서는 컨트롤러에서의 `dom_id`와 `dom_class` 메소드가 Deprecated되었습니다(뷰에서 사용하는 것은 문제 없습니다). 그 기능이 필요한 컨트롤러에서는 `ActionView::RecordIdentifier` 모듈을 포함시킬 필요가 있습니다.

* 레일스 4.0에서는 `link_to` 헬퍼에서 `:confirm` 옵션이 Deprecated되었습니다. 대신에 data 속성을 사용해주세요(예시: `data: { confirm: 'Are you sure?' }`).
`link_to_if`나 `link_to_unless` 등에서도 같은 대응이 필요합니다.

* 레일스 4.0에서는 `assert_generates`, `assert_recognizes`, `assert_routing`의 동작이 변경되었습니다. 이러한 단언에서는 `ActionController::RoutingError` 대신에 `Assertion`이 발생하도게 되었습니다.

* 레일스 4.0에서는 이름 있는 라우팅의 정의가 중복되는 경우에 `ArgumentError`가 발생하도록 변경되었습니다. 이 에러는 명시적으로 정의된 이름 있는 라우팅이나 `resources` 메소드에 의해서 발생합니다.다음은 이름 있는 라우팅 `example_path`가 충돌하는 예제를 2개입니다.

```ruby
  get 'one' => 'test#example', as: :example
  get 'two' => 'test#example', as: :example
```

```ruby
  resources :examples
  get 'clashing/:id' => 'test#example', as: :example
```

첫번째 예제에서는 복수의 라우팅에서 같은 이름을 사용하지 않도록 하는 것으로 회피할 수 있습니다. 다음 예제에서는 `only` 또는 `except` 옵션을 `resources` 메소드에서 사용하는 것으로 생성되는 라우팅을 제한할 수 있습니다. 자세한 것은 [라우팅 가이드](routing.html#라우팅-생성을-제한하기)를 참조하세요.

* 레일스 4.0에서는 unicode 문자 라우팅의 추출 방법이 변경되었습니다. unicode 문자를 사용하는 라우팅을 직접 추출할 수 있게 되었습니다.

```ruby
get Rack::Utils.escape('안녕하세요'), controller: 'welcome', action: 'index'
```

이 코드를 다음과 같이 변경하세요.

```ruby
get '안녕하세요', controller: 'welcome', action: 'index'
```

* 레일스 4.0에서 라우팅에서 `match`를 사용하는 경우에는 요청 메소드를 지정하는 것이 필수가 되었습니다. 다음은 예시입니다.

```ruby
  # 레일스 3.x
  match '/' => 'root#index'

  # 이 코드는 다음처럼 변경해야 합니다.
  match '/' => 'root#index', via: :get

  # 또는
  get '/' => 'root#index'
```

* 레일스 4.0부터 `ActionDispatch::BestStandardsSupport` 미들웨어가 제거되었습니다. `<!DOCTYPE html>`은 이미 http://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx 의 표준 모드를 실행하도록 되어있으며, ChromeFrame의 헤더는 `config.action_dispatch.default_headers`로 이동되었습니다.

그러므로 애플리케이션 코드에 있는 이 미들웨어에 대한 참조를 모두 제거해야 합니다.

```ruby
# 예외 발생
config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
```

환경 설정을 확인하고 `config.action_dispatch.best_standards_support`가 있는 경우에 제거해주세요.

* 레일스 4.0의 애셋 사전 컴파일에서는 `vendor/assets`와 `lib/assets`에 있는 비JS/CSS 애셋을 자동적으로 복사하지 않게 되었습니다. 레일스 애플리케이션과 엔진의 개발자는 이러한 애셋을 직접 `app/assets`에 옮기고 `config.assets.precompile`를 지정해주세요.

* 레일스 4.0에서는 요청된 형식이 액션에서 사용할 수 없을 경우에 `ActionController::UnknownFormat`가 발생하게 되었습니다. 기본으로 이 예외는 406 Not Acceptable 응답으로 처리됩니다만, 이 동작을 재정의할 수도 있습니다. 레일스 3에서는 항상 406 Not Acceptable가 반환됩니다. 재정의는 할 수 없습니다.

* 레일스 4.0에서는 `ParamsParser`가 요청 파라미터를 넘기지 않은 경우에 일반적인 `ActionDispatch::ParamsParser::ParseError` 예외가 발생하게 되었습니다. `MultiJson::DecodeError`와 같은 저레벨의 예외 대신에 이 예외를 사용할 수 있습니다.

* 레일스 4.0에서는 URL 프리픽스에서 지정된 애플리케이션에 엔진이 마운트 되어 있는 경우에 `SCRIPT_NAME`가 올바르게 중첩되게 변경되었습니다. 앞으로는 URL 프리픽스의 재정의를 피하기 위해서 `default_url_options[:script_name]`를 설정할 필요가 없습니다.

* 레일스 4.0에서는 `ActionDispatch::Integration`의 도입에 따라 `ActionController::Integration`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::IntegrationTest`의 도입에 따라 `ActionController::IntegrationTest`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::PerformanceTest`의 도입에 따라 `ActionController::PerformanceTest`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::Request`의 도입에 따라 `ActionController::AbstractRequest`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::Request`의 도입에 따라 `ActionController::Request`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::Response`의 도입에 따라 `ActionController::AbstractResponse`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::Response`의 도입에 따라 `ActionController::Response`가 Deprecated되었습니다.
* 레일스 4.0에서는 `ActionDispatch::Routing`의 도입에 따라 `ActionController::Routing`가 Deprecated되었습니다.

### Active Support

레일스 4.0에서는 `ERB::Util#json_escape`의 별칭인 `j`가 폐기되었습니다. 이 별칭 `j`는 이미 `ActionView::Helpers::JavaScriptHelper#escape_javascript`에서 사용되고 있기 때문입니다.

### 헬퍼 로딩 순서

레일스 4.0에서는 다수의 폴더로부터 헬퍼들의 로딩 순서가 변경되었습니다. 이전은 모든 헬퍼를 모아서 알파벳 순서대로 정렬했습니다. 레일스 4.0으로 업그레이드를 하면, 헬퍼는 로딩된 폴더의 순서를 저장하고, 정렬은 각 폴더 내에서 이루어집니다. `helpers_path` 파라미터를 명시적으로 사용하는 경우를 제외하고, 이 변경은 엔진에서 헬퍼를 로딩하는 방법에만 영향을 줍니다. 헬퍼 로딩의 순서에 의존하고 있는 경우에는 업그레이드 이후에 올바른 메소드가 사용되고 있는지 확인할 필요가 있습니다. 엔진이 읽어오는 순서를 변경하고 싶은 경우에는 `config.railties_order=` 메소드를 사용할 수 있습니다.

### Active Record Observer와 Action Controller Sweeper

`Active Record Observer`와 `Action Controller Sweeper`는 `rails-observers` gem으로 분리되었습니다. 이러한 기능이 필요한 경우에는 `rails-observers` gem을 추가해주세요.

### sprockets-rails

* `assets:precompile:primary`와 `assets:precompile:all`이 삭제되었습니다. `assets:precompile`를 대신 사용해주세요.
* `config.assets.compress` 옵션은 예를 들어 다음과 같이 `config.assets.js_compressor`로 변경해야합니다.

```ruby
config.assets.js_compressor = :uglifier
```

### sass-rails

* 인수를 2개 사용하는 `asset-url`이 Deprecated되었습니다. 예를 들어, `asset-url("rails.png", image)`은 `asset-url("rails.png")`로 변경해주세요.

레일스 3.1에서 레일스 3.2로 업그레이드
-------------------------------------

레일스 애플리케이션의 버전이 3.1보다 이전인 경우, 우선 3.1로 업그레이드를 완료한 이후에 레일스 3.2로 업그레이드를 시작해주세요.

### Gemfile

`Gemfile`을 다음과 같이 변경합니다.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

development 환경에 몇몇 새로운 설정을 추가해야합니다.

```ruby
# Active Record의 모델을 대량할당으로부터 보호하기 위해 예외를 발생시킵니다
config.active_record.mass_assignment_sanitizer = :strict

# 쿼리의 실행 계획(Query Plan)을 현재보다 많이 출력합니다
# (SQLite、MySQL、PostgreSQL에서 동작)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`mass_assignment_sanitizer` 설정을 `config/environments/test.rb`에도 추가해야 합니다.

```ruby
# Active Record의 모델을 대량할당으로부터 보호하기 위해서 예외를 발생시킵니다
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

`vendor/plugins`는 레일스 3.2에서 Deprecated되었으며, 레일스 3.0에서는 완전히 삭제되었습니다. 레일스 3.2로 업그레이드할 때에는 필수가 아닙니다만, 미리 플러그인을 gem으로 내보내서 Gemfile에 추가하는 것이 좋습니다. 이유가 있어 gem으로 만들 수 없는 경우라면, 플러그인을 `lib/my_plugin/*`로 옮기고, 적절한 초기화 작업을 `config/initializers/my_plugin.rb`에 추가해주세요.

### Active Record

`:dependent => :restrict` 옵션은 `belongs_to`로부터 삭제되었습니다. 관계로 연결된 객체가 있는 경우에 이 객체를 삭제하고싶지 않은 경우에는 `:dependent => :destroy`를 설정하고, 관계로 연결된 객체의 destroy 콜백에서 연결된 다른 객체가 있는지를 확인한 뒤 `false`를 반환합니다.

레일스 3.0에서 레일스 3.1로 업그레이드
-------------------------------------

레일스 애플리케이션이 3.0보다 이전인 경우, 우선 3.0으로 업그레이드를 완료한 이후에 레일스 3.1로의 업그레이드 작업을 시작해주세요.

다음의 설명은 레일스 3.1.x의 최신판인 레일스 3.1.12로 업그레이드하기 위한 것입니다.

### Gemfile

`Gemfile`를 다음과 같이 변경합니다.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2' 

# 새로운 애셋 파이프라인으로 변경
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# 레일스 3.1에서 jQuery가 기본 JavaScript 라이브러리가 되었습니다
gem 'jquery-rails'
```

### config/application.rb

애셋 파이프라인을 사용하기 위해서 다음을 변경하세요.

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

레일스 애플리케이션에서 리소스의 라우팅에 "/assets" 라우팅을 사용하는 경우, 충돌을 피하기 위해서 다음을 추가하세요.

```ruby
# '/assets'가 기본값
config.assets.prefix = '/asset-files'
``` 

### config/environments/development.rb

RJS의 설정 `config.action_view.debug_rjs = true`을 삭제해주세요.

애셋 파이프라인을 활성화하고 싶은 경우에는 다음 설정을 추가합니다.

```ruby
# 개발환경에서는 애셋을 압축하지 않습니다
config.assets.compress = false

# 애셋에서 가져온 라인을 전개합니다
config.assets.debug = true
```

### config/environments/production.rb

아래의 변경사항은 대부분이 애셋 파이프라인을 위한 것입니다. 자세한 설명은 [애셋 파이프라인](asset_pipeline.html) 가이드를 참조해주세요.

```ruby
# JavaScript와 CSS를 압축합니다
config.assets.compress = true

# 사전 컴파일된 애셋이 발견되지 않는 경우 애셋 파이프라인으로 폴백하지 않습니다
config.assets.compile = false

# 애셋 URL의 다이제스트를 생성합니다
config.assets.digest = true

# Rails.root.join("public/assets")의 기본값
# config.assets.manifest = 해당하는 경로

# 추가 애셋(application.js, application.css 과 모든 비JS/CSS가 추가되어 있음)을 사전 컴파일합니다
# config.assets.precompile += %w( search.js )

# 애플리케이션에 대한 모든 접근을 강제적으로 SSL로 만들고, Strict-Transport-Security와 보안 쿠키를 사용합니다
# config.force_ssl = true
``` 

### config/environments/test.rb

테스트 환겅에 다음을 추가하여 테스트 성능을 향상시킵니다.

```ruby
# Cache-Control를 사용하는 테스트에서 정적인 애셋 서버를 구성하고, 성능을 향상시킵니다
config.serve_static_assets = true
config.static_cache_control = 'public, max-age=3600'
```

### config/initializers/wrap_parameters.rb

중첩된 해시에 파라미터를 포함하고 싶은 경우에는, 이 파일에 다음의 내용을 추가합니다. 새로운 애플리케이션에서는 이것이 기본값입니다.

```ruby
# 이 파일을 변경한 뒤에 반드시 서버를 다시 기동해주세요.
# 이 파일에는 ActionController::ParamsWrapper용의 설정이 포함되어 있으며
# 기본으로 활성화되어 있습니다.

# JSON 용의 파라미터를 감쌉니다. :format에 빈 배열을 설정하는 것으로 무효화할 수 있습니다.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# JSON의 루트 요소를 기본으로 비활성화 한다
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

세로운 세션 키를 설정하거나, 모든 세선을 삭제할지를 선택해야합니다.

```ruby
# config/initializers/session_store.rb에 다음을 설정합니다
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

또는

```bash
$ bin/rake db:sessions:clear
```

###  뷰의 애셋 헬퍼 참조로부터 :cache 옵션과 :concat 옵션을 삭제하기

* Asset Pipeline의 :cache 옵션과 :concat 옵션이 삭제되었습니다. 뷰에서 이 옵션들을 제거해주세요.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
