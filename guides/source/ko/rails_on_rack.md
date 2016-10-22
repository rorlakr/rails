
Rails와 Rack
=============

이 가이드에서는 Rails와 Rack의 관계, Rails와 다른 Rack 컴포넌트간의 관계에 대해서 설명합니다.

이 가이드의 내용:

* Rack의 미들웨어를 Rails에서 사용하는 방법
* Action Pack에서의 미들웨어 스택에 대해서
* 직접 미들웨어 스택을 정의하는 방법

--------------------------------------------------------------------------------

WARNING: 이 가이드는 Rack의 미들웨어, url맵, `Rack::Builder`같은 Rack의 프로토콜이나 개념에 관한 지식이 어느정도 있을 것이라고 가정하고 설명합니다.

Rack 입문
--------------------

Rack은 Ruby의 웹 애플리케이션에 대해서 최소한으로 모듈화 되어 있으며, 응용을 할 수 있는 인터페이스를 제공하고 있습니다. Rack은 HTTP 요청과 응답을 가능한 간단한 방법으로 감싸서 웹서버, 웹 프레임워크, 그 에 상당하는 위치의 소프트웨어(미들웨어라고 불립니다)의 API를 하나의 메소드 호출 형태로 만들어줍니다.

* [Rack API 문서](http://rack.github.io/)

Rack에 대한 설명은 이 가이드의 범주를 넘습니다. Rack에 관한 기본적인 지식이 부족한 경우, 아래의 [리소스](#참고자료)를 확인해주세요.

Rails와 Rack
-------------

### Rack 애플리케이션으로서의 Rails 애플리케이션

`Rails.application`은 Rails 애플리케이션을 Rack 애플리케이션으로 구현한 것입니다. Rack에 준거한 웹서버로, Rails 애플리케이션을 제공하기 위해서는 `Rails.application`객체를 사용해야합니다.

### `rails server`

`rails server` 명령은 `Rack::Server`의 객체를 생성하고, 웹 서버를 실행합니다.

`rails server` 명령은 다음과 같이 `Rack::Server`의 객체를 생성합니다.

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` 클래스는 `Rack::Server` 클래스를 상속하고 있으며, 다음과 같이 `Rack::Server#start`를 호출합니다.

```ruby
class Server < ::Rack::Server
  def start
    ...
    super
  end
end
```

### `rackup`

Rails의 `rails server` 명령 대신에 `rackup` 명령을 사용할 때에는 아래의 내용을 `config.ru`를 작성해서 Rails 애플리케이션의 최상위 폴더에 저장합니다.

```ruby
# Rails.root/config.ru
require_relative 'config/environment'
run Rails.application
```

서버를 실행합니다.

```bash
$ rackup config.ru
```

`rackup`의 옵션에 대해서 자세히 알고 싶을 때에는 다음을 입력하세요.

```bash
$ rackup --help
```

### 개발과 자동 로딩

미들웨어는 한번 불러오고나면 변경되더라도 다시 불러와지지 않습니다. 변경사항을 반영하고 싶은 경우에는 애플리케이션을 재기동해야 합니다.

Action Dispatcher의 미들웨어 스택
----------------------------------

Action Dispatcher에 포함되어 있는 많은 컴포넌트들은 Rack 미들웨어로서 구현되어 있습니다. Rails 내외의 다양한 미들웨어들을 결합하여, 완전한 Rails의 Rack 애플리케이션을 만들기 위해 `Rails::Application`는 `ActionDispatch::MiddlewareStack`을 사용하고 있습니다.

NOTE: `ActionDispatch::MiddlewareStack`는 `Rack::Builder`의 Rails 버전입니다만, Rails 애플리케이션의 요구를 충족하기 위해서 좀 더 유연성을 가지고 있으며, 더 많은 기능을 가지고 있습니다.

### 미들웨어 스택을 확인하기

Rails에는 미들웨어 스택을 확인하기 위한 Rake 태스크가 있습니다.

```bash
$ bin/rails middleware
```

막 생성한 Rails 애플리케이션에서는 다음과 같이 출력될 겁니다.

```ruby
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::RemoteIp
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
run Rails.application.routes
```

기본의 미들웨어(와 그 중에 일부)에 대해서는 [Internal Middlewares](#미들웨어-스택의-내용)을 참고해주세요.

### 미들웨어 스택을 설정하기

미들웨어 스택에 미들웨어를 추가하거나, 삭제 및 변경하려면 `application.rb` 또는 환경마다 존재하는 `environments/<environment>.rb` 파일에서 `config.middleware`를 사용하면 됩니다.

#### 미들웨어를 추가하기

다음 메소드를 사용하여 미들웨어 스택에 새로운 미들웨어를 추가할 수 있습니다.

* `config.middleware.use(new_middleware, args)` - 미들웨어 스택의 가장 아래에 새로운 미들웨어를 추가합니다.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - (첫번째 인수로)지정된 미들웨어의 앞에 새로운 미들웨어를 추가합니다.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - (첫번째 인수로)지정된 미들웨어의 뒤에 새로운 미들웨어를 추가합니다.

```ruby
# config/application.rb

# Rack::BounceFavicon를 가장 마지막에 추가한다
config.middleware.use Rack::BounceFavicon

# ActiveRecord::Executor의 뒤에 Lifo::Cache를 추가한다
# 그리고 Lifo::Cache에 { page_cache: false }를 넘긴다
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### 미들웨어를 교체하기

`config.middleware.swap`를 사용하여 미들웨어 스택에 있는 미들웨어를 다른 것으로 교체할 수 있습니다.

```ruby
# config/application.rb

# Lifo::ShowExceptions를 ActionDispatch::ShowExceptions로 교체한다.
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### 미들웨어를 삭제하기

애플리케이션의 설정에 다음의 코드를 추가해주세요.

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

미들웨어 스택을 확인하면 `Rack::Runtime`가 없어졌다는 것을 확인할 수 있습니다.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
use Rack::Runtime
...
run Rails.application.routes
```

세션 관련 미들웨어를 삭제하고 싶은 경우에는 다음과 같이 작성하면 됩니다.

```ruby
# config/application.rb
config.middleware.delete "ActionDispatch::Cookies"
config.middleware.delete "ActionDispatch::Session::CookieStore"
config.middleware.delete "ActionDispatch::Flash"
```

브라우저 관련 미들웨어를 삭제하고 싶은 경우에는 다음과 같이 작성하면 됩니다.

```ruby
# config/application.rb
config.middleware.delete "Rack::MethodOverride"
```

### 미들웨어 스택의 내용

Action Controller의 기능의 대부분은 미들웨어로서 구현되어 있습니다. 아래에서 각각의 역할을 설명합니다.

**`Rack::Sendfile`**

* X-Sendfile header를 설정합니다. `config.action_dispatch.x_sendfile_header` 옵션을 통하여 설정을 변경할 수 있습니다.

**`ActionDispatch::Static`**

* 정적인 파일을 제공할 때 사용합니다. `config.serve_static_assets`를 `false`로 변경하면 비활성화됩니다.

**`Rack::Lock`**

* `env["rack.multithread"]`를 `false`로 설정하여 애플리케이션을 Mutex로 감쌉니다.

**`ActionDispatch::Executor`**

* 개발 중에 스레드 안전한 코드 리로딩을 위해서 사용됩니다.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* 메모리를 사용한 캐싱을 위해서 사용합니다. 이 캐시는 스레드 안전(thread-safe)하지 않습니다.

**`Rack::Runtime`**

* X-Runtime 헤더를 생성합니다. 이 헤더에는 요청을 처리하는 데에 걸린 시간을 초단위로 표시합니다.

**`Rack::MethodOverride`**

* `params[:_method]`가 존재할 때에 (HTTP의) 메소드를 덮어씁니다. HTTP의 PUT 메소드, DELETE 메소드를 구현하기 위한 미들웨어입니다.

**`ActionDispatch::RequestId`**

* 유일한 id를 생성하여 `X-Request-Id`에 저장합니다. `ActionDispatch::Request#uuid` 메소드도 동일한 id를 사용합니다.

**`Rails::Rack::Logger`**

* 요청을 처리하기 시작했다는 정보를 로그에 알립니다. 요청을 전부 처리하고 나면 모든 로그를 출력합니다.

**`ActionDispatch::ShowExceptions`**

* 애플리케이션이 던지는 예외를 잡고, 예외 처리용의 애플리케이션을 실행합니다. 예외 처리용의 애플리케이션은 사용자가 예외를 보기 쉽도록 가공합니다.

**`ActionDispatch::DebugExceptions`**

* 예외를 로그에 남기고, 로컬에서의 요청인 경우 디버그용 페이지를 출력합니다.

**`ActionDispatch::RemoteIp`**

* IP 스푸핑 공격 여부를 확인합니다.

**`ActionDispatch::Reloader`**

* development 환경에서 코드를 다시 불러오기 위해서 prepare 콜백과 cleanup 콜백을 제공합니다.

**`ActionDispatch::Callbacks`**

* 요청을 처리하기 전, 후에 실행 가능한 콜백을 제공합니다.

**`ActiveRecord::Migration::CheckPending`**

* 적용되지 않은 마이그레이션이 있는지 확인합니다. 미실행된 것이 있으면 `ActiveRecord::PendingMigrationError`를 발생시킵니다.

**`ActionDispatch::Cookies`**

* 쿠키 기능을 제공합니다.

**`ActionDispatch::Session::CookieStore`**

* 세션을 쿠키에 저장합니다.

**`ActionDispatch::Flash`**

* flash 기능을 제공합니다(flash란 연속된 요청간에 값을 공유하는 기능입니다). 이것은 `config.action_controller.session_store`에 값이 설정되어 있을 경우에만 유효합니다.

**`Rack::Head`**

* HEAD 요청을 `GET`으로 변환하여 처리합니다.

**`Rack::ConditionalGet`**

* "조건부 `GET`" (Conditional `GET`) 기능을 제공합니다. "조건부 `GET`"이 활성화되어 있으면, 요청된 페이지에 변경이 없는 경우에 한해서 빈 body를 돌려주게 됩니다.

**`Rack::ETag`**

* body가 문자열만으로 구성된 응답에 대해서, ETag 헤더를 추가합니다. ETag는 캐시의 유효성을 검증할 때에 사용됩니다.

TIP: 이러한 미들웨어는 모두 Rack의 미들웨어 스택에서도 사용할 수 있습니다.

참고자료
---------

### Rack에 대해 자세히 배우기

* [Rack 공식 사이트](http://rack.github.io)
* [Rack 입문](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### 미들웨어를 이해하기

* [Railscast on Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
