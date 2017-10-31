
Rails에서 JavaScript 사용하기
================================

이 가이드에서는 Rails에 내장되어 있는 Ajax/JavaScript 기능 등에 대해서 설명합니다. 이들을 활용하여 멋진 Ajax 애플리케이션을 간단하게 만들 수 있습니다.

이 가이드의 내용:

* Ajax 기초
* 겸손한 JavaScript
* Rails의 내장 헬퍼 사용하기
* 서버측에서 Ajax를 다루기
* Turbolinks

-------------------------------------------------------------------------------

Ajax 소개
------------------------

Ajax를 이해하려면 웹브라우저의 기본적인 동작을 이해할 필요가 있습니다.

브라우저의 주소창에 `http://localhost:3000`라고 입력하고 'Go'를 누르면 브라우저(다시 말해, 클라이언트)는 서버에게 요청을 하나 전송합니다. 브라우저는 서버로부터 받은 응답을 해석하고, 이어서 필요한 모든 애셋(JavaScript 파일, 스타일시트, 이미지)등을 받아옵니다. 다음으로 브라우저는 페이지를 그립니다. 브라우저에 표시된 링크를 클릭하면 같은 과정이 반복됩니다. 브라우저는 페이지와 애셋을 순서대로 가져오고 그것들을 모두 모아서 결과를 출력합니다. 이것이 흔히 말하는 '요청-응답' 사이클입니다.

JavaScript도 위에서 설명한 것과 마찬가지로 요청을 전송하고, 응답을 해석할 수 있습니다. JavaScript는 페이지상의 정보를 갱신할 수도 있습니다. JavaScript 개발자는 브라우저와 JavaScript라는 2개의 기술을 하나로 합쳐, 현재 보이는 페이지의 일부만을 갱신할 수도 있습니다. 필요한 웹페이지를 서버로부터 모두 가져올 필요가 없습니다. 이 강력한 기법이 바로 Ajax라고 불리는 것입니다.

Rails에는 JavaScript를 쓰기 편하게 만든 CoffeeScript가 기본으로 포함되어 있습니다. 이후, 이 가이드에서는 모든 예제를 CoffeeScript로 기술합니다. 물론 이 모든 예제들은 그냥 JavaScript에서도 적용할 수 있습니다.

예를 들어, jQuery 라이브러리를 사용해서 Aajx 요청을 전송하는 CoffeeScript 코드를 보이겠습니다.

```coffeescript
$.ajax(url: "/test").done (html) ->
  $("#results").append html
```

이 코드는 "/test"에서 데이터를 취득하여, 결과를 웹페이지 위의 `results`라는 id를 가지는 `div` 태그에 집어넣습니다.

Rails에는 이러한 기법을 웹페이지를 생성시에 사용하기 위한 추가 기능이 여럿 내장되어 있습니다. 따라서, 이러한 코드를 모두 직접 작성할 필요는 없습니다. 이후, 이러한 기법으로 Rails 웹사이트를 생성하는 방법에 대해서 설명합니다. 이러한 기법은 모두 간단한 기본 테크닉 위에서 성립합니다.

겸손한(Unobtrusive) JavaScript
-------------------------------------

Rails에서는 JavaScript를 DOM에 추가할 때의 기법을 '겸손한(unobtrusive) JavaScript'라고 부르고 있습니다. 이것은 일반적으로 프론트엔드 개발자 커뮤니티에서는 가장 좋은 방법이라고 여겨지고 있습니다만, 여기에서는 조금 다른 관점에서 설명합니다.

가장 간단한 JavaScript를 예로 들어서 생각해봅시다. 아래와 같은 작성법은 '인라인 JavaScript'라고 불립니다.

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```
이 링크를 클릭하면 배경이 붉게 변합니다. 하지만 벌써부터 여기에서 문제가 발생합니다. 클릭했을 때에 JavaScript에서 추가 작업을 하고 싶을 때에는 어떻게 해야할까요?

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';">Paint it green</a>
```

많이 복잡해졌습니다. 그러면 여기에서 함수를 사용해서 click 핸들러를 바깥으로 꺼내고, CoffeeScript로 변환해봅시다.

```coffeescript
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor
```

페이지의 내용은 다음과 같습니다.

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
```

이를 통해서 코드가 많이 개선되었습니다. 하지만 같은 효과를 여러 링크에 대해서 사용하려면 어떻게 될까요?

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(this, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(this, '#000099', '#FFFFFF')">Paint it blue</a>
```

이래서는 DRY하다고 말할 수 없습니다. 이번에는 이벤트를 사용해서 개선해보죠. 처음에 `data-*` 속성을 링크에 추가합니다. 그리고 이 속성을 가지는 모든 링크에서 발생하는 클릭 이벤트에 핸들러를 할당합니다.

```coffeescript
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

$ ->
  $("a[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
```

```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

우리들은 이러한 방법을 '겸손한 JavaScript'라고 부릅니다. 이 명칭은 HTML 코드에 JavaScript 코드를 섞이도록 하지 않겠다는 의도에서 유래합니다. JavaScript를 올바르게 분리할 수 있었으므로, 앞으로의 변경이 유리해집니다. 이후에는 이 `data-*` 속성을 링크 태그에 추가하기만 하면 이 동작을 간단하게 추가할 수 있습니다. Rails에서는 이러한 최소화와 연결을 사용해서 많은 JavaScript를 실행할 수 있습니다. JavaScript 코드는 Rails의 어떤 웹페이지에서든 단일하게 사용됩니다. 다시 말해서 페이지가 처음 브라우저에 로드되었을 때에 다운로드되며, 이후에는 브라우저에 캐싱됩니다. 이를 통해 많은 이점을 얻을 수 있습니다.

Rails 팀은 이 가이드에서 소개한 방법으로 CoffeeScript와 JavaScript를 사용하기를 강하게 추천합니다. 많은 JavaScript 라이브러리도 앞으로는 이러한 방식으로 사용될 것입니다.

내장 헬퍼
----------------------

HTML 생성을 쉽게 하기 위해서 Ruby로 작성된 다양한 뷰 헬퍼 메소드가 정의되어 있습니다. 이러한 HTML 요소에 Ajax 코드를 조금만 추가하고 싶은 경우에도 Rails는 이를 도와줍니다.

Rails의 JavaScript는 '겸손한 JavaScript' 원칙에 따라서 JavaScript에 의한 요소와 Ruby에 의한 요소로 구성되어 있습니다.

애셋 파이프라인을 비활성화하지 않는다면 JavaScript에 의한 부분은 [rails.js](https://github.com/rails/jquery-ujs/blob/master/src/rails.js)로 제공되며, Ruby에 의한 요소는 어떤 정규 뷰 헬퍼를 통해서 DOM에 적절한 태그를 추가합니다.

### form_for

[`form_for`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)는 폼 생성을 돕는 헬퍼입니다. `form_for`는 JavaScript를 사용하기 위한 `:remote` 옵션을 인수로 넘길 수 있습니다. 이 동작은 다음과 같습니다.

```erb
<%= form_for(@article, remote: true) do |f| %>
  ...
<% end %>
```

이 코드는 아래와 같은 HTML 코드를 생성합니다.

```html
<form accept-charset="UTF-8" action="/articles" class="new_article" data-remote="true" id="new_article" method="post">
  ...
</form>
```

form 태그에 `data-remote="true"`라는 속성이 추가되었다는 점에 주목해주세요. 이를 통해, 폼의 전송이 브라우저에 의한 일반적인 전송이 아닌, Ajax를 통해 전송되게 됩니다.

기입된 `<form>`을 가져오는 것만으로는 부족합니다. 전송이 성공했을 경우에 무언가 눈에 보이는 효과를 주고 싶습니다. 이를 위해서는 `ajax:success` 이벤트를 사용합니다. 전송에 실패한 경우에는 `ajax:error`를 사용합니다. 실제 예제를 봅시다.

```coffeescript
$(document).ready ->
  $("#new_article").on("ajax:success", (e, data, status, xhr) ->
    $("#new_article").append xhr.responseText
  ).on "ajax:error", (e, xhr, status, error) ->
    $("#new_article").append "<p>ERROR</p>"
```

명백하게 이전에 작성한 방법보다 보기 좋습니다. 하지만 이것은 맛보기에 불과합니다. 더 자세한 설명은 [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki/ajax)에 설명되어 있는 이벤트를 참조해주세요.

### form_tag

[`form_tag`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)는 `form_for`와 무척 비슷합니다. 이 메소드에도 `:remote` 옵션이 있으며, 아래와 같이 사용할 수 있습니다.

```erb
<%= form_tag('/articles', remote: true) do %>
  ...
<% end %>
```

이 코드로부터 다음의 HTML이 생성됩니다.

```html
<form accept-charset="UTF-8" action="/articles" data-remote="true" method="post">
  ...
</form>
```

그 이외의 부분은 `form_for`와 동일합니다. 자세한 설명은 문서를 참조해주세요.

### link_to

[`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)는 링크 생성을 도와주는 헬퍼입니다. 이 메소드에는 `:remote` 옵션이 있으며 다음과 같이 사용할 수 있습니다.

```erb
<%= link_to "an article", @article, remote: true %>
```

이 코드는 다음을 생성합니다.

```html
<a href="/articles/1" data-remote="true">an article</a>
```

`form_for`의 경우와 마찬가지로 같은 Ajax 이벤트를 연결할 수 있습니다. 다음에서 예제를 보입니다. 한번의 클릭으로 기사를 삭제할 수 있는 목록이 있습니다. 이 HTML 코드는 다음으로 생성할 수 있습니다.

```erb
<%= link_to "Delete article", @article, remote: true, method: :delete %>
```

여기에 추가로 CoffeeScript를 작성합니다.

```coffeescript
$ ->
  $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    alert "The article was deleted."
```

### button_to

[`button_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)는 버튼을 생성하기 위한 헬퍼입니다. 이 메소드에는 `:remote` 옵션이 있으며 다음과 같이 사용할 수 있습니다.

```erb
<%= button_to "An article", @article, remote: true %>
```

이 코드로 다음의 HTML 코드가 생성됩니다.

```html
<form action="/articles/1" class="button_to" data-remote="true" method="post">
  <input type="submit" value="An article">
</form>
```

작성된 것은 일반적인 `<form>`이므로 `form_for`에 관한 정보를 모두 `button_to`에도 사용할 수 있습니다.

서버에서 고려해야할 점
--------------------

Ajax는 클라이언트 쪽뿐만 아니라, 어느 정도 서버 쪽에서도 작업이 필요합니다. Ajax 요청에 대해서 응답을 반환할 때의 형식은 HTML보다도 JSON을 사용하는 것이 선호됩니다. 그러면 필요한 부분에 대해서 설명하겠습니다.

### 간단한 예시

출력하고 싶은 사용자 목록이 있고, 그 페이지에 새 사용자를 생성하는 폼을 두고 싶다고 합시다. 이 컨트롤러의 index 액션은 다음과 같을 것입니다.

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

index 뷰(`app/views/users/index.html.erb`)는 다음과 같이 작성합니다.

```erb
<b>Users</b>

<ul id="users">
<%= render @users %>
</ul>

<br>

<%= form_for(@user, remote: true) do |f| %>
  <%= f.label :name %><br>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

`app/views/users/_user.html.erb` 파셜의 내용은 이렇습니다.

```erb
<li><%= user.name %></li>
```

index페이지의 상단에서는 사용자의 목록을 표시합니다. 아래에는 사용자를 생성하기 위한 폼이 표시됩니다.

하단의 폼은 `UsersController`의 `create` 액션을 호출합니다. 폼의 remote 옵션이 켜져있으므로 요청은 Ajax 요청으로서 `UsersController`에 넘겨지고, JavaScript를 찾습니다. 컨트롤러에서 요청에 응답하는 `create` 액션은 다음과 같이 될것입니다.

```ruby
# app/controllers/users_controller.rb
  # ......
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.js   {}
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

format.js이 `respond_to` 블록 안에 있다는 점을 주의해주세요. 이를 통해서 컨트롤러가 Ajax 요청에 대해 응답을 돌려줄 수 있게 됩니다. 이어서 대응하는 `app/views/users/create.js.erb` 뷰 파일을 작성합니다. 실제로 JavaScript 코드는 이 뷰에서 생성되어, 클라이언트로 넘어가 실행됩니다.

```erb
$("<%= escape_javascript(render @user) %>").appendTo("#users");
```

Turbolinks
----------

Rails에는 [Turbolinks 라이브러리](https://github.com/turbolinks/turbolinks)이 포함되어 있습니다. 이는 Ajax를 사용하여 대부분의 애플리케이션에서의 페이지 렌더링 속도를 향상시킵니다.

### Turbolinks의 동작 원리

Turbolinks는 페이지에 존재하는 모든 `<a>`에 클릭 핸들러를 하나씩 추가합니다. 브라우저에서 [PushState](https://developer.mozilla.org/en-US/docs/Web/API/History_API)가 지원되는 경우 Turbolinks는 그 페이지를 위한 Ajax 요청을 생성하고, 서버로부터 응답을 분석하여 그 페이지의 `<body>` 전체를 응답의 `<body>`로 교체합니다. 이어서, Turbolinks는 PushState를 사용하여 올바른 URL로 변경하여 새로고침 시맨틱을 유지하며 깨끗한 URL을 유지합니다.

Turbolinks를 활성화하려면 Turbolinks를 Gemfile에 추가하고, JavaScript의 매니페스트(`app/assets/javascripts/application.js`)에 `//= require turbolinks`를 추가합니다.

Turbolinks를 특정 링크에서만 끄고 싶은 경우에는 태그에 `data-turbolinks="false"`를 추가합니다.

```html
<a href="..." data-turbolinks="false">No turbolinks here</a>.
```

### 페이지 변경 이벤트

CoffeeScript 코드로 개발하는 도중, 페이지 로딩과 관련된 처리를 추가하고 싶을 때가 있습니다. jQuery를 사용하고 있다면, 아래와 같은 코드를 작성할 수도 있을 겁니다.

```coffeescript
$(document).ready ->
  alert "page has loaded!"
```

하지만 일반적인 페이지 로딩 프로세스는 Turbolinks에 의해서 덮어써지기 때문에 페이지 로딩에 의존하는 이벤트가 발생하지 않습니다. 이러한 코드가 있는 경우에는 다음과 같이 변경해야합니다.

```coffeescript
$(document).on "turbolinks:load", ->
  alert "page has loaded!"
```

그 외에도 연결 가능한 이벤트 등에 대해서는 [Turbolinks README](https://github.com/turbolinks/turbolinks/blob/master/README.md)를 참조해주세요.

그 외의 리소스
---------------

공부에 도움이 될법한 링크를 몇가지 소개합니다.

* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [jquery-ujs에 대한 글 목록](https://github.com/rails/jquery-ujs/wiki/External-articles)
* [Rails 3 Remote Links와 Forms에 대해서: 결정판 가이드](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [Railscasts: 겸손한 JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks?language=ko&view=asciicast) (한국어)

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
