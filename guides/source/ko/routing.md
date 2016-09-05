Rails 라우팅
=================================

이 가이드에서는 개발자를 대상으로 Rails의 라우팅 기능을 해설합니다.

이 가이드의 내용:

* routes.rb를 읽는 방법
* 직접 라우팅을 작성하는 방법(리소스 베이스의 라우팅을 추천합니다만, match 메소드를 사용한 라우팅도 가능합니다)
* 액션에서 받는 파라미터
* 라우트 헬퍼를 사용해서 경로나 URL을 자동생성하는 방법
* 제한을 추가하거나 Rack 엔드포인트 생성하는 방법

--------------------------------------------------------------------------------

Rails 라우터의 목적
-------------------------------

Rails의 라우터는 요청받은 URL을 인식하고 적절한 컨트롤러의 액션을 매칭합니다. 라우터는 뷰에서 이러한 경로나 URL을 직접 하드 코딩하는 것을 피하기 위한 경로나 URL도 제공합니다.

### URL을 실제 코드와 연결하기

Rails 애플리케이션이 아래와 같은 HTTP 요청을 받았다고 합시다.

```
GET /patients/17
```

이 요청은 특정 컨트롤러의 액션에 매치하도록 라우터에 요구합니다. 처음에 매칭된 것이 아래와 같은 라우팅이라고 해봅시다.

```ruby
get '/patients/:id', to: 'patients#show'
```

이 요청은 patients 컨트롤러의 show 액션에 할당되며, params에는 { id: '17' } 해시가 포함됩니다.

### 코드로부터 경로나 URL을 생성하기

경로나 URL을 생성할 수도 있습니다. 예를 들어 위의 라우팅이 아래와 같이 변경되었다고 해봅시다.

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

그리고 애플리케이션의 컨트롤러에 다음과 같은 코드가 있다고 합시다.

```ruby
@patient = Patient.find(17)
```

이에 대응하는 뷰는 아래와 같습니다.

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

이것으로 라우터에 의해서 /patients/17 라는 경로가 생성됩니다. 이것을 사용하는 것으로 뷰를 유지보수하기 쉬워지며, 코드도 읽기 쉬워집니다. 이 라우트 헬퍼에서는 id를 지정할 필요가 없다는 점을 주목해주세요.

리소스 기반으로 라우팅하기: Rails의 기본
-----------------------------------

리소스 기반의 라우팅(이하 리소스 라우팅)을 사용하는 것으로 리소스 기반으로 구성된 컨트롤러에 대응되는 공통 라우팅을 간단하게 선언할 수 있습니다. RESTful한 라우팅을 선언하는 것으로 컨트롤러의 index, show, new, edit, create, update, destroy 액션을 별도로 선언하지 않고 한줄로 완료할 수 있습니다.

### Web 상의 리소스

브라우저는 Rails로 요청을 전송할 때에 특정 HTTP 메소드(GET, POST, PATCH, PUT, DELETE 등)을 사용해서, URL에 요청을 생성합니다. 위에서 이야기한 HTTP 메소드는 모두다 리소스에 대해 어떤 조작을 실행할 것을 지시하는 요청입니다. 리소스 라우팅에서는 연관된 다양한 요청을 컨트롤러의 각 액션에 매핑합니다.


Rails 애플리케이션이 아래의 HTTP 요청을 받았다고 합시다.

```
DELETE /photos/17
```

이 요청은 라우터에게 특정 컨트롤러에 있는 액션을 맵핑하도록 요구합니다. 처음 매치한 것이 아래와 같은 라우팅이라고 합시다.

```ruby
resources :photos
```

Rails는 이 요청을 photos 컨트롤러에 있는 destroy 액션에 맵핑하고 params 해시에 { id: '17' }를 넣어줍니다.

### CRUD, 동사, 액션

Rails의 리소스 라우팅에서는 (GET, PUT 등의) 각종 HTTP 메서드(verb와 컨트롤러의 액션을 가리키는 URL을 맵핑합니다. 하나의 액션은 데이터베이스 상에서 특정 CRUD (Create/Read/Update/Delete) 조작에 대응하도록 되어있습니다. 예를 들어 아래와 같은 라우팅이 있다고 해봅시다.

```ruby
resources :photos
```

이에 따라 애플리케이션 내에 아래의 7개의 라우팅이 생성되며, 이 모두는 'Photos' 컨트롤러가 처리하게 됩니다.

| HTTP 메서드 | 경로             | 컨트롤러#액션 | 목적                                     |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | 모든 사진 목록을 표시                |
| GET       | /photos/new      | photos#new        | 사진을 1개 생성하기 위한 HTML 양식을 반환 |
| POST      | /photos          | photos#create     | 사진을 1개 생성                           |
| GET       | /photos/:id      | photos#show       | 특정 사진을 보여줌                     |
| GET       | /photos/:id/edit | photos#edit       | 사진 편집용의 HTML 양식을 반환      |
| PATCH/PUT | /photos/:id      | photos#update     | 특정 사진을 갱신                      |
| DELETE    | /photos/:id      | photos#destroy    | 특정 사진을 삭제                      |

NOTE: Rails의 라우터에서는 서버가 받은 요청을 매칭할 때에 HTTP 메서드와 URL을 사용하기 때문에 4종류의 URL(GET/POST/PATCH/DELETE)이 7종류의 서로 다른 액션(index/new/create/show/edit/update/destroy)에 맵핑됩니다.

NOTE: Rails의 라우팅은 라우팅 파일의 '위에서부터 선언된 순서대로' 맵핑됩니다. 그렇기 때문에 `resources :photos`라는 라우팅이 `get 'photos/poll` 보다 앞에 나오게 되면 `resources`행의 `show` 액션이 `get` 선언보다도 우선되기 때문에 `get` 라우팅은 무효화됩니다. 이 문제를 해결하기 위해서는 `get` 행을 `resources`행**보다도 위로** 옮겨주세요. 이렇게 하면 `get`에 매칭되게 됩니다.

### 경로와 URL용 헬퍼

RESTful한 라우팅을 작성하면, 애플리케이션의 컨트롤러에서 많은 헬퍼를 사용할 수 있게 됩니다. `resources :photos`라는 라우팅으로 예를 들어보겠습니다.

* `photos_path`는 `/photos`를 돌려줍니다.
* `new_photo_path`는 `/photos/new`를 돌려줍니다.
* `edit_photo_path(:id)`는 `/photos/:id/edit`를 돌려줍니다(`edit_photo_path(10)`라면 `/photos/10/edit`를 돌려줍니다).
* `photo_path(:id)`는 `/photos/:id`를 돌려줍니다(`photo_path(10)`이라면 `/photos/10`을 돌려줍니다).

이러한 _path 헬퍼에는 각각에 대응하는 `_url` 헬퍼(`photos_url` 등)가 있습니다. _url 헬퍼는 _path의 앞에 현재의 호스트명, 포트번호, 그리고 경로의 접두어가 포함됩니다.

### 복수의 리소스를 동시에 정의하기

리소스를 여러개 정의해야 할 때에는 아래와 같은 방식으로 한번에 정의하여 코딩양을 줄일 수 있습니다.

```ruby
resources :photos, :books, :videos
```

이 표기는 아래와 완전히 동일합니다.

```ruby
resources :photos
resources :books
resources :videos
```

### 단수형 리소스

상황에 따라서는 사용자가 ID를 참조할 필요가 없는 리소스가 필요할 때도 있습니다. 예를 들어, `/profile`에서는 항상 '현재 로그인한 사용자 자신'의 프로파일을 보여주고, 다른 사용자의 id를 참조할 필요가 없습니다. 이러한 경우에는 단수형 리소스(singular resource)를 사용해서 `show`액션에 (`/profile/:id`이 아니고) `/profile`를 맵핑할 수 있습니다.

```ruby
get 'profile', to: 'users#show'
```

`get`의 인수로 `문자열`을 넘기는 경우에는 `컨트롤러#액션` 형식이어야 한다는 전제가 있습니다만, `get`의 인수로 `심볼`을 넘기면 액션에 직접 맵핑됩니다.

```ruby
get 'profile', to: :show
```

다음의 RESTful한 라우팅은,

```ruby
resource :geocoder
```

아래의 6개의 라우팅을 생성하며, 모두 `Geocoders` 컨트롤러에 할당됩니다.

| HTTP 메서드 | 경로             | 컨트롤러#액션 | 목적                                     |
| --------- | -------------- | ----------------- | --------------------------------------------- |
| GET       | /geocoder/new  | geocoders#new     | geocoder 작성용 양식을 반환 |
| POST      | /geocoder      | geocoders#create  | geocoder를 생성                       |
| GET       | /geocoder      | geocoders#show    | 하나뿐인 geocoder 리소스를 표시    |
| GET       | /geocoder/edit | geocoders#edit    | geocoder 수정용 HTML 양식을 반환  |
| PATCH/PUT | /geocoder      | geocoders#update  | 하나뿐인 geocoder 리소스를 갱신    |
| DELETE    | /geocoder      | geocoders#destroy | geocoder 리소스를 삭제                  |

NOTE: 단수형 리소스는 복수형 이름을 가지는 컨트롤러에 맵핑됩니다. 이것은 같은 컨트롤러에서 단수형(`/account`)과 복수형(`/accounts/45`)을 모두 사용하는 경우를 고려해서 입니다. 따라서 `resource :photo`와 `resources :photos`를 선언하면 단수형 라우팅과 복수형 라우팅을 모두 생성하고 같은 컨트롤러(`PhotosController`)에 할당됩니다.

단수형 라우팅을 사용하면 아래의 헬퍼 메소드가 생성됩니다.

* `new_geocoder_path`는 `/geocoder/new`를 반환합니다.
* `edit_geocoder_path`는 `/geocoder/edit`를 반환합니다.
* `geocoder_path`는 `/geocoder`를 반환합니다.

복수형 리소스의 경우와 마찬가지로, 단수형 리소스에서도 `_path` 헬퍼에 대응하는 `_url` 헬퍼를 사용할 수 있습니다. `_url` 헬퍼는 `_path` 결과갚의 앞에 현재의 호스트명, 포트 번호, 경로의 접두어 등을 추가한다는 점이 다릅니다.

WARNING: 어떤 [장기 미해결 버그](https://github.com/rails/rails/issues/1769)가 원인으로 `form_for`에서는 단수형 리소스를 자동으로 처리할 수 없습니다. 이를 해결하기 위해서는 아래와 같은 양식 url을 직접 지정해주세요.

```ruby
form_for @geocoder, url: geocoder_path do |f|
```

### 컨트롤러의 네임 스페이스와 라우팅

컨트롤러를 네임 스페이스에 따라서 그룹으로 묶는 것도 가능합니다. 가장 많이 사용되는 네임 스페이스는 다수의 관리용 컨트롤러들을 묶는 `Admin::` 네임 스페이스일 것입니다. 이 컨트롤러들을 `app/controllers/admin` 폴더에 위치시키고 라우팅을 통해 한 그룹으로 만듭니다.

```ruby
namespace :admin do
  resources :posts, :comments
end
```

이 라우팅에 의해서 `posts` 컨트롤러나 `comments` 컨트롤러에 대한 라우팅이 다수 생성됩니다. 예를 들어 `Admin::PostsController`에 대해 생성되는 라우팅은 아래와 같습니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 네임 스페이스 헬퍼              |
| --------- | --------------------- | ------------------- | ------------------------- |
| GET       | /admin/posts          | admin/posts#index   | admin_posts_path          |
| GET       | /admin/posts/new      | admin/posts#new     | new_admin_post_path       |
| POST      | /admin/posts          | admin/posts#create  | admin_posts_path          |
| GET       | /admin/posts/:id      | admin/posts#show    | admin_post_path(:id)      |
| GET       | /admin/posts/:id/edit | admin/posts#edit    | edit_admin_post_path(:id) |
| PATCH/PUT | /admin/posts/:id      | admin/posts#update  | admin_post_path(:id)      |
| DELETE    | /admin/posts/:id      | admin/posts#destroy | admin_post_path(:id)      |

예외적으로 (`/admin`이 앞에 붙어있지 않은) `/posts`를 `Admin::PostsController`에 라우팅하고 싶은 경우에는 다음과 같이 만들면 됩니다.

```ruby
scope module: 'admin' do
  resources :posts, :comments
end
```

또는 블록을 사용하지 않고 작성할 수도 있습니다.

```ruby
resources :posts, module: 'admin'
```

반대로 `/admin/posts`을 (`Admin::`이 없는) `PostsController`에 라우팅하고 싶은 경우에는 다음과 같이 작성하면 됩니다.

```ruby
scope '/admin' do
  resources :posts, :comments
end
```

아래와 같이 블록을 사용하지 않는 방법도 존재합니다.

```ruby
resources :posts, path: '/admin/posts'
```

어느 경우에도 이름을 붙인 경로(named route)는 `scope`를 사용하지 않은 경우에도 마찬가지라는 점에 주목해주세요. 마지막 예제의 경우, 아래의 경로가 `PostsController`와 연결됩니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 경로 헬퍼              |
| --------- | --------------------- | ----------------- | ------------------- |
| GET       | /admin/posts          | posts#index       | posts_path          |
| GET       | /admin/posts/new      | posts#new         | new_post_path       |
| POST      | /admin/posts          | posts#create      | posts_path          |
| GET       | /admin/posts/:id      | posts#show        | post_path(:id)      |
| GET       | /admin/posts/:id/edit | posts#edit        | edit_post_path(:id) |
| PATCH/PUT | /admin/posts/:id      | posts#update      | post_path(:id)      |
| DELETE    | /admin/posts/:id      | posts#destroy     | post_path(:id)      |

TIP: _`namespace` 블럭 내부에 다른 컨트롤러 명을 사용하고 싶다면 '`get '/foo' => '/foo#index'`'처럼 '/'를 사용하는 절대 컨트롤러 경로로 지정하면 됩니다._

### 중첩된 리소스

때때로 다른 리소스에 자식 리소스를 위치시켜야할 때도 있습니다. 예를 들어, Rails 애플리케이션에 아래와 같은 모델이 있다고 해봅시다.

```ruby
class Magazine < ActiveRecord::Base
  has_many :ads
end

class Ad < ActiveRecord::Base
  belongs_to :magazine
end
```

라우팅을 중첩시켜, 이 관계를 라우팅으로 표현할 수 있습니다. 이 예제의 경우, 아래와 같은 라우팅으로 선언할 수 있습니다.

```ruby 
resources :magazines do
  resources :ads
end
```

이 라우팅에 의해서 잡지(magazine)를 위한 라우팅에 더해 광고(ad)를 `AdsController`에 라우팅할 수 있게 됩니다. 그리고 ad의 URL은 magazine을 요구하게 됩니다.

| HTTP 메서드 | 경로             | 컨트롤러#액션 | 목적                                     |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | 잡지 1권에 포함되는 광고를 모두 표시한다.                          |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | 어떤 잡지에 광고를 추가할 수 있는 HTML 양식을 반환한다. |
| POST      | /magazines/:magazine_id/ads          | ads#create        | 어떤 잡지 1권에 잡지용의 광고를 하나 추가한다.                           |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | 어떤 잡지 1권에 포함되는 광고를 하나 보여준다.                    |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | 어떤 잡지 1권에 포함되는 광고 하나를 수정할 수 있는 HTML 양식을 반환한다.     |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | 어떤 잡지 1권에 포함되는 광고 하나를 갱신한다.                      |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | 어떤 잡지 한권에 포함되는 광고를 하나 삭제한다.                      |

라우팅을 선언하면, 라우트 헬퍼 역시 자동으로 생성됩니다. 헬퍼는 `magazine_ads_url`나 `edit_magazine_ad_path` 같은 이름이 됩니다. 이 헬퍼는 첫 인수로 Magazine 모델의 객체를 하나 받습니다. (`magazine_ads_url(@magazine)`)。

#### 중첩 횟수의 제한

아래처럼 중첩된 리소스에서 다른 리소스를 다시 한번 중첩할 수도 있습니다.

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

쉽게 상상이 갈 거라고 생각합니다만, 중첩이 깊어질수록 다루기가 어려워집니다. 예를 들어 위의 라우팅은 애플리케이션에서 다음과 같은 경로로 인식됩니다.

```
/publishers/1/magazines/2/photos/3
```

이 URL에 대응하는 라우트 헬퍼는 `publisher_magazine_photo_url`이 됩니다. 이 헬퍼를 사용하기 위해서는 매번 3개의 객체를 지정해주어야 할 필요가 있습니다. 중첩이 많아질 수록 라우팅을 다루기 불편해지는 문제에 대해서는 Jamis Buck의 유명한 [글](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)을 참조해주세요. Jamis는 Rails 애플리케이션을 설계할 때에 유용한 규칙을 제안합니다.

TIP: _리소스의 중첩을 두 번 이상 해서는 안됩니다._

#### '얕은' 중첩

앞에서 이야기 했던, 많은 중첩을 피하는 방법으로서 컬렉션(index/new/create와 같은 id를 가지지 않는 액션)만을 부모의 스코프에 생성하는 기법이 있습니다. 이 때, 멤버(show/edit/update/destroy와 같은 id를 필요로 하는 액션)은 중첩하지 않는 것이 포인트입니다. 이를 통해서 컬렉션만을 중첩된 경로로 받아올 수 있습니다. 다시 말해, 아래와 같이 최소한의 정보로 리소스를 표현하는 라우팅을 생성할 수 있다는 의미입니다.

```ruby
resources :posts do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

이 방법은 라우팅의 선언을 복잡하게 만들지 않으며, 많은 중첩을 생성하지 않는 절묘한 밸런스를 유지하고 있습니다. `:shallow` 옵션을 사용하여 이와 동일한 내용을 간단하게 선언할 수 있습니다.

```ruby
resources :posts do
  resources :comments, shallow: true
end
```

이로서 생성되는 라우팅은, 앞에서 보았던 예제와 완전히 동일합니다. 부모 리소스에서 `:shallow` 옵션을 지정하면, 모든 중첩된 리소스들에 대해서 같은 규칙이 적용됩니다.

```ruby
resources :posts, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

DSL (도메인 특화 언어) 중 `shallow` 메소드를 라우팅에 사용하면 모든 중첩이 얕아지는 스코프를 생성할 수 있습니다. 이 블럭 내에서 생성된 라우팅은 모두 얕은(shallow) 라우팅이 생성됩니다.

```ruby
shallow do
  resources :posts do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

`scope` 메소드에서는 '얕은' 라우팅을 커스터마이즈할 수 있는 옵션이 2가지 존재합니다. `:shallow_path` 옵션은 지정된 파라미터를 멤버의 경로의 앞 부분에 추가합니다.

```ruby
scope shallow_path: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

이 경우, comments 리소스의 라우팅은 아래와 같이 구성됩니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 경로 헬퍼              |
| --------- | -------------------------------------- | ----------------- | --------------------- |
| GET       | /posts/:post_id/comments(.:format)     | comments#index    | post_comments_path    |
| POST      | /posts/:post_id/comments(.:format)     | comments#create   | post_comments_path    |
| GET       | /posts/:post_id/comments/new(.:format) | comments#new      | new_post_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)    | comments#edit     | edit_comment_path     |
| GET       | /sekret/comments/:id(.:format)         | comments#show     | comment_path          |
| PATCH/PUT | /sekret/comments/:id(.:format)         | comments#update   | comment_path          |
| DELETE    | /sekret/comments/:id(.:format)         | comments#destroy  | comment_path          |

`:shallow_prefix` 옵션을 사용하면, 지정된 값을 (경로가 아닌) 경로 헬퍼의 앞에 추가합니다.

```ruby
scope shallow_prefix: "sekret" do
  resources :posts do
    resources :comments, shallow: true
  end
end
```

이 경우, comments 리소스의 라우팅은 아래와 같이 생성됩니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 경로 헬퍼              |
| --------- | -------------------------------------- | ----------------- | ------------------------ |
| GET       | /posts/:post_id/comments(.:format)     | comments#index    | post_comments_path    |
| POST      | /posts/:post_id/comments(.:format)     | comments#create   | post_comments_path    |
| GET       | /posts/:post_id/comments/new(.:format) | comments#new      | new_post_comment_path    |
| GET       | /comments/:id/edit(.:format)           | comments#edit     | edit_sekret_comment_path |
| GET       | /comments/:id(.:format)                | comments#show     | sekret_comment_path      |
| PATCH/PUT | /comments/:id(.:format)                | comments#update   | sekret_comment_path      |
| DELETE    | /comments/:id(.:format)                | comments#destroy  | sekret_comment_path      |

### 라우팅의 'concern' 기능

concern을 사용하여, 다른 리소스나 라우팅의 내부에서 사용할 수 있는 공통의 라우팅을 선언할 수 있습니다. concern은 아래와 같이 정의합니다.

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

concern을 이용하면, 같은 라우팅을 반복해서 작성하지 않을 수 있으며, 복수의 라우팅에서 동일한 동작을 공유할 수 있습니다.

```ruby
resources :messages, concerns: :commentable

resources :posts, concerns: [:commentable, :image_attachable]
```

이 코드는 아래와 동일합니다.

```ruby
resources :messages do
  resources :comments
end

resources :posts do
  resources :comments
  resources :images, only: :index
end
```

concern은 라우팅 내에서 어느 곳에 위치시켜도 좋습니다. 스코프나 네임스페이스에서도 마찬가지로 사용할 수 있습니다.

```ruby
namespace :posts do
  concerns :commentable
end
```

### 객체로 경로와 URL 생성하기

라우트 헬퍼를 사용하는 방법 이외에도, 파라미터의 배열에서 경로나 URL을 생성할 수도 있습니다. 예를 들어 아래와 같은 라우팅이 있다고 가정합니다.

```ruby
resources :magazines do
  resources :ads
end
```

`magazine_ad_path`를 사용하면 id를 숫자로 넘기는 대신 `Magazine`와 `Ad` 객체를 넘길 수 있습니다.

```erb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

복수의 객체가 모여있는 집합에 대해서 `url_for`를 사용할 수도 있습니다. 복수의 객체를 넘기더라도 적절한 라우팅을 자동적으로 생성합니다.

```erb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

이 경우, Rails는 `@magazine`이 `Magazine`이고, `@ad`이 `Ad`라는 것을 인식하고, 이에 맞는 `magazine_ad_path` 헬퍼를 호출합니다. 또는, `link_to` 헬퍼에서도 완전한 `url_for` 호출 대신 객체를 넘길 수도 있습니다.

```erb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

1권의 잡지만을 연결하고 싶은 경우에는 아래와 같이 작성하면 됩니다.

```erb
<%= link_to 'Magazine details', @magazine %>
```

이외의 액션일 경우에는, 배열의 첫번째 자리에 액션명을 대입하면 됩니다.

```erb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

이를 통해 모델 객체를 URL처럼 다룰 수 있습니다. 이는 RESTful한 방식을 채용하여 얻을 수 있는 장점 중 하나입니다.

### RESTful한 액션을 더 추가하기

기본으로 생성되는 RESTful한 라우팅은 7개 입니다만, 7개이어야만 한다는 규칙은 없습니다. 필요하다면 컬렉션이나 컬렉션의 각 멤버들에 대해 사용가능한 리소스를 추가할 수 있습니다.

#### 멤버 라우팅을 추가하기

멤버(member) 라우팅을 추가하고 싶은 경우에는 `member` 블록을 리소스 블록에 추가합니다.

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

이 라우팅은 GET 요청과 그에 따른 `/photos/1/preview`를 인식하고, 요청을 `Photos` 컨트롤러의 `preview` 액션에 라우팅하며 리소스 id를 `params[:id]`에 넘겨줍니다. 동시에 `preview_photo_url` 헬퍼와 `preview_photo_path` 헬퍼도 생성됩니다.

member 라우팅 블록 내부에는 다음에 기술할 HTTP 메서드가 지정된 라우팅을 인식할 수 있습니다. 지정 가능한 동사는 `get`, `patch`, `put`, `post`, `delete`입니다. `member` 라우팅이 하나 뿐이라면, 아래와 같이 라우팅에 `:on` 옵션을 지정하여 블록을 생략할 수 있습니다.

```ruby
resources :photos do
  get 'preview', on: :member
end
```

`:on` 옵션을 생략해도 같은 member 라우팅을 생성할 수 있습니다. 다만 이 경우에는 리소스 id를 가져올 때에 `params[:id]`가 아닌 `params[:photo_id]`를 사용하게 됩니다.

#### 컬렉션 라우팅을 추가하기

다음과 같은 방법으로 라우팅에 컬랙션(collection)을 추가할 수 있습니다.

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

이 라우팅은 GET 요청 + `/photos/search` 등의 (id를 사용하지 않는) 경로를 인식하며 요청을 `Photos` 컨트롤러의 `search` 액션으로 던져줍니다. 이 때, `search_photos_url`이나 `search_photos_path` 라우트 헬퍼도 동시에 생성됩니다.

collection 라우팅에서도 member 라우팅과 마찬가지로 `:on` 옵션을 사용할 수 있습니다.

```ruby
resources :photos do
  get 'search', on: :collection
end
```

#### 추가된 액션에 라우팅을 추가하기

`:on` 옵션을 사용해서, 다음과 같은 새 액션을 추가할 수 있습니다.

```ruby
resources :comments do
  get 'preview', on: :new
end
```

이를 통해 GET + `/comments/new/preview`와 같은 경로가 매칭되며, `Comments` 컨트롤러의 `preview` 액션에 라우팅 됩니다. `preview_new_comment_url`나 `preview_new_comment_path`같은 라우트 헬퍼도 동시에 생성됩니다.

TIP: 너무 많은 액션에 대한 라우팅을 추가했다고 생각한다면, 그만 멈추고 거기에 다른 리소스가 숨겨져 있는 것은 아닌지 고민해볼 필요가 있습니다.

Resourceful하지 않은 라우팅
----------------------

Rails에서는 리소스 라우팅을 사용할 때에 임의의 URL을 액션에 라우팅할 수도 있습니다. 이 방식을 사용하는 경우, Resourceful 라우팅처럼 자동으로 라우팅 그룹이 생성되지 않습니다. 따라서 애플리케이션에서 필요한 라우팅을 각각 설정하게 됩니다.

기본적으로 Resourceful 라우팅을 사용하는 것이 좋습니다만, 이러한 단순한 라우팅이 편리한 경우도 많습니다. Resourceful 라우팅 때문에 복잡해질 수 있다면, 애플리케이션에서 무리해서 사용할 필요는 없습니다.

이 방식은 이전의 URL을 새로운 Rails 액션으로 매핑하는 작업을 간단하게 만들어 줍니다.

### 파라미터 나누기

일반적인 라우팅을 설정한다면, Rails가 브라우저로부터 받은 HTTP 요청을 라우팅에 매칭하기 위한 심볼을 몇 개 넘깁니다. 이 심볼 중 `:controller`와 `:action`은 애플리케이션의 컨트롤러와 액션에 각각 매칭됩니다. 아래의 예제를 보시죠.

```ruby
get ':controller(/:action(/:id))'
```

브라우저에서 보낸 `/photos/show/1` 요청은 위의 라우팅으로 처리하게 된다면, `Photos` 컨트롤러의 `show` 액션이 호출되며, URL의 마지막에 있는 `"1"`은 `params[:id]`를 통해 접근할 수 있습니다. `:action`과 `:id`가 필수가 아니라는 점을 ()로 표현하고 있으므로, 이 라우팅은 `/photos`를 `PhotosController#index`로 넘겨줄 수도 있습니다.

### 동적인 세그먼트

일반 라우팅의 일부로서, 문자열을 고정하지 않는 동적인 세그먼트를 자유롭게 사용할 수 있습니다. `:controller`나 `:action`을 제외한 어떤 것이라도 `params`에 포함시켜 액션에 건네줄 수 있습니다. 아래와 같은 라우팅을 선언했다고 가정합시다.

```ruby
get ':controller/:action/:id/:user_id'
```

브라우저에서의 `/photos/show/1/2` 경로는 `Photos` 컨트롤러의 `show` 액션에 매칭됩니다. 이 경우에는 `params[:id]`에는 `"1"`, `params[:user_id]`에는 `"2"`가 저장됩니다.

NOTE: `:controller` 경로 세그먼트를 사용하는 경우 `:namespace`나 `:module`를 함께 사용할 수 없습니다. 반드시 사용하고 싶다면, 아래와 같이 필요한 네임스페이스에서만 :controller`에 제약을 추가합니다.

```ruby
get ':controller(/:action(/:id))', controller: /admin\/[^\/]+/
```

TIP: 동적인 세그먼트 분할에서는 기본적으로 마침표(`.`)을 사용할 수 없습니다. 이는 마침표가 라우팅에서 포맷을 구분하기 위한 용도로 사용되고 있기 때문입니다. 반드시 동적 세그먼트 내에서 마침표를 쓰고 싶은 때에는 기본 설정을 덮어써야합니다. 예를 들어 `id: /[^\/]+/`라고 사용한다면 슬래시 이외의 모든 문자를 사용할 수 있습니다.

### 정적인 세그먼트

라우트 선언시에 콜론을 사용하지 않은 경우, 정적인 세그먼트가 되어 고정 문자열을 사용하게 됩니다.

```ruby
get ':controller/:action/:id/with_user/:user_id'
```

이 라우팅에서는 `/photos/show/1/with_user/2`와 같은 경로가 매칭됩니다. `with_user`는 그대로 사용되고 있습니다. 이 때 액션에서 사용할 수 있는 `params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 됩니다.

### 쿼리 문자열

쿼리 문자열으로 지정되어있는 파라미터도 모두 `params`에 포함됩니다. 아래의 라우팅으로 예를 들어 보겠습니다.

```ruby
get ':controller/:action/:id'
```

브라우저에서 `/photos/show/1?user_id=2`라는 경로를 요청받으면 `Photos` 컨트롤러의 `show` 액션에 매칭됩니다. 이 때 `params`는 `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`가 됩니다.

### 기본 설정을 정의하기

`:controller` 심볼이나 `:action` 심볼은 라우팅 내에서 명시적으로 지정할 필요가 없습니다. 이 들은 아래와 같이 기본으로 지정할 수 있습니다.

```ruby
get 'photos/:id', to: 'photos#show'
```

이 라우팅은 `/photos/12`라는 경로에 매칭되며, `Photos` 컨트롤러의 `show` 액션에 할당됩니다.

`:defaults` 옵션에 해시를 넘기는 것으로 추가 기본 설정을 정의할 수도 있습니다. 이 정의는 동적 세그먼트로서 지정하지 않은 파라미터에 대해서도 적용됩니다. 예를 들면,

```ruby 
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

이 경로는 `photos/12`에 매칭되며 `Photos` 컨트롤러의 `show` 액선에 할당되며, `params[:format]`에는 `"jpg"`가 할당됩니다.

### 이름이 있는 라우팅

`:as` 옵션을 사용하여 라우팅에 이름을 지정할 수도 있습니다.

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

이 라우팅에서는 `logout_path`와 `logout_url`가 애플리케이션의 헬퍼로 생성됩니다. `logout_path`를 호출하면 `/exit`가 반환됩니다.

이 방법을 사용해 리소스로 정의되어있는 라우팅을 아래와 같이 덮어쓸 수 있습니다.

```ruby
get ':username', to: 'users#show', as: :user
```

여기에서는 `user_path` 메소드가 생성되며, 컨트롤러, 헬퍼, 뷰에서 각각 사용할 수 있습니다. 이 메소드는 `/bob`와 같은 사용자 이름을 가지는 라우팅으로 이동합니다. `Users` 컨트롤러의 `show` 액션 내부의 `params[:username]`에 접근하면 사용자의 이름을 가져올 수 있습니다. 파라미터 이름을 `:username`으로 사용하고 싶지 않은 경우에는 라우팅 정의에서 `:username`을 변경해주세요.

### HTTP 메서드를 제한하기

어떤 라우팅을 특정 HTTP와 매칭하기 위해서 일반적으로 `get`, `post`, `put`, `patch`, `delete` 메소드 중 하나를 사용할 필요가 있습니다. `match` 메소드와 `:via` 옵션을 사용하여 복수의 HTTP 메서드를 동시에 사용 가능한 라우팅을 선언할 수 있습니다.

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

`via: :all`을 지정하면, 모든 HTTP 메서드에 매칭하는 특별한 라우팅을 선언할 수 있습니다.

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: 하나의 액션에 `GET` 요청과 `POST` 요청을 모두 라우팅하게 되면 보안에 영향을 줄 가능성이 있습니다. 정말 필요한 경우가 아니라면 하나의 액션에 여러 HTTP 메서드를 라우팅하지 말아주세요.

### 세그먼트를 제한하기

`:constraints` 옵션을 사용하면 동적인 세그먼트의 URL 포맷을 하나로 제한할 수 있습니다.

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

이 라우팅에서는 `/photos/A12345`와 같은 경로와 매칭됩니다만, `/photos/893`에는 매칭되지 않습니다. 아래와 같이 좀 더 간결하게 선언할 수도 있습니다.

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints`에서는 정규표현을 사용할 수 있습니다만, 여기에서는 정규표현의 '앵커'를 사용할 수 없다는 점을 주의해주세요. 예를 들어, 아래와 같은 라우팅에서의 '^'는 의미가 없습니다.

```ruby
get '/:id', to: 'posts#show', constraints: {id: /^\d/}
```

대상이 되는 라우팅은 매칭 시작 지점이 고정되어 있으므로, 이와 같은 표현을 사용할 필요가 없습니다.

예를 들자면, 아래의 라우팅에서는 루트(root) 네임스페이스를 공유할 때에 `posts`에 대해서 `to_param`이 `1-hello-world`처럼 숫자로 시작하는 값만을 사용할 수 있으며, `users`에 대해서 `to_param`이 `david`와 같은 숫자로 시작하지 않는 값만을 사용할 수 있습니다.

```ruby
get '/:id', to: 'posts#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### 요청의 내용에 따라 조건을 추가하기
또한 `String`을 반환하는 <a href="action_controller_overview.html#request-객체">Request</a> 객체의 어떤 메소드를 사용하여 라우팅에 조건을 추가할 수도 있습니다.

요청에 따른 조건은 세그먼트를 제한할 때와 마찬가지의 방법으로 지정할 수 있습니다.

```ruby
get 'photos', constraints: {subdomain: 'admin'}
```

블럭을 통한 방식도 사용 가능합니다.

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTE: 요청 기반의 조건은 Request 객체에 대해 지정된 메소드를 호출합니다. 메소드를 호출할 때에는 호출시에 넘긴 해시의 키와 동일한 이름의 메소드를 Request 객체로 호출하며, 반환된 값과 해시의 값을 비교합니다. 따라서, 조건에 사용된 값의 타입이 대응하는 Request 객체 메소드의 결과의 타입과 일치해야합니다. 예를 들어 `constraints: { subdomain: 'api' }`라는 조건은 `api` 서브 도메인을 정상적으로 매칭할 수 있습니다만, `constraints: { subdomain: :api }`와 같이 심볼을 사용한 경우에는 `api`와 정상적으로 비교되지 않습니다. `request.subdomain`가 돌려주는 `'api'`는 문자열이기 때문입니다.

### 복잡한 조건

좀 더 복잡한 조건을 사용하고 싶은 경우에는, Rails에서 요구하는 `matches?`에 알맞은 객체를 넘기면 됩니다. 예를 들어 블랙리스트에 등록되어있는 모든 사용자를 `BlacklistController`로 라우팅하고 싶다고 가정해봅시다. 이러한 경우에는 다음과 같이 정의하면 됩니다.

```ruby
class BlacklistConstraint
  def initialize
    @ips = Blacklist.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: BlacklistConstraint.new
end
```

람다식을 통해 조건을 걸 수도 있습니다.

```ruby
Rails.application.routes.draw do
  get '*path', to: 'blacklist#index',
    constraints: lambda { |request| Blacklist.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?` 메소드든 람다식이든 인수로 `request` 객체를 받습니다.

### 라우팅 글롭과 와일드카드 세그먼트

라우팅 글롭(route globbing)이란 와일드카드를 사용하여 특정 위치로부터 그 뒤에 있는 주소를 파라미터와 매칭시킬 때에 사용하는 방식입니다. 예를 들어, 

```ruby
get 'photos/*other', to: 'photos#unknown'
```

이 라우팅은 `photos/12`이나 `/photos/long/path/to/12`와 매칭하며,  `params[:other]`에는 `"12"`나 `"long/path/to/12"`가 설정됩니다. 앞 부분에 `*`가 붙어있는 부분을 '와일드카드 세그먼트'라고 부릅니다.

와일드카드 세그먼트는 라우팅의 어떤 부분에도 사용할 수 있습니다.

```ruby
get 'books/*section/:title', to: 'books#show'
```

이 라우팅은 `books/some/section/last-words-a-memoir`을 매칭하고 `params[:section]`에는 `'some/section'`이 저장되며 `params[:title]`에는 `'last-words-a-memoir'`이 저장됩니다.

기술적으로는 하나의 라우팅에 2개의 와일드카드 세그먼트를 포함할 수도 있습니다. 매쳐가 세그먼트를 파라미터를 나누는 방법은 직관적입니다. 예를 들어,

```ruby
get '*a/foo/*b', to: 'test#index'
```

이 라우팅에서는 `zoo/woo/foo/bar/baz`을 매칭하고, `params[:a]`에는 `'zoo/woo'`가 저장되고, `params[:b]`에는 `'bar/baz'`가 저장됩니다.

NOTE: `'/foo/bar.json'`을 요청하면 `params[:pages]`에는 `'foo/bar'`가 JSON 요청 포맷 정보와 함께 저장됩니다. Rails 3.0.x 때의 동작으로 되돌리고 싶은 경우에는 아래와 같이 `format: false`을 지정할 수도 있습니다.

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: 이 세그먼트 포맷을 항상 사용하고 싶은 경우에는 아래와 같이 `format: true`를 지정합니다.

```ruby
get '*pages', to: 'pages#show', format: true
```

### 리다이렉트

라우팅에서 `redirect`를 사용하면 어떤 경로를 다른 경로로 리다이렉트할 수 있습니다.

```ruby
get '/stories', to: redirect('/posts')
```

경로에 매칭되는 동적 세그먼트를 재활용해서 리다이렉트를 할 수도 있습니다.

```ruby
get '/stories/:name', to: redirect('/posts/%{name}')
```

리다이렉트에 블록을 넘겨줄 수도 있습니다. 이 리다이렉트에서는 심볼화된 경로 파라미터와 request 객체를 넘겨 받습니다.

```ruby
get '/stories/:name', to: redirect {|path_params, req| "/posts/#{path_params[:name].pluralize}" }
get '/stories', to: redirect {|path_params, req| "/posts/#{req.subdomain}" }
```

여기서 이루어지고 있는 리다이렉트는 HTTP 상태 코드 중 '301 "Moved Permanently"'라는 점에 주의해주세요. 일부 웹 브라우저나 프록시 서버에서는 이러한 리다이렉트를 캐시하는 경우가 있으며, 그 때에는 리다이렉트 이전의 페이지에는 더이상 접근할 수 없게 됩니다.

Rails는 호스트(`http://www.example.com` 등)가 URL에 지정되어있지 않은 어떤 상황에서든 이전 요청이 아닌 현재의 요청으로부터 필요한 정보를 얻습니다.

### Rack 애플리케이션에 라우팅하기

`Post` 컨트롤러의 `index` 액션에 대응하는 `'posts#index'`같은 문자열 대신에 임의의 <a href="rails_on_rack.html">Rack 애플리케이션</a>을 매쳐의 엔드 포인트로 지정할 수 있습니다.

```ruby
match '/application.js', to: Sprockets, via: :all
```

Rails 라우터의 입장에서 보면 `Sprockets`은 `call`에 응답해서 `[status, headers, body]`를 돌려주기만 하면 라우팅이 된 장소가 Rack 애플리케이션이든 액션이든 관계가 없습니다. 이것은 Rack 애플리케이션이 모든 HTTP 메서드를 적절하게 다루기를 원할 수 있으므료, `via: :all`의 적절한 사용 예시가 될 수 있습니다.

NOTE: 참고로 `'posts#index'`는 `PostsController.action(:index)`라는 형태로 변환됩니다. 이는 올바른 Rack 애플리케이션을 반환합니다.

### `root`를 변경하기

`root` 메소드로 Rails가 루트 `'/'`로 사용할 경로를 지정할 수 있습니다.

```ruby
root to: 'pages#main'
root 'pages#main' # 같은 의미의 다른 표현
```

`root` 라우팅은 라우팅 파일의 상단에 선언해주세요. root는 가장 자주 사용되는 라우팅이므로 가장 먼저 매칭될 필요가 있기 때문입니다.

NOTE: `root` 라우팅이 액션에 넘길 수 있는 것은 `GET` 요청 뿐입니다.

네임스페이스나 스코프의 내부에 root를 위치시킬 수도 있습니다.

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### Unicode문자열을 라우팅에서 사용하기

Unicode문자열을 라우팅에서 직접 사용할 수 있습니다.

```ruby
get '안녕하세요', to: 'welcome#index'
```

Resourceful 라우팅을 커스터마이즈하기
------------------------------

대부분의 경우, `resources :posts`를 통해 생성되는 기본 라우팅과 헬퍼들로 충분합니다만, 이를 좀 더 커스터마이즈 하고 싶을 때가 있습니다. Rails에서는 Resourceful 헬퍼의 어느 부분에서라도 커스터마이즈를 할 수 있도록 해줍니다.

### 사용할 컨트롤러를 지정하기

`:controller` 옵션은 리소스에서 사용하는 컨트롤러를 명시적으로 지정합니다. 예를 들어,

```ruby
resources :photos, controller: 'images'
```

이 라우팅에서는 `/photos`로 시작하는 경로를 매칭하지만, 라우팅은 `Images` 컨트롤러로 처리됩니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 헬퍼              |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | images#index      | photos_path          |
| GET       | /photos/new      | images#new        | new_photo_path       |
| POST      | /photos          | images#create     | photos_path          |
| GET       | /photos/:id      | images#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | images#destroy    | photo_path(:id)      |

NOTE: 이 리소스에 대한 경로를 생성하기 위해서는 `photos_path`나 `new_photo_path` 등을 사용해주세요.

네임스페이스에 존재하는 컨트롤러는 아래와 같이 지정할 수 있습니다.

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

이는 `Admin::UserPermissions`로 라우팅됩니다.

NOTE: 여기에서 지원되는 기법은 `/`로 구분되는 '디렉토리 표기법' 뿐입니다. 루비에서 사용하는 네임스페이스 표기법(`controller: 'Admin::UserPermissions'` 등)을 컨트롤러에 대해서 사용하면 라우팅에 문제가 생길 수 있습니다.

### 조건을 지정하기

`:constraints` 옵션을 사용하면 암묵적으로 사용되는 `id`의 형태를 지정할 수 있습니다.

```ruby
resources :photos, constraints: {id: /[A-Z][A-Z][0-9]+/}
```

이 선언은 `:id` 파라미터에 조건을 추가하고, 지정한 정규표현을 만족하는 경우에만 매칭합니다. 따라서 이 예제에서는 `/photos/1`와 같은 경로를 사용할 수 없습니다. 그 대신 `/photos/RR27`와 같은 경로를 사용할 수 있습니다.

블록을 사용하여, 다수의 라우팅에 대해서 조건을 추가할 수도 있습니다.

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE: 물론 이런 경우라면 'Resourceful하지 않은' 라우팅을 사용해 제약 조건을 추가할 수도 있습니다.

TIP: `:id` 파라미터에서는 기본적으로 마침표 `.`를 사용할 수 없습니다. 마침표는 라우팅에서 포맷을 구분하기 위해서 사용되고 있기 때문입니다. 만약 `:id`에서 마침표를 사용하고 싶다면, 기본 설정을 덮어쓰는 조건을 추가하면 됩니다. 예를 들어 `id: /[^\/]+/`를 사용하면 `/`를 제외한 모든 문자를 사용할 수 있습니다.

### 경로 헬퍼를 덮어쓰기

`:as` 옵션을 사용하면, 경로 헬퍼를 다른 이름으로 생성할 수 있습니다. 예를 들어,

```ruby
resources :photos, as: 'images'
```

이 라우팅에서는 `/photos`로 시작하는 경로를 인식하고, `Photos` 컨트롤러로 라우팅합니다만, 경로 헬퍼로는 `:as` 옵션으로 넘겨받은 값을 사용합니다.

| HTTP 메서드 | 경로                  | 컨트롤러#액션   | 경로 헬퍼              |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | images_path          |
| GET       | /photos/new      | photos#new        | new_image_path       |
| POST      | /photos          | photos#create     | images_path          |
| GET       | /photos/:id      | photos#show       | image_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | image_path(:id)      |

### `new` 세그먼트와 `edit` 세그먼트를 덮어쓰기

`:path_names` 옵션을 사용하면 경로에 포함되어있는 자동 생성된, "new"나 "edit"을 덮어쓸 수 있습니다.

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

이에 따라서 라우팅에서는 아래와 같은 경로를 사용할 수 있게 됩니다.

```
/photos/make
/photos/1/change
```

NOTE: 이 옵션을 지정하더라도 실제 액션명이 변경되는 것은 아닙니다. 변경 후의 경로를 사용하더라도 여전히 `new`와 `edit` 액션으로 라우팅 됩니다.

TIP: 이 옵션에 의한 변경을 모든 라우팅에 대해서 일괄적으로 적용하고 싶은 경우에는 스코프를 사용하면 됩니다.

```ruby
scope path_names: { new: 'make' } do
  # 나머지 라우팅
end
```

### 경로 라우팅에 접두어를 추가하기

`:as` 옵션을 사용하여 Rails가 라우팅에 대해서 생성한 경로 헬퍼에 대해 접두어를 추가할 수도 있습니다. 경로 스코프를 사용하여 라우팅끼리 이름이 충돌하는 것을 방지하기 위해서 사용해 주세요. 예를 들어,

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

이 라우팅에서는 `admin_photos_path`이나 `new_admin_photo_path` 같은 라우트 헬퍼가 생성됩니다. 라우트 헬퍼에 일괄적으로 접두어를 추가하고 싶은 경우에는 다음과 같이 `scope` 메소드와 `:as` 옵션을 사용합니다.

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

이에 따라 `admin_photos_path`와 `admin_accounts_path` 같은 라우팅이 생성됩니다. 이것들은 `/admin/photos`와 `/admin/accounts`에 각각 매핑됩니다.

NOTE: `namespace` 스코프를 사용하면 `:module`이나 `:path`와 함께 `:as`도 자동적으로 추가합니다.

이름 있은 파라미터를 가지는 라우팅에 접두어를 추가할 수도 있습니다.

```ruby
scope ':username' do
  resources :posts
end
```

이 라우팅으로 `/bob/posts/1`와 같은 형식의 URL을 사용할 수 있게 됩니다. 또한 컨트롤러, 헬퍼, 뷰 등 어디에서든 이 경로의 `username`부분에 해당하는 문자열(이 예제에서는 bob)을 `params[:username]`으로 참조할 수 있습니다.

### 라우팅 생성을 제한하기

Rails는 애플리케이션 내의 모든 RESTful한 라우팅에 대해서 기본적으로 7개의 액션(index, show, new, create, edit, update, destroy)에 대한 라우팅을 생성합니다. `:only` 옵션이나 `:except` 옵션을 사용하는 것으로 이러한 생성 목록을 변경할 수 있습니다. `:only` 옵션은 지정된 라우팅만을 생성합니다.

```ruby
resources :photos, only: [:index, :show]
```

이것으로 `/photos`에 대한 `GET` 요청은 성공하고, `/photos`에 대한 `POST` 요청(보통 `create` 액션으로 라우팅 되어야 하는)이 실패합니다.

`:except` 옵션은 반대로 지정된 라우팅만을 생성하지 _않도록_ 만듭니다.

```ruby
resources :photos, except: :destroy
```

여기에서는 `destroy`(`/photos/:id`에 대한 `DELETE` 요청)을 제외한 라우팅이 생성됩니다.

TIP: 애플리케이션에서 RESTful한 라우팅을 사용하고 있다면 각각에 적절한 `:only`나 `:except` 옵션을 사용해서 정말로 필요한 라우팅만을 생성하여 메모리를 절약하고, 라우팅 속도 향상을 꾀할 수 있습니다.

### 경로를 변경하기

`scope` 메소드를 사용하는 것으로  `resource`에 의해 생성되는 기본 경로명을 변경할 수 있습니다.

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

이 선언을 통해 아래와 같은 `Categories` 컨트롤러에 대한 라우팅이 생성됩니다.

| HTTP 메서드 | 경로 | 컨트롤러#액션 | 경로 헬퍼 |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### '단수형 폼'을 덮어쓰기

어떤 리소스의 '단수형'을 정의하고 싶은 경우 `Inflector`에 활용형 룰을 추가하면 됩니다.

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### 이름 있는 리소스에 `:as`를 사용하기

`:as`를 사용하면 중첩된 라우트 헬퍼 내부에 리소스용으로 자동 생성된 이름을 덮어쓸 수 있습니다. 예를 들어,

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

이 라우팅에 따라서 `magazine_periodical_ads_url`나 `edit_magazine_periodical_ad_path`같은 라우트 헬퍼가 생성됩니다.

라우팅 검사와 테스트
-----------------------------

Rails에는 라우팅을 확인하는 기능과 테스트를 하기 위한 기능이 존재합니다.

### 기존의 룰을 한번에 확인하기

현재 애플리케이션에서 사용가능한 라우팅을 모두 보기 위해서는 서버가 **development** 환경에서 동작하고 있는 상태로 브라우저에서 `http://localhost:3000/rails/info/routes`에 접속합니다. 터미널에서 `bin/rails routes`를 실행해도 같은 결과를 얻을 수 있습니다.

어떤 방법을 사용하더라도 `routes.rb` 파일에 기록된 순서대로 라우팅이 표시됩니다. 하나의 라우팅에 에 대해 다음과 같은 정보를 보여줍니다.

* 라우팅의 이름(있을 경우)
* 사용되는 HTTP 메서드(그 라우팅이 모든 HTTP 메서드에 대해서 응답하는 것이 아닌 경우)
* 매칭되는 URL 패턴
* 그 라우팅에서 사용되는 파라미터

아래는 어떤 RESTful한 라우팅에 대해서 `bin/rails routes`을 실행한 결과를 발췌한 것입니다.

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

`CONTROLLER` 환경 변수를 넘겨서 특정 컨트롤러의 라우팅 목록만을 볼 수도 있습니다.

```bash
$ CONTROLLER=users bin/rails routes
```

TIP: 라우팅 목록이 너무 길지 않다면 `bin/rails routes` 쪽이 읽기 편할 것입니다. 

### 라우팅 테스트하기

애플리케이션의 다른 부분들과 마찬가지로, 라우팅에 대한 테스트 전략도 세워야 할 것입니다. Rails는 이를 위해 3개의 [내장 assertion](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html)을 제공합니다.

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### `assert_generates` Assertion

`assert_generates`는 특정 옵션들의 조합이 한 경로를 생성하는지, 그리고 기본 라우팅이나 커스텀 라우팅에서 사용할 수 있는지를 확인할 때 사용합니다.

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes` Assertion

`assert_recognizes`는 `assert_generates`와는 반대 방향의 테스트를 수행합니다. 주어진 경로가 인식가능한지, 애플리케이션의 특정 장소로 라우팅이 되는지를 확인합니다.

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

인수로 `:mothod`를 사용하여 HTTP 메서드를 지정할 수도 있습니다.

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing` Assertion

`assert_routing`은 라우팅을 2개의 관점(주어진 경로에 따라 옵션이 생성되는지, 그 옵션을 통해서 원래의 경로를 생성할 수 있는지)에서 테스트합니다. 다시 말해서 `assert_generates`와 `assert_recognizes`의 기능을 합쳐놓은 형태입니다.

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
