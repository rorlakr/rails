[Rails on Rack] 루비 웹서버 인터페이스
=============

본 가이드는 Rack과 레일스를 통합하고 다른 Rack 컴포넌트와 인터페이스하는 것을 다룹니다. [[[This guide covers Rails integration with Rack and interfacing with other Rack components.]]]

본 가이드를 읽은 후에 아래와 같은 내용을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* 레일스 Metal 어플리케이션을 작성하는 방법 [[[How to create Rails Metal applications.]]]

* 레일스 어플리케이션에서 Rack 미들웨어를 사용하는 방법 [[[How to use Rack Middlewares in your Rails applications.]]]

* 액션팩의 내부 미들웨어 스택 [[[Action Pack's internal Middleware stack.]]]

* 커스텀 미들웨어 스택을 정의하는 방법 [[[How to define a custom Middleware stack.]]]

--------------------------------------------------------------------------------

WARNING: 본 가이드는 Rack 프로토콜과 미들웨어, url 맵, `Rack::Builder`와 같은 Rack 개념에 대한 관련 지식을 가지고 있는 것으로 가정합니다. [[[This guide assumes a working knowledge of Rack protocol and Rack concepts such as middlewares, url maps and `Rack::Builder`.]]]

[Introduction to Rack] Rack 소개
--------------------

Rack은 루비로 웹어플리케이션을 개발할 때 사용할 수 있는, 최소한의, 모듈방식의, 어댑터로 연결할 수 있는 인터페이스를 제공합니다.
Rack은 가능한한 가장 간단한 방식으로 요청과 응답을 포장하여, 웹서버, 웹프레임워크, 그리고 이들 사이의 존재하는 소프트웨어(미들웨어)에 대한 API를 하나의 메소드 호출로 통합하여 추출한 것입니다. [[[Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call.]]]

- [Rack API Documentation](http://rack.rubyforge.org/doc/)

Rack을 설명하는 것을 본 가이드의 범위를 벗어나는 것입니다. Rack에 대한 기본지식이 없는 경우 아래에 있는 [Resources](#resources)를 점검해 보기 바랍니다. [[[Explaining Rack is not really in the scope of this guide. In case you are not familiar with Rack's basics, you should check out the [Resources](#resources) section below.]]]

Rails on Rack
-------------

### [Rails Application's Rack Object] 레일스 어플리케이션의 Rack 객체

`ApplicationName::Application`은 레일스 어플리케이션의 기본적인 Rack 어플리케이션 객체입니다. 레일스 어플리케이션을 제공하기 위해서는 어떤 Rack 기반의 웹 서버들든지  `ApplicationName::Application` 객체를 사용해야합니다. `Rails.application`은 해당 어플리케이션 객체를 참조합니다. [[[`ApplicationName::Application` is the primary Rack application object of a Rails application. Any Rack compliant web server should be using `ApplicationName::Application` object to serve a Rails application. `Rails.application` refers to the same application object.]]]

### `rails server`

`rails server` 는 `Rack::Server` 객체를 생성하고 웹서버를 실행시키는 기본적인 작업을 수행합니다. [[[`rails server` does the basic job of creating a `Rack::Server` object and starting the webserver.]]]

다음은 `rails server`가 `Rack::Server` 인스턴스를 생성하는 방법입니다. [[[Here's how `rails server` creates an instance of `Rack::Server`]]]

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server`는 `Rack::Server`를 상속받고 `Rack::Server#start` 메서드를 다음과 같은 방식으로 호출합니다. [[[The `Rails::Server` inherits from `Rack::Server` and calls the `Rack::Server#start` method this way:]]]

```ruby
class Server < ::Rack::Server
  def start
    ...
    super
  end
end
```

다음은 미들웨어를 불러오는 방법입니다. [[[Here's how it loads the middlewares:]]]

```ruby
def middleware
  middlewares = []
  middlewares << [Rails::Rack::Debugger] if options[:debugger]
  middlewares << [::Rack::ContentLength]
  Hash.new(middlewares)
end
```

`Rails::Rack::Debugger`는 주로 개발 환경에서만 유용합니다. 다음 표는 불러온 미들웨어 사용에 대한 설명입니다. [[[`Rails::Rack::Debugger` is primarily useful only in the development environment. The following table explains the usage of the loaded middlewares:]]]

| 미들웨어                  | 목적                                                            |
| ----------------------- | ---------------------------------------------------------------|
| `Rails::Rack::Debugger` | 디버거를 시작합니다.
| `Rack::ContentLength`   | response의 바이트 수를 세어 HTTP Content-Length 헤더에 세팅합니다. |

### `rackup`

`rails server` 대신 `rackup`을 사용하기 위해선, 레일즈 어플리케이션 루트 디렉토리의 `config.ru` 파일에 다음의 내용을 넣습니다.[[[To use `rackup` instead of Rails' `rails server`, you can put the following inside `config.ru` of your Rails application's root directory:]]]

```ruby
# Rails.root/config.ru
require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Debugger
use Rack::ContentLength
run Rails.application
```

그리고 서버를 실행합니다. [[[And start the server:]]]

```bash
$ rackup config.ru
```

다른 `rackup` 옵션들을 찾아볼 수 있습니다. [[[To find out more about different `rackup` options:]]]

```bash
$ rackup --help
```

[Action Dispatcher Middleware Stack] Action Dispatcher 미들웨어 스택
----------------------------------

많은 Action Dispatcher 내부 컴포넌트는 Rack 미들웨어로써 구현되어 있습니다. `Rails::Application`은 완전한 레일스 Rack 애플리케이션의 구성을 위해서, 내/외부 다양한 미들웨어를 결합하기 위한 `ActionDispatch::MiddlewareStack` 사용합니다. [[[Many of Action Dispatcher's internal components are implemented as Rack middlewares. `Rails::Application` uses `ActionDispatch::MiddlewareStack` to combine various internal and external middlewares to form a complete Rails Rack application.]]]

NOTE: 레일스의 `ActionDispatch::MiddlewareStack`은 `Rack::Builder`에 해당합니다. 하지만 레일스의 필요 조건에 따라 더 유연하고 많은 기능들로 만들어졌습니다. [[[NOTE: `ActionDispatch::MiddlewareStack` is Rails equivalent of `Rack::Builder`, but built for better flexibility and more features to meet Rails' requirements.]]]

### [Inspecting Middleware Stack] 미들웨어 스택 살펴보기

레일스에는 사용되고 있는 미들웨어 스택을 살펴볼 수 있는 편리한 rake 명령이 있습니다. [[[Rails has a handy rake task for inspecting the middleware stack in use:]]]


```bash
$ rake middleware
```

처음 만들어진 레일스 어플리케이션에서는 다음과 같은 결과가 나타날 것입니다. [[[For a freshly generated Rails application, this might produce something like:]]]

```ruby
use ActionDispatch::Static
use Rack::Lock
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x000000029a0838>
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use ActionDispatch::DebugExceptions
use ActionDispatch::RemoteIp
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use ActiveRecord::QueryCache
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ParamsParser
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
run MyApp::Application.routes
```

이 미들웨어의 각 목적은 [내부 미들웨어](#internal-middleware-stack) 섹션에 설명되어 있습니다. [[[Purpose of each of this middlewares is explained in the [Internal Middlewares](#internal-middleware-stack) section.]]]

### [Configuring Middleware Stack] 미들웨어 스택 설정

레일스는 `application.rb` 또는 각 환경에 맞는 설정 파일 `environments/<environment>.rb`을 통해 미들웨어 스택에 미들웨어를 추가하고, 제거하고, 변경하기 위한 `config.middleware`라는 간편한 설정 인터페이스를 제공합니다. [[[Rails provides a simple configuration interface `config.middleware` for adding, removing and modifying the middlewares in the middleware stack via `application.rb` or the environment specific configuration file `environments/<environment>.rb`.]]]

#### [Adding a Middleware] 미들웨어 추가하기

미들웨어 스택에 새로운 미들웨어를 추가하기 위해 다음과 같은 메서드를 사용할 수 있습니다. [[[You can add a new middleware to the middleware stack using any of the following methods:]]]

* `config.middleware.use(new_middleware, args)` - 미들웨어 스택 마지막에 새로운 미들웨어를 추가합니다. [[[Adds the new middleware at the bottom of the middleware stack.]]]

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - 미들웨어 스택의 특정 미들웨어 앞에 새로운 미들웨어를 추가합니다. [[[Adds the new middleware before the specified existing middleware in the middleware stack.]]]

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - 미들웨어 스택의 특정 미들웨어 뒤에 새로운 미들웨어를 추가합니다. [[[Adds the new middleware after the specified existing middleware in the middleware stack.]]]

```ruby
# config/application.rb

# Push Rack::BounceFavicon at the bottom
config.middleware.use Rack::BounceFavicon

# Add Lifo::Cache after ActiveRecord::QueryCache.
# Pass { page_cache: false } argument to Lifo::Cache.
config.middleware.insert_after ActiveRecord::QueryCache, Lifo::Cache, page_cache: false
```

#### [Swapping a Middleware] 미들웨어 교체

`config.middleware.swap`을 이용하여 미들웨어 스택에 존재하는 미들웨어를 교체할 수 있습니다.[[[You can swap an existing middleware in the middleware stack using `config.middleware.swap`.]]]

```ruby
# config/application.rb

# Replace ActionDispatch::ShowExceptions with Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Middleware Stack is an Enumerable

미들웨어 스택은 일반 `Enumerable`처럼 작동합니다. 이 스택을 조작하거나 질의하기 위해 어떤 `Enumerable` 메서드든 사용할 수 있습니다. 또한 미들웨어 스택은 `[]`, `unshift`, `delete`를 포함한 몇 가지 `Array` 메서드들로도 구현되어 있습니다. 윗 섹션에 설명된 메서드들은 단지 편리함을 위한 메서드들입니다. [[[The middleware stack behaves just like a normal `Enumerable`. You can use any `Enumerable` methods to manipulate or interrogate the stack. The middleware stack also implements some `Array` methods including `[]`, `unshift` and `delete`. Methods described in the section above are just convenience methods.]]]

다음 라인을 어플리케이션 설정에 추가해보세요. [[[Append following lines to your application configuration:]]]

```ruby
# config/application.rb
config.middleware.delete "Rack::Lock"
```

그리고 미들웨어 스택을 확인해보면 `Rack::Lock`이 빠져있는 것을 볼 수 있습니다. [[[And now if you inspect the middleware stack, you'll find that `Rack::Lock` will not be part of it.]]]

```bash
$ rake middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
use Rack::Runtime
...
run Blog::Application.routes
```

만약 세션에 관련된 미들웨어를 제거하고 싶다면, 다음과 같이 해보세요. [[[If you want to remove session related middleware, do the following:]]]

```ruby
# config/application.rb
config.middleware.delete "ActionDispatch::Cookies"
config.middleware.delete "ActionDispatch::Session::CookieStore"
config.middleware.delete "ActionDispatch::Flash"
```

그리고 브라우져와 관련된 미들웨어를 제거하고 싶다면, [[[And to remove browser related middleware,]]]

```ruby
# config/application.rb
config.middleware.delete "Rack::MethodOverride"
```

### [Internal Middleware Stack] 내부 미들웨어 스택

Action Controller의 기능 중의 상당 부분이 미들웨어로써 구성되었습니다. 다음 리스트들은 각 미들웨어의 목적을 설명합니다. [[[Much of Action Controller's functionality is implemented as Middlewares. The following list explains the purpose of each of them:]]]

 **`ActionDispatch::Static`**

* static assets를 전달하는데 사용됩니다. `config.serve_statis_assets`가 false면 사용되지 않습니다.  

 [[[* Used to serve static assets. Disabled if `config.serve_static_assets` is false]]]

 **`Rack::Lock`**

* `env["rack.multithread]`를 false로 지정하면 어플리케이션을 Mutex로 감쌈니다.

 [[[* Sets `env["rack.multithread"]` flag to `false` and wraps the application within a Mutex.]]]

 **`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* 메모리 캐시를 위해 사용됩니다. 이 캐시는 쓰레드 세이프하지 않습니다.

 [[[* Used for memory caching. This cache is not thread safe.]]]

 **`Rack::Runtime`**

* 요청을 수행하는데 소요된 시간(초)을 담고있는 X-Runtime 헤더를 설정합니다.

 [[[* Sets an X-Runtime header, containing the time (in seconds) taken to execute the request.]]]

 **`Rack::MethodOverride`**

* 만약 `params[:_method]`가 설정되어 있으면 method를 오버라이드 하는 것이 허용됩니다. HTTP method 타입 중 PUT, DELETE를 지원하기 위한 미들웨어입니다.

 [[[* Allows the method to be overridden if `params[:_method]` is set. This is the middleware which supports the PUT and DELETE HTTP method types.]]]

 **`ActionDispatch::RequestId`**

* 응답에 유용한 고유한 `X-Request-Id` 헤더를 만들고 `ActionDispatch::Request#uuid` 메서드를 사용할 수 있도록 합니다.

 [[[* Makes a unique `X-Request-Id` header available to the response and enables the `ActionDispatch::Request#uuid` method.]]]

 **`Rails::Rack::Logger`**

* 요청이 시작되었다고 로그에 알립니다. 요청이 끝나면 모든 남깁니다(flush).

 [[[* Notifies the logs that the request has began. After request is complete, flushes all the logs.]]]

 **`ActionDispatch::ShowExceptions`**

* 어플리케이션에서 반환된 예외사항을 잡아내고, 최종 사용자를 위한 형태로 포장하는 예외 앱을 호출합니다.

 [[[* Rescues any exception returned by the application and calls an exceptions app that will wrap it in a format for the end user.]]]

 **`ActionDispatch::DebugExceptions`**

 * 로컬의 요청인 경우 예외 로그를 기록하고 디버깅 페이지를 보여줄 책임을 가집니다.

 [[[* Responsible for logging exceptions and showing a debugging page in case the request is local.]]]

 **`ActionDispatch::RemoteIp`**

* IP 스푸핑 공격을 체크합니다.

 [[[* Checks for IP spoofing attacks.]]]

 **`ActionDispatch::Reloader`**

 * 준비하고 정리하는 콜백(prepare and cleanup callbacks)을 제공하고, 개발 환경에서 코드를 다시 불러오는 것을 지원합니다.

 [[[* Provides prepare and cleanup callbacks, intended to assist with code reloading during development.]]]

 **`ActionDispatch::Callbacks`**

* 요청을 넘기기 전 준비 콜백들(prepare callbacks)을 실행합니다.

 [[[* Runs the prepare callbacks before serving the request.]]]

 **`ActiveRecord::ConnectionAdapters::ConnectionManagement`**

 * 요청 환경의 `rack.test` 키가 `true`로 세팅되어 있지 않으면, 각 요청 후 활성화된 연결을 정리합니다.

 [[[* Cleans active connections after each request, unless the `rack.test` key in the request environment is set to `true`.]]]

 **`ActiveRecord::QueryCache`**

* Active Record의 쿼리 캐시를 활성화합니다.

 [[[* Enables the Active Record query cache.]]]

 **`ActionDispatch::Cookies`**

* 요청에 대해 쿠키를 설정합니다.

 [[[* Sets cookies for the request.]]]

 **`ActionDispatch::Session::CookieStore`**

* 세션을 쿠키에 저장하는 것을 책임집니다.

 [[[* Responsible for storing the session in cookies.]]]

 **`ActionDispatch::Flash`**

* `config.action_controller.session_store`에 값이 설정된 경우에 한해서 flash key를 설정합니다.

 [[[* Sets up the flash keys. Only available if `config.action_controller.session_store` is set to a value.]]]

 **`ActionDispatch::ParamsParser`**

* `params`내 request로부터 parameter를 파싱합니다.

 [[[* Parses out parameters from the request into `params`.]]]

 **`ActionDispatch::Head`**

* `HEAD` 요청을 `GET` 요청으로 변환시킨 후 전달합니다.

 [[[* Converts HEAD requests to `GET` requests and serves them as so.]]]

 **`Rack::ConditionalGet`**

* "Conditional `GET`"의 지원을 추가함으로써, 페이지가 변하지 않으면 서버는 내용이 없는 응답을 합니다.

 [[[* Adds support for "Conditional `GET`" so that server responds with nothing if page wasn't changed.]]]

 **`Rack::ETag`**

* 모든 문자열 바디에 ETag 헤더를 추가합니다. ETag는 캐시 검증에 사용됩니다.

 [[[* Adds ETag header on all String bodies. ETags are used to validate cache.]]]

TIP: 위의 모든 미들웨어들은 커스텀된 Rack 스택에 사용될 수 있습니다. [[[TIP: It's possible to use any of the above middlewares in your custom Rack stack.]]]

### [Using Rack Builder] Rack Builder 사용하기

다음은 레일스가 제공하는 `MiddlewareStack`대신 `Rack::Builder`로 전환하여 사용하는 방법입니다. [[[The following shows how to replace use `Rack::Builder` instead of the Rails supplied `MiddlewareStack`.]]]

<strong>레일즈 있는 미들웨어 스택 제거</strong> [[[<strong>Clear the existing Rails middleware stack</strong>]]]

```ruby
# config/application.rb
config.middleware.clear
```

<br />
<strong> `Rails.root`에 `config.ru` 파일 추가합니다.</strong> [[[<strong>Add a `config.ru` file to `Rails.root`</strong>]]]

```ruby
# config.ru
use MyOwnStackFromScratch
run Rails.application
```

Resources
---------

### [Learning Rack] Rack 배우기

* [Official Rack Website](http://rack.github.io)
* [Introducing Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)
* [Ruby on Rack #1 - Hello Rack!](http://m.onkey.org/ruby-on-rack-1-hello-rack)
* [Ruby on Rack #2 - The Builder](http://m.onkey.org/ruby-on-rack-2-the-builder)

### [Understanding Middlewares] 미들웨어에 대한 이해

* [Railscast on Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
