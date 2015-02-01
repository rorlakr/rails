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

Introduction to Rack
--------------------

Rack은 루비로 웹어플리케이션을 개발할 때 사용할 수 있는, 최소한의, 모듈방식의, 어댑터로 연결할 수 있는 인터페이스를 제공합니다.
Rack은 가능한한 가장 간단한 방식으로 요청과 응답을 포장하여, 웹서버, 웹프레임워크, 그리고 이들 사이의 존재하는 소프트웨어(미들웨어)에 대한 API를 하나의 메소드 호출로 통합하여 추출한 것입니다. [[[Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call.]]]

- [Rack API Documentation](http://rack.rubyforge.org/doc/)

Rack을 설명하는 것을 본 가이드의 범위를 벗어나는 것입니다. Rack에 대한 기본지식이 없는 경우 아래에 있는 [Resources](#resources)를 점검해 보기 바랍니다. [[[Explaining Rack is not really in the scope of this guide. In case you are not familiar with Rack's basics, you should check out the [Resources](#resources) section below.]]]

Rails on Rack
-------------

### [Rails Application's Rack Object] 레일스 어플리케이션의 Rack 객체


[[[`ApplicationName::Application` is the primary Rack application object of a Rails
application. Any Rack compliant web server should be using
`ApplicationName::Application` object to serve a Rails
application. `Rails.application` refers to the same application object.]]]

### `rails server`

`rails server` does the basic job of creating a `Rack::Server` object and starting the webserver.

Here's how `rails server` creates an instance of `Rack::Server`

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

The `Rails::Server` inherits from `Rack::Server` and calls the `Rack::Server#start` method this way:

```ruby
class Server < ::Rack::Server
  def start
    ...
    super
  end
end
```

Here's how it loads the middlewares:

```ruby
def middleware
  middlewares = []
  middlewares << [Rails::Rack::Debugger] if options[:debugger]
  middlewares << [::Rack::ContentLength]
  Hash.new(middlewares)
end
```

`Rails::Rack::Debugger` is primarily useful only in the development environment. The following table explains the usage of the loaded middlewares:

| Middleware              | Purpose                                                                           |
| ----------------------- | --------------------------------------------------------------------------------- |
| `Rails::Rack::Debugger` | Starts Debugger                                                                   |
| `Rack::ContentLength`   | Counts the number of bytes in the response and set the HTTP Content-Length header |

### `rackup`

To use `rackup` instead of Rails' `rails server`, you can put the following inside `config.ru` of your Rails application's root directory:

```ruby
# Rails.root/config.ru
require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Debugger
use Rack::ContentLength
run Rails.application
```

And start the server:

```bash
$ rackup config.ru
```

To find out more about different `rackup` options:

```bash
$ rackup --help
```

Action Dispatcher Middleware Stack
----------------------------------

Many of Action Dispatcher's internal components are implemented as Rack middlewares. `Rails::Application` uses `ActionDispatch::MiddlewareStack` to combine various internal and external middlewares to form a complete Rails Rack application.

NOTE: `ActionDispatch::MiddlewareStack` is Rails equivalent of `Rack::Builder`, but built for better flexibility and more features to meet Rails' requirements.

### Inspecting Middleware Stack

Rails has a handy rake task for inspecting the middleware stack in use:

```bash
$ rake middleware
```

For a freshly generated Rails application, this might produce something like:

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

Purpose of each of this middlewares is explained in the [Internal Middlewares](#internal-middleware-stack) section.

### Configuring Middleware Stack

Rails provides a simple configuration interface `config.middleware` for adding, removing and modifying the middlewares in the middleware stack via `application.rb` or the environment specific configuration file `environments/<environment>.rb`.

#### Adding a Middleware

You can add a new middleware to the middleware stack using any of the following methods:

* `config.middleware.use(new_middleware, args)` - Adds the new middleware at the bottom of the middleware stack.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Adds the new middleware before the specified existing middleware in the middleware stack.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Adds the new middleware after the specified existing middleware in the middleware stack.

```ruby
# config/application.rb

# Push Rack::BounceFavicon at the bottom
config.middleware.use Rack::BounceFavicon

# Add Lifo::Cache after ActiveRecord::QueryCache.
# Pass { page_cache: false } argument to Lifo::Cache.
config.middleware.insert_after ActiveRecord::QueryCache, Lifo::Cache, page_cache: false
```

#### Swapping a Middleware

You can swap an existing middleware in the middleware stack using `config.middleware.swap`.

```ruby
# config/application.rb

# Replace ActionDispatch::ShowExceptions with Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Middleware Stack is an Enumerable

The middleware stack behaves just like a normal `Enumerable`. You can use any `Enumerable` methods to manipulate or interrogate the stack. The middleware stack also implements some `Array` methods including `[]`, `unshift` and `delete`. Methods described in the section above are just convenience methods.

Append following lines to your application configuration:

```ruby
# config/application.rb
config.middleware.delete "Rack::Lock"
```

And now if you inspect the middleware stack, you'll find that `Rack::Lock` will not be part of it.

```bash
$ rake middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
use Rack::Runtime
...
run Blog::Application.routes
```

If you want to remove session related middleware, do the following:

```ruby
# config/application.rb
config.middleware.delete "ActionDispatch::Cookies"
config.middleware.delete "ActionDispatch::Session::CookieStore"
config.middleware.delete "ActionDispatch::Flash"
```

And to remove browser related middleware,

```ruby
# config/application.rb
config.middleware.delete "Rack::MethodOverride"
```

### Internal Middleware Stack

Much of Action Controller's functionality is implemented as Middlewares. The following list explains the purpose of each of them:

 **`ActionDispatch::Static`**

* Used to serve static assets. Disabled if `config.serve_static_assets` is true.

 **`Rack::Lock`**

* Sets `env["rack.multithread"]` flag to `false` and wraps the application within a Mutex.

 **`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Used for memory caching. This cache is not thread safe.

 **`Rack::Runtime`**

* Sets an X-Runtime header, containing the time (in seconds) taken to execute the request.

 **`Rack::MethodOverride`**

* Allows the method to be overridden if `params[:_method]` is set. This is the middleware which supports the PUT and DELETE HTTP method types.

 **`ActionDispatch::RequestId`**

* Makes a unique `X-Request-Id` header available to the response and enables the `ActionDispatch::Request#uuid` method.

 **`Rails::Rack::Logger`**

* Notifies the logs that the request has began. After request is complete, flushes all the logs.

 **`ActionDispatch::ShowExceptions`**

* Rescues any exception returned by the application and calls an exceptions app that will wrap it in a format for the end user.

 **`ActionDispatch::DebugExceptions`**

* Responsible for logging exceptions and showing a debugging page in case the request is local.

 **`ActionDispatch::RemoteIp`**

* Checks for IP spoofing attacks.

 **`ActionDispatch::Reloader`**

* Provides prepare and cleanup callbacks, intended to assist with code reloading during development.

 **`ActionDispatch::Callbacks`**

* Runs the prepare callbacks before serving the request.

 **`ActiveRecord::ConnectionAdapters::ConnectionManagement`**

* Cleans active connections after each request, unless the `rack.test` key in the request environment is set to `true`.

 **`ActiveRecord::QueryCache`**

* Enables the Active Record query cache.

 **`ActionDispatch::Cookies`**

* Sets cookies for the request.

 **`ActionDispatch::Session::CookieStore`**

* Responsible for storing the session in cookies.

 **`ActionDispatch::Flash`**

* Sets up the flash keys. Only available if `config.action_controller.session_store` is set to a value.

 **`ActionDispatch::ParamsParser`**

* Parses out parameters from the request into `params`.

 **`ActionDispatch::Head`**

* Converts HEAD requests to `GET` requests and serves them as so.

 **`Rack::ConditionalGet`**

* Adds support for "Conditional `GET`" so that server responds with nothing if page wasn't changed.

 **`Rack::ETag`**

* Adds ETag header on all String bodies. ETags are used to validate cache.

TIP: It's possible to use any of the above middlewares in your custom Rack stack.

### Using Rack Builder

The following shows how to replace use `Rack::Builder` instead of the Rails supplied `MiddlewareStack`.

<strong>Clear the existing Rails middleware stack</strong>

```ruby
# config/application.rb
config.middleware.clear
```

<br />
<strong>Add a `config.ru` file to `Rails.root`</strong>

```ruby
# config.ru
use MyOwnStackFromScratch
run Rails.application
```

Resources
---------

### Learning Rack

* [Official Rack Website](http://rack.github.io)
* [Introducing Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)
* [Ruby on Rack #1 - Hello Rack!](http://m.onkey.org/ruby-on-rack-1-hello-rack)
* [Ruby on Rack #2 - The Builder](http://m.onkey.org/ruby-on-rack-2-the-builder)

### Understanding Middlewares

* [Railscast on Rack Middlewares](http://railscasts.com/episodes/151-rack-middleware)
