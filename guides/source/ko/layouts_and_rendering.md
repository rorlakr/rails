
레이아웃과 랜더링
==============================

이 가이드에서는 Action Controller와 Action View에 의한 기본적인 레이아웃 기능에 대해서 설명합니다.

이 가이드의 내용:

* Rails에 포함되어있는 다양한 랜더링 방법의 사용법
* 컨텐츠를 여러 개 포함하는 레이아웃 만들기
* 파셜을 사용해서 뷰를 DRY하게 만들기
* 레이아웃을 중첩시키는 방법(서브 템플릿)

--------------------------------------------------------------------------------

개요: 부품을 조립하는 방법
-------------------------------------

이 가이드에서는 컨트롤러-뷰-모델 삼각형에서 컨트롤러와 뷰 사이에서 일어나는 동작들을 다루고 있습니다. 이미 알고 계시듯, Rails의 컨트롤러는 요청을 다루는 프로세스 전반을 관리할 책임을 가지고 있으며, 무거운 처리는 모델에 맡기는 것이 일반적입니다. 모델에서의 처리가 끝나고 사용자에게 결과를 표시할 시간이 다가오면, 컨트롤러는 처리 결과를 뷰에게 넘깁니다. 이 때 컨트롤러에서 뷰로 결과를 넘기는 방법이 바로 이 가이드의 주제입니다.

크게 보면 사용자에게 돌려보낼 응답의 내용을 결정하는 것과, 그 응답을 생성하기 위한 적절한 메소드를 호출하는 것이 이 과정에 포함됩니다. 사용자에게 돌려줄 응답 화면을 완전한 뷰로 만들기 위해서, Rails는 레이아웃에서 뷰를 감싸고, 그 안에서 파셜 뷰를 가져오는 등의 작업을 할 것입니다. 이후 이 가이드에서는 이러한 방법들을 모두 소개합니다.

응답을 생성하기
------------------

컨트롤러의 입장에서 보면 HTTP 응답의 생성 방법은 크게 3가지가 있습니다.

* `render`를 호출해서 브라우저에 돌려줄 응답을 생성한다
* `redirect_to`를 호출해서 HTTP 리다이렉트 코드를 브라우저에 돌려준다
* `head`를 호출해서 HTTP 헤더로만 구성된 응답을 생성한다

### 기본 출력: 액션에서의 '설정보다 규약'

Rails에서는 '설정보다 규약(CoC: convention over configuration)'를 권장한다는 것을 들어보셨을 겁니다. 기본 출력 결과는 CoC의 좋은 예시이기도 합니다. Rails 컨트롤러는 기본적으로 라우팅에 맞는 이름을 가지는 뷰를 자동적으로 선택하고, 그것을 사용해서 결과를 출력합니다. 예를 들어, `BooksController`라는 컨트롤러에 다음의 코드가 있다고 가정합니다.

```ruby
class BooksController < ApplicationController
end
```

그리고 라우팅 파일에는 아래와 같이 적혀있다고 가정합시다.

```ruby
  resources :books
```

`app/views/books/index.html.erb` 뷰 파일의 내용은 이렇다고 합시다.

```html+erb
<h1>Books are coming soon!</h1>
```

이렇게 하는 것으로 유저가 브라우저에서 `/books`에 접속하면 Rails는 자동적으로 `app/views/books/index.html.erb` 뷰를 사용해서 응답을 생성하고, 그 결과, 화면에는 'Books are coming soon!'라는 문자열이 화면에 표시됩니다.

하지만 이 화면만으로는 전혀 실용성이 없으므로 `Book` 모델을 생성하고, `BooksController`에 index 액션을 추가해봅시다.

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

이 코드에서 주목해야하는 부분은 '설정보다 규약'이라는 원칙 덕분에 index 액션의 마지막 부분에서 명시적으로 랜더링을 지시할 필요가 없다는 점입니다. 여기에서의 원칙은 '컨트롤러의 액션의 마지막 부분에서 명시적인 랜더링 지시가 없을 경우에는 컨트롤러가 사용가능한 뷰 목록의 경로로부터 `action명.html.erb`이라는 뷰 템플릿을 찾고, 그것을 사용할 것'입니다. 따라서, 이 경우에는 `app/views/books/index.html.erb`을 사용해서 출력합니다.

뷰에서 모든 책의 속성을 출력하고 싶은 경우에는 아래와 같이 ERB를 작성해야 할 필요가 있습니다.

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

<br>

<%= link_to "New book", new_book_path %>
```

NOTE: 실제 랜더링은 `ActionView::TemplateHandlers`의 서브클래스에서 실행됩니다. 이 가이드에서 랜더링의 상세에 대해서는 다루지 않습니다만, 템플릿 핸들러의 선택이 뷰 템플릿 파일의 확장자에 의해서 제어되고 있다는 것은 기억해주세요. Rails 2이후의 뷰 템플릿의 표준 확장자는 ERB(HTML + eMbedded RuBy)의 경우에는 `.erb`, Builder(XML 제너레이터)의 경우에는 `.builder`입니다.

### `render`를 사용하기

대부분의 경우, `ActionController::Base#render` 메소드가 브라우저에 애플리케이션의 내용을 출력을 출력하는 일을 담당합니다. `render` 메소드는 다양한 방법으로 커스터마이즈할 수 있습니다. Rails 템플릿의 기본 뷰를 출력할 수도 있고, 특정 템플릿, 파일, 인라인 코드를 지정해서 출력하거나, 아무것도 출력하지 않는 것도 가능합니다. 텍스트, JSON, XML을 출력하는 것도 가능합니다. 출력되는 응답의 Content-Type나 HTTP Status Code를 지정할 수도 있습니다.

TIP: 출력 결과를 브라우저에서 출력하지 않고 `render`의 정확한 결과를 얻고 싶은 경우에는 `render_to_string`을 호출하면 됩니다. 이 메소드의 동작은 `render`와 동일하며 출력 결과를 브라우저로 돌려주지 않고 문자열의 형태로 돌려준다는 점이 다릅니다.

#### 아무것도 출력하고 싶지 않은 경우

`render` 메소드에서 가능한 가장 간단한 동작이라고 한다면, 아무것도 출력하지 않는 것입니다.

```ruby
render nothing: true
```

이 응답을 curl을 사용해서 확인해보면 아래와 같습니다.

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

응답의 내용도 비어있습니다만(`Cache-Control` 이후의 데이터가 없습니다) 상태 코드가 200 OK로 되어있기 때문에 요청이 성공했음을 알 수 있습니다. render 메소드의 `:status` 옵션을 설정하는 것으로 상태 코드를 변경할 수 있습니다. 아무것도 출력하지 않는 응답은, Ajax 요청을 사용할 경우에 편리합니다. 이것을 사용하여 요청이 성공했다는 확인 응답만을 브라우저에게 돌려보낼 수 있기 때문입니다.

TIP: 200 OK 헤더만 보내고 싶은 경우라면 여기서 소개한 `render :nothing`보다도 이 가이드의 뒷 부분에서 설명할 `head` 메소드를 사용하는 것을 추천합니다. `head` 메소드는 `render :nothing` 보다도 유연성이 높고, HTTP 헤더만을 생성하고 있다는 점을 명확히 나타낼 수 있기 때문입니다.

#### Action View 출력하기

`render` 메소드를 사용해서 같은 컨트롤러에서 기본 설정과 다른 템플릿을 지정할 수 있습니다.

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

위의 `update` 액션에서 모델의 `update` 메소드가 실패하면, 같은 컨트롤러에 준비해둔 `edit.html.erb` 템플릿을 사용하도록 합니다.

문자열 대신에 심볼을 사용할 수도 있습니다.

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit
  end
end
```

#### 다른 컨트롤러의 템플릿을 사용하기

한 컨트롤러의 액션에서, 다른 컨트롤러에 속해있는 템플릿을 사용하는 것은 가능할까요? 이것도 `render` 메소드로 가능합니다. `render` 메소드는 `app/views`를 기본으로 하는 경로를 넘길수 있으므로, 출력하고 싶은 템플릿의 경로 전체를 넘겨주면 됩니다. 예를 들어 `app/controllers/admin`에 존재하는 `AdminProducts` 컨트롤러에서 `app/views/products`에 존재하는 뷰 템플릿을 사용하고 싶다면, 아래와 같이 작성하면 됩니다.

```ruby
render "products/show"
```

Rails는 경로에 `/`가 포함되어 있으면 다른 컨트롤러에 속해있는 템플릿이라고 인식합니다. 다른 컨트롤러의 템플릿임을 좀 더 명확하게 나타내고 싶은 경우에는 아래와 같이 `:template` 옵션을 사용할 수도 있습니다(Rails 2.2 이하에서는 이 옵션이 필수였습니다).

```ruby
render template: "products/show"
```

#### 별도의 파일을 사용하기

`render` 메소드로 지정할 수 있는 뷰는 현재 애플리케이션의 폴더 바깥에 있어도 상관 없습니다(예를 들어, 2개의 Rails 애플리케이션이 같은 뷰 템플릿을 공유하고 있는 경우).

```ruby
render "/u/apps/warehouse_app/current/app/views/products/show"
```

Rails는 경로가 `/`로 시작되는 경우 별도의 파일을 사용한 랜더링이라고 인식합니다. 이러한 경우에 좀 더 명확하게 표현하고 싶은 경우에는 아래처럼 `:file` 옵션을 사용할 수 있습니다(Rails 2.2 이전에서는 해당 옵션을 반드시 사용해야 했습니다).

```ruby
render file: "/u/apps/warehouse_app/current/app/views/products/show"
```

`:file` 옵션으로 주어진 경로는 파일 시스템을 기준으로 하는 절대 경로입니다. 당연하지만 해당 파일에 대한 접근 권한이 부여되어있어야 합니다.

NOTE: 파일을 사용하는 경우, 기본적으로 현재 레이아웃이 무시됩니다. 이 랜더링 작업을 현재 레이아웃 내부에서 수행하고 싶은 경우에는 `layout: true` 옵션을 추가할 필요가 있습니다.

TIP: Microsoft Windows에서 Rails를 실행하는 경우, 파일을 랜더링하는 경우에 `:file` 옵션을 생략할 수 없습니다. Windows의 파일명 형식이 Unix와 같지 않기 때문입니다.

#### 요약

지금까지 소개한 3가지 방법(컨트롤러에 속해있는 다른 템플릿 사용하기, 컨트롤러에 속해있지 않은 템플릿 사용하기, 파일 시스템에 있는 별도의 파일 사용하기)은 실제로는 하나의 액션의 다양한 사용 방법에 불과합니다.

사실, 예를 들어 BooksController 클래스의 update 액션에서 책의 정보를 변경하는데에 실패한 경우에 edit 템플릿을 랜더링하고 싶다고 한다면, 아래의 어떤 방식을 선택하더라도 최종적으로는 `views/books` 폴더에 있는 `edit.html.erb`를 사용해서 랜더링하게 됩니다.

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

어떤 방식으로 랜더링을 할지는 사용 스타일과 규칙의 문제입니다만, 가급적 간단한 방법을 사용하는 것이 코드를 읽기 쉽게 해줄 것입니다.

#### `render`에서 `:inline` 옵션 사용하기

`render` 메소드는 호출할 때에 `:inline` 옵션을 사용하여 ERB를 넘겨주면, 뷰 템플릿 없이도 실행할 수 있습니다. 예를 들어, 다음은 정상적으로 동작하는 코드입니다.

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

WARNING: 이 옵션을 실제로 사용하는 경우는 흔치 않습니다. 컨트롤러의 코드에 ERB를 혼재시키게 되면 Rails의 MVC 패턴을 무시하게 될 뿐만 아니라, 다른 사람이 코드를 읽기 어렵게 만듭니다. 가급적 별도의 ERB 뷰 템플릿을 사용해주세요.

인라인 옵션에서는 기본으로 ERB를 사용하며, `:type` 옵션으로 ERB 대신 Builder를 사용하라고 명령할 수 있습니다.

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### 텍스트 랜더링하기

`render`에서 `:plain` 옵션을 사용하면, 문자열을 그대로 브라우저에 전송할 수 있습니다.

```ruby
render plain: "OK"
```

TIP: 문자열 랜더링은, Ajax나 웹 서비스 응답시에 유용합니다. 이것들은 HTML 이외의 응답을 요구하기 때문입니다.

NOTE: 기본적으로 `:plain` 옵션을 사용하면 현재 레이아웃을 무시하고 랜더링됩니다. 레이아웃을 포함해서 랜더링 하고 싶은 경우에는 `layout: true` 옵션을 추가할 필요가 있습니다.

#### HTML 랜더링하기

`render`에서 `:html` 옵션을 사용하면 HTML 문자열을 직접 브라우저에 전송할 수 있습니다.

```ruby 
render html: "<strong>Not Found</strong>".html_safe
```

TIP: 이 방법은 무척 적은 양의 HTML 코드를 랜더링하고 싶을 때에 편리합니다. 이렇게 랜더링하던 코드가 복잡해지는 경우, 뷰 템플릿 사용을 검토해주세요.

NOTE: 이 옵션을 사용하면 문자열이 'HTML safe'하지 않은 경우에 이스케이프를 수행합니다.

#### JSON 랜더링하기

JSON은 JavaScript의 데이터 형식 중 하나로, 많은 Ajax 라이브러리에서 사용되고 있습니다. Rails에서는 객체를 JSON형식으로 변환하고, 변환된 JSON을 브라우저로 전송하기 위한 기능이 지원되고 있습니다.

```ruby
render json: @product
```

TIP: 랜더링할 객체에 `to_json`을 호출할 필요는 없습니다. `:json` 옵션을 지정하면 `render`에 의해서 `to_json`이 자동적으로 호출되기 때문입니다.

#### XML 랜더링하기

Rails에서는 객체를 XML로 변환하고, 변환된 XML을 브라우저에 전송하기 위한 기능이 지원됩니다.

```ruby
render xml: @product
```

TIP: 랜더링할 객체에 대해서 `to_xml`을 호출할 필요는 없습니다. `:xml` 옵션을 지정하면 `render`에 의해서 `to_xml`이 자동적으로 호출되기 때문입니다.

#### Vanilla JavaScript 랜더링하기

Rails는 vanilla JavaScript도 랜더링할 수 있습니다.

```ruby
render js: "alert('Hello Rails');"
```

이 코드는 인수로 넘겨진 문자열을 MIME 형식 `text/javascript`로 브라우저에 전송합니다.

#### 컨텐츠를 그대로 랜더링하기

`render`로 `:body` 옵션을 지정하면, content-type을 지정하지 않고 전송할 수 있습니다.

```ruby
render body: "raw"
```

TIP: 응답의 content-type이 어떤 형태라도 상관 없는 경우일 경우에만 이 옵션을 사용해주세요. 대부분의 경우, `:plain`이나 `:html`을 사용하는 것이 적당합니다.

NOTE: 이 옵션을 사용해서 브라우저로 전송된 응답은 별도로 지정하지 않는 이상 `text/html`이 사용됩니다. 이는 Action Dispatch에 의한 기본 content-type 이기 때문입니다.

#### `render` 옵션

`render` 메소드에서 자주 사용되는 옵션은 아래의 4가지 입니다.

* `:content_type`
* `:layout`
* `:location`
* `:status`

##### `:content_type`

Rails가 기본으로 출력하는 결과의 MIME content-type는 `text/html`입니다(단 `:json`을 사용하는 경우에는 `application/json`, `:xml`을 사용하면 `application/xml`이 됩니다). content-type를 변경하고 싶은 경우에는 `:content_type`를 사용합니다.

```ruby
render file: filename, content_type: "application/rss"
```

##### `:layout`

`render`에서 지정 가능한 대부분의 옵션은 현재 레이아웃의 일부로서 랜더링 됩니다. 더 자세한 내용은 이 가이드의 나머지 부분에서 설명합니다.

`:layout` 옵션을 사용하면 현재의 액션에서 특정 파일을 레이아웃으로 사용할 수 있습니다.

```ruby
render layout: "special_layout"
```

랜더링할 때에 레이아웃을 사용하지 않도록 설정할 수도 있습니다.

```ruby
render layout: false
```

##### `:location`

`:location`을 사용하면 HTTP의 `Location` 헤더를 설정할 수 있습니다.

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status`

Rails가 돌려주는 응답의 HTTP 상태 코드는 자동적으로 생성됩니다(대부분의 경우 `200 OK`가 됩니다). `:status` 옵션을 사용하는 것으로 응답의 상태 코드를 변경할 수 있습니다.

```ruby
render status: 500
render status: :forbidden
```

상태 코드는 숫자를 그대로 넘겨주거나, 아래 표에 나타난 심볼을 사용할 수도 있습니다.

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
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
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

#### 레이아웃의 탐색 순서

Rails는 레이아웃을 탐색하는 경우, 우선 현재 컨트롤러와 같은 이름을 가지는 레이아웃이 `app/views/layouts` 에 있는지를 확인합니다. 예를 들어, `PhotosController` 클래스의 액션을 랜더링하는 경우라고 가정한다면 `app/views/layouts/photos.html.erb`나 `app/views/layouts/photos.builder`를 찾습니다. 해당하는 레이아웃이 존재하지 않는 경우, `app/views/layouts/application.html.erb`나 `app/views/layouts/application.builder`를 사용합니다. `.erb` 레이아웃이 없는 경우, `.builder` 레이아웃이 있다면 그것을 사용합니다. Rails에는 각 컨트롤러나 액션별로 특정 레이아웃을 더 정확하게 지정할 수 있는 방법을 몇가지 제공합니다.

##### 컨트롤러 레이아웃 지정하기

`layout` 선언을 사용하는 것으로 컨트롤러의 기본 레이아웃을 지정할 수 있습니다.

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

이 선언을 통해서 `ProductsController`에서 랜더링 시에 사용되는 레이아웃이 `app/views/layouts/inventory.html.erb`로 변경됩니다.

`ApplicationController`에서 `layout`을 선언하면 애플리케이션 전체에 걸친 기본 레이아웃을 변경하게 됩니다.

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

이 선언에 의해서 애플리케이션의 모든 뷰에서 사용되는 레이아웃이 `app/views/layouts/main.html.erb`로 변경됩니다.

##### 실행 시에 레이아웃 지정하기

심볼을 사용해서 레이아웃을 지정하면 사용할 레이아웃의 선택을 요청이 실제로 처리될 때까지 연기할 수 있습니다.

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

이 코드는 현재 사용자가 특별한 사용자이고, 그 사용자가 제품 페이지를 보는 경우에 특별한 레이아웃을 사용하게 됩니다.

레이아웃을 결정할 때에 Proc 등의 인라인 메소드를 사용할 수도 있습니다. Proc 객체를 넘기면 Proc의 블록으로 `controller` 인스턴스를 넘겨받습니다. 이를 이용해서 현재의 요청에 알맞는 레이아웃을 결정할 수 있습니다.

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### 조건부 레이아웃

컨트롤러에서 선언하는 layout에서는 `:only`와 `:except`를 지원합니다. 이 옵션들은 단일 메소드명 또는 메소드명의 배열을 인수로 넘겨 받습니다. 넘기는 메소드 이름은 컨트롤러 내부의 메소드 이름에 대응합니다.

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

이 선언에 의해, `rss`와 `index` 이외의 모든 액션에서는 `product` 레이아웃이 사용됩니다.

##### 레이아웃의 상속

레이아웃 선언은 자식 컨트롤러에 상속됩니다. 자식 컨트롤러, 다시 말해 좀 더 구체적인 레이아웃 선언은 부모 컨트롤러에서 선언된 일반적인 레이아웃보다 우선되게 됩니다.

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

위의 컨트롤러는 다음과 같이 동작합니다.

* 뷰를 랜더링하는 경우에는 기본적으로 `main` 레이아웃이 사용됩니다.
* `PostsController#index`에서는 `main`이 사용됩니다.
* `SpecialPostsController#index`에서는 `special`이 사용됩니다.
* `OldPostsController#show`은 레이아웃을 사용하지 않습니다.
* `OldPostsController#index`에서는 `old` 레이아웃이 사용됩니다.

#### 이중 랜더링 에러 피하기

Rails 개발을 하다보면, 한번쯤은 "Can only render or redirect once per action" 에러를 만나게 될 겁니다. 지긋지긋한 에러입니다만, 고치는 것은 비교적 간단합니다. 이 에러는 대부분, 개발자가 `render` 메소드의 동작을 잘못 이해하고 있는 것이 원인입니다.

이 에러를 발생시키는 코드를 보면서 설명하겠습니다.

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

`@book.special?`이 `true`인 경우, Rails는 랜더링을 시작하고, `@book` 변수를 `special_show` 뷰에 넘겨줍니다. 하지만, `show` 액션의 코드가 _종료되지 않는다는_ 점에 주의해야 합니다. `show` 액션의 코드는 메소드의 마지막까지 실행되며, `regular_show` 뷰를 랜더링하려는 시점에서 에러가 발생합니다. 해결법은 간단합니다. 하나의 코드 실행 방법에서 `render` 메소드나 `redirect` 메소드를 단 한번만 실행해주세요. 여기서 무척 편리한 것이 `and return`이라는 메소드입니다. 이 메소드를 사용해서 변경한 코드는 아래와 같습니다.

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

`&& return` 가 아닌 `and return`을 사용해주세요. `&& return`은 루비에서 `&&`의 연산순위가 높기 때문에 여기에서는 정상적으로 동작하지 않습니다.

Rails에 내장되어 있는 ActionController가 수행하는 기본 랜더링(역주: `render`를 호출하지 않았을 경우, 액션명과 같은 뷰를 호출하는 기본 동작을 의미)은 `render` 메소드가 호출이 되었는지 아닌지를 확인하고 나서 랜더링을 시작합니다. 따라서 아래의 코드는 정상적으로 동작합니다.

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

이 코드는 어떤 책이 `special?`일 경우에만 `special_show` 템플릿을 사용합니다. 그 이외의 경우에는 `show` 템플릿을 사용하게 됩니다.

### `redirect_to` 사용하기

HTTP 요청에 응답을 돌려주는 또다른 방법으로는 `redirect_to`를 사용하는 것입니다. 이전에 언급했듯 `render`는 응답을 구성할 경우에 어떤 뷰(또는 애셋)을 사용할지를 지정하는 메소드입니다. `redirect_to` 메소드는 이 부분에 있어서 `render` 메소드와 근본적으로 다릅니다. `redirect_to` 메소드는 다른 URL에 대해서 다시 요청을 전송하도록 브라우저에게 명령을 내립니다. 예를 들어 아래와 같이 사용하면, 애플리케이션에서 현재 어떤 페이지가 나타나 있더라도, 사진 목록을 볼 수 있는 페이지로 리다이렉트됩니다.

```ruby 
redirect_to photos_url
```

`redirect_to`의 인수로는 어떤 값도 지정할 수 있습니다만, `link_to`나 `url_for`를 사용하는 것이 일반적입니다. 유저를 직전 페이지로 되돌려보내는, 특수한 리다이렉트도 가능합니다.

```ruby
redirect_to :back
```

#### 리다이렉트 상태 코드를 변경하기

`redirect_to`를 호출하면 일시적인 페이지 이동을 의미하는 HTTP 상태 코드인 302가 브라우저로 전송되며, 브라우저는 그 정보를 바탕으로 페이지 이동을 합니다. 다른 상태 코드(301: 영구적인 재전송이 자주 쓰입니다)로 변경하기 위해서는 `:status` 옵션을 사용하세요.

```ruby
redirect_to photos_path, status: 301
```

`render`의 `:status` 옵션과 마찬가지로 `redirect_to`의 `:status`도 헤더를 지정할 때에 심볼을 사용할 수 있습니다.

#### `render`와 `redirect_to`의 차이점

때때로, `redirect_to`를 일종의 `goto` 명령어와 같은 것이라고 이해하고 있는 초급 개발자들을 볼 수 있습니다. Rails 코드의 실행위치를 어떤 장소에서 다른 장소로 옮기는 명령이라고 생각하고 있다는 것인데, 이것은 _올바르지 않은_ 생각입니다. `redirect_to`를 실행한 뒤, 코드는 거기서 종료되며, 브라우저에게서 다른 요청을 기다립니다(평소의 요청 대기 상태). 그 직후에 `redirect_to`로 브라우저에 전송된 HTTP 상태 코드 302에 따라서, 다른 URL 요청이 서버로 전송되고 서버는 이 요청을 처리합니다. 그 이외의 처리는 하지 않습니다.

`render`와 `redirect_to`의 차이를 아래의 액션으로 비교해보죠.

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

위의 코드에서는 `@book` 인스턴스 변수가 `nil`일 경우에 문제가 발생할 가능성이 있습니다. `render :action`은 대상이 되는 액션의 코드를 실행하지 않는다는 점을 상기해주세요. 따라서 `index` 뷰에서 필요로 할 `@books` 인스턴스 변수에는 아무것도 설정되지 않고, 아무 것도 없는 서적 목록이 표시되게 됩니다. 이것을 해결하는 방법 중 하나는 render를 redirect로 변경하는 것입니다.

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

이 코드라면, 브라우저에서 index 페이지를 달라는 요청이 새로 전송되기 때문에 `index` 액션의 코드가 정상적으로 실행됩니다.

이 코드에서 한가지 아쉬운 점이 있다면, 브라우저와의 통신을 한번 더 해야한다는 점입니다. 브라우저의 `/books/1` 요청에 대해서 show 액션이 호출되고 책이 하나도 없다는 것을 확인한 뒤, 컨트롤러는 브라우저에 대해서 `/books/`를 요청하라는 상태 코드 302(리다이렉트)를 돌려줍니다. 브라우저는 이 지시를 받고, 이 컨트롤러의 `index` 액션을 호출하기 위한 요청을 전송합니다. 그러면 컨트롤러는 이 요청을 받아서 데이터베이스에 존재하는 모든 서적 목록을 가져온 뒤 index 템플릿을 랜더링하여 결과를 브라우저에게 전송하고, 브라우저는 서적 목록을 보여주게 됩니다.

이 반복된 통신에 의한 지연은 소규모 애플리케이션이라면 별 문제가 없습니다만, 지연이 문제가 되기 시작하게 되면 이 부분을 고쳐야할 필요가 있을 수도 있습니다. 브라우저와의 통신 횟수를 늘리지 않기 위해 개선한 예제는 아래와 같습니다.

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Your book was not found"
    render "index"
  end
end
```

이 코드의 동작은 다음과 같습니다. 지정된 id를 가지는 책이 발견되지 않은 경우에는, 모델에 있는 모든 서적 목록을 `@books` 인스턴스 변수에 보존합니다. 이어서 flash를 이용해 경고 메시지를 추가하고, 마지막으로 `index.html.erb` 템플릿을 랜더링하도록 지시합니다.

### `head`로 본문이 없는 응답 생성하기

`head` 메소드를 사용하면 브라우저에게 본문(body)이 없는 응답을 전송할 수 있습니다. 이 메소드의 이름은 `render :nothing`보다도 동작을 명확히 표현하고 있습니다. `head` 메소드에는 인수로 HTTP 상태 코드를 표현하는 심볼을 넘길 수 있습니다([참조 테이블](#status) 참조). 옵션의 인수는 헤더명과 값을 쌍으로 하는 해시값이라고 해석됩니다. 예를 들어 아래의 코드는 응답으로 에러 헤더만을 전송합니다.

```ruby
head :bad_request
```

이 코드에 의해서 아래와 같은 헤더가 생성됩니다.

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

아래와 같이 헤더에 별도의 정보를 포함할 수도 있습니다.

```ruby
head :created, location: photo_path(@photo)
```

이 코드의 결과는 아래와 같습니다.

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

레이아웃 구성하기
-------------------

Rails가 뷰에서 응답을 생성할 때에, 현재 레이아웃도 거기에 포함됩니다. 현재 레이아웃을 탐색하는 방법은 이 가이드의 위에서 이미 설명한 대로입니다. 레이아웃 내에 존재하는 다양한 조각들을 조합하여 최종적인 응답을 만들기 위해 3가지 도구를 사용합니다.

* Asset tags
* `yield`와 `content_for`
* Partials

### 애셋 태그 헬퍼

애셋 태그 헬퍼가 제공하는 메소드는 피드, JavaScript, 스타일시트, 이미지, 동영상과 음성의 링크를 위한 HTML 생성용입니다. Rails에서는 아래 6개의 애셋 태그 헬퍼를 사용할 수 있습니다.

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

이 태그들은 레이아웃 뿐 아니라 뷰에서도 사용할 수 있습니다. 이 중에서 `auto_discovery_link_tag`, `javascript_include_tag`, `stylesheet_link_tag`는 레이아웃의 `<head>` 부분에서 사용하는 것이 일반적입니다.

WARNING: 이 애셋 태그 헬버들은 지정한 위치에 애셋이 존재하는지 _확인하지 않습니다_.

#### `auto_discovery_link_tag`를 사용해서 피드를 링크하기

`auto_discovery_link_tag` 헬퍼를 사용하면, RSS 피드나, Atom 피드로 연결되는 HTML 태그가 생성됩니다. 이 메소드가 받는 인수로는 링크의 종류(`:rss`나 `:atom`), url_for로 넘길 수 있는 해시, 마지막으로 태그의 옵션을 저장한 해시입니다.

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

`auto_discovery_link_tag`에서는 아래의 3개의 태그 옵션을 사용할 수 있습니다.

* `:rel`은 링크의 `rel` 값을 설정합니다. 기본값은 "alternate"입니다.
* `:type`은 MIME 타입을 명시적으로 지정하고 싶을 때 사용합니다. 일반적으로 Rails는 적절한 MIME 형식을 자동적으로 생성합니다.
* `:title`는 링크의 제목을 지정합니다. 기본으로 `:type`값을 대문자로 변경한 값을 사용하게 됩니다("ATOM"이나 "RSS" 등).

#### `javascript_include_tag`를 사용해서 JavaScript 파일을 링크하기
    
`javascript_include_tag` 헬퍼는 지정된 소스마다 `script` 태그를 생성합니다.

Rails에서 [애셋 파이프라인](asset_pipeline.html)을 사용하는 경우, JavaScript의 링크는 이전 Rails의 `public/javascripts`가 아닌 `/assets/javascripts/`가 됩니다. 그 후, 이 링크는 애셋 파이프라인에 의해서 사용이 가능해집니다.

Rails 애플리케이션 내부나, Rails 엔진 내부의 JavaScript 파일은 `app/assets`, `lib/assets`, `vendor/assets` 중 어딘가에 위치하고 있습니다. 이러한 위치들에 대한 자세한 설명은 애셋 파이프라인 가이드의 [애셋의 구성](asset_pipeline.html#애셋의_구성)을 참조해주세요.

취향에 따라서 상대경로나 URL을 지정할 수도 있습니다. 예를 들어서 `app/assets`, `lib/assets`, 또는 `vendor/assets`에 있는 `javascripts` 폴더에 있는 JavaScript 파일을 링크하고 싶은 경우에는 아래와 같이 쓸 수 있습니다.

```erb
<%= javascript_include_tag "main" %>
```

이 코드에 의해서 아래와 같은 `script` 태그가 생성됩니다.

```html
<script src='/assets/main.js'></script>
```

이 애셋에 대한 요청은 Sprokets 잼이 처리합니다.

복수의 파일을 링크하고 싶은 경우(ex: `app/assets/javascripts/main.js`와 `app/assets/javascripts/columns.js`를 동시에 쓰고 싶을 때), 아래와 같이 작성할 수 있습니다.

```erb
<%= javascript_include_tag "main", "columns" %>
```

`app/assets/javascripts/main.js`와 `app/assets/javascripts/photos/columns.js`를 포함하고 싶은 경우에는 아래와 같이 작성합니다.

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

`http://example.com/main.js`를 포함하고 싶은 경우에는 이렇게 작성할 수 있습니다.

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### `stylesheet_link_tag`를 사용해서 CSS 파일을 링크하기

`stylesheet_link_tag` 헬퍼는 넘겨진 소스마다 `<link>` 태그를 반환합니다.

Rails에서 애셋 파이프라인을 사용하고 있는 경우 이 헬퍼는 `/assets/stylesheets/`에 대한 링크를 생성하며, 이 링크는 Sprokets 잼에 의해서 처리됩니다. 스타일 시트 파일은 `app/assets`, `lib/assets`, 또는 `vendor/assets` 중 한 곳에 둘 수 있습니다.

상대 경로나 URL을 사용할 수도 있습니다. 예를 들어, `app/assets`, `lib/assets`, 또는 `vendor/assets`에 존재하는 `stylesheets` 폴더의 스타일 시트를 링크하고 싶은 경우에는 아래와 같이 작성할 수 있습니다.

```erb
<%= stylesheet_link_tag "main" %>
```

`app/assets/stylesheets/main.css`와 `app/assets/stylesheets/columns.css`를 포함하고 싶을 때에는 다음과 같이 작성합니다.

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

`app/assets/stylesheets/main.css`와 `app/assets/stylesheets/photos/columns.css`를 포함하고 싶을 때에는 다음과 같이 작성합니다.

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

`http://example.com/main.css`를 링크하고 싶을 때에는 다음과 같이 작성합니다.

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

기본적으로 `stylesheet_link_tag`에 의해서 생성되는 링크에는 `media="screen" rel="stylesheet"`라는 속성이 포함되어 있습니다. 적절한 옵션(`:media`, `:rel`)을 사용하면 이 값들을 변경할 수 있습니다.

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### `image_tag`로 이미지를 링크하기

`image_tag`는 어떤 파일을 가리키는 `<img />` 태그를 생성합니다. 기본적으로 파일은 `public/images`에 있다고 가정합니다.

WARNING: 이미지 파일의 확장자는 생략할 수 없습니다.

```erb
<%= image_tag "header.png" %>
```

취향에 맞춰서 이미지 파일의 경로를 직접 지정할 수도 있습니다.

```erb
<%= image_tag "icons/delete.gif" %>
```

해시 형식으로 주어진 HTML 옵션을 추가할 수도 있습니다.

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

사용자가 브라우저에서 이미지 보기를 비활성화하고 있는 경우, alt 속성의 텍스트를 출력하게 됩니다. alt 속성이 명시적으로 지정되어 있지 않은 경우 파일명이 alt의 기본값으로 사용됩니다. 이때 파일명의 첫글자는 대문자가 되며, 확장자는 생략됩니다. 예를 들어 아래 2개의 image_tag 헬퍼는 같은 코드를 반환하게 됩니다.

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

"{너비}x{높이}"라는 형식으로 size 옵션을 지정할 수도 있습니다.

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

위의 특수한 태그 옵션 이외에도 `:class`나 `:id`나 `:name` 같은 표준적인 HTML 옵션을 해시로 만든 뒤 인수로 넘길 수도 있습니다.

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### `video_tag`로 비디오 링크하기

`video_tag` 헬퍼는 지정된 파일의 HTML 5 `<video>` 태그를 생성합니다. 기본적으로 파일은 `public/videos`에 존재한다고 가정합니다.

```erb
<%= video_tag "movie.ogg" %>
```

이 코드로 다음과 같은 태그가 생성됩니다.

```erb
<video src="/videos/movie.ogg" />
```

`image_tag`와 마찬가지로 절대경로, 또는 `public/videos` 폴더로부터 시작하는 상대 경로를 지정할 수 있습니다. 또한 `image_tag`의 경우처럼 `size: "#{너비}x#{높이}"` 옵션을 지정할 수도 있습니다. 물론 비디오 태그에서도 `id`나 `class` 같은 HTML 옵션을 자유롭게 지정할 수 있습니다.

`image_tag`에서는 `<video>`의 HTML 옵션을 아래와 같은 형태로 해시를 통해 지정할 수 있습니다.

* `poster: "image_name.png"`는 비디오 재생 전에 비디오의 위치에 표시하고 싶은 이미지를 지정합니다.
* `autoplay: true`이면 페이지 로딩이 끝나고 비디오를 재생합니다.
* `loop: true`이면 비디오를 마지막까지 재생하고, 재생이 완료되면 처음부터 다시 재생합니다.
* `controls: true`이면 브라우저가 제공하는 비디오 제어 패널을 사용할 수 있게 합니다.
* `autobuffer: true`이면 비디오를 바로 재생할 수 있도록 페이지 로딩시에 미리 버퍼링을 시작합니다.

`video_tag`에 비디오 파일의 배열을 넘기는 것으로 여러개의 비디오를 재생할 수도 있습니다.

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

이 코드에 의해 다음과 같은 태그가 생성됩니다.

```erb
<video><source src="trailer.ogg" /><source src="movie.ogg" /></video>
```

#### `audio_tag`로 음원 파일을 링크하기

`audio_tag`는 지정된 파일의 HTML 5 `<audio>` 태그를 생성합니다. 기본적으로 넘겨진 파일이 `public/audios`에 있을 것이라고 가정합니다.

```erb
<%= audio_tag "music.mp3" %>
```

취향에 따라서 음원 파일의 경로를 직접 지정할 수도 있습니다.

```erb
<%= audio_tag "music/first_song.mp3" %>
```

`:id`나 `:class` 등의 옵션을 해시 형식으로 넘겨줄 수 있습니다.

`video_tag`와 마찬가지로, `audio_tag`에도 아래와 같은 특별한 옵션들이 있습니다.

* `autoplay: true`이면 페이지가 로딩되고나서 음원 파일을 재생합니다.
* `controls: true`이면 브라우저가 제공하는 음원 파일 제어 패널을 사용할 수 있습니다.
* `autobuffer: true`이면 페이지가 로딩되고나서 바로 재생할 수 있도록 파일을 사전에 읽습니다.

### `yield` 이해하기

`yield` 메소드는 레이아웃에서 뷰에 삽입해야할 장소를 지정할 때 사용합니다. `yield`의 가장 단순한 사용법으로는 `yield`를 하나만 사용하고, 지정된 뷰의 컨텐츠 전체를 그 위치에 삽입하는 것입니다.

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

`yield`을 여러 곳에서 호출하는 레이아웃을 작성할 수도 있습니다.

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

뷰의 메인 부분은 언제나 '이름이 없는' `yield`에서 랜더링 됩니다. 컨텐츠를 이름이 붙어있는 `yield`로서 랜더링 하는 경우에는 `content_for` 메소드를 사용합니다.

### `content_for` 사용하기

`content_for` 메소드를 사용하면, 컨텐츠를 이름이 붙은 `yield` 블록으로 호출해 레이아웃에 삽입할 수 있습니다. 예를 들어 아래와 같은 뷰가 있다고 합시다.

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

이 페이지를 위에서 보여드린 레이아웃을 사용해서 랜더링하면 최종적으로 아래와 같은 HTML이 출력됩니다.

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

`content_for` 메소드는 레이아웃이 'sidebar'나 'footer'같은 영역으로 분리되어있고, 각각 다른 컨텐츠를 삽입하고 싶은 상황에서 무척 편리합니다. 또는 많은 페이지에서 사용하는 공통의 헤더가 존재하고, 이 헤더에 특정 페이지에서만 JavaScript나 CSS 파일을 삽입하고 싶은 경우에도 편리합니다.

### 파셜(Partial) 사용하기

파셜 템플릿-간단하게 파셜이라고 부르는 경우가 많습니다-은 위에서 설명한 것과는 다른 방법으로 랜더링을 편하게 만들기 위한 것입니다. 파셜을 사용하면 응답으로 넘겨줄 페이지의 특정 부분을 랜더링 하기 위한 코드를 별도의 파일로 저장할 수 있습니다.

#### 파셜 명명하기

파셜을 뷰에서 사용하려면, 뷰 내에서 `render` 메소드를 호출해야 합니다.

```ruby
<%= render "menu" %>
```

뷰 템플릿에 존재하는 이 코드는 그 장소에서 `_menu.html.erb`라는 이름의 파일을 랜더링합니다. 파셜 파일명은 언더스코어(_)로 시작된다는 점을 주의해주세요. 이것은 일반적인 뷰 템플릿과 구분을 하기 위해서 붙여진 것입니다. 단, render로 호출할 때에 언더스코어를 쓸 필요는 없습니다. 아래와 같이 다른 폴더에 존재하는 파셜을 호출할 때에도 마찬가지입니다.

```ruby
<%= render "shared/menu" %>
```

이 코드는 `app/views/shared/_menu.html.erb` 파셜의 내용을 랜더링하게 됩니다.

#### 파셜을 사용해서 뷰를 간단하게 만들기

파셜의 사용방법중 하나로, 파셜을 일종의 서브 루틴처럼 사용하는 것이 있습니다. 상세한 표시 내용을 파셜로 만들어 뷰에서 추출하여 코드를 읽기 쉽게 만들 수 있습니다. 예를 들어 아래와 같은 뷰가 있다고 합시다.

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

이 코드에서 `_ad_banner.html.erb` 파셜과 `_footer.html.erb` 파셜은 많은 페이지에서 재활용 가능한 컨텐츠를 포함할 수 있습니다. 이렇게 하면, 어떤 페이지를 개발중일때 상세한 부분에 대해서는 신경쓰지 않아도 됩니다.

TIP: 모든 페이지에서 공유되는 컨텐츠라면 파셜을 레이아웃에서 직접 사용해도 좋습니다.

#### 파셜 레이아웃

뷰에 레이아웃이 있는 것처럼, 파셜에도 파셜 용의 레이아웃을 사용할 수 있습니다. 예를 들어, 아래와 같은 파셜을 호출한다고 해봅시다.

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

이 코드는 `_link_area.html.erb` 라는 이름의 파셜을 검색하고, `_graybar.html.erb`라는 이름의 레이아웃을 사용해서 랜더링하게 됩니다. 파셜 레이아웃은 대응하는 일반 파셜과 마찬가지로 파일명의 시작에 언더스코어를 사용해야 하며, 파셜과 그 파셜 레이아웃은 반드시 같은 폴더에 있어야 합니다. 파셜 레이아웃은 `layouts` 폴더에는 놓일 수 없으므로 주의해주세요.

마지막으로 `:layout` 등의 추가 옵션을 넘기고 싶은 경우에는 `:partial` 옵션을 명시적으로 지정해야할 필요가 있습니다.

#### 지역 변수 넘겨주기

파셜을 좀 더 유연하게 사용하기 위해서 지역 변수를 넘길 수 있습니다. 예를 들어 new 페이지와 edit 페이지의 차이가 무척 적다면, 이 방법을 사용해서 코드의 중복을 줄일 수 있습니다.

* `new.html.erb`

    ```html+erb
    <h1>New zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Editing zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_for(zone) do |f| %>
      <p>
        <b>Zone name</b><br>
        <%= f.text_field :name %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    ```

위 2개의 뷰에서는 같은 파셜을 랜더링합니다만 ActionView의 submit 헬퍼는 new 액션인 경우에는 "Create Zone"을 반환하고, edit 액션에서는 "Update Zone"을 반환합니다.

모든 파셜은 언더스코어를 제외한 파셜명과 동일한 이름의 지역 변수를 가집니다. `:object` 옵션을 사용해서 이 지역 변수에 객체를 넘겨줄 수 있습니다.

```erb
<%= render partial: "customer", object: @new_customer %>
```

이 `customer` 파셜 랜더링이 이루어질 때에는 `customer`라는 지역 변수는 부모 뷰의 `@new_customer`를 가리킵니다.

어떤 모델의 인스턴스를 파셜을 통해서 랜더링하고 싶다면, 아래와 같이 간결하게 작성할 수도 있습니다.

```erb
<%= render @customer %>
```

이 코드에서는 `@customer` 인스턴스 변수에 `Customer` 모델의 인스턴스가 들어있습니다. 이 경우 랜더링에는 `_customer.html.erb` 파셜이 사용되며, 이 파셜에 존재하는 `customer`라는 지역 변수는 부모 뷰에 있는 `@customer`를 가리킵니다.

#### 컬렉션 랜더링하기

파셜은 데이터의 반복(컬렉션)을 랜더링할 때에도 무척 유용합니다. `:collection` 옵션을 사용해서 파셜에 컬렉션을 넘겨주면, 컬렉션의 각 멤버마다 파셜을 랜더링하게 됩니다.

* `index.html.erb`

    ```html+erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Product Name: <%= product.name %></p>
    ```

파셜을 호출할 때에 컬렉션 이름이 복수형인 경우, 파셜은 각각의 인스턴스로부터 랜더링할 멤버 객체에 접근합니다. 이때 파셜명에 맞는 이름의 지역 변수가 사용됩니다. 위의 예제의 경우, 파셜의 이름은 `_product`이고, 이 `_product` 파셜 내에서 `product`라는 이름의 변수를 사용해서 랜더링할 객체를 얻을 수 있습니다.

이 메소드는 간단하게 줄여 쓸 수도 있습니다. `@products`가 `product` 인스턴스의 컬렉션이라고 한다면, `index.html.erb`에 아래와 같이 적어도, 위의 코드와 같은 결과를 얻을 수 있습니다.

```html+erb
<h1>Products</h1>
<%= render @products %>
```

사용하는 파셜의 이름은 컬랙션 내부의 모델명을 이용해서 결정됩니다. 사실 멤버가 한 가지 종류의 클래스가 아닌 컬렉션에도 이 방법은 그대로 사용됩니다. 이 경우 컬렉션 멤버에 따라서 적당한 파셜을 자동적으로 선택하게 됩니다.

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

이 코드에서는 컬렉션 멤버의 형태에 따라서 알맞은 customer 파셜과 employee 파셜을 자동적으로 선택합니다.

컬렉션이 비어있는 경우, `render`는 nil을 반환합니다. 아래와 같은 간단한 방법도 괜찮으므로, 대신할 내용을 랜더링하는 것이 좋습니다.

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### 지역 변수

파셜의 지역 변수를 커스터마이즈 하고 싶은 경우에는 파셜 호출시에 `:as` 옵션을 사용하면 됩니다.

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

이 코드에서는 `@products` 컬렉션의 인스턴스를 `item`이라는 이름의 지역 변수를 통해서 접근할 수 있습니다.

그리고 `locals: {}` 옵션을 사용하는 것으로, 어떤 파셜에라도 임의의 이름을 가지는 지역 변수를 넘겨줄 수 있습니다.

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

위의 예제에서는 `title`이라는 이름의 지역 변수에 "Products Page"라는 값이 담기고, 파셜에서 이 값이 접근 할 수 있게 됩니다.

TIP: 컬렉션에 따라, 파셜 내부에서 카운터 변수가 사용되는 경우도 있습니다. 이 카운터 변수는 컬렉션명의 뒤에 `_counter`를 추가한 이름을 사용합니다. 예를 들어 파셜에서 `@products`를 랜더링하는 횟수를 `product_counter` 변수로 참조할 수 있습니다. 단, 이 옵션은 `as: :value` 옵션과 함께 사용할 수 없습니다.

`:spacer_template` 옵션을 사용하면 메인 파셜에서 랜더링되는 각각의 인스턴스들의 사이에 랜더링할 파셜을 지정할 수 있습니다.

#### Spacer Templates

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

이 코드에서는 `_product` 파셜과 각 `_product` 파셜의 사이에 `_product_ruler` 파셜(인수 없음)을 랜더링합니다.

#### 컬렉션 파셜 레이아웃

컬렉션을 렌더링 할 때에도 `:layout` 옵션을 사용할 수 있습니다.

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

이 레이아웃은 컬렉션에서 각 멤버들을 랜더링할 때마다 함께 랜더링 됩니다. 파셜 내부에서 사용 가능한 지역 변수(객체명, 객체명_counter)는 레이아웃에서도 사용할 수 있습니다.

### 중첩된 레이아웃 사용하기

특정 컨트롤러를 위해서 애플리케이션의 표준 레이아웃과 다른 점이 아주 약간 있는 레이아웃을 쓰고 싶은 상황이 때때로 있습니다. 중첩된 레이아웃(서브 템플릿이라고도 부릅니다)을 사용하는 것으로 주 레이아웃을 복사해서 편집할 필요 없이 이를 처리할 수 있습니다.

예를 들어, 아래와 같은 `ApplicationController` 레이아웃이 있다고 합시다.

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

`NewsController`에 의해서 생성되는 페이지에서는 상단 메뉴를 숨기고, 우측에서 메뉴를 보여주고 싶다고 해봅시다.

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

이렇게 하면 됩니다. News 뷰에서 새로운 레이아웃을 사용하게 되며, 상단 메뉴가 숨겨지고 "content" div 태그에 있는 우측 메뉴가 새롭게 추가 됩니다.

이와 같은 결과를 얻을 수 있는 서브 템플릿의 사용법은 이외에도 여러가지가 있습니다. 중첩 횟수에는 제한이 없다는 점을 기억하세요. 예를 들어, News 레이아웃에서 새로운 레이아웃을 사용하기 위해 `render template: 'layouts/news'`를 사용해 `ActionView::render` 메소드를 사용할 수도 있습니다. `News` 레이아웃을 서브 템플릿으로 만들고 싶지 않다면 `content_for?(:news_content) ? yield(:news_content) : yield`를 `yield`로 바꾸기만 하면 됩니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
