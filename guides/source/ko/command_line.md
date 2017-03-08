The Rails Command Line
======================

이 가이드의 내용:

* Rails 애플리케이션을 생성하는 방법
* 모델, 컨트롤러, 데이터베이스의 마이그레이션 파일, 그리고 단위 테스트를 생성하는 방법
* 개발용 서버를 실행하는 방법
* 인터랙티브 쉘을 사용하여 객체를 테스트하는 방법

--------------------------------------------------------------------------------

NOTE: 이 가이드는 [Rails 시작하기](getting_started.html)를 읽고, 기본적인 Rails 지식이 있다는 것을 전제로 합니다.

커맨드라인의 기초
-------------------

Rails를 사용할 때에 가장 중요한 명령이 몇 가지 있습니다. 이들을 사용빈도 순으로 나열해보면 다음과 같습니다.

* `rails console`
* `rails server`
* `bin/rails`
* `rails generate`
* `rails dbconsole`
* `rails new app_name`

어떤 명령어든 `-h` 또는 `--help` 옵션을 사용해서 자세한 설명을 확인할 수 있습니다.

간단한 Rails 애플리케이션을 만들면서 하나씩 명령을 실행해봅시다.

### `rails new`

Rails를 설치한 다음에 해야하는 것은 `rails new` 명령을 실행해서 새로운 Rails 애플리케이션을 생성하는 일입니다.

INFO: 아직 Rails를 설치하지 않은 경우에는 `gem install rails`를 실행해서 Rails를 설치할 수 있습니다.

```bash
$ rails new commandsapp
    create
    create README.md
    create Rakefile
    create config.ru
    create .gitignore
    create Gemfile
    create app
    ...
    create  tmp/cache
    ...
        run bundle install
```

이러한 짧은 명령어를 실행하는 것만으로 Rails는 폴더 구성, 애플리케이션에 필요한 모든 코드 등, 무척 많은 것들을 준비해줍니다.

### `rails server`

`rails server` 명령을 실행하면, Rails에 포함되어 있는 Puma라는 이름의 웹서버가 실행됩니다. 웹브라우저로 애플리케이션에 접속할 때에는 이 명령을 사용합니다.

새로운 Rails 애플리케이션을 생성한 뒤 `rails server`로 바로 실행할 수 있습니다.

```bash
$ cd commandsapp
$ bin/rails server
=> Booting Puma
=> Rails 5.0.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.0.2 (ruby 2.3.0-p0), codename: Plethora of Penguin Pinatas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

단 3개의 명령으로 Rails 서버를 3000번 포트에서 실행했습니다. 브라우저를 켜고 [http://localhost:3000](http://localhost:3000)를 열어보세요. Rails 애플리케이션이 동작중임을 확인할 수 있습니다.

INFO: 서버를 실행할 때에는 `rails s`처럼 "s"라는 별칭을 사용할 수 있습니다.

`-p` 옵션을 사용하여 사용할 포트를 변경할 수 있습니다. 서버 환경은 `-e` 옵션으로 변경할 수 있으며, 지정하지 않으면 development 환경이 사용됩니다.

```bash
$ bin/rails server -e production -p 4000
```

`-b` 옵션을 사용하면 Rails를 특정 IP에 바인딩할 수 있습니다. 기본값은 0.0.0.0입니다. `-d` 옵션으로 서버를 데몬으로 기동할 수 있습니다.

### `rails generate`

`rails generate` 명령으로 템플릿을 사용하여 다양한 코드를 생성할 수 있습니다. `rails generate`를 실행하면 이용가능한 제너레이터 목록을 확인할 수 있습니다.

INFO: 제너레이터 명령을 실행할 때에는 `rails g`처럼 "g"라는 별칭을 사용할 수 있습니다.

```bash
$ bin/rails generate
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

NOTE: 제너레이터 잼을 설치하거나 플러그인에 포함되어 있는 제너레이터를 설치하여 사용할 수 있습니다. 또한 직접 제너레이터를 개발할 수도 있습니다.

제너레이터를 사용하면 애플리케이션을 움직일때 필요한 [**Boilerplate Code**](http://en.wikipedia.org/wiki/Boilerplate_code)를 작성할 필요가 없어지므로, 시간을 절약할 수 있습니다.

그렇다면 컨트롤러 제너레이터를 사용해서, 컨트롤러를 생성해봅시다. 어떤 명령을 사용하면 좋을까요? 제너레이터에게 물어봅시다.

INFO: Rails의 모든 명령에는 각각의 도움말이 존재합니다. 많은 *nix(역주: Linux나 Unix, Unix 계열의 OS 등)의 유틸리티와 마찬가지로 명령의 마지막에 `--help` 또는 `-h` 옵션을 넘겨주세요(예: `rails server --help`).

```bash
$ bin/rails generate controller
Usage: rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a path like 'parent_module/controller_name'.

    ...

Example:
    `rails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```


컨트롤러 제너레이터에는 `generate controller ControllerName action1 action2`와 같은 형식의 인수를 넘길 수 있습니다. **hello** 액션을 실행하면, 멋진 메시지를 반환해주는 `Greetings` 컨트롤러를 만들어보죠.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get "greetings/hello"
     invoke    erb 
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke  assets
     invoke    coffee
     create      app/assets/javascripts/greetings.js.coffee
     invoke    scss
     create      app/assets/stylesheets/greetings.css.scss
```

어떠한 것들이 생성되었을까요? 몇몇 폴더가 애플리케이션에 존재하는 것을 확인하고, 컨트롤러 파일, 뷰 파일, 기능 테스트를 위한 파일, 뷰 헬퍼, JavaScript 파일, 그리고 스타일 시트를 생성했습니다.

컨트롤러(`app/controllers/greetings_controller.rb`)를 찾아서 조금 고쳐봅시다.

  ```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Hello, how are you today?"
  end 
end 
```

메시지를 표시하기 위한 뷰(`app/views/greetings/hello.html.erb`)도 편집합시다.

```erb
<h1>A Greeting for You!</h1>
<p><%= @message %></p>
```

`rails server`로 서버를 실행합니다.

```bash
$ bin/rails server
=> Booting Puma...
```

URL은 [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello)입니다.

INFO: 일반적인 Rails 애플리케이션에서는 URL이 http://(host)/(controller)/(action)와 같은 패턴이 됩니다. 또한 http://(host)/(controller)라는 패턴의 URL은 컨트롤러의 **index** 액션에 대한 URL로 인식됩니다.

Rails에는 데이터 모델을 위한 제너레이터도 포함되어 있습니다.

```bash
$ bin/rails generate model
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

NOTE: 사용가능한 필드 타입(field types)에 대해서는 `TableDefinition`의 컬럼 메소드를 [API 문서](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column)를 참조해주세요.

여기에서는 직접 모델을 만드는 대신에(모델을 생성하는 방법은 나중에 설명하겠습니다), scaffold를 생성해봅시다. Rails에서의 **scaffold**란 모델, 모델을 위한 마이그레이션, 모델을 조작하기 위한 컨트롤러, 모델을 조작, 표시하기 위한 뷰, 이 모두를 위한 테스트 코드를 포함한 것을 가리킵니다.

"HighScore"라는 이름의 리소스를 만들어봅시다. 이 리소스의 역할은 비디오 게임의 최고 득점을 기록하는 것입니다.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20130717151933_create_high_scores.rb
    create    app/models/high_score.rb
    invoke  test_unit
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
    invoke  test_unit
    create      test/controllers/high_scores_controller_test.rb
    invoke  helper
    create      app/helpers/high_scores_helper.rb
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    invoke  assets
    invoke    coffee
    create      app/assets/javascripts/high_scores.coffee
    invoke    scss
    create      app/assets/stylesheets/high_scores.scss
    invoke  scss
   identical    app/assets/stylesheets/scaffolds.scss
```

제너레이터는 모델, 컨트롤러, 헬퍼, 레이아웃, 기능 테스트, 유닛 테스트, 스타일시트용의 데이터가 존재하는지를 체크하고, 뷰, 컨트롤러, 모델, (`high_scores` 테이블과 필드를 생성하는)마이그레이션을 생성하고, 이 **리소스**를 가리키는 라우팅을 추가하고 마지막으로 이 모든 것을 위한 테스트를 생성합니다.

그리고 **migrate**를 실행하여 마이그레이션을 적용해야 합니다. 다시 말해서, 데이터베이스 스키마를 변경하기 위한 Ruby 코드(`20130717151933_create_high_scores.rb`와 같은 파일에 작성되어 있는 코드입니다)를 실행해야 합니다. 데이터베이스란 어떤 데이터베이스를 가리키는 걸까요? `bin/rails db:migrate` 명령을 실행하면 Rails는 SQLite3에 새로운 데이터베이스를 생성합니다. bin/rails에 대해서는 나중에 더 자세하게 설명하겠습니다.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: 유닛 테스트에 대해서 설명하겠습니다. 유닛 테스트란 코드를 테스트하고 단언을 하기 위한 코드입니다. 유닛 테스트에서는 모델의 메소드 중 일부를 가져와 그 인수와 반환값을 검사합니다. 유닛 테스트는 당신의 친구이며, 이를 작성하는 것이 좀 더 나은 삶을 살 수 있게 해줄 것입니다. 자세한 설명은 [테스팅 가이드](testing.html)를 참고하세요.

Rails가 생성한 인터페이스를 확인해봅시다.

```bash
$ bin/rails server
```

브라우저에서 [http://localhost:3000/high_scores](http://localhost:3000/high_scores)를 열어봅시다. 새로운 최고 점수를 생성할 수 있습니다(스페이스 인베이더에서 55,160점이라든가 말이죠!) (역주: 2003년에 Donald Hayes가 기록한 점수입니다).

### `rails console`

`console` 명령을 사용하면 커맨드라인에서 Rails 애플리케이션을 직접 다룰 수 있습니다. `rails console`은 내부적으로 IRB를 사용하고 있으므로, IRB를 사용한 적이 있다면, 사용하는 것은 간단합니다. 떠오른 아이디어를 시험해보거나, 웹사이트에 접속하지 않고 서버의 데이터를 변경할 때에 유용합니다.

INFO: 이 명령을 실행할 때에는 `rails c`처럼 "c"라는 별칭을 사용할 수 있습니다.

`console` 명령을 실행할 환경을 지정할 수도 있습니다.

```bash
$ bin/rails console staging
```

데이터를 변경하지 않고 테스트를 하고 싶은 경우에는 `rails console --sandbox`를 실행하세요.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 5.0.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### app 객체와 helper 객체

`rails console`를 실행하는 도중 `app` 객체와 `helper` 객체에 접근할 수 있습니다.

`app` 메소드를 사용하면 URL 헬퍼와 path 헬퍼에 접근할 수 있습니다. 또한 request를 던질 수도 있습ㄴ니다.

```bash
>> app.root_path
=> "/"

>> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

`helper` 메소드를 사용하면 Rails 애플리케이션이 제공하는 헬퍼와 직접 구현한 헬퍼에 접근할 수 있습니다.

```bash
>> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

>> helper.my_custom_helper
=> "my custom helper"
```

### `rails dbconsole`

`rails dbconsole` 명령은 사용하고 있는 데이터베이스를 찾고, 적절한 데이터베이스 커맨드라인 툴을 실행합니다(또한 커맨드라인 툴에서 필요한 인수를 넘길 수도 있습니다). MySQL(MariaDB도 포함합니다), PostgreSQL, SQLite, 그리고 SQLite3을 지원합니다.

INFO: DB 콘솔 명령을 실행할 때에는 `rails db`와 같이 "db"라는 별칭을 사용할 수 있습니다.

### `rails runner`

`runner` 명령으로 Rails의 컨텍스트에서 Ruby 코드를 실행할 수 있습니다. 예를 들자면 다음과 같이 말이죠.

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: 러너 명령을 실행할 때에는 `rails r`와 같은 별칭 "r"을 사용할 수 있습니다.

`-e`로 `runner` 명령을 실행할 환경을 지정할 수 있습니다.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

아니면 파일에 필요한 Ruby 코드를 작성해두고, 이를 넘길 수도 있습니다.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```


### `rails destroy`

`destroy`는 `generate`와 반대입니다. 제너레이터 명령이 무엇을 실행했는지 확인하고, 그것을 이전 상태로 되돌립니다.

INFO: `rails d`처럼 "d"라는 별칭을 사용해 destroy 명령을 실행할 수 있습니다.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```
```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

bin/rails
---------

Rails 5.0+ 부터 rake 명령이 rails 명령에 포함되어 `bin/rails`가 새로운 실행 명령이 되었습니다.

애플리케이션의 최상단 폴더에서 `bin/rails --help`를 실행하면 bin/rails로 실행할 수 있는 명령 목록을 가져올 수 있습니다. 각 명령은 설명을 가지고 있으며, 필요한 것을 찾을 때에 도움을 줄 것입니다.

```bash
$ bin/rails --help
Usage: rails COMMAND [ARGS]

The most common rails commands are:
generate    Generate new code (short-cut alias: "g")
console     Start the Rails console (short-cut alias: "c")
server      Start the Rails server (short-cut alias: "s")
...

All commands can be run with -h (or --help) for more information.

In addition to those commands, there are:
about                               List versions of all Rails ...
assets:clean[keep]                  Remove old compiled assets
assets:clobber                      Remove compiled assets
assets:environment                  Load asset compile environment
assets:precompile                   Compile all the assets ...
...
db:fixtures:load                    Loads fixtures into the ...
db:migrate                          Migrate the database ...
db:migrate:status                   Display status of migrations
db:rollback                         Rolls the schema back to ...
db:schema:cache:clear               Clears a db/schema_cache.dump file
db:schema:cache:dump                Creates a db/schema_cache.dump file
db:schema:dump                      Creates a db/schema.rb file ...
db:schema:load                      Loads a schema.rb file ...
db:seed                             Loads the seed data ...
db:structure:dump                   Dumps the database structure ...
db:structure:load                   Recreates the databases ...
db:version                          Retrieves the current schema ...
...
restart                             Restart app by touching ...
tmp:create                          Creates tmp directories ...
```

INFO: 또는 `bin/rails -T`를 사용하여 목록을 가져올 수 있습니다.

### `about`

`bin/rails about`를 실행하면, Ruby, RubyGems, Rails, Rails의 서브 컴포넌트(역주: Active Record나 Action Pack 등)의 버전, Rails 애플리케이션의 폴더명, 현재 Rails의 환경 이름과 데이터베이스의 어댑터, 그리고 스키마의 버전이 표시됩니다. 누군가에게 질문을 하고 싶을 때나, 보안 패치가 자신의 애플리케이션에 영향을 주고 있는지 등, 현재 사용하고 있는 Rails에 대한 정보가 필요할 때에 사용할 수 있습니다.

```bash
$ bin/rails about
About your application's environment
Rails version             5.0.0
Ruby version              2.2.2 (x86_64-linux)
RubyGems version          2.4.6
Rack version              1.6
JavaScript Runtime        Node.js (V8)
Middleware                Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x007ffd131a7c88>, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::RemoteIp, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActiveRecord::ConnectionAdapters::ConnectionManagement, ActiveRecord::QueryCache, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20110805173523
```

### `assets`

`bin/rails assets:precompile`를 실행하면 `app/assets` 하에 있는 파일을 컴파일합니다. 또한 `bin/rails assets:clean`를 실행하면 오래된 컴파일 후의 파일들을 삭제할 수 있습니다. `assets:clean`은 새로운 assets의 빌드를 실행하며 오래된 assets에 대한 링크를 남기는 'Rolling deploy'라는 방식을 채용하고 있습니다.

`public/assets`에 있는 내용물을 완전히 제거할 때에는 `bin/rails assets:clobber`를 실행하세요.

### `db`

`db:`라는 bin/rails의 네임스페이스에 속해있는 태스크 중에서 가장 많이 사용되는 것은 `migrate`와 `create`입니다. 마이그레이션에 대한 태스크(`up`, `down`, `redo`, `reset`)은 모두 한번씩 실험해보는 것을 추천합니다. `bin/rails db:version`을 사용하면 데이터베이스의 버전을 알 수 있으므로 문제가 생겼을 때에 도움이 됩니다.

마이그레이션에 대해서는 [마이그레이션](active_record_migrations.html)에서 좀 더 자세하게 다루고 있습니다.

### `notes`

`bin/rails notes`는 코드의 주석으로부터 FIXME, OPTIMIZE, TODO로 시작하는 줄을 찾아서 출력합니다. 검색 대상이 되는 파일의 확장자는 `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js`, `.erb`로, 기본으로 사용되는 어노테이션 이외의 다른 것들도 사용할 수 있습니다.

```bash
$ bin/rails notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/models/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

검색할 파일 확장자를 추가하려면 `config.annotations.register_extensions` 옵션을 사용하세요. 이 옵션은 확장자의 목록과, 출력할 줄을 선택하는 정규표현을 인수로 받습니다.

  ```ruby
config.annotations.register_extensions("scss", "sass", "less") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

특정 어노테이션만을 출력하고 싶은 경우(예를 들어 FIXME 만을 출력하고 싶은 때)에는 `bin/rails notes:fixme`처럼 실행하시면 됩니다. 이 때, 어노테이션은 소문자로 적어야한다는 점을 주의해주세요.

```bash
$ bin/rails notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/models/school.rb:
  * [ 17]
```

다른 어노테이션을 사용하고 싶은 경우에는 `bin/rails notes:custom`라고 쓰고 `ANNOTATION` 환경 변수를 사용해서 어노테이션 이름을 지정합니다.

```bash
$ bin/rails notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/models/article.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE: 특정 어노테이션만을 출력할 때나, 독자적인 어노테이션을 출력하는 경우에는 FIXME나 BUG같은 각 어노테이션의 이름은 출력되지 않습니다.

기본으로 `rails notes`는 `app`, `config`, `db`, `lib`, `test` 폴더를 확인합니다.
다른 폴더들에 대해서도 탐색하고 싶다면 쉼표로 구분된 목록을
`SOURCE_ANNOTATION_DIRECTORIES` 환경 변수에 넘겨주세요.

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='spec,vendor'
$ bin/rails notes
(in /home/foobar/commandsapp)
app/models/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`rails routes`를 사용하면 정의되어있는 모든 라우팅을 출력할 수 있습니다. 이것은 라우팅에서 생긴 문제를 해결해야하거나, 애플리케이션의 라우팅 전체를 이해해야 할 때에 도움이 됩니다.

### `test`

INFO: Rails에서의 유닛 테스트에 대해서는 [Rails 애플리케이션 테스트하기](testing.html)를 참조해주세요.

Rails에는 Minitest라고 불리는 테스트 라이브러리가 포함되어 있습니다. Rails에서는 테스트를 작성하여 안정적인 애플리케이션을 개발합니다. `test:`라는 네임스페이스에 정의되어 있는 태스크는 앞으로 작성할 다양한 테스트를 실행할 때에 도움이 될 것입니다.

### `tmp`

`Rails.root/tmp` 폴더는 (*nix 계열에서 말하는 `/tmp` 폴더처럼) 프로세스ID 파일, 액션 캐시와 같은 임시 파일을 저장하기 위한 폴더입니다.

`tmp:`라는 네임스페이스에는 `Rails.root/tmp` 폴더를 생성, 삭제하기 위한 태스크가 포함되어 있습니다.

* `rails tmp:cache:clear`로 `tmp/cache`를 비웁니다.
* `rails tmp:sockets:clear`로 `tmp/sockets`를 비웁니다.
* `rails tmp:clear`로 `cache, sessions, sockets`를 비웁니다.
* `rails tmp:create`로 캐시, 소켓, pid의 tmp 폴더를 생성합니다.

### 그 이외의 태스크

* `rails stats`는 코드에 대한 테스트 비율이나 KLOCs(코드의 라인 수) 등, 코드에 대한 총계를 표시합니다.
* `rails secret`는 세션 시크릿에 사용하는 의사난수를 생성합니다.
* `rails time:zones:all`는 Rails가 다룰 수 있는 모든 시간대를 표시합니다.

### Rake 태스크 만들기

Rake 태스크의 확장자는 `.rake`로 `Rails.root/lib/tasks`에 저장합니다.
그리고 직접 태스크를 생성할 수 있는 `bin/rails generate task`라는 명령도 있습니다.

  ```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # All your magic here
  # Any valid Ruby code is allowed
end 
```

태스크에 인수를 넘기려면 다음과 같이 작성합니다.

  ```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

네임스페이스에서 태스크를 정의하여 태스크를 그룹으로 묶을 수 있습니다.

  ```ruby
namespace :db do 
  desc "This task does nothing"
  task :nothing do
    # Seriously, nothing
  end 
end 
```

그리고 아래와 같이 태스크를 호출합니다.

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # entire argument string should be quoted
$ bin/rails db:nothing
```

NOTE: 애플리케이션 내의 모델을 사용하거나, 데이터베이스에 대해서 쿼리를 던지고 싶은 경우에는 태스크에서 `environment` 태스크에 대한 의존성을 정의해야 합니다. `environment` 태스크는 애플리케이션의 코드를 읽어오는 태스크입니다.

Rails의 고급 커맨드 라인 명령
-------------------------------

여기에서는 작업을 줄여주는 유용하고 편리한(또는 놀랄만한) 옵션을 찾아서 소개합니다.

### 데이터베이스와 소스 관리 시스템과 Rails

새로운 Rails 애플리케이션을 생성할 때에 데이터베이스의 종류나 소스 관리 시스템의 종류를 지정할 수 있습니다. 이 옵션을 사용해서 타이핑에 걸리는 시간을 절약할 수 있습니다.

그러면 `--database=postgresql` 옵션과 `--git` 옵션이 어떻게 동작하는지 확인해봅시다.

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
      create  README.md
add 'README.md'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

Rails가 git의 저장소에 파일을 생성하기 전에 **gitapp** 폴더를 생성하고 빈 git 저장소를 초기화 해둘 필요가 있습니다. Rails가 어떤 데이터베이스 설정을 생성했는지 확인해봅시다.

```bash
$ cat config/database.yml
# PostgreSQL. Versions 9.1 and up are supported.
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

Rails는 선택한 데이터베이스(PostgreSQL)에 대응하도록 database.yml를 구성합니다.

NOTE: 소스 코드 관리 시스템에 대한 옵션을 사용할 때에는, 우선 애플리케이션의 폴더를 생성하고 소스 코드 관리 시스템을 초기화한 이후에 `rails new` 명령어를 실행해주세요.
