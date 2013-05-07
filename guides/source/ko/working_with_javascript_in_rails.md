Working with JavaScript in Rails
================================

레일스에서 자바스크립트로 작업하기
================================

This guide covers the built-in Ajax/JavaScript functionality of Rails (and
more); it will enable you to create rich and dynamic Ajax applications with
ease!

본 가이드는 레일스의 내장 Ajax/JavaScript 기능(그리고 그 이상)을 다룹니다; 당신이 손쉽게 풍부하고 동적인 Ajax 응용프로그램을 작성할 수 있도록 해 줄 것입니다.

After reading this guide, you will know:

본 가이드를 읽은 후, 당신을 아래 내용들을 알게 될 것입니다.

* The basics of Ajax.
* Unobtrusive JavaScript.
* How Rails' built-in helpers assist you.
* How to handle Ajax on the server side.
* The Turbolinks gem.

* Ajax의 기초.
* 겸손한 자바스크립트(Unobtrusive JavaScript).
* 레일스의 내장 헬퍼가 당신을 돕는 방식.
* 서버측에서 Ajax를 다루는 법.
* Turbolinks gem.

-------------------------------------------------------------------------------

An Introduction to Ajax
------------------------

-------------------------------------------------------------------------------

Ajax 소개
------------------------

In order to understand Ajax, you must first understand what a web browser does
normally.

Ajax를 이해하기 위해, 먼저 웹브라우저가 보통 무엇을 하는지 이해해야 합니다.

When you type `http://localhost:3000` into your browser's address bar and hit
'Go,' the browser (your 'client') makes a request to the server. It parses the
response, then fetches all associated assets, like JavaScript files,
stylesheets and images. It then assembles the page. If you click a link, it
does the same process: fetch the page, fetch the assets, put it all together,
show you the results. This is called the 'request response cycle.'

당신이 웹브라우저의 주소 막대에 `http://localhost:3000`를 입력하고 'Go'를 누르면, 브라우저는 서버로 보낼 요청을 만듭니다.
브라우저는 서버로부터의 응답을 분석하고, 자바스크립트 파일들, 스타일시트들 그리고 이미지들과 같은 연관된 모든 자산들을 불러옵니다.
그리고 나서 페이지들을 조합합니다. 만약 당신이 링크를 클릭하면, 브라우저는 같은 절차를 수행합니다. 
페이지를 불러오고, 자산들을 불러오고, 그것들을 조합하여 당신에게 결과를 보여줍니다.
이것을 '요청 응답 순환(Cycle)'이라 합니다.

JavaScript can also make requests to the server, and parse the response. It
also has the ability to update information on the page. Combining these two
powers, a JavaScript writer can make a web page that can update just parts of
itself, without needing to get the full page data from the server. This is a
powerful technique that we call Ajax.

자바스크립트도 서버로의 요청을 만들고, 응답을 분석할 수 있습니다. 그리고 페이지에 정보를 업데이트할 수 있습니다.
이 두가지 능력을 조합하여 자바스크립트 작성자는 서버로부터 전체 페이지 데이터를 받아올 필요 없이, 
단지 페이지의 일부만을 갱신하는 웹 페이지를 작성할 수 있습니다.
이것이 우리가 Ajax라 부르는 강력한 기술입니다.

Rails ships with CoffeeScript by default, and so the rest of the examples
in this guide will be in CoffeeScript. All of these lessons, of course, apply
to vanilla JavaScript as well.

레일스는 커피스크립트(CoffeeScript)를 기본으로 탑재하고 있고 본 가이드에 있는 예제들은 커피스크립트로 만들어질 것입니다.
예제 강좌 전부는 평범한 자바스크립트에도 물론 적용됩니다.

As an example, here's some CoffeeScript code that makes an Ajax request using
the jQuery library:

여기 jQuery 라이브러리를 이용하여 Ajax 요청을 만드는 커피스크립트 코드 에제가 있습니다.

```coffeescript
$.ajax(url: "/test").done (html) ->
  $("#results").append html
```

This code fetches data from "/test", and then appends the result to the `div`
with an id of `results`.

이 코드는 "/test"로부터 데이터를 받아온 후, `results` 아이디를 가진 `div`에 그 결과를 덧붙입니다.

Rails provides quite a bit of built-in support for building web pages with this
technique. You rarely have to write this code yourself. The rest of this guide
will show you how Rails can help you write websites in this way, but it's
all built on top of this fairly simple technique.

Unobtrusive JavaScript
-------------------------------------

Rails uses a technique called "Unobtrusive JavaScript" to handle attaching
JavaScript to the DOM. This is generally considered to be a best-practice
within the frontend community, but you may occasionally read tutorials that
demonstrate other ways.

Here's the simplest way to write JavaScript. You may see it referred to as
'inline JavaScript':

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```
When clicked, the link background will become red. Here's the problem: what
happens when we have lots of JavaScript we want to execute on a click?

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';">Paint it green</a>
```

Awkward, right? We could pull the function definition out of the click handler,
and turn it into CoffeeScript:

```coffeescript
paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor
```

And then on our page:

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
```

That's a little bit better, but what about multiple links that have the same
effect?

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(this, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(this, '#000099', '#FFFFFF')">Paint it blue</a>
```

Not very DRY, eh? We can fix this by using events instead. We'll add a `data-*`
attribute to our link, and then bind a handler to the click event of every link
that has that attribute:

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

We call this 'unobtrusive' JavaScript because we're no longer mixing our
JavaScript into our HTML. We've properly separated our concerns, making future
change easy. We can easily add behavior to any link by adding the data
attribute. We can run all of our JavaScript through a minimizer and
concatenator. We can serve our entire JavaScript bundle on every page, which
means that it'll get downloaded on the first page load and then be cached on
every page after that. Lots of little benefits really add up.

The Rails team strongly encourages you to write your CoffeeScript (and
JavaScript) in this style, and you can expect that many libraries will also
follow this pattern.

Built-in Helpers
----------------------

Rails provides a bunch of view helper methods written in Ruby to assist you
in generating HTML. Sometimes, you want to add a little Ajax to those elements,
and Rails has got your back in those cases.

Because of Unobtrusive JavaScript, the Rails "Ajax helpers" are actually in two
parts: the JavaScript half and the Ruby half.

[rails.js](https://github.com/rails/jquery-ujs/blob/master/src/rails.js)
provides the JavaScript half, and the regular Ruby view helpers add appropriate
tags to your DOM. The CoffeeScript in rails.js then listens for these
attributes, and attaches appropriate handlers.

### form_for

[`form_for`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)
is a helper that assists with writing forms. `form_for` takes a `:remote`
option. It works like this:

```erb
<%= form_for(@post, remote: true) do |f| %>
  ...
<% end %>
```

This will generate the following HTML:

```html
<form accept-charset="UTF-8" action="/posts" class="new_post" data-remote="true" id="new_post" method="post">
  ...
</form>
```

Note the `data-remote='true'`. Now, the form will be submitted by Ajax rather
than by the browser's normal submit mechanism.

You probably don't want to just sit there with a filled out `<form>`, though.
You probably want to do something upon a successful submission. To do that,
bind to the `ajax:success` event. On failure, use `ajax:error`. Check it out:

```coffeescript
$(document).ready ->
  $("#new_post").on("ajax:success", (e, data, status, xhr) ->
    $("#new_post").append xhr.responseText
  ).bind "ajax:error", (e, xhr, status, error) ->
    $("#new_post").append "<p>ERROR</p>"
```

Obviously, you'll want to be a bit more sophisticated than that, but it's a
start.

### form_tag

[`form_tag`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)
is very similar to `form_for`. It has a `:remote` option that you can use like
this:

```erb
<%= form_tag('/posts', remote: true) %>
```

Everything else is the same as `form_for`. See its documentation for full
details.

### link_to

[`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
is a helper that assists with generating links. It has a `:remote` option you
can use like this:

```erb
<%= link_to "a post", @post, remote: true %>
```

which generates

```html
<a href="/posts/1" data-remote="true">a post</a>
```

You can bind to the same Ajax events as `form_for`. Here's an example. Let's
assume that we have a list of posts that can be deleted with just one
click. We would generate some HTML like this:

```erb
<%= link_to "Delete post", @post, remote: true, method: :delete %>
```

and write some CoffeeScript like this:

```coffeescript
$ ->
  $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
    alert "The post was deleted."
```

### button_to

[`button_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) is a helper that helps you create buttons. It has a `:remote` option that you can call like this:

```erb
<%= button_to "A post", @post, remote: true %>
```

this generates

```html
<form action="/posts/1" class="button_to" data-remote="true" method="post">
  <div><input type="submit" value="A post"></div>
</form>
```

Since it's just a `<form>`, all of the information on `form_for` also applies.

Server-Side Concerns
--------------------

Ajax isn't just client-side, you also need to do some work on the server
side to support it. Often, people like their Ajax requests to return JSON
rather than HTML. Let's discuss what it takes to make that happen.

### A Simple Example

Imagine you have a series of users that you would like to display and provide a
form on that same page to create a new user. The index action of your
controller looks like this:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

The index view (`app/views/users/index.html.erb`) contains:

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

The `app/views/users/_user.html.erb` partial contains the following:

```erb
<li><%= user.name %></li>
```

The top portion of the index page displays the users. The bottom portion
provides a form to create a new user.

The bottom form will call the create action on the Users controller. Because
the form's remote option is set to true, the request will be posted to the
users controller as an Ajax request, looking for JavaScript. In order to
service that request, the create action of your controller would look like
this:

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

Notice the format.js in the `respond_to` block; that allows the controller to
respond to your Ajax request. You then have a corresponding
`app/views/users/create.js.erb` view file that generates the actual JavaScript
code that will be sent and executed on the client side.

```erb
$("<%= escape_javascript(render @user) %>").appendTo("#users");
```

Turbolinks
----------

Rails 4 ships with the [Turbolinks gem](https://github.com/rails/turbolinks).
This gem uses Ajax to speed up page rendering in most applications.

### How Turbolinks Works

Turbolinks attaches a click handler to all `<a>` on the page. If your browser
supports
[PushState](https://developer.mozilla.org/en-US/docs/DOM/Manipulating_the_browser_history#The_pushState(\).C2.A0method),
Turbolinks will make an Ajax request for the page, parse the response, and
replace the entire `<body>` of the page with the `<body>` of the response. It
will then use PushState to change the URL to the correct one, preserving
refresh semantics and giving you pretty URLs.

The only thing you have to do to enable Turbolinks is have it in your Gemfile,
and put `//= require turbolinks` in your CoffeeScript manifest, which is usually
`app/assets/javascripts/application.js`.

If you want to disable Turbolinks for certain links, add a `data-no-turbolink`
attribute to the tag:

```html
<a href="..." data-no-turbolink>No turbolinks here</a>.
```

### Page Change Events

When writing CoffeeScript, you'll often want to do some sort of processing upon
page load. With jQuery, you'd write something like this:

```coffeescript
$(document).ready ->
  alert "page has loaded!"
```

However, because Turbolinks overrides the normal page loading process, the
event that this relies on will not be fired. If you have code that looks like
this, you must change your code to do this instead:

```coffeescript
$(document).on "page:change", ->
  alert "page has loaded!"
```

For more details, including other events you can bind to, check out [the
Turbolinks
README](https://github.com/rails/turbolinks/blob/master/README.md).

Other Resources
---------------

Here are some helpful links to help you learn even more:

* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [jquery-ujs list of external articles](https://github.com/rails/jquery-ujs/wiki/External-articles)
* [Rails 3 Remote Links and Forms: A Definitive Guide](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)