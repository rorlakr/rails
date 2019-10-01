**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

레일스로 시작하기
==========================

본 가이드 내용에서는 루비온레일스(이하 레일스)를 준비하고 실행하는 것에 대해서 다룬다.

본 가이드를 읽은 후에는 다음의 내용을 알게 된다.

* 레일스를 설치하는 방법, 레일스 애플리케이션을 생성하는 방법, 애플리케이션을 데이터베이스로 연결하는 방법
* 레일스 애플리케이션의 일반적인 레이아웃
* MVC(Model, View, Controller)와 RESTful 디자인에 대한 기본 원리
* 레일스 애플리케이션의 시작부분을 신속하게 생성하는 방법

--------------------------------------------------------------------------------

가이드에 대한 전제조건
-----------------

본 가이드 내용은 레일스 애플리케이션을 만들어 본 경험이 없는 초보자를 대상으로 작성되었다. 반드시 레일스에 대한 경험을 필요로 하지 않는다.

레일스는 루비 언어로 만들어진 웹애플리케이션 프레임워크이다. 
루비 언어에 대한 사전 지식이 없이 바로 레일스로 작업을 하게 되면 매우 경사진 학습곡선을 경험하게 될 것이다. 아래에 루비 언어를 배우기 위한 온라인 자원에 대한 몇가지 목록을 모아 놓았다.

* [루비언어 공식 웹사이트](https://www.ruby-lang.org/en/documentation/)
* [무료 프로그래밍 서적 목록](https://github.com/EbookFoundation/free-programming-books/blob/master/free-programming-books.md#ruby)

주의할 것은 위에서 소개한 서적 중에는, 그 내용이 아주 훌륭한 것이지만, 오래된 버전인 루비 1.6과 주로 1.8 버전에 대한 것들이 있어서 레일스로 개발할 때 주로 접하게 되는 루비 문법들이 포함되지 않을 수 있다는 것이다.

레일스란 무엇인가?
--------------

레일스란 루비 언어로 작성된 웹애플리케이션 개발 프레임워크이다.
모든 개발자들이 작업을 시작할 때 필요로 하는 것들이 사전에 준비된 것으로 가정하여 웹애플리케이션을 보다 쉽게 개발할 수 있도록 만들어졌다.
다수의 언어와 프레임워크보다 더 작은 량의 코드를 작성하여 더 많은 것을 구현할 수 있게 해준다.
고급 레일스 개발자들 역시 레일스가 웹애플리케이션 개발을 더 재밋게 해 준다고 말한다.

레일스는 독단적인 측면을 가지는 소프트웨어다. 즉 최선의 방식이 있다고 가정하여 그 방법을 사용하도록 권하지만 경우에 따라서는 다른 대안을 사용하지 않도록 한다. 소위 "레일스 방식"을 배우게 되면 생산성에 있어서 어마어마한 향상을 가져오게 되는 것을 알게 될 것이다. 다른 언어를 사용할 때 익혔던 습관을 레일스 개발시에 버리지 못하거나 다른 곳에서 배웠던 패턴을 그대로 사용하려고 할 경우는 레일스를 사용하므로써 얻게 되는 즐거움을 더 느끼게 될 것이다.

레일스 철학은 두 개의 중요한 가이드 원칙을 포함한다.

* **Don't Repeat Yourself:** DRY란 하나의 소프트웨어 개발 원칙으로 "모든 지식은 하나의 시스템 내에서 유일해야 하고 모호성이 없어야 하며 권위를 가져야 한다"는 내용을 의미한다. 같은 내용의 정보를 반복해서 작성하지 않으므로써 코드를 더 잘 유지할 수 있고 더 많은 확장성을 부여할 수 있으며 버그를 줄일 수 있게 되는 것이다.
* **Convention Over Configuration:** 레일스는 웹애플리케이션에서 발생할 수 있는 다양한 작업들에 대한 최선의 방법을 알고 있기 때문에, 한없이 이어지는 설정파일들을 사용해서 상세한 설정 내용을 명시하는 대신에 이런 것들에 대한 일련의 사전 정의된 설정을 기본 규칙으로 지정해 준다.

레일스 프로젝트 생성하기
----------------------------
본 가이드를 읽어가는 최선의 방식은 단계별로 따라서 해 보는 것이다. 모든 단계는 예제 애플리케이션을 실행하는데 필수이며 어떠한 코드나 단계도 추가적으로 필요하지 않다.  

본 가이드를 따라하면 `blog`라는 간단한 웹브로그 프로젝트를 만들게 될 것이다. 프로젝트를 진행하기 전에 각자의 시스템에 레일스가 설치되어 있어야 한다.

TIP: 아래의 예제에서 사용하는 `$` 문자는 유닉스계열의 운영체제에서 터미널 프롬프트로 사용하는 것인데 설정에 따라 다르게 보일 수 있다. 윈도우를 사용할 경우에는 `C:\sourc_code`와 같이 보일 것이다.

### 레일스 설치하기

레일스를 설치하기 전에 각자의 시스템에 레일스 프레이워크에서 사용하는 연관 언어나 프로그램이 설치되어 있는지 확인해야 하는데, 여기에는 루비와 SQLite3 등이 포함된다.

우선 터미널 프로그램을 실행한 후 커맨드라인 프롬프트를 연다. macOS에서는 Terminal.app 프로그램을 실행하고, 윈도에서는 시작 메뉴로부터 "실행(Run)" 명령을 선택한 후 'cmd.exe'라고 입력하여 엔터키를 입력한다. 달러 표시 `$` 문자 뒤에 오는 명령은 커맨드라인에서 실행해야 한다. 이어서 이설치된 루비 버전을 확인한다.

```bash
$ ruby -v
ruby 2.5.0
```

레일스는 루비 버전이 최소한 2.5.0 이상이어야 한다. 따라서, 이전 버전으로 확인될 경우는 최신버전으로 설치할 필요가 있다.

TIP: 윈도우 시스템에 레일스를 신속하게 설치하기 위해서는 [Rails Installer](http://railsinstaller.org)를 사용할 수 있다. 대부분의 운영체제에서 더 많은 설치 방법을 찾아 보길 원한다면 [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/)를 살펴보기 바란다.

윈도우에서 작업을 할 경우는, [Ruby Installer Development Kit](https://rubyinstaller.org/downloads/)를 추가로 설치해야 한다.

또한 SQLite3 데이터베이스를 설치할 필요가 있다.
많은 사람들이 사용하는 다수의 유닉스계열의 운영체제는 SQLite3 가용 버전이 미리 설치되어 있다. 
윈도우에서는 Rails Installer를 이용하여 설치한 경우, 이미 SQLite가 설치되어 있다. 기타 다른 경우에는 [SQLite3 웹사이트](https://www.sqlite.org)를 방문하여 설치 안내문을 참고할 수 있다.
제대로 설치되었을 경우 PATH에 경로가 추가되었는지 확인해 보기 바란다.

```bash
$ sqlite3 --version
```

위의 명령을 실행할 경우 버전이 표시되어야 한다.

레일스를 설치하기 위해서는 RubyGems에서 제공하는 `gem install` 명령을 실행한다.

```bash
$ gem install rails
```

이상의 모든 것이 제대로 설치되었다는 것을 확인하기 위해서 아래의 명령을 실행할 수 있어야 한다.

```bash
$ rails --version
```

"Rails 6.0.0"과 같이 표시된다면 이제 시작할 준비가 된 것이다. 

### Blog 애플리케이션 생성하기

레일스에서 기본으로 제공해 주는 많은 생성자 스크립트를 이용하면 특정 작업에 필요한 모든 것을 자동으로 생성해 주기 때문에 개발을 보다 쉽게 할 수 있다. 이 중에 하나는 애플리케이션을 만들어 주는 생성자 스크립트인데 레일스 애플리케이션의 기본 골격구조를 제공해 주기 때문에 직접 코드를 작성할 필요가 없다.

이 생성자를 사용하기 위해서는 터미널을 열고 파일을 생성할 권한이 있는 적당한 디렉토리로 이동한 후 아래와 같이 입력한다.

```bash
$ rails new blog
```

이로써 `blog` 디렉토리에 Blog라는 레일스 애플리케이션이 생성되고 `bundle install` 명령으로 `Gemfile`에 명시된 젬들이 설치될 것이다.

NOTE: Windows Subsystem for Linux(WSL)를 사용할 경우에는 현재 파일 시스템 알림 기능상에 제약점이 발견되어 `rails new blog --skip-spring --skin-listen` 와 같이 옵션을 추가하여 명령을 실행하여 `spring`과 `listen` 젬의 기능을 중단해야 한다.

TIP: `rails new -h` 명령을 실행하면 레일스 애플리케이션 빌더가 사용할 수 있는 모든 커맨드라인 옵션들을 볼 수 있다.

blog 애플리케이션을 생성한 후에는 해당 폴더로 이동한다.

```bash
$ cd blog
```

`blog` 디렉토리에는 다수의 자동생성된 파일과 폴더가 존재하는데 레일스 애플리케이션의 구조를 반영한 것이다. 본 튜토리얼상의 대부분의 작업은 `app` 폴더에서 진행할 것이지만 레일스에서 디폴트로 생성한 파일과 폴더의 기능들에 대한 기본 설명을 아래에 기술해 놓았다.

| 파일/폴더 | 용도 |
| ----------- | ------- |
|app/|애플리케이션의 컨트롤러, 모델, 뷰, 헬퍼, 메일러, 채널, 작업 및 애셋을 포함한다. 본 가이드의 나머지 부분에서는 이 폴더에 중점을 둘 것이다.|
|bin/|앱을 시작하는 레일스 스크립트를 포함하며 애플리케이션 설정, 업데이트, 배포 또는 실행하는 데 사용하는 스크립트를 포함 할 수 있다.|
|config/|애플리케이션의 라우트, 데이터베이스 등을 구성한다. [Configuring Rails Applications](configuring.html)에 자세히 설명되어 있다.|
|config.ru|애플리케이션을 시작하는 데 사용되는 랙(Rack) 기반 서버의 랙 구성. 랙에 대한 자세한 내용은 [Rack 웹 사이트](https://rack.github.io/)를 참조한다.|
|db/|현재 데이터베이스 스키마와 데이터베이스 마이그레이션이 포함되어 있다.|
|Gemfile<br>Gemfile.lock|이 파일을 사용하면 레일스 애플리케이션에 필요한 젬(gem) 의존성을 지정할 수 있다. 이 파일은 Bundler 젬에서 사용한다. Bundler에 대한 자세한 내용은 [Bundler 웹 사이트](https://bundler.io)를 참조한다.|
|lib/|애플리케이션을 위한 확장 모듈.|
|log/|애플리케이션 로그 파일|
|package.json|이 파일을 사용하면 레일스 애플리케이션에 필요한 npm 종속성을 지정할 수 있다. 이 파일은 Yarn에서 사용한다. Yarn에 대한 자세한 내용은 [Yarn 웹 사이트](https://yarnpkg.com/lang/en/)를 참조한다.|
|public/|누구라도 접급할 수 있는 유일한 폴더이다. 정적 파일 및 컴파일 된 애셋을 포함한다.|
|Rakefile|이 파일은 커맨드 라인에서 실행할 수 있는 태스크(task)를 찾아서 로드한다. 태스크 정의는 레일스의 구성 요소 전체에 걸쳐 정의된다. `Rakefile`을 변경하는 대신 애플리케이션의 `lib/tasks` 디렉토리에 파일을 추가한 후 자신의 태스크를 추가해야 한다.|
|README.md|애플리케이션에 대한 간단한 사용 설명서이다. 이 파일을 편집하여 다른 사용자에게 애플리케이션의 기능, 설정 방법 등을 알려 주어야 한다.|
|storage/|디스크 서비스용 액티브 스토리지 파일. 이에 대해서는 [Active Storage Overview](active_storage_overview.html)에서 다룬다.|
|test/|유닛 테스트, 픽스쳐(fixtures, 테스트 데이터) 및 기타 테스트 장치. 이것들은 [Testing Rails Applications](testing.html)에서 다룬다.|
|tmp/|임시 파일 (캐시(cache)와 pid 파일).|
|vendor/|모든 벤더(타사) 코드를 위한 장소이다. 전형적인 레일스 애플리케이션에서는 벤더에서 제공하는 젬을 여기에 포함한다.|
|.gitignore|이 파일은 git에게 무시해야 할 파일 (또는 패턴)을 알려준다. 파일 무시에 대한 자세한 내용은 [GitHub - Ignoring files](https://help.github.com/articles/ignoring-files)를 참조한다.
|.ruby-version|이 파일에는 기본 루비 버전이 포함되어 있다.|

Hello, Rails!
-------------

먼저, 스크린 상에 어떤 문자들이 보이도록 해 보자. 이를 위해서 레일스 애플리케이션 서버를 실행시켜야 한다.

### 웹서버 시작하기

레일스 애플리케이션은 사실 이미 정상적으로 동작이 가능한 상태이다. 이를 확인하려면 각자의 개발 머신에서 웹서버를 시작할 필요가 있다. `blog` 디렉토리에서 아래의 명령을 실행하여 서버를 시작할 수 있다.

```bash
$ rails server
```

TIP: 윈도우를 사용할 경우에는 `bin` 폴더에 있는 스크립트를, 예: `ruby bin\rails server`, 루비 인터프리터로 직접 넘겨 주어야 한다.

TIP: 자바스크립트 애셋을 압축하기 위해서는 시스템에 자바스크립트 런타임이 설치되어 있어야 하는데, 만약 그렇지 못할 경우에는 `execjs` 에러가 발생할 것이다. 대부분의 경우 macOS와 윈도우에는 자바스크립트 런타임이 이미 설치되어 있다. `therubyrhino`는 JRuby 사용자들을 위한 권장되는 런타임이며 JRuby 하에 생성된 앱의 `Gemfile`에 기본으로 추가된다. [ExecJS](https://github.com/rails/execjs#readme)에서 모든 사용가능한 런타임을 찾아 볼 수 있다.

이로써 레일스에서 디폴트로 배포하는 웹서버인 Puma를 시동하게 될 것이다. 작업 중인 애플리케이션이 동작하는 것을 확인하기 위해서 브라우저를 연 후 <http://localhost:3000>로 이동했을 때 아래와 같은 레일스 디폴트 정보 페이지를 볼 수 있어야 한다.

![Welcome aboard screenshot](images/getting_started/rails_welcome.png)

TIP: 웹서버를 중단하기 위해서는 서버가 실행 중인 터미널 윈도우에서 Ctrl+C를 누른다. 서버가 중단된 것을 확인하기 위해서는 커맨드 프롬프트를 다시 볼 수 있어야 한다. macOS를 포함해서 대부분의 유닉스계열의 시스템에서는 커맨드 프롬프트가 달러 문자 `$`로 표시될 것이다. 개발 모드에서는 변경된 내용이 서버에 자동으로 반영되기 때문에 일반적으로 서버를 재시동할 필요가 없다.

"Welcome aboard" 페이지는 레일스 애플리케이션이 제대로 생성되었는지를 알 수 있는 일종의 _smoke test_ 의 의미를 가진다. 즉, 소프트웨어가 제대로 설정되어 페이지를 서비스할 수 있음을 확인하는 것이다.

### "Hello, Rails" 표시하기

"Hello" 문자를 표시하기 위해서는 최소한 하나의 _controller(컨트롤러)_ 와 하나의 _view(뷰)_ 를 생성해야 한다.

컨트롤러는 애플리케이션에 대한 특정 요청를 받는 역할을 한다.
_Routing(라우팅)_ 은 어떤 컨트롤러가 어떤 요청을 받을 것인가를 결정한다. 종종 하나의 컨트롤러가 하나 이상의 라우트로 연결되기도 하는데 이 때 특정 컨트롤러의 라우트들은 각기 다른 _actions(액션)_ 을 호출하여 서비스한다. 액션은 정보를 모아서 뷰에 제공하는 역할을 수행한다.

뷰는 이러한 정보를 사람이 읽을 수 있는 형태로 표시하는데 중요한 차이점은 정보를 수집하는 곳이 뷰가 아니고 _컨트롤러_ 라는 점이다. 뷰는 바로 이러한 정보를 단지 표시만해야 한다. 보통 뷰 템플릿은 eRuby(Embeded Ruby)로 작성하는데 사용자들에게 보내지기 전에 레일스 엔진이 요청 주기에 따라 처리하게 된다.

컨트롤러를 새로이 추가할 때는 "controlller" 생성자를 실행해야 하는데 이 때 "Welcome"이라는 컨트롤러와 "index"라는 액션을 아래와 같이 알려 주어야 한다.

```bash
$ rails generate controller Welcome index
```

이로써 다수의 파일과 하나의 라우트가 생성될 것이다.

```bash
create  app/controllers/welcome_controller.rb
 route  get 'welcome/index'
invoke  erb
create    app/views/welcome
create    app/views/welcome/index.html.erb
invoke  test_unit
create    test/controllers/welcome_controller_test.rb
invoke  helper
create    app/helpers/welcome_helper.rb
invoke    test_unit
invoke  assets
invoke    scss
create      app/assets/stylesheets/welcome.scss
```

이 중에서 가장 중요한 것은 `app/controllers/welcome_controller.rb`에 위치한 컨트롤러 파일과 `app/views/welcome/index.html.erb`에 위치한 뷰 파일이다.

텍스트 에디터 상에서 `app/views/welcome/index.html.erb` 파일을 열고 기존 코드를 모두 삭제한 후 아래의 코드로 대체한다.

```html
<h1>Hello, Rails!</h1>
```

### 애플리케이션 홈 페이지 설정하기

컨트롤러와 뷰를 작성했기 때문에 이제 레일스에게 "Hello, Rails!"라는 글을 보여줄 시점을 알려 주어야 한다. 여기서는 루트 URL <http://localhost:3000>로 이동할 때 보여 주고자 한다. 이 순간 바로 "Welcom aboard" 라는 글을 보게 될 것이다.

다음으로는 실제 홈 페이지의 위치를 지정해 주어야 한다.

에디터 상에서 `config/routes.rb` 파일을 열면 아래와 같은 내용이 보인다.

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

이것은 특별한 [DSL (domain-specific language)](https://en.wikipedia.org/wiki/Domain-specific_language)로 작성된 라우트 항목들을 포함하는 애플리케이션의 _routing file(라우팅 파일)_ 이며 이 파일을 통해서 레일스는 서버로 들어오는 요청을 어떤 컨트롤러와 액션으로 연결할지 알게 된다. 이 파일에 `root 'welcome#index'` 코드라인을 추가하면 아래와 같이 보이게 된다.

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  root 'welcome#index'
end
```

`root 'welcome#index'`는 레일스에게 애플리케이션 루트로 들어오는 요청을 welcome 컨트롤러의 index 액션으로 매핑하도록 알려 주며 `get 'welcome/index'`는 <http://localhost:3000/welcome/index>로 들어오는 요청을 welcome 컨트롤러의 index 액션으로 매핑하도록 알려 준다. 이것은 이전에 컨트롤러 생성자(`rails generate controller Welcome index`)를 실행했을 때 이미 만들어졌던 것이다.

컨트롤러를 만들기 위해서 중단한 경우에는 웹서버를 시작한 후 브라우저 상에서 <http://localhost:3000>로 이동한다. 이 때 `app/views/welcome/index.html.erb` 파일에 추가했던 "Hello, Rails!" 메시지를 보게 된다면 새로 추가한 라우트가 `WelcomeController`의 `index` 액션으로 제대로 이동하여 뷰를 정확하게 렌더링하고 있다는 것을 간접적으로 시사하는 것이다.

TIP: 라우팅에 대한 더 자세한 내용은 [Rails Routing from the Outside In](routing.html)를 참고하기 바란다.

작동하기
----------------------

컨트롤러, 액션, 뷰 작성법을 알게 되었으니 이제 좀 더 실질적인 것을 만들어 보도록 하자.

Blog 애플리케이션에서 새로운 _resource(리소스)_ 를 하나 추가할 것이다. 리소스란 기사(읽은거리), 사람, 동물 등과 같이 비슷한 객체들을 일컫는 말한다. 특정 리소스에 대한 항목을 생성하고, 읽고, 업데이트하고, 삭제할 수 있고 이러한 작업을 _CRUD_ 작업으로 말하기도 한다.

레일스에서 제공하는 `resources` 메소드는 표준 REST 리소스를 선언하는데 사용할 수 있다. 따라서 `config/routes.rb` 파일에 _article resource_ 를 추가할 필요가 있으며 그 파일 내용은 아래와 같다.

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  resources :articles

  root 'welcome#index'
end
```

`rails routes` 명령을 실행하면 모든 표준 RESTful 액션에 대한 라우트 정의를 볼 수 있을 것이다. prefix 열과 다른 열의 의미는 나중에 보게 될 것이지만 지금 당장은 레일스가 단수형 `article`을 추론한 후 각 라우트를 구분하기 위해 의미있게 사용하는 것을 주목한다.

```bash
$ rails routes
       Prefix Verb   URI Pattern                  Controller#Action
welcome_index GET    /welcome/index(.:format)     welcome#index
     articles GET    /articles(.:format)          articles#index
              POST   /articles(.:format)          articles#create
  new_article GET    /articles/new(.:format)      articles#new
 edit_article GET    /articles/:id/edit(.:format) articles#edit
      article GET    /articles/:id(.:format)      articles#show
              PATCH  /articles/:id(.:format)      articles#update
              PUT    /articles/:id(.:format)      articles#update
              DELETE /articles/:id(.:format)      articles#destroy
         root GET    /                            welcome#index
```

다음 섹션에서 새 기사를 생성한 후 결과를 볼 수 있도록 기능을 추가할 것이다. 이것은 CRUD에서 "C"와 "R"에 해당하는 것으로 create(생성하기)와 read(읽기)를 의미한다. 이러한 작업을 하는 폼 형태는 아래와 같이 보일 것이다.

![The new article form](images/getting_started/new_article.png)

현재 상태는 기본 형태로 보이지만 작동하는데 문제가 없다. 이후에 스타일을 좋게 만드는 작업을 보게 될 것이다.

### 기본틀 잡기

먼저, 새로운 기사를 작성할 장소가 필요하다. 이를 위한 적당한 위치는 `/articles/new`가 될 것이다. 이미 정의된 바 있는 라우트를 따라 외부로부터의 요청은 `/articles/new`로 이어질 것이다. <http://localhost:3000/articles/new>로 이동하면 라우팅 에러가 발생할 것이다. 

![Another routing error, uninitialized constant ArticlesController](images/getting_started/routing_error_no_controller.png)

이 에러는 해당 라우트의 요청을 처리하기 위해서는 하나의 컨트롤러가 정의되어 있어야 하기 때문에 발생한다.
이러한 문제를 해결하는 방법은 간단하다. `ArticlesController`라는 컨트롤러를 생성하는 것이다. 아래와 같은 명령을 실행하면 이러한 작업을 수행할 수 있다.

```bash
$ rails generate controller Articles
```

방금 생성된 `app/controllers/articles_controller.rb` 파일을 열면 빈 컨트롤러를 보게 될 것이다.

```ruby
class ArticlesController < ApplicationController
end
```

이 컨트롤러는 `ApplicationController`로부터 상속받는 단지 하나의 클래스에 불과하다.
이 클래스 내에 컨트롤러 액션으로 동작하는 메소드를 정의하게 된다. 이러한 액션들은 기사들에 대한 CRUD 작업을 수행하게 된다.

NOTE: 루비에는 `public`, `private`, `protected` 메소드가 있지만 `public` 메소드만이 컨트롤러 액션으로 작업을 수행하게 된다. 더 자세한 내용은 [Programming Ruby](http://www.ruby-doc.org/docs/ProgrammingRuby/)을 확인해 보기 바란다.

이제 <http://localhost:3000/articles/new>를 다시 보기하면 새로운 에러를 보게 될 것이다.

![Unknown action new for ArticlesController!](images/getting_started/unknown_action_new_for_articles.png)

이러한 에러는 방금 전에 생성한 `ArticlesController` 내에 `new` 액션이 정의되어 있지 않다는 것을 알려 준다. 이것은 컨트롤러의 생성과정에서 원하는 액션을 명시적으로 추가하지 않는 한 레일스가 컨트롤러를 비어 있는 상태로 생성하기 때문이다.

컨트롤러 내에 액션을 수작업으로 정의하기 위해서는 단지 해당 컨트롤러 내에 새로운 메소드를 정의하면 된다. `app/controllers/articles_controller.rb` 파일을 열고 `ArticlesController` 클래스 내에 `new` 메소드를 정의하면 아래와 같이 보이게 된다.

```ruby
class ArticlesController < ApplicationController
  def new
  end
end
```

이 상태에서 <http://localhost:3000/articles/new>를 새로 보기하면 또 다른 에러를 보게 될 것이다.

![Template is missing for articles/new]
(images/getting_started/template_is_missing_articles_new.png)

레일스는 이와 같은 단순한 액션이 자신의 정보를 표시하기 위해 이와 연과되는 뷰를 가지는 것으로 기대하기 때문에 이런 에러가 발생하는 것이다. 뷰가 없다면 레일스는 예외를 발생할 것이다.

다시 전체 에러 메시지를 살펴 보자.

>ArticlesController#new 액션은 다음의 요청 포맷으로 작성된 템플릿 파일이 누락되어 있다: text/html

>NOTE!
>별도로 이름을 명시하지 않는 한, 레일스는 컨트롤러 이름과 동일한 폴더 내에 액션 이름과 동일한 템플릿 파일을 만들어 줄 것으로 기대한다. 이 컨트롤러가 204(컨텐츠 없음) 응답 상태를 보내는 API일 경우에는 이러한 템플릿 파일이 필요없지만, 브라우저 상에서 이 컨트롤러에 접근할 때는 HTML 템플릿이 요구되기 때문에 이런 에러 메시지를 보이게 된다. 그런 경우라면 계속해서 작업을 진행하면 된다.

이 메시지는 어떤 템플릿 파일이 누락되었는지 알려 준다. 이 경우는 `articles/new` 템플릿 파일이 해당된다. 레일스는 먼저 이 템플릿 파일을 찾게 되고 해당 위치에 없을 경우, `ArticlesController`가 `AppllicationController`로부터 상속을 받기 때문에 `application/new` 템플릿 파일을 로드하려고 시도할 것이다.

다음으로 메시지 내용 중에는 `request.formats`가 포함되어 있는데, 이것은 응답으로 내보낼 템플릿 파일의 포맷을 명시하는 것이다. 브라우저를 통해서 이 페이지를 요청했기 때문에 `text/html`로 설정되어 있다. 따라서 레일스는 HTML 포맷의 템플릿 파일을 찾게 된다.

이 경우에 동작하게 될 가장 단순한 템플릿 파일은 `app/views/articles/new.html.erb`에 위치하게 될 것이다. 이 파일명의 확장자명이 중요한데, 첫번째 확장자(.html)는 템플릿의 _포맷_ 이고 두번째 확장자는 템플릿을 최종적으로 작성할 때 사용하는 _핸들러_ 를 의미한다. 레일스는 애플리케이션의 `app/views` 폴더 내 `articles/new` 템플릿 파일을 찾게 된다. 이 템플릿의 포맷은 `html`이고 HTML 포맷에 대한 기본 핸들러는 `erb`이라고 해석하게 된다. 다른 포맷에 대해서 다른 핸들러를 사용하게 된다. `builder` 핸들러는 XML 템플릿을 빌드하고 `coffee` 핸들러는 자바스크립트 템플릿을 빌드하는데 사용할 수 있다. HTML 폼을 새로 만들기 원하기 때문에 HTML 문서에 루비 언어를 임베드하기 위해 만들어진 `ERB` 언어를 사용할 것이다.

따라서, 파일명은 `articles/new.html.erb` 이어야 하고 애플리케이션의 `app/views` 디렉토리 내에 위치해야 한다.

이제 `app/views/articles/new.html.erb` 위치에 새로운 파일을 생성하고 아래와 같이 작성한다.

```html
<h1>New Article</h1>
```

<http://localhost:3000/articles/new>를 새로 보기하면 하나의 타이틀을 포함하는 페이지를 보게 될 것이다. 라우트, 컨트롤러, 액션, 뷰가 조화롭게 잘 동작하고 있는 것이다. 새로운 기사를 작성할 폼을 생성할 시점이 되었다.

### 첫번째 폼

이 템플릿 파일에 폼을 생성하기 위해 *폼 빌더* 를 사용할 것이다. 레일스에서 사용하는 기본 폼 빌더는 `form_with` 헬퍼메소드가 제공해 준다. 이 메소드를 사용하기 위해서는 아래의 코드를 `app/views/articles/new.html.erb` 파일에 추가해 준다.

```html+erb
<%= form_with scope: :article, local: true do |form| %>
  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>
<% end %>
```

이제 이 페이지를 다시 보기하면 위의 예제에서 보았던 것과 동일한 폼을 보게 될 것이다. 
레일스에서 폼을 빌드하는 것은 정말 이렇게도 쉽다!

`form_with` 메소드를 호출할 때 이 폼에 대한 식별용 스코프를 지정한다. 이 경우에는 심볼 형태인 `:article`로 지정한다. 이것은 `form_with` 헬퍼에게 이 폼의 용도를 알려 주는 것이다. 이 메소드의 블록 내에서는 `form` 블록변수로 표시되는 `FormBuilder` 객체를 이용하여 기사 title과 text 용으로 두 개의 라벨과 두 개의 텍스트 필드를 빌드한다. 최종적으로 `form` 객체에 대해서 `submit` 메소드를 호출하여 폼에서 사용하게 되는 서밋 버튼을 생성하게 된다.

그러나 이 폼에서는 한가지 문제가 있다. 페이지의 소스보기에서 헬프메소드로 생성된 HTML을 조사해 보면 form 태그의 `action` 속성이 `articles/new`로 지정된 것을 알 수 있다. 이 라우트가 현재 폼이 위치하는 바로 그 페이지를 가리키기 때문이다. 이 라우트는 새로운 기사를 입력하기 위한 폼을 표시하기 위해서만 사용되어야 한다.

이 폼이 또 다른 곳으로 이동하기 위해서는 다른 URL을 사용해야 한다. 이 작업은 `form_with` 메소드에 `:url` 옵션을 지정함으로써 바로 해결할 수 있다. 레일스에서 보통, 이와 같이 새로운 폼 데이터를 서밋할 때 사용하는 액션을 "create"라고 부르는데 폼은 바로 이 액션으로 서밋되도록 해야 한다.

app/views/articles/new.html.erb` 파일에 있는 `form_with`를 아래와 같이 보이도록 수정한다.

```html+erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>
```
이 예문에서는 `:url` 옵션으로 `articles_path` 헬퍼를 넘겨준다. 이러한 작업으로 초래되는 결과를 보기 위해서 `rails routes`의 결과를 다시 보도록 한다.

```bash
$ rails routes
      Prefix Verb   URI Pattern                  Controller#Action
welcome_index GET    /welcome/index(.:format)     welcome#index
     articles GET    /articles(.:format)          articles#index
              POST   /articles(.:format)          articles#create
  new_article GET    /articles/new(.:format)      articles#new
 edit_article GET    /articles/:id/edit(.:format) articles#edit
      article GET    /articles/:id(.:format)      articles#show
              PATCH  /articles/:id(.:format)      articles#update
              PUT    /articles/:id(.:format)      articles#update
              DELETE /articles/:id(.:format)      articles#destroy
         root GET    /                            welcome#index
```

`articles_path` 헬퍼는 폼이 `articles` 접두어(prefix)와 연관되는 URI 패턴을 가리키도록 하는데 이 때 폼은 기본상태에서 해당 라우트로 `POST` 요청을 보내게 된다. 이 라우트는 `ArticlesController` 컨트롤러의 `create` 액션과 연결된다.

폼과 라우트가 지정된 상태에서 폼에 데이터를 입력한 후 서밋 버튼을 클릭하면 새 기사를 생성하는 과정을 시작하게 된다. 언급한 바와 같이 폼을 서밋하면 익숙한 에러 메시지를 보게 된다.

![Unknown action create for ArticlesController]
(images/getting_started/unknown_action_create_for_articles.png)

이제 이것이 제대로 동작하도록 하려면 `ArticlesController` 내에 `create` 액션을 작성해야 한다.

NOTE: 보통은 `form_with` 헬퍼는 Ajax로 폼을 서밋하게 되므로 전체 페이지 리디렉션이 발생하지 않는다. 현재는 이 가이드를 보다 쉽게 이해할 수 있도록 `local: true`로 옵션을 지정하여 이 기능을 사용하지 않도록 했다.

### 기사 작성하기

"Unknow action" 에러 메시지가 사라지게 하려면, 아래와 같이 `app/controllers/articles_controller.rb` 파일 내의 `ArticlesController` 클래스에서, `new` 액션 바로 아래에, `create` 액션을 정의한다.

```ruby
class ArticlesController < ApplicationController
  def new
  end

  def create
  end
end
```

이제 다시 폼 서밋하면 페이지상에 아무런 변화를 볼 수 없을 것이다. 잘 못 된 것은 아니므로 걱정할 필요 없다. 응답으로 보낼 내용이 없는 경우 레일스는 보통 `204 No Content(내용 없음)` 응답을 보내기 때문이다. 단지 `create` 액션만 추가한 후 응답으로 보낼 내용을 작성하지 않았다. 이 경우에는, `create` 액션은 데이터베이스로 새로 작성한 기사를 저장하도록 해야 한다.

폼이 서밋될 때, 폼 필드는 _매개변수(parameters)_ 로써 레일스로 보내진다. 이 매개변수들은 어떤 특정 일을 수행하기 위해 컨트롤러 액션에서 참조할 수 있다. 이 매개변수들의 상태를 보기 위해 아래와 같이 `create` 액션을 수정한다.

```ruby
def create
  render plain: params[:article].inspect
end
```

여기서 `render` 메소드는 `:plain` 키와 `params[:article].inspect` 값을 가지는 매우 단순한 해시를 인수로 받는다. `params` 메소드는 폼에서부터 넘어오는 매개변수(또는 폼 필드)를 나타내는 객체이다. `params` 메소드는 `ActionController::Parameters` 객체를 반환하는데, 이 객체로서 문자열이나 심볼을 이용하여 해시 키에 접근할 수 있도록 한다. 이 경우에 중요한 매개변수들은 폼으로부터 넘어 오는 것들 뿐이다.

TIP: `params` 메소드를 꽤나 일상적으로 사용할 것이기 때문에 확실하게 파악해 둘 필요가 있다. **http://www.example.com/?username=dhh&email=dhh@email.com** 와 같은 URL을 예로 들어 보자. 이 URL에서 `params[:username]`은 "dhh"가 될 것이고 `params[:email]`은 "dhh@email.com"가 될 것이다.

한번 더 폼을 다시 서밋하면 아래와 같은 것을 보게 될 것이다.

```ruby
<ActionController::Parameters {"title"=>"First Article!", "text"=>"This is my first article."} permitted: false>
```

이 액션은 폼으로부터 넘어 오는 해당 기사에 대한 매개변수를 보여 준다. 그러나 이것은 실제로 그렇게 유용하지 못하다. 그렇다. 매개변수들을 볼 수 있지만 그것들을 이용하여 특별히 작업한 것이 전혀 없다.

### Article 모델 생성하기

레일스에서는 모델 이름을 단수형으로 사용하고 해당 데이터베이스 테이블명으로는 복수형을 사용한다. 레일스는 모델을 생성하는 생성자 스크립트를 제공하는데 대부분의 레일스 개발자들은 새로운 모델을 작성할 때 이것을 사용하려고 한다. 새로운 모델을 작성할 때는 터미널에서 아래의 명령을 실행한다.

```bash
$ rails generate model Article title:string text:text
```
이 명령으로써 문자형의 _title_ 속성과 텍스트 속성의 _text_ 속성을 가지는 `Article` 모델을 원한다고 레일스에게 알려주게 된다. 이 속성들은 자동으로 데이터베이스 `articles` 테이블에 추가되어 `Article` 모델로 매핑된다.

레일스 다수의 파일들을 생성하므로써 응답을 보이게 된다. 현재로서는 `app/models/article.rb` 와 `db/migrate/20140120191729_create_articles.rb` 파일(각자 파일명에 차이가 있을 수 있음)에만 집중하도록 한다. 후자는 데이터베이스 구조를 정의하는 것을 담당하는데 이것은 다음에 살펴 보도록 한다.

TIP: 액티브 레코드는 매우 스마트해서 자동으로 컬럼명을 모델 속성으로 매핑해 주는데, 이것은 액티브 레코드가 자동으로 해 주기 때문에 레일스 모델 내에서 속성들을 따로 선언해 줄 필요가 없다는 것을 뜻한다.

### 마이그레이션 작업 수행하기

방금 보았듯이 `rails generate model` 명령으로 `db/migrate` 디렉토리 내에 _데이터베이스 마이그레이션_ 파일이 생성되었다. 마이그레이션을 데이터베이스 테이블을 생성하고 변경하는 작업을 쉽게 해 주기 위해 작성된 루비 클래스이다. 레일스는 rake 명령을 사용하여 마이그레이션 작업을 수행하며 데이터베이스에 적용이 완료된 후에도 마이그레이션을 취소할 수도 있다. 마이그레이션 파일명은 타임스탬프를 포함하는데 생성된 순서대로 마이그레이션으로 처리하기 위한 것이다.

`db/migrate/YYYYMMDDHHMMSS_create_articles.rb` 파일(각자의 파일명이 다를 수 있음)의 내용은 아래와 같을 것이다.

```ruby
class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
```

위의 마이그레이션에서 작성되는 `change` 메소드는 마이그레이션 작업이 수행될 때 호출된다. 이 메소드에서 정의된 작업 또한 가역적이며 이것은 나중에 되돌리기를 원할 경우 레일스가 마이그레이션으로 변경된 내용을 되돌릴 수 있는 방법을 알고 있다는 것을 의미한다. 이 마이그레이션을 수행하면 하나의 문자열 컬럼과 텍스트 컬럼을 가지는 `articles` 테이블을 생성하게 될 것이다. 또한 두 개의 타임스탬프 필드도 생성하는데 레일스가 기사를 생성하고 업데이트하는 시간을 추적하는데 사용된다.

TIP: 마이그레이션에 대한 더 많은 정보를 원할 경우 [Active Record Migrations]
(active_record_migrations.html)를 참고한다.

이 지점에서 아래와 같이 레일스 명령을 사용하여 마이그레이션 작업을 수행할 수 있다.

```bash
$ rails db:migrate
```

레일스는 이 마이그레이션 명령을 실행한 후 Articles 테이블이 생성되었음을 알려 줄 것이다.

```bash
==  CreateArticles: migrating ==================================================
-- create_table(:articles)
   -> 0.0019s
==  CreateArticles: migrated (0.0020s) =========================================
```

NOTE. 보통 개발 환경에서 작업을 할 것이기 때문에 `config/database.yml` 파일의 `development` 섹션에 정의된 데이터베이스에 마이그레이션 작업이 적용될 것이다. 다른 환경에서 마이그레이션을 실행하고자 할 경우, 예를 들어 운영 환경에서, `rails db:migrate RAILS_ENV=production`와 같이 명령을 호출할 때 명시적으로 지정해 주어야 한다.

### 컨트롤러에서 데이터 저장하기

새로 생성한 `Article` 모델을 이용하여 데이터베이스로 데이터를 저장하기 위해서는 `ArticlesController`로 돌아가서 `create` 액션을 변경할 필요가 있다. `app/controllers/articles_controller.rb` 파일을 열고 아래와 같이 `create` 액션을 변경한다.

```ruby
def create
  @article = Article.new(params[:article])

  @article.save
  redirect_to @article
end
```

위에서 일어난 상황을 설명하면 다음과 같다. 모든 레일스 모델은 각각의 데이터베이스 테이블 컬럼으로 자동으로 매핑되는 각각의 속성으로 초기화될 수 있다. 첫번째 코드라인에서 이런 작업을 하게 된다(`params[:article]`에는 관심있는 속성들이 포함되어 있다는 것을 기억한다). 다음으로 `@article.save`은 모델을 데이터베이스에 저장한다. 마지막으로 사용자를 `show` 액션으로 리디렉션하는데 이것은 나중에 정의할 것이다.

TIP: 이 가이드에서 기사들에 대한 대부분의 다른 참조는 소문자를 사용했던 반면, `Article.new`에서는 `A`를 대문자로 표시한 점에 대해서 궁금할 수 있다. 여기서는 `app/models/article.rb`에 정의 된 `Article` 클래스를 참조한다. 루비의 클래스 이름은 대문자로 시작해야 한다.

TIP: 나중에 알게 되겠지만 `@article.save`는 기사가 저장되었는지 여부를 부울 값(true/false)으로 반환한다.

<http://localhost:3000/articles/new>로 이동하면 기사를 *거의* 생성할 수 있게 될 것이다. 이와 같이 시도할 경우 아래와 같은 에러 메시지를 보게 될 것이다.

![Forbidden attributes for new article]
(images/getting_started/forbidden_attributes_for_new_article.png)

레일스에는 보안상 안전한 프로그램을 작성하는데 도움이되는 몇 가지 보안 기능이 있으며 이제 그 중 하나를 사용할 것이다. 이것은 [strong parameters](action_controller_overview.html#strong-parameters)라고 하는 것인데 컨트롤러 동작에 어떤 파라미터가 허용되는지 레일스에게 정확히 알려 준다.

왜 이렇게 귀찮은 과정을 거쳐야 할까? 모든 컨트롤러 파라미터를 한꺼번에 취합해서 모델로 자동 할당할 수 있다면 프로그래밍 작업을 더 쉽게 할 수 있겠지만 이 간편함은 역시 악의적인 용도로 사용될 수 있다. 서버에 대한 요청이 새로운 기사를 폼 서밋하는 것처럼 보이도록 조작되고 애플리케이션의 무결성을 위반하는 값을 가진 별도의 필드가 포함되었다면 어떻게 될까? 그것들은 기사 속성들과 함께 모델에서 데이터베이스로 '대량 할당' 되어 애플리케이션을 손상 시키거나 악화시킬 수 있을 것이다.

잘못된 대량 할당을 방지하기 위해서 허용되는 컨트롤러 매개변수를 정의해야 한다. 여기서는 `create`를 유효하게 사용하기 위해 `title` 및 `text` 매개 변수를 허용하고 필수항목으로 지정한다. 이를 위한 문법으로 `require`와 `permit`을 도입한다. `create` 액션에 아래와 같이 한 줄을 포함할 것이다.

```ruby
  @article = Article.new(params.require(:article).permit(:title, :text))
```

이것은 종종 별도의 메소드로 분리되어 동일한 컨트롤러 내의 여러 액션(예 :`create` 및`update`)에서 재사용 되기도 한다. 이 메소드는 대량 할당 문제를 해결할 뿐만 아니라 종종 의도된 경우 외에는 호출될 수 없도록 `private`로 선언한다. 아래에 그 결과를 보여 준다.

```ruby
def create
  @article = Article.new(article_params)

  @article.save
  redirect_to @article
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

TIP: 자세한 내용은 위의 레퍼런스 및 [Strong Paramters에 대한 이 블로그의 관련 기사](ttps://weblog.rubyonrails.org/2012/3/21/strong-parameters/)를 참고한다.

### 기사 보여주기

지금 폼을 다시 서밋하면 레일스는 `show` 액션를 찾지 못한다고 불평할 것이다. 그다지 유용하지는 않더라도 계속하기 전에 `show` 액션을 추가하도록 한다.

`rails routes`의 결과에서 보았 듯이 `show` 액션의 라우트는 다음과 같다.

```
article GET    /articles/:id(.:format)      articles#show
```

특수한 문법인 `:id` 는 이 라우트가 `:id` 매개 변수를 필요로 한다는 것을 레일스에 알려 주는데 이 경우에는 기사의 ID가 된다.

이전과 마찬가지로 `app/controllers/articles_controller.rb`의 `show` 액션과 해당 뷰를 추가해야 한다.

NOTE: 자주 사용하는 방법은 표준 CRUD 작업을 각 컨트롤러에 `index`, `show`, `new`, `edit`, `create`, `update` 및 `destroy` 순서로 배치하는 것이다. 각자가 임의로 순서를 변경할 수 있지만 이 메소드들은 public 메소드라는 점을 기억해 둔다. 이 가이드의 앞부분에서 언급했듯이 컨트롤러 상에 `private`를 선언하기 전에 배치해야 한다.

이를 감안하여 아래와 같이`show` 액션을 추가하자.

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  def new
  end

  # snippet for brevity
```

몇 가지 유의할 사항. `Article.find`를 사용하여 요청에서 `:id` 매개 변수를 얻기 위해 `params[:id]`를 전달하여 관심있는 기사를 찾는다. 또한 기사 객체에 대한 참조를 유지하기 위해 인스턴스 변수(`@` 접두사)를 사용한다. 레일스가 모든 인스턴스 변수를 뷰에 전달하기 때문에 이 작업을 수행한다.

이제 다음 내용으로 새 파일 `app/views/articles/show.html.erb`를 작성한다.

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>
```

이와 같이 변경한 후 비로서 기사를 새로 작성할 수 있게 되는 것이다.
이제 <http://localhost:3000/articles/new>를 방문하여 직접 사용해 보기 바란다!

![Show action for articles](images/getting_started/show_action_for_articles.png)

### 모든 기사 목록 보기

모든 기사를 나열할 방법도 필요하므로 함께 진행하도록 하자.
`rails routes`의 결과에 따른 라우트는 아래와 같다.

```
articles GET    /articles(.:format)          articles#index
```

`app/controllers/articles_controller.rb` 파일의 `ArticlesController` 내에 해당 라우트로 연결되는 `index` 액션을 추가한다. `index` 액션을 작성할 때는 습관적으로 컨트롤러 내에 첫 번째 메소드로 배치한다. 아래와 같이 작성한다.

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
  end

  # snippet for brevity
```

마지막으로 이 액션에 대한 뷰를 추가한다. 이 뷰 파일은 `app/views/articles/index.html.erb`에 위치한다.

```html+erb
<h1>Listing articles</h1>

<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
    </tr>
  <% end %>
</table>
```

이제 <http://localhost:3000/articles>로 이동하면 지금까지 작성한 모든 기사 목록이 표시될 것이다.

### 링크 추가하기

이제 기사를 작성하고 보여주고 목록을 나열할 수 있게 되었다. 다음으로 페이지간의 이동을 위한 몇가지 링크를 추가해 보도록 하자.

`app/views/welcome/index.html.erb` 파일을 열고 아래와 같이 변경한다.

```html+erb
<h1>Hello, Rails!</h1>
<%= link_to 'My Blog', controller: 'articles' %>
```

`link_to` 메소드는 레일스의 내장 뷰 헬퍼 중 하나이다. 표시할 텍스트와 이동 위치(이 경우 기사 목록에 대한 경로)를 기반으로 하이퍼링크를 생성한다.

이 "New Article" 링크를 `app/views/articles/index.html.erb`에 추가하여 다른 뷰에 대한 링크를 추가하고 `<table>` 태그 위에 배치해 보자.

```erb
<%= link_to 'New article', new_article_path %>
```

이 링크를 사용하면 새 기사를 작성할 수 있는 폼을 불러올 수 있다.

이제 `app/views/articles/new.html.erb` 파일 내의 폼 아래에 또 다른 링크를 추가하여 `index` 액션으로 돌아 갈 수 있도록 한다.

```erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>
  ...
<% end %>

<%= link_to 'Back', articles_path %>
```

마지막으로, `app/views/articles/show.html.erb` 템플릿에 링크를 추가하여 `index` 액션으로 돌아갈 수 있도록 하면 단일 기사를 보는 상태에서 되돌아 가서 다시 전체 목록을 볼 수 있게 된다.

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<%= link_to 'Back', articles_path %>
```

TIP: 레일스는 기본적으로 현재 컨트롤러를 사용하기 때문에 동일한 컨트롤러에서 액션에 연결하고자 할 경우 `:controller` 옵션을 지정할 필요가 없다.

TIP: 개발 모드(기본적으로 작업중인 모드)에서 레일스는 모든 브라우저 요청에 따라 애플리케이션을 다시 로드하므로 소스 코드의 변경시 웹 서버를 중지했다가 다시 시작할 필요가 없다.

### 몇가지 유효성 검사 추가하기

`app/models/article.rb` 모델 파일은 아래와 같이 간단하다.

```ruby
class Article < ApplicationRecord
end
```

이 파일에는 그다지 많은 내용이 있지 않지만 `Article` 클래스가 `ApplicationRecord`로부터 상속 받는다는 것에 주목한다. `ApplicationRecord`는, 기본 데이터베이스 CRUD (Create, Read, Update, Destroy) 작업, 데이터 유효성 검사, 정교한 검색 지원 및 여러 모델을 서로 연관시키는 기능을 포함하여, 레일스 모델에 많은 기능을 무료로 제공하는 `ActiveRecord::Base`로부터 상속받는다.

레일스에는 모델로 보내는 데이터의 유효성 검사에 도움이 되는 메소드가 포함되어 있다.
`app/models/article.rb` 파일을 열고 아래와 같이 변경한다.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

이로써 모든 기사의 제목은 5자 이상이어야 한다. 레일스는 컬럼의 유무와 형식, 그리고 관련 객체의 존재 등 모델의 다양한 조건을 검증 할 수 있다. 유효성 검사는 [Active Record Validations](active_record_validations.html)에 자세히 설명되어 있다.

유효성 검사가 설정된 상태에서 유효하지 않은 기사에 대해서 `@article.save`를 호출하면 `false`를 반환할 것이다. `app/controllers/articles_controller.rb`를 다시 열면 `create` 액션 내에서 `@article.save`를 호출 한 결과를 확인하지 않는다는 것을 알게 될 것이다.
이 상태에서 `@article.save`가 실패하면 사용자에게 폼을 다시 보여줘야 한다. 이를 위해서는 `app/controllers/articles_controller.rb`의 `new` 및 `create` 액션을 아래와 같이 변경한다.

```ruby
def new
  @article = Article.new
end

def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

`new` 액션은 이제 인스턴스 변수 `@article`을 새로 생성하게 되는데, 잠시 후에 그 이유를 알게 될 것이다.

`create` 액션 내에서 `save`가 `false`를 반환 할 때 `redirect_to` 대신 `render`를 사용하는 것을 주목한다. 렌더링될 때 `@article` 객체를  `new` 템플릿으로 다시 전달하기 위해 `render` 메소드를 사용하는 것이다.  이 렌더링은 폼 서밋과 동일한 요청 내에서 수행되지만 `redirect_to`는 브라우저에 다른 요청을 하도록 한다.

<http://localhost:3000/articles/new>를 다시 로드하고 title 없이 기사를 저장하려고 하면 검증 오류로 인하여 다시 폼이 렌더링 되지만 이에 대한 유용한 정보를 제공해 주지 못한다. 사용자에게 무언가 잘못되었다고 알려 주어야 한다. 이를 위해 `app/views/articles/new.html.erb`를 수정하여 오류 메시지가 발생한 경우 표시하도록 한다.

```html+erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>

<%= link_to 'Back', articles_path %>
```

여기서 처리되는 과정을 보면, `@article.errors.any?`를 호출하여 오류가 있는지 확인하고, 이 경우 `@article.errors.full_messages`로 모든 오류 목록을 표시하도록 한다.

`pluralize`는 숫자와 문자열을 인수로 받는 레일스 헬퍼 메소드이다. 숫자가 1보다 크면 문자열이 복수형으로 자동변환된다.

`ArticlesController`에 `@article = Article.new`를 추가한 이유는 그렇지 않을 경우 뷰 상에서 인스턴스 변수 `@article`의 값은 `nil`이 되고  이 때`@article.errors.any?`를 호출하면 에러가 발생하기 때문이다.

TIP: 레일스는 `field_with_errors` 클래스가 지정되어 있는 div 태그로 에러를 포함하는 필드를 자동으로 래핑한다. CSS 규칙을 정의하여 이러한 필드를 두드러지게 보이게 할 수 있다.

이제 새 기사 폼 <http://localhost:3000/articles/new>에서 title을 지정하지 않고 기사를 저장할 때 오류 메시지가 멋있게 표시될 것이다.

![Form With Errors](images/getting_started/form_with_errors.png)

### 기사 업데이트하기

지금까지 CRUD의 "CR"부분을 다뤘다. 이제 기사를 업데이트하면서 "U"부분에 초점을 맞추어 보자.

첫 번째 단계는 아래와 같이 `edit` 액션을 `ArticlesController`에 추가하는 것이다. 일반적으로 `new`와 `create` 액션 사이에 위치한다.

```ruby
def new
  @article = Article.new
end

def edit
  @article = Article.find(params[:id])
end

def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end
```

뷰에는 기사를 새로 작성할 때 사용한 것과 유사한 폼이 포함된다. `app/views/articles/edit.html.erb`라는 파일을 생성한 후 아래와 같이 추가한다.

```html+erb
<h1>Edit article</h1>

<%= form_with(model: @article, local: true) do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>

<%= link_to 'Back', articles_path %>
```

이번에는 폼이 `update` 액션을 가리키도록 하는데, 아직 정의되지 않았지만 곧 될 것이다.

`form_with` 메소드에 기사 객체를 전달하면 편집 된 기사 폼을 서밋하기 위한 URL이 자동으로 설정된다. 이 옵션을 사용하면 `PATCH` HTTP 메소드로 이 폼을 서밋할 수 있으며 이 메소드는 REST 프로토콜에 따라 리소스를 **업데이트**하는 데 사용하는 HTTP 메소드이다.

또한, 위의 편집 뷰에서 `model: @article`과 같이 `form_with`에 모델 객체를 전달하면 폼 헬퍼가 객체의 해당 값으로 폼 필드를 채우게 된다. new 뷰에서와 같이 `scope: :article`과 같은 심볼 스코프를 전달하면 빈 폼 필드 만 생성된다. 자세한 내용은 [form_with documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)에서 찾아 볼 수 있다.

다음으로 `app/controllers/articles_controller.rb`에 `update` 액션을 만들어야 한다. `create` 액션과 `private` 메소드 사이에 추가한다.

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end

def update
  @article = Article.find(params[:id])

  if @article.update(article_params)
    redirect_to @article
  else
    render 'edit'
  end
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

새로 작성하는 `update` 메소드는 이미 존재하는 레코드를 업데이트할 때 사용되며 업데이트하려는 속성을 포함하는 해시를 이용한다. 이전과 마찬가지로 기사를 업데이트하는 동안 오류가 발생하면 폼을 사용자에게 다시 보여 주도록 한다.

앞서 create 액션을 위해 정의했던 `article_params` 메소드를 재사용한다.

TIP: 모든 속성을 `update`에 전달할 필요는 없다. 예를 들어, `@article.update(title: 'A new title')`이 호출되면 레일스는 `title` 속성 만 업데이트하고 다른 모든 속성은 변경하지 않는다.

마지막으로, 모든 기사 목록에서 `edit` 액션에 대한 링크를 보여 주기 위해서, 이제 `app/views/articles/index.html.erb`에 이 링크를 추가하여 "Show" 링크 옆에 보이도록 한다.

```html+erb
<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th colspan="2"></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
    </tr>
  <% end %>
</table>
```

또한 `app/views/articles/show.html.erb` 템플릿에도 하나를 추가하여 기사 페이지에도 "Edit" 링크가 위치하게 된다. 템플릿 맨 아래에 추가한다.

```html+erb
...

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

그리고 지금까지 작업한 내용은 아래와 같다.

![Index action with edit link](images/getting_started/index_action_with_edit_link.png)

### 파셜을 이용하여 뷰의 중복 코드 정리하기

`edit` 페이지는 `new` 페이지와 매우 유사하다. 실제로 둘 다 폼을 표시하기 위해 동일한 코드를 공유한다. 뷰 파셜을 사용하여 이러한 중복 코드를 제거할 수 있다. 일반적으로 파셜 파일의 이름은 밑줄로 시작된다.

TIP: 파셜에 대한 자세한 내용은 [Layouts and Rendering in Rails](layouts_and_rendering.html) 가이드를 읽어 보기 바란다.

아래의 내용으로 `app/views/articles/_form.html.erb` 파일을 새로 생성한다.

```html+erb
<%= form_with model: @article, local: true do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>
```

`form_with` 선언을 제외한 모든 것은 동일하게 유지되었다.
이와 같이 더 짧고 간단한 `form_with` 선언을 다른 폼 중 하나에 사용할 수 있는 이유는 `@article`이 전체 RESTful 라우트 세트에 일치하는 *리소스*이고 레일스가 어떤 URI와 메소드를 사용할 것인지를 유추할 수 있기 때문이다.
`form_with` 사용에 대한 자세한 내용은 [Resource-oriented style](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with-label-Resource-oriented+style)을 참조하기 바란다.

이제 이 파셜을 사용하도록 `app/views/articles/new.html.erb` 뷰를 완전히 다시 작성하여 업데이트 하자.

```html+erb
<h1>New article</h1>

<%= render 'form' %>

<%= link_to 'Back', articles_path %>
```

그런 다음 `app/views/articles/edit.html.erb` 뷰에 대해 동일한 작업을 수행한다.

```html+erb
<h1>Edit article</h1>

<%= render 'form' %>

<%= link_to 'Back', articles_path %>
```

### 기사 삭제하기

이제 데이터베이스에서 기사를 삭제하는 CRUD의 "D"부분에 대해선 언급할 것이다. REST 규칙에 따른 `rails routes`의 결과를 근거로 기사 삭제 라우트는 아래와 같다.

```ruby
DELETE /articles/:id(.:format)      articles#destroy
```

`delete` 라우팅 메소드는 리소스를 삭제하는 라우트에 사용해야 한다. 이것을 일반적인 `get` 라우트 그대로 남겨 둘 경우 사람들이 아래와 같은 악의적인 URL을 만들어 공격할 수 있다.

```html
<a href='http://example.com/articles/1/destroy'>look at this cat!</a>
```

리소스 삭제 시에 `delete` 메소드를 사용하는데, 이 라우트는 아직 존재하지 않는 `app/controllers/articles_controller.rb` 내의 `destroy` 액션에 매핑된다. `destroy` 메소드는 일반적으로 컨트롤러 상에서 마지막 CRUD 액션이며 다른 public CRUD 액션과 마찬가지로 `private` 또는 `protected` 메소드 앞에 배치해야 한다. 아래와 같이 추가한다.

```ruby
def destroy
  @article = Article.find(params[:id])
  @article.destroy

  redirect_to articles_path
end
```

`app/controllers/articles_controller.rb` 파일의 `ArticlesController`의 최종본은 이제 아래와 같아야 한다.

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def edit
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render 'new'
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to articles_path
  end

  private
    def article_params
      params.require(:article).permit(:title, :text)
    end
end
```

데이터베이스에서 삭제하려는 경우 액티브 레코드 객체에서 `destroy`를 호출 할 수 있다. 주목할 것은 `index` 액션으로 리디렉션하기 때문에 이 액션에 대한 뷰를 추가 할 필요는 없다.

마지막으로 할 작업은, `index` 액션 템플릿(`app/views/articles/index.html.erb`)에 `Destroy` 링크를 추가하여 마무리 하는 것이다.

```html+erb
<h1>Listing Articles</h1>
<%= link_to 'New article', new_article_path %>
<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th colspan="3"></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
      <td><%= link_to 'Destroy', article_path(article),
              method: :delete,
              data: { confirm: 'Are you sure?' } %></td>
    </tr>
  <% end %>
</table>
```

여기서는 다른 방식으로 `link_to`를 사용할 것이다. 네임드 라우트(named route, prefix가 있는 라우트)를 두 번째 인수로, 다른 옵션을 또 다른 인수로 전달한다.
`method: :delete` 및 `data: { confirm : 'Are you sure?' }` 옵션은 HTML5 속성으로 사용되기 때문에, 링크를 클릭할 경우 레일스는 먼저 사용자에게 확인창을 보여 준 다음, `delete` 메소드를 사용하여 링크를 서밋한다. 이것은 애플리케이션을 생성 할 때 애플리케이션 레이아웃 (`app/views/layouts/application.html.erb`)에 자동으로 포함되는 자바스크립트 파일 `rails-ujs`를 통해 수행된다. 이 파일이 없으면 확인창이 나타나지 않을 것이다.

![Confirm Dialog](images/getting_started/confirm_dialog.png)

TIP: [Working With JavaScript in Rails](working_with_javascript_in_rails.html) 가이드에서 unobtrusive 자바스크립트에 대해 자세히 알 수 있다.

축하한다. 이제 기사를 작성, 보여주기, 리스트보기, 업데이트 및 삭제할 수 있게 되었다.

TIP: 일반적으로 레일스는 라우트를 수동으로 선언하는 대신 리소스 객체를 사용하도록 권장한다. 라우팅에 대한 자세한 내용은 [Rails Routing from the Outside In](routing.html)을 참조하기 바란다.

두번째 모델 추가하기
---------------------

이제 애플리케이션에 두 번째 모델을 추가할 때가 되었다. 두 번째 모델은 기사에 대한 댓글을 처리할 것이다.

### 모델 생성하기

`Article` 모델을 생성할 때 전에 사용했던 것과 같은 생성자를 사용할 것이다. 이번에는 기사에 대한 참조를 담는 `Comment` 모델을 생성할 것이다. 터미널에서 아래의 명령을 실행한다.

```bash
$ rails generate model Comment commenter:string body:text article:references
```

이 명령은 4 개의 파일을 생성할 것이다.

| 파일                                         | 용도                                                                                                |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb | 데이터베이스에 comments 테이블을 작성하기 위한 마이그레이션 (파일명에 각기 다른 타임스탬프가 포함됨) |
| app/models/comment.rb                        | Comment 모델                                                                                      |
| test/models/comment_test.rb                  | comment 모델의 기능 테스트하기                                                                 |
| test/fixtures/comments.yml                   | 테스트에 사용할 샘플 댓글                                                                     |

먼저, `app/models/comment.rb` 파일 내용을 살펴 본다.

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

이것은 앞서 본 `Article` 모델과 매우 유사하다. 차이점은 `belongs_to: article`이며, 액티브레코드 _association(관계)_ 을 설정한다.
본 가이드의 다음 섹션에서 관계에 대해 약간 배우게 된다.

bash 명령에 사용 된 (`:references`) 키워드는 모델의 특수 데이터 유형이다.
지정된 모델 이름 끝에 정수 값을 보유할 수 있는 `_id`를 추가하여 데이터베이스 테이블에 컬럼으로 추가한다. 이해를 돕기 위해 마이그레이션을 실행 한 후 `db/schema.rb` 파일을 분석해 보기 바란다.

모델 외에도 레일스는 해당 데이터베이스 테이블을 생성하기 위한 마이그레이션을 작성했다.

```ruby
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

`t.references` 줄은 `article_id`라는 정수 컬럼, 이 컬럼에 대한 인덱스, articles 테이블의 `id` 컬럼을 가리키는 외래 키 제약 조건을 만든다. 이제 아랭와 같이 마이그레이션을 실행한다.

```bash
$ rails db:migrate
```

레일스는 현재 데이터베이스에 대해 아직 실행되지 않은 마이그레이션만 실행하기 때문에 이 경우에는 아래과 같은 결과를 보게 될 것이다.

```bash
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### 모델 관계 선언하기

액티브레코드 관계를 사용하면 두 모델 간의 관계를 쉽게 선언 할 수 있다. 댓글과 기사의 경우 다음과 같이 관계를 작성할 수 있다.

* 각 댓글은 하나의 기사에 속한다.
* 하나의 기사는 다수의 댓글을 가질 수 있다.

실제로 이것은 레일스가 이 관계를 선언하는 데 사용하는 문법과 매우 유사하다. `Comment` 모델 (app/models/comment.rb)에서 각 댓글이 기사에 속하도록 하는 코드 라인을 이미 보았고 아래와 같다.

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

관계의 다른 쪽을 추가하려면 `app/models/article.rb`를 수정해야 한다.

```ruby
class Article < ApplicationRecord
  has_many :comments
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

이 두 가지 선언을 통해서 몇가지 작업을 자동화할 수 있다. 예를 들어 기사를 포함하는 인스턴스 변수 '@article'가 있는 경우 `@ article.comments`를 사용하여 해당 기사에 속하는 모든 댓글을 배열로 검색 할 수 있다.

TIP: 액티브 레코드 연결에 대한 자세한 내용은 [Active Record Associations](association_basics.html) 안내서를 참조한다.

### 댓글에 대한 라우트 추가하기

`welcome` 컨트롤러와 마찬가지로 `comments` 리소스에 대한 라우트를 추가해야 할 것이다. `config/routes.rb` 파일을 다시 열고 아래와 같이 수정한다.

```ruby
resources :articles do
  resources :comments
end
```

이것은 `articles` 내에서 `comments`를 _nested resource_ 상태로 생성한다. 이것은 기사와 댓글 사이에 존재하는 계층적 관계를 적용하는 또 다른 부분이다.

TIP: 라우팅에 대한 자세한 내용은 [Rails Routing](routing.html) 안내서를 참조한다.

### 컨트롤러 생성하기

모델이 준비된 상태에서 다음으로 연관 컨트롤러를 만드는 데 집중해야 한다. 이 때 전에 사용했던 것과 동일한 생성자를 사용할 것이다.

```bash
$ rails generate controller Comments
```

이것은 4개의 파일과 하나의 빈 디렉토리를 생성한다.

| 파일/디렉토리                               | 용도                                  |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | Comments 컨트롤러                  |
| app/views/comments/                          | 해당 컨트롤러에 대한 뷰 파일들이 여기에 저장된다.  |
| test/controllers/comments_controller_test.rb | 해당 컨트롤러에 대한 테스트              |
| app/helpers/comments_helper.rb               | 뷰 헬퍼 파일                       |
| app/assets/stylesheets/comments.scss         | 해당 컨트롤러에 대한 CSS 파일 |

다른 블로그와 마찬가지로 독자들이 기사를 읽은 직후에 댓글을 작성할 것이며 일단 댓글이 추가되면 기사 보기 페이지로 되돌아가서 해당 기사에 달린 댓글 목록을 보게 될 것이다. 이로 인해 `CommentsController`는 댓글을 작성하고 스팸 댓글이 달리면 삭제하는 메소드를 제공한다.

먼저, 기사 보기 템플릿 (`app/views/articles/show.html.erb`)을 연결하여 새로운 댓글을 작성할 수 있도록 한다.

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Add a comment:</h2>
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

이것은 `Article` 보기 페이지에 `CommentsController` `create` 액션을 호출하여 새로운 댓글을 작성하는 폼을 추가한다. 여기서 `form_with` 메소드 호출할 때 배열을 인수로 사용하는데, `/articles/1/comments`와 같은 중첩 라우트를 생성해 줄 것이다.

`app/controllers/comments_controller.rb`에서 `create` 액션을 아래와 같이 작성하여 연결한다.

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

기사 컨트롤러에서 보다 약간 더 복잡해지는 것을 알게 될 것이다. 이것은 중첩 라우팅으로 인한 부작용이다. 댓글에 대한 요청시 마다 댓글이 달린 기사를 기억해 두어야 하므로 `Article` 모델의 `find` 메소드를 초기에 호출하여 해당 기사를 확보해 두어야 한다.

또한 코드 작성시 모델 관계에서 사용할 수 있는 메소드를 활용한다. `@article.comments`에서 `create` 메소드를 사용하여 댓글을 작성하고 저장한다. 이렇게 하므로써 댓글이 해당 특정 기사에 속하도록 자동 링크된다.

새로운 댓글을 작성하면 `article_path (@article)` 헬퍼를 사용하여 사용자를 원래 기사로 돌려 보낸다. 이미 보았 듯이, 이것은 `ArticlesController`의`show` 액션을 호출하여`show.html.erb` 템플릿을 렌더링한다. 이것은 댓글을 보여줄 위치이므로 `app/views/articles/show.html.erb`에 댓글을 추가해 보자.

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

이제 블로그에 기사와 댓글을 추가하고 재위치에 보여 줄 수 있게 되었다.

![Article with Comments](images/getting_started/article_with_comments.png)

리팩토링하기
-----------

이제 기사와 댓글이 작성되었으므로 `app/views/articles/show.html.erb` 템플릿을 살펴 보도록 한다. 코드가 길어지면서 점점 어색해지고 있다. 파셜을 사용하면 깨끗하게 정리할 수 있다.

### Rendering Partial Collections

First, we will make a comment partial to extract showing all the comments for
the article. Create the file `app/views/comments/_comment.html.erb` and put the
following into it:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

Then you can change `app/views/articles/show.html.erb` to look like the
following:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

This will now render the partial in `app/views/comments/_comment.html.erb` once
for each comment that is in the `@article.comments` collection. As the `render`
method iterates over the `@article.comments` collection, it assigns each
comment to a local variable named the same as the partial, in this case
`comment`, which is then available in the partial for us to show.

### Rendering a Partial Form

Let us also move that new comment section out to its own partial. Again, you
create a file `app/views/comments/_form.html.erb` containing:

```html+erb
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Then you make the `app/views/articles/show.html.erb` look like the following:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

The second render just defines the partial template we want to render,
`comments/form`. Rails is smart enough to spot the forward slash in that
string and realize that you want to render the `_form.html.erb` file in
the `app/views/comments` directory.

The `@article` object is available to any partials rendered in the view because
we defined it as an instance variable.

Deleting Comments
-----------------

Another important feature of a blog is being able to delete spam comments. To do
this, we need to implement a link of some sort in the view and a `destroy`
action in the `CommentsController`.

So first, let's add the delete link in the
`app/views/comments/_comment.html.erb` partial:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>

<p>
  <%= link_to 'Destroy Comment', [comment.article, comment],
               method: :delete,
               data: { confirm: 'Are you sure?' } %>
</p>
```

Clicking this new "Destroy Comment" link will fire off a `DELETE
/articles/:article_id/comments/:id` to our `CommentsController`, which can then
use this to find the comment we want to delete, so let's add a `destroy` action
to our controller (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

The `destroy` action will find the article we are looking at, locate the comment
within the `@article.comments` collection, and then remove it from the
database and send us back to the show action for the article.


### Deleting Associated Objects

If you delete an article, its associated comments will also need to be
deleted, otherwise they would simply occupy space in the database. Rails allows
you to use the `dependent` option of an association to achieve this. Modify the
Article model, `app/models/article.rb`, as follows:

```ruby
class Article < ApplicationRecord
  has_many :comments, dependent: :destroy
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

Security
--------

### Basic Authentication

If you were to publish your blog online, anyone would be able to add, edit and
delete articles or delete comments.

Rails provides a very simple HTTP authentication system that will work nicely in
this situation.

In the `ArticlesController` we need to have a way to block access to the
various actions if the person is not authenticated. Here we can use the Rails
`http_basic_authenticate_with` method, which allows access to the requested
action if that method allows it.

To use the authentication system, we specify it at the top of our
`ArticlesController` in `app/controllers/articles_controller.rb`. In our case,
we want the user to be authenticated on every action except `index` and `show`,
so we write that:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # snippet for brevity
```

We also want to allow only authenticated users to delete comments, so in the
`CommentsController` (`app/controllers/comments_controller.rb`) we write:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # snippet for brevity
```

Now if you try to create a new article, you will be greeted with a basic HTTP
Authentication challenge:

![Basic HTTP Authentication Challenge](images/getting_started/challenge.png)

Other authentication methods are available for Rails applications. Two popular
authentication add-ons for Rails are the
[Devise](https://github.com/plataformatec/devise) rails engine and
the [Authlogic](https://github.com/binarylogic/authlogic) gem,
along with a number of others.


### Other Security Considerations

Security, especially in web applications, is a broad and detailed area. Security
in your Rails application is covered in more depth in
the [Ruby on Rails Security Guide](security.html).


What's Next?
------------

Now that you've seen your first Rails application, you should feel free to
update it and experiment on your own.

Remember, you don't have to do everything without help. As you need assistance
getting up and running with Rails, feel free to consult these support
resources:

* The [Ruby on Rails Guides](index.html)
* The [Ruby on Rails Tutorial](https://www.railstutorial.org/book)
* The [Ruby on Rails mailing list](https://groups.google.com/group/rubyonrails-talk)
* The [#rubyonrails](irc://irc.freenode.net/#rubyonrails) channel on irc.freenode.net


Configuration Gotchas
---------------------

The easiest way to work with Rails is to store all external data as UTF-8. If
you don't, Ruby libraries and Rails will often be able to convert your native
data into UTF-8, but this doesn't always work reliably, so you're better off
ensuring that all external data is UTF-8.

If you have made a mistake in this area, the most common symptom is a black
diamond with a question mark inside appearing in the browser. Another common
symptom is characters like "Ã¼" appearing instead of "ü". Rails takes a number
of internal steps to mitigate common causes of these problems that can be
automatically detected and corrected. However, if you have external data that is
not stored as UTF-8, it can occasionally result in these kinds of issues that
cannot be automatically detected by Rails and corrected.

Two very common sources of data that are not UTF-8:

* Your text editor: Most text editors (such as TextMate), default to saving
  files as UTF-8. If your text editor does not, this can result in special
  characters that you enter in your templates (such as é) to appear as a diamond
  with a question mark inside in the browser. This also applies to your i18n
  translation files. Most editors that do not already default to UTF-8 (such as
  some versions of Dreamweaver) offer a way to change the default to UTF-8. Do
  so.
* Your database: Rails defaults to converting data from your database into UTF-8
  at the boundary. However, if your database is not using UTF-8 internally, it
  may not be able to store all characters that your users enter. For instance,
  if your database is using Latin-1 internally, and your user enters a Russian,
  Hebrew, or Japanese character, the data will be lost forever once it enters
  the database. If possible, use UTF-8 as the internal storage of your database.
