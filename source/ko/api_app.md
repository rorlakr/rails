API 전용 레일스 애플리케이션 만들기
=====================================

이 가이드의 내용:

* 레일스가 API 전용 애플리케이션을 위해 제공하는 기능
* 브라우저 관련 기능을 제외하고 레일스를 실행하기
* 미들웨어 선택하기
* 컨트롤러에서 사용할 모듈 선택하기

--------------------------------------------------------------------------------

API 애플리케이션에 대해
---------------------------

지금까지 레일스로 API를 사용한다고 하면 프로그램이 사용할 수 있는 API를 웹 애플리케이션에 추가하는 방식을 의미했습니다.
예를 들어 GitHub이 제공하는 [API](http://developer.github.com)를 직접 만든 클라이언트에서 사용할 수 있습니다.

클라이언트 프레임워크의 등장에 따라, 다른 웹 애플리케이션과 네이티브 애플리케이션에서 레일스로 만든
백엔드 서버를 사용하는 경우가 늘었습니다.

Twitter는 자사 웹 애플리케이션에서 [공개 API](https://dev.twitter.com)를 사용하고 있습니다.
이 웹 애플리케이션은 JSON 리소스만을 사용하는 정적인 사이트입니다.

많은 개발자가 레일스를 폼이나 링크를 통하는 서버 간의 통신을 위해 HTML을 생성하는 대신,
웹 애플리케이션을 단순한 API 클라이언트로 정의하고, JSON API를 사용하는 HTML과 자바스크립트를 제공하는
방식으로 다루게 되었습니다.

여기에서는 클라이언트 프레임워크의 설명을 포함해, JSON 리소스를 API 클라이언트에 제공하는 레일스
애플리케이션을 구축하는 방법에 관해서 설명합니다.

JSON API에 레일스를 사용하는 이유
----------------------------

레일스로 JSON API를 만드는 것에 대해서 많은 개발자가 가장 먼저 떠올리는 질문은 이렇습니다.
"레일스로 JSON을 제공하는건 너무 거창하지 않나요? 그냥 Sinatra로 만들면 어떤가요?"

단순한 API 서버라면 아마도 그럴 겁니다. 하지만 HTML의 비중이 매우 큰 애플리케이션이라도, 로직 대부분은
뷰 레이어가 아닌 곳에 존재합니다.

많은 개발자가 레일스를 채용하는 이유는 세세한 설정을 고민하지 않고,
빠르게 애플리케이션을 제공할 수 있기 때문입니다.

API 애플리케이션 개발에 도움이 되는 레일스의 기능을 몇 가지 소개합니다.

미들웨어에서 제공하는 기능 목록

- 리로딩: 레일스 애플리케이션은 '투명한 리로딩'을 지원합니다. 예를 들어 애플리케이션이 커져 요청마다 서버를 재기동하는 방법을 사용할 수 없더라도 투명한 리로딩이 가능합니다.
- 개발 모드: 레일스 애플리케이션의 개발 모드에는 기본값이 이미 설정되어 있으므로 실제 환경의 성능에 대한 걱정 없이 즐겁게 작업을 진행할 수 있습니다.
- 테스트 모드: 개발 모드와 같습니다.
- 로그 출력: 레일스 애플리케이션은 요청마다 로그를 출력합니다. 또한 현재 모드에 따라서 로그의 레벨이 조정됩니다. 개발 모드의 로그에는 요청 환경, 데이터베이스 질의, 간단한 성능 정보 등이 출력됩니다.
- 보안: [IP 스푸핑 공격](https://en.wikipedia.org/wiki/IP_address_spoofing)을 검출, 방어합니다. 또한 [타이밍 공격](http://en.wikipedia.org/wiki/Timing_attack)에 대응할 수 있는 암호화 서명을 다룹니다.
- 매개변수 분석: URL 인코딩이나 문자열 대신 JSON으로 매개변수를 지정할 수 있습니다. JSON은 레일스에서 해석되어 `params`를 통해 접근할 수 있습니다. 물론 중첩된 URL 인코딩 매개변수도 다룰 수 있습니다.
- 조건부 GET: 레일스에서는 `ETag`나 `Last-Modified`를 사용한 조건부 GET을 사용합니다. 이는 요청 헤더를 처리하고, 올바른 응답 헤더와 상태 코드를 돌려줍니다. 컨트롤러에 [`stale?`](http://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)을 추가하면 HTTP의 구체적인 동작은 레일스가 처리합니다.
- HEAD 요청: 레일스에서는 `HEAD` 요청을 투명하게 `GET` 요청으로 변환하고, 헤더만을 반환합니다. 이를 통해서 모든 레일스 API에서 `HEAD` 요청을 사용할 수 있습니다.

Rack 미들웨어의 이런 기능들을 직접 구현할 수도 있습니다만, 레일스의 기본 미들웨어를 "JSON 생성용"으로
쓰더라도 많은 이점을 얻을 수 있습니다.

액션 팩에서 제공하는 기능

- 리소스 기반 라우팅: RESTful JSON API를 개발한다면 레일스의 라우터도 사용하고 싶을 것입니다. HTTP로부터 컨트롤러로 명확하게 연결할 수 있으므로 HTTP에 대해서 API를 어떻게 구성할지 고민할 필요가 없습니다.
- URL 생성: 라우팅은 URL을 생성할 때에도 편리합니다. 잘 구성된 HTTP 기반의 API에는 URL도 포함됩니다([GitHub Gist API](http://developer.github.com/v3/gists/)가 좋은 예시입니다).
- 헤더 응답이나 리다이렉션 응답: `head :no_content`나 `redirect_to user_url(current_user)` 등을 사용할 수 있습니다. 헤더 응답을 직접 생성하지 않아도 됩니다.
- 캐시: 레일스는 페이지 캐싱, 액션 캐싱, 조각 캐싱을 사용할 수 있습니다. 특히 조각 캐싱은 중첩된 JSON 객체를 만들 때 유용합니다.
- 기본 인증, 다이제스트 인증, 토큰 인증: 3종류의 HTTP 인증을 간단하게 도입할 수 있습니다.
- 계측(Instrumentation): 레일스의 계측 API는 등록한 다양한 이벤트 핸들러를 실행합니다. 액션 처리, 파일이나 데이터 전송, 리다이렉트, 데이터베이스 질의 등을 다룹니다. 각 이벤트의 페이로드에 다양한 정보가 포함되어 있습니다. 예를 들어 이벤트를 처리하는 액션의 경우, 페이로드에는 컨트롤러, 액션, 매개변수, 요청 형식, 요청 경로등이 포함됩니다.
- 제너레이터: 명령 하나로 리소스를 간단하게 생성하고, API에 맞는 모델, 컨트롤러, 테스트 스텁, 라우팅을 바로 사용할 수 있습니다. 마이그레이션 등의 작업도 명령으로 실행할 수 있습니다.
- 플러그인: 수많은 서드파티 라이브러리를 사용할 수 있습니다. 라이브러리 설정이나 웹 프레임워크 등의 연동도 간단하므로, 비용을 줄일 수 있습니다. 플러그인을 통해 기존 제너레이터를 덮어쓰거나 Rake 태스크를 추가, 또는 레일스의 동작을 변경할 수도 있습니다(로거나 캐시 백엔드 등).

물론 레일스의 실행 프로세스에서는 등록된 컴포넌트를 모두 읽어서 연동합니다. 예를 들어 실행할 때에 `config/database.yml` 파일을 통하여 액티브 레코드를 설정합니다.

**한줄 요약**: 레일스에서 뷰와 관련된 동작을 제외하면 어떤 기능을 사용할 수 있을까요? 기능 대부분을 사용할 수 있습니다.

기본 설정
-----------------------

레일스 애플리케이션을 API 서버로 구축하고 싶다면, 기능을 제한한 레일스 하위 셋을 사용하여 필요한 기능을
추가하는 것이 좋을 겁니다.

### 애플리케이션을 새로 생성하기

API 레일스 애플리케이션을 생성하려면 다음의 명령을 사용합니다.

```bash
$ rails new my_api --api
```

이 명령은 다음 3개의 동작을 실행합니다.

- 사용하는 미들웨어를 기존보다 적게끔 설정합니다. 특히 브라우저용 애플리케이션에서 유용한 미들웨어(쿠키 등의 지원)를 완전히 사용할 수 없게 됩니다.
- `ApplicationController`을 `ActionController::Base`가 아닌 `ActionController::API`에서 상속받습니다. 미들웨어와 마찬가지로 액션 컨트롤러 모듈에서 브라우저용 애플리케이션에서만 사용되는 부분을 모두 제외합니다.
- 제너레이터가 뷰, 헬퍼, 어셋을 생성하지 않도록 합니다.

### 기존의 애플리케이션을 변경하기

기존의 애플리케이션을 API 전용으로 만들려면 다음 순서를 따라주세요.

`config/application.rb`의 `Application` 클래스에 다음을 추가합니다.

```ruby
config.api_only = true
```

`config/environments/development.rb`에서 `config.debug_exception_response_format`을 통해
개발 모드에서 에러가 발생할 경우에 응답에서 사용할 형식을 지정하세요.

`:default`는 HTML 페이지로 디버깅 정보를 제공합니다.

```ruby
config.debug_exception_response_format = :default
```

`:api`는 응답 형식을 유지한 채로 디버깅 정보를 제공합니다.

```ruby
config.debug_exception_response_format = :api
```

`config.api_only`를 true로 설정하면 `config.debug_exception_response_format`의
기본값이 `:api`로 설정됩니다.

마지막으로 `app/controllers/application_controller.rb`를,

```ruby
class ApplicationController < ActionController::Base
end 
```

다음과 같이 변경합니다.

```ruby
class ApplicationController < ActionController::API
end 
```

미들웨어 선택하기
--------------------

API 애플리케이션에서는 기본으로 다음의 미들웨어를 사용합니다.

- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::RemoteIp`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

자세한 설명은 Rack 가이드의 [내부 미들웨어](rails_on_rack.html#미들웨어-스택의-내용)에서 확인하세요.

미들웨어는 액티브 레코드 등의 플러그인에 의해서 추가되는 경우도 있습니다. 일반적으로 구축할 애플리케이션의
종류와 미들웨어는 관련이 없습니다만, API 전용 레일스 애플리케이션에서는 의미가 있습니다.

애플리케이션의 모든 미들웨어를 확인하려면 다음 명령을 실행하세요.

```bash
$ rails middleware
```

### 캐시 미들웨어를 사용하기

레일스는 애플리케이션의 설정에 따라 캐시 저장소(기본값은 memcache)를 제공하는 미들웨어를 추가합니다.
다시 말해, 레일스에 포함된 HTTP 캐시는 이 캐시 저장소에 의존합니다.

예를 들자면, 다음과 같이 `stale?` 메소드를 호출한다고 가정합시다.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

`stale?` 호출은 `@post.updated_at`과 요청에 있는 `If-Modified-Since` 헤더를 비교합니다. 헤더가 마지막 변경 시점보다 새로운 경우 "304 Not Modified"를 반환하거나 `Last-Modified` 헤더를 포함하여 응답을 랜더링합니다.

일반적으로 이 동작은 클라이언트마다 이루어집니다만, 캐시 미들웨어가 있다면 클라이언트 간에 이 캐시를
공유할 수도 있습니다. 클라이언트 캐시 공유는 `stale?` 호출 시점에 지정할 수 있습니다.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end 
end
```

캐시 미들웨어는 URL에 대응하는 `Last-Modified` 값을 레일스 캐시에 저장하고 이후 같은 URL 요청을
수신할 경우 `If-Modified-Since` 헤더를 추가합니다.

이는 HTTP를 사용하는 페이지 캐싱이라고 생각할 수도 있을 겁니다.

### Rack::Sendfile 사용하기

레일스 컨트롤러에서 `send_file` 메소드가 실행되면 `X-Sendfile` 헤더가 추가됩니다.
`Rack::Sendfile`은 실제 파일 전송을 책임집니다.

빠른 파일 전송(accelerated file sending)을 지원하는 프론트엔드 서버는 `Rack::Sendfile`
대신에 실제 파일을 전송합니다.

프론트엔드 서버에서 파일 전송에 사용하는 헤더의 이름은 해당하는 환경 설정 파일의
`config.action_dispatch.x_sendfile_header`에서 지정할 수 있습니다.

[Rack::Sendfile 문서](http://rubydoc.info/github/rack/rack/master/Rack/Sendfile)에서
인기있는 프론트엔드와 함께 `Rack::Sendfile`을 사용하는 방법을 확인하세요.

빠른 파일 전송을 사용하려면 헤더에 다음과 같은 값을 설정하세요.

```ruby
# Apache, lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

이 옵션을 사용하려면 `Rack::Sendfile` 문서를 따라서 서버를 설정해주세요.

### ActionDispatch::Request 사용하기

`ActionDispatch::Request#params`는 클라이언트로부터 매개변수를 JSON 형식으로 받아 컨트롤러의
`params`로 접근할 수 있게 해줍니다.

이 기능을 사용하려면 JSON으로 인코딩된 매개변수를 클라이언트에서 보내고, 이 때 `Content-Type`가
`application/json`이어야 합니다.

jQuery 예제는 다음과 같습니다.

```javascript
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request`에서는 이 `Content-Type`으로 다음 인자를 받습니다.

```ruby
{ :person => { :firstName => "Yehuda", :lastName => "Katz" } }
```

### 그 이외의 미들웨어

레일스에서는 이외에도 API 애플리케이션을 위한 여러 미들웨어를 사용할 수 있습니다. 특히 브라우저가
API 클라이언트가 되는 경우에 다음의 미들웨어들이 유용합니다.

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`
- 세션 관리용
    * `ActionDispatch::Session::CacheStore`
    * `ActionDispatch::Session::CookieStore`
    * `ActionDispatch::Session::MemCacheStore`

이 미들웨어들은 다음과 같이 추가할 수 있습니다.

```ruby
config.middleware.use Rack::MethodOverride
```

### 미들웨어 제거하기

API 전용 미들웨어에 포함하고 싶지 않은 미들웨어는 다음과 같이 삭제할 수 있습니다.

```ruby
config.middleware.delete ::Rack::Sendfile
```

이 미들웨어를 삭제하면 액션 컨트롤러의 일부 기능을 사용할 수 없게 되므로 조심하세요.

컨트롤러에서 사용할 모듈 선택하기
---------------------------

API 애플리케이션(`ActionController::API`를 사용)에는 다음과 같은 컨트롤러 모듈이 포함됩니다.

- `ActionController::UrlFor`: `url_for` 등의 헬퍼 제공
- `ActionController::Redirecting`: `redirect_to` 제공
- `AbstractController::Rendering`와 `ActionController::ApiRendering`: 기본적인 랜더링을 제공
- `ActionController::Renderers::All`: `render :json` 등을 제공
- `ActionController::ConditionalGet`: `stale?`을 제공
- `ActionController::BasicImplicitRender`: 명시적인 응답이 없으면 빈 응답을 반환
- `ActionController::StrongParameters`: 매개변수를 위한 화이트리스트를 제공(액티브 모델의 대량 할당과 함께 동작)
- `ActionController::ForceSSL`: `force_ssl`을 제공
- `ActionController::DataStreaming`: `send_file`이나 `send_data`를 제공
- `AbstractController::Callbacks`: `before_action` 등의 헬퍼를 제공
- `ActionController::Rescue`: `rescue_from`을 제공
- `ActionController::Instrumentation`: 액션 컨트롤러에서 정의하는 계측 훅을 제공([계측 가이드](active_support_instrumentation.html#action-controller)를 참조)
- `ActionController::ParamsWrapper`: 매개변수 해시를 감싸서 중첩된 해시로 만듦. 이를 통해서 POST 요청을 전송하는 경우에도 최상위 요소를 지정하지 않도록 해줌

다른 플러그인을 통해 모듈이 추가되는 경우도 있습니다. `ActionController::API`의 모든 모듈 목록은
다음 명령으로 확인할 수 있습니다.

```bash
$ bin/rails c
>> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API, 
    ActiveRecord::Railties::ControllerRuntime, 
    ActionDispatch::Routing::RouteSet::MountedHelpers, 
    ActionController::ParamsWrapper, 
    ... , 
    AbstractController::Rendering, 
    ActionView::ViewPaths]
```

### 그 외의 모듈 추가하기

액션 컨트롤러의 어떤 모듈도 자신이 의존하는 모듈을 파악하고 있으므로 자유롭게 컨트롤러에 모듈을 추가할 수 있습니다.

자주 사용되는 것은 다음과 같습니다.

- `AbstractController::Translation`: 지역화용 `l`과 번역용 `t` 메소드를 제공
- `ActionController::HttpAuthentication::Basic`(그리고 `Digest`, `Token`): HTTP의 기본 인증, 다이제스트 인증, 토큰 인증을 제공
- `ActionView::Layouts`: 레이아웃을 제공
- `ActionController::MimeResponds`: `respond_to`을 제공
- `ActionController::Cookies`: 서명과 암호화를 포함한 `cookies`를 제공. 쿠키 미들웨어가 필요.

모듈은 `ApplicationController`에 추가하는 것이 가장 좋습니다만, 각각의 컨트롤러에 추가해도 괜찮습니다.
