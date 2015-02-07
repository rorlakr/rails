[The Rails Initialization Process] 레일스 초기화 프로세스
====================================================

이 가이드는 레일스 4의 초기화 내부 작업에 대해 설명한다. 이는 매우 심도있는 가이드이며 숙련된 레일스 개발자들에게 권한다. [[[This guide explains the internals of the initialization process in Rails as of Rails 4. It is an extremely in-depth guide and recommended for advanced Rails developers.]]]

이 가이드를 읽은 후, 다음과 같은 것들을 익히게 된다: [[[After reading this guide, you will know:]]]

* `rails server` 사용법. [[[How to use `rails server`.]]]

--------------------------------------------------------------------------------

이 가이드는 기본적으로 레일스 4 애플리케이션의 루비온레일스 스택을 부트하기 위해 필요한 모든 메소드 호출을 하나하나 자세히 설명하면서 진행된다. 이 가이드에서, 앱을 부트하기 위해 +rails server+를 호출할 때 어떤 일이 발생하는지에 초점을 둘 것이다. [[[This guide goes through every method call that is required to boot up the Ruby on Rails stack for a default Rails 4 application, explaining each part in detail along the way. For this guide, we will be focusing on what happens when you execute +rails server+ to boot your app.]]]

NOTE: 다른 방법으로 특정하지 않았다면 이 가이드의 경로들은 레일스 혹은 레일스 애플리케이션에 상대적인 경로들이다. [[[Paths in this guide are relative to Rails or a Rails application unless otherwise specified.]]]

TIP: 만일 레일스 [소스코드](https://github.com/rails/rails)를 탐색하며 따라오고 싶다면, `t` 단축키를 이용하여 GitHub 파일 탐색기를 열어 파일을 빠르게 찾아가며 보길 권장한다. [[[If you want to follow along while browsing the Rails [source code](https://github.com/rails/rails), we recommend that you use the `t` key binding to open the file finder inside GitHub and find files quickly.]]]

[Launch!] 실행하기!
-------

이제 드디어 앱을 부트하고, 초기화한다. 이는 모두 `bin/rails` 실행 명령으로 시작한다. 레일스 애플리케이션은 보통 `rails console` 혹은 `rails server`를 실행하여 시작한다. [[[Now we finally boot and initialize the app. It all starts with your app's `bin/rails` executable. A Rails application is usually started by running `rails console` or `rails server`.]]]

### `bin/rails`

이 파일은 아래와 같다: [[[This file is as follows:]]]

```ruby
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require 'rails/commands'
```

`APP_PATH` 상수는 나중에 `rails/commands`에서 쓰이게 된다. 여기서 참조된 `config/boot` 파일은 애플리케이션에서 Bundler를 로드하고 설정하는 역할을 하는 `config/boot.rb` 파일이다. [[[The `APP_PATH` constant will be used later in `rails/commands`. The `config/boot` file referenced here is the `config/boot.rb` file in our application which is responsible for loading Bundler and setting it up.]]]

### `config/boot.rb`

`config/boot.rg` 파일은 다음과 같은 내용을 포함한다: [[[`config/boot.rb` contains:]]]

```ruby
# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
```

표준 레일스 애플리케이션에는, 애플리케이션의 모든 의존성을 정의하는 `Gemfile`이 있다. `config/boot.rb`는 `ENV['BUNDLE_GEMFILE']`에 이 파일의 위치를 지정한다. 만일 Gemfile이 존재할 경우, `bundler/setup`을 요구한다. [[[In a standard Rails application, there's a `Gemfile` which declares all dependencies of the application. `config/boot.rb` sets `ENV['BUNDLE_GEMFILE']` to the location of this file. If the Gemfile exists, `bundler/setup` is then required.]]]

표준 레일스 애플리케이션은 몇가지 gem들에 의존하는데, 특히: [[[A standard Rails application depends on several gems, specifically:]]]

* abstract
* actionmailer
* actionpack
* activemodel
* activerecord
* activesupport
* arel
* builder
* bundler
* erubis
* i18n
* mail
* mime-types
* polyglot
* rack
* rack-cache
* rack-mount
* rack-test
* rails
* railties
* rake
* sqlite3-ruby
* thor
* treetop
* tzinfo

### `rails/commands.rb`

`config/boot.rb`가 끝나면, 다음으로 필요한 파일은 전달된 매개변수를 바탕으로 명령을 실행하는 `rails/commands` 이다. 이 경우, `ARGV` 배열은 단순히 이 라인들을 이용하여 `command` 변수로 추출된 `server`를 포함한다. [[[Once `config/boot.rb` has finished, the next file that is required is `rails/commands` which will execute a command based on the arguments passed in. In this case, the `ARGV` array simply contains `server` which is extracted into the `command` variable using these lines:]]]

```ruby
ARGV << '--help' if ARGV.empty?

aliases = {
  "g"  => "generate",
  "d"  => "destroy",
  "c"  => "console",
  "s"  => "server",
  "db" => "dbconsole",
  "r"  => "runner"
}

command = ARGV.shift
command = aliases[command] || command
```

TIP: 보시다시피, 비어있는 ARGV 리스트는 레일스가 도움말 문구를 보여주도록 한다. [[[As you can see, an empty ARGV list will make Rails show the help snippet.]]]

만약 `server` 대신 `s`를 사용한다면, 레일스는 파일에 정의된 `aliases`를 이용하고, 그들 각각의 명령어에 대응시킨다. `server` 커맨드로, 레일스는 이 코드를 실행한다. [[[If we used `s` rather than `server`, Rails will use the `aliases` defined in the file and match them to their respective commands. With the `server` command, Rails will run this code:]]]

```ruby
when 'server'
  # Change to the application's path if there is no config.ru file in current dir.
  # This allows us to run `rails server` from other directories, but still get
  # the main config.ru and properly set the tmp directory.
  Dir.chdir(File.expand_path('../../', APP_PATH)) unless File.exists?(File.expand_path("config.ru"))

  require 'rails/commands/server'
  Rails::Server.new.tap do |server|
    # We need to require application after the server sets environment,
    # otherwise the --environment option given to the server won't propagate.
    require APP_PATH
    Dir.chdir(Rails.application.root)
    server.start
  end
```

이 파일은 레일스의 루트 디렉토리(`config/application.rb`를 가리키는 `APP_PATH`의 두 단계 상위 디렉토리)로 변경되지만, 이는 `config.ru` 파일을 찾을 수 없을 경우 뿐이다. 그럴 경우 이 파일은 `Rails::Server` 클래스를 설정하는 `rails/commands/server`를 요구한다. [[[This file will change into the Rails root directory (a path two directories up from `APP_PATH` which points at `config/application.rb`), but only if the `config.ru` file isn't found. This then requires `rails/commands/server` which sets up the `Rails::Server` class.]]]

```ruby
require 'fileutils'
require 'optparse'
require 'action_dispatch'

module Rails
  class Server < ::Rack::Server
```

`fileutils`와 `optparse`는 파일들과 옵션 파싱 작업시 helper 함수들을 제공해주는 표준 루비 라이브러리 [[[`fileutils` and `optparse` are standard Ruby libraries which provide helper functions for working with files and parsing options.]]]

### `actionpack/lib/action_dispatch.rb`

Action Dispatch는 레일스 프레임워크의 라우팅 컴포넌트이다. 라우팅, 세션, 일반 미들웨어와 같은 기능을 제공한다. [[[Action Dispatch is the routing component of the Rails framework. It adds functionality like routing, session, and common middlewares.]]]

### `rails/commands/server.rb`

`Rails::Server` 클래스는 `Rack::Server`로부터 상속받아 이 파일에 정의되어 있다. `Rails::Server.new`가 호출되면, 이 클래스는 `rails/commands/server.rb` 안의 `initialize` 메소드를 호출한다. [[[The `Rails::Server` class is defined in this file by inheriting from `Rack::Server`. When `Rails::Server.new` is called, this calls the `initialize` method in `rails/commands/server.rb`:]]]

```ruby
def initialize(*)
  super
  set_environment
end
```

처음으로, `Rack::Server`의 `initialize` 메소드를 호출하는 `super`를 호출한다. [[[Firstly, `super` is called which calls the `initialize` method on `Rack::Server`.]]]

### Rack: `lib/rack/server.rb`

`Rack::Server`는 이제는 레일스 또한 그 일부가 된 모든 Rack 기반 애플리케이션들을 위한 일반 서버 인터페이스를 제공하는 역할을 한다. [[[`Rack::Server` is responsible for providing a common server interface for all Rack-based applications, which Rails is now a part of.]]]

`Rack::Server`의 `initialize` 메소드는 단순히 두 가지 변수를 설정한다. [[[The `initialize` method in `Rack::Server` simply sets a couple of variables:]]]

```ruby
def initialize(options = nil)
  @options = options
  @app = options[:app] if options && options[:app]
end
```

이 경우, `options`는 `nil`이 되어 이 메소드에서는 아무일도 발생하지 않는다. [[[In this case, `options` will be `nil` so nothing happens in this method.]]]

`Rack::Server`에서 `super`가 끝난 후, 다시 `rails/commands/server.rb`로 넘어간다. 이 지점에서, `set_environment`는 `Rails::Server`의 문맥 안에서 호출되고, 이 메소드는 처음에는 많은 일을 하지 않게 보인다: [[[After `super` has finished in `Rack::Server`, we jump back to `rails/commands/server.rb`. At this point, `set_environment` is called within the context of the `Rails::Server` object and this method doesn't appear to do much at first glance:]]]

```ruby
def set_environment
  ENV["RAILS_ENV"] ||= options[:environment]
end
```

사실, `options` 메소드는 꽤 많은 것을 한다. 이 메소드는 `Rack::Server`에 이와 같이 정의한다: [[[In fact, the `options` method here does quite a lot. This method is defined in `Rack::Server` like this:]]]

```ruby
def options
  @options ||= parse_options(ARGV)
end
```

그리고 `parse_options`는 이와 같이 정의한다: [[[Then `parse_options` is defined like this:]]]

```ruby
def parse_options(args)
  options = default_options

  # Don't evaluate CGI ISINDEX parameters.
  # http://hoohoo.ncsa.uiuc.edu/cgi/cl.html
  args.clear if ENV.include?("REQUEST_METHOD")

  options.merge! opt_parser.parse! args
  options[:config] = ::File.expand_path(options[:config])
  ENV["RACK_ENV"] = options[:environment]
  options
end
```

`default_options`는 이렇게 설정한다: [[[With the `default_options` set to this:]]]

```ruby
def default_options
  {
    :environment => ENV['RACK_ENV'] || "development",
    :pid         => nil,
    :Port        => 9292,
    :Host        => "0.0.0.0",
    :AccessLog   => [],
    :config      => "config.ru"
  }
end
```

`REQUEST_METHOD` 키가 `ENV`에 존재하지 않아 그 라인을 건너뛸 수 있다. 그 다음 라인은 `Rack::Server`에 명확하게 정의된 `opt_parser`로부터 options에 병합한다. [[[There is no `REQUEST_METHOD` key in `ENV` so we can skip over that line. The next line merges in the options from `opt_parser` which is defined plainly in `Rack::Server`]]]

```ruby
def opt_parser
  Options.new
end
```

클래스는 `Rack::Server`에 정의되어있지만, 다른 매개변수들을 받기 위해 `Rails:Server`에 덮어씌워져 있다. 그의 `parse!` 메소드는 이와 같이 시작한다: [[[The class **is** defined in `Rack::Server`, but is overwritten in `Rails::Server` to take different arguments. Its `parse!` method begins like this:]]]

```ruby
def parse!(args)
  args, options = args.dup, {}

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: rails server [mongrel, thin, etc] [options]"
    opts.on("-p", "--port=port", Integer,
            "Runs Rails on the specified port.", "Default: 3000") { |v| options[:Port] = v }
  ...
```

이 메소드는 레일스가 그 서버를 어떻게 실행할지 결정할 수 있도록 해주는 `options`의 키들을 설정한다. `initialize`가 끝난 후, (더 먼저 설정된) `APP_PATH`가 요구되는 `rails/server`로 돌아간다. [[[This method will set up keys for the `options` which Rails will then be able to use to determine how its server should run. After `initialize` has finished, we jump back into `rails/server` where `APP_PATH` (which was set earlier) is required.]]]

### `config/application`

`require APP_PATH`가 실행될 때, `config/application.rb`를 로드한다. 이 파일은 앱 안에 존재하며, 필요에 따라 자유롭게 변경할 수 있다. [[[When `require APP_PATH` is executed, `config/application.rb` is loaded. This file exists in your app and it's free for you to change based on your needs.]]]

### `Rails::Server#start`

`config/application`이 로드된 후, `server.start`를 호출한다. 이 메소드는 다음과 같이 정의되어 있다: [[[After `config/application` is loaded, `server.start` is called. This method is defined like this:]]]

```ruby
def start
  url = "#{options[:SSLEnable] ? 'https' : 'http'}://#{options[:Host]}:#{options[:Port]}"
  puts "=> Booting #{ActiveSupport::Inflector.demodulize(server)}"
  puts "=> Rails #{Rails.version} application starting in #{Rails.env} on #{url}"
  puts "=> Run `rails server -h` for more startup options"
  trap(:INT) { exit }
  puts "=> Ctrl-C to shutdown server" unless options[:daemonize]

  #Create required tmp directories if not found
  %w(cache pids sessions sockets).each do |dir_to_make|
    FileUtils.mkdir_p(Rails.root.join('tmp', dir_to_make))
  end

  unless options[:daemonize]
    wrapped_app # touch the app so the logger is set up

    console = ActiveSupport::Logger.new($stdout)
    console.formatter = Rails.logger.formatter

    Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
  end

  super
ensure
  # The '-h' option calls exit before @options is set.
  # If we call 'options' with it unset, we get double help banners.
  puts 'Exiting' unless @options && options[:daemonize]
end
```

여기는 레일스 초기화의 첫 출력이 발생하는 부분이다. 이 메소드는 `INT` 시그널에 함정을 만들기 때문에, 서버에 `CTRL-C`를 할 경우 프로세스를 종료시킬 것이다. 이 코드에서 볼 수 있듯이, 이는 `tmp/cache`, `tmp/pids`, `tmp/sessions`, 그리고 `tmp/sockets` 디렉토리를 생성한다. 그리고 `ActiveSupport::Logger`의 인스턴스를 생성하고 할당하기 전에 Rack 앱을 생성하는 `wrapped_app`을 호출한다. [[[This is where the first output of the Rails initialization happens. This method creates a trap for `INT` signals, so if you `CTRL-C` the server, it will exit the process. As we can see from the code here, it will create the `tmp/cache`, `tmp/pids`, `tmp/sessions` and `tmp/sockets` directories. It then calls `wrapped_app` which is responsible for creating the Rack app, before creating and assigning an instance of `ActiveSupport::Logger`.]]]

`super` 메소드는 이런 식으로 그의 정의를 시작하는 `Rack::Server.start`을 호출한다: [[[The `super` method will call `Rack::Server.start` which begins its definition like this:]]]

```ruby
def start &blk
  if options[:warn]
    $-w = true
  end

  if includes = options[:include]
    $LOAD_PATH.unshift(*includes)
  end

  if library = options[:require]
    require library
  end

  if options[:debug]
    $DEBUG = true
    require 'pp'
    p options[:server]
    pp wrapped_app
    pp app
  end

  check_pid! if options[:pid]

  # Touch the wrapped app, so that the config.ru is loaded before
  # daemonization (i.e. before chdir, etc).
  wrapped_app

  daemonize_app if options[:daemonize]

  write_pid if options[:pid]

  trap(:INT) do
    if server.respond_to?(:shutdown)
      server.shutdown
    else
      exit
    end
  end

  server.run wrapped_app, options, &blk
end
```

레일스 앱의 흥미로운 부분은 마지막 줄인 `server.run`이다. 여기서 `wrapped_app` 메소드를 다시 만나게 되는데, 이제 더 탐색해야 할 시간이다. (비록 이전에 실행되었지만, 지금 다시 떠오르게 된다.) [[[The interesting part for a Rails app is the last line, `server.run`. Here we encounter the `wrapped_app` method again, which this time we're going to explore more (even though it was executed before, and thus memorized by now).]]]

```ruby
@wrapped_app ||= build_app app
```

`app` 메소드는 이렇게 정의한다: [[[The `app` method here is defined like so:]]]

```ruby
def app
  @app ||= begin
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end
end
```

`options[:config]` 값은 기본적으로 이러한 내용을 포함하는 `config.ru`으로 설정한다: [[[The `options[:config]` value defaults to `config.ru` which contains this:]]]

```ruby
# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run <%= app_const %>
```


`Rack::Builder.parse_file` 메소드는 `config.ru` 파일로부터 내용을 가져와 다음 코드를 사용하여 파싱한다: [[[The `Rack::Builder.parse_file` method here takes the content from this `config.ru` file and parses it using this code:]]]

```ruby
app = eval "Rack::Builder.new {( " + cfgfile + "\n )}.to_app",
    TOPLEVEL_BINDING, config
```

`Rack::Builder`의 `initialize` 메소드는 이 블록을 가져와 `Rack::Builder`의 인스턴스 내부에서 실행한다. 이 곳이 레일스의 초기화 프로세스의 많은 부분이 발생하는 곳이다. `config.ur`의 `config/environment.rb`을 다루는 `require` 라인이 실행을 위한 가장 첫 부분 이다: [[[The `initialize` method of `Rack::Builder` will take the block here and execute it within an instance of `Rack::Builder`. This is where the majority of the initialization process of Rails happens. The `require` line for `config/environment.rb` in `config.ru` is the first to run:]]]

```ruby
require ::File.expand_path('../config/environment',  __FILE__)
```

### `config/environment.rb`

이 파일은 `config.ru`와 Passenger가 요구하는 일반 파일이다. 이 곳은 서버를 실행하는 두 가지 방법이 만나는 부분이다; 이 지점 이전의 모든 것들은 Rack과 레일스 설정에 존재한다. [[[This file is the common file required by `config.ru` (`rails server`) and Passenger. This is where these two ways to run the server meet; everything before this point has been Rack and Rails setup.]]]

이 파일은 `config/application.rb`를 필요로 하면서 시작한다. [[[This file begins with requiring `config/application.rb`.]]]

### `config/application.rb`

이 파일은 `config/boot.rb`를 요구하지만, 이전에 요구되지 않은 `rails server`의 경우에만 해당하고, Passenger의 경우에는 해당하지 **않는다**. [[[This file requires `config/boot.rb`, but only if it hasn't been required before, which would be the case in `rails server` but **wouldn't** be the case with Passenger.]]]

이제 재미있는 것들이 시작된다![[[Then the fun begins!]]]

[Loading Rails] 레일스 로드하기
-------------

`config/application.rb`의 다음 라인은 이렇다: [[[The next line in `config/application.rb` is:]]]

```ruby
require 'rails/all'
```

### `railties/lib/rails/all.rb`

이 파일은 레일스의 모든 개별 프레임워크들을 모두 요구한다: [[[This file is responsible for requiring all the individual frameworks of Rails:]]]

```ruby
require "rails"

%w(
    active_record
    action_controller
    action_mailer
    rails/test_unit
    sprockets
).each do |framework|
  begin
    require "#{framework}/railtie"
  rescue LoadError
  end
end
```

이 곳은 모든 레일스 프레임워크들이 로드되어 애플리케이션을 사용 가능하도록 만들어 주는 부분이다. 여기서는 프레임워크 내부적으로 어떤 일이 발생하는지 자세히 들여다보진 않을 것이지만 스스로 찾아보고, 시도해보는 것을 장려한다. [[[This is where all the Rails frameworks are loaded and thus made available to the application. We won't go into detail of what happens inside each of those frameworks, but you're encouraged to try and explore them on your own.]]]

이제, 레일스 엔진, I18n, 레일스 설정들과 같은 일반 기능들은 이 곳에 정의되어 있다는 것만 명심하십시오. [[[For now, just keep in mind that common functionality like Rails engines, I18n and Rails configuration are all being defined here.]]]

### Back to `config/environment.rb`

`config/application.rb`가 레일스를 로드하고, 애플리케이션 네임스페이스 정의를 완료했을 때, 애플리케이션이 초기화 되어있는 `config/environment.rb`로 돌아간다. 예를 들어, 만약 애플리케이션이 `Blog`라는 이름이라면, `rails/application.rb` 안에 정의된 `Blog::Application.initialize!`를 발견할 수 있을 것이다. [[[When `config/application.rb` has finished loading Rails, and defined the application namespace, we go back to `config/environment.rb`, where the application is initialized. For example, if the application was called `Blog`, here we would find `Blog::Application.initialize!`, which is defined in `rails/application.rb`]]]

### `railties/lib/rails/application.rb`

`initialize!` 메소드는 이러한 형태를 갖는다: [[[The `initialize!` method looks like this:]]]

```ruby
def initialize!(group=:default) #:nodoc:
  raise "Application has been already initialized." if @initialized
  run_initializers(group, self)
  @initialized = true
  self
end
```

보시다시피, 앱은 단 한번만 초기화할 수 있다. 이 곳은 또한 이니셜라이져들이 실행되는 곳이기도 한다. [[[As you can see, you can only initialize an app once. This is also where the initializers are run.]]]

TODO: review this

이니셜라이져 코드는 그 자체로도 까다롭다. 레일스가 이 곳에서 하는 일은 모든 클래스 조상들을 가로지르며 `initializers` 메소드를 찾아 정렬하고, 실행한다. 예를 들어, `Engine` 클래스는 `initializers` 메소드를 제공함으로써 모든 사용 가능한 엔진들을 만들게 된다. [[[The initializers code itself is tricky. What Rails is doing here is it traverses all the class ancestors looking for an `initializers` method, sorting them and running them. For example, the `Engine` class will make all the engines available by providing the `initializers` method.]]]

이후에 다시 `Rack::Server`로 돌아간다. [[[After this is done we go back to `Rack::Server`]]]

### Rack: lib/rack/server.rb

이전에 `app` 메소드를 정의하고 넘어갔다: [[[Last time we left when the `app` method was being defined:]]]

```ruby
def app
  @app ||= begin
    if !::File.exist? options[:config]
      abort "configuration #{options[:config]} not found"
    end

    app, options = Rack::Builder.parse_file(self.options[:config], opt_parser)
    self.options.merge! options
    app
  end
end
```

이 지점에서 `app`은 그 자체가 레일스 앱이 되고, 그 이후에는 Rack이 모든 제공되는 미들웨어들을 호출할 것이다: [[[At this point `app` is the Rails app itself (a middleware), and what happens next is Rack will call all the provided middlewares:]]]

```ruby
def build_app(app)
  middleware[options[:environment]].reverse_each do |middleware|
    middleware = middleware.call(self) if middleware.respond_to?(:call)
    next unless middleware
    klass = middleware.shift
    app = klass.new(app, *middleware)
  end
  app
end
```

기억하자. `build_app`은 (wrapped_app 에 의해) `Server#start`의 마지막 라인에 호출되었다. 이전에 남겨둔 시점에 그것은 이런 형태이다: [[[Remember, `build_app` was called (by wrapped_app) in the last line of `Server#start`. Here's how it looked like when we left:]]]

```ruby
server.run wrapped_app, options, &blk
```

이 때, `server.run`의 구현은 사용하는 서버에 따라 달라진다. 예를 들어, 당신이 Mongrel을 사용하고 있다면, `run` 메소드는 이런 형태일 것이다: [[[At this point, the implementation of `server.run` will depend on the server you're using. For example, if you were using Mongrel, here's what the `run` method would look like:]]]

```ruby
def self.run(app, options={})
  server = ::Mongrel::HttpServer.new(
    options[:Host]           || '0.0.0.0',
    options[:Port]           || 8080,
    options[:num_processors] || 950,
    options[:throttle]       || 0,
    options[:timeout]        || 60)
  # Acts like Rack::URLMap, utilizing Mongrel's own path finding methods.
  # Use is similar to #run, replacing the app argument with a hash of
  # { path=>app, ... } or an instance of Rack::URLMap.
  if options[:map]
    if app.is_a? Hash
      app.each do |path, appl|
        path = '/'+path unless path[0] == ?/
        server.register(path, Rack::Handler::Mongrel.new(appl))
      end
    elsif app.is_a? URLMap
      app.instance_variable_get(:@mapping).each do |(host, path, appl)|
       next if !host.nil? && !options[:Host].nil? && options[:Host] != host
       path = '/'+path unless path[0] == ?/
       server.register(path, Rack::Handler::Mongrel.new(appl))
      end
    else
      raise ArgumentError, "first argument should be a Hash or URLMap"
    end
  else
    server.register('/', Rack::Handler::Mongrel.new(app))
  end
  yield server  if block_given?
  server.run.join
end
```

여기서는 서버 설정 자체를 파고들진 않지만, 이것은 레일스 초기화 과정에서의 마지막 부분이다. [[[We won't dig into the server configuration itself, but this is the last piece of our journey in the Rails initialization process.]]]

이 높은 수준의 개요는 코드가 언제, 어떻게 실행되는지 이해하는 데에 도움을 주고, 종합해서 더 좋은 레일스 개발자가 될 수 있도록 도와줄 것이다. 아직 많은 것들이 알고 싶다면, 레일스 소스 코드는 이 다음 단계로 가는 데에 그 자체로도 최고의 장이 될 것이다. [[[This high level overview will help you understand when your code is executed and how, and overall become a better Rails developer. If you still want to know more, the Rails source code itself is probably the best place to go next.]]]
