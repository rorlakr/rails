레일스 커맨드라인
======================

레일스는 당신이 필요로 할 모든 커맨드라인 도구들이 함께 제공됩니다.

이 가이드를 통해서 다음의 내용을 배울 수 있습니다.

* 레일스 애플리케이션을 만드는 방법
* 모델, 컨트롤러, 데이터베이스 마이그레이션과 유닛 테스트를 만들 수 있습니다.
* 개발용 서버를 실행 할 수 있습니다.
* 인터렉티브 쉘을 통해 객체들을 이용할 수 있습니다.
* 새 프로그램을 프로파일링 하거나 벤치마킹 할 수 있습니다.

--------------------------------------------------------------------------------

NOTE: 이 튜토리얼은  [Getting Started with Rails Guide](getting_started.html)을 이미 읽어봤다고 가정합니다.
[[[Rails comes with every command line tool you'll need to

After reading this guide, you will know:

* How to create a Rails application.
* How to generate models, controllers, database migrations, and unit tests.
* How to start a development server.
* How to experiment with objects through an interactive shell.
* How to profile and benchmark your new creation.

NOTE: This tutorial assumes you have basic Rails knowledge from reading the [Getting Started with Rails Guide](getting_started.html).
]]]


커맨드라인 기초
-------------------

다음의 몇 개의 명령어는 거의 매일 레일스를 개발하면서 사용할 것입니다. 아마 이미 많이 사용해 보았을 명령어들입니다:

* `rails console`
* `rails server`
* `rake`
* `rails generate`
* `rails dbconsole`
* `rails new app_name`

간단한 레일스 애플리케이션을 각각의 명령어를 사용하면서 만들어 보겠습니다.

### `rails new`

첫째로, 레일스 애플리케이션을 만들기 위해 레일스를 설치한 이후 `rails new` 명령어를 입력합니다.

INFO: 만약 레일스가 설치되어 있지 않다면, `gem install rails`를 입력해서 레일스 젬을 설치할 수 있습니다. 
[[[Command Line Basics
-------------------

There are a few commands that are absolutely critical to your everyday usage of Rails. In the order of how much you'll probably use them are:

* `rails console`
* `rails server`
* `rake`
* `rails generate`
* `rails dbconsole`
* `rails new app_name`

Let's create a simple Rails application to step through each of these commands in context.

### `rails new`

The first thing we'll want to do is create a new Rails application by running the `rails new` command after installing Rails.

INFO: You can install the rails gem by typing `gem install rails`, if you don't have it already.
]]]

```bash
$ rails new commandsapp
     create
     create  README.rdoc
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

레일스는 이와같이 많은 양의 파일들을 작은 명령어만으로 만들어냅니다! 이제 레일스를 수행하는데 필요한 모든 코드를 얻었습니다.
[[[Rails will set you up with what seems like a huge amount of stuff for such a tiny command! You've got the entire Rails directory structure now with all the code you need to run our simple application right out of the box.]]]

### `rails server`

`rails server` 명령을 입력하면 WEBrick이라는 루비 기반의 작은 서버가 실행됩니다. 이제 웹브라우저에서 어느때나 접속해볼 수 있습니다.

INFO: WEBrick 이외에도 레일스 서버는 많습니다.  [나중에](#server-with-different-backends)확인 해볼 수 있습니다.

다른 것들 필요 없이, `rails server` 는 멋진 레일스 서버를 실행해 줍니다:
[[[The `rails server` command launches a small web server named WEBrick which comes bundled with Ruby. You'll use this any time you want to access your application through a web browser.

INFO: WEBrick isn't your only option for serving Rails. We'll get to that [later](#server-with-different-backends).

With no further work, `rails server` will run our new shiny Rails app:]]]

```bash
$ cd commandsapp
$ rails server
=> Booting WEBrick
=> Rails 3.2.3 application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
[2012-05-28 00:39:41] INFO  WEBrick 1.3.1
[2012-05-28 00:39:41] INFO  ruby 1.9.2 (2011-02-18) [x86_64-darwin11.2.0]
[2012-05-28 00:39:41] INFO  WEBrick::HTTPServer#start: pid=69680 port=3000
```

단 3개의 명령어로 3000번 포트를 사용하는 레일스 서버를 실행 하였습니다. 브라우저를 열어 [http://localhost:3000](http://localhost:3000)로 접속하면, 기본적인 레일스 앱이 실행되고 있는 것을 확인할 수 있습니다.


INFO: "s"만을 사용해서 서버를 실행할 수 있습니다: `rails s`.

다른 포트를 사용하기 위해서 `-p` 옵션을 사용할 수 있습니다. 기본적으로 개발환경으로 시작되나, `-e` 옵션을 이용해서 변경할 수 있습니다.
[[[With just three commands we whipped up a Rails server listening on port 3000. Go to your browser and open [http://localhost:3000](http://localhost:3000), you will see a basic Rails app running.

INFO: You can also use the alias "s" to start the server: `rails s`.

The server can be run on a different port using the `-p` option. The default development environment can be changed using `-e`.]]]
```bash
$ rails server -e production -p 4000
```

`-b` 옵션을 사용하면 구체적인 IP 로 지정할 수 있습니다. 기본값은 0.0.0.0 입니다. 데몬으로 서버를 실행하기 위해 `-d` 옵션을 사용합니다.
[[[The `-b` option binds Rails to the specified IP, by default it is 0.0.0.0. You can run a server as a daemon by passing a `-d` option.]]]

### `rails generate`

`rails generate` 명령어는 템플릿을 이용해서 많은 것들을 만들어냅니다. `rails generate` 실행해서 생성할 수 있는 것들의 리스트를 확인할 수 있습니다.

INFO: "g"만 이용해서 제너레이터를 사용할 수 있습니다 : `rails g`.
[[[The `rails generate` command uses templates to create a whole lot of things. Running `rails generate` by itself gives a list of available generators:

INFO: You can also use the alias "g" to invoke the generator command: `rails g`.]]]
```bash
$ rails generate
Usage: rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  controller
  generator
  ...
  ...
```

NOTE: gem을 이용해서 더 많은 것들을 생성할 수 있습니다. 이미 만들어진 의심할 필요 없는 플러그인들을 이용할 수 있습니다. 혹은 스스로 만든 것을 이용할 수 있습니다.

제너레이터는 많은 시간들을 줄여줄 **boilerplate code**를 만들어 줍니다. 

이번에는 컨트롤러 제너레이터로 컨트롤러를 만들어 보겠습니다. 그런데 어떤 명령어를 사용해야 하나요? 제너레이터에 물어보겠습니다.

INFO: 모든 레일스 콘솔 도구들은 도움말을 포함하고 있습니다. 많은 *nix 계열의 도구에 `--help` 또는 `-h` 를 끝에 붙여 입력하면 됩니다. 예를들어 `rails server --help` 를 입력하여 봅니다.
[[[NOTE: You can install more generators through generator gems, portions of plugins you'll undoubtedly install, and you can even create your own!

Using generators will save you a large amount of time by writing **boilerplate code**, code that is necessary for the app to work.

Let's make our own controller with the controller generator. But what command should we use? Let's ask the generator:

INFO: All Rails console utilities have help text. As with most *nix utilities, you can try adding `--help` or `-h` to the end, for example `rails server --help`.]]]

```bash
$ rails generate controller
Usage: rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a
    path like 'parent_module/controller_name'.

    ...

Example:
    `rails generate controller CreditCard open debit credit close`

    Credit card controller with URLs like /credit_card/debit.
        Controller: app/controllers/credit_card_controller.rb
        Test:       test/controllers/credit_card_controller_test.rb
        Views:      app/views/credit_card/debit.html.erb [...]
        Helper:     app/helpers/credit_card_helper.rb
```

컨트롤러 제너레이터는 `generate controller 컨트롤러이름 액션1 액션2` 와 같이 사용합니다. `Greetings` 컨트롤러를 만들어 보겠습니다 그리고 액션으로 **hello** 를 사용합니다. 아마 많은 것들을 볼 수 있습니다.
[[[The controller generator is expecting parameters in the form of `generate controller ControllerName action1 action2`. Let's make a `Greetings` controller with an action of **hello**, which will say something nice to us.]]]
```bash
$ rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get "greetings/hello"
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
     create      test/helpers/greetings_helper_test.rb
     invoke  assets
     invoke    coffee
     create      app/assets/javascripts/greetings.js.coffee
     invoke    scss
     create      app/assets/stylesheets/greetings.css.scss
```

무엇이 만들어 졌습니까? 우리의 애플리케이션에 컨트롤러 파일과 뷰파일, 테스트용 파일, 뷰를 위한 헬퍼, 그리고 자바스크립트 파일과 스타일시트 파일이 만들어졌습니다.
(`app/controllers/greetings_controller.rb`)파일을 확인하여 컨트롤러를 확인해보시기 바랍니다.
[[[What all did this generate? It made sure a bunch of directories were in our application, and created a controller file, a view file, a functional test file, a helper for the view, a JavaScript file and a stylesheet file.

Check out the controller and modify it a little (in `app/controllers/greetings_controller.rb`):]]]
```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end
end
```

뷰를 보면, 이러한 메시지를 볼 수 있습니다.(`app/views/greetings/hello.html.erb`):
[[[Then the view, to display our message (in `app/views/greetings/hello.html.erb`):]]]
```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

`rails server` 명령어를 이용해서 서버를 실행합니다.
[[[Fire up your server using `rails server`.]]]
```bash
$ rails server
=> Booting WEBrick...
```

URL은 [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello) 입니다.

INFO: 기본적으로, URL은 http://(host)/(controller)/(action) 과 같은 패턴으로 만들어 집니다. 그리고 컨트롤러의 **index** URL은 http://(host)/(controller) 와 같습니다.

또한 레일스는 데이터 모델을 만들 수 있습니다.
[[[The URL will be [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: With a normal, plain-old Rails application, your URLs will generally follow the pattern of http://(host)/(controller)/(action), and a URL like http://(host)/(controller) will hit the **index** action of that controller.

Rails comes with a generator for data models too.]]]

```bash
$ rails generate model
Usage:
  rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

Active Record options:
      [--migration]            # Indicates when to generate migration
                               # Default: true

...

Description:
    Create rails files for model generator.
```

NOTE: 사용가능한 필드의 종류들은 [API documentation](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column)에서 확인할 수 있습니다. `TableDefinition` 클래스에서 사용할 수 있는 column 메소드에 대해 볼 수 있습니다.

그러나 직접 모델을 만드는 대신에, scaffold를 사용합니다. 레일스의 **scaffold** 는 모델에 필요한 모든 것(모델을 이용한 데이터 마이그레이션, 조작을 위한 컨트롤러, 출력과 조작을 위한 뷰 등)을 만들어 줍니다.

우리는 간단한 비디오게임의 최고점수를 기록하는 "HighScore" 애플리케이션을 만들겠습니다.
[[[NOTE: For a list of available field types, refer to the [API documentation](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) for the column method for the `TableDefinition` class.

But instead of generating a model directly (which we'll be doing later), let's set up a scaffold. A **scaffold** in Rails is a full set of model, database migration for that model, controller to manipulate it, views to view and manipulate the data, and a test suite for each of the above.

We will set up a simple resource called "HighScore" that will keep track of our highest score on video games we play.]]]
```bash
$ rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20120528060026_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    create        test/helpers/high_scores_helper_test.rb
    invoke  assets
    invoke    coffee
    create      app/assets/javascripts/high_scores.js.coffee
    invoke    scss
    create      app/assets/stylesheets/high_scores.css.scss
    invoke  scss
    create    app/assets/stylesheets/scaffolds.css.scss
```

제너레이터는 이미 존재하는 모델, 컨트롤러, 헬퍼, 레이아웃, 유닛테스트, 스타일시트, 만들어진 뷰, HighScore를 위한 데이터베이스 마이그레이션(만들어진 'high_scores 테이블과 필드'), **resource**를 위한 라우트 등, 모든것을 확인합니다.

마이그레이션은 **migrate** 를 이용하여 약간의 데이터베이스의 스키마를 수정할 Ruby 코드를 만들어 냅니다.(`20120528060026_create_high_scores.rb` 여기서는 입니다.)  어떤 데이터베이스 인지 궁금합니까? 레일스의  `rake db:migrate` 명령어를 사용해서 sqlite3 데이터베이스를 조작합니다. Rake in-depth에서 더 알아보겠습니다.
[[[The generator checks that there exist the directories for models, controllers, helpers, layouts, functional and unit tests, stylesheets, creates the views, controller, model and database migration for HighScore (creating the `high_scores` table and fields), takes care of the route for the **resource**, and new tests for everything.

The migration requires that we **migrate**, that is, run some Ruby code (living in that `20120528060026_create_high_scores.rb`) to modify the schema of our database. Which database? The sqlite3 database that Rails will create for you when we run the `rake db:migrate` command. We'll talk more about Rake in-depth in a little while.]]]
```bash
$ rake db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: 유닛테스트에 대해 알아보겠습니다. 유닛테스트는 코드에 대한 단언(assertion)을 만드는 것입니다. 유닛테스트는 모델의 메소드를 이용하여 입출력을 테스트 합니다. 유닛테스트는 우리의 친구입니다. 곧 유닛 테스트는 우리의 삶의 질을 향상시킨다는 것을 알 수 있을 거입니다. 우리는 하나의 테스트를 순식간에 만들 수 있습니다.

레일스가 우리에게 만들어주는 인터페이스들을 확인하겠습니다.
[[[INFO: Let's talk about unit tests. Unit tests are code that tests and makes assertions about code. In unit testing, we take a little part of code, say a method of a model, and test its inputs and outputs. Unit tests are your friend. The sooner you make peace with the fact that your quality of life will drastically increase when you unit test your code, the better. Seriously. We'll make one in a moment.

Let's see the interface Rails created for us.]]]
```bash
$ rails server
```

브라우저를 열어 [http://localhost:3000/high_scores](http://localhost:3000/high_scores)에 접속해봅니다. 이제 새 최고 점수를 입력해 보겠습니다 (Space Invaders 의 점수는 55,160 입니다!)
[[[Go to your browser and open [http://localhost:3000/high_scores](http://localhost:3000/high_scores), now we can create new high scores (55,160 on Space Invaders!)]]]

### `rails console`

`console` 명령어를 이용해서 커맨드라인 명령어를 통해 레일스 애플리케이션과 상호작용 할 수 있습니다. 아래에 IRB를 이용한 `rails console`를 사용해본 적이 있을 것입니다. 웹사이트를 이용하지 않고 서버의 데이터를 빠르게 변경할 수 있습니다.

INFO: 콘솔을 사용하기 위해서 "c"로 줄여서 사용할 수 있습니다: `rails c`.

당신은 `console` 명령어가 작동하는 환경을 지정할 수 있습니다.
[[[The `console` command lets you interact with your Rails application from the command line. On the underside, `rails console` uses IRB, so if you've ever used it, you'll be right at home. This is useful for testing out quick ideas with code and changing data server-side without touching the website.

INFO: You can also use the alias "c" to invoke the console: `rails c`.

You can specify the environment in which the `console` command should operate.]]]
```bash
$ rails console staging
```

데이터를 변경하지 않고 테스트하기 위해서는 다음의 명령어를 사용합니다. `rails console --sandbox` 
[[[If you wish to test out some code without changing any data, you can do that by invoking `rails console --sandbox`.]]]
```bash
$ rails console --sandbox
Loading development environment in sandbox (Rails 3.2.3)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

### `rails dbconsole`

`rails dbconsole`은 커맨드라인 인터페이스에서 데이터베이스를 사용하거나 제거할 수 있습니다.(또한 커맨드라인 파라미터로 전달할 수 있습니다!) MySQL, PostgreSQL, SQLite와 SQLite3를 지원합니다.

INFO: 또한 "db"로 줄여서 사용할 수 있습니다: `rails db`.
[[[`rails dbconsole` figures out which database you're using and drops you into whichever command line interface you would use with it (and figures out the command line parameters to give to it, too!). It supports MySQL, PostgreSQL, SQLite and SQLite3.

INFO: You can also use the alias "db" to invoke the dbconsole: `rails db`.]]]
### `rails runner`

`runner`는 상호작용적이지 않은 루비 코드를 실행합니다. 예를 들어:
[[[`runner` runs Ruby code in the context of Rails non-interactively. For instance:]]]
```bash
$ rails runner "Model.long_running_method"
```

INFO: 또한 "r" 로 줄여서 사용할 수 있습니다: `rails r`.

`runner` 커맨드와 `-e`를 이용해서 실행 환경을 변경할 수 있습니다.
[[[INFO: You can also use the alias "r" to invoke the runner: `rails r`.

You can specify the environment in which the `runner` command should operate using the `-e` switch.]]]
```bash
$ rails runner -e staging "Model.long_running_method"
```

### `rails destroy`

`destroy`는 `generate`와 반대라고 생각하면 됩니다. 제너레이터로 만든것들을 제거합니다.

INFO: 또한 "d"로 줄여서 사용할 수 있습니다: `rails d`.
[[[Think of `destroy` as the opposite of `generate`. It'll figure out what generate did, and undo it.

INFO: You can also use the alias "d" to invoke the destroy command: `rails d`.]]]
```bash
$ rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```
```bash
$ rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

Rake
----

Rake(Ruby Make)는 단독으로 실행되는 루비 프로그램입니다. Unix의 'make' 대신 이용하고 'Rakefile'을 이용하여 작업 목록인 `.rake`을 빌드합니다. 레일스에서, Rake는 기본적으로 관리자 작업을 이용합니다. 특별히 필요한 경우에는 따로 이용합니다. 

우리는 이용가능한 Rake 작업들의 목록을 얻을 수 있습니다. 보통 현재 디렉터리에 의존합니다. `rake --tasks` 의 설명을 볼 수 있습니다. 필요한 경우에 도움이 될 것입니다.
[[[Rake is Ruby Make, a standalone Ruby utility that replaces the Unix utility 'make', and uses a 'Rakefile' and `.rake` files to build up a list of tasks. In Rails, Rake is used for common administration tasks, especially sophisticated ones that build off of each other.

You can get a list of Rake tasks available to you, which will often depend on your current directory, by typing `rake --tasks`. Each task has a description, and should help you find the thing you need.]]]
```bash
$ rake --tasks
rake about              # List versions of all Rails frameworks and the environment
rake assets:clean       # Remove compiled assets
rake assets:precompile  # Compile all the assets named in config.assets.precompile
rake db:create          # Create the database from config/database.yml for the current Rails.env
...
rake log:clear          # Truncates all *.log files in log/ to zero bytes (specify which logs with LOGS=test,development)
rake middleware         # Prints out your Rack middleware stack
...
rake tmp:clear          # Clear session, cache, and socket files from tmp/ (narrow w/ tmp:sessions:clear, tmp:cache:clear, tmp:sockets:clear)
rake tmp:create         # Creates tmp directories for sessions, cache, sockets, and pids
```

### `about`

`rake about`은 Ruby와 RubyGems, Rails와 레일스의 세부항목들, 애플리케이션 폴더, 현재 레일스 환경, 데이터베이스 어댑터, 스키마에 대한 버전을 보여줍니다. 이것들은 도움을 위해 필요합니다. 만약 보안 패치가 필요한 경우 또는 레일스 설치에 대한 정보가 필요한 경우에 확인해야합니다.
[[[`rake about` gives information about version numbers for Ruby, RubyGems, Rails, the Rails subcomponents, your application's folder, the current Rails environment name, your app's database adapter, and schema version. It is useful when you need to ask for help, check if a security patch might affect you, or when you need some stats for an existing Rails installation.]]]
```bash
$ rake about
About your application's environment
Ruby version              1.9.3 (x86_64-linux)
RubyGems version          1.3.6
Rack version              1.3
Rails version             4.0.0.beta
JavaScript Runtime        Node.js (V8)
Active Record version     4.0.0.beta
Action Pack version       4.0.0.beta
Action Mailer version     4.0.0.beta
Active Support version    4.0.0.beta
Middleware                ActionDispatch::Static, Rack::Lock, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::RemoteIp, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActiveRecord::ConnectionAdapters::ConnectionManagement, ActiveRecord::QueryCache, ActionDispatch::Cookies, ActionDispatch::Session::EncryptedCookieStore, ActionDispatch::Flash, ActionDispatch::ParamsParser, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20110805173523
```

### `assets`

`app/assets`에 미리 컴파일된 assets들을 보관하기 위하여 `rake assets:precompile`을 이용합니다. 미리 컴파일된 데이터를 지우기 위해서 `rake assets:clean`을 이용합니다.
[[[You can precompile the assets in `app/assets` using `rake assets:precompile` and remove those compiled assets using `rake assets:clean`.]]]

### `db`

가장 보편적인 작업은 `db:`입니다. Rake의 네임스페이스는 `migrate`와 `create`와  모든 마이그레이션 rake 작업들(`up`, `down`, `redo`, `reset`)들을 가지고 있습니다. `rake db:version`은 데이터베이스의 현재 버전의 문제해결을 위해 사용합니다.

더 많은 마이그레이션의 정보는 [Migrations](migrations.html) 가이드에 있습니다.
[[[The most common tasks of the `db:` Rake namespace are `migrate` and `create`, and it will pay off to try out all of the migration rake tasks (`up`, `down`, `redo`, `reset`). `rake db:version` is useful when troubleshooting, telling you the current version of the database.

More information about migrations can be found in the [Migrations](migrations.html) guide.]]]
### `doc`

`doc:` 네임스페이스는 애플리케이션과 API 문서, 가이드 문서를 만들기 위한 문서입니다. 보통 코드에 기반한 유용한 문서를 만들어 내고 필요한 경우 필요한 코드만 남깁니다. 임베디드 플랫폼에 대한 레일스 애플리케이션을 만드는 경우와 같습니다.

* `rake doc:app` 은 `doc/app` 폴더에 애플리케이션에 관한 문서를 만듭니다. 
* `rake doc:guides` 는 레일스 가이드를 `doc/guides` 폴더에 만듭니다.
* `rake doc:rails` 는 레일스 API 문서를 `doc/api`에 만듭니다.
[[[The `doc:` namespace has the tools to generate documentation for your app, API documentation, guides. Documentation can also be stripped which is mainly useful for slimming your codebase, like if you're writing a Rails application for an embedded platform.

* `rake doc:app` generates documentation for your application in `doc/app`.
* `rake doc:guides` generates Rails guides in `doc/guides`.
* `rake doc:rails` generates API documentation for Rails in `doc/api`.]]]

### `notes`

`rake notes`는 FIXEME, OPTIMIZE 또는 TODO 로 시작하는 주석을 찾습니다. 검색은 다음과 같은 확장자를 가진 파일에서 수행됩니다.  `.builder`, `.rb`, `.erb`, `.haml` , `.slim`
[[[`rake notes` will search through your code for comments beginning with FIXME, OPTIMIZE or TODO. The search is done in files with extension `.builder`, `.rb`, `.erb`, `.haml` and `.slim` for both default and custom annotations.]]]

```bash
$ rake notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/models/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

만약 FIXEME에 대한 구체적인 주석을 확인하려면 `rake notes:fixme` 를 이용할 수 있습니다. Note는 주석의 이름을 소문자로 보여줍니다.
[[[If you are looking for a specific annotation, say FIXME, you can use `rake notes:fixme`. Note that you have to lower case the annotation's name.]]]
```bash
$ rake notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/models/school.rb:
  * [ 17]
```

또한 사용자 정의 주석을 만들 수 있습니다. `rake notes:custom` 과 같이 사용합니다.  환경 변수는 `ANNOTATION`입니다.
[[[You can also use custom annotations in your code and list them using `rake notes:custom` by specifying the annotation using an environment variable `ANNOTATION`.]]]

```bash
$ rake notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/models/post.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE. 구체적인 주석과 사용자 정의 주석을 이용하는 경우에 주석의 이름(FIXME, BUG 등)은 출력되지 않습니다.

기본적으로, `rake notes`는 `app`, `config`, `lib`, `bin`과 `test` 디렉터리에서 볼 수 있습니다. 만약 다른 디렉터리에서 찾기를 원한다면 , 를 이용해서 `SOURCE_ANNOTATION_DIRECTORIES` 를 제공할 수 있습니다.
[[[NOTE. When using specific annotations and custom annotations, the annotation name (FIXME, BUG etc) is not displayed in the output lines.

By default, `rake notes` will look in the `app`, `config`, `lib`, `bin` and `test` directories. If you would like to search other directories, you can provide them as a comma separated list in an environment variable `SOURCE_ANNOTATION_DIRECTORIES`.]]]

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='spec,vendor'
$ rake notes
(in /home/foobar/commandsapp)
app/models/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`rake routes`는 모든 route의 목록을 보여줍니다. 애플리케이션에서 라우팅 문제가 생겼을 때, 좋은 URL을 이용한 익숙한 개요를 제공하기 때문에 유용합니다. 
[[[`rake routes` will list all of your defined routes, which is useful for tracking down routing problems in your app, or giving you a good overview of the URLs in an app you're trying to get familiar with.]]]

### `test`

INFO: 유닛테스트에 대한 좋은 설명은 이곳에서 볼 수 있습니다. [A Guide to Testing Rails Applications](testing.html)

레일스에서 제공하는 테스트 스위트는 `Test::Unit`이라고 부릅니다. 레일스는 사용의 안정성에 테스트를 이용합니다. 이러한 작업들은 `test:` 네임스페이스에 있으며 원하느 서로 다른 테스트를 실행할 수 있습니다.
[[[INFO: A good description of unit testing in Rails is given in [A Guide to Testing Rails Applications](testing.html)

Rails comes with a test suite called `Test::Unit`. Rails owes its stability to the use of tests. The tasks available in the `test:` namespace helps in running the different tests you will hopefully write.]]]

### `tmp`

`Rails.root/tmp` 디렉터리는 *nix 계열 OS의 /tmp 디렉터리와 같습니다. 세션과 같은 임시 파일, 프로세스 id, 캐시 액션들을 임시로 보관합니다.

The `tmp:` namespaced tasks will help you clear the `Rails.root/tmp` directory:
`tmp:` 네임스페이스는 `Rails.root/tmp` 디렉터리를 지울 수 있도록 도와줍니다.

* `rake tmp:cache:clear`는 `tmp/cache`를 삭제합니다.
* `rake tmp:sessions:clear`는 `tmp/sessions`를 삭제합니다.
* `rake tmp:sockets:clear`는 `tmp/sockets`를 삭제합니다.
* `rake tmp:clear`는 모든것을 삭제합니다. 캐시, 세션, 소켓
[[[The `Rails.root/tmp` directory is, like the *nix /tmp directory, the holding place for temporary files like sessions (if you're using a file store for files), process id files, and cached actions.

The `tmp:` namespaced tasks will help you clear the `Rails.root/tmp` directory:

* `rake tmp:cache:clear` clears `tmp/cache`.
* `rake tmp:sessions:clear` clears `tmp/sessions`.
* `rake tmp:sockets:clear` clears `tmp/sockets`.
* `rake tmp:clear` clears all the three: cache, sessions and sockets.]]]

### Miscellaneous

* `rake stats`는 코드에 대한 통계를 보여주는 훌륭한 도구입니다. KLOCs(1000라인 단위의 코드)로 보여주고 코드와 테스트의 비율을 보여줍니다.
* `rake secret` 은 세션 암호화를 위한 의사 무작위 키를 제공합니다.
* `rake time:zones:all` 은 레일스에서 사용할 수 있는 시간대 전부를 보여줍니다.
[[[* `rake stats` is great for looking at statistics on your code, displaying things like KLOCs (thousands of lines of code) and your code to test ratio.
* `rake secret` will give you a pseudo-random key to use for your session secret.
* `rake time:zones:all` lists all the timezones Rails knows about.]]]
### Custom Rake Tasks

사용자 정의 rake 작업들은 `.rake` 확장자를 가지고 `Rails.root/lib/tasks` 폴더에 위치합니다.
[[[Custom rake tasks have a `.rake` extension and are placed in `Rails.root/lib/tasks`.]]]

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # All your magic here
  # Any valid Ruby code is allowed
end
```

사용자 정의 작업들은 아규먼트를 이용할 수 있습니다:
[[[To pass arguments to your custom rake task:]]]

```ruby
task :task_name, [:arg_1] => [:pre_1, :pre_2] do |t, args|
  # You can use args from here
end
```

작업들을 네임스페이스를 이용하여 그룹으로 이용할 수 있습니다:
[[[You can group tasks by placing them in namespaces:]]]
```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Seriously, nothing
  end
end
```

작업들의 호출은 다음과 같이 합니다:
[[[Invocation of the tasks will look like:]]]

```bash
rake task_name
rake "task_name[value 1]" # entire argument string should be quoted
rake db:nothing
```

NOTE: 애플리케이션의 모델과 상호작용(쿼리 작업 등)은 `environment` 작업에 의존합니다. 
[[[NOTE: If your need to interact with your application models, perform database queries and so on, your task should depend on the `environment` task, which will load your application code.]]]

레일스 커맨드라인 고급
-------------------------------

커맨드라인의 더 고급의 유용한 옵션을 발견하고 요구 사항과 특정 워크플로우에 초점을 맞추고 있습니다. 이것들의 목록들이 여기에 있습니다.
[[[More advanced use of the command line is focused around finding useful (even surprising at times) options in the utilities, and fitting those to your needs and specific work flow. Listed here are some tricks up Rails' sleeve.]]]

### 레일스의 데이터베이스와 소스코드 관리(SCM)

새 레일스 애플리케이션을 만들 경우에 여러 종류의 데이터베이스와 소스코드 관리 시스템을 사용할 수 있습니다. 이것은 여러분의 시간과 타이핑 수를 줄일 수 있도록 도와줍니다.

`--git` 옵션과 `--database=postgresql` 옵션을 살펴 보겠습니다.
[[[When creating a new Rails application, you have the option to specify what kind of database and what kind of source code management system your application is going to use. This will save you a few minutes, and certainly many keystrokes.

Let's see what a `--git` option and a `--database=postgresql` option will do for us:]]]

```bash
$ mkdir gitapp
$ cd gitapp
$ git init
Initialized empty Git repository in .git/
$ rails new . --git --database=postgresql
      exists
      create  app/controllers
      create  app/helpers
...
...
      create  tmp/cache
      create  tmp/pids
      create  Rakefile
add 'Rakefile'
      create  README.rdoc
add 'README.rdoc'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

**gitapp* 을 만들면 빈 git 저장소가 만들고 생성된 파일을 추가하기 전에 빈 저장소를 초기화 해야 합니다.  이를 위해 데이터베이스 설정을 알아보겠습니다.
[[[We had to create the **gitapp** directory and initialize an empty git repository before Rails would add files it created to our repository. Let's see what it put in our database configuration:]]]

```bash
$ cat config/database.yml
# PostgreSQL. Versions 8.2 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On OS X with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On OS X with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem 'pg'
#
development:
  adapter: postgresql
  encoding: unicode
  database: gitapp_development
  pool: 5
  username: gitapp
  password:
...
...
```

또한 PostgreSQL의 선택에 따른 일부 코드를 database.yml에 생성합니다.

NOTE. SCM을 사용하기 위해 필요한 한가지는 애플리케이션 디렉터리에서 만들어야 하는 것 입니다. 첫째로 `rails new` 명령을 한 이후에 SCM을 초기화하여야 합니다.
[[[It also generated some lines in our database.yml configuration corresponding to our choice of PostgreSQL for database.

NOTE. The only catch with using the SCM options is that you have to make your application's directory first, then initialize your SCM, then you can run the `rails new` command to generate the basis of your app.]]]
