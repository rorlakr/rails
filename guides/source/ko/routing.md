[Rails Routing from the Outside In] 외부로부터 들어오는 레일스 라우팅
=================================

본 가이드는 레일스 라우팅의 사용자 접점 기능을 다룹니다. [[[This guide covers the user-facing features of Rails routing.]]]

본 가이드를 읽은 후 다음 내용을 알게 됩니다.[[[After reading this guide, you will know:]]]

* `routes.rb`의 코드를 해석하는 방법. [[[How to interpret the code in `routes.rb`.]]]

* 적절한 리소스풀 스타일(resourceful style) 혹은 `match` 메서드를 사용하여 자신만의 라우트를 구축하는 방법. [[[How to construct your own routes, using either the preferred resourceful style or the `match` method.]]]

* 수신 액션에 요구되는 매개변수. [[[What parameters to expect an action to receive.]]]

* 라우트 헬퍼를 사용, 경로와 URL을 만드는 방법.[[[How to automatically create paths and URLs using route helpers.]]]

* 제약, Rack 엔드포인트와 같은 고급 기술. [[[Advanced techniques such as constraints and Rack endpoints.]]]

--------------------------------------------------------------------------------

[The Purpose of the Rails Router] 레일스 라우터의 목적
-------------------------------

레일스 라우터는 URL을 인식하여 컨트롤러의 액션에 전달합니다. [[[The Rails router recognizes URLs and dispatches them to a controller's action.]]]
또한 경로와 URL을 생성하여 뷰에 문자열을 하드코딩할 필요를 없애줍니다. [[[It can also generate paths and URLs, avoiding the need to hardcode strings in your views.]]]

### [Connecting URLs to Code] 코드에 URL 연결하기

레일스 응용프로그램이 다음과 같은 요청을 받았다면:[[[When your Rails application receives an incoming request for:]]]

```
GET /patients/17
```

레일스는 그 요청이 컨트롤러 액션과 일치하는지 라우터에 문의합니다.[[[it asks the router to match it to a controller action.]]]
만약 처음 매챙되는 라우트가 아래와 같다면: [[[If the first matching route is:]]]

```ruby
get '/patients/:id', to: 'patients#show'
```

요청은 `params` 안의 `{ id: '17' }`로 `patients` 컨트롤러의 `show` 액션에 전달됩니다.[[[the request is dispatched to the `patients` controller's `show` action with `{ id: '17' }` in `params`.]]]

### [Generating Paths and URLs from Code] 코드로부터 경로와 URL 생성하기

경로와 URL을 생성할 수도 있습니다.[[[You can also generate paths and URLs.]]]
위와 같은 라우트는 다음과 같이 수정될 수 있습니다.[[[If the route above is modified to be:]]]

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

그리고 응용프로그램 컨트롤러에 다음 코드를 넣고[[[and your application contains this code in the controller:]]]

```ruby
@patient = Patient.find(17)
```

대응하는 뷰에 다음 코드를 넣습니다.[[[and this in the corresponding view:]]]

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

그러면 라우터는 `/patients/17` 경로를 생성할 것입니다. [[[then the router will generate the path `/patients/17`.]]]
이는 뷰의 불안정성을 줄여주고, 코드를 이해하기 쉽게 해 줍니다.[[[This reduces the brittleness of your view and makes your code easier to understand.]]]
라우터 헬퍼에 id를 지정할 필요가 없다는 점을 주목하십시오. [[[Note that the id does not need to be specified in the route helper.]]]

[Resource Routing: the Rails Default] 리소스 라우팅: 레일스 디폴트
-----------------------------------

리소스풀 라우팅은 주어진 리소스풀 컨트롤러를 위한 모든 일반적인 라우트를 빠르게 선언할 수 있게 해줍니다.[[[Resource routing allows you to quickly declare all of the common routes for a given resourceful controller.]]]
`index`, `show`, `new`, `edit`, `create`, `update` 그리고 `destroy`를 위한 라우트를 개별적으로 선언하는 대신, 리소스풀 라우트는 한 줄의 코드로 모두를 선언합니다. [[[Instead of declaring separate routes for your `index`, `show`, `new`, `edit`, `create`, `update` and `destroy` actions, a resourceful route declares them in a single line of code.]]]

### [Resources on the Web] 웹상의 리소스

브라우저는 `GET`, `POST`, `PATCH`, `PUT` 와 `DELETE`와 같은 특정 HTTP 메서드를 사용하여 만들어진 요청으로 레일스에 페이지를 요청합니다. [[[Browsers request pages from Rails by making a request for a URL using a specific HTTP method, such as `GET`, `POST`, `PATCH`, `PUT` and `DELETE`. ]]]
각각의 메서드는 리소스에 대한 작업을 수행할 수 있는 요청입니다.[[[Each method is a request to perform an operation on the resource.]]]
리소스 라우트는 단일 컨트롤러상 액션에 연관되는 요청의 수를 매핑합니다. [[[A resource route maps a number of related requests to actions in a single controller.]]]

다음과 같이 들어오는 요청을 레일스가 받았다면:[[[When your Rails application receives an incoming request for:]]]

```
DELETE /photos/17
```

레일스는 이 요청을 컨트롤러 액션에 매핑하기 위해 라우터를 요청합니다.[[[it asks the router to map it to a controller action.]]]
만약 첫 번째로 매칭되는 라우트가 아래와 같다면:[[[If the first matching route is:]]]

```ruby
resources :photos
```

레일스는 `params`안에 `{ id: '17' }`를 넣어  `photos` 컨트롤러의 `destroy` 메서드에 보냅니다.[[[Rails would dispatch that request to the `destroy` method on the `photos` controller with `{ id: '17' }` in `params`.]]]

### CRUD, Verbs, and Actions

레일스에서 리소스풀 라우트는 HTTP verbs와 URL을 컨트롤러 액션에 연결하는 매핑을 제공합니다.[[[In Rails, a resourceful route provides a mapping between HTTP verbs and URLs to controller actions.]]]
규칙(컨벤션)에 따라, 각 액션은 데이터베이스의 특정 CRUD 작업에 매핑됩니다.[[[By convention, each action also maps to particular CRUD operations in a database.]]]
라우팅 파일에 다음과 같은 단일 엔트리가 있다면,[[[A single entry in the routing file, such as:]]]

```ruby
resources :photos
```

이것은 응용프로그램에 있는 일곱 개의 다른 라우트를 만들어냅니다. 이들은 모두 `Photos` 컨트롤러에 다음과 같이 매핑됩니다.[[[creates seven different routes in your application, all mapping to the `Photos` controller:]]]

| HTTP Verb | Path             | Action  | Used for                                     |
| --------- | ---------------- | ------- | -------------------------------------------- |
| GET       | /photos          | index   | display a list of all photos                 |
| GET       | /photos/new      | new     | return an HTML form for creating a new photo |
| POST      | /photos          | create  | create a new photo                           |
| GET       | /photos/:id      | show    | display a specific photo                     |
| GET       | /photos/:id/edit | edit    | return an HTML form for editing a photo      |
| PATCH/PUT | /photos/:id      | update  | update a specific photo                      |
| DELETE    | /photos/:id      | destroy | delete a specific photo                      |

노트: 라우터는 HTTP verb와 URL을 인바운드 요청에 매치하기 위해 사용하기 때문에, 네 가지 URL은 일곱 가지 다른 액션에 매핑됩니다.[[[NOTE: Because the router uses the HTTP verb and URL to match inbound requests, four URLs map to seven different actions.]]]

레일스 라우트는 명시된 순서에 따라 매치됩니다. 그래서 `get 'photos/poll'` 위에 `resources :photos`가 있다면 `resources` 행을 위한 `show` 액션의 라우트는 `get` 행보다 먼저 매칭됩니다.[[[NOTE: Rails routes are matched in the order they are specified, so if you have a `resources :photos` above a `get 'photos/poll'` the `show` action's route for the `resources` line will be matched before the `get` line.]]]
이것을 바로잡기 위해서는 `get` 행을 `resources` 행 위로 옮겨서 먼저 매치되도록 해야 합니다.[[[To fix this, move the `get` line **above** the `resources` line so that it is matched first.]]]

### [Path and URL Helpers] 경로와 URL 헬퍼

리소스풀 라우트를 만들면 응용프로그램의 컨트롤러에 여러 개의 헬퍼를 노출하게 됩니다.[[[Creating a resourceful route will also expose a number of helpers to the controllers in your application.]]]
`resources :photos`의 경우라면:[[[In the case of `resources :photos`:]]]

* `photos_path`는 `/photos`를 반환합니다. [[[`photos_path` returns `/photos`]]]

* `new_photo_path`는 `/photos/new`를 반환합니다. [[[`new_photo_path` returns `/photos/new`]]]

* `edit_photo_path(:id)`는 `/photos/:id/edit`를 반환합니다. (예를 들어, `edit_photo_path(10)`는 `/photos/10/edit`를 반환합니다.) [[[`edit_photo_path(:id)` returns `/photos/:id/edit` (for instance, `edit_photo_path(10)` returns `/photos/10/edit`)]]]

* `photo_path(:id)`는 `/photos/:id`를 반환합니다. (예를 들어, `photo_path(10)`는 `/photos/10`를 반환합니다.) [[[`photo_path(:id)` returns `/photos/:id` (for instance, `photo_path(10)` returns `/photos/10`)]]]

이들 핼퍼는 각각 그에 상응하는 `_url` 헬퍼(`photos_url` 같은)를 갖는데, 현재의 호스트, 포트 그리고 경로 접두사와 같은 경로 접두사를 반환합니다. [[[Each of these helpers has a corresponding `_url` helper (such as `photos_url`) which returns the same path prefixed with the current host, port and path prefix.]]]

### [Defining Multiple Resources at the Same Time] 중복 리소스를 한번에 정의하기

하나 이상의 리소스를 위한 라우트를 만들 필요가 있다면, `resources` 단일 호출로 그들 모두를 정의하여 타이핑을 줄일 수 있습니다.[[[If you need to create routes for more than one resource, you can save a bit of typing by defining them all with a single call to `resources`:]]]

```ruby
resources :photos, :books, :videos
```

위 코드는 아래 코드와 완전히 동일하게 작동합니다.[[[This works exactly the same as:]]]

```ruby
resources :photos
resources :books
resources :videos
```

### [Singular Resources] 단수형 리소스

간혹, 당신의 클라이언트가 언제나 ID를 참조하지 않고 조회하는 자원이 있습니다.[[[Sometimes, you have a resource that clients always look up without referencing an ID.]]]
예를 들어, `/profile`로 항상 현재 로그인 된 사용자의 프로파일을 보여주고 싶을 것입니다.[[[For example, you would like `/profile` to always show the profile of the currently logged in user.]]]
이런 경우, `show` 액션에 `profile`(`/profile/:id`을 사용하는 대신)을 매핑하고자 단수형 리소스를 사용할 수 있습니다.[[[In this case, you can use a singular resource to map `/profile` (rather than `/profile/:id`) to the `show` action:]]]

```ruby
get 'profile', to: 'users#show'
```

`String`을 `match`에 전달하면 `controller#action` 형식을 기대할 수 있지만, `Symbol`을 전달하면 직접 액션에 매핑될 것입니다. [[[Passing a `String` to `match` will expect a `controller#action` format, while passing a `Symbol` will map directly to an action:]]]

```ruby
get 'profile', to: :show
```

다음 리소스풀 라우트는: [[[This resourceful route:]]]

```ruby
resource :geocoder
```

응용프로그램에 여섯 개의 다른 라우트를 생성하고, 들은 모두 `Geocoders` 컨트롤러에 매핑됩니다. [[[creates six different routes in your application, all mapping to the `Geocoders` controller:]]]

| HTTP Verb | Path           | Action  | Used for                                      |
| --------- | -------------- | ------- | --------------------------------------------- |
| GET       | /geocoder/new  | new     | return an HTML form for creating the geocoder |
| POST      | /geocoder      | create  | create the new geocoder                       |
| GET       | /geocoder      | show    | display the one and only geocoder resource    |
| GET       | /geocoder/edit | edit    | return an HTML form for editing the geocoder  |
| PATCH/PUT | /geocoder      | update  | update the one and only geocoder resource     |
| DELETE    | /geocoder      | destroy | delete the geocoder resource                  |

노트: 단수형 라우트 (`/account`)와 복수형 라우트 (`/accounts/45`)를 위해 동일 컨트롤러를 사용하고자 할 수 있기 때문에, 단수형 리소스는 복수 컨트롤러에 매핑됩니다. [[[NOTE: Because you might want to use the same controller for a singular route (`/account`) and a plural route (`/accounts/45`), singular resources map to plural controllers.]]]
그래서, 예를 들어, `resource :photo` 와 `resources :photos`는 동일 컨트롤러 (`PhotosController`)에 매핑되는 단수형과 복수형 라우트를 함께 생성합니다. [[[So that, for example, `resource :photo` and `resources :photos` creates both singular and plural routes that map to the same controller (`PhotosController`).]]]

단수형 리소스풀 라우트는 다음과 같은 헬퍼들을 생성합니다. [[[A singular resourceful route generates these helpers:]]]

* `new_geocoder_path`는 `/geocoder/new`를 반환합니다. [[[`new_geocoder_path` returns `/geocoder/new`]]]

* `edit_geocoder_path`는 `/geocoder/edit`를 반환합니다. [[[`edit_geocoder_path` returns `/geocoder/edit`]]]

* `geocoder_path`는 `/geocoder`를 반환합니다. [[[`geocoder_path` returns `/geocoder`]]]

복수형 리소스와 같이, `_url`로 끝나는 동일한 헬퍼들은 호스트, 포트 그리고 경로 접두사를 포함합니다. [[[As with plural resources, the same helpers ending in `_url` will also include the host, port and path prefix.]]]

### [Controller Namespaces and Routing] 컨트롤러 네임스페이스와 라우팅

컨트롤러의 묶음을 네임스페이스 아래 정리하고 싶을 경우가 있습니다. [[[You may wish to organize groups of controllers under a namespace.]]]
일반적으로 관리 용도의 컨트롤러 묶음은 `Admin::` 네임스페이스 아래 두고 싶을 것입니다.[[[Most commonly, you might group a number of administrative controllers under an `Admin::` namespace.]]]
이러한 컨트롤러들을 `app/controllers/admin` 디렉터리 아래 위치시키고, 라우터에서 이들을 그룹으로 묶을 수 있습니다.[[[You would place these controllers under the `app/controllers/admin` directory, and you can group them together in your router:]]]

```ruby
namespace :admin do
  resources :posts, :comments
end
```

이것은 `posts`와 `comments` 컨트롤러를 위한 여러 개의 라우트를 생성합니다.[[[This will create a number of routes for each of the `posts` and `comments` controller.]]]
`Admin::PostsController`를 위해, 레일스는 다음의 라우트를 만들것입니다.[[[For `Admin::PostsController`, Rails will create:]]]

| HTTP Verb | Path                  | Action  | Used for                  |
| --------- | --------------------- | ------- | ------------------------- |
| GET       | /admin/posts          | index   | admin_posts_path          |
| GET       | /admin/posts/new      | new     | new_admin_post_path       |
| POST      | /admin/posts          | create  | admin_posts_path          |
| GET       | /admin/posts/:id      | show    | admin_post_path(:id)      |
| GET       | /admin/posts/:id/edit | edit    | edit_admin_post_path(:id) |
| PATCH/PUT | /admin/posts/:id      | update  | admin_post_path(:id)      |
| DELETE    | /admin/posts/:id      | destroy | admin_post_path(:id)      |

만약 `Admin::PostsController`에 (`/admin` 접두사 없이) `/posts`로 라우트하고 싶다면, 다음과 같이 사용할 수 있습니다. '/[[[If you want to route `/posts` (without the prefix `/admin`) to `Admin::PostsController`, you could use:]]]

```ruby
scope module: 'admin' do
  resources :posts, :comments
end
```

아니면 단일 케이스로:[[[or, for a single case:]]]

```ruby
resources :posts, module: 'admin'
```

만약 (`Admin::` 모듈 접두사 없이) `PostsController`에 `/admin/posts`로 라우트하고 싶다면, 다음과 같이 사용할 수 있습니다.[[[If you want to route `/admin/posts` to `PostsController` (without the `Admin::` module prefix), you could use:]]]

```ruby
scope '/admin' do
  resources :posts, :comments
end
```

혹은 단일 케이스로:[[[or, for a single case:]]]

```ruby
resources :posts, path: '/admin/posts'
```

이러한 각각의 사례에, 명명된 라우트는 `scope`를 사용하지 않은 것과 동일하게 유지됩니다.[[[In each of these cases, the named routes remain the same as if you did not use `scope`.]]]
마지막 사례에 있어, 각각의 경로는 `PostController`에 다음과 같이 매핑됩니다.[[[In the last case, the following paths map to `PostsController`:]]]

| HTTP Verb | Path                  | Action  | Named Helper        |
| --------- | --------------------- | ------- | ------------------- |
| GET       | /admin/posts          | index   | posts_path          |
| GET       | /admin/posts/new      | new     | new_post_path       |
| POST      | /admin/posts          | create  | posts_path          |
| GET       | /admin/posts/:id      | show    | post_path(:id)      |
| GET       | /admin/posts/:id/edit | edit    | edit_post_path(:id) |
| PATCH/PUT | /admin/posts/:id      | update  | post_path(:id)      |
| DELETE    | /admin/posts/:id      | destroy | post_path(:id)      |

### [Nested Resources] 중첩 리소스

논리적으로 다른 리소스의 자식인 리소스를 갖는 것은 일반적인 일입니다. [[[It's common to have resources that are logically children of other resources.]]]
예를 들어, 응용프로그램이 다음과 같은 모델을 포함하고 있다고 가정합니다.[[[For example, suppose your application includes these models:]]]

```ruby
class Magazine < ActiveRecord::Base
  has_many :ads
end

class Ad < ActiveRecord::Base
  belongs_to :magazine
end
```

중첩 라우트는 라우팅의 관계를 캡쳐할 수 있게 해줍니다. [[[Nested routes allow you to capture this relationship in your routing.]]]
이 경우, 다음과 같은 라우트선언을 포함할 수 있습니다. [[[In this case, you could include this route declaration:]]]

```ruby
resources :magazines do
  resources :ads
end
```

magazines를 위한 라우트일 뿐 아니라, 이 선언은 또한 `AdsController`에 ads를 라우트해 줄 것입니다. [[[In addition to the routes for magazines, this declaration will also route ads to an `AdsController`.]]]
ad URL은 magazine을 필요로 합니다.[[[The ad URLs require a magazine:]]]

| HTTP Verb | Path                                 | Action  | Used for                                                                   |
| --------- | ------------------------------------ | ------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | index   | display a list of all ads for a specific magazine                          |
| GET       | /magazines/:magazine_id/ads/new      | new     | return an HTML form for creating a new ad belonging to a specific magazine |
| POST      | /magazines/:magazine_id/ads          | create  | create a new ad belonging to a specific magazine                           |
| GET       | /magazines/:magazine_id/ads/:id      | show    | display a specific ad belonging to a specific magazine                     |
| GET       | /magazines/:magazine_id/ads/:id/edit | edit    | return an HTML form for editing an ad belonging to a specific magazine     |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | update  | update a specific ad belonging to a specific magazine                      |
| DELETE    | /magazines/:magazine_id/ads/:id      | destroy | delete a specific ad belonging to a specific magazine                      |

이것은 또한 `magazine_ads_url`와 `edit_magazine_ad_path` 같은 라우팅 펠퍼를 생성할 것입니다. [[[This will also create routing helpers such as `magazine_ads_url` and `edit_magazine_ad_path`.]]] 
이러한 헬퍼들은 첫 번째 파라미터로서 Magazine의 인스턴스를 갖습니다. (`magazine_ads_url(@magazine)`)[[[These helpers take an instance of Magazine as the first parameter (`magazine_ads_url(@magazine)`).]]]

#### [[[Limits to Nesting]]] 중첨의 제한

만약 원한다면, 다른 충첩된 리소스 안에 리소스를 중첩할 수 있습니다. [[[You can nest resources within other nested resources if you like.]]]
예를 들면: [[[For example:]]]

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

깊게-중첩된 리소스는 급속도로 복잡해집니다. [[[Deeply-nested resources quickly become cumbersome.]]]
이 경우, 예를 들면, 응용프로그램은 경로를 다음과 같이 인식할 것입니다.[[[In this case, for example, the application would recognize paths such as:]]]

```
/publishers/1/magazines/2/photos/3
```

이에 대응하는 라우트 헬퍼는 `publisher_magazine_photo_url`가 될 것이고, 이 헬퍼는 세 레벨의 객체 모두를 지정해야  합니다. [[[The corresponding route helper would be `publisher_magazine_photo_url`, requiring you to specify objects at all three levels.]]]
실제로 이 상황은 유명한 [article](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)에서 제이미스 벅이 제안한 좋은 레일스 디자인을 위한 주먹구구식 방법만큼이나 혼란스럽습니다. [[[[Indeed, this situation is confusing enough that a popular [article](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) by Jamis Buck proposes a rule of thumb for good Rails design:]]]

팁: 리소스는 1 레벨 이상으로 중첩되어서는 안됩니다. [[[TIP: _Resources should never be nested more than 1 level deep._]]]

#### Shallow Nesting

(위에서 추천한 바와 같이) 깊은 중첩을 피하는 한 가지 방법은 부모 아래 범주화된(scoped) 액션의 컬렉션을 생성하여 멤버 액션을 중첩하지 않고, 계층의 의미를 갖는 것입니다.[[[One way to avoid deep nesting (as recommended above) is to generate the collection actions scoped under the parent, so as to get a sense of the hierarchy, but to not nest the member actions.]]]
[[[In other words, to only build routes with the minimal amount of information to uniquely identify the resource, like this:]]]

```ruby
resources :posts do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

This idea strikes a balance between descriptive routes and deep nesting. There exists shorthand syntax to achieve just that, via the `:shallow` option:

```ruby
resources :posts do
  resources :comments, shallow: true
end
```

This will generate the exact same routes as the first example. You can also specify the `:shallow` option in the parent resource, in which case all of the nested resources will be shallow:

```ruby
resources :posts, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

The `shallow` method of the DSL creates a scope inside of which every nesting is shallow. This generates the same routes as the previous example:

```ruby
shallow do
  resources :posts do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

There exists two options for `scope` to customize shallow routes. `:shallow_path` prefixes member paths with the specified parameter:

```ruby
scope shallow_path: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

The comments resource here will have the following routes generated for it:

| HTTP Verb | Path                                   | Named Helper        |
| --------- | -------------------------------------- | ------------------- |
| GET       | /posts/:post_id/comments(.:format)     | post_comments       |
| POST      | /posts/:post_id/comments(.:format)     | post_comments       |
| GET       | /posts/:post_id/comments/new(.:format) | new_post_comment    |
| GET       | /sekret/comments/:id/edit(.:format)    | edit_comment        |
| GET       | /sekret/comments/:id(.:format)         | comment             |
| PATCH/PUT | /sekret/comments/:id(.:format)         | comment             |
| DELETE    | /sekret/comments/:id(.:format)         | comment             |

The `:shallow_prefix` option adds the specified parameter to the named helpers:

```ruby
scope shallow_prefix: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

The comments resource here will have the following routes generated for it:

| HTTP Verb | Path                                   | Named Helper        |
| --------- | -------------------------------------- | ------------------- |
| GET       | /posts/:post_id/comments(.:format)     | post_comments       |
| POST      | /posts/:post_id/comments(.:format)     | post_comments       |
| GET       | /posts/:post_id/comments/new(.:format) | new_post_comment    |
| GET       | /comments/:id/edit(.:format)           | edit_sekret_comment |
| GET       | /comments/:id(.:format)                | sekret_comment      |
| PATCH/PUT | /comments/:id(.:format)                | sekret_comment      |
| DELETE    | /comments/:id(.:format)                | sekret_comment      |

### Routing concerns

Routing Concerns allows you to declare common routes that can be reused inside others resources and routes. To define a concern:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

These concerns can be used in resources to avoid code duplication and share behavior across routes:

```ruby
resources :messages, concerns: :commentable

resources :posts, concerns: [:commentable, :image_attachable]
```

The above is equivalent to:

```ruby
resources :messages do
  resources :comments
end

resources :posts do
  resources :comments
  resources :images, only: :index
end
```

Also you can use them in any place that you want inside the routes, for example in a scope or namespace call:

```ruby
namespace :posts do
  concerns :commentable
end
```

### Creating Paths and URLs From Objects

In addition to using the routing helpers, Rails can also create paths and URLs from an array of parameters. For example, suppose you have this set of routes:

```ruby
resources :magazines do
  resources :ads
end
```

When using `magazine_ad_path`, you can pass in instances of `Magazine` and `Ad` instead of the numeric IDs:

```erb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

You can also use `url_for` with a set of objects, and Rails will automatically determine which route you want:

```erb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

In this case, Rails will see that `@magazine` is a `Magazine` and `@ad` is an `Ad` and will therefore use the `magazine_ad_path` helper. In helpers like `link_to`, you can specify just the object in place of the full `url_for` call:

```erb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

If you wanted to link to just a magazine:

```erb
<%= link_to 'Magazine details', @magazine %>
```

For other actions, you just need to insert the action name as the first element of the array:

```erb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

This allows you to treat instances of your models as URLs, and is a key advantage to using the resourceful style.

### Adding More RESTful Actions

You are not limited to the seven routes that RESTful routing creates by default. If you like, you may add additional routes that apply to the collection or individual members of the collection.

#### Adding Member Routes

To add a member route, just add a `member` block into the resource block:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

This will recognize `/photos/1/preview` with GET, and route to the `preview` action of `PhotosController`, with the resource id value passed in `params[:id]`. It will also create the `preview_photo_url` and `preview_photo_path` helpers.

Within the block of member routes, each route name specifies the HTTP verb that it will recognize. You can use `get`, `patch`, `put`, `post`, or `delete` here. If you don't have multiple `member` routes, you can also pass `:on` to a route, eliminating the block:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

You can leave out the `:on` option, this will create the same member route except that the resource id value will be available in `params[:photo_id]` instead of `params[:id]`.

#### Adding Collection Routes

To add a route to the collection:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

This will enable Rails to recognize paths such as `/photos/search` with GET, and route to the `search` action of `PhotosController`. It will also create the `search_photos_url` and `search_photos_path` route helpers.

Just as with member routes, you can pass `:on` to a route:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

#### Adding Routes for Additional New Actions

To add an alternate new action using the `:on` shortcut:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

This will enable Rails to recognize paths such as `/comments/new/preview` with GET, and route to the `preview` action of `CommentsController`. It will also create the `preview_new_comment_url` and `preview_new_comment_path` route helpers.

TIP: If you find yourself adding many extra actions to a resourceful route, it's time to stop and ask yourself whether you're disguising the presence of another resource.

Non-Resourceful Routes
----------------------

In addition to resource routing, Rails has powerful support for routing arbitrary URLs to actions. Here, you don't get groups of routes automatically generated by resourceful routing. Instead, you set up each route within your application separately.

While you should usually use resourceful routing, there are still many places where the simpler routing is more appropriate. There's no need to try to shoehorn every last piece of your application into a resourceful framework if that's not a good fit.

In particular, simple routing makes it very easy to map legacy URLs to new Rails actions.

### Bound Parameters

When you set up a regular route, you supply a series of symbols that Rails maps to parts of an incoming HTTP request. Two of these symbols are special: `:controller` maps to the name of a controller in your application, and `:action` maps to the name of an action within that controller. For example, consider this route:

```ruby
get ':controller(/:action(/:id))'
```

If an incoming request of `/photos/show/1` is processed by this route (because it hasn't matched any previous route in the file), then the result will be to invoke the `show` action of the `PhotosController`, and to make the final parameter `"1"` available as `params[:id]`. This route will also route the incoming request of `/photos` to `PhotosController#index`, since `:action` and `:id` are optional parameters, denoted by parentheses.

### Dynamic Segments

You can set up as many dynamic segments within a regular route as you like. Anything other than `:controller` or `:action` will be available to the action as part of `params`. If you set up this route:

```ruby
get ':controller/:action/:id/:user_id'
```

An incoming path of `/photos/show/1/2` will be dispatched to the `show` action of the `PhotosController`. `params[:id]` will be `"1"`, and `params[:user_id]` will be `"2"`.

NOTE: You can't use `:namespace` or `:module` with a `:controller` path segment. If you need to do this then use a constraint on :controller that matches the namespace you require. e.g:

```ruby
get ':controller(/:action(/:id))', controller: /admin\/[^\/]+/
```

TIP: By default, dynamic segments don't accept dots - this is because the dot is used as a separator for formatted routes. If you need to use a dot within a dynamic segment, add a constraint that overrides this – for example, `id: /[^\/]+/` allows anything except a slash.

### Static Segments

You can specify static segments when creating a route by not prepending a colon to a fragment:

```ruby
get ':controller/:action/:id/with_user/:user_id'
```

This route would respond to paths such as `/photos/show/1/with_user/2`. In this case, `params` would be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### The Query String

The `params` will also include any parameters from the query string. For example, with this route:

```ruby
get ':controller/:action/:id'
```

An incoming path of `/photos/show/1?user_id=2` will be dispatched to the `show` action of the `Photos` controller. `params` will be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Defining Defaults

You do not need to explicitly use the `:controller` and `:action` symbols within a route. You can supply them as defaults:

```ruby
get 'photos/:id', to: 'photos#show'
```

With this route, Rails will match an incoming path of `/photos/12` to the `show` action of `PhotosController`.

You can also define other defaults in a route by supplying a hash for the `:defaults` option. This even applies to parameters that you do not specify as dynamic segments. For example:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails would match `photos/12` to the `show` action of `PhotosController`, and set `params[:format]` to `"jpg"`.

### Naming Routes

You can specify a name for any route using the `:as` option:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

This will create `logout_path` and `logout_url` as named helpers in your application. Calling `logout_path` will return `/exit`

You can also use this to override routing methods defined by resources, like this:

```ruby
get ':username', to: 'users#show', as: :user
```

This will define a `user_path` method that will be available in controllers, helpers and views that will go to a route such as `/bob`. Inside the `show` action of `UsersController`, `params[:username]` will contain the username for the user. Change `:username` in the route definition if you do not want your parameter name to be `:username`.

### HTTP Verb Constraints

In general, you should use the `get`, `post`, `put` and `delete` methods to constrain a route to a particular verb. You can use the `match` method with the `:via` option to match multiple verbs at once:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

You can match all verbs to a particular route using `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: Routing both `GET` and `POST` requests to a single action has security implications. In general, you should avoid routing all verbs to an action unless you have a good reason to.

### Segment Constraints

You can use the `:constraints` option to enforce a format for a dynamic segment:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

This route would match paths such as `/photos/A12345`, but not `/photos/893`. You can more succinctly express the same route this way:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` takes regular expressions with the restriction that regexp anchors can't be used. For example, the following route will not work:

```ruby
get '/:id', to: 'posts#show', constraints: {id: /^\d/}
```

However, note that you don't need to use anchors because all routes are anchored at the start.

For example, the following routes would allow for `posts` with `to_param` values like `1-hello-world` that always begin with a number and `users` with `to_param` values like `david` that never begin with a number to share the root namespace:

```ruby
get '/:id', to: 'posts#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Request-Based Constraints

You can also constrain a route based on any method on the <a href="action_controller_overview.html#the-request-object">Request</a> object that returns a `String`.

You specify a request-based constraint the same way that you specify a segment constraint:

```ruby
get 'photos', constraints: {subdomain: 'admin'}
```

You can also specify constraints in a block form:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

### Advanced Constraints

If you have a more advanced constraint, you can provide an object that responds to `matches?` that Rails should use. Let's say you wanted to route all users on a blacklist to the `BlacklistController`. You could do:

```ruby
class BlacklistConstraint
  def initialize
    @ips = Blacklist.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

TwitterClone::Application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: BlacklistConstraint.new
end
```

You can also specify constraints as a lambda:

```ruby
TwitterClone::Application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: lambda { |request| Blacklist.retrieve_ips.include?(request.remote_ip) }
end
```

Both the `matches?` method and the lambda gets the `request` object as an argument.

### Route Globbing and Wildcard Segments

Route globbing is a way to specify that a particular parameter should be matched to all the remaining parts of a route. For example:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

This route would match `photos/12` or `/photos/long/path/to/12`, setting `params[:other]` to `"12"` or `"long/path/to/12"`. The fragments prefixed with a star are called "wildcard segments".

Wildcard segments can occur anywhere in a route. For example:

```ruby
get 'books/*section/:title', to: 'books#show'
```

would match `books/some/section/last-words-a-memoir` with `params[:section]` equals `'some/section'`, and `params[:title]` equals `'last-words-a-memoir'`.

Technically, a route can have even more than one wildcard segment. The matcher assigns segments to parameters in an intuitive way. For example:

```ruby
get '*a/foo/*b', to: 'test#index'
```

would match `zoo/woo/foo/bar/baz` with `params[:a]` equals `'zoo/woo'`, and `params[:b]` equals `'bar/baz'`.

NOTE: By requesting `'/foo/bar.json'`, your `params[:pages]` will be equals to `'foo/bar'` with the request format of JSON. If you want the old 3.0.x behavior back, you could supply `format: false` like this:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: If you want to make the format segment mandatory, so it cannot be omitted, you can supply `format: true` like this:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirection

You can redirect any path to another path using the `redirect` helper in your router:

```ruby
get '/stories', to: redirect('/posts')
```

You can also reuse dynamic segments from the match in the path to redirect to:

```ruby
get '/stories/:name', to: redirect('/posts/%{name}')
```

You can also provide a block to redirect, which receives the params and the request object:

```ruby
get '/stories/:name', to: redirect {|params, req| "/posts/#{params[:name].pluralize}" }
get '/stories', to: redirect {|p, req| "/posts/#{req.subdomain}" }
```

Please note that this redirection is a 301 "Moved Permanently" redirect. Keep in mind that some web browsers or proxy servers will cache this type of redirect, making the old page inaccessible.

In all of these cases, if you don't provide the leading host (`http://www.example.com`), Rails will take those details from the current request.

### Routing to Rack Applications

Instead of a String like `'posts#index'`, which corresponds to the `index` action in the `PostsController`, you can specify any <a href="rails_on_rack.html">Rack application</a> as the endpoint for a matcher:

```ruby
match '/application.js', to: Sprockets, via: :all
```

As long as `Sprockets` responds to `call` and returns a `[status, headers, body]`, the router won't know the difference between the Rack application and an action. This is an appropriate use of `via: :all`, as you will want to allow your Rack application to handle all verbs as it considers appropriate.

NOTE: For the curious, `'posts#index'` actually expands out to `PostsController.action(:index)`, which returns a valid Rack application.

### Using `root`

You can specify what Rails should route `'/'` to with the `root` method:

```ruby
root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

You should put the `root` route at the top of the file, because it is the most popular route and should be matched first.

NOTE: The `root` route only routes `GET` requests to the action.

You can also use root inside namespaces and scopes as well.  For example:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### Unicode character routes

You can specify unicode character routes directly. For example:

```ruby
get 'こんにちは', to: 'welcome#index'
```

Customizing Resourceful Routes
------------------------------

While the default routes and helpers generated by `resources :posts` will usually serve you well, you may want to customize them in some way. Rails allows you to customize virtually any generic part of the resourceful helpers.

### Specifying a Controller to Use

The `:controller` option lets you explicitly specify a controller to use for the resource. For example:

```ruby
resources :photos, controller: 'images'
```

will recognize incoming paths beginning with `/photos` but route to the `Images` controller:

| HTTP Verb | Path             | Action  | Named Helper         |
| --------- | ---------------- | ------- | -------------------- |
| GET       | /photos          | index   | photos_path          |
| GET       | /photos/new      | new     | new_photo_path       |
| POST      | /photos          | create  | photos_path          |
| GET       | /photos/:id      | show    | photo_path(:id)      |
| GET       | /photos/:id/edit | edit    | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | update  | photo_path(:id)      |
| DELETE    | /photos/:id      | destroy | photo_path(:id)      |

NOTE: Use `photos_path`, `new_photo_path`, etc. to generate paths for this resource.

For namespaced controllers you can use the directory notation. For example:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

This will route to the `Admin::UserPermissions` controller.

NOTE: Only the directory notation is supported. Specifying the
controller with ruby constant notation (eg. `:controller =>
'Admin::UserPermissions'`) can lead to routing problems and results in
a warning.

### Specifying Constraints

You can use the `:constraints` option to specify a required format on the implicit `id`. For example:

```ruby
resources :photos, constraints: {id: /[A-Z][A-Z][0-9]+/}
```

This declaration constrains the `:id` parameter to match the supplied regular expression. So, in this case, the router would no longer match `/photos/1` to this route. Instead, `/photos/RR27` would match.

You can specify a single constraint to apply to a number of routes by using the block form:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE: Of course, you can use the more advanced constraints available in non-resourceful routes in this context.

TIP: By default the `:id` parameter doesn't accept dots - this is because the dot is used as a separator for formatted routes. If you need to use a dot within an `:id` add a constraint which overrides this - for example `id: /[^\/]+/` allows anything except a slash.

### Overriding the Named Helpers

The `:as` option lets you override the normal naming for the named route helpers. For example:

```ruby
resources :photos, as: 'images'
```

will recognize incoming paths beginning with `/photos` and route the requests to `PhotosController`, but use the value of the :as option to name the helpers.

| HTTP Verb | Path             | Action  | Named Helper         |
| --------- | ---------------- | ------- | -------------------- |
| GET       | /photos          | index   | images_path          |
| GET       | /photos/new      | new     | new_image_path       |
| POST      | /photos          | create  | images_path          |
| GET       | /photos/:id      | show    | image_path(:id)      |
| GET       | /photos/:id/edit | edit    | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | update  | image_path(:id)      |
| DELETE    | /photos/:id      | destroy | image_path(:id)      |

### Overriding the `new` and `edit` Segments

The `:path_names` option lets you override the automatically-generated "new" and "edit" segments in paths:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

This would cause the routing to recognize paths such as:

```
/photos/make
/photos/1/change
```

NOTE: The actual action names aren't changed by this option. The two paths shown would still route to the `new` and `edit` actions.

TIP: If you find yourself wanting to change this option uniformly for all of your routes, you can use a scope.

```ruby
scope path_names: { new: 'make' } do
  # rest of your routes
end
```

### Prefixing the Named Route Helpers

You can use the `:as` option to prefix the named route helpers that Rails generates for a route. Use this option to prevent name collisions between routes using a path scope. For example:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

This will provide route helpers such as `admin_photos_path`, `new_admin_photo_path` etc.

To prefix a group of route helpers, use `:as` with `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

This will generate routes such as `admin_photos_path` and `admin_accounts_path` which map to `/admin/photos` and `/admin/accounts` respectively.

NOTE: The `namespace` scope will automatically add `:as` as well as `:module` and `:path` prefixes.

You can prefix routes with a named parameter also:

```ruby
scope ':username' do
  resources :posts
end
```

This will provide you with URLs such as `/bob/posts/1` and will allow you to reference the `username` part of the path as `params[:username]` in controllers, helpers and views.

### Restricting the Routes Created

By default, Rails creates routes for the seven default actions (index, show, new, create, edit, update, and destroy) for every RESTful route in your application. You can use the `:only` and `:except` options to fine-tune this behavior. The `:only` option tells Rails to create only the specified routes:

```ruby
resources :photos, only: [:index, :show]
```

Now, a `GET` request to `/photos` would succeed, but a `POST` request to `/photos` (which would ordinarily be routed to the `create` action) will fail.

The `:except` option specifies a route or list of routes that Rails should _not_ create:

```ruby
resources :photos, except: :destroy
```

In this case, Rails will create all of the normal routes except the route for `destroy` (a `DELETE` request to `/photos/:id`).

TIP: If your application has many RESTful routes, using `:only` and `:except` to generate only the routes that you actually need can cut down on memory use and speed up the routing process.

### Translated Paths

Using `scope`, we can alter path names generated by resources:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails now creates routes to the `CategoriesController`.

| HTTP Verb | Path                       | Action  | Used for                |
| --------- | -------------------------- | ------- | ----------------------- |
| GET       | /kategorien                | index   | categories_path         |
| GET       | /kategorien/neu            | new     | new_category_path       |
| POST      | /kategorien                | create  | categories_path         |
| GET       | /kategorien/:id            | show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | destroy | category_path(:id)      |

### Overriding the Singular Form

If you want to define the singular form of a resource, you should add additional rules to the `Inflector`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### Using `:as` in Nested Resources

The `:as` option overrides the automatically-generated name for the resource in nested route helpers. For example:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

This will create routing helpers such as `magazine_periodical_ads_url` and `edit_magazine_periodical_ad_path`.

Inspecting and Testing Routes
-----------------------------

Rails offers facilities for inspecting and testing your routes.

### Listing Existing Routes

To get a complete list of the available routes in your application, visit `http://localhost:3000/rails/info/routes` in your browser while your server is running in the **development** environment. You can also execute the `rake routes` command in your terminal to produce the same output.

Both methods will list all of your routes, in the same order that they appear in `routes.rb`. For each route, you'll see:

* The route name (if any)
* The HTTP verb used (if the route doesn't respond to all verbs)
* The URL pattern to match
* The routing parameters for the route

For example, here's a small section of the `rake routes` output for a RESTful route:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

You may restrict the listing to the routes that map to a particular controller setting the `CONTROLLER` environment variable:

```bash
$ CONTROLLER=users rake routes
```

TIP: You'll find that the output from `rake routes` is much more readable if you widen your terminal window until the output lines don't wrap.

### Testing Routes

Routes should be included in your testing strategy (just like the rest of your application). Rails offers three [built-in assertions](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html) designed to make testing routes simpler:

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### The `assert_generates` Assertion

`assert_generates` asserts that a particular set of options generate a particular path and can be used with default routes or custom routes. For example:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### The `assert_recognizes` Assertion

`assert_recognizes` is the inverse of `assert_generates`. It asserts that a given path is recognized and routes it to a particular spot in your application. For example:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

You can supply a `:method` argument to specify the HTTP verb:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### The `assert_routing` Assertion

The `assert_routing` assertion checks the route both ways: it tests that the path generates the options, and that the options generate the path. Thus, it combines the functions of `assert_generates` and `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
