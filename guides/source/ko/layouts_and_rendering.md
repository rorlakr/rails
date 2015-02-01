[Layouts and Rendering in Rails] 레일스의 레이아웃과 렌더링
==============================

본 가이드에서는 액션 컨트롤러와 액션 뷰의 기본 레이아웃 기능을 다루게 됩니다. [[[This guide covers the basic layout features of Action Controller and Action View.]]]

본 가이드를 읽고나면 다음의 내용들을 이해할 수 있습니다: [[[After reading this guide, you will know:]]]

* 레일스에 내장된 다양한 렌더링 메소드 사용법 [[[How to use the various rendering methods built into Rails.]]]

* 다중 컨텐츠 섹션을 위한 레이아웃 생성 [[[How to create layouts with multiple content sections.]]]

* 반복작업을 하지 않기 위한 partial 사용법 [[[How to use partials to DRY up your views.]]]

* 중첩 레이아웃(서브 레이아웃) 사용법 [[[How to use nested layouts (sub-templates).]]]

--------------------------------------------------------------------------------

[Overview: How the Pieces Fit Together] 개요: 조각이 하나로 합쳐지는 방법
-------------------------------------

본 가이드에서는 모델-뷰-컨트롤러 삼각구조에서 컨트롤러와 뷰의 상호작용에 대해 초점을 맞추고 있습니다. 일반적으로 많은 코드가 모델에 집중되어 있지만 레일스에서 컨트롤러는 요청에 대한 전체를 지휘하는 역할을 합니다. 하지만 응답을 유저에게 보내야하는 상황에서, 컨트롤러는 권한을 뷰에 넘겨주게 됩니다. 본가이드의 주제는 바로 이부분의 권한 이전에 대한것입니다. [[[This guide focuses on the interaction between Controller and View in the Model-View-Controller triangle. As you know, the Controller is responsible for orchestrating the whole process of handling a request in Rails, though it normally hands off any heavy code to the Model. But then, when it's time to send a response back to the user, the Controller hands things off to the View. It's that handoff that is the subject of this guide.]]]

이는 응답으로 보낼것과 응답을 만들기 위한 적절한 메소드 호출을 결정하는것을 포함합니다. 응답이 완전한 뷰인 경우, 레일스는 어떤 추가적인 작업을 실행하여 뷰를 레이아웃으로 감싸고 가능한경우 partial 뷰를 이용하게 됩니다. 이 모든 것을 본 가이드에게 알게 될 것입니다. [[[In broad strokes, this involves deciding what should be sent as the response and calling an appropriate method to create that response. If the response is a full-blown view, Rails also does some extra work to wrap the view in a layout and possibly to pull in partial views. You'll see all of those paths later in this guide.]]]

[Creating Responses] 응답 만들기
------------------

컨트롤러의 관점에서 뷰를 보면 3가지 방법으로 HTTP 응답을 만들수 있습니다: [[[From the controller's point of view, there are three ways to create an HTTP response:]]]

* `render`를 호출하여 전체 응답을 만들고 브라우저에 보내기 [[[Call `render` to create a full response to send back to the browser]]]

* `redirect_to`를 호출하여 HTTP redirect 상태코드를 브라우저로 보내기 [[[Call `redirect_to` to send an HTTP redirect status code to the browser]]]

* `head`를 호출하여 HTTP 헤더만으로 이루어진 응답을 만들고 브라우저로 보내기 [[[Call `head` to create a response consisting solely of HTTP headers to send back to the browser]]]

### [[[Rendering by Default: Convention Over Configuration in Action]]] 기본 렌더링: 액션에서의 설정보다 관례

레일스의 "설정보다 관례"에 대해서 들어본적이 있을것입니다. 기본 렌더링은 이에 대한 좋은예 입니다. 레일스의 컨트롤러는 라우트의 이름으로 자동으로 뷰를 렌더딩합니다. 예를들어 `BooksController` 클래스에 다음과 같은 코드가 있는경우: [[[You've heard that Rails promotes "convention over configuration". Default rendering is an excellent example of this. By default, controllers in Rails automatically render views with names that correspond to valid routes. For example, if you have this code in your `BooksController` class:]]]

```ruby
class BooksController < ApplicationController
end
```

그리고 라우트 파일에 다음과 같은경우:[[And the following in your routes file:]]

```ruby
resources :books
```

그리고 `app/views/books/index.html.erb` 뷰 파일을 가지고 있다면 [[[And you have a view file `app/views/books/index.html.erb`:]]]

```html+erb
<h1>Books are coming soon!</h1>
```

이 상태에서 `/books` 를 탐색하는경우 레일스는 자동으로 `app/views/books/index.html.erb` 를 랜더딩해서 "Books are coming soon!" 메시지가 화면에 보이게 됩니다. [[[Rails will automatically render `app/views/books/index.html.erb` when you navigate to `/books` and you will see "Books are coming soon!" on your screen.]]]

coming soon 화면은 별 정보가 없어서 유용하지 않으므로 `Book` 모델을 만들고 `BooksController`에 index 액션을 추가하겠습니다: [[[However a coming soon screen is only minimally useful, so you will soon create your `Book` model and add the index action to `BooksController`:]]]

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

여기서 우리는 "설정보다 관례"에 의해 index 액션의 마지막에 render 를 명시하지 않았습니다. 이 규칙은 컨트롤러의 액션 마지막에 명시적인 render가 없는 경우, 레일스는 자동으로 컨트롤러의 뷰 경로에서 `action_name.html.erb` 템플릿파일을 탐색하고 렌더링합니다. 그래서 이 경우 레일스는 `app/views/books/index.html.erb` 파일을 렌더링합니다.  [[[Note that we don't have explicit render at the end of the index action in accordance with "convention over configuration" principle. The rule is that if you do not explicitly render something at the end of a controller action, Rails will automatically look for the `action_name.html.erb` template in the controller's view path and render it. So in this case, Rails will render the `app/views/books/index.html.erb` file.]]]

만약 뷰에서 책의 정보를 보여주고 싶다면, ERB 템플릿을 다음과 같이 작성할 수 있습니다. [[[If we want to display the properties of all the books in our view, we can do so with an ERB template like this:]]]

```html+erb
<h1>Listing Books</h1>

<table>
  <tr>
    <th>Title</th>
    <th>Summary</th>
    <th></th>
    <th></th>
    <th></th>
  </tr>

<% @books.each do |book| %>
  <tr>
    <td><%= book.title %></td>
    <td><%= book.content %></td>
    <td><%= link_to "Show", book %></td>
    <td><%= link_to "Edit", edit_book_path(book) %></td>
    <td><%= link_to "Remove", book, method: :delete, data: { confirm: "Are you sure?" } %></td>
  </tr>
<% end %>
</table>

<br />

<%= link_to "New book", new_book_path %>
```

NOTE: 실제 렌더링 작업은 `ActionsView::TemplateHandlers` 가 하게 됩니다. 본 가이드에서는 이 과정을 깊숙이 다루지 않을 것이지만, 뷰 파일의 확장자에 따라 템플릿 핸들러가 결정 된다는 것을 아는 것이 중요합니다. 레일스 2 부터  ERB(루비 코드가 포함된 HTML)에 대한 표준 확장자는 .erb 이고 Builder(XML 생성기)에 대한 확장자는 `.builder` 입니다. [[[The actual rendering is done by subclasses of `ActionView::TemplateHandlers`. This guide does not dig into that process, but it's important to know that the file extension on your view controls the choice of template handler. Beginning with Rails 2, the standard extensions are `.erb` for ERB (HTML with embedded Ruby), and `.builder` for Builder (XML generator).]]]

### [Using `render`] `render` 사용

대부분의 경우 `ActionController::Base#render` 메소드는 브라우저에 보여 줄 어플리케이션의 내용물을 렌더링하는 힘든 작업을 하게 됩니다. 이러한 `render` 메소드의 작업을 변경하는 방법에는 여러가지가 있습니다. 레일스 템플릿의 디폴트 뷰, 특정 템플릿, 파일, 인라인 코드, 빈내용을 렌더링할 수 있다는 것입니다. 문자열, JSON, XML 포맷으로 렌더링할 수 있습니다. 또한 렌더링되는 응답의 종류나 HTTP 상태를 명시할 수 있습니다. [[[In most cases, the `ActionController::Base#render` method does the heavy lifting of rendering your application's content for use by a browser. There are a variety of ways to customize the behavior of `render`. You can render the default view for a Rails template, or a specific template, or a file, or inline code, or nothing at all. You can render text, JSON, or XML. You can specify the content type or HTTP status of the rendered response as well.]]]

TIP: `render` 호출에 대한 정확한 결과를 브라우저에서 조사(개발자도구)를 통하지 않고 보기를 원한다면, `render_to_string` 를 사용할 수 있습니다. 이 메소드는 `render`와 동일한 옵션을 가지지만 응답내용을 브라우저가 아닌 문자열로 반환합니다. [[[If you want to see the exact results of a call to `render` without needing to inspect it in a browser, you can call `render_to_string`. This method takes exactly the same options as `render`, but it returns a string instead of sending a response back to the browser.]]]

#### [[[Rendering Nothing]]] 아무것도 렌더링하지 않

`render`로 할 수 있는 가장 간단한 작업은 아마도 아무것도 렌더링하지 않는것입니다:[[[Perhaps the simplest thing you can do with `render` is to render nothing at all:]]]

```ruby
render nothing: true
```

cURL 명렁어를 이용해 응답을 살펴보면 다음과 같습니다: [[[If you look at the response for this using cURL, you will see the following:]]]

```bash
$ curl -i 127.0.0.1:3000/books
HTTP/1.1 200 OK
Connection: close
Date: Sun, 24 Jan 2010 09:25:18 GMT
Transfer-Encoding: chunked
Content-Type: */*; charset=utf-8
X-Runtime: 0.014297
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache


 $
```

비어있는 응답을 보게 되는데(`Cache-Control` 줄 다음에 아무데이터 없음), 요청은 레일스에서 200 OK 응답을 설정했기 때문에 성공적으로 완료됩니다. `:status` 옵션을 이용해 이 응답을 변경할수 있습니다. 아무것도 렌더링하지 않는것은 Ajax 요청에서 브라우저에게 요청이 완료되었음만을 알려줄때 유용합니다. [[[We see there is an empty response (no data after the `Cache-Control` line), but the request was successful because Rails has set the response to 200 OK. You can set the `:status` option on render to change this response. Rendering nothing can be useful for Ajax requests where all you want to send back to the browser is an acknowledgment that the request was completed.]]]

TIP: `render :nothing` 보다는 본 가이드에서 언급할 `head` 메소드를 이용하는것이 좋습니다. 이는 유연성과 헤더만 생성한다는것을 명시적으로 나타냅니다. [[[You should probably be using the `head` method, discussed later in this guide, instead of `render :nothing`. This provides additional flexibility and makes it explicit that you're only generating HTTP headers.]]]

#### [Rendering an Action's View] 액션 뷰 렌더링하기

동일한 컨트롤러에서 다른 템플릿 뷰를 렌더링하고자 한다면, `render`를 뷰 이름과 함께 사용합니다: [[[If you want to render the view that corresponds to a different template within the same controller, you can use `render` with the name of the view:]]]

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(params[:book])
    redirect_to(@book)
  else
    render "edit"
  end
end
```

`update` 메소드가 실패한다면, `update` 액션은 동일 컨트롤러의 `edit.html.erb` 템플릿을 이용할것입니다. [[[If the call to `update` fails, calling the `update` action in this controller will render the `edit.html.erb` template belonging to the same controller.]]]

선호에 따라 문자열 대신 심볼을 이용할 수 있습니다: [[[If you prefer, you can use a symbol instead of a string to specify the action to render:]]]

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(params[:book])
    redirect_to(@book)
  else
    render :edit
  end
end
```

#### [Rendering an Action's Template from Another Controller] 다른 컨트롤러의 액션 템플릿 랜더링하기

액션코드가 있는 컨트롤러와는 완전 다른 컨트롤러에 있는 템플릿을 렌더링하고자 한다면 어떻게 될까요? 이 때는 렌더링할 템플릿의 `app/views` 디렉토리로 부터의 상대경로를 지정해 주고 `render` 메소드를 호출하면 됩니다. 예를 들면, `app/controllers/admin` 폴더에 있는 `AdminProductsController`에서 코드를 실행하고자 하면 해당 액션의 결과는 다음과 같이 `app/views/products` 폴더에 있는 템플릿으로 렌더링할 수 있습니다. [[[What if you want to render a template from an entirely different controller from the one that contains the action code? You can also do that with `render`, which accepts the full path (relative to `app/views`) of the template to render. For example, if you're running code in an `AdminProductsController` that lives in `app/controllers/admin`, you can render the results of an action to a template in `app/views/products` this way:]]]

```ruby
render "products/show"
```

레일스는 슬래쉬 문자를 통해 해당뷰가 다른 컨트롤러에 있다고 판단합니다. 만약 명시적으로 지정하고 싶다면 `:template` 옵션을 사용합니다. (레일스 2.2 이전버전에서는 필수) [[[Rails knows that this view belongs to a different controller because of the embedded slash character in the string. If you want to be explicit, you can use the `:template` option (which was required on Rails 2.2 and earlier):]]]

```ruby
render template: "products/show"
```

#### [Rendering an Arbitrary File] 임의의 파일 렌더링하기

`render` 메소드는 애플리케이션의 외부에 있는 파일도 뷰로 사용할 수 있습니다.(만약 당신이 두개의 레일스 애플리케이션에서 뷰를 공유하는경우) [[[The `render` method can also use a view that's entirely outside of your application (perhaps you're sharing views between two Rails applications):]]]

```ruby
render "/u/apps/warehouse_app/current/app/views/products/show"
```

문자열의 맨앞에 있는 슬래쉬 문자를 통해 레일스는 파일이라고 판단합니다. 명시적으로 지정하고 싶다면 `:file` 옵션을 사용합니다.  (레일스 2.2 이전버전에서는 필수) [[[Rails determines that this is a file render because of the leading slash character. To be explicit, you can use the `:file` option (which was required on Rails 2.2 and earlier):]]]

```ruby
render file: "/u/apps/warehouse_app/current/app/views/products/show"
```

`:file` 옵션은 파일의 절대경로를 사용합니다. 물론 렌더링하기 위해서는 해당 파일에 대한 접근권한이 있어야 합니다. [[[The `:file` option takes an absolute file-system path. Of course, you need to have rights to the view that you're using to render the content.]]]

NOTE: 파일은 기본적으로 레이아웃없이 렌더딩됩니다. 파일에 현재 레이아웃을 적용하고 싶다면 `layout: true` 옵션을 추가합니다. [[[By default, the file is rendered without using the current layout. If you want Rails to put the file into the current layout, you need to add the `layout: true` option.]]]

TIP: 마이크로소프트의 윈도우즈를 사용한다면 파일 렌더링을 위해 `:file` 옵션을 사용해야합니다. 이는 윈도우의 파일이름이 Unix 의 파일시스템과 다르기 때문입니다. [[[If you're running Rails on Microsoft Windows, you should use the `:file` option to render a file, because Windows filenames do not have the same format as Unix filenames.]]]

#### [Wrapping it up] 정리하기

지금까지 소개한 렌더링에 관한 3가지 방법(컨트롤러내의 다른 액션의 템플릿 렌더링하기, 다른 컨트롤러내의 템플릿을 렌더링하기, 파일시스템 내의 임의의 파일 렌더링하기)은 사실 동일한 작업에 대한 변형들입니다. [[[The above three ways of rendering (rendering another template within the controller, rendering a template within another controller and rendering an arbitrary file on the file system) are actually variants of the same action.]]]

사실, BooksController 클래스에서 book 에 대한 업데이트가 실패하면 update 액션에서 edit 템플릿을 렌더링하고자 할 경우, 아래의 모든 렌더링 호출은 `views/books` 디렉토리에 있는 동일한 `edit.html.erb` 템플릿을 렌더링하게 될 것입니다. [[[In fact, in the BooksController class, inside of the update action where we want to render the edit template if the book does not update successfully, all of the following render calls would all render the `edit.html.erb` template in the `views/books` directory:]]]

```ruby
render :edit
render action: :edit
render "edit"
render "edit.html.erb"
render action: "edit"
render action: "edit.html.erb"
render "books/edit"
render "books/edit.html.erb"
render template: "books/edit"
render template: "books/edit.html.erb"
render "/path/to/rails/app/views/books/edit"
render "/path/to/rails/app/views/books/edit.html.erb"
render file: "/path/to/rails/app/views/books/edit"
render file: "/path/to/rails/app/views/books/edit.html.erb"
```

어떤 것을 사용할 것인가는 본인의 스타일과 관례에 관한 것이지만, 원칙은 가장 간단한 것을 사용한 것입니다. [[[Which one you use is really a matter of style and convention, but the rule of thumb is to use the simplest one that makes sense for the code you are writing.]]]

#### [Using `render` with `:inline`] `render` 메소드에 `:inline` 사용

ERB를 제공해 주기 위해서 메소드 호출의 일부로 `:inline` 옵션을 이용하면 뷰 템플릿 없이도 `render` 메소드가 작업을 할 수 있습니다. 다음과 같은 render 메소드는 완벽하게 동작합니다. [[[The `render` method can do without a view completely, if you're willing to use the `:inline` option to supply ERB as part of the method call. This is perfectly valid:]]]

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

WARNING: 사실 이 옵션을 사용할 이유는 거의 없습니다. ERB를 컨트롤러에 섞어 버리면 레일스의 MVC 구현 정책에 위배 되는 것이고 다른 개발자들이 해당 프로젝트의 로직을 이해하기가 힘들어 질 것입니다. 따라서 대신에 별도의 erb 뷰 파일을 사용하기 바랍니다. [[[There is seldom any good reason to use this option. Mixing ERB into your controllers defeats the MVC orientation of Rails and will make it harder for other developers to follow the logic of your project. Use a separate erb view instead.]]]

기본 설정으로 inline 렌더링은 ERB를 사용합니다. 그러나 `:type` 옵션을 사용하면 대신에 Builder를 사용하도록 할 수 있습니다. [[[By default, inline rendering uses ERB. You can force it to use Builder instead with the `:type` option:]]]

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### [Rendering Text] 문자열 렌더링

`:text` 옵션을 이용해서 렌더링하면 브라우저로 단순한 텍스트만 - 마크없이 없는 - 보낼 수 있습니다. [[[You can send plain text - with no markup at all - back to the browser by using the `:text` option to `render`:]]]

```ruby
render text: "OK"
```

TIP: 순수한 문자열으로만 이루어진 응답을 렌더링하는 것은 HTML외에 다른 무언가를 기대하는 Ajax나 웹서비스 요청에 대한 응답을 보낼 때 가장 유용합니다. [[[Rendering pure text is most useful when you're responding to Ajax or web service requests that are expecting something other than proper HTML.]]]

NOTE: 기본설정으로 `:text` 옵션을 이용하면 현재의 레이아웃을 사용하지 않은 채 텍스트를 렌더링하게 됩니다. 레이아웃를 적용해서 텍스트를 렌더링하고자 한다면 `layout: true` 옵션을 추가해야 합니다. [[[By default, if you use the `:text` option, the text is rendered without using the current layout. If you want Rails to put the text into the current layout, you need to add the `layout: true` option.]]]

#### [Rendering JSON] JSON 렌더링

JSON은 다수의 Ajax 라이브러리에서 사용하는 자바스크립트 데이터 포맷을 말합니다. 레일스는 객체를 JSON으로 변환하고 JSON을 브라우저로 렌더링하는 것을 지원합니다. [[[JSON is a JavaScript data format used by many Ajax libraries. Rails has built-in support for converting objects to JSON and rendering that JSON back to the browser:]]]

```ruby
render json: @product
```

TIP: 렌더링하고 하는 객체에 대해서 `to_json` 을 호출할 필요가 없습니다. `:json` 옵션을 사용하면 렌더링시 자동으로 `to_json` 을 호출하게 됩니다. [[[You don't need to call `to_json` on the object that you want to render. If you use the `:json` option, `render` will automatically call `to_json` for you.]]]

#### [Rendering XML] XML 렌더링

레일스는 또한 객체를 XML로 변환하고 호출자에게 XML을 렌더링해서 보내도록 지원합니다: [[[Rails also has built-in support for converting objects to XML and rendering that XML back to the caller:]]]

```ruby
render xml: @product
```

TIP: 렌더일하고자 하는 객체에 대해서 `to_xml` 을 호출할 필요가 없습니다. `:xml` 옵션을 사용하면 렌더일시 자동으로 `to_xml` 호출하게 됩니다. [[[You don't need to call `to_xml` on the object that you want to render. If you use the `:xml` option, `render` will automatically call `to_xml` for you.]]]

#### Rendering Vanilla JavaScript

Rails can render vanilla JavaScript:

```ruby
render js: "alert('Hello Rails');"
```

This will send the supplied string to the browser with a MIME type of `text/javascript`.

#### Options for `render`

Calls to the `render` method generally accept four options:

* `:content_type`
* `:layout`
* `:location`
* `:status`

##### The `:content_type` Option

By default, Rails will serve the results of a rendering operation with the MIME content-type of `text/html` (or `application/json` if you use the `:json` option, or `application/xml` for the `:xml` option.). There are times when you might like to change this, and you can do so by setting the `:content_type` option:

```ruby
render file: filename, content_type: "application/rss"
```

##### The `:layout` Option

With most of the options to `render`, the rendered content is displayed as part of the current layout. You'll learn more about layouts and how to use them later in this guide.

You can use the `:layout` option to tell Rails to use a specific file as the layout for the current action:

```ruby
render layout: "special_layout"
```

You can also tell Rails to render with no layout at all:

```ruby
render layout: false
```

##### The `:location` Option

You can use the `:location` option to set the HTTP `Location` header:

```ruby
render xml: photo, location: photo_url(photo)
```

##### The `:status` Option

Rails will automatically generate a response with the correct HTTP status code (in most cases, this is `200 OK`). You can use the `:status` option to change this:

```ruby
render status: 500
render status: :forbidden
```

Rails understands both numeric status codes and the corresponding symbols shown below.

| Response Class      | HTTP Status Code | Symbol                           |
| ------------------- | ---------------- | -------------------------------- |
| **Informational**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **Success**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **Redirection**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 306              | :reserved                        |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **Client Error**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :request_entity_too_large        |
|                     | 414              | :request_uri_too_long            |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :requested_range_not_satisfiable |
|                     | 417              | :expectation_failed              |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 423              | :precondition_required           |
|                     | 424              | :too_many_requests               |
|                     | 426              | :request_header_fields_too_large |
| **Server Error**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |

#### Finding Layouts

To find the current layout, Rails first looks for a file in `app/views/layouts` with the same base name as the controller. For example, rendering actions from the `PhotosController` class will use `app/views/layouts/photos.html.erb` (or `app/views/layouts/photos.builder`). If there is no such controller-specific layout, Rails will use `app/views/layouts/application.html.erb` or `app/views/layouts/application.builder`. If there is no `.erb` layout, Rails will use a `.builder` layout if one exists. Rails also provides several ways to more precisely assign specific layouts to individual controllers and actions.

##### Specifying Layouts for Controllers

You can override the default layout conventions in your controllers by using the `layout` declaration. For example:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

With this declaration, all of the views rendered by the products controller will use `app/views/layouts/inventory.html.erb` as their layout.

To assign a specific layout for the entire application, use a `layout` declaration in your `ApplicationController` class:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

With this declaration, all of the views in the entire application will use `app/views/layouts/main.html.erb` for their layout.

##### Choosing Layouts at Runtime

You can use a symbol to defer the choice of layout until a request is processed:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end

end
```

Now, if the current user is a special user, they'll get a special layout when viewing a product.

You can even use an inline method, such as a Proc, to determine the layout. For example, if you pass a Proc object, the block you give the Proc will be given the `controller` instance, so the layout can be determined based on the current request:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Conditional Layouts

Layouts specified at the controller level support the `:only` and `:except` options. These options take either a method name, or an array of method names, corresponding to method names within the controller:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

With this declaration, the `product` layout would be used for everything but the `rss` and `index` methods.

##### Layout Inheritance

Layout declarations cascade downward in the hierarchy, and more specific layout declarations always override more general ones. For example:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `posts_controller.rb`

    ```ruby
    class PostsController < ApplicationController
    end
    ```

* `special_posts_controller.rb`

    ```ruby
    class SpecialPostsController < PostsController
      layout "special"
    end
    ```

* `old_posts_controller.rb`

    ```ruby
    class OldPostsController < SpecialPostsController
      layout false

      def show
        @post = Post.find(params[:id])
      end

      def index
        @old_posts = Post.older
        render layout: "old"
      end
      # ...
    end
    ```

In this application:

* In general, views will be rendered in the `main` layout
* `PostsController#index` will use the `main` layout
* `SpecialPostsController#index` will use the `special` layout
* `OldPostsController#show` will use no layout at all
* `OldPostsController#index` will use the `old` layout

#### Avoiding Double Render Errors

Sooner or later, most Rails developers will see the error message "Can only render or redirect once per action". While this is annoying, it's relatively easy to fix. Usually it happens because of a fundamental misunderstanding of the way that `render` works.

For example, here's some code that will trigger this error:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

If `@book.special?` evaluates to `true`, Rails will start the rendering process to dump the `@book` variable into the `special_show` view. But this will _not_ stop the rest of the code in the `show` action from running, and when Rails hits the end of the action, it will start to render the `regular_show` view - and throw an error. The solution is simple: make sure that you have only one call to `render` or `redirect` in a single code path. One thing that can help is `and return`. Here's a patched version of the method:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

Make sure to use `and return` instead of `&& return` because `&& return` will not work due to the operator precedence in the Ruby Language.

Note that the implicit render done by ActionController detects if `render` has been called, so the following will work without errors:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

This will render a book with `special?` set with the `special_show` template, while other books will render with the default `show` template.

### [Using `redirect_to`] `redirect_to` 사용

HTTP 요청에 대한 응답을 다루는 또 다른 방법은 `redirect_to` 입니다. 이미 봤듯이 `render`는 레일스에게 응답을 만들때 어떤 뷰(혹은 자원)를 사용할지 알려줍니다. `redirect_to`는 이와 완전히 다르게 브라우저에게 새로운 URL로의 요청을 보내도록 알립니다. 예를들어 다음의 호출로 코드 어디서든지 사진목록으로 리다이렉트 할 수 있습니다. [[[Another way to handle returning responses to an HTTP request is with `redirect_to`. As you've seen, `render` tells Rails which view (or other asset) to use in constructing a response. The `redirect_to` method does something completely different: it tells the browser to send a new request for a different URL. For example, you could redirect from wherever you are in your code to the index of photos in your application with this call:]]]

```ruby
redirect_to photos_url
```

`redirect_to` 인자에는 `link_to` 또는 `url_for`에 사용하는 인자를 사용할 수 있습니다. 또한 사용자가 이전에 방문했던 페이지로 돌려보내는 특별한 리다이렉트도 있습니다. [[[You can use `redirect_to` with any arguments that you could use with `link_to` or `url_for`. There's also a special redirect that sends the user back to the page they just came from:]]]

```ruby
redirect_to :back
```

#### [Getting a Different Redirect Status Code] 리다이렉트 상태코드 지정

레일스에서 `redirect_to`를 호출할때 임시 리다이렉트를 의미하는 HTTP 302 상태코드를 사용합니다. 만약 영구 리다이렉트를 의미하는 301과 같은 상태코드를 사용하고자 하는경우 `:status` 옵션을 사용합니다. [[[Rails uses HTTP status code 302, a temporary redirect, when you call `redirect_to`. If you'd like to use a different status code, perhaps 301, a permanent redirect, you can use the `:status` option:]]]

```ruby
redirect_to photos_path, status: 301
```

`redirect_to`에서 `:status` 옵션은 `render` 에서의 `:status` 옵션과 동일하게 숫자나 심볼릭 명칭을 지정할 수 있습니다. [[[Just like the `:status` option for `render`, `:status` for `redirect_to` accepts both numeric and symbolic header designations.]]]

#### [The Difference Between `render` and `redirect_to`] `render`와 `redirect_to`의 차이점

때때로 경험이 부족한 개발자들은 `redirect_to`를 레일스의 코드에서 다른 지점으로 실행점이 옮겨지는 `goto`와 같은 종류로 인식합니다. 하지만 이것은 _틀렸_습니다. 코드는 실행을 중지하고 브라우저로부터의 새로운 요청을 기다리는 상태가 됩니다. 이때 브라우저에게 HTTP 302 상태코드를 보내 다음에 요청할것을 알려줍니다. [[[Sometimes inexperienced developers think of `redirect_to` as a sort of `goto` command, moving execution from one place to another in your Rails code. This is _not_ correct. Your code stops running and waits for a new request for the browser. It just happens that you've told the browser what request it should make next, by sending back an HTTP 302 status code.]]]

아래 액션들의 다른점을 알아보겠습니다:[[[Consider these actions to see the difference:]]]

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by_id(params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

이 코드에서는 `@book` 변수가 `nil`인경우 문제점이 있습니다. 기억해야할점은 `render :action`은 타겟의 액션코드를 실행하지 않는다는점입니다. 따라서 `index` 뷰에서 필요로하는 `@books` 변수가 설정되지 않습니다. 이 문제는 고치는 방법중 하나는 렌더링 대신 리다이렉트를 사용하는것입니다. [[[With the code in this form, there will likely be a problem if the `@book` variable is `nil`. Remember, a `render :action` doesn't run any code in the target action, so nothing will set up the `@books` variable that the `index` view will probably require. One way to fix this is to redirect instead of rendering:]]]

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by_id(params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

이 코드에서 브라우저는 인덱스 페이지를 위해 새로운 요청을 보내 `index` 메소드를 실행하고 모든것은 정상적으로 작동합니다. [[[With this code, the browser will make a fresh request for the index page, the code in the `index` method will run, and all will be well.]]]

이 코드의 유일한 단점은 브라우저로 되돌아 가는 것입니다. 브라우저가 `/books/1` 요청을 보내 show 액션을 요청하면 컨트롤러는 책이 없다는것을 알고 `/books/`로 이동하라는 302 리다이렉트 응답을 브라우저에게 보냅니다. 브라우저를 이를 해석해 새로 `index` 액션을 컨트롤러에게 요청하면 컨트롤러는 데이터베이스로부터 모든 책 목록을 가져와 index 템플릿에 렌더링한 결과를 브라우저에게 보내 사용자의 화면에 보이게 됩니다. [[[The only downside to this code is that it requires a round trip to the browser: the browser requested the show action with `/books/1` and the controller finds that there are no books, so the controller sends out a 302 redirect response to the browser telling it to go to `/books/`, the browser complies and sends a new request back to the controller asking now for the `index` action, the controller then gets all the books in the database and renders the index template, sending it back down to the browser which then shows it on your screen.]]]

소규모의 어플리케이션에서 이러한 시간 지체가 문제가 되지 않겠지만 응답속도가 중요한경우 생각해 볼 만합니다. 예제를 통해 이 문제를 다루는 방법중 하나를 살펴보겠습니다. [[[While in a small application, this added latency might not be a problem, it is something to think about if response time is a concern. We can demonstrate one way to handle this with a contrived example:]]]

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by_id(params[:id])
  if @book.nil?
    @books = Book.all
    flash[:alert] = "Your book was not found"
    render "index"
  end
end
```

이것은 특정 ID에 해당하는 책이 없는것을 알게 되었을때 `@books` 인스턴스 변수에 모든책을 할당하고, 사용자에게 무슨일이 벌어졌는지 알려주는 플래시 경고메시지와 함께 `index.html.erb` 템플릿을 렌더링해 브라우저에게 응답합니다. [[[This would detect that there are no books with the specified ID, populate the `@books` instance variable with all the books in the model, and then directly render the `index.html.erb` template, returning it to the browser with a flash alert message to tell the user what happened.]]]

### [Using `head` To Build Header-Only Responses] `head`를 이용해 헤더만 응답하기

`head` 메소드는 헤더정보만 가진 응답을 보낼수 있습니다. 이것은 `render :nothing`보다 좋은 대안을 제공합니다. `head` 메소드는 HTTP 상태코드를 나타내는 숫자나 심볼을([reference table](#the-status-option)) 인자로 허용합니다. 추가 인자는 헤더이름과 값으로 이루어진 해쉬입니다. 예를들어 오류 헤더만 반환하는경우 다음과 같습니다: [[[The `head` method can be used to send responses with only headers to the browser. It provides a more obvious alternative to calling `render :nothing`. The `head` method accepts a number or symbol (see [reference table](#the-status-option)) representing a HTTP status code. The options argument is interpreted as a hash of header names and values. For example, you can return only an error header:]]]

```ruby
head :bad_request
```

이것은 다음과 같은 헤더를 생성합니다: [[[This would produce the following header:]]]

```
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

또는 다른 HTTP 헤더를 사용해서 추가 정보를 보낼 수도 있습니다. [[[Or you can use other HTTP headers to convey other information:]]]

```ruby
head :created, location: photo_path(@photo)
```

이것은 다음과 같은 헤더를 생성합니다: [[[Which would produce:]]]

```
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

[Structuring Layouts] 레이아웃 구조화
-------------------

레일스에서 응답으로 뷰를 렌더링할때, 현재 레이아웃과 뷰를 결합 합니다. 현재 레이아웃을 찾는 규칙은 본 가이드의 앞부분에 설명되었습니다. 레이아웃안에서 여러개의 결과물을 합쳐 전체응답을 만들어내는데 3가지 툴을 사용할 수 있습니다: [[[When Rails renders a view as a response, it does so by combining the view with the current layout, using the rules for finding the current layout that were covered earlier in this guide. Within a layout, you have access to three tools for combining different bits of output to form the overall response:]]]

* Asset 태그들 [[[Asset tags]]]

* `yield`와 `content_for` [[[`yield` and `content_for`]]]

* Partials

### [Asset Tag Helpers] Asset 태그 헬퍼

Asset 태그 헬퍼는 피드, 자바스크립트, 스타일시트, 이미지, 비디오, 오디오등을 뷰와 연결하는 HTML을 만들어주는 메소드를 제공합니다: [[[Asset tag helpers provide methods for generating HTML that link views to feeds, JavaScript, stylesheets, images, videos and audios. There are six asset tag helpers available in Rails:]]]

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

이 태그들은 레이아웃이나 다른 뷰에서 사용할 수 있으며, `auto_discovery_link_tag`, `javascript_include_tag`, `stylesheet_link_tag` 태그는 일반적으로 레이아웃의 `<head>` 영역에서 사용됩니다. [[[You can use these tags in layouts or other views, although the `auto_discovery_link_tag`, `javascript_include_tag`, and `stylesheet_link_tag`, are most commonly used in the `<head>` section of a layout.]]]

WARNING: asset 태그 헬퍼는 asset이 지정한 위치에 존재하는지 검증하지 _않습니다_; 이는 단순히 당신이 무엇을 하는지 알고 있다고 가정하고 링크만을 생성합니다. [[[The asset tag helpers do _not_ verify the existence of the assets at the specified locations; they simply assume that you know what you're doing and generate the link.]]]

#### [Linking to Feeds with the `auto_discovery_link_tag`] `auto_discovery_link_tag`를 이용해 피드와 연결하기

`auto_discovery_link_tag` 헬퍼는 대부분의 브라우저와 뉴스리더에서 RSS 혹은 Atom 피드의 존재를 찾을수 있도록 하는 HTML을 생성합니다. 헬퍼는 인자로 링크에 대한 타입(`:rss` 혹은 `:atom`), 해쉬로 이루어진 url_for 에 사용하는 것과 같은 옵션, 태그를 위한 옵션을 받습니다: [[[The `auto_discovery_link_tag` helper builds HTML that most browsers and newsreaders can use to detect the presence of RSS or Atom feeds. It takes the type of the link (`:rss` or `:atom`), a hash of options that are passed through to url_for, and a hash of options for the tag:]]]

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

`auto_discovery_link_tag` 의 3가지 태그 옵션:[[[There are three tag options available for the `auto_discovery_link_tag`:]]]

* `:rel`은 링크의 `rel` 값을 의미합니다. 기본값은 "alternate" 입니다. [[[`:rel` specifies the `rel` value in the link. The default value is "alternate".]]]

* `:type`은 MIME 타입을 명시적으로 나타냅니다. 기본적으로 레일스는 알맞은 MIME 타입을 자동으로 만들어 냅니다. [[[`:type` specifies an explicit MIME type. Rails will generate an appropriate MIME type automatically.]]]

* `:title`은 링크의 제목을 의미합니다. 기본값은 `:type` 값의 대문자입니다. 예를들어 "ATOM", "RSS"와 같습니다. [[[`:title` specifies the title of the link. The default value is the uppercase `:type` value, for example, "ATOM" or "RSS".]]]

#### [Linking to JavaScript Files with the `javascript_include_tag`] `javascript_include_tag`를 이용해 자바스크립트 파일 연결하기

`javascript_include_tag` 헬퍼는 인자로 주어진 소스에 대한 `script` HTML 태그를 반환합니다. [[[The `javascript_include_tag` helper returns an HTML `script` tag for each source provided.]]]

만약 레일스의 [Asset Pipeline](asset_pipeline.html)을 활성화 했다면 레일스 이전버전의 `public/javascripts` 대신 `/assets/javascripts/` 에 대한 링크를 생성하게 됩니다. [[[If you are using Rails with the [Asset Pipeline](asset_pipeline.html) enabled, this helper will generate a link to `/assets/javascripts/` rather than `public/javascripts` which was used in earlier versions of Rails. This link is then served by the asset pipeline.]]]

레일스나 레일스 엔진에서 자바스크립트 파일의 위치는 `app/assets`, `lib/assets`, `vendor/assets` 3곳중 한곳입니다. 이 위치에 대한 자세한 설명은 [Asset Pipeline 가이드의 자원의 구성 섹션](asset_pipeline.html#asset-organization)에 되어 있습니다. [[[A JavaScript file within a Rails application or Rails engine goes in one of three locations: `app/assets`, `lib/assets` or `vendor/assets`. These locations are explained in detail in the [Asset Organization section in the Asset Pipeline Guide](asset_pipeline.html#asset-organization)]]]

선호도에 따라 문서 루트에서의 상대경로로 지정하거나 URL을 지정할수 있습니다. 예를들어 `app/assets`, `lib/assets`, `vendor/assets`폴더중 하나안의 `javascripts` 폴더의 파일을 링크하고자 한다면 다음과 같이할 수 있습니다: [[[You can specify a full path relative to the document root, or a URL, if you prefer. For example, to link to a JavaScript file that is inside a directory called `javascripts` inside of one of `app/assets`, `lib/assets` or `vendor/assets`, you would do this:]]]

```erb
<%= javascript_include_tag "main" %>
```

레일스가 만들어내는 `script` 태그의 결과물은 다음과 같습니다: [[[Rails will then output a `script` tag such as this:]]]

```html
<script src='/assets/main.js'></script>
```

이 asset 요청에 대한 처리는 Sprockets gem이 담당합니다. [[[The request to this asset is then served by the Sprockets gem.]]]

`app/assets/javascripts/main.js`, `app/assets/javascripts/columns.js` 같이 여러개의 파일을 동시에 포함시키기 위해서는: [[[To include multiple files such as `app/assets/javascripts/main.js` and `app/assets/javascripts/columns.js` at the same time:]]]

```erb
<%= javascript_include_tag "main", "columns" %>
```

`app/assets/javascripts/main.js`, `app/assets/javascripts/photos/columns.js`을 포함시키기 위해서는:[[[To include `app/assets/javascripts/main.js` and `app/assets/javascripts/photos/columns.js`:]]]

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

`http://example.com/main.js`을 포함시키기 위해서는:[[[To include `http://example.com/main.js`:]]]

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### [Linking to CSS Files with the `stylesheet_link_tag`] `stylesheet_link_tag`를 이용해 CSS 파일 연결하기

`stylesheet_link_tag` 헬퍼는 인자로 주어진 소스에 대한 `<link>` HTML 태그를 반환합니다.  [[[The `stylesheet_link_tag` helper returns an HTML `<link>` tag for each source provided.]]]

만약 레일스의 "Asset Pipeline"을 활성화 했다면 `/assets/stylesheets/`에 대한 링크를 생성합니다. 이 링크는 Sprockets gem이 처리합니다. 스타일시트 파일은 다음 3개의 폴더에 저장될 수 있습니다 `app/assets`, `lib/assets`, `vendor/assets` [[[If you are using Rails with the "Asset Pipeline" enabled, this helper will generate a link to `/assets/stylesheets/`. This link is then processed by the Sprockets gem. A stylesheet file can be stored in one of three locations: `app/assets`, `lib/assets` or `vendor/assets`.]]]

문서 루트에서의 상대경로로 지정하거나 URL을 지정할수 있습니다. 예를들어 `app/assets`, `lib/assets`, `vendor/assets`폴더중 하나안의 `stylesheets` 폴더의 파일을 링크하고자 한다면 다음과 같이할 수 있습니다: [[[You can specify a full path relative to the document root, or a URL. For example, to link to a stylesheet file that is inside a directory called `stylesheets` inside of one of `app/assets`, `lib/assets` or `vendor/assets`, you would do this:]]]

```erb
<%= stylesheet_link_tag "main" %>
```

`app/assets/stylesheets/main.css`, `app/assets/stylesheets/columns.css`을 포함시키기 위해서는: [[[To include `app/assets/stylesheets/main.css` and `app/assets/stylesheets/columns.css`:]]]

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

`app/assets/stylesheets/main.css`, `app/assets/stylesheets/photos/columns.css`을 포함시키기 위해서는: [[[To include `app/assets/stylesheets/main.css` and `app/assets/stylesheets/photos/columns.css`:]]]

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

`http://example.com/main.css`을 포함시키기 위해서는: [[[To include `http://example.com/main.css`:]]]

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

기본값으로 `stylesheet_link_tag`은 태그속성 `media="screen" rel="stylesheet"`과 함께 생성합니다. 이 기본값은 (`:media`, `:rel`) 옵션에 적당한 값을 입력해 변경할 수 있습니다: [[[By default, the `stylesheet_link_tag` creates links with `media="screen" rel="stylesheet"`. You can override any of these defaults by specifying an appropriate option (`:media`, `:rel`):]]]

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### [Linking to Images with the `image_tag`] `image_tag`를 이용해 이미지 연결하기

`image_tag` 헬퍼는 특정 파일에 대한 `<img />` HTML 태그를 생성합니다. 기본설정으로 파일은 `public/images` 폴더에서 로드됩니다. [[[The `image_tag` helper builds an HTML `<img />` tag to the specified file. By default, files are loaded from `public/images`.]]]

WARNING: 이미지파일의 확장자를 명시해야합니다. [[[Note that you must specify the extension of the image.]]]

```erb
<%= image_tag "header.png" %>
```

이미지 경로는 다음과 같이 지정할 수 있습니다.: [[[You can supply a path to the image if you like:]]]

```erb
<%= image_tag "icons/delete.gif" %>
```

해쉬를 이용해 HTML 태그 옵션을 지정할 수 있습니다.: [[[You can supply a hash of additional HTML options:]]]

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

사용자가 브라우저에서 이미지를 보이지 않도록 했을때 제공할 대체 텍스트도 지정할 수 있습니다. 대체 텍스트를 명시적으로 지정하지 않으면 이미지 파일의 확장자를 제외한 이름의 대문자로 제공됩니다. 예를들어 다음의 2개의 이미지 태그는 같은 코드를 반환합니다: [[[You can supply alternate text for the image which will be used if the user has images turned off in their browser. If you do not specify an alt text explicitly, it defaults to the file name of the file, capitalized and with no extension. For example, these two image tags would return the same code:]]]

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

"{가로}x{세로}" 포맷을 이용해 태그의 크기를 지정할 수 있습니다.[[[You can also specify a special size tag, in the format "{width}x{height}":]]]

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

위의 특수 태그이외에도 마지막 해쉬에 `:class`, `:id`, `:name`와 같은 키를 이용해 HTML 옵션을 지정할 수 있습니다.[[[In addition to the above special tags, you can supply a final hash of standard HTML options, such as `:class`, `:id` or `:name`:]]]

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### [Linking to Videos with the `video_tag`] `video_tag`를 이용해 비디오 연결하기

`video_tag` 헬퍼는 특정 파일에 대한 `<video>` HTML 5 태그를 생성합니다. 기본설정으로 파일은 `public/videos` 폴더에서 로드됩니다. [[[The `video_tag` helper builds an HTML 5 `<video>` tag to the specified file. By default, files are loaded from `public/videos`.]]]

```erb
<%= video_tag "movie.ogg" %>
```

다음과 같은 코드 생성 [[[Produces]]]

```erb
<video src="/videos/movie.ogg" />
```

`image_tag` 태그처럼 절대경로나 `public/videos` 디렉토리로부터의 상대경로를 지정할 수 있습니다. 추가로 `image_tag`처럼 `size: "#{가로}x#{세로}"` 옵션을 지정할 수 있습니다. 또한 `id`, `class`와 같은 HTML 옵션을 비디오태그의 마지막에 붙여 사용할 수 있습니다. [[[Like an `image_tag` you can supply a path, either absolute, or relative to the `public/videos` directory. Additionally you can specify the `size: "#{width}x#{height}"` option just like an `image_tag`. Video tags can also have any of the HTML options specified at the end (`id`, `class` et al).]]]

추가적으로 비디오태그는 다음과 같은 옵션들을 포함해서 `<video>` HTML 태그 옵션의 모든것을 해쉬로 지원합니다: [[[The video tag also supports all of the `<video>` HTML options through the HTML options hash, including:]]]

* `poster: "image_name.png"`, 비디오가 플레이되기전에 보여질 이미지를 지정. [[[provides an image to put in place of the video before it starts playing.]]]

* `autoplay: true`, 페이지 로드가 끝났을경우 자동으로 재생. [[[starts playing the video on page load.]]]

* `loop: true`, 비디오 재생이 완료되었을경우 다시 재생.[[[loops the video once it gets to the end.]]]

* `controls: true`, 사용자가 비디오를 제어할 수 있도록 브라우저가 제공하는 컨트롤을 추가. [[[provides browser supplied controls for the user to interact with the video.]]]

* `autobuffer: true`, 사용자가 페이지를 로드한후 비디오파일을 미리 로드. [[[the video will pre load the file for the user on page load.]]]

여러개의 비디오목록을 `video_tag`에 배열로 넘겨 사용: [[[You can also specify multiple videos to play by passing an array of videos to the `video_tag`:]]]

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

다음과 같은 코드를 생성:[[[This will produce:]]]

```erb
<video><source src="trailer.ogg" /><source src="movie.ogg" /></video>
```

#### [Linking to Audio Files with the `audio_tag`] `audio_tag`를 이용해 소리파일 연결하기

`audio_tag` 헬퍼는 특정 파일에 대한 `<audio>` HTML 5 태그를 생성합니다. 기본설정으로 파일은 `public/audios` 폴더에서 로드됩니다. [[[The `audio_tag` helper builds an HTML 5 `<audio>` tag to the specified file. By default, files are loaded from `public/audios`.]]]

```erb
<%= audio_tag "music.mp3" %>
```

소리파일에 대한 경로는 다음과 같이 지정합니다: [[[You can supply a path to the audio file if you like:]]]

```erb
<%= audio_tag "music/first_song.mp3" %>
```

`:id`, `:class` 같은 추가옵션을 해쉬를 이용해 지정할 수 있습니다. [[[You can also supply a hash of additional options, such as `:id`, `:class` etc.]]]

`video_tag`처럼 `audio_tag`도 다음과 같은 특수 옵션을 가집니다: [[[Like the `video_tag`, the `audio_tag` has special options:]]]

* `autoplay: true`, 페이지 로드가 끝났을경우 자동으로 재생 [[[starts playing the audio on page load]]]

* `controls: true`, 사용자가 소리를 제어할 수 있도록 브라우저가 제공하는 컨트롤을 추가. [[[provides browser supplied controls for the user to interact with the audio.]]]

* `autobuffer: true`, 사용자가 페이지를 로드한후 소리파일을 미리 로드. [[[the audio will pre load the file for the user on page load.]]]

### [Understanding `yield`] `yield`에 대한 이해

레이아웃 문법에서 `yield`는 뷰의 컨텐츠가 추가될 영역을 의미합니다. 이를 사용하는 간단한 방법은 하나의 `yield`를 사용해 렌더된 뷰의 전체 컨텐츠를 추가하는것입니다: [[[Within the context of a layout, `yield` identifies a section where content from the view should be inserted. The simplest way to use this is to have a single `yield`, into which the entire contents of the view currently being rendered is inserted:]]]

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

여러개의 yeild 영역을 가진 레이아웃을 생성할 수 있습니다.[[[You can also create a layout with multiple yielding regions:]]]

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

뷰의 메인영역은 이름이 지정되지 않은 `yield`에 추가됩니다. 이름이 지정된 `yield`에 컨텐츠를 표시하려면 `content_for` 메소드를 이용합니다. [[[The main body of the view will always render into the unnamed `yield`. To render content into a named `yield`, you use the `content_for` method.]]]

### [Using the `content_for` Method] `content_for` 메서드 사용

`content_for` 메소드는 레이아웃에서 이름을 가진 `yield` 블록에 컨텐츠를 추가할 수 있게합니다. 예를들어 다음의 뷰는 레이아웃의 동작방식을 보여줍니다: [[[The `content_for` method allows you to insert content into a named `yield` block in your layout. For example, this view would work with the layout that you just saw:]]]

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

레이아웃이 렌더링된 HTML 결과물은 다음과 같습니다: [[[The result of rendering this page into the supplied layout would be this HTML:]]]

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

레이아웃이 사이드바, 푸터와 같이 컨텐츠가 추가될 별개의 영역들을 가진 경우 `content_for` 메소드는 매우 유용합니다. 페이지에 특화된 자바스크립트나 CSS 파일의 태그를 일반 레이아웃의 헤더에 추가하는데도 유용합니다. [[[The `content_for` method is very helpful when your layout contains distinct regions such as sidebars and footers that should get their own blocks of content inserted. It's also useful for inserting tags that load page-specific JavaScript or css files into the header of an otherwise generic layout.]]]

### [Using Partials] Partial 사용

partial 템플릿 - "partials" 라고 불리우는 - 은 다루기 쉬운 작은조각으로 나누는 렌더링 프로세스의 또다른 도구입니다. partial을 사용하면 응답의 특정 부분을 렌더링하는 코드를 파일로 옮길수 있습니다. [[[Partial templates - usually just called "partials" - are another device for breaking the rendering process into more manageable chunks. With a partial, you can move the code for rendering a particular piece of a response to its own file.]]]

#### [Naming Partials] Partial 이름 규칙

partial을 뷰의 일부로 렌더링하기 위해서 뷰 내부에서 `render` 메소드를 사용합니다. [[[To render a partial as part of a view, you use the `render` method within the view:]]]

```ruby
<%= render "menu" %>
```

위의 코드는 뷰가 만들어질때 해당 지점에 `_menu.html.erb` 라는 이름의 파일을 렌더링합니다. 여기서 주목할것은 첫문자인 밑줄문자입니다: partial을 사용할때 밑줄문자가 없더라도 다른 일반뷰와 구별하기 위해 첫문자를 밑줄문자로 시작하게 이름짓습니다. 이는 다른폴더의 partial을 불러올때도 적용됩니다: [[[This will render a file named `_menu.html.erb` at that point within the view being rendered. Note the leading underscore character: partials are named with a leading underscore to distinguish them from regular views, even though they are referred to without the underscore. This holds true even when you're pulling in a partial from another folder:]]]

```ruby
<%= render "shared/menu" %>
```

위 코드는 `app/views/shared/_menu.html.erb` partial을 불러옵니다. [[[That code will pull in the partial from `app/views/shared/_menu.html.erb`.]]]

#### [Using Partials to Simplify Views] partial 을 이용해서 뷰를 간소화하기

partial 을 이용하는 한가지 방법은 partial을 마치 서브루틴처럼 생각하는 것입니다: 상세한 내용을 뷰로부터 분리시켜 더 쉽게 파악할 수 있도록 이동시키는 것처럼. 예를 들어, 다음과 같은 뷰가 있다고 가정해 봅시다: [[[One way to use partials is to treat them as the equivalent of subroutines: as a way to move details out of a view so that you can grasp what's going on more easily. For example, you might have a view that looked like this:]]]

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

여기서 `_ad_banner.html.erb` 과 `_footer.html.erb` partial은 어플리케이션의 다른 페이지에서도 많이 공유하는 내용을 가지고있을 수 있습니다. 특정 페이지에 대한 내용에 집중할때 이러한 영역의 자세한 내용은 볼 필요가 없습니다. [[[Here, the `_ad_banner.html.erb` and `_footer.html.erb` partials could contain content that is shared among many pages in your application. You don't need to see the details of these sections when you're concentrating on a particular page.]]]

TIP: 어플리케이션의 모든 페이지에서 공유하는 내용인경우 레이아웃에서 직접 partial을 사용할 수 있습니다. [[[For content that is shared among all pages in your application, you can use partials directly from layouts.]]]

#### [Partial Layouts] Partial 레이아웃

partial은 뷰가 레이아웃을 사용하는것처럼 자신만의 레이아웃 파일을 가질수 있습니다.예를들어, partial은 다음과 같이 호출할 수 있습니다: [[[A partial can use its own layout file, just as a view can use a layout. For example, you might call a partial like this:]]]

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

위의 코드는 `_link_area.html.erb` partial을 만들때 `_graybar.html.erb` 레이아웃 파일을 이용합니다. 여기서 주목할점은 partial을 위한 레이아웃역시 partial 처럼 밑줄문자로 시작하고, partial이 있는 위치와 같은 폴더에 존재한다는것입니다.(기본뷰 위치의 `layouts`폴더가 아님) [[[This would look for a partial named `_link_area.html.erb` and render it using the layout `_graybar.html.erb`. Note that layouts for partials follow the same leading-underscore naming as regular partials, and are placed in the same folder with the partial that they belong to (not in the master `layouts` folder).]]]

또한 주의할 사항은 `:layout` 옵션을 사용할 때는 `:partial` 을 명시해야 한다는 것입니다. [[[Also note that explicitly specifying `:partial` is required when passing additional options such as `:layout`.]]]

#### [Passing Local Variables] 지역변수 전달

partial에 지역변수를 전달해서 보다 강력하고 유연하게 만들수 있습니다. 예를들어, new와 edit 페이지가 각각 다른 내용을 가지면서 중복을 줄일 수 있게 됩니다: [[[You can also pass local variables into partials, making them even more powerful and flexible. For example, you can use this technique to reduce duplication between new and edit pages, while still keeping a bit of distinct content:]]]

* `new.html.erb`

    ```html+erb
    <h1>New zone</h1>
    <%= error_messages_for :zone %>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Editing zone</h1>
    <%= error_messages_for :zone %>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_for(zone) do |f| %>
      <p>
        <b>Zone name</b><br />
        <%= f.text_field :name %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    ```

비록 동일한 partial 이 두개의 뷰로 렌더링되지만, Action View 의 submit 헬퍼는 new 액션에 대해서는 "Create Zone"을 edit 액션에 대해서는 "Update Zone"을 리턴하게 됩니다. [[[Although the same partial will be rendered into both views, Action View's submit helper will return "Create Zone" for the new action and "Update Zone" for the edit action.]]]

모든 partial은 partial 이름과 동일한 지역변수를 가지고 있습니다(밑줄문자를 제외한). `:object` 옵션을 이용해 이 지역변수에 객체를 전달할 수 있습니다. [[[Every partial also has a local variable with the same name as the partial (minus the underscore). You can pass an object in to this local variable via the `:object` option:]]]

```erb
<%= render partial: "customer", object: @new_customer %>
```

`customer` partial의 `customer` 변수는 상위뷰의 `@new_customer`변수를 참조하게 됩니다. [[[Within the `customer` partial, the `customer` variable will refer to `@new_customer` from the parent view.]]]

모델의 인스턴스를 partial로 렌더링할 경우에는 다음과 같이 단축 문법을 사용할 수 있습니다. [[[If you have an instance of a model to render into a partial, you can use a shorthand syntax:]]]

```erb
<%= render @customer %>
```

`@customer` 인스턴스 변수가 `Customer` 모델의 인스턴스를 가지고 있다고 가정한다면, 위의 코드는 `_customer.html.erb` partial을 이용해서 렌더링할 것이고 이 때 partial의 `customer` 지역변수에 상위 뷰의 `@customer` 인스턴스 변수를 전달해 참조할 수 있도록합니다. [[[Assuming that the `@customer` instance variable contains an instance of the `Customer` model, this will use `_customer.html.erb` to render it and will pass the local variable `customer` into the partial which will refer to the `@customer` instance variable in the parent view.]]]

#### [Rendering Collections] 컬렉션 렌더링

Partial은 컬렉션을 렌더링할 때 매우 유용합니다. `:collection` 옵션을 이용해서 partial에 컬렉션을 넘겨 줄 때, partial에 컬렉션의 각 항목들이 한번씩 채워지게 됩니다: [[[Partials are very useful in rendering collections. When you pass a collection to a partial via the `:collection` option, the partial will be inserted once for each member in the collection:]]]

* `index.html.erb`

    ```html+erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Product Name: <%= product.name %></p>
    ```


컬렉션으로 partial이 호출되는경우, 각각의 partial 인스턴스는 컬렉션의 항목이 partial 이름의 변수로 할당되어 렌더링됩니다. 이 경우에 partial은 `_product` 이 되고 `_product` partial 내에서 `product` 변수를 참조하여 렌더링됩니다. [[[When a partial is called with a pluralized collection, then the individual instances of the partial have access to the member of the collection being rendered via a variable named after the partial. In this case, the partial is `_product`, and within the `_product` partial, you can refer to `product` to get the instance that is being rendered.]]]

이것에 대한 짧은 방법이 있습니다. `@products`가 `product` 인스턴스의 컬렉션이라고 가정하면, 동일한 결과물을 얻기 위해 `index.html.erb` 에 다음과 같이 사용할 수 있습니다. [[[There is also a shorthand for this. Assuming `@products` is a collection of `product` instances, you can simply write this in the `index.html.erb` to produce the same result:]]]

```html+erb
<h1>Products</h1>
<%= render @products %>
```

레일스는 컬렉션에 있는 모델 이름을 찾아보고 partial 이름을 결정하게 됩니다. 사실, 다양한 종류의 모델로부터 만들어진 인스턴스로 구성된 컬렉션을 만들어 동일한 방법으로 렌더링할 수 있는데, 이때 레일스는 컬렉션 각 멤버에 대한 적절한 partial을 선택하게 될 것입니다. [[[Rails determines the name of the partial to use by looking at the model name in the collection. In fact, you can even create a heterogeneous collection and render it this way, and Rails will choose the proper partial for each member of the collection:]]]

* `index.html.erb`

    ```html+erb
    <h1>Contacts</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>Customer: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>Employee: <%= employee.name %></p>
    ```

위의 경우, 레일스는 컬렉션의 각 멤버에 따라 해당하는 모델의 partial로 customer 또는 employee partial을 사용하게 될 것입니다. [[[In this case, Rails will use the customer or employee partials as appropriate for each member of the collection.]]]

컬렉션이 비어있는경우, `render`는 nil을 반환하므로 정말 간단하게 대체 내용을 제공할 수 있습니다. [[[In the event that the collection is empty, `render` will return nil, so it should be fairly simple to provide alternative content.]]]

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### [Local Variables] 지역 변수

partial 내에서 별도의 지역변수 이름을 사용하고자 할때는, partial 호출시에 `:as` 옵션에 명시해 주면 됩니다. [[[To use a custom local variable name within the partial, specify the `:as` option in the call to the partial:]]]

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

위의 경우, partial에서 `@products` 컬렉션 인스턴스 항목을 `item` 지역변수로 접근할 수 있습니다. [[[With this change, you can access an instance of the `@products` collection as the `item` local variable within the partial.]]]

`locals: {}` 옵션을 이용해 렌더링하면 partial에서 임의의 지역변수를 사용할 수 있습니다. [[[You can also pass in arbitrary local variables to any partial you are rendering with the `locals: {}` option:]]]

```erb
<%= render partial: "products", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

이것은 지역변수 `item`으로 partial 로 넘어가는 `@products` 인스턴스 변수의 `product` 각각에 대해서 `_productions.html.erb` partial 을 렌더링하게 될 것입니다.

`@products` 인스턴스변수의 `product` 인스턴스 항목들을 `_products.html.erb` partial로 렌더링할때 `item` 지역변수와 `Product Page` 값을가진 `title` 지역변수를 가집니다. [[[Would render a partial `_products.html.erb` once for each instance of `product` in the `@products` instance variable passing the instance to the partial as a local variable called `item` and to each partial, make the local variable `title` available with the value `Products Page`.]]]

TIP: 레일스는 컬렉션에 의해 partial이 호출될 때 counter 변수를 생성합니다. 이 변수는 컬렉션 멤버의 이름 뒤에 `_counter` 를 붙인 형태의 이름을 가지게 됩니다. 예를 들면, `@products` 를 렌더링할 경우, partial에서 `product_counter`를 참조하면 partial이 렌더링된 횟수를 알 수 있습니다. 그러나 `as: :value` 옵션을 사용해서 partial을 호출한 경우에는 작동하지 않습니다. [[[Rails also makes a counter variable available within a partial called by the collection, named after the member of the collection followed by `_counter`. For example, if you're rendering `@products`, within the partial you can refer to `product_counter` to tell you how many times the partial has been rendered. This does not work in conjunction with the `as: :value` option.]]]

`:spacer_template` 옵션을 이용하면 여러개의 주 partial 사이에 렌더링되는 두번째 partial 을 지정할 수 있습니다. [[[You can also specify a second partial to be rendered between instances of the main partial by using the `:spacer_template` option:]]]

#### [Spacer Templates] 스페이서 템플릿

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

레일스는 `_product_ruler` partial을(데이터가 전달되지 않는 경우) `_product` partial 사이 사이에 렌더링하게 될 것입니다. [[[Rails will render the `_product_ruler` partial (with no data passed in to it) between each pair of `_product` partials.]]]

#### [Collection Partial Layouts] 컬렉션 Partial 레이아웃

컬렉션 partial을 렌더링할때도 `:layout` 옵션을 사용할 수 있습니다. [[[When rendering collections it is also possible to use the `:layout` option:]]]

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

이 레이아웃은 컬렉션의 각 항목에 대해 렌더링될때 사용됩니다. partial에서 그렇듯 현재 object와 object_counter 변수를 레이아웃에서 사용할 수 있습니다. [[[The layout will be rendered together with the partial for each item in the collection. The current object and object_counter variables will be available in the layout as well, the same way they do within the partial.]]]

### [Using Nested Layouts] 중첩 레이아웃 사용

일반 레이아웃과는 달리 특정 컨트롤러를 지원하는 레이아웃이 필요한 경우가 있을 것입니다. 주 레이아웃을 수정후 사용하기를 반복하는것 보다 중첩 레이아웃을(때로 sub-template라고도 불리는) 이용할 수도 있습니다. 아래에 그 예를 보여줍니다: [[[You may find that your application requires a layout that differs slightly from your regular application layout to support one particular controller. Rather than repeating the main layout and editing it, you can accomplish this by using nested layouts (sometimes called sub-templates). Here's an example:]]]

ApplicationController 레이아웃있다고 가정하면: [[[Suppose you have the following `ApplicationController` layout:]]]

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Top menu items here</div>
      <div id="menu">Menu items here</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

`NewsController` 에서 만들어지는 페이지에서는 상단 메뉴를 감추고 오른쪽 메뉴를 추가하고 싶다면: [[[On pages generated by `NewsController`, you want to hide the top menu and add a right menu:]]]

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Right menu items here</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

News 뷰는 "content" div 안에 상단 메뉴가 사라지고 우측 메뉴가 추가된 새 레이아웃을 사용할 것입니다. [[[That's it. The News views will use the new layout, hiding the top menu and adding a new right menu inside the "content" div.]]]

이러한 기법을 이용하면 다양한 서브템플릿으로 비슷한 결과를 보여주는 방법이 많아지게 됩니다. 중첩 레벨에는 제한이 없습니다. `render template: 'layouts/news'` 으로 `ActionView::render` 메소드를 이용하여 News 레아아웃 상에 새로운 레이아웃을 만들 수 있습니다. 만약에 `News` 레이아웃을 서브템플릿으로 사용하지 않을 경우에는 `content_for?(:news_content) ? yield(:news_content) : yield`를 `yield`로 대치 하면 됩니다.  [[[There are several ways of getting similar results with different sub-templating schemes using this technique. Note that there is no limit in nesting levels. One can use the `ActionView::render` method via `render template: 'layouts/news'` to base a new layout on the News layout. If you are sure you will not subtemplate the `News` layout, you can replace the `content_for?(:news_content) ? yield(:news_content) : yield` with simply `yield`.]]]
