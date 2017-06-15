
Rails 애플리케이션 디버깅
============================

이 가이드에서는 Ruby on Rails 애플리케이션을 디버깅하는 다양한 방법을 소개합니다.

이 가이드의 내용:

* 디버깅의 목적
* 테스트에서 잡아낼 수 없었던 문제가 애플리케이션에서 발생했을 때의 추적 방법
* 다양한 디버깅 방법
* 스택 트레이스를 분석하는 방법

--------------------------------------------------------------------------------

디버깅을 위한 뷰 헬퍼
--------------------------

변수에 어떤 값이 저장되어 있는지를 확인하는 작업은 여러모로 필요합니다. Rails에서는 아래의 3개의 메소드를 사용할 수 있습니다.

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug` 헬퍼는 \<pre> 태그를 반환합니다. 이 태그 속에 YAML 형식으로 객체를 출력합니다. 이를 통해 객체의 정보를 사람이 읽을 수 있는 형태의 데이터로 변환할 수 있습니다. 예를 들자면, 아래의 코드가 뷰에 있다고 해봅시다.

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

여기에서는 다음의 출력을 얻을 수 있습니다.

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: It's a very helpful guide for debugging your Rails app.
  title: Rails debugging guide
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Rails debugging guide
```

### `to_yaml`

인스턴스 변수나 그 외의 모든 객체나 메소드를 YAML 형식으로 변환하여 출력합니다. 아래와 같이 사용할 수 있습니다.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

`to_yaml` 메소드는 메소드를 YAML 형식으로 변환하여 읽기 쉽게 만들어 주며, `simple_format` 헬퍼는 출력 결과를 콘솔처럼 각 줄별로 개행처리를 해줍니다. 이것이 `debug` 메소드가 동작하는 방식입니다.

결과, 아래와 같은 정보가 출력됩니다.

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: It's a very helpful guide for debugging your Rails app.
title: Rails debugging guide
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Rails debugging guide
```

### `inspect`

객체의 값을 출력하기 위한 메소드로 `inspect`도 사용할 수 있습니다. 특히 배열이나 해시값을 다루는 경우에 유용합니다. 이 메소드는 객체의 값을 문자열로 출력합니다. 다음은 예시입니다.

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

이 코드로부터 다음 결과를 얻을 수 있습니다.

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

로거(Logger)
----------

실행시에 정보를 로그에 저장해두면 유용하게 활용할 수 있습니다. Rails는 실행 환경마다 다른 로그 파일을 사용하도록 되어있습니다.

### 로거란?

Rails는 `ActiveSupport::Logger` 클래스를 사용하여 로그 정보를 출력합니다.
필요에 따라, `Log4r` 등의 다른 로거로 변경해도 좋습니다.

다른 로거의 설정은 `config/application.rb` 또는 각 환경의 설정파일에서 할 수 있습니다.

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

또는 `Initializer`에 _다음 중 하나_를 추가합니다.

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

TIP: 로그의 저장 위치는 기본으로 `Rails.root/log/`로 되어 있습니다. 로그 파일 이름은 애플리케이션이 실행되었을 때의 환경(development/test/production 등)이 사용됩니다.

### 로그의 출력 레벨

메시지의 로그 레벨이 설정되어 있는 최소 로그 레벨 이상이 되었을 경우에만 로그
파일에 그 메시지를 출력합니다. 현재 로그 레벨을 알고 싶은 경우에는
`Rails.logger.level` 메소드를 호출하세요.

지정가능한 로그 레벨은 `:debug`, `:info`, `:warn`, `:error`, `:fatal`,
`:unknown`의 6가지가 있으며, 각각 0부터 5까지의 숫자에 대응합니다. 기본 로그
레벨을 변경하려면 아래와 같이 추가하세요.

```ruby
config.log_level = :warn # 환경마다, 또는 initializer에서 사용 가능
Rails.logger.level = 0 # 언제라도 사용 가능
```

이것은 development 환경이나 staging 환경에서는 로그를 출력하고, 실제 환경에서는
필요 없는 정보를 로그에 출력하고 싶지 않을 경우 등에 유용합니다.

TIP: Rails의 기본 로그 레벨은 모든 환경에서 `debug`입니다.

### 메시지 전송

컨트롤러, 모델, 메일러에서 로그를 남기고 싶은 경우에는
`logger.(debug|info|warn|error|fatal)`를 사용합니다.

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

예를 들어 로그에 다른 정보를 기록하는 기능을 가지고 있는 메소드를 예시로 듭니다.

```ruby
  class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(params[:article])
    logger.debug "새로운 글: #{@article.attributes.inspect}"
    logger.debug "글이 문제 없는지?: #{@article.valid?}"

    if @article.save
      flash[:notice] =  'Article was successfully created.'
      logger.debug "글을 정상적으로 저장하고, 사용자를 이동시키는 중..."
      redirect_to(@article)
    else
      render action: "new"
    end
  end

  # ...
end
```

이 컨트롤러의 액션을 실행하면 아래와 같은 로그가 생성됩니다.

``` 
Processing ArticlesController#create (for 127.0.0.1 at 2008-09-08 11:52:54) [POST]
  Session ID: BAh7BzoMY3NyZl9pZCIlMDY5MWU1M2I1ZDRjODBlMzkyMWI1OTg2NWQyNzViZjYiCmZsYXNoSUM6J0FjdGl
vbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=--b18cd92fba90eacf8137e5f6b3b06c4d724596a4
  Parameters: {"commit"=>"Create", "article"=>{"title"=>"Debugging Rails",
"body"=>"I'm learning how to print in logs!!!", "published"=>"0"},
"authenticity_token"=>"2059c1286e93402e389127b1153204e0d1e275dd", "action"=>"create", "controller"=>"articles"}
새로운 글: {"updated_at"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!",
"published"=>false, "created_at"=>nil}
글이 문제 없는지?: true
  Article Create (0.000443)   INSERT INTO "articles" ("updated_at", "title", "body", "published",
"created_at") VALUES('2008-09-08 14:52:54', 'Debugging Rails',
'I''m learning how to print in logs!!!', 'f', '2008-09-08 14:52:54')
글을 정상적으로 저장하고, 사용자를 이동시키는 중...
Redirected to # Article:0x20af760>
Completed in 0.01224 (81 reqs/sec) | DB: 0.00044 (3%) | 302 Found [http://localhost/articles]
```

이처럼 로그에 추가 정보를 기록하게 되면, 예상외의 동작을 발견하기 용이하게 됩니다. 로그에 이런 저보를 추가한 경우에는, production 로그가 의미없는 대량의 메시지를 생성하지 않도록 적절한 로그 레벨을 사용해주세요.

### 태깅된 로깅

사용자와 계정을 여럿 사용하는 애플리케이션을 실행할 때에, 어떤 식으로든 커스텀 규칙을 만들어서 사용하는 것이 유용할 때가 있습니다. Active Support의 `TaggedLogging`을 사용하면 서브 도메인이나 요청의 ID등을 지정하여 로그에 포함시킬 수 있으며 애플리케이션 디버깅에서 무척 유용하게 호라용할 수 있습니다.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

### 로그가 성능에 주는 영향
로그 출력이 Rails 애플리케이션의 성능에 주는 영향은 무척 적습니다. 로그를 디스크에 저장하는 경우에는 특히나 더 그렇습니다. 단 상황에 따라서는 그렇다고 단언하기 힘들 때도 있습니다.

로그 레벨 `:debug`는 `:fatal`과 비교해서 무척 많은 문자열을 평가하고 (디스크 등에) 출력하기 때문에 성능에 주는 영향이 상대적으로 많이 커집니다.

그 이외에도 아래처럼 `Logger`를 여러번 호출했을 경우에 발생할 수 있는 실수도 주의해야 합니다.

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

이 예제에서는 로그 출력 레벨을 debug로 하지 않은 경우에도 성능이 저하됩니다. 외냐하면 이 코드에서 문자열을 평가할 필요가 있으며, 그 때에 비교적 동작이 느린 `String` 객체의 인스턴스화 작업과 실행에 시간이 걸리는 변수의 식전개(interpolation)가 필요하기 때문입니다. 따라서, 로거 메소드에 넘기는 인수는 블럭으로 만드는 것을 추천합니다. 블럭을 만들어 넘겨주면, 블럭에 대한 실행은 출력 레벨이 설정 레벨 이상일 경우에만 처리되기 때문입니다. 이 방법을 위의 코드에 적용하면 아래와 같이 다시 작성할 수 있습니다.

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

넘긴 블럭의 내용(여기에서는 문자열의 식전개)은 debug가 유효한 경우에만 처리됩니다. 이 방법을 통해서 얻어지는 성능의 개선은 대량의 로그를 출력하는 경우가 아니라면 크게 실감이 되지 않을 수 있습니다만, 그렇다 하더라도 채용할 만한 가치는 있습니다.

`byebug` 젬을 사용해서 디버깅하기
---------------------------------

코드가 기대한대로 동작하지 않는 경우에는 로그나 콘솔에 출력해서 문제를 진단할 필요가 있습니다. 하지만 이 방법으로는 에러 추적을 몇번이고 반복해야 하므로, 근본적인 원인을 찾기에는 그다지 효율이 좋다고 말할 수 없습니다. 실행중인 코드의 상황을 확인할 필요가 있는 경우에 가장 의지할 만한 것은 역시 디버거입니다.

디버거는 어디서 시작되는지 모르는 Rails의 코드를 추적할 때에도 유용합니다. 애플리케이션의 요청을 모두 디버깅하여, 자신이 작성한 코드로부터 Rails의 가장 깊은 부분까지 확인하는 방법을 배워봅시다.

### 설치

`byebug` 젬을 사용하면, Rails 코드에 중단점을 지정하여 단계별로 실행할 수 있습니다. 다음을 실행하는 것으로 젬을 설치할 수 있습니다.

```bash
$ gem install byebug
```

그러면 Rails 애플리케이션에서 `byebug` 메소드를 호출하면 언제든지 디버거를 동작시킬 수 있습니다.

다음은 예시입니다.

```ruby
class PeopleController < ApplicationController
  def new
    byebug
    @person = Person.new
  end
end
``` 

### 쉘

애플리케이션에서 `byebug`를 호출하면, 애플리케이션 서버가 실행되고 있는 터미널 윈도우 내부에서 디버거 쉘이 실행되고, `(byebug)`라는 프롬프트가 나타납니다. 프롬프트의 앞에는 실행하려고 했던 부분 전후의 코드가 나타나며, '=>'로 현재의 실행 라인을 보여줍니다. 다음은 예시입니다.

``` 
[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug)
```

브라우저로부터의 요청에 의해서 디버그 라인에 도착했을 경우, 요청한 브라우저 상의 처리는 디버거가 종료되어 요청에 대한 처리가 완전히 끝날 때까지 중단됩니다.

다음은 예시입니다.

```bash
=> Booting Puma
=> Rails 5.0.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.4.0 (ruby 2.3.1-p112), codename: Owl Bowl Brawl
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
Started GET "/" for 127.0.0.1 at 2014-04-11 13:11:48 +0200
  ActiveRecord::SchemaMigration Load (0.2ms)  SELECT "schema_migrations".* FROM "schema_migrations"
Processing by ArticlesController#index as HTML

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

그러면 애플리케이션의 깊은 곳으로 들어가봅시다. 우선 디버거의 헬프를 확인해
보는 것이 좋습니다. `help`를 입력해보세요.

```
(byebug) help

  break      -- Sets breakpoints in the source code
  catch      -- Handles exception catchpoints
  condition  -- Sets conditions on breakpoints
  continue   -- Runs until program ends, hits a breakpoint or reaches a line
  debug      -- Spawns a subdebugger
  delete     -- Deletes breakpoints
  disable    -- Disables breakpoints or displays
  display    -- Evaluates expressions every time the debugger stops
  down       -- Moves to a lower frame in the stack trace
  edit       -- Edits source files
  enable     -- Enables breakpoints or displays
  finish     -- Runs the program until frame returns
  frame      -- Moves to a frame in the call stack
  help       -- Helps you using byebug
  history    -- Shows byebug's history of commands
  info       -- Shows several informations about the program being debugged
  interrupt  -- Interrupts the program
  irb        -- Starts an IRB session
  kill       -- Sends a signal to the current process
  list       -- Lists lines of source code
  method     -- Shows methods of an object, class or module
  next       -- Runs one or more lines of code
  pry        -- Starts a Pry session
  quit       -- Exits byebug
  restart    -- Restarts the debugged program
  save       -- Saves current byebug session to a file
  set        -- Modifies byebug settings
  show       -- Shows byebug settings
  source     -- Restores a previously saved byebug session
  step       -- Steps into blocks or methods one or more times
  thread     -- Commands to manipulate threads
  tracevar   -- Enables tracing of a global variable
  undisplay  -- Stops displaying all or some expressions when program stops
  untracevar -- Stops tracing a global variable
  up         -- Moves to a higher frame in the stack trace
  var        -- Shows variables and its values
  where      -- Displays the backtrace

(byebug)
```

이전의 10줄을 확인하고 싶다면 `list-`(또는 `l-`)를 입력하세요.

```
(byebug) l-

[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
   1  class ArticlesController < ApplicationController
   2    before_action :set_article, only: [:show, :edit, :update, :destroy]
   3
   4    # GET /articles
   5    # GET /articles.json
   6    def index
   7      byebug
   8      @articles = Article.find_recent
   9
   10      respond_to do |format|
```

이를 통해서 파일 내부에서 `byebug`를 호출한 라인의 윗부분에 어떤 코드가 있는지를 확인할 수 있습니다. 마지막으로, 원래 있었던 곳으로 돌아가려면 `list=`를 입력하면 됩니다.

```
(byebug) list=

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

### 컨텍스트

애플리케이션을 디버깅하는 동안은 평소와는 다른 '컨텍스트'에 포함됩니다. 구체적으로는 스택의 다른 부분을 살펴볼 수 있는 컨텍스트입니다.

디버거는 중지 위치나 이벤트에 도달할 때에 '컨텍스트'를 생성합니다. 생성된 컨텍스트에는 중단되어 있는 프로그램에 대한 정보가 포함되어 있으며, 디버거는 그 정보를 사용하여 프레임 스택을 조사하거나 디버깅 중인 프로그램에 있는 변수를 평가합니다. 또한 디버깅 중인 프로그램이 어디에서 정지되어 있는지에 대한 정보도 포함됩니다.

`backtrace` 명령어(또는 그 별칭이기도 한 `where`명령어)를 사용하면 언제라도 애플리케이션의 백트레이스를 출력할 수 있습니다. 이것은 코드의 특정 위치에 도달할 때까지 어떤 과정을 거쳤는지 확인할 때에 사용할 수 있습니다.

```
(byebug) where
--> #0  ArticlesController.index
      at /PathToProject/app/controllers/articles_controller.rb:8
    #1  ActionController::BasicImplicitRender.send_action(method#String, *args#Array)
      at /PathToGems/actionpack-5.0.0/lib/action_controller/metal/basic_implicit_render.rb:4
    #2  AbstractController::Base.process_action(action#NilClass, *args#Array)
      at /PathToGems/actionpack-5.0.0/lib/abstract_controller/base.rb:181
    #3  ActionController::Rendering.process_action(action, *args)
      at /PathToGems/actionpack-5.0.0/lib/action_controller/metal/rendering.rb:30
...
```

현재의 프레임은 `-->`로 표시됩니다. `frame `_n_ 명령어(_n_은 프레임 번호)를 사용하면 트레이스 내의 어떤 컨텍스트로도 자유롭게 이동할 수 있습니다. 이 명령을 실행하면 `byebug`는 새로운 컨텍스트를 표시합니다.

```
(byebug) frame 2

[176, 185] in /PathToGems/actionpack-5.0.0/lib/abstract_controller/base.rb
   176:       # is the intended way to override action dispatching.
   177:       #
   178:       # Notice that the first argument is the method to be dispatched
   179:       # which is *not* necessarily the same as the action name.
   180:       def process_action(method_name, *args)
=> 181:         send_action(method_name, *args)
   182:       end
   183:
   184:       # Actually call the method associated with the action. Override
   185:       # this method if you wish to change how action methods are called,
(byebug)
```

코드를 한줄씩 실행하는 경우에도, 사용할 수 있는 변수는 동일합니다. 다시 말해, 이것이 바로 디버깅이라는 작업입니다.

`up [n]`(단축형인 `u`도 가능) 명령이나 `down [n]` 명령을 사용해서 스택을 _n_ 프레임 위로, 또는 아래로 이동하여 컨텍스트를 변경하는 것도 가능합니다. up은 스택 프레임 번호가 큰 방향으로 이동하며, down은 작은 방향으로 이동합니다.

### 스레드(Threads)

디버거에서 `thread`(단축형은 `th`) 명령을 사용하면, 실행중인 스레드 목록을 통해 표시/정지/재개/변경을 할 수 있습니다. 이 명령에서는 다음과 같은 옵션들이 있습니다.

* `thread`는 현재의 스레드를 표시합니다.
* `thread list`는 모든 스레드의 목록을 현재 상태 정보와 포함하여 보여줍니다. 현재 실행중인 스레드는 '+' 기호와 숫자로 표시됩니다.
* `thread stop `_n_는 스레드 _n_을 정지합니다.
* `thread resume `_n_는 스레드 _n_을 재개합니다.
* `thread switch `_n_은 현재의 스레드 컨텍스트를 _n_으로 변경합니다.

이 명령은 동시 실행중인 스레드의 디버깅 중에 경쟁 상태에 빠져있는 것은 아닌지 확인할 필요가 있는 경우 등에 무척 유용합니다.

### 변수를 조사하기

모든 식은, 현재 컨텍스트에서 평가됩니다. 식을 평가하기 위해서는 그냥 그 식을 입력하면 됩니다.

다음 예제에서는 현재 컨텍스트에서 정의된 인스턴스 변수를 출력하는 방법을 보이고 있습니다.

```
[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config]
```

이와 같이, 컨트롤러에서 접근할 수 있는 모든 변수가 출력됩니다. 출력된 변수 목록은 코드의 실행과 함께 동적으로 갱신됩니다. 예를 들어, `next` 명령으로 한 라인을 실행했다고 해봅시다(이 명령에 대해서는 다음에 설명합니다).

```
(byebug) next
[5, 14] in /PathTo/project/app/controllers/articles_controller.rb
   5     # GET /articles.json
   6     def index
   7       byebug
   8       @articles = Article.find_recent
   9
=> 10       respond_to do |format|
   11         format.html # index.html.erb
   12        format.json { render json: @articles }
   13      end
   14    end
   15
(byebug)
```

그러면 instance_variables을 다시 한번 확인해보죠.

```
(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config, :@articles]
```

정의 부분이 실행된 것으로, 이번에는 `@articles`도 인스턴스 변수 목록에 포함되어 있습니다.

TIP: `irb` 명령을 사용하는 것으로, **irb** 모드로 실행할 수도 있습니다. 이를 통해 호출한 시점의 컨텍스트 내에서 irb 세션이 시작됩니다. 단, 이 기능은 아직 테스트 단계입니다.

변수와 값의 목록을 확인하기 위해서 유용한 것은 `var` 메소드입니다.
`byebug`에서 이 메소드를 사용해 보세요.

```
(byebug) help var

  [v]ar <subcommand>

  Shows variables and its values


  var all      -- Shows local, global and instance variables of self.
  var args     -- Information about arguments of the current scope
  var const    -- Shows constants of an object.
  var global   -- Shows global variables.
  var instance -- Shows instance variables of self or a specific object.
  var local    -- Shows local variables in current scope.

```

이 메소드는 현재 컨텍스트에서 변수의 값을 검사할 때에 유용한 방법입니다. 예를 들자면, 현 시점에서 지역 변수가 아무것도 정의되지 않은 상태인지 확인해봅시다.

```
(byebug) var local
(byebug)
```

다음 방법으로 객체의 메소드를 조사해볼 수도 있습니다.

```
(byebug) var instance Article.new
@_start_transaction_state = {}
@aggregation_cache = {}
@association_cache = {}
@attributes = #<ActiveRecord::AttributeSet:0x007fd0682a9b18 @attributes={"id"=>#<ActiveRecord::Attribute::FromDatabase:0x007fd0682a9a00 @name="id", @value_be...
@destroyed = false
@destroyed_by_association = nil
@marked_for_destruction = false
@new_record = true
@readonly = false
@transaction_state = nil
@txn = nil
```

`display` 명령을 사용해서 변수를 모니터링할 수도 있습니다. 이것은 디버거에서 코드를 계속 실행하면서 변수의 값이 어떤 식으로 변하는지 추적할 때에 무척 유용합니다.

```
(byebug) display @articles
1: @articles = nil
```

스택 내에서 이동할 때마다 그 때의 변수와 값의 목록이 출력됩니다. 변수를 더이상 보고 싶지 않은 경우에는 `undisplay`_n_(_n_은 변수 번호)를 실행하세요. 위의 예제에서라면 변수 번호는 1입니다.

### 순차 실행

이것으로 트레이스 실행 중에 현재 실행 중인 위치를 확인하고, 이용 가능한 변수를 언제든지 확인할 수 있게 되었습니다. 애플리케이션의 실행에 대해서 좀 더 배워봅시다.

`step` 명령(단축형은 `s`)를 사용하면, 프로그램을 계속 실행하고, 다음 중단점까지
진행하면 디버거에게 제어 권한을 돌려줍니다. `next`는 `step`과 유사합니다만, `step`은 다음 줄의 코드를 실행하기 직전까지 진행하는 반면, `next`는 메소드가 있어도 그 내부를 확인하지 않고 진행합니다.

다음과 같은 예제를 생각해봅시다.

```ruby
Started GET "/" for 127.0.0.1 at 2014-04-11 13:39:23 +0200
Processing by ArticlesController#index as HTML

[1, 6] in /PathToProject/app/models/article.rb
   1: class Article < ApplicationRecord
   2:   def self.find_recent(limit = 10)
   3:     byebug
=> 4:     where('created_at > ?', 1.week.ago).limit(limit)
   5:   end
   6: end

(byebug)
```

`next`를 사용하여 메소드 호출 내부로 들어갔다고 해봅시다. 그런데 byebug는 들어가는 대신에 단순히 같은 컨텍스트의 다음 줄로 진행합니다. 이 예제의 경우, 다음 줄이란 메소드의 마지막 줄이 됩니다. 따라서 `byebug`는 이전 프레임에 있는 다음 줄로 점프합니다.

```
(byebug) next
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug)
```

같은 상황에서 `step`을 사용하면, 말그대로 'Ruby 코드에서 실행해야하는 다음 줄'로 진행합니다. 여기에서는 ActiveSupport의 `week` 메소드로 들어가게 됩니다.

```
(byebug) step

[50, 59] in /PathToGems/activesupport-5.0.0/lib/active_support/core_ext/numeric/time.rb
   50:     ActiveSupport::Duration.new(self * 24.hours, [[:days, self]])
   51:   end
   52:   alias :day :days
   53:
   54:   def weeks
=> 55:     ActiveSupport::Duration.new(self * 7.days, [[:days, self * 7]])
   56:   end
   57:   alias :week :weeks
   58:
   59:   def fortnights

(byebug)
```

이것은 자신의 코드의 버그를 찾기 위한 무척 좋은 방법입니다.

TIP: `step n`이나 `next n`을 사용하여 `n`번 만큼 한번에 진행할 수 있습니다.

### 중단점

중단점이란, 애플리케이션의 실행이 프로그램의 특정 장소에 도착했을 때에 중지할 위치를 가리킵니다. 그리고 그 장소에서 디버거 쉘이 실행됩니다.

`break`(또는 `b`) 명령을 사용해서 중단점을 동적으로 추가할 수도 있습니다. 직접 중단점을 추가할 수 있는 방법은 아래의 3가지가 있습니다.

* `break n`: 현재 소스 파일의 숫자 _n_이 가리키는 줄에 중단점을 설정합니다.
* `break file:line [if expression]`: _file_의 _n_번째 줄에 중단점을 설정합니다. _expression_이 주어진 경우, 그 식이 _true_를 반환하는 경우에만 디버거가 실행됩니다.
* `break class(.|\#)method [if expression]`: _class_에 정의되어 있는 _method_에 중단점을 설정합니다('.'과 '\#'는 각각 클래스와 인스턴스 메소드를 가리킵니다). _expression_의 동작은 file:n의 경우와 같습니다.

아까와 같은 상황으로 예시를 들어보겠습니다.

```
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug) break 11
Successfully created breakpoint with id 1

```

`info breakpoints`를 사용하여 중단점 목록을 확인하세요. 숫자를 넘기면 그 번호의 중단점을 보여줍니다. 그렇지 않으면 모든 중단점을 보여줍니다.

```
(byebug) info breakpoints
Num Enb What
1   y   at /PathTo/project/app/controllers/articles_controller.rb:11
```

`delete `_n_ 명령을 사용하면 _n_ 번 중단점을 제거합니다. 번호를 지정하지 않는 경우에는 현재 유효한 중단점을 모두 제거합니다.

```
(byebug) delete 1
(byebug) info breakpoints
No breakpoints.
```

중단점을 활성화하거나, 무효로 만들 수도 있습니다.

* `enable breakpoints [n [m [...]]]`: _breakpoints_로 지정한 중단점의 목록(지정하지 않은 경우는 모든 중단점)을 활성화합니다. 중단점은 활성화 상태로 생성됩니다.
* `disable breakpoints [n [m [...]]]`: _breakpoints_로 지정한 중단점이 비활성화 되어, 해당 지점에서 디버거가 멈추지 않게 됩니다.

### 예외 잡기

`catch exception-name` (단축형은 `cat exception-name`)을 사용하면 예외를 받는 핸들러가 따로 없다고 판단되는 경우에 _exception-name_으로 예외의 종류를 지정하여 가로챌 수 있습니다.

예외를 잡는 시점을 모두 목록으로 보고 싶은 경우에는 `catch`라고 입력하세요.

### 실행 재개

디버거로 정지된 애플리케이션을 재개하는 방법은 두 가지가 있습니다.

* `continue [n]`: 스크립트가 직전에 정지되어 있던 주소로부터 프로그램의 실행을 재개합니다. 이 경우, 그때까지 설정되어 있던 중단점이 모두 무시됩니다. 옵션으로 특정 줄 번호를 한번만 유효한 중단점으로 설정할 수 있습니다.
* `finish [n]`: 지정한 스택 프레임이 돌아올 때까지 계속해서 실행합니다. frame-number가 지정되어 있지 않은 경우에는 현재 선택되어 있는 프레임이 돌아올 때까지 실행합니다. 프레임의 위치가 지정되어 있지 않은(up이나 down, 또는 프레임 번호가 지정되어 있지 않은) 경우에는 현재 위치로부터 가장 가까운 프레임 또는 0프레임부터 시작합니다. 프레임 번호를 지정하면, 그 프레임이 돌아올 때까지 계속 실행합니다.

### 편집

디버거 상의 코드를 에디터에서 열기 위한 명령어는 두 가지가 있습니다.

* `edit [file:n]`: _file_을 에디터로 엽니다. 에디터는 EDITOR 환경 변수에 지정되어 있는 것을 사용합니다. _n_으로 몇번째 줄인지를 지정할 수 있습니다.

### 종료

디버깅을 종료할 때에는 `quit` 명령(단축형은 `q`) 또는 별칭인 `exit`을 사용하세요. 아니면 `q!`를 입력하여 `Really quit? (y/n)`를 무시할 수 있습니다.

quit을 실행하면 사실상 모든 스레드가 종료됩니다. 결과적으로 서버도 종료되므로, 재기동시킬 필요가 있습니다.

### 설정

`byebug`의 동작을 변경하기 위한 옵션이 몇가지 존재합니다.

```
(byebug) help set

  set <setting> <value>

  Modifies byebug settings

  Boolean values take "on", "off", "true", "false", "1" or "0". If you
  don't specify a value, the boolean setting will be enabled. Conversely,
  you can use "set no<setting>" to disable them.

  You can see these environment settings with the "show" command.

  List of supported settings:

  autosave       -- Automatically save command history record on exit
  autolist       -- Invoke list command on every stop
  width          -- Number of characters per line in byebug's output
  autoirb        -- Invoke IRB on every stop
  basename       -- <file>:<line> information after every stop uses short paths
  linetrace      -- Enable line execution tracing
  autopry        -- Invoke Pry on every stop
  stack_on_error -- Display stack trace when `eval` raises an exception
  fullpath       -- Display full file names in backtraces
  histfile       -- File where cmd history is saved to. Default: ./.byebug_history
  listsize       -- Set number of source lines to list by default
  post_mortem    -- Enable/disable post-mortem mode
  callstyle      -- Set how you want method call parameters to be displayed
  histsize       -- Maximum number of commands that can be stored in byebug history
  savefile       -- File where settings are saved to. Default: ~/.byebug_save
```

TIP: 이 설정들은 홈 폴더의 `.byebugrc` 파일에 저장해둘 수도 있습니다. 디버거가 실행되면, 이 설정이 전역으로 적용됩니다. 다음은 예시입니다.

```bash
set callstyle short
set listsize 25
```

`web-console` 젬으로 디버깅하기
-----------------------------------

웹 콘솔은 `byebug`와 비슷하지만 브라우저에서 동작한다는 점이 다릅니다. 개발중인 페이지에서 뷰나 컨트롤러의 컨텍스트에 존재하는 콘솔을 요청할 수 있습니다. 콘솔은 HTML 요소들의 뒤에 랜더링됩니다.

### 콘솔

컨트롤러의 액션이나 뷰에서 `console` 메소드로 콘솔을 호출할 수 있습니다.

예를 들어, 컨트롤러라면,

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

뷰라면,

```html+erb
<% console %>

<h2>New Post</h2>
```

와 같이 호출할 수 있습니다.

이는 뷰에 콘솔을 랜더링합니다. `console`의 호출 위치에 대해서 신경쓸 필요는 없습니다. 콘솔은 콘솔이 호출된 위치에 관계없이 HTML 요소들의 가장 마지막에 랜더링됩니다.

콘솔은 순수한 Ruby 코드로 실행됩니다. 클래스를 선언하거나 초기화할 수 있고, 새 모델을 만들거나, 변수들을 검사할 수도 있습니다.

NOTE: 요청 당 단 하나의 콘솔만을 랜더링할 수 있습니다. 그렇지 않으면 `web-console`이 두번째 `console` 호출시에 에러를 던질 것입니다.

메모리 누수 디버깅
------------------------------------

원인이 Ruby 코드 때문이든, 또는 C 코드 레벨 때문이든, Ruby 애플리케이션(Rails이든 아니든) 메모리 누수가 발생할 수 있습니다.

여기에서는 이러한 Valgrind와 같은 도구를 사용해서 그러한 메모리 누수를 찾고, 고치는 방법에 대해서 설명합니다.

### Valgrind

[Valgrind](http://valgrind.org/)는 Linux 전용 애플리케이션으로, C 코드 기반의 메모리 누수나 경쟁 상태를 검출할 때에 사용합니다.

Valgrind에는 다양한 메모리 관리상의 버그나 스레드 버그 등을 자동으로 검출하고, 프로그램의 상세한 프로파일링을 수행하기 위한 각종 도구가 존재합니다. 예를 들자면 인터프리터에 있는 C확장기능이 `malloc()`을 호출한 뒤에 `free()`를 올바르게 호출하지 않았을 경우, 이 메모리는 애플리케이션이 종료할 때까지 사용할 수 없게 됩니다.

Valgrind의 설치 방법과 Ruby에서의 사용 방법에 대해서는 [Valgrind와 Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/)(Evan Weaver, 영어)를 참조해주세요.

디버그용 플러그인
---------------------

애플리케이션의 에러를 검출하고, 디버깅하기 위한 Rails 플러그인이 다수 존재합니다. 디버깅할 때에 유용한 플러그인들을 소개합니다.

* [Footnotes](https://github.com/josevalim/rails-footnotes): 모든 Rails 페이지에 각주를 추가하고, 요청 정보를 보여주거나 TextMate로 소스 코드를 열어보기 위한 링크를 제공하거나 합니다.
* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master): 로그에 쿼리의 출처를 추가합니다.
* [Query Reviewer](https://github.com/nesquena/query_reviewer): 이 Rails 플러그인은 개발중인 select 쿼리의 앞에 "EXPLAIN"을 실행합니다. 또한 페이지마다 DIV를 추가하여 분석 대상의 쿼리마다 경고의 개요를 보여줍니다.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master): Rails 애플리케이션에서의 에러 발생시의 메일러 객체와 메일 통지 전송 템플릿의 기본 값을 제공합니다.
* [Better Errors](https://github.com/charliesome/better_errors): Rails 표준 에러 페이지를 소스 코드나 변수 조사에 편리한 컨텍스트 정보를 추가하여 보여줍니다.
* [RailsPanel](https://github.com/dejan/rails_panel): Rails 개발용의 Chrome 확장 기능입니다. 이것이 있으면 development.log에서 tail 명령을 실행할 필요가 없어집니다. Rails 애플리케이션의 요청에 대한 모든 정보를 브라우저 상(Developer Tools 패널)에서 볼 수 있습니다. db 시간, 랜더링 시간, 총 시간, 파라미터 리스트, 출력한 뷰 등을 볼 수 있습니다.

참고자료
----------

* [ruby-debug 홈페이지](http://bashdb.sourceforge.net/ruby-debug/home-page.html)
* [debugger 홈페이지](https://github.com/cldwalker/debugger)
* [byebug 홈페이지](https://github.com/deivid-rodriguez/byebug)
* [web-console 홈페이지](https://github.com/rails/web-console)
* [글: Debugging a Rails application with ruby-debug](http://www.sitepoint.com/debug-rails-app-ruby-debug/)
* [Ryan Bates의 루비 디버깅하기 스크린캐스트](http://railscasts.com/episodes/54-debugging-ruby-revised)
* [Ryan Bates의 스택 추적하기 스크린캐스트](http://railscasts.com/episodes/24-the-stack-trace)
* [Ryan Bates의 로거 스크린캐스트](http://railscasts.com/episodes/56-the-logger)
* [ruby-debug로 디버깅하기](http://bashdb.sourceforge.net/ruby-debug.html)
