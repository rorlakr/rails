[Debugging Rails Applications] 레일스 응용프로그램 디버깅하기
============================

본 가이드는 루비 온 레일스 응용프로그램을 디버깅하기 위한 기술을 소개합니다. [[[This guide introduces techniques for debugging Ruby on Rails applications.]]]

본 가이드를 읽은 후, 다음을 알게 됩니다. [[[After reading this guide, you will know:]]]

* 디버깅의 목적. [[[The purpose of debugging.]]]

* 테스트 결과가 확인되지 않는 응용프로그램에서 문제와 이슈를 추척하는 방법. [[[How to track down problems and issues in your application that your tests aren't identifying.]]]

* 디버깅의 다른 방법. [[[The different ways of debugging.]]]

* 스택 추적을 분석하는 방법. [[[How to analyze the stack trace.]]]

--------------------------------------------------------------------------------

[View Helpers for Debugging] 디버깅을 위한 뷰 헬퍼들
--------------------------

한가지 일반적인 작업은 변수의 내용을 확인하는 것입니다. 레일스에서는 다음의 세 가지 메서드로 확인할 수 있습니다. [[[One common task is to inspect the contents of a variable. In Rails, you can do this with three methods:]]]

* `debug`
* `to_yaml`
* `inspect`

### `debug`

`debug` 헬퍼는 YAML 형식을 사용하여 객체를 렌더링한 \<pre> 태그를 반환합니다. 이것은 어떤 객체라도 사람이 읽을 수 있는 데이터를 생성합니다. 예를 들어, 뷰에 다음의 코드가 있다면: [[[The `debug` helper will return a \<pre> tag that renders the object using the YAML format. This will generate human-readable data from any object. For example, if you have this code in a view:]]]

```html+erb
<%= debug @post %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

다음가 같은 것을 볼 것입니다. [[[You'll see something like this:]]]

```yaml
--- !ruby/object:Post
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

YAML 형식으로 인스턴스 변수나 다른 객체 혹은 메서드를 표시하는 것은 이 방법으로 달성할 수 있습니다. [[[Displaying an instance variable, or any other object or method, in YAML format can be achieved this way:]]]

```html+erb
<%= simple_format @post.to_yaml %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

`to_yaml` 메서드는 메서드를 보다 읽기 쉬운 YAML 포맷으로 변환합니다. 그리고 `simple_format` 헬퍼는 콘솔에 표시하는 것처럼 각 라인을 렌더링하는데 사용됩니다. 이것이 `debug` 메서드가 마법을 발휘하는 방법입니다. [[[The `to_yaml` method converts the method to YAML format leaving it more readable, and then the `simple_format` helper is used to render each line as in the console. This is how `debug` method does its magic.]]]

그 결과로 뷰에서는 다음과 같은 것을 보게 될 것입니다. [[[As a result of this, you will have something like this in your view:]]]

```yaml
--- !ruby/object:Post
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

특히 배열 혹은 해시와 함께 사용할 때, 객체의 값을 표시하는 또다른 유용한 메서드는 `inspect`입니다. 이것은 객체의 값을 문자열로 출력할 것입니다. 예를 들면: [[[Another useful method for displaying object values is `inspect`, especially when working with arrays or hashes. This will print the object value as a string. For example:]]]

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @post.title %>
</p>
```

위 코드는 다음과 같이 렌더링될 것입니다: [[[Will be rendered as follows:]]]

```
[1, 2, 3, 4, 5]

Title: Rails debugging guide
```

[The Logger] 로거
----------

런타임 중에 정보를 로그 파일에 기록하는 것 또한 유용할 것입니다. 레일스는 각 런타임 환경별로 개별 로그 파일을 관리합니다. [[[It can also be useful to save information to log files at runtime. Rails maintains a separate log file for each runtime environment.]]]

### [What is the Logger?] 로거는 무엇인가?

레일스는 로그 정보를 기록하기 위해 `ActiveSupport::Logger` 클래스를 활용합니다. 원한다면 `Log4r`과 같은 다른 로거로 대체할 수도 있습니다. [[[Rails makes use of the `ActiveSupport::Logger` class to write log information. You can also substitute another logger such as `Log4r` if you wish.]]]

`environment.rb` 혹은 다른 환경 파일에서 대체 로거를 지정할 수 있습니다. [[[You can specify an alternative logger in your `environment.rb` or any environment file:]]]

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

또는 `Initializer` 섹션 안에, 다음 중 하나를 추가합니다. [[[Or in the `Initializer` section, add _any_ of the following]]]

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

TIP: 기본값으로, 각 로그는 `Rails.root/log/` 아래 생성됩니다. 그리고 로그 파일명은 `environment_name.log` 입니다. [[[TBy default, each log is created under `Rails.root/log/` and the log file name is `environment_name.log`.]]]

### Log Levels

무엇인가가 로그될 때, 메시지의 로그 레벨이 로그 레벨 설정값 이상이라면 로그는 해당하는 로그에 출력됩니다. 만약 현재 로그 레벨을 알고 싶다면 `Rails.logger.level` 메서드를 호출할 수 있습니다. [[[When something is logged it's printed into the corresponding log if the log level of the message is equal or higher than the configured log level. If you want to know the current log level you can call the `Rails.logger.level` method.]]]

사용 가능한 로그 레벨은: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, 그리고 `:unknown`이며 이에 상응하는 로그 레벨 번호는 0부터 5입니다. 기본 로그 레벨을 변경하려면 다음을 사용하십시오. [[[The available log levels are: `:debug`, `:info`, `:warn`, `:error`, `:fatal`, and `:unknown`, corresponding to the log level numbers from 0 up to 5 respectively. To change the default log level, use]]]

```ruby
config.log_level = :warn # In any environment initializer, or
Rails.logger.level = 0 # at any time
```

이것은 개발 환경과 스테이징 환경 하에서 로그를 기록하고자 할 때 유용하지만, 프로덕션 로그가 불필요한 정보로 넘쳐 흐르는 것을 원하지는 않을 것입니다. [[[This is useful when you want to log under development or staging, but you don't want to flood your production log with unnecessary information.]]]

TIP: 기본 레일스 로그 레벨은 프로덕션 모드에서는 `info`이고 개발과 테스트 모드에서는 `debug`입니다. [[[The default Rails log level is `info` in production mode and `debug` in development and test mode.]]]

### [Sending Messages] 메시지 보내기

현재 로그를 기록하려면 컨트롤러, 모델 혹은 메일러에서 `logger.(debug|info|warn|error|fatal)` 메서드를 사용하십시오. [[[To write in the current log use the `logger.(debug|info|warn|error|fatal)` method from within a controller, model or mailer:]]]

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

여기 부가 로깅으로 계측된 메서드의 예제가 있습니다:[[[Here's an example of a method instrumented with extra logging:]]]

```ruby
class PostsController < ApplicationController
  # ...

  def create
    @post = Post.new(params[:post])
    logger.debug "New post: #{@post.attributes.inspect}"
    logger.debug "Post should be valid: #{@post.valid?}"

    if @post.save
      flash[:notice] = 'Post was successfully created.'
      logger.debug "The post was saved and now the user is going to be redirected..."
      redirect_to(@post)
    else
      render action: "new"
    end
  end

  # ...
end
```

아래는 이 컨트롤러 액션이 실행될 때 생성된 로그의 예입니다: [[[Here's an example of the log generated when this controller action is executed:]]]

```
Processing PostsController#create (for 127.0.0.1 at 2008-09-08 11:52:54) [POST]
  Session ID: BAh7BzoMY3NyZl9pZCIlMDY5MWU1M2I1ZDRjODBlMzkyMWI1OTg2NWQyNzViZjYiCmZsYXNoSUM6J0FjdGl
vbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=--b18cd92fba90eacf8137e5f6b3b06c4d724596a4
  Parameters: {"commit"=>"Create", "post"=>{"title"=>"Debugging Rails",
 "body"=>"I'm learning how to print in logs!!!", "published"=>"0"},
 "authenticity_token"=>"2059c1286e93402e389127b1153204e0d1e275dd", "action"=>"create", "controller"=>"posts"}
New post: {"updated_at"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs!!!",
 "published"=>false, "created_at"=>nil}
Post should be valid: true
  Post Create (0.000443)   INSERT INTO "posts" ("updated_at", "title", "body", "published",
 "created_at") VALUES('2008-09-08 14:52:54', 'Debugging Rails',
 'I''m learning how to print in logs!!!', 'f', '2008-09-08 14:52:54')
The post was saved and now the user is going to be redirected...
Redirected to #<Post:0x20af760>
Completed in 0.01224 (81 reqs/sec) | DB: 0.00044 (3%) | 302 Found [http://localhost/posts]
```

이와 같이 부가 로깅을 더하면 로그상의 의도하지 않았거나 비정상적인 행동을 검색하기 쉽게 해줍니다. 만약 부가 로깅을 추가하려면 프로덕션 로그가 불필요한 내용들로 채워지는 것을 피하기 위해 로그 레벨을 합리적으로 사용해야 합니다. [[[Adding extra logging like this makes it easy to search for unexpected or unusual behavior in your logs. If you add extra logging, be sure to make sensible use of log levels to avoid filling your production logs with useless trivia.]]]

### [Tagged Logging] 태그된 로깅

다중-사용자, 다중-계정 응용프로그램을 실행할 때는 몇 가지 사용자 정의 규칙을 사용하여 로그를 필터링할 수 있도록 하는 것이 종종 유용합니다. 액티브 서포트의 `TaggedLogging`은 그러한 응용프로그램을 디버깅하는 것을 지원하는 서브도메인, 요청 id, 그리고 그밖의 것들을 로그에 찍어주어 정확히 그와 같은 일을 할 수 있도록 도와줍니다. [[[When running multi-user, multi-account applications, it’s often useful to be able to filter the logs using some custom rules. `TaggedLogging` in ActiveSupport helps in doing exactly that by stamping log lines with subdomains, request ids, and anything else to aid debugging such applications.]]]

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

[Debugging with the `debugger` gem] `debugger`젬으로 디버깅하기
---------------------------------

코드가 의도하지 않은 방식으로 작동할 때, 문제를 분석하기 위해 로그나 콘솔에 출력을 시도할 수 있습니다. 불행하게도, 문제의 근본 원인을 찾기에 이런 종류의 오류 추적이 효과적이지 않을 때가 있습니다. 실행되고 있는 소스 코드 내부로 여행을 떠나야 할 필요가 있을 때, 디버거는 최고의 동반자입니다. [[[When your code is behaving in unexpected ways, you can try printing to logs or the console to diagnose the problem. Unfortunately, there are times when this sort of error tracking is not effective in finding the root cause of a problem. When you actually need to journey into your running source code, the debugger is your best companion.]]]

디버거는 또한 레일스 소스 코드에 대해 학습하고 싶지만 어디서부터 시작해야 할 지 모를 때 도움이 될 수도 있습니다. 그냥 응용프로그램에 대한 모든 요청을 디버그하고, 자신이 작성한 코드로부터 레일스 코드 깊은 곳으로 이동하는 것을 익히기 위해 본 가이드를 사용하십시오. [[[The debugger can also help you if you want to learn about the Rails source code but don't know where to start. Just debug any request to your application and use this guide to learn how to move from the code you have written deeper into Rails code.]]]

### [Setup] 설정

중단점을 설정하고 레일스의 실제 코드를 단계적으로 관통하기(step through) 위해 `debugger` 젬을 사용할 수 있습니다. 이것을 설치하려면, 다음을 실행하십시오: [[[You can use the `debugger` gem to set breakpoints and step through live code in Rails. To install it, just run:]]]

```bash
$ gem install debugger
```

레일스는 레일스 2.0 버전부터 디버깅을 지원하는 내장 지원을 가지고 있습니다. 모든 레일스 응용프로그램 내부에서 `debugger` 메서드를 호출하여 디버거를 호출할 수 있습니다. [[[Rails has had built-in support for debugging since Rails 2.0. Inside any Rails application you can invoke the debugger by calling the `debugger` method.]]]

여기 예제가 있습니다: [[[Here's an example:]]]

```ruby
class PeopleController < ApplicationController
  def new
    debugger
    @person = Person.new
  end
end
```

만약 콘솔이나 로그에 다음 메시지를 보게 된다면: [[[If you see this message in the console or logs:]]]

```
***** Debugger requested, but was not available: Start server with --debugger to enable *****
```

웹 서버를 `--debugger` 옵션으로 웹 서버를 실행했는지 확인하십시오. [[[Make sure you have started your web server with the option `--debugger`:]]]

```bash
$ rails server --debugger
=> Booting WEBrick
=> Rails 3.2.13 application starting on http://0.0.0.0:3000
=> Debugger enabled
...
```

TIP: 개발 모드에서는, `--debugger` 옵션 없이 실행했더라도, 서버를 재시작하지 않고도 동적으로 `require \'debugger\'` 할 수 있습니다. [[[In development mode, you can dynamically `require \'debugger\'` instead of restarting the server, even if it was started without `--debugger`.]]]

### The Shell

응용프로그램이 `debugger` 메서드를 호출할 때, 디버거는 응용프로그램 서버가 실행된 터미널 창 안의 디버거 셸에서 시작될 것이며 디버거 프롬프트 `(rdb:n)`에 위치할 것입니다. _n_ 은 쓰레드 번호입니다. 프롬프트는 또한 실행 대기중인 코드의 다름 라인을 보여줄 것입니다. [[[As soon as your application calls the `debugger` method, the debugger will be started in a debugger shell inside the terminal window where you launched your application server, and you will be placed at the debugger's prompt `(rdb:n)`. The _n_ is the thread number. The prompt will also show you the next line of code that is waiting to run.]]]

만약 브라우저의 요청에 의해 해당 지점에 이르렀다면, 요청이 포함된 브라우저 탭은 디버거가 종료되고 전체 요청을 처리하는 추적이 끝날 때까지 중지됩니다. [[[If you got there by a browser request, the browser tab containing the request will be hung until the debugger has finished and the trace has finished processing the entire request.]]]

예를 들어: [[[For example:]]]

```bash
@posts = Post.all
(rdb:7)
```

이제 응응프로그램 내부를 탐구하고 발굴할 때입니다. 좋은 시작점은 디버거에게 도움말을 구하는 것입니다. `help`를 입력합니다: [[[Now it's time to explore and dig into your application. A good place to start is by asking the debugger for help. Type: `help`]]]

```
(rdb:7) help
ruby-debug help v0.10.2
Type 'help <command-name>' for help on a specific command

Available commands:
backtrace  delete   enable  help    next  quit     show    trace
break      disable  eval    info    p     reload   source  undisplay
catch      display  exit    irb     pp    restart  step    up
condition  down     finish  list    ps    save     thread  var
continue   edit     frame   method  putl  set      tmate   where
```

TIP: 특정 명령에 대한 도움말 메뉴를 보려면 `help <command-name>`을 디버거 프롬프트에서 사용하십시오. 예를 들어: _`help var`_ [[[To view the help menu for any command use `help <command-name>` at the debugger prompt. For example: _`help var`_]]]

다음으로 학습할 명령은 가장 유용한 것 중 하나인 `list` 입니다. 다른 명령어와 구별하기에 충분한 문자를 제공하여 모든 디버깅 명령을 생략할 수 있습니다. 그러므로 `list` 명령을 위해 `l`을 사용할 수도 있습니다. [[[The next command to learn is one of the most useful: `list`. You can abbreviate any debugging command by supplying just enough letters to distinguish them from other commands, so you can also use `l` for the `list` command.]]]

이 명령은 코드상에서 현재 라인을 중심으로 10 라인을 출력하여 보여줍니다; 본 예제에 특정한 경우 현재 라인은 6번째 라인이며 `=>`로 표시됩니다. [[[This command shows you where you are in the code by printing 10 lines centered around the current line; the current line in this particular case is line 6 and is marked by `=>`.]]]

```
(rdb:7) list
[1, 10] in /PathTo/project/app/controllers/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
=> 6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

만약 `list` 명령을, 지금은 `l`만 사용하여, 반복한다면 파일의 다음 10개 라인이 출력될 것입니다. [[[If you repeat the `list` command, this time using just `l`, the next ten lines of the file will be printed out.]]]

```
(rdb:7) l
[11, 20] in /PathTo/project/app/controllers/posts_controller.rb
   11      end
   12    end
   13
   14    # GET /posts/1
   15    # GET /posts/1.json
   16    def show
   17      @post = Post.find(params[:id])
   18
   19      respond_to do |format|
   20        format.html # show.html.erb
```

그리고 현재 파일이 끝날 때까지 반복합니다. 파일의 끝에 다다르면, `list` 명령은 다시 파일의 처음으로부터 시작하여 끝까지 반복할 것입니다. 파일을 원형 버퍼로 취급하는 것입니다. [[[And so on until the end of the current file. When the end of file is reached, the `list` command will start again from the beginning of the file and continue again up to the end, treating the file as a circular buffer.]]]

반대로, 이전 열 개의 라임을 보려면 `list-` (혹은 `l-`)를 입력해야 합니다. [[[On the other hand, to see the previous ten lines you should type `list-` (or `l-`)]]]

```
(rdb:7) l-
[1, 10] in /PathTo/project/app/controllers/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
   6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

이 방법으로 파일 내부로 들어가, `debugger`를 추가한 다음 라인을 볼 수 있습니다. [[[This way you can move inside the file, being able to see the code above and over the line you added the `debugger`.]]]
마지막으로, 현재 실행중인 코드를 다시 보려면 `list=`를 입력할 수 있습니다. [[[Finally, to see where you are in the code again you can type `list=`]]]

```
(rdb:7) list=
[1, 10] in /PathTo/project/app/controllers/posts_controller.rb
   1  class PostsController < ApplicationController
   2    # GET /posts
   3    # GET /posts.json
   4    def index
   5      debugger
=> 6      @posts = Post.all
   7
   8      respond_to do |format|
   9        format.html # index.html.erb
   10        format.json { render :json => @posts }
```

### The Context

응용프로그램 디버깅을 시작할 때, 스택의 다른 부분을 거쳐감에 따라 다른 컨텍스트에 위치할 것입니다. [[[When you start debugging your application, you will be placed in different contexts as you go through the different parts of the stack.]]]

중단점이나 이벤트에 도달했을 때, 디버거는 컨텍스트를 만듭니다. 컨텍스트는 중단된 프로그램에 대한 정보로, 디버거가 프레임 스텍을 검사하고, 디버그된 프로그램의 관점에서 변수들을 평가할 수 있도록 해줍니다. 그리고 컨텍스트는 디버그된 프로그램이 중단된 지점에 대한 정보를 포함합니다. [[[The debugger creates a context when a stopping point or an event is reached. The context has information about the suspended program which enables a debugger to inspect the frame stack, evaluate variables from the perspective of the debugged program, and contains information about the place where the debugged program is stopped.]]]

언제든지 `backtrace` 명령(혹은 별칭인 `where`)을 호출하여 응용프로그램의 역추적 정보를 출력할 수 있습니다. 이것은 어떻게 현재 지점에 도달했는지 알아내기 위해 매우 유용할 수 있습니다. 만약 어떻게 코드 내의 어딘가에 도달했는지 궁금하다면, `backtrace`가 그 답을 줄 것입니다. [[[At any time you can call the `backtrace` command (or its alias `where`) to print the backtrace of the application. This can be very helpful to know how you got where you are. If you ever wondered about how you got somewhere in your code, then `backtrace` will supply the answer.]]]

```
(rdb:5) where
    #0 PostsController.index
       at line /PathTo/project/app/controllers/posts_controller.rb:6
    #1 Kernel.send
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
    #2 ActionController::Base.perform_action_without_filters
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
    #3 ActionController::Filters::InstanceMethods.call_filters(chain#ActionController::Fil...,...)
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/filters.rb:617
...
```

`frame _n_` 명령(_n_은 특정 프레임 번호)을 사용하여 이 추적 내에 원하는 어디로든 이동할 수 있습니다.(이것은 컨텍스트를 변경합니다) [[[You move anywhere you want in this trace (thus changing the context) by using the `frame _n_` command, where _n_ is the specified frame number.]]]

```
(rdb:5) frame 2
#2 ActionController::Base.perform_action_without_filters
       at line /PathTo/project/vendor/rails/actionpack/lib/action_controller/base.rb:1175
```

사용가능한 변수들은 코드를 라인 바이 라인으로 실행하는 것과 동일합니다. 결국, 이것이 디버깅입니다. [[[The available variables are the same as if you were running the code line by line. After all, that's what debugging is.]]]

스택 프레임을 위 아래로 이동: 컨텍스트 _n_ 프레임을 스택 위 혹은 아래로 변경하기 위해 각각 `up [n]` (단축 `u`)과 `down [n]` 명령을 각각 사용할 수 있습니다. 이 경우 up은 더 높은 번호의 스택 프레임으로, down 은 낮은 번호의 스택 프레임으로 이동합니다. [[[Moving up and down the stack frame: You can use `up [n]` (`u` for abbreviated) and `down [n]` commands in order to change the context _n_ frames up or down the stack respectively. _n_ defaults to one. Up in this case is towards higher-numbered stack frames, and down is towards lower-numbered stack frames.]]]

### Threads

디버거는 `thread` (혹은 단축 `th`) 명령을 사용하여 실행중인 쓰레드의 목록 보기, 정지, 재시작과 쓰레드간 이동을 할 수 있습니다. 본 명령에는 몇 가지 옵션이 있습니다. [[[The debugger can list, stop, resume and switch between running threads by using the command `thread` (or the abbreviated `th`). This command has a handful of options:]]]

* `thread`는 현재 쓰레드를 보여줍니다. [[[`thread` shows the current thread.]]]

* `thread list`는 모든 쓰레드들과 그들의 상태 목록을 보기 위해 사용됩니다. + 문자와 숫자는 현재 실행중인 쓰레드를 나타냅니다. [[[`thread list` is used to list all threads and their statuses. The plus + character and the number indicates the current thread of execution.]]]

* `thread stop _n_`는 _n_ 번 쓰레드를 정지시킵니다. [[[`thread stop _n_` stop thread _n_.]]]

* `thread resume _n_`는 _n_ 번 쓰레드를 재시작합니다. [[[`thread resume _n_` resumes thread _n_.]]]

* `thread switch _n_`는 현재 쓰레트 컨텍스트를 _n_ 번 쓰레드로 바꿉니다. [[[`thread switch _n_` switches the current thread context to _n_.]]]

본 명령은 다른 경우들 중에서 동시 쓰레드를 디버깅할 때 유용하며 코드상에 경쟁 조건이 있는지 확인할 필요가 있습니다. [[[This command is very helpful, among other occasions, when you are debugging concurrent threads and need to verify that there are no race conditions in your code.]]]

### [Inspecting Variables] 변수 검사하기

어떤 표현식이라도 현재 컨텍스트에서 평가될 수 있습니다. 표현식을 평가하려면, 그저 입력만 하십시오! [[[Any expression can be evaluated in the current context. To evaluate an expression, just type it!]]]

아래 예제는 현재 컨텍스트에서 정의된 인스턴스 변수들(instance_variables)를 출력하는 법을 보여줍니다. [[[This example shows how you can print the instance_variables defined within the current context:]]]

```
@posts = Post.all
(rdb:11) instance_variables
["@_response", "@action_name", "@url", "@_session", "@_cookies", "@performed_render", "@_flash", "@template", "@_params", "@before_filter_chain_aborted", "@request_origin", "@_headers", "@performed_redirect", "@_request"]
```

알아채신 바와 같이, 컨트롤러에서 접근할 수 있는 모든 변수가 표시됩니다. 이 목록은 코드가 실행될 때 동적으로 업데이트됩니다. 예를 들어, `next`(이 명령에 대해서는 본 가이드의 뒷 부분에서 배울 것입니다)를 사용하여 다음 라인을 실행합니다.[[[As you may have figured out, all of the variables that you can access from a controller are displayed. This list is dynamically updated as you execute code. For example, run the next line using `next` (you'll learn more about this command later in this guide).]]]

```
(rdb:11) next
Processing PostsController#index (for 127.0.0.1 at 2008-09-04 19:51:34) [GET]
  Session ID: BAh7BiIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA==--b16e91b992453a8cc201694d660147bba8b0fd0e
  Parameters: {"action"=>"index", "controller"=>"posts"}
/PathToProject/posts_controller.rb:8
respond_to do |format|
```

그다음 instance_variables를 다시 요청합니다. [[[And then ask again for the instance_variables:]]]

```
(rdb:11) instance_variables.include? "@posts"
true
```

이제 `@posts`가 안스턴스 변수들에 포함됩니다. 정의된 라인이 실행되었기 때문입니다. [[[Now `@posts` is included in the instance variables, because the line defining it was executed.]]]

TIP: `irb` 명령으로 **irb** 모드로 진입할 수도 있습니다. 이 방법으로 irb 세션은 연결된 컨텍스트와 함께 시작될 것입니다. 그러나 경고를 보게 됩니다: 이 기능은 시험용 기능(experimental feature)입니다[[[You can also step into **irb** mode with the command `irb` (of course!). This way an irb session will be started within the context you invoked it. But be warned: this is an experimental feature.]]]

`var` 메서드는 변수들과 그 값들을 보여주기에 가장 편리한 방법입니다. [[[The `var` method is the most convenient way to show variables and their values:]]]

```
var
(rdb:1) v[ar] const <object>            show constants of object
(rdb:1) v[ar] g[lobal]                  show global variables
(rdb:1) v[ar] i[nstance] <object>       show instance variables of object
(rdb:1) v[ar] l[ocal]                   show local variables
```

이것은 현재 컨텍스트 변수들의 값을 검사하는 훌륭한 방법입니다. 예를 들면: [[[This is a great way to inspect the values of the current context variables. For example:]]]

```
(rdb:9) var local
  __dbg_verbose_save => false
```

또한 이 방법으로 객체 메서드를 검사할 수도 있습니다. [[[You can also inspect for an object method this way:]]]

```
(rdb:9) var instance Post.new
@attributes = {"updated_at"=>nil, "body"=>nil, "title"=>nil, "published"=>nil, "created_at"...
@attributes_cache = {}
@new_record = true
```

TIP: `p` (print)와 `pp` (pretty print) 명령은 콘솔에 루비 표현식을 평가하고 변수들의 값을 표시하는데 사용될 수 있습니다. [[[The commands `p` (print) and `pp` (pretty print) can be used to evaluate Ruby expressions and display the value of variables to the console.]]]

또한 `display`를 사용하여 변수들을 주시하기 시작할 수 있습니다. 이것은 실행이 진행되는 동안 변수의 값을 추적하는 좋은 방법입니다. [[[You can use also `display` to start watching variables. This is a good way of tracking the values of a variable while the execution goes on.]]]

```
(rdb:1) display @recent_comments
1: @recent_comments =
```

표시 목록 안의 변수들은 스택 내부로 이동한 후 그 값들과 함께 출력될 것입니다. 변수 표시를 중단하려면 `undisplay _n_`를 사용하십시오. _n_ 은 변수 번호(마지막 예제에 있는 1)입니다.[[[The variables inside the displaying list will be printed with their values after you move in the stack. To stop displaying a variable use `undisplay _n_` where _n_ is the variable number (1 in the last example).]]]

### Step by Step

이제 실행 추적의 어디에 있는지 알아내고 사용 가능한 변수를 출력할 수 있어야 합니다. 하지만 응용프로그램 실행에 대해 계속 진행해 보겠습니다. [[[Now you should know where you are in the running trace and be able to print the available variables. But lets continue and move on with the application execution.]]]

`step`(단축 `s`)를 사용하면 다음 논리적 중단 지점까지 프로그램 실행을 계속하여 디버거에 제어를 넘겨줍니다. [[[Use `step` (abbreviated `s`) to continue running your program until the next logical stopping point and return control to the debugger.]]]

TIP: 각각 `step+ n`과 `step- n`을 사용하여 `n` 단계 앞과 뒤로 이동할 수도 있습니다. [[[ You can also use `step+ n` and `step- n` to move forward or backward `n` steps respectively.]]]

step과 비슷하게 `next`를 사용할 수도 있습니다. 그러나 코드 라인 내에 표시되는 함수 혹은 메서드 호출은 중단 없이 실행됩니다. step 명령으로는, _n_ 단계를 이동하기 위해 플러스 기호(+)를 사용할 수 있습니다. [[[You may also use `next` which is similar to step, but function or method calls that appear within the line of code are executed without stopping. As with step, you may use plus sign to move _n_ steps.]]]

`next`와 `step`의 차이는 `step`은 실행된 코드의 다음 라인에 정지하여 한 단계만을 실행하는 반면, `next`는 메서드 내부로 내려가지 않은 채 다음 라인으로 이동한다는 것입니다. [[[The difference between `next` and `step` is that `step` stops at the next line of code executed, doing just a single step, while `next` moves to the next line without descending inside methods.]]]

예를 들어, `debugger` 문이 포함된 다음과 같인 코드 블록을 생각해 봅시다: [[[For example, consider this block of code with an included `debugger` statement:]]]

```ruby
class Author < ActiveRecord::Base
  has_one :editorial
  has_many :comments

  def find_recent_comments(limit = 10)
    debugger
    @recent_comments ||= comments.where("created_at > ?", 1.week.ago).limit(limit)
  end
end
```

TIP: `rails console`을 사용할 때 디버거를 사용할 수도 있습니다. `debugger` 메서드가 호출되기 전에 `require "debugger"`를 실행해야 한다는 것만 기억하십시오. [[[TIP: You can use the debugger while using `rails console`. Just remember to `require "debugger"` before calling the `debugger` method.]]]

```
$ rails console
Loading development environment (Rails 3.2.13)
>> require "debugger"
=> []
>> author = Author.first
=> #<Author id: 1, first_name: "Bob", last_name: "Smith", created_at: "2008-07-31 12:46:10", updated_at: "2008-07-31 12:46:10">
>> author.find_recent_comments
/PathTo/project/app/models/author.rb:11
)
```

코드가 중단되면, 출력을 둘러봅니다. [[[With the code stopped, take a look around:]]]

```
(rdb:1) list
[2, 9] in /PathTo/project/app/models/author.rb
   2    has_one :editorial
   3    has_many :comments
   4
   5    def find_recent_comments(limit = 10)
   6      debugger
=> 7      @recent_comments ||= comments.where("created_at > ?", 1.week.ago).limit(limit)
   8    end
   9  end
```

라인의 끝에 위치해 있습니다만... 이 라인은 실행되었을까요? 인스턴스 변수를 검사할 수 있습니다. [[[You are at the end of the line, but... was this line executed? You can inspect the instance variables.]]]

```
(rdb:1) var instance
@attributes = {"updated_at"=>"2008-07-31 12:46:10", "id"=>"1", "first_name"=>"Bob", "las...
@attributes_cache = {}
```

`@recent_comments`가 아직 정의되지 않았습니다. 따라서 아직 이 라인이 실행되지 않은 것이 분명합니다. `next` 명령어를 사용하여 이 코드에서 이동합니다. [[[`@recent_comments` hasn't been defined yet, so it's clear that this line hasn't been executed yet. Use the `next` command to move on in the code:]]]

```
(rdb:1) next
/PathTo/project/app/models/author.rb:12
@recent_comments
(rdb:1) var instance
@attributes = {"updated_at"=>"2008-07-31 12:46:10", "id"=>"1", "first_name"=>"Bob", "las...
@attributes_cache = {}
@comments = []
@recent_comments = []
```

이제 이 라인이 실행되었기 때문에 `@comments`의 관계가 로드되고 @recent_comments가 정의된 것을 볼 수 있습니다. [[[Now you can see that the `@comments` relationship was loaded and @recent_comments defined because the line was executed.]]]

만약 스택 추적 안으로 더 깊이 들어가고 싶다면 호출 메서드를 통하거나 레일스 코드 내부로 단일 단계(`steps`)로 이동할 수 있습니다. 이것은 자신의 코드나 어쩌면 루비 온 레일스에 있을지 모르는 버그를 찾아내는 가장 좋은 방법입니다. [[[If you want to go deeper into the stack trace you can move single `steps`, through your calling methods and into Rails code. This is one of the best ways to find bugs in your code, or perhaps in Ruby or Rails.]]]

### [Breakpoints] 중단점

중단점은 프로그램의 특정 지점에 도달했을 때마다 응용프로그램을 중단시켜줍니다. 디버거 쉘은 그 라인에서 호출됩니다. [[[A breakpoint makes your application stop whenever a certain point in the program is reached. The debugger shell is invoked in that line.]]]

`break` (혹은 `b`) 명령으로 동적으로 중단점을 넣을 수 있습니다. 중단점을 수동으로 넣는 세 가지 방법이 있습니다:[[[You can add breakpoints dynamically with the command `break` (or just `b`). There are 3 possible ways of adding breakpoints manually:]]]

* `break line`: 현재 소스파일의 _line_ 에 중단점을 설정합니다. [[[`break line`: set breakpoint in the _line_ in the current source file.]]]

* `break file:line [if expression]`: 중단점을 _file_ 내부의 _line_ 에 설정합니다. _expression_ 이 주어진 경우, 표현식이 _true_ 로 평가되어야 디버거가 실행됩니다. [[[`break file:line [if expression]`: set breakpoint in the _line_ number inside the _file_. If an _expression_ is given it must evaluated to _true_ to fire up the debugger.]]]

* `break class(.|\#)method [if expression]`: 중단점을 _class_ 내에 정의된 _method_ 내에 설정합니다.(. 과 \#는 각각 클래스와 인스턴스 메서드를 위한 것입니다) _expression_ 은 file:line에서와 같은 방식으로 작동합니다. [[[`break class(.|\#)method [if expression]`: set breakpoint in _method_ (. and \# for class and instance method respectively) defined in _class_. The _expression_ works the same way as with file:line.]]]

```
(rdb:5) break 10
Breakpoint 1 file /PathTo/project/vendor/rails/actionpack/lib/action_controller/filters.rb, line 10
```

중단점 목록을 보려면 `info breakpoints _n_` 혹은 `info break _n_`을 사용하십시오. 아니면 모든 중단점을 나열합니다. [[[Use `info breakpoints _n_` or `info break _n_` to list breakpoints. If you supply a number, it lists that breakpoint. Otherwise it lists all breakpoints.]]]

```
(rdb:5) info breakpoints
Num Enb What
  1 y   at filters.rb:10
```

중단점을 삭제하려면: _n_ 번 중단점을 삭제하려면 `delete _n_` 명령을 사용하십시오. 만약 숫자가 지정되어 있지 않다면, 현재 활성화된 모든 중단점을 삭제합니다. [[[To delete breakpoints: use the command `delete _n_` to remove the breakpoint number _n_. If no number is specified, it deletes all breakpoints that are currently active..]]]

```
(rdb:5) delete 1
(rdb:5) info breakpoints
No breakpoints.
```

중단점을 활성 혹은 비활성 할 수도 있습니다. [[[You can also enable or disable breakpoints:]]]

* `enable breakpoints`: 프로그램을 중단하기 위해 단일 _breakpoints_ 리스트 혹은 리스트가 지정되지 않은 경우에는 전체를 허용합니다. 이것은 중단점을 생성했을 때의 기본 상태입니다. [[[`enable breakpoints`: allow a list _breakpoints_ or all of them if no list is specified, to stop your program. This is the default state when you create a breakpoint.]]]

* `disable breakpoints`: 프로그램상의 _breakpoints_ 는 무효화될 것입니다. [[[`disable breakpoints`: the _breakpoints_ will have no effect on your program.]]]

### Catching Exceptions

`catch exception-name` 명령(혹은 `cat exception-name`)는 해당 예외를 위한 핸들러가 없을 때 _exception-name_ 형식의 예외를 가로채기 위해 사용될 수 있습니다. [[[The command `catch exception-name` (or just `cat exception-name`) can be used to intercept an exception of type _exception-name_ when there would otherwise be is no handler for it.]]]

모든 활성화된 캐치포인트의 목록을 보려면 `catch`를 사용하십시오. [[[To list all active catchpoints use `catch`.]]]

### [Resuming Execution] 실행 재개하기

디버거에서 중단된 응용프로그램의 실행을 재개하기 위한 두 가지 방법이 있습니다: [[[There are two ways to resume execution of an application that is stopped in the debugger:]]]

* `continue` [line-specification] \(혹은 `c`): 스크립트가 최종 중단된 주소에서부터 프로그램 실행을 재개합니다; 해당 주소에 설정된 중단점들은 무시됩니다. 선택적 인수 line-specification은 해당 중단점에 도달했을 때 삭제되는 일회성 중단점을 설정할 라인을 지정할 수 있게 해 줍니다. [[[`continue` [line-specification] \(or `c`): resume program execution, at the address where your script last stopped; any breakpoints set at that address are bypassed. The optional argument line-specification allows you to specify a line number to set a one-time breakpoint which is deleted when that breakpoint is reached.]]]

* `finish` [frame-number] \(혹은 `fin`): 선택된 스택 프레임을 반환할 때까지 실행합니다. 만약 프레임 번호가 주어지지 않았다면, 응용프로그램은 현재 선택된 프레임을 반환할 때까지 실행될 것입니다. 현재 선택된 프레임은 가장 최근의 프레임 혹은 프레임 위지치정(예 up, down 아니면 frame)이 수행되지 않았다면 0번으로 시작합니다. 만약 프레임 번호가 지정되었다면 응용프로그램은 지정된 프레임을 반환할 때까지 실행됩니다. [[[`finish` [frame-number] \(or `fin`): execute until the selected stack frame returns. If no frame number is given, the application will run until the currently selected frame returns. The currently selected frame starts out the most-recent frame or 0 if no frame positioning (e.g up, down or frame) has been performed. If a frame number is given it will run until the specified frame returns.]]]

### Editing

아래 두 명령은 디버거로부터 에디터로 코드를 열 수 있도록 해 줍니다: [[[Two commands allow you to open code from the debugger into an editor:]]]

* `edit [file:line]`: EDITOR 환경 변수에 의해 지정된 에디터를 사용하여 _file_ 을 수정합니다. 특정 _line_ 도 부여할 수 있습니다. [[[`edit [file:line]`: edit _file_ using the editor specified by the EDITOR environment variable. A specific _line_ can also be given.]]]

* `tmate _n_` (단축 `tm`): 현재 파일을 텍스트메이트에서 엽니다. _n_ 이 지정되어 있다면, n번째 프레임을 사용합니다. [[[`tmate _n_` (abbreviated `tm`): open the current file in TextMate. It uses n-th frame if _n_ is specified.]]]

### Quitting

디버거를 종료하려면, `quit` 명령 (단축 `q`) 혹은 별칭 `exit` 명령을 사용하십시오. [[[To exit the debugger, use the `quit` command (abbreviated `q`), or its alias `exit`.]]]

단순 quit은 모든 유효한 쓰레드 종료를 시도합니다. 그러므로 서버는 중단될 것이며 서버를 다시 시작해야 할 것입니다. [[[A simple quit tries to terminate all threads in effect. Therefore your server will be stopped and you will have to start it again.]]]

### Settings

`debugger` 젬은 자동으로 현재 단계적으로 진행하고 있는 코드를 보여주고, 에디터에서 수정될 때 코드를 리로드할 수 있습니다. 여기 몇 개의 사용가능한 옵션이 있습니다: [[[The `debugger` gem can automatically show the code you're stepping through and reload it when you change it in an editor. Here are a few of the available options:]]]

* `set reload`: 변경되었을 때 코드를 리로드합니다. [[[`set reload`: Reload source code when changed.]]]

* `set autolist`: 모든 중단점에서 `list` 명령을 수행합니다. [[[`set autolist`: Execute `list` command on every breakpoint.]]]

* `set listsize _n_`: 목록에 모여줄 소스 라인 수를 기본값에서 _n_ 으로 설정합니다. [[[`set listsize _n_`: Set number of source lines to list by default to _n_.]]]

* `set forcestep`: `next`와 `step` 명령이 항상 새 라인으로 이동하도록 강제합니다. [[[`set forcestep`: Make sure the `next` and `step` commands always move to a new line]]]

`help set`을 사용하여 전체 리스트를 볼 수 있습니다. `help set _subcommand_`를 사용하여 특정 `set` 명령어에 대해 학습하십시오. [[[You can see the full list by using `help set`. Use `help set _subcommand_` to learn about a particular `set` command.]]]

TIP: 이들 설정을 홈 디렉터리 내의 `.rdebugrc` 파일 안에 저장할 수 있습니다. 디버거는 시작될 때 이들을 전역 설정으로 읽어들입니다. [[[TIP: You can save these settings in an `.rdebugrc` file in your home directory. The debugger reads these global settings when it starts.]]]

아래 `.rdebugrc`를 위한 좋은 시작 출발점이 있습니다: [[[Here's a good start for an `.rdebugrc`:]]]

```bash
set autolist
set forcestep
set listsize 25
```

[Debugging Memory Leaks] 메모리 누수 디버깅하기
----------------------

루비 응용프로그램(레일스던 아니던)은 -루비 코드 안에서든 C 코드 레벨에서든-메모리가 누수될 수 있습니다. [[[A Ruby application (on Rails or not), can leak memory - either in the Ruby code or at the C code level.]]]

본 섹션에서는, Valgrind와 같은 도구를 사용하여 그러한 누수를 찾아내고 고치는 방법을 학습합니다. [[[In this section, you will learn how to find and fix such leaks by using tool such as Valgrind.]]]

### Valgrind

[Valgrind](http://valgrind.org/)는 C-기반 메모리 누수와 경쟁 조건을 탐지하기 위한 리눅스 전용 응용프로그램입니다. [[[[Valgrind](http://valgrind.org/) is a Linux-only application for detecting C-based memory leaks and race conditions.]]]

자동으로 대량 메모리 관리와 쓰레딩 버그를 탐지하고 프로그램을 세밀히 프로파일링 할 수 있는 Valgrind 도구들이 있습니다. 예를 들어 인터프리터에서 C 확장이 `malloc()`를 호출하였으나 적절하게 `free()`를 호출하지 않았다면, 이 메모리는 응용프로그램이 종료될 때까지 사용할 수 없게 될 것입니다. [[[There are Valgrind tools that can automatically detect many memory management and threading bugs, and profile your programs in detail. For example, a C extension in the interpreter calls `malloc()` but is doesn't properly call `free()`, this memory won't be available until the app terminates.]]]

Valgrind를 설치하고 루비와 함께 사용하는 법에 대한 더 많은 정보는, Evan Weaver가 쓴 [Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/)를 참조하십시오. [[[For further information on how to install Valgrind and use with Ruby, refer to [Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/) by Evan Weaver.]]]

[Plugins for Debugging] 디버깅을 위한 플러그인들
---------------------

응용프로그램의 에러를 찾고 디버깅하는 것을 돕는 몇 가지 레일스 플러그인들이 있습니다. 아래 디버깅을 위한 유용한 플러그인 목록이 있습니다: [[[There are some Rails plugins to help you to find errors and debug your application. Here is a list of useful plugins for debugging:]]]

* [Footnotes](https://github.com/josevalim/rails-footnotes) 모든 레일스 페이지는 요청 정보와 TextMate를 통해 소스로 돌아가는 링크를 주는 각주를 갖게 됩니다. [[[[Footnotes](https://github.com/josevalim/rails-footnotes) Every Rails page has footnotes that give request information and link back to your source via TextMate.]]]

* [Query Trace](https://github.com/ntalbott/query_trace/tree/master) 로그에 쿼리의 기원 추적을 추가합니다. [[[[Query Trace](https://github.com/ntalbott/query_trace/tree/master) Adds query origin tracing to your logs.]]]

* [Query Reviewer](https://github.com/nesquena/query_reviewer)는 개발시에 각 select 쿼리 이전에 "EXPLAIN"을 실행하며, 분석된 각 쿼리에 대한 경고 요약을 각 페이지 출력에 렌더링하여 작은 DIV로 제공합니다. [[[[Query Reviewer](https://github.com/nesquena/query_reviewer) This rails plugin not only runs "EXPLAIN" before each of your select queries in development, but provides a small DIV in the rendered output of each page with the summary of warnings for each query that it analyzed.]]]

* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) 레일스 응용프로그램에 에러가 발생했을 때 이메일 알림을 전송하기 위한 메일러 객체와 기본 템플릿을 제공합니다. [[[[Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) Provides a mailer object and a default set of templates for sending email notifications when errors occur in a Rails application.]]]

References
----------

* [ruby-debug Homepage](http://bashdb.sourceforge.net/ruby-debug/home-page.html)
* [debugger Homepage](https://github.com/cldwalker/debugger)
* [Article: Debugging a Rails application with ruby-debug](http://www.sitepoint.com/debug-rails-app-ruby-debug/)
* [Ryan Bates' debugging ruby (revised) screencast](http://railscasts.com/episodes/54-debugging-ruby-revised)
* [Ryan Bates' stack trace screencast](http://railscasts.com/episodes/24-the-stack-trace)
* [Ryan Bates' logger screencast](http://railscasts.com/episodes/56-the-logger)
* [Debugging with ruby-debug](http://bashdb.sourceforge.net/ruby-debug.html)
