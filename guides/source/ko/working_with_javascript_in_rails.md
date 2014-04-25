[Working with JavaScript in Rails] 레일스에서 자바스크립트로 작업하기
================================

본 가이드는 레일스의 내장 Ajax/JavaScript 기능(그 이상)을 다룹니다; 당신이 손쉽게 풍부하고 동적인 Ajax 응용프로그램을 작성할 수 있도록 해 줄 것입니다. [[[This guide covers the built-in Ajax/JavaScript functionality of Rails (and
more); it will enable you to create rich and dynamic Ajax applications with
ease!]]]

본 가이드를 읽은 후, 다음의 내용들을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* Ajax의 기초. [[[The basics of Ajax.]]]

* 분리형 자바스크립트(Unobtrusive JavaScript). [[[Unobtrusive JavaScript.]]]

* 어떻게 레일스의 내장 헬퍼가 당신을 돕는가. [[[How Rails' built-in helpers assist you.]]]

* 서버측에서 Ajax를 다루는 법. [[[How to handle Ajax on the server side.]]]

* Turbolinks gem. [[[The Turbolinks gem.]]]

-------------------------------------------------------------------------------

[An Introduction to Ajax] Ajax 소개
------------------------

Ajax를 이해하기 위해, 먼저 웹브라우저가 보통 무엇을 하는지 이해해야 합니다. 웹브라우저의 주소 막대에 `http://localhost:3000`를 입력하고 'Go'를 누르면, 브라우저('클라이언트')는 서버로 요청을 보냅니다. 브라우저는 서버로부터의 응답을 분석하고, 자바스크립트 파일들, 스타일시트들 그리고 이미지들과 같은 연관된 모든 자산들을 불러옵니다. 그리고 나서 페이지들을 조합합니다. 만약 링크를 클릭하면, 브라우저는 같은 절차를 수행합니다. 페이지를 불러오고, 자산들을 불러오고, 그것들을 조합하여 결과를 보여줍니다. 이것을 '요청 응답 주기(request response cycle)'이라 합니다. [[[In order to understand Ajax, you must first understand what a web browser does normally. When you type `http://localhost:3000` into your browser's address bar and hit 'Go,' the browser (your 'client') makes a request to the server. It parses the
response, then fetches all associated assets, like JavaScript files,
stylesheets and images. It then assembles the page. If you click a link, it
does the same process: fetch the page, fetch the assets, put it all together,
show you the results. This is called the 'request response cycle.']]]

자바스크립트도 서버로의 요청을 보내고, 응답을 분석할 수 있습니다. 그리고 페이지에 정보를 업데이트할 수 있습니다. 이 두가지 능력을 조합하여 자바스크립트 작성자는 서버로부터 전체 페이지 데이터를 받아올 필요 없이, 페이지의 일부만을 갱신하는 웹 페이지를 작성할 수 있습니다. 이것이 Ajax라 부르는 강력한 기술입니다. [[[JavaScript can also make requests to the server, and parse the response. It
also has the ability to update information on the page. Combining these two
powers, a JavaScript writer can make a web page that can update just parts of
itself, without needing to get the full page data from the server. This is a
powerful technique that we call Ajax.]]]

레일스는 커피스크립트(CoffeeScript)를 기본으로 탑재하고 있고 본 가이드의 나머지 예제들은 커피스크립트로 만들어질 것입니다. 예제 강좌는 모두 평범한 자바스크립트에도 적용됨은 물론입니다. [[[Rails ships with CoffeeScript by default, and so the rest of the examples
in this guide will be in CoffeeScript. All of these lessons, of course, apply
to vanilla JavaScript as well.]]]

여기 jQuery 라이브러리를 이용하여 Ajax 요청을 만드는 커피스크립트 코드 에제가 있습니다. [[[As an example, here's some CoffeeScript code that makes an Ajax request using
the jQuery library:]]]

```coffeescript
$.ajax(url: "/test").done (html) ->
  $("#results").append html
```

이 코드는 "/test"로부터 데이터를 받아온 후, `results` 아이디를 가진 `div`에 그 결과를 덧붙입니다. [[[This code fetches data from "/test", and then appends the result to the `div`
with an id of `results`.]]]

레일스에는 이 기술을 이용하여 웹페이지를 만드는데 필요한 많은 내장 지원이 있습니다. 당신은 이 코드를 직접 작성할 필요가 거의 없습니다. 이후 본 가이드는 당신이 이 방식으로 웹사이트를 만드는데 레일스가 어떻게 도움을 주는지 보여줄 것입니다. 
하지만 이 모든 것은 매우 간단한 기술 위에 만들어져 있습니다. [[[Rails provides quite a bit of built-in support for building web pages with this
technique. You rarely have to write this code yourself. The rest of this guide
will show you how Rails can help you write websites in this way, but it's
all built on top of this fairly simple technique.]]]

[Unobtrusive JavaScript] 분리형(Unobtrusive) 자바스크립트 
-------------------------------------

레일스는 DOM에 연결된 자바스크립트를 다루기 위해 "분리형 자바스크립트"라 불리는 기술을 사용합니다. 이것은 일반적으로 프론트엔드 커뮤니티에서 모범사례로 간주됩니다. 
하지만 당신은 간혹 다른 방식으로 보여주는 튜토리얼을 볼 수 있습니다. [[[Rails uses a technique called "Unobtrusive JavaScript" to handle attaching
JavaScript to the DOM. This is generally considered to be a best-practice
within the frontend community, but you may occasionally read tutorials that
demonstrate other ways.]]]

여기 자바스크립트를 작성하는 가장 간단한 방법이 있습니다. 이것은 'inline JavaScript'라 불리는 것입니다. [[[Here's the simplest way to write JavaScript. You may see it referred to as
'inline JavaScript':]]]

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```

링크가 클릭될 때, 배경색이 붉은색으로 바뀔 것입니다. 여기 문제가 있습니다. 
클릭했을 때 실행되기를 원하는 자바스크립트가 아주 많이 있다면 어떤 일이 생길까요? [[[When clicked, the link background will become red. Here's the problem: what
happens when we have lots of JavaScript we want to execute on a click?]]]

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';">Paint it green</a>
```

불편하지 않습니까? 우리는 클릭 핸들러 밖으로 함수 정의를 끌어내어 커피스크립트로 바꿀 수 있습니다. [[[Awkward, right? We could pull the function definition out of the click handler,
and turn it into CoffeeScript:]]]

```coffeescript
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor
```

이렇게 하면 페이지는 다음과 같이 됩니다. [[[And then on our page:]]]

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
```

좀 더 나아졌습니다만, 같은 효과를 가진 여러 링크가 있다면 어떻게 될까요? [[[That's a little bit better, but what about multiple links that have the same
effect?]]]

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(this, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(this, '#000099', '#FFFFFF')">Paint it blue</a>
```

그닥 DRY하지 않지요? 우리는 이벤트를 이용하여 이 문제를 해결할 수 있습니다. 우리는 링크에 `data-*` 속성을 추가하고 이 속성을 가진 모든 링크의 클릭 이벤트에 핸들러를 연결할 것입니다. [[[Not very DRY, eh? We can fix this by using events instead. We'll add a `data-*`
attribute to our link, and then bind a handler to the click event of every link
that has that attribute:]]]

```coffeescript
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

$ ->
  $("a[data-background-color]").click ->
    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
```
```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

우리는 이것을 '분리형' 자바스크립트라고 부릅니다. 더이상 자바스크립트를 HTML 안에 섞지 않기 때문입니다. 우리는 앞으로 있을 변경을 쉽게 하기 위해 적절하게 우리 고려사항을 분리했습니다. 우리는 data 속성을 추가하는 것만으로 어떤 링크에든 손쉽게 동작을 추가할 수 있습니다. 우리는 미니마이저와 연결연산자를 통해 모든 우리의 자바스크립트를 실행할 수 있습니다. 우리는 전체 자바스크립트 묶음을 모든 페이지에 제공할 수 있는데, 이는 전체 자바스크립트가 첫 번째 페이지 로드할 때 다운로드되고,
이후 모든 페이지에서 캐시됨을 뜻합니다. [[[We call this 'unobtrusive' JavaScript because we're no longer mixing our
JavaScript into our HTML. We've properly separated our concerns, making future
change easy. We can easily add behavior to any link by adding the data
attribute. We can run all of our JavaScript through a minimizer and
concatenator. We can serve our entire JavaScript bundle on every page, which
means that it'll get downloaded on the first page load and then be cached on
every page after that.]]] 수많은 작은 혜택들이 늘어날 것입니다. [[[Lots of little benefits really add up.]]]

레일스 팀은 이런 스타일로 당신의 커피스크립트(자바스크립트 역시)를 작성할 것을 강력 권장합니다. 
그리고 많은 라이브러리들이 이 패턴을 따를 것을 당신은 기대할 수 있습니다. [[[The Rails team strongly encourages you to write your CoffeeScript (and
JavaScript) in this style, and you can expect that many libraries will also
follow this pattern.]]]

[Built-in Helpers] 내장 헬퍼들
----------------------

레일스는 HTML을 생성함에 있어 당신을 돕기 위해 루비로 작성된 많은 뷰 헬퍼 메서드를 갖고 있습니다. 간혹 당신은 요소들에 약간의 Ajax를 추가하기를 원하고, 그러한 경우 레일스는 당신을 도와줄 것입니다. [[[Rails provides a bunch of view helper methods written in Ruby to assist you
in generating HTML. Sometimes, you want to add a little Ajax to those elements,
and Rails has got your back in those cases.]]]

분리형 자바스크립트 때문에, 레일스의 "Ajax Helpers"는 사실 두 부분으로 되어 있습니다. 자바스크립트 부분과 루비 부분입니다. [[[Because of Unobtrusive JavaScript, the Rails "Ajax helpers" are actually in two
parts: the JavaScript half and the Ruby half.]]]

[rails.js](https://github.com/rails/jquery-ujs/blob/master/src/rails.js)는 자바스크립트 부분을 제공하고,
표준 루비 뷰 헬퍼는 적절한 태그를 당신의 DOM에 추가합니다. rails.js 안의 CoffeeScript는 이들 속성을 수신하고 적절한 핸들러를 연결합니다. [[[[rails.js](https://github.com/rails/jquery-ujs/blob/master/src/rails.js)
provides the JavaScript half, and the regular Ruby view helpers add appropriate
tags to your DOM. The CoffeeScript in rails.js then listens for these
attributes, and attaches appropriate handlers.]]]

### form_for

[`form_for`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)는 form을 작성하는 것을 도와주는 헬퍼입니다. `form_for`는 `:remote` 옵션을 가집니다. [[[[`form_for`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)
is a helper that assists with writing forms. `form_for` takes a `:remote`
option.]]] 이것은 다음과 같이 작동합니다. [[[It works like this:]]]

```erb
<%= form_for(@post, remote: true) do |f| %>
  ...
<% end %>
```

이 코드는 다음과 같은 HTML을 생성합니다. [[[This will generate the following HTML:]]]

```html
<form accept-charset="UTF-8" action="/posts" class="new_post" data-remote="true" id="new_post" method="post">
  ...
</form>
```

`data-remote='true'` 부분을 참고하십시오. [[[Note the `data-remote='true'`.]]] 이제 폼은 브라우저의 일반적은 전송 메커니즘 대신 Ajax에 의해 전송될 것입니다. [[[Now, the form will be submitted by Ajax rather
than by the browser's normal submit mechanism.]]]

하지만 어쩌면 당신은 완성된 `<form>`을 앉아서 구경만 하고 싶지 않을지 모릅니다. 당신은 전송 성공시 뭔가를 하고 싶을 수 있습니다. 그렇게 하려면 `ajax:success` 이벤트를 연결하십시오. 실패시에는 `ajax:error`를 사용하십시오. 다음을 확인해 보십시오.[[[You probably don't want to just sit there with a filled out `<form>`, though. You probably want to do something upon a successful submission. To do that,
bind to the `ajax:success` event. On failure, use `ajax:error`. Check it out:]]]

```coffeescript
$(document).ready ->
  $("#new_post").on("ajax:success", (e, data, status, xhr) ->
    $("#new_post").append xhr.responseText
  ).bind "ajax:error", (e, xhr, status, error) ->
    $("#new_post").append "<p>ERROR</p>"
```

분명 당신은 그보다 좀더 정교해지기를 원할 것입니다. 그러나 이것이 시작입니다. [[[Obviously, you'll want to be a bit more sophisticated than that, but it's a
start.]]]

### form_tag

[`form_tag`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)는 `form_for`와 아주 유사합니다. 이는 `:remote` 옵션을 가지고 있는데, 이것은 다음과 같이 사용할 수 있습니다. [[[[`form_tag`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)
is very similar to `form_for`. It has a `:remote` option that you can use like
this:]]]

```erb
<%= form_tag('/posts', remote: true) %>
```

다른 것들은 `form_for`와 같습니다. [[[Everything else is the same as `form_for`.]]] 세부사항 확인을 위해서는 문서를 확인하십시오. [[[See its documentation for full
details.]]]

### link_to

[`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)는 링크를 생성하는 것을 돕는 헬퍼입니다. 이것은 `:remote` 옵션을 가지고 있는데, 다음과 같이 사용할 수 있습니다. [[[[`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
is a helper that assists with generating links. It has a `:remote` option you
can use like this:]]]

```erb
<%= link_to "a post", @post, remote: true %>
```

이것은 다음 코드를 생성합니다. [[[which generates]]]

```html
<a href="/posts/1" data-remote="true">a post</a>
```

당신은 `form_for`에서와 같은 Ajax 이벤트를 연결할 수 있습니다. 여기 예제가 있습니다. 단 한번의 클릭으로 삭제될 수 있는 포스트의 목록이 있다고 가정해 봅시다. 다음과 같이 HTML을 생성합니다. [[[You can bind to the same Ajax events as `form_for`. Here's an example. Let's
assume that we have a list of posts that can be deleted with just one
click. We would generate some HTML like this:]]]

```erb
<%= link_to "Delete post", @post, remote: true, method: :delete %>
```

그리고 약간의 커피스크립트를 다음과 같이 작성합니다. [[[and write some CoffeeScript like this:]]]

```coffeescript
$ ->
  $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    alert "The post was deleted."
```

### button_to

[`button_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)는 버튼을 생성하는 것을 돕는 헬퍼입니다.
이것은 `:remote` 옵션을 갖고 있으며 다음과 같이 호출할 수 있습니다. [[[[`button_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) is a helper that helps you create buttons. It has a `:remote` option that you can call like this:]]]

```erb
<%= button_to "A post", @post, remote: true %>
```

이것은 다음 코드를 생성합니다. [[[this generates]]]

```html
<form action="/posts/1" class="button_to" data-remote="true" method="post">
  <div><input type="submit" value="A post"></div>
</form>
```

이것은 단지 `<form>`이기 때문에, `form_for`에 있는 모든 정보 역시 적용됩니다. [[[Since it's just a `<form>`, all of the information on `form_for` also applies.]]]

[Server-Side Concerns] 서버측 고려사항들
--------------------

Ajax는 단지 클라이언트측 코드가 아닙니다. 당신은 Ajax를 지원하기 위해 서버측에도 몇 가지 작업을 해야 합니다. 사람들은 간혹 Ajax 요청을 하면서 HTML보다는 JSON을 돌려받기를 원합니다. 그렇게 하기 위해 필요한 것을 논의해 보겠습니다. [[[Ajax isn't just client-side, you also need to do some work on the server
side to support it. Often, people like their Ajax requests to return JSON
rather than HTML. Let's discuss what it takes to make that happen.]]]

### [A Simple Example] 간단한 예제

당신이 보여주고자 하는 일련의 사용자 목록을 갖고 있으며 같은 페이지에서 새로운 사용자를 만드는 폼을 제공한다고 해 보겠습니다. 당신의 컨트롤러의 인덱스 액션은 다음과 같을 것입니다. [[[magine you have a series of users that you would like to display and provide a
form on that same page to create a new user. The index action of your
controller looks like this:]]]

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

인덱스 뷰 (`app/views/users/index.html.erb`)는 다음 내용을 포함합니다. [[[The index view (`app/views/users/index.html.erb`) contains:]]]

```erb
<b>Users</b>

<ul id="users">
<% @users.each do |user| %>
  <%= render user %>
<% end %>
</ul>

<br>

<%= form_for(@user, remote: true) do |f| %>
  <%= f.label :name %><br>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

`app/views/users/_user.html.erb` 파셜은 다음 내용을 포함합니다. [[[The `app/views/users/_user.html.erb` partial contains the following:]]]

```erb
<li><%= user.name %></li>
```

인덱스 페이지의 상단 부분은 사용자를 표시합니다. 하단 부분은 새로운 사용자를 생성하는 폼을 제공합니다. [[[The top portion of the index page displays the users. The bottom portion
provides a form to create a new user.]]]

하단 폼은 Users 컨트롤러에 있는 create 액션을 호출할 것입니다. 폼의 remote 옵션이 true로 되어 있기 때문에, 요청은 자바스크립트를 찾아 Ajax 요청으로 사용자 컨트롤러에 전송될 것입니다. 그 요청을 처리하기 위한 컨트롤러의 create 액션은 다음과 같을 것입니다. [[[The bottom form will call the create action on the Users controller. Because
the form's remote option is set to true, the request will be posted to the
users controller as an Ajax request, looking for JavaScript. In order to
service that request, the create action of your controller would look like
this:]]]

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

`respond_to` 블록에 있는 format.js를 주목하십시오. 이것은 컨트롤러가 당신의 Ajax 요청에 응답할 수 있도록 합니다. 다음으로 그에 상응하는 뷰파일 `app/views/users/create.js.erb`이 있는데, 이것은 클라이언트측에 전송되고 실행될 실제 자바스크립트 코드를 생성합니다. [[[Notice the format.js in the `respond_to` block; that allows the controller to
respond to your Ajax request. You then have a corresponding
`app/views/users/create.js.erb` view file that generates the actual JavaScript
code that will be sent and executed on the client side.]]]

```erb
$("<%= escape_javascript(render @user) %>").appendTo("#users");
```

Turbolinks
----------

레일스 4는 [Turbolinks gem](https://github.com/rails/turbolinks)를 포함하여 배포됩니다.
이 젬은 대부분의 응용프로그램에서 페이지 렌더링 속도를 높이기 위해 Ajax를 사용합니다.
[[[Rails 4 ships with the [Turbolinks gem](https://github.com/rails/turbolinks).
This gem uses Ajax to speed up page rendering in most applications.]]]

### [How Turbolinks Works] Turbolinks는 어떻게 작동하는가

Turbolinks는 페이지에 있는 모든 `<a>`에 클릭 핸들러를 연결합니다. 만약 당신의 브라우저가 [PushState](https://developer.mozilla.org/en-US/docs/DOM/Manipulating_the_browser_history#The_pushState(\).C2.A0method)를 지원하는 것이라면,
Turbolinks는 Ajax 요청을 만들고, 응답을 분석하고, 응답에 있는 `<body>` 내용으로 페이지상의 `<body>` 전체를 바꿔줍니다. 그 다음으로, PushState를 이용하여 URL을 올바른 것으로 변경하는데, 이는 새로고침 의미를 유지하고 예쁜 URL을 제공하기 위함입니다. [[[Turbolinks attaches a click handler to all `<a>` on the page. If your browser
supports
[PushState](https://developer.mozilla.org/en-US/docs/DOM/Manipulating_the_browser_history#The_pushState(\).C2.A0method),
Turbolinks will make an Ajax request for the page, parse the response, and
replace the entire `<body>` of the page with the `<body>` of the response. It
will then use PushState to change the URL to the correct one, preserving
refresh semantics and giving you pretty URLs.]]]

Turbolinks를 사용하기 위해 해야할 일은 당신의 Gemfile에 Turbolinks를 포함하고, 커피스크립트 manifest에 `//= require turbolinks`를 넣는 것입니다.
커피스크립트 manifest는 보통 `app/assets/javascripts/application.js` 안에 있습니다. [[[The only thing you have to do to enable Turbolinks is have it in your Gemfile,
and put `//= require turbolinks` in your CoffeeScript manifest, which is usually
`app/assets/javascripts/application.js`.
]]]

만약 특정 링크에 Turbolinks 지원을 하지 않으려면 태그의 속성에 `data-no-turbolink`를 추가하십시오. [[[If you want to disable Turbolinks for certain links, add a `data-no-turbolink`
attribute to the tag:]]]

```html
<a href="..." data-no-turbolink>No turbolinks here</a>.
```

### [Page Change Events] 페이지 변경 이벤트

커피스크립트를 작성할 때, 페이지 로드시 몇 가지 절차를 수행하고 싶을 때가 있습니다. jQuery로 다음과 같은 코드를 작성할 수 있습니다. [[[When writing CoffeeScript, you'll often want to do some sort of processing upon
page load. With jQuery, you'd write something like this:]]]

```coffeescript
$(document).ready ->
  alert "page has loaded!"
```

하지만, Turbolinks는 일반적인 페이지의 로딩 절차를 오버라이드하기 때문에 이에 의존하는 이벤트가 발생하지 않을 것입니다. 만일 그러한 코드가 있면, 아래와 같이 코드를 변경해야 합니다. [[[However, because Turbolinks overrides the normal page loading process, the
event that this relies on will not be fired. If you have code that looks like
this, you must change your code to do this instead:]]]

```coffeescript
$(document).on "page:change", ->
  alert "page has loaded!"
```

연결하고자 하는 다른 이벤트들을 포함한 보다 상세한 내용은 [the Turbolinks README](https://github.com/rails/turbolinks/blob/master/README.md)를 참고하십시오. [[[For more details, including other events you can bind to, check out [the
Turbolinks
README](https://github.com/rails/turbolinks/blob/master/README.md).]]]

[Other Resources] 기타 리소스
---------------

여기 더 많은 내용 학습에 유용한 링크들이 있습니다. [[[Here are some helpful links to help you learn even more:]]]

* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [jquery-ujs list of external articles](https://github.com/rails/jquery-ujs/wiki/External-articles)
* [Rails 3 Remote Links and Forms: A Definitive Guide](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)