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

리소스 라우팅은 주어진 리소스풀 컨트롤러를 위한 모든 일반적인 라우트를 빠르게 선언할 수 있게 해줍니다.[[[Resource routing allows you to quickly declare all of the common routes for a given resourceful controller.]]]
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

NOTE: 라우터는 HTTP verb와 URL을 인바운드 요청에 매치하기 위해 사용하기 때문에, 네 가지 URL은 일곱 가지 다른 액션에 매핑됩니다.[[[NOTE: Because the router uses the HTTP verb and URL to match inbound requests, four URLs map to seven different actions.]]]

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

### [Defining Multiple Resources at the Same Time] 여러 리소스를 한번에 정의하기

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

NOTE: 단수형 라우트 (`/account`)와 복수형 라우트 (`/accounts/45`)를 위해 동일 컨트롤러를 사용하고자 할 수 있기 때문에, 단수형 리소스는 복수 컨트롤러에 매핑됩니다. [[[NOTE: Because you might want to use the same controller for a singular route (`/account`) and a plural route (`/accounts/45`), singular resources map to plural controllers.]]]
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

### [Nested Resources] 내포 리소스

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

내포 라우트는 라우팅의 관계를 캡쳐할 수 있게 해줍니다. [[[Nested routes allow you to capture this relationship in your routing.]]]
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

#### [[[Limits to Nesting]]] 내포의 제한

만약 원한다면, 다른 충첩된 리소스 안에 리소스를 내포할 수 있습니다. [[[You can nest resources within other nested resources if you like.]]]
예를 들면: [[[For example:]]]

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

깊게-내포된 리소스는 급속도로 복잡해집니다. [[[Deeply-nested resources quickly become cumbersome.]]]
이 경우, 예를 들면, 응용프로그램은 경로를 다음과 같이 인식할 것입니다.[[[In this case, for example, the application would recognize paths such as:]]]

```
/publishers/1/magazines/2/photos/3
```

이에 대응하는 라우트 헬퍼는 `publisher_magazine_photo_url`가 될 것이고, 이 헬퍼는 세 레벨의 객체 모두를 지정해야  합니다. [[[The corresponding route helper would be `publisher_magazine_photo_url`, requiring you to specify objects at all three levels.]]]
실제로 이 상황은 유명한 [article](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)에서 제이미스 벅이 제안한 좋은 레일스 디자인을 위한 주먹구구식 방법만큼이나 혼란스럽습니다. [[[[Indeed, this situation is confusing enough that a popular [article](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) by Jamis Buck proposes a rule of thumb for good Rails design:]]]

TIP: 리소스는 1 레벨 이상으로 내포되어서는 안됩니다. [[[TIP: _Resources should never be nested more than 1 level deep._]]]

#### Shallow Nesting

(위에서 추천한 바와 같이) 깊은 내포를 피하는 한 가지 방법은 부모 아래 범주화된(scoped) 액션의 컬렉션을 생성하여 멤버 액션을 내포하지 않고, 계층의 의미를 갖는 것입니다.[[[One way to avoid deep nesting (as recommended above) is to generate the collection actions scoped under the parent, so as to get a sense of the hierarchy, but to not nest the member actions.]]]
다시 말해, 단지 최소한의 정보로 고유하게 리소스를 식별하는 라우트를 만들는 방법은 다음과 같습니다:[[[In other words, to only build routes with the minimal amount of information to uniquely identify the resource, like this:]]]

```ruby
resources :posts do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

본 아이디어는 기술적인 라우트(descriptive routes)와 깊은 내포 사이에서 절충합니다. [[[This idea strikes a balance between descriptive routes and deep nesting.]]]
그렇게 하기 위한 축약 문법이 있는데, `:shallow` 옵션으로 할 수 있습니다.[[[There exists shorthand syntax to achieve just that, via the `:shallow` option:]]]

```ruby
resources :posts do
  resources :comments, shallow: true
end
```

이 코드는 첫 번째 예제와 완전히 동일한 라우트를 생성할 것입니다. [[[This will generate the exact same routes as the first example.]]] 
또한 `:shallow` 옵션을 부모 리소스에 지정할 수 있는데, 이 경우 모든 내포된 리소스들은 얕아지게 됩니다:[[[You can also specify the `:shallow` option in the parent resource, in which case all of the nested resources will be shallow:]]]

```ruby
resources :posts, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

DSL의 `shallow` 메서드는 모든 내포가 얕아진 범위를 내부에 만듭니다. [[[The `shallow` method of the DSL creates a scope inside of which every nesting is shallow.]]]
이것은 이전 예제와 같은 라우트를 생성합니다. [[[This generates the same routes as the previous example:]]]

```ruby
shallow do
  resources :posts do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

얕은 라우트를 지정하는 `scope`에 대한 두 가지 옵션이 있습니다. [[[There exists two options for `scope` to customize shallow routes.]]]
`:shallow_path`는 명시 파라미터를 갖는 멤버 경로 앞에 옵니다. [[[`:shallow_path` prefixes member paths with the specified parameter:]]]

```ruby
scope shallow_path: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

이 comments 리소스는 다음과 같이 생성된 라우트를 가질 것입니다. [[[The comments resource here will have the following routes generated for it:]]]

| HTTP Verb | Path                                   | Named Helper        |
| --------- | -------------------------------------- | ------------------- |
| GET       | /posts/:post_id/comments(.:format)     | post_comments       |
| POST      | /posts/:post_id/comments(.:format)     | post_comments       |
| GET       | /posts/:post_id/comments/new(.:format) | new_post_comment    |
| GET       | /sekret/comments/:id/edit(.:format)    | edit_comment        |
| GET       | /sekret/comments/:id(.:format)         | comment             |
| PATCH/PUT | /sekret/comments/:id(.:format)         | comment             |
| DELETE    | /sekret/comments/:id(.:format)         | comment             |

`:shallow_prefix` 옵션은 명시된 파라미터를 명명될 헬퍼에 추가합니다. [[[The `:shallow_prefix` option adds the specified parameter to the named helpers:]]]

```ruby
scope shallow_prefix: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

이 comments 리소스는 다음과 같이 생성된 라우트를 가질 것입니다. [[[The comments resource here will have the following routes generated for it:]]]

| HTTP Verb | Path                                   | Named Helper        |
| --------- | -------------------------------------- | ------------------- |
| GET       | /posts/:post_id/comments(.:format)     | post_comments       |
| POST      | /posts/:post_id/comments(.:format)     | post_comments       |
| GET       | /posts/:post_id/comments/new(.:format) | new_post_comment    |
| GET       | /comments/:id/edit(.:format)           | edit_sekret_comment |
| GET       | /comments/:id(.:format)                | sekret_comment      |
| PATCH/PUT | /comments/:id(.:format)                | sekret_comment      |
| DELETE    | /comments/:id(.:format)                | sekret_comment      |

### [Routing concerns] 라우팅 배려

라우팅 배려는 일반 라우트를 선언하여 다른 리소스와 라우트 내에서 재사용될 수 있도록 해줍니다. [[[Routing Concerns allows you to declare common routes that can be reused inside others resources and routes.]]]
배려(concern)를 정의하개 위해서는: [[[To define a concern:]]]

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

이러한 배려들(concerns)은 코드 중복을 피하고 라우크간 행동을 공유하기 위해서 리소스 내부에 사용할 수 있습니다.[[[These concerns can be used in resources to avoid code duplication and share behavior across routes:]]]

```ruby
resources :messages, concerns: :commentable

resources :posts, concerns: [:commentable, :image_attachable]
```

위의 코드는 아래의 것과 동일합니다. [[[The above is equivalent to:]]]

```ruby
resources :messages do
  resources :comments
end

resources :posts do
  resources :comments
  resources :images, only: :index
end
```

또한 그것들을 라우트 안에 넣고자 하는-예를 들어 범위 안이나 네임스페이스 호출의 경우- 어떤 곳에서든 사용할 수 있습니다: [[[Also you can use them in any place that you want inside the routes, for example in a scope or namespace call:]]]

```ruby
namespace :posts do
  concerns :commentable
end
```

### [Creating Paths and URLs From Objects] 객체로부터 경로와 URL 생성하기

라우팅 헬퍼를 사용하는 것 이외에도, 레일스는 또한 매개변수의 배열로부터 경로와 URL을 생성할 수 있습니다. [[[In addition to using the routing helpers, Rails can also create paths and URLs from an array of parameters.]]]
예를 들어, 다음과 같은 라우트 집합이 있다고 가정합니다: [[[For example, suppose you have this set of routes:]]]

```ruby
resources :magazines do
  resources :ads
end
```

`magazine_ad_path`를 사용할 때, 숫자 ID 대신 `Magazine`과 `Ad`의 인스턴스를 전달할 수 있습니다. [[[When using `magazine_ad_path`, you can pass in instances of `Magazine` and `Ad` instead of the numeric IDs:]]]

```erb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

또한 객체의 집합과 함께 `url_for`를 사용할 수 있고, 레일스는 자동으로 어떤 라우트를 원하는지 알아낼 것입니다. [[[You can also use `url_for` with a set of objects, and Rails will automatically determine which route you want:]]]

```erb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

이 경우, 레일스는 `@magazine`이 `Magazine`이고 `@ad`가 `Ad`라고 이해하기 때문에 `magazine_ad_path` 헬퍼를 사용할 것입니다. [[[In this case, Rails will see that `@magazine` is a `Magazine` and `@ad` is an `Ad` and will therefore use the `magazine_ad_path` helper.]]]
`link_to`와 같은 헬퍼에서 전체 `url_for` 호출을 하는 위치에 객체를 지정하기만 해도 됩니다. [[[In helpers like `link_to`, you can specify just the object in place of the full `url_for` call:]]]

```erb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

만약 magazine에 링크를 하고 싶을 뿐이라면: [[[If you wanted to link to just a magazine:]]]

```erb
<%= link_to 'Magazine details', @magazine %>
```

다른 액션을 위해서는, 배열의 첫 번째 요소로 액션 명을 넣어주기만 하면 됩니다. [[[For other actions, you just need to insert the action name as the first element of the array:]]]

```erb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

이것은 모델의 인스턴스를 URL로 취급할 수 있게 해 주며, 이것이 리소스풀 스타일을 사용하는 주요 장점입니다. [[[This allows you to treat instances of your models as URLs, and is a key advantage to using the resourceful style.]]]

### [Adding More RESTful Actions] 더 많은 레스트풀 액션 추가하기

기본으로 레스트풀 라우팅이 만들어내는 일곱 개의 라우팅이 제한되는 것입니다. [[[You are not limited to the seven routes that RESTful routing creates by default.]]]
원한다면, 컬렉션이나 컬렉션의 개별 멤버에 적용할 더 많은 라우트를 추가할 수 있습니다. [[[If you like, you may add additional routes that apply to the collection or individual members of the collection.]]]

#### [Adding Member Routes] 멤버 라우트 추가하기

멤버 라우트를 추가하려면, 리소스 블록 안에 `member` 블록을 추가하기만 하면 됩니다: [[[To add a member route, just add a `member` block into the resource block:]]]

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

이것은 GET 방식으로 `/photos/1/preview`를 인식하고 `params[:id]`로 전달된 값의 리소스 id를 `PhotosController`의 `preview` 액션으로 라우트합니다. [[[This will recognize `/photos/1/preview` with GET, and route to the `preview` action of `PhotosController`, with the resource id value passed in `params[:id]`.]]]
이것은 또한 `preview_photo_url`과 `preview_photo_path` 헬퍼를 생성합니다. [[[It will also create the `preview_photo_url` and `preview_photo_path` helpers.]]]

member 라우트의 블록 내에서, 각 라우트명은 인식할 HTTP verb를 지정합니다. [[[Within the block of member routes, each route name specifies the HTTP verb that it will recognize.]]]
여기에는 `get`, `patch`, `put`, `post`, 혹은 `delete`를 사용할 수 있습니다. [[[You can use `get`, `patch`, `put`, `post`, or `delete` here.]]]
만약 중복된 `member` 라우트가 없다면, 블록을 제거하고 `:on`을 라우트에 전달할 수 있습니다. [[[If you don't have multiple `member` routes, you can also pass `:on` to a route, eliminating the block:]]]

```ruby
resources :photos do
  get 'preview', on: :member
end
```

`:on` 옵션을 생략할 수 있는데, 이것은 리소스 id 값이 `params[:id]` 대신 `params[:photo_id]` 안에서 사용될 것이라는 점을 제외하면 동일한 멤버 라우트를 생성할 것입니다. [[[You can leave out the `:on` option, this will create the same member route except that the resource id value will be available in `params[:photo_id]` instead of `params[:id]`.]]]

#### [Adding Collection Routes] 컬렉션 라우트 추가하기

컬렉션에 라우트를 추가하고자 한다면: [[[To add a route to the collection:]]]

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

이것은 레일스가 GET 방식으로 `/photos/search`와 같은 경로를 인식할 수 있게 해 주고, `PhotosController`의 `search` 액션으로 라우트할 수 있게 해줍니다. [[[This will enable Rails to recognize paths such as `/photos/search` with GET, and route to the `search` action of `PhotosController`.]]]
또한 `search_photos_url`과 `search_photos_path` 라우트 헬퍼를 생성할 것입니다. [[[It will also create the `search_photos_url` and `search_photos_path` route helpers.]]]

멤버 라우트에서와 같이, 라우트에 `:on`을 전달할 수 있습니다. [[[Just as with member routes, you can pass `:on` to a route:]]]

```ruby
resources :photos do
  get 'search', on: :collection
end
```

#### [Adding Routes for Additional New Actions] 부가적인 새 액션을 위한 라우트 추가하기

`:on` 숏컷을 이용하여 다른 새 액션을 추가하고자 한다면: [[[To add an alternate new action using the `:on` shortcut:]]]

```ruby
resources :comments do
  get 'preview', on: :new
end
```

이것은 레일스가 GET 방식으로 `/comments/new/preview`와 같은 경로를 인식할 수 있게 해 주고, `CommentsController`의 `preview` 액션으로 라우트할 수 있게 해 줍니다. [[[This will enable Rails to recognize paths such as `/comments/new/preview` with GET, and route to the `preview` action of `CommentsController`.]]]
또한 `preview_new_comment_url`과 `preview_new_comment_path` 라우트 헬퍼를 생성할 것입니다. [[[It will also create the `preview_new_comment_url` and `preview_new_comment_path` route helpers.]]]

TIP: 만약 리소스풀 라우트에 많은 추가 액션을 추가하고 있다면, 그것을 중단하고 다른 리소스를 숨기고 있는지 반문해야 합니다. [[[TIP: If you find yourself adding many extra actions to a resourceful route, it's time to stop and ask yourself whether you're disguising the presence of another resource.]]]

[Non-Resourceful Routes] 비-리소스풀 라우트
----------------------

리소스 라우팅 이외에도, 레일스는 임의의 URL을 액션으로 라우팅하는 강력한 지원을 합니다. [[[In addition to resource routing, Rails has powerful support for routing arbitrary URLs to actions.]]]
여기에는, 리소스풀 라우팅에 의해 자동 생성된 라우트의 그룹이 없습니다. [[[Here, you don't get groups of routes automatically generated by resourceful routing.]]]
대신, 응용프로그램 안의 각 라우트를 개별적으로 설정합니다.[[[Instead, you set up each route within your application separately.]]]

일반적으로는 리소스풀 라우팅을 사용해야 하지만, 여전히 많은 곳에는 좀더 단순한 라우팅이 적절합니다. [[[While you should usually use resourceful routing, there are still many places where the simpler routing is more appropriate.]]]
적절하지 않은 경우라면, 리소스풀 프레임워크에 응용프로그램의 남은 조각 전부를 쑤셔넣을 필요는 없습니다. [[[There's no need to try to shoehorn every last piece of your application into a resourceful framework if that's not a good fit.]]]

특히, 간단한 라우팅은 레거시 URL을 새로운 레일스 액션에 손쉽게 매핑할 수 있습니다. [[[In particular, simple routing makes it very easy to map legacy URLs to new Rails actions.]]]

### [Bound Parameters] 바인딩된 매개변수

정규 라우트를 설정할 때, 레일스가 들어오는 HTTP 요청 부분을 매핑하는 일련의 심볼을 제공합니다. [[[When you set up a regular route, you supply a series of symbols that Rails maps to parts of an incoming HTTP request.]]]
이들 두 심볼은 특별합니다: `:controller` 심볼은 응용프로그램의 컨트롤러 명에 매핑하고, `:action` 심볼은 컨트롤러 안의 액션명에 매핑합니다. [[[Two of these symbols are special: `:controller` maps to the name of a controller in your application, and `:action` maps to the name of an action within that controller.]]]
예를 들어, 다음 라우트를 고려해 보십시오: [[[For example, consider this route:]]]

```ruby
get ':controller(/:action(/:id))'
```

만약 들어오는 요청 `/photos/show/1`이 (파일 내 이전의 어떤 라우트에도 일지하지 않아) 위 라우트에 의해 처리되었다면, 결과는 `PhotosController`의 `show` 액션을 불러들일 것이고 마지막 매개변수 `"1"`을 `params[:id]`로 사용 가능하게 할 것입니다. [[[If an incoming request of `/photos/show/1` is processed by this route (because it hasn't matched any previous route in the file), then the result will be to invoke the `show` action of the `PhotosController`, and to make the final parameter `"1"` available as `params[:id]`.]]]
`:action`과 `:id`는 괄호로 표시된 선택적 매개변수이기 때문에, 이 라우트는 또한 `/photos`의 들어오는 요청을 `PhotosController#index`에 라우트할 것입니다. [[[This route will also route the incoming request of `/photos` to `PhotosController#index`, since `:action` and `:id` are optional parameters, denoted by parentheses.]]]

### [Dynamic Segments] 동적 세그먼트

정규 라우트 내에는 원하는 만큼 많은 동적 세그먼트를 설정할 수 있습니다. [[[You can set up as many dynamic segments within a regular route as you like.]]]
`:controller`나 `:action` 이외의 어떤 것도 `params`의 일부로 액션에 사용가능할 것입니다. [[[Anything other than `:controller` or `:action` will be available to the action as part of `params`.]]]
만약 다음 라우트를 설정하였다면: [[[If you set up this route:]]]

```ruby
get ':controller/:action/:id/:user_id'
```

`/photos/show/1/2`의 들어오는 경로는 `PhotosController`의 `show` 액션에 보내질 것입니다. [[[An incoming path of `/photos/show/1/2` will be dispatched to the `show` action of the `PhotosController`.]]]
`params[:id]`는 `"1"`, `params[:user_id]`는 2가 될 것입니다. [[[`params[:id]` will be `"1"`, and `params[:user_id]` will be `"2"`.]]]

NOTE: `:controller` 경로 세그먼트와 함께 `:namespace` 혹은 `:module`을 사용할 수 있습니다. 이렇게 해야한다면, 다음과 같이 필요로 하는 네임스페이스와 일치하는 :controller상에 제약을 사용합니다. [[[NOTE: You can't use `:namespace` or `:module` with a `:controller` path segment. If you need to do this then use a constraint on :controller that matches the namespace you require. e.g:]]]

```ruby
get ':controller(/:action(/:id))', controller: /admin\/[^\/]+/
```

TIP: 기본값으로, 동적 세그먼트는 구두점(.)을 받아들이지 않습니다. 왜냐하면 구두점은 형식화된 라우트를 위한 구분자로 사용되기 때문입니다. [[[TIP: By default, dynamic segments don't accept dots - this is because the dot is used as a separator for formatted routes.]]]
만약 동적 세그먼트 안에 구두점을 사용할 필요가 있다면, 이것을 오버라이드하는 제약을 추가하십시오. 예를 들어, `id: /[^\/]+/`는 슬래시(/) 이외의 모든 것을 허용합니다. [[[If you need to use a dot within a dynamic segment, add a constraint that overrides this – for example, `id: /[^\/]+/` allows anything except a slash.]]]

### [Static Segments] 정적 세그먼트

분절의 앞에 콜론을 추가하지 않고 라우트를 만들면 정적 세그먼트를 명시할 수 있습니다. [[[You can specify static segments when creating a route by not prepending a colon to a fragment:]]]

```ruby
get ':controller/:action/:id/with_user/:user_id'
```

위 라우트는 `/photos/show/1/with_user/2`와 같은 경로에 응답할 것입니다.[[[This route would respond to paths such as `/photos/show/1/with_user/2`.]]]
이 경우에, `params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 될 것입니다. [[[In this case, `params` would be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.]]]

### [The Query String] 질의 문자열

`params`은 또한 질의 문자열로부터 어떤 매개변수라도 포함할 것입니다. [[[The `params` will also include any parameters from the query string.]]]
다음 라우트를 예로 들면: [[[For example, with this route:]]]

```ruby
get ':controller/:action/:id'
```

`/photos/show/1?user_id=2`로 들어오는 경로는 `Photos` 컨트롤러의 `show` 액션으로 보내질 것입니다. [[[An incoming path of `/photos/show/1?user_id=2` will be dispatched to the `show` action of the `Photos` controller.]]]
`params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 될 것입니다.[[[`params` will be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.]]]

### [Defining Defaults] 기본값 정의하기

라우트에서 `:controller`과 `:action`을 명시적으로 사용할 필요는 없습니다. [[[You do not need to explicitly use the `:controller` and `:action` symbols within a route.]]]
기본값으로 그들을 제공할 수 있습니다. [[[You can supply them as defaults:]]]

```ruby
get 'photos/:id', to: 'photos#show'
```

위 라우트로, 레일스는 유입되는 경로 `/photos/12`를 `PhotosController`의 `show` 액션에 매칭할 것입니다. [[[With this route, Rails will match an incoming path of `/photos/12` to the `show` action of `PhotosController`.]]]

또한 `:defaults` 옵션의 해시를 제공하여 라우트에 다른 기본값을 정의할 수 있습니다. [[[You can also define other defaults in a route by supplying a hash for the `:defaults` option.]]]
이것도 동적 세그먼트로 지정하지 않은 매개변수에 적용됩니다. 예를 들어: [[[This even applies to parameters that you do not specify as dynamic segments. For example:]]]

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

레일스는 `photos/12`를 `PhotosController`의 `show` 액션에 매칭하고 `params[:format]`을 `"jpg"`로 설정할 것입니다.[[[Rails would match `photos/12` to the `show` action of `PhotosController`, and set `params[:format]` to `"jpg"`.]]]

### [Naming Routes] 명명된 라우트

`:as` 옵션을 사용하면 어떤 라우트에도 이름을 지정할 수 있습니다: [[[You can specify a name for any route using the `:as` option:]]]

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

이것은 응용프로그램에 명명된 헬퍼로서 `logout_path`와 `logout_url`을 생성할 것입니다. [[[This will create `logout_path` and `logout_url` as named helpers in your application.]]] 
`logout_path`를 호출하면 `/exit`를 반환할 것입니다. [[[Calling `logout_path` will return `/exit`]]]

또한 다음과 같이 리소스에 의해 정의된 라우팅 메서드를 오버라이드하기 위해 이것을 사용할 수 있습니다. [[[You can also use this to override routing methods defined by resources, like this:]]]

```ruby
get ':username', to: 'users#show', as: :user
```

이것은 `user_path` 메서드를 정의할 것이고 컨트롤러, `/bob`처럼 라우트로 갈 헬퍼 그리고 뷰에서 사용 가능할 것입니다. [[[This will define a `user_path` method that will be available in controllers, helpers and views that will go to a route such as `/bob`.]]]
`UsersController`의 `show` 액션 내부에서, `params[:username]`는 user의 username을 포함할 것입니다. [[[Inside the `show` action of `UsersController`, `params[:username]` will contain the username for the user.]]]
매개변수 이름이 `:username`이 되기를 원하지 않는다면 라우트 정의에 있는 `:username`을 변경하십시오. [[[Change `:username` in the route definition if you do not want your parameter name to be `:username`.]]]

### [HTTP Verb Constraints] HTTP Verb 제약

일반적으로 특정 verb로 라우트를 제한하기 위해 `get`, `post`, `put` 그리고 `delete`를 사용해야 합니다. [[[In general, you should use the `get`, `post`, `put` and `delete` methods to constrain a route to a particular verb.]]]
한번에 여러 verb를 매칭하려면 `match` 메서드를 `:via` 옵션과 함께 사용할 수 있습니다: [[[You can use the `match` method with the `:via` option to match multiple verbs at once:]]]

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

`via: :all`을 사용하여 모든 verb를 특정 라우트에 매칭시킬 수 있습니다. [[[You can match all verbs to a particular route using `via: :all`:]]]

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: `GET`과 `POST` 두 방식의 요청을 모두 단일 액션에 라우팅하는 것은 보안 문제가 있습니다. [[[NOTE: Routing both `GET` and `POST` requests to a single action has security implications.]]]
일반적으로, 좋은 이유가 있는 것이 아니라면 모든 verb를 액션에 라우팅하는 것은 피해야 합니다. [[[In general, you should avoid routing all verbs to an action unless you have a good reason to.]]]

### [Segment Constraints] 세그먼트 제약

동적 세그먼트를 위한 형식을 강제하기 위해 `:constraints` 옵션을 사용할 수 있습니다.: [[[You can use the `:constraints` option to enforce a format for a dynamic segment:]]]

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

이것은 `/photos/A12345`와 같은 경로를 매칭할 것이지만, `/photos/893`은 그렇지 않을 것입니다.: [[[This route would match paths such as `/photos/A12345`, but not `/photos/893`.]]]
좀더 간결하게 이런 방식으로 같은 라우트를 표현할 수 있습니다.: [[[You can more succinctly express the same route this way:]]]

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints`는 정규 표현식을 갖는데, regexp 앵커(역자주: ^, $, \A, \Z, \z, \G, \b, \B 등)는 사용될 수 없습니다. [[[`:constraints` takes regular expressions with the restriction that regexp anchors can't be used.]]]
예를 들어 다음의 라우트는 작동하지 않을 것입니다. [[[For example, the following route will not work:]]]

```ruby
get '/:id', to: 'posts#show', constraints: {id: /^\d/}
```

하지만, 모든 라우트는 시작점에 고정되어 있기 때문에, 앵커를 사용할 필요가 없다는 점을 주의하십시오. [[[However, note that you don't need to use anchors because all routes are anchored at the start.]]]

예를 들어, 다음의 라우트들은 루트 네임스페이스를 공유하기 위해 `1-hello-world`처럼 항상 숫자로 시작하는 `to_param` 값을 `posts`을 위해 허용하며, `david`처럼 절대 숫자로 시작하지 않는 `to_param` 값을 `users`을 위해 허용할 것입니다. [[[For example, the following routes would allow for `posts` with `to_param` values like `1-hello-world` that always begin with a number and `users` with `to_param` values like `david` that never begin with a number to share the root namespace:]]]

```ruby
get '/:id', to: 'posts#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### [Request-Based Constraints] 요청-기반 제약

`String`을 반환하는 <a href="action_controller_overview.html#the-request-object">요청</a> 객체상의 어떤 메서드에 기반한 라우트를 제한할 수도 있습니다. [[[You can also constrain a route based on any method on the <a href="action_controller_overview.html#the-request-object">Request</a> object that returns a `String`.]]]

세그먼트 제약을 명시하는 것과 같은 방법으로 요청-기반의 제약을 명시할 수 있습니다. [[[You specify a request-based constraint the same way that you specify a segment constraint:]]]

```ruby
get 'photos', constraints: {subdomain: 'admin'}
```

또한 블록 형태의 제한을 지정할 수도 있습니다. [[[You can also specify constraints in a block form:]]]

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

### [Advanced Constraints] 고급 제약

더 고급의 제약을 하고 싶다면, 레일스가 사용할 `matches?`에 응답하는 객체를 제공할 수 있습니다. [[[If you have a more advanced constraint, you can provide an object that responds to `matches?` that Rails should use.]]]
블랙리스트에 있는 모든 사용자를 `BlacklistController`에 라우트하고 싶다고 할 때, 다음과 같이 할 수 있습니다.: [[[Let's say you wanted to route all users on a blacklist to the `BlacklistController`. You could do:]]]

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

또한 제약을 람다로 명시할 수 있습니다: [[[You can also specify constraints as a lambda:]]]

```ruby
TwitterClone::Application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: lambda { |request| Blacklist.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?` 메서드와 람다 양쪽 모두 인수로 `request` 객체를 가져옵니다. [[[Both the `matches?` method and the lambda gets the `request` object as an argument.]]]

### [Route Globbing and Wildcard Segments] 패턴매칭(Globbing) 라우트와 와일드카드 세그먼트

패턴매칭 라우트(Route globbing)은 라우트의 잔여 부분 전체에 매칭되는 특정 매개변수를 지정할 수 있는 방법입니다. 예를 들면: [[[Route globbing is a way to specify that a particular parameter should be matched to all the remaining parts of a route. For example:]]]

```ruby
get 'photos/*other', to: 'photos#unknown'
```

본 라우트는 `photos/12`나 `/photos/long/path/to/12`를 매칭할 것이고, `params[:other]`에 `"12"`나 `"long/path/to/12"`를 설정할 것입니다. [[[This route would match `photos/12` or `/photos/long/path/to/12`, setting `params[:other]` to `"12"` or `"long/path/to/12"`.]]]
별표(*)로 접두 표기된 조각을 "와일드카드 세그먼트"라 부릅니다. [[[The fragments prefixed with a star are called "wildcard segments".]]]

와일드카드 세그먼트는 라우트의 어떤 곳에도 넣을 수 있습니다. 예를 들면: [[[Wildcard segments can occur anywhere in a route. For example:]]]

```ruby
get 'books/*section/:title', to: 'books#show'
```

위 라우트는 `books/some/section/last-words-a-memoir`의 `params[:section]`가 `'some/section'`와 같은 것으로, `params[:title]`가 `'last-words-a-memoir'`와 같은 것으로 하여 매칭됩니다. [[[would match `books/some/section/last-words-a-memoir` with `params[:section]` equals `'some/section'`, and `params[:title]` equals `'last-words-a-memoir'`.]]]

기술적으로, 라우트는 하나 이상의 와일드카드 세그먼트도 가질 수 있습니다. [[[Technically, a route can have even more than one wildcard segment.]]]
연결자(matcher)는 직관적인 방식으로 세그먼트를 매개변수에 할당합니다. 예를 들면: [[[The matcher assigns segments to parameters in an intuitive way. For example:]]]

```ruby
get '*a/foo/*b', to: 'test#index'
```

위 라우트는 `params[:a]`를 `'zoo/woo'`와 같은 것으로, `params[:b]`를 `'bar/baz'`와 같은 것으로 하여 `zoo/woo/foo/bar/baz`를 매칭할 것입니다. [[[would match `zoo/woo/foo/bar/baz` with `params[:a]` equals `'zoo/woo'`, and `params[:b]` equals `'bar/baz'`.]]]

NOTE: `'/foo/bar.json'`를 요청하면, `params[:pages]`는 `'foo/bar'`와 같은 것으로 JSON 형식 요청으로 매칭됩니다. [[[NOTE: By requesting `'/foo/bar.json'`, your `params[:pages]` will be equals to `'foo/bar'` with the request format of JSON.]]]
이전 3.0.x 행동으로 되돌리길 원한다면, 다음과 같이 `format:false`를 제공할 수 있습니다.: [[[If you want the old 3.0.x behavior back, you could supply `format: false` like this:]]]

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: 형식 세그먼트를 필수로 하고, 생략될 수 없게 하고자 한다면, 다음과 같이 `format: true`를 제공할 수 있습니다.: [[[NOTE: If you want to make the format segment mandatory, so it cannot be omitted, you can supply `format: true` like this:]]]

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirection

라우터에 `redirect` 헬퍼를 사용하면 어떤 경로든 다른 경로로 리다이렉트할 수 있습니다.: [[[You can redirect any path to another path using the `redirect` helper in your router:]]]

```ruby
get '/stories', to: redirect('/posts')
```

경로에 리다이렉트될 곳을 매칭하기 위해 동적 세그면트를 재사용할 수도 있습니다.[[[You can also reuse dynamic segments from the match in the path to redirect to:]]]

```ruby
get '/stories/:name', to: redirect('/posts/%{name}')
```

리다이렉트에 params와 request 객체를 수신하는 블록을 제공할 수도 있습니다.: [[[You can also provide a block to redirect, which receives the params and the request object:]]]

```ruby
get '/stories/:name', to: redirect {|params, req| "/posts/#{params[:name].pluralize}" }
get '/stories', to: redirect {|p, req| "/posts/#{req.subdomain}" }
```

이 리다이렉션은 301 "Moved Permanently" 리다이렉트임을 주지하십시오. [[[Please note that this redirection is a 301 "Moved Permanently" redirect.]]]
일부 웹브라우저와 프록시 서버가 이 유형의 리다이렉트를 캐시하고 예전 페이지에 접근하지 못하게 될 수 있음을 명심하십시오. [[[Keep in mind that some web browsers or proxy servers will cache this type of redirect, making the old page inaccessible.]]]

이러한 모든 경우에, 선행 호스트(`http://www.example.com`)을 제공하지 않으면, 레일스는 현재 요청에서 그 내용을 취할 것입니다. [[[In all of these cases, if you don't provide the leading host (`http://www.example.com`), Rails will take those details from the current request.]]]

### Routing to Rack Applications

`PostsController`의 `index` 액션에 대응하는 `'posts#index'`와 같은 문자열 대신, 연결자(matcher)를 위한 엔드포인트로서 특정 <a href="rails_on_rack.html">Rack application</a>를 지정할 수 있습니다.: [[[Instead of a String like `'posts#index'`, which corresponds to the `index` action in the `PostsController`, you can specify any <a href="rails_on_rack.html">Rack application</a> as the endpoint for a matcher:]]]

```ruby
match '/application.js', to: Sprockets, via: :all
```

`Sprockets`가 `call`에 응답하고, `[status, headers, body]`를 반환하는 동안, Rack 응용프로그램과 액션의 차이에 대해 라우터는 알지 못합니다. [[[As long as `Sprockets` responds to `call` and returns a `[status, headers, body]`, the router won't know the difference between the Rack application and an action.]]]
Rack 응용프로그램이 모든 verbs를 적절하게 고려하여 다루도록 허용하기를 바라는 것이 `via: :all`의 적절한 용법입니다. [[[This is an appropriate use of `via: :all`, as you will want to allow your Rack application to handle all verbs as it considers appropriate.]]]

NOTE: `'posts#index'`는 실제로 `PostsController.action(:index)`로 확장되어, 유효한 Rack 응용프로그램을 반환합니다. [[[NOTE: For the curious, `'posts#index'` actually expands out to `PostsController.action(:index)`, which returns a valid Rack application.]]]

### [Using `root`] `root` 사용하기

`root` 메서드를 사용하여 레일스가 `'/'`를 라우트할 지점을 지정할 수 있습니다.: [[[You can specify what Rails should route `'/'` to with the `root` method:]]]

```ruby
root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

`root` 라우트는 파일의 맨 처음에 두어야 하는데, 이것이 가장 일반적인 라우트이고 처음 매칭되어야 하는 것이기 때문입니다. [[[You should put the `root` route at the top of the file, because it is the most popular route and should be matched first.]]]

NOTE: `root` 라우트는 `GET` 요청만 액션으로 라우트합니다. [[[NOTE: The `root` route only routes `GET` requests to the action.]]]

네임스페이스나 스코프 안에 root를 사용할 수도 있습니다. 예를 들면: [[[You can also use root inside namespaces and scopes as well.  For example:]]]

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### [Unicode character routes] 유니코드 캐릭터 라우트

다음과 같이, 직접적으로 유니코드 캐릭터 라우트를 지정할 수 있습니다.: [[[You can specify unicode character routes directly. For example:]]]

```ruby
get 'こんにちは', to: 'welcome#index'
```

Customizing Resourceful Routes
------------------------------

`resources :posts`에 의해 생성된 기본 라우트와 헬버는 일반적으로 잘 돌아갈 것이지만, 어떤 점에서는 그들을 커스터마이즈 하길 원할 수 있습니다. [[[While the default routes and helpers generated by `resources :posts` will usually serve you well, you may want to customize them in some way.]]]
레일스는 리소스 헬퍼의 거의 모든 일반적인 부분들을 가상적으로 커스터마이즈 할 수 있습니다. [[[Rails allows you to customize virtually any generic part of the resourceful helpers.]]]

### [Specifying a Controller to Use] 사용할 컨트롤러 지정하기

`:controller` 옵션은 리소스에 사용할 컨트롤러를 명시적으로 지정할 수 있게 합니다. 예를 들면: [[[The `:controller` option lets you explicitly specify a controller to use for the resource. For example:]]]

```ruby
resources :photos, controller: 'images'
```

위 라우트는 `/photos`로 시작하는 유입 경로를 인식하지만, `Images` 컨트롤러로 라우트합니다. [[[will recognize incoming paths beginning with `/photos` but route to the `Images` controller:]]]

| HTTP Verb | Path             | Action  | Named Helper         |
| --------- | ---------------- | ------- | -------------------- |
| GET       | /photos          | index   | photos_path          |
| GET       | /photos/new      | new     | new_photo_path       |
| POST      | /photos          | create  | photos_path          |
| GET       | /photos/:id      | show    | photo_path(:id)      |
| GET       | /photos/:id/edit | edit    | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | update  | photo_path(:id)      |
| DELETE    | /photos/:id      | destroy | photo_path(:id)      |

NOTE: 이 리소스의 경로를 생성하기 위해 `photos_path`, `new_photo_path` 등을 사용하십시오. [[[NOTE: Use `photos_path`, `new_photo_path`, etc. to generate paths for this resource.]]]

네임스페이스 컨트롤러의 경우 디렉터리 표기를 사용할 수 있습니다. 예를 들면: [[[For namespaced controllers you can use the directory notation. For example:]]]

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

이것은 `Admin::UserPermissions` 컨트롤러로 라우트할 것입니다. [[[This will route to the `Admin::UserPermissions` controller.]]]

NOTE: 디렉터리 표기만 지원됩니다. 루비 상수 표기법(예. `:controller => 'Admin::UserPermissions'`)으로 컨트롤러를 지정하면 라우팅 문제와 경고 결과를 초래할 수 있습니다. [[[NOTE: Only the directory notation is supported. Specifying the controller with ruby constant notation (eg. `:controller => 'Admin::UserPermissions'`) can lead to routing problems and results in a warning.]]]

### [Specifying Constraints] 제약 지정하기

암시적 `id`에 필요한 형식을 지정하기 위해 `:constraints` 옵션을 사용할 수 있습니다. 예를 들면: [[[You can use the `:constraints` option to specify a required format on the implicit `id`. For example:]]]

```ruby
resources :photos, constraints: {id: /[A-Z][A-Z][0-9]+/}
```

이 선언은 제공된 정규 표현식에 일치하는 `:id` 매개변수를 제한합니다. [[[This declaration constrains the `:id` parameter to match the supplied regular expression.]]]
그래서 이 경우에, 라우터는 더이상 `/photos/1`을 이 라우트에 매치하지 않을 것입니다. [[[So, in this case, the router would no longer match `/photos/1` to this route.]]]
대신, `/photos/RR27`은 매치될 것입니다. [[[Instead, `/photos/RR27` would match.]]]

블록 형식을 사용하여 여러 라우트에 적용할 단일 제약을 지정할 수 있습니다.: [[[You can specify a single constraint to apply to a number of routes by using the block form:]]]

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE: 물론, 이 문맥에서 비-리소스풀 라우트 내에 보다 향상된 제약을 사용할 수도 있습니다. [[[NOTE: Of course, you can use the more advanced constraints available in non-resourceful routes in this context.]]]

TIP: 기본적으로 `:id` 매개변수는 구두점(.)을 허용하지 않습니다. 이것은 구두점이 형식화된 라우트에서 구분자로 사용되기 때문입니다. 만약 `:id` 내에 구두점을 사용해야 할 필요가 있다면 이것을 오버라이드한 제약을 추가하십시오. 예를 들어 `id: /[^\/]+/`는 슬래시(/)를 제외한 모든 것을 허용합니다. [[[TIP: By default the `:id` parameter doesn't accept dots - this is because the dot is used as a separator for formatted routes. If you need to use a dot within an `:id` add a constraint which overrides this - for example `id: /[^\/]+/` allows anything except a slash.]]]

### [Overriding the Named Helpers] 명명된 헬퍼 오버리이드하기

`:as` 옵션은 명명된 라우트 헬퍼의 평범한 작명을 오버라이드할 수 있게 해줍니다. 예를 들면: [[[The `:as` option lets you override the normal naming for the named route helpers. For example:]]]

```ruby
resources :photos, as: 'images'
```

이것은 `/photos`로 시작하는 유입 경로를 인식하여 요청을 `PhotosController`로 라우트합니다. 그러나 :as 옵션의 값을 사용하여 헬퍼의 이름을 짓습니다. [[[will recognize incoming paths beginning with `/photos` and route the requests to `PhotosController`, but use the value of the :as option to name the helpers.]]]

| HTTP Verb | Path             | Action  | Named Helper         |
| --------- | ---------------- | ------- | -------------------- |
| GET       | /photos          | index   | images_path          |
| GET       | /photos/new      | new     | new_image_path       |
| POST      | /photos          | create  | images_path          |
| GET       | /photos/:id      | show    | image_path(:id)      |
| GET       | /photos/:id/edit | edit    | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | update  | image_path(:id)      |
| DELETE    | /photos/:id      | destroy | image_path(:id)      |

### [Overriding the `new` and `edit` Segments] `new`와 `edit` 세그먼트 오버라이드하기

`:path_names` 옵션은 경로상 자동 생성된 "new"와 "edit" 세그먼트를 오버라이드할 수 있게 합니다. [[[The `:path_names` option lets you override the automatically-generated "new" and "edit" segments in paths:]]]

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

이것은 라우팅을 다음과 같은 경로로 인식하게 합니다. [[[This would cause the routing to recognize paths such as:]]]

```
/photos/make
/photos/1/change
```

NOTE: 실제 액션명은 이 옵션에 의해 변경되지 않습니다. 두 경로는 여전히 `new`와 `edit` 액션으로 라우트될 것입니다. [[[NOTE: The actual action names aren't changed by this option. The two paths shown would still route to the `new` and `edit` actions.]]]

TIP: 만약 모든 라우트를 이 옵션으로 동일하게 변경하고 싶다면, 스코프를 사용할 수 있습니다. [[[TIP: If you find yourself wanting to change this option uniformly for all of your routes, you can use a scope.]]]

```ruby
scope path_names: { new: 'make' } do
  # rest of your routes
end
```

### [Prefixing the Named Route Helpers] 명명된 라우트 헬퍼에 접두어 붙이기

레일스가 라우트를 위해 생성한 명명된 라우트 헬퍼에 접두어를 붙이기 위해 `:as` 옵션을 사용할 수 있습니다. [[[You can use the `:as` option to prefix the named route helpers that Rails generates for a route.]]]
라우트와 경로 스코프간의 이름 충돌을 방지하려면 이 옵션을 사용하십시오. 예를 들면: [[[Use this option to prevent name collisions between routes using a path scope. For example:]]]

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

이것은 `admin_photos_path`, `new_admin_photo_path` 등과 같은 라우트 헬퍼를 제공할 것입니다. [[[This will provide route helpers such as `admin_photos_path`, `new_admin_photo_path` etc.]]]

라우트 헬퍼 집합에 접두어를 붙이려면, `scope:`와 함께 `:as`를 사용하십시오. [[[To prefix a group of route helpers, use `:as` with `scope`:]]]

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

이것은 `/admin/photos`와 `/admin/accounts`에 매핑되는 `admin_photos_path`와 `admin_accounts_path` 같은 라우트를 생성할 것입니다. [[[This will generate routes such as `admin_photos_path` and `admin_accounts_path` which map to `/admin/photos` and `/admin/accounts` respectively.]]]

NOTE: `namespace` 스코프는 `:module`과 `:path` 접두어와 마찬가지로 `:as`를 자동적으로 추가할 것입니다. [[[NOTE: The `namespace` scope will automatically add `:as` as well as `:module` and `:path` prefixes.]]]

You can prefix routes with a named parameter also:

```ruby
scope ':username' do
  resources :posts
end
```

이것은 `/bob/posts/1`과 같은 URL을 제공할 것이고, 컨트롤러, 헬퍼 그리고 뷰에서 `params[:username]` 경로의 `username`을 참조할 수 있게 할 것입니다. [[[This will provide you with URLs such as `/bob/posts/1` and will allow you to reference the `username` part of the path as `params[:username]` in controllers, helpers and views.]]]

### [Restricting the Routes Created] 라우트 생성 제한하기

기본값으로, 레일스는 응용프로그램 내의 모든 레스트풀 라우트를 위한 일곱 개의 기본 액션(index, show, new, create, edit, update, and destroy) 라우트를 생성합니다.[[[By default, Rails creates routes for the seven default actions (index, show, new, create, edit, update, and destroy) for every RESTful route in your application.]]]
`:only`와 `:except` 옵션을 사용하여 이 행동을 미세 조정할 수 있습니다. [[[You can use the `:only` and `:except` options to fine-tune this behavior.]]]
`:only` 옵션은 레일스에게 지정된 라우트만 생성하도록 요청합니다. [[[The `:only` option tells Rails to create only the specified routes:]]]

```ruby
resources :photos, only: [:index, :show]
```

이제 `/photos`로의 `GET` 요청은 성공할 것이지만, `/photos`로의 `POST` 요청(일반적으로 `create` 액션으로 라우트되는)은 실패할 것입니다. [[[Now, a `GET` request to `/photos` would succeed, but a `POST` request to `/photos` (which would ordinarily be routed to the `create` action) will fail.]]]

`:except` 옵션은 레일스가 생성하지 않아야 할 라우트의 목록을 지정합니다.: [[[The `:except` option specifies a route or list of routes that Rails should _not_ create:]]]

```ruby
resources :photos, except: :destroy
```

이 경우, 레일스는 `destroy`로의 라우트(`/photos/:id`로의 `DELETE` 요청)를 제외한 모든 일반 라우트를 생성할 것입니다. [[[In this case, Rails will create all of the normal routes except the route for `destroy` (a `DELETE` request to `/photos/:id`).]]]

TIP: 만약 응용프로그램이 많은 레스트풀 라우트를 가지고 있다면, `:only`와 `:except`를 사용하여 살제로 필요한 라우트만 생성하는 것은 메모리 사용량을 줄이고 라우팅 프로세서의 속도를 높일 수 있습니다.: [[[TIP: If your application has many RESTful routes, using `:only` and `:except` to generate only the routes that you actually need can cut down on memory use and speed up the routing process.]]]

### [Translated Paths] 번역된 경로

`scope`를 사용하면, 리소스에 의해 생성된 경로명을 변경할 수 있습니다.: [[[Using `scope`, we can alter path names generated by resources:]]]

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

레일스는 이제 `CategoriesController`로의 라우트를 생성합니다. [[[Rails now creates routes to the `CategoriesController`.]]]

| HTTP Verb | Path                       | Action  | Used for                |
| --------- | -------------------------- | ------- | ----------------------- |
| GET       | /kategorien                | index   | categories_path         |
| GET       | /kategorien/neu            | new     | new_category_path       |
| POST      | /kategorien                | create  | categories_path         |
| GET       | /kategorien/:id            | show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | destroy | category_path(:id)      |

### [Overriding the Singular Form] 단수 형식 오버라이드하기

만약 리소스의 단수 형식을 정의하길 원한다면, `Inflector`에 부가 규칙을 더해야 합니다. [[[If you want to define the singular form of a resource, you should add additional rules to the `Inflector`:]]]

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### [Using `:as` in Nested Resources] 내포 리소스에 `:as` 사용하기

`:as` 옵션은 내포 라우트 헬퍼를 위해 자동 생성된 이름을 오버라이드합니다. 예를 들면: [[[The `:as` option overrides the automatically-generated name for the resource in nested route helpers. For example:]]]

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

이것은 `magazine_periodical_ads_url`과 `edit_magazine_periodical_ad_path` 같은 라우팅 헬퍼를 만듭니다. [[[This will create routing helpers such as `magazine_periodical_ads_url` and `edit_magazine_periodical_ad_path`.]]]

[Inspecting and Testing Routes] 라우트를 검사하고 테스트하기
-----------------------------

레일스는 라우트를 검사하고 테스트하기 위한 기능을 제공합니다. [[[Rails offers facilities for inspecting and testing your routes.]]]

### [Listing Existing Routes] 기존 라우트 목록보기

응용프로그램에서 사용가능한 전체 목록을 얻으려면, 서버가 **개발** 환경에서 구동되는 동안 브라우저로 `http://localhost:3000/rails/info/routes`를 방문하십시오. [[[To get a complete list of the available routes in your application, visit `http://localhost:3000/rails/info/routes` in your browser while your server is running in the **development** environment.]]]
또한 터미널에서 `rake routes`를 실행하면 동일한 출력을 만들 수 있습니다. [[[You can also execute the `rake routes` command in your terminal to produce the same output.]]]

두 메서드는 `routes.rb` 내에 나타나는 동일 순서대로 전체 라우트의 목록을 보여줄 것입니다. [[[Both methods will list all of your routes, in the same order that they appear in `routes.rb`.]]]
각각의 라우트에서 다음 내용을 확인할 수 있습니다.:[[[For each route, you'll see:]]]

* 라우트 이름 (만약 있다면) [[[The route name (if any)]]]

* 사용되는 HTTP verb (만약 라우트가 모든 verb에 응답하는 것이 아니라면) [[[The HTTP verb used (if the route doesn't respond to all verbs)]]]

* 매칭될 URL 패턴 [[[The URL pattern to match]]]

* 라우트를 위한 라우팅 매개변수들 [[[The routing parameters for the route]]]

예를 들어, 아래 레스트풀 라우트를 위한 `rake routes`의 작은 부분이 있습니다. [[[For example, here's a small section of the `rake routes` output for a RESTful route:]]]

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

`CONTROLLER` 환경 변수를 설정하여 특정 컨트롤러로 매핑되는 라우트의 목록으로 한정할 수 있습니다. [[[You may restrict the listing to the routes that map to a particular controller setting the `CONTROLLER` environment variable:]]]

```bash
$ CONTROLLER=users rake routes
```

TIP: 터미널 창을 행이 줄바꿈하지 않을 때까지 넓히면 `rake routes`의 출력은 더 읽기 쉬워짐을 확인할 것입니다. [[[TIP: You'll find that the output from `rake routes` is much more readable if you widen your terminal window until the output lines don't wrap.]]]

### [Testing Routes] 라우트 테스트하기

라우트는 (응용 프로그램의 다른 부분과 마찬가지로) 테스팅 전략에 포함되어야 합니다. [[[Routes should be included in your testing strategy (just like the rest of your application).]]]
레일스는 테스트를 보다 간단하게 할 수 있도록 설계된 세 가지 [내장 assertion]을 제공합니다.: (http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html)[[[Rails offers three [built-in assertions](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html) designed to make testing routes simpler:]]]

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### [The `assert_generates` Assertion] `assert_generates` Assertion

`assert_generates`는 옵션의 특정 셋이 특정 경로를 생성하고 기본 라우트 혹은 커스텀 라우트와 함께 사용될 수 있음을 assert 합니다. 예를 들면:[[[`assert_generates` asserts that a particular set of options generate a particular path and can be used with default routes or custom routes. For example:]]]

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### [The `assert_recognizes` Assertion] `assert_recognizes` Assertion

`assert_recognizes`는 `assert_generates`의 반대입니다. [[[`assert_recognizes` is the inverse of `assert_generates`.]]]
주어진 경로가 응용프로그램의 특정 지점을 인식하고 라우트함을 assert 합니다. 예를 들면: [[[It asserts that a given path is recognized and routes it to a particular spot in your application. For example:]]]

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

`:method` 인수를 제공하여 HTTP verb를 지정할 수 있습니다.: [[[You can supply a `:method` argument to specify the HTTP verb:]]]

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### [The `assert_routing` Assertion] `assert_routing` Assertion

`assert_routing`은 양쪽 방법 모두로 라우트를 점검합니다: 이것은 경로가 옵션을 생성하는 것을, 그리고 옵션이 경로를 생성하는 것을 테스트합니다. [[[The `assert_routing` assertion checks the route both ways: it tests that the path generates the options, and that the options generate the path.]]]
따라서, 이것은 `assert_generates`와 `assert_recognizes`의 기능을 합친 것입니다. [[[Thus, it combines the functions of `assert_generates` and `assert_recognizes`:]]]

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
