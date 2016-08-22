Ruby on Rails 5.0 릴리스 노트
===============================

Rails 5.0에서 주목할 점

* 액션케이블
* Rails API
* 액션레코드 속성 API
* 테스트 러너
* Rake 명령을 `rails` 명령으로 통일
* Sprockets 3
* Turbolinks 5
* 루비 2.2.2 이상의 버전을 요구

이 릴리스에서는 주요 변경점에 대해서만 설명합니다. 수정된 버그 및 변경점에 대해서는 Github Rails 저장소에 있는 [커밋 목록](https://github.com/rails/rails/commits/5-0-stable)의 changelog를 참고해주세요.

--------------------------------------------------------------------------------

Rails 5.0로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것은 좋은 생각입니다. 애플리케이션이 Rails 4.2로 업그레이드되지 않았다면 우선 이를 우선하고, 애플리케이션이 정상적으로 동작하는지 충분히 확인한 뒤에 Rails 5.0을 올려주세요. 업그레이드 시의 주의점에 대해서는 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#rails-4-2에서-Rails-5-0로-업그레이드)를 참고해주세요.


주요 변경점
--------------

### 액션케이블

액션케이블은 레일스 5에서 새롭게 도입된 프레임워크로 레일스 애플리케이션에서 [웹 소켓](https://en.wikipedia.org/wiki/WebSocket)과 관련된 부분을 부드럽게 통합합니다.

액션 케이블을 도입하면, 레일스 애플리케이션의 좋은 효율과 확장 가능성을 유지하며 기존의 레일스 애플리케이션과 동일한 스타일, 방법으로 실시간 기능을 루비로 작성할 수 있습니다. 액션케이블은 클라이언트 쪽의 자바 스크립트 프레임워크와 서버 쪽의 루비 프레임워크를 동시에 제공합니다. 액션레코드와 같은 ORM으로 작성된 모든 도메인 모델에 접근할 수 있습니다.

자세한 설명은 [액션케이블의 개요](action_cable_overview.html)를 참조해주세요.

### API 애플리케이션

API만을 제공하는 간단한 애플리케이션을 레일스를 사용해 생성할 수 있게 되었습니다.
[Twitter](https://dev.twitter.com) API나 [GitHub](http://developer.github.com) API와 같은 공용 API 서버는 물론, 그 외의 애플리케이션을 위한 API 서버를 작성할 때에도 편리합니다.

API Rails 애플리케이션을 생성하려면 다음의 명령어를 사용합니다.

```bash
$ rails new my_api --api
```

이 명령은 다음 3개의 동작을 실행합니다.

- 사용하는 미들웨어를 일반적인 상황보다 적게 사용하여 서버를 실행하도록 설정합니다. 특히 브라우저용 애플리케이션에서 유용한 미들웨어(쿠키에 대한 지원 등)를 일체 사용할 수 없게 됩니다.
- `ApplicationController`는 기존의 `ActionController::Base` 대신에 `ActionController::API`를 계승합니다. 미들웨어와 마찬가지로 액션컨트롤러 모듈에서 브라우저용 애플리케이션에서만 사용되는 모듈을 모두 제외합니다.
- 제너레이터가 뷰, 헬퍼, 애셋을 생성하지 않습니다.

생성된 API 애플리케이션은 API 제공하기 위한 기본이 되며, 필요에 따라서 [기능을 추가](api_app.html) 할 수 있게 됩니다.

자세한 설명은 [레일스에서 API 전용 애플리케이션을 만들기](api_app.html)를 참고하세요.

### 액티브레코드 속성 API

모델에 type 속성을 정의합니다. 필요하다면 기존의 속성을 덮어써도 좋습니다.
이를 사용하여 모델의 속성을 SQL로 어떻게 상호변환할지를 제어할 수 있습니다.
또한 `ActiveRecord::Base.where`에 넘겨진 값의 동작을 변경할 수도 있습니다.
이를 통하여 구현의 상세나 몽키 패치에 의존하지 않고 액티브레코드의 대부분에서 도메인 객체를 사용할 수 있게 됩니다.

다음과 같이 사용할 수도 있습니다.

* 액티브레코드에서 검출된 타입을 덮어쓸 수 있습니다.
* 기본 동작을 지정할 수 있습니다.
* 속성은 데이터베이스 컬럼을 요구하지 않습니다.

```ruby

# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end

# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end 

store_listing = StoreListing.new(price_in_cents: '10.1')

# 변경전
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # 커스텀 타입
  attribute :my_string, :string, default: "new default" # 기본값
  attribute :my_default_proc, :datetime, default: -> { Time.now } # 기본값
  attribute :field_without_db_column, :integer, array: true
end 

# 변경후
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes #=> {field_without_db_column: [1, 2, 3]}
```

**커스텀 타입 만들기:**

독자적인 타입을 정의할 수 있으며, 이는 값의 타입으로 정의된 메소드에 응답하는 경우에 한해서만 가능합니다.
`deserialize` 메소드나 `cast` 메소드는 작성한 타입 객체로 호출되어 데이터베이스나 컨트롤러로부터의 받은 실제 입력을 인수로 사용합니다.
이는 통화 변환처럼 직접 별도의 변환을 해야하는 경우에 유용합니다.

**쿼리하기:**

`ActiveRecord::Base.where`이 호출되면 모델 클래스에 정의된 타입을 사용하여 값을 SQL로 변환하고, 그 값의 객체로 `serialize`를 호출합니다.

이를 통해서 SQL 쿼리를 실행할 때에 객체를 어떻게 변환할지를 지정할 수 있게 됩니다.

**Dirty Tracking:**

타입의 속성은 'Dirty Tracking'의 실행 방법을 변경할 수 있게 해줍니다.

자세한 내용은 [문서](http://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html)를 참고해주세요.


### 테스트 러너

새로운 테스트 러너가 도입되어, 레일스에서의 테스트 실행 기능이 강화되었습니다.
`bin/rails test`로 명령하면 테스트 러너를 사용할 수 있습니다.

테스트 러너는 `RSpec`, `minitest-reporters`, `maxitest`로부터 영감을 얻었습니다.
다음과 같은 많은 개선이 이루어졌습니다.

- 테스트의 줄번호를 지정하여 한 테스트만을 실행.
- 테스트의 줄번호를 지정하여 복수의 테스트를 실행.
- 실패한 경우에 보여주는 메시지가 개선되어, 실패한 테스트를 곧장 재실행할 수 있게 되었습니다.
- `-f` 옵션을 사용하면 실패했을 때에 곧바로 테스트를 정지할 수 있습니다.
- `-d` 옵션을 사용하면 테스트가 완료될때까지 메시지 출력을 미룰 수 있습니다.
- `-b` 옵션을 사용하면 예외에 대한 전체 백트레이스를 얻을 수 있습니다.
- `Minitest`와 통합되어 `-s`로 시드 데이터를 지정, `-n`으로 특정 테스트명을 지정, `-v`로 자세한 메시지 출력을 활성화 하는 등 다양한 옵션을 사용할 수 있게 되었습니다.
- 테스트 출력에 색깔이 추가되었습니다.

Railties
--------

자세한 변경사항은 [Changelog][railties]를 참고해주세요.

### 제거된 것들

*  `debugger`를 지원하지 않습니다. `debugger`는 루비 2.2에서는 지원되지 않으므로 앞으로는 byebug를 사용할 것.
    ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   제거 예정이었던 `test:all` 태스크와 `test:all:db` 태스크를 제거.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   제거 예정이었던 `Rails::Rack::LogTailer`를 제거.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   제거 예정이었던 `RAILS_CACHE` 정수를 제거.
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   제거 예정이었던 `serve_static_assets` 설정을 제거.
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   문서 생성용 태스크 `doc:app`, `doc:rails`, `doc:guides`를 제거.
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   `Rack::ContentLength` 미들웨어를 기본 스택으로부터 제거.
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### 제거 예정

*   `config.static_cache_control`이 제거될 예정. 앞으로는 `config.public_file_server.headers`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*  `config.serve_static_files`가 제거될 예정. 앞으로는 `config.public_file_server.enabled`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   태스크의 네임스페이스 `rails`가 제거될 예정. 앞으로는 `app`을 사용.
    （e.g. `rails:update` 태스크나 `rails:template` 태스크는 `app:update`나 `app:template`로 변경됨）
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### 주요 변경점

*   Rails 테스트 러너 `bin/rails test`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   새 애플리케이션이나 플러그인의 README이 마크다운 형식인 `README.md`로 변경됨.
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   레일스 애플리케이션을 touch `tmp/restart.txt`로 재기동하는 `bin/rails restart` 태스크가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   모든 정의된 이니셜라이져를 레일스가 실행하는 순서대로 출력하는 `bin/rails initializers` 태스크가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   development 모드에서 캐시의 활성화 여부를 지정하는 `bin/rails dev:cache`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   developement 환경을 자동으로 업데이트하는 `bin/update` 스크립트가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   rake 태스크를 `bin/rails`로 사용할 수 있도록 위임함.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   새로 생성된 애플리케이션은 Linux나 Mac OS X 상에서 '파일 시스템의 이벤트 감시'（evented file system monitor）가 활성화됨. `--skip-listen` 옵션을 사용하여 이 기능을 끌 수 있음.
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003), [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   새로 생성된 애플리케이션은 `RAILS_LOG_TO_STDOUT` 환경 변수를 사용해서 production 환경에서 STDOUT으로 로그를 출력하도록 지정할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   새 애플리케이션에서는 HSTS（HTTP Strict Transport Security）에서 IncludeSudomains 헤더가 기본으로 `true`임.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   애플리케이션 제너레이터로부터 새롭게 `config/spring.rb` 파일이 생성됨. 이를 사용하여 Spring의 감시 대상을 추가할 수 있음.
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   새 애플리케이션 생성 시에 액션메일러를 생략하는 `--skip-action-mailer`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   `tmp/sessions` 폴더와 여기에 관련된 코드를 제거.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   scaffold 제너레이터가 생성하는 `_form.html.erb`를 지역 변수를 사용하도록 변경.
    ([Pull Request](https://github.com/rails/rails/pull/13434))

*   production 환경에서 클래스를 자동 로딩하지 않도록 변경.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

자세한 변경사항은 [Changelog][action-pack]을 참고해주세요.

### 제거된 것들

*   `ActionDispatch::Request::Utils.deep_munge`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   `ActionController::HideActions`가 제거됨.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   플레이스 홀더 메소드인 `respond_to`와 `respond_with`를 [responders](https://github.com/plataformatec/responders) gem로 추출됨.
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   제거 예정이었던 단언(assertion) 파일들이 제거됨.
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   제거 예정이던 URL 헬퍼에서 문자열 키를 사용하는 방식이 제거됨.
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   제거 예정이던 `only_path` 옵션을 `*_path` 헬퍼에서 제거됨.
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   제거 예정이던 `NamedRouteCollection#helpers`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*  `#`을 포함하지 않는 `:to` 옵션(제거 예정)의 라우팅 정의 방법이 제거됨.
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   제거 예정이던 `ActionDispatch::Response#to_ary`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   제거 예정이던 `ActionDispatch::Request#deep_munge`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   제거 예정이던 `ActionDispatch::Http::Parameters#symbolized_path_parameters`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   컨트롤러 테스트로부터 제거 예정이던 `use_route`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   `assigns`와 `assert_template`가 [rails-controller-testing](https://github.com/rails/rails-controller-testing) gem으로 추출됨.
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### 제거 예정

*   `*_filter` 콜백이 모두 제거 예정. 앞으로는 `*_action` 콜백을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   통합 테스트 메소드 `*_via_redirect`가 제거 예정. 앞으로 동일한 동작이 필요한 상황에는 요청을 호출한 뒤, `follow_redirect!`를 직접 실행.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*  `AbstractController#skip_action_callback`가 제거 예정. 앞으로는 각각의 skip_callback 메소드를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*  `render`메소드의 `:nothing` 옵션이 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*  `head` 메소드의 첫번째 인수를 `Hash`로 넘기는 방식과 기본 상태 코드를 넘기는 방식이 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   미들웨어의 클래스명을 문자열이나 심볼로 표현하는 방식이 제거 예정. 앞으로는 클래스명을 그대로 사용할 것.
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   MIME 타입을 상수로 자정하여 사용하는 방식을 제거 예정(e.g. `Mime::HTML`). 앞으로는 대괄호로 감싼 심볼을 사용할 것(e.g. `Mime[:html]`)
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   `RedirectBackError`를 피하기 위해 `fallback_location`를 반드시 넘겨야하는 `redirect_back`를 장려하기 위해 `redirect_to :back`가 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest`와 `ActionController::TestCase`에서 순서대로 들어오는 인수를 받는 방식을 제거 예정. 앞으로는 키워드 인수를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   경로 파라미터 `:controller`와 `:action`가 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   컨트롤러의 인스턴스에서 env 메소드가 제거 예정.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`가 제거 예정이 되고, 미들웨어 스택에서 제거됨. 앞으로 파라미터 파서가 필요한 경우에는 `ActionDispatch::Request.parameter_parsers=`를 사용.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1), [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### 주요 변경점

*   컨트롤러 액션의 외부에서 임의의 템플릿을 랜더링할 수 있는 `ActionController::Renderer`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   `ActionController::TestCase`와 `ActionDispatch::Integration`의 HTTP 요청 메소드에 키워드 인수 구문이 통합됨.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   만료 기한이 없는 응답을 응답을 캐싱하는 `http_cache_forever`가 액션컨트롤러에 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   요청의 variant에 알기 쉬운 지정 방식이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   대응하는 템플릿이 없는 경우에는 에러 대신 `head :no_content`를 랜더링하게됨.
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   컨트롤러의 기본 폼 빌더를 덮어쓰는 기능이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   API 전용의 애플리케이션에 대한 지원 기능을 추가. 이러한 경우에는 `ActionController::Base` 대신에 `ActionController::API`가 사용됨.
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters`는 앞으로 `HashWithIndifferentAccess`를 상속하지 않음.
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   보다 안전한 SSL을 실험하거나 쉽게 비활성화할 수 있도록 `config.force_ssl`와 `config.ssl_options`를 사용하기 쉽게 만듬.
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   `ActionDispatch::Static`에 임의의 헤더를 반환하는 기능이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   `protect_from_forgery`의 prepend의 기본값이 `false`로 변경됨.
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase`는 레일스 5.1에서 gem으로 추출될 예정. 앞으로는 `ActionDispatch::IntegrationTest`를 사용.
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   레일스에서 생성하는 ETag이 '강한' 방식에서 '약한' 방식으로 변경됨.
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   컨트롤러 액션에서 `render`가 명시적으로 호출되지 않고, 대응하는 템플릿도 없는 경우, 에러 대신에 `head :no_content`를 암묵적으로 호출하게 됨.
    (Pull Request [1](https://github.com/rails/rails/pull/19377), [2](https://github.com/rails/rails/pull/23827))

*   폼마다 CSRF 토큰을 생성할 수 있는 옵션이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   요청의 인코딩과 응답을 해석하는 부분이 통합 테스트에 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   컨트롤러 액션에서 응답이 명시적으로 지정되지 않은 경우의 기본 랜더링 방식이 변경됨.
    ([Pull Request](https://github.com/rails/rails/pull/23827))


*   컨트롤러 레벨에서 뷰 컨텍스트에 접근하는 `ActionController#helpers`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/24866))

*   버려진 플래시 메시지를 세션에 저장하지 않고 제거하게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   `fresh_when`나 `stale?`에 레코드의 컬렉션을 넘기는 기능이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live`가 `ActiveSupport::Concern`로 변경됨.
    `ActiveSupport::Concern`에서 확장하지 않은 다른 모듈에는 포함되지 않음.
    그리고 `ActionController::Live`는 production 환경에서는 사용되지 않는다.
    `ActionController::Live`가 사용되는 경우 생성된 스레드에서 던진 `:warden`을 미들웨어에서 잡지 못하는 문제가 있었음.
    이에 대응하기 위해 `Warden`/`Devise`의 인증 에러를 다루는 특수한 코드를 포함하는 별도의 모듈을 사용하는 개발자들이 있었음.
    ([이에 대한 자세한 설명이 포함된 이슈](https://github.com/rails/rails/issues/25581))


Action View
-------------

자세한 변경사항은 [Changelog][action-view]을 참고해주세요.

### 제거된 것들

*  非推奨の`AbstractController::Base::parent_prefixes`を削除。
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*  `ActionView::Helpers::RecordTagHelper`を削除。この機能は[record_tag_helper](https://github.com/rails/record_tag_helper) gemに移行済み。
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*  i18nでのサポート廃止に伴い、`translate`の`:rescue_format`オプションを削除。
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### 주요 변경점

*  デフォルトのテンプレートハンドラを`ERB`から`Raw`に変更。
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   コレクションのレンダリングで、複数の部分テンプレート（パーシャル）のキャッシュと取得を一度に行えるようになった。
    ([Pull Request](https://github.com/rails/rails/pull/18948), [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*  明示的な依存関係指定にワイルドカードによるマッチングを追加。
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*  `disable_with`をsubmitタグのデフォルトの動作に設定。これにより送信時にボタンを無効にし、二重送信を防止する。
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   部分テンプレート（パーシャル）名はRubyの有効な識別子ではなくなった。
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag`ヘルパーで`datetime-local`を指定したinputタグが生成されるようになった。
    ([Pull Request](https://github.com/rails/rails/pull/25469))

Action Mailer
-------------

자세한 변경사항은 [Changelog][action-mailer]을 참고해주세요.

### 제거된 것들

*  非推奨の`*_path`ヘルパーをemailビューから削除。
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*  非推奨の`deliver`メソッドと`deliver!`メソッドを削除。
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 주요 변경점

*   テンプレートを検索するときにデフォルトのロケールとi18nにフォールバックするようになった。
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*  ジェネレーターで生成されたメイラーに`_mailer`サフィックスを追加。コントローラやジョブと同様の命名規則に従う。
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   `assert_enqueued_emails`と`assert_no_enqueued_emails`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*  メイラーキュー名を設定する`config.action_mailer.deliver_later_queue_name`設定を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*  Action Mailerビューでフラグメントキャッシュをサポート。
テンプレートでキャッシュが有効かどうかを検出する`config.action_mailer.perform_caching`設定オプションを追加。
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

자세한 변경사항은 、[Changelog][active-record]을 참고해주세요.

### 제거된 것들

*  ネストした配列をクエリ値として渡す機能（非推奨）を削除。([Pull Request](https://github.com/rails/rails/pull/17919))

*  非推奨の`ActiveRecord::Tasks::DatabaseTasks#load_schema`を削除。このメソッドは`ActiveRecord::Tasks::DatabaseTasks#load_schema_for`で置き換え済み。
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*  非推奨の`serialized_attributes`を削除。
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   `has_many :through`の自動カウンタのキャッシュ（非推奨）を削除。
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*  非推奨の`sanitize_sql_hash_for_conditions`を削除。
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*  非推奨の`Reflection#source_macro`を削除。
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*  非推奨の`symbolized_base_class`と`symbolized_sti_name`を削除。
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*  非推奨の`ActiveRecord::Base.disable_implicit_join_references=`を削除。
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*  文字列アクセサによる接続使用へのアクセス（非推奨）を削除。
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*  インスタンスに依存するプリロード（非推奨）のサポートを削除。
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   PostgreSQLでしか使われない値の範囲の下限値（非推奨）を削除。
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*  キャッシュされたArelとのリレーションを変更したときの動作（非推奨）を削除。
今後は`ImmutableRelation`エラーが出力される。
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*  `ActiveRecord::Serialization::XmlSerializer`をコアから削除。この機能は[activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gemに移行済み。([Pull Request](https://github.com/rails/rails/pull/21161))

*  古い`mysql`データベースアダプタのサポートをコアから削除。今後は原則として`mysql2`を使用。今後古いアダプタのメンテナンス担当者が決まった場合、アダプタは別のgemに切り出される予定。([Pull Request 1](https://github.com/rails/rails/pull/22642)], [Pull Request 2](https://github.com/rails/rails/pull/22715))

* `protected_attributes` gem のサポートを終了。
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*  PostgreSQL 9.1以前のサポートを削除。
    ([Pull Request](https://github.com/rails/rails/pull/23434))

`activerecord-deprecated_finders` gem のサポートを終了。
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

### 제거 예정

*   クエリでクラスを値として渡すことを非推奨に指定。ユーザーは文字列を渡すこと。([Pull Request](https://github.com/rails/rails/pull/17916))

*   Active Recordのコールバックチェーンを止めるために`false`を返すことを非推奨に指定。代わりに`throw(:abort)`の利用を推奨。([Pull Request](https://github.com/rails/rails/pull/17227))

*  `ActiveRecord::Base.errors_in_transactional_callbacks=`を非推奨に指定。
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   `Relation#uniq`を非推奨に指定。今後は`Relation#distinct`を使用。
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   PostgreSQLの`:point` typeを非推奨に指定。今後は`Array`ではなく`Point`オブジェクトを返す新しいtypeを使用。
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   trueになる引数を関連付け用メソッドに渡して関連付けを強制的に再読み込みする手法を非推奨に指定。
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   関連付け`restrict_dependent_destroy`エラーのキーを非推奨に指定。今後は新しいキー名を使用。
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   `#tables`の動作を統一。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `SchemaCache#tables`、`SchemaCache#table_exists?`、`SchemaCache#clear_table_cache!`を非推奨に指定。今後は新しい同等のデータソースを使用。
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   SQLite3アダプタとMySQLアダプタの`connection.tables`を非推奨に指定。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `#tables`に引数を渡すことを非推奨に指定。一部のアダプタ（mysql2、sqlite3）の`#tables`メソッドはテーブルとビューを両方返すが、他のアダプタはテーブルのみを返す。動作を統一するため、今後は`#tables`はテーブルのみを返すようになる予定。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `table_exists?`を非推奨に指定。`#table_exists?`メソッドでテーブルとビューが両方チェックされていることがあるため。`#tables`の動作を統一するため、今後`#table_exists?`はテーブルのみをチェックするようになる予定。
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   ``find_nth`に`offset`を引数として渡すことを非推奨に指定。今後リレーションでは`offset`メソッドを使用。
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   `DatabaseStatements`の`{insert|update|delete}_sql`を非推奨に指定。
   今後は`{insert|update|delete}`パブリックメソッドを使用。
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   `use_transactional_fixtures`を非推奨に指定。今後はより明瞭な`use_transactional_tests`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*  `ActiveRecord::Connection#quote`にカラムを渡すことを非推奨に指定。
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*  `start`パラメータを補完する`end`オプション（バッチ処理の停止位置を指定）を`find_in_batches`に追加。
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### 주요 변경점

*  テーブルの作成中に`foreign_key`オプションを`references`に追加。
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*  新しい属性API。([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*  `enum`の定義に`:_prefix`/`:_suffix`オプションを追加。
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*  `ActiveRecord::Relation`に`#cache_key`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*  `timestamps`のデフォルトの`null`値を`false`に変更。
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   `ActiveRecord::SecureToken`を追加。`SecureRandom`を使うモデル内の属性で一意のトークン生成をカプセル化するメソッド。
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   `:if_exists` option for `drop_table`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   `ActiveRecord::Base#accessed_fields`を追加。データベース内の必要なデータだけをselectしたい場合に、参照したモデルでどのフィールドが読み出されたかをこのメソッドで簡単に調べられる。
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   `ActiveRecord::Relation`に`#or`メソッドを追加。WHERE句やHAVING句を結合するOR演算子。
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   `#touch`に`:time`オプションを追加。
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   `ActiveRecord::Base.suppress`を追加。指定のブロックを実行中にレシーバーが保存されないようにする。
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   関連付けが存在しない場合、`belongs_to`でバリデーションエラーが発生するようになった。この機能は関連付けごとに`optional: true`でオフにできる。また、`belongs_to`の`required`オプションも非推奨に指定。今後は`optional`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*  `db:structure:dump`の動作を設定する`config.active_record.dump_schemas`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*  `config.active_record.warn_on_records_fetched_greater_than`オプションを追加。
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   MySQLでネイティブJSONデータタイプをサポート。
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*  PostgreSQLでのインデックス削除の並列実行をサポート。
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*  接続アダプタに`#views`メソッドと`#view_exists?`メソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*  `ActiveRecord::Base.ignored_columns`を追加。カラムの一部をActive Recordに対して隠蔽する。
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   `connection.data_sources`と`connection.data_source_exists?`
Active Recordモデル（通常はテーブルやビュー）を支えるリレーションを特定するのに利用できる。
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*  フィクスチャファイルを使って、モデルのクラスをYAMLファイルそのものの中に設定できるようになった。
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   データベースマイグレーションの生成時に`uuid`をデフォルトの主キーに設定できる機能を追加。([Pull Request](https://github.com/rails/rails/pull/21762))

*  `ActiveRecord::Relation#left_joins`と`ActiveRecord::Relation#left_outer_joins`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*  `after_{create,update,delete}_commit`コールバックを追加。
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*  クラスのマイグレーションに出現するAPIのバージョンを管理し、既存のマイグレーションを損なわずにパラメータを変更したり、非推奨サイクルの間に書き換えるためにバージョンを強制適用したりできるようにした。
    ([Pull Request](https://github.com/rails/rails/pull/21538))

`ApplicationRecord`がアプリのすべてのモデルのスーパークラスとして新設され、`ActionController::Base`に代わって`ApplicationController`を継承する。この変更により、アプリ全体のモデルの動作を1か所で変更できるようになった。
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*  ActiveRecordに`#second_to_last`メソッドと`#third_to_last`メソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*  データベースオブジェクト（テーブル、カラム、インデックス）にコメントを追加して、PostgreSQLやMySQLのデータベースメタデータに保存する機能を追加。
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*  プリペアドステートメントを`mysql2`アダプタに追加（mysql2 0.4.4以降向け）。
従来は古い`mysql`アダプタでしかサポートされていなかった。
config/database.ymlに`prepared_statements: true`と記述することでプリペアドステートメントが有効になる。
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*  `ActionRecord::Relation#update`を追加。リレーションオブジェクトに対して、そのリレーションにあるすべてのオブジェクトのコールバックでバリデーション（検証）を実行できる。
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*  `save`メソッドに`:touch`オプションを追加。タイムスタンプを変更せずにレコードを保存する場合に使用。
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*  PostgreSQL向けに式インデックスと演算子クラスのサポートを追加。
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*  ネストした属性のエラーにインデックスを追加する`:index_errors`オプションを追加。
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*  依存関係の削除（destroy）を双方向に行える機能を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*  トランザクションテストでの`after_commit`コールバックのサポートを追加。
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*  `foreign_key_exists?`メソッドを追加。テーブルに外部キーが存在するかどうかを確認できる。
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*  `touch`メソッドに`:time`オプションを追加。レコードに現在時刻以外の時刻を指定する場合に使用。
    ([Pull Request](https://github.com/rails/rails/pull/18956))

Active Model
------------

자세한 변경사항은 [Changelog][active-model]을 참고해주세요.

### 제거된 것들

*  非推奨の`ActiveModel::Dirty#reset_#{attribute}`と`ActiveModel::Dirty#reset_changes`を削除
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*  XMLシリアライズを削除。この機能は[activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gemに移行済み。
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*  `ActionController::ModelNaming`モジュールを削除。
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### 제거 예정

*   Active Modelのコールバックチェーンを止めるために`false`を返すことを非推奨に指定。代わりに`throw(:abort)`の利用を推奨。([Pull Request](https://github.com/rails/rails/pull/17227))

*  `ActiveModel::Errors#get`、`ActiveModel::Errors#set`、`ActiveModel::Errors#[]=`メソッドの動作が一貫していないため、非推奨に指定。
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*  `validates_length_of`の`:tokenizer`オプションを非推奨に指定。今後はRubyの純粋な機能を使用。
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*  `ActiveModel::Errors#add_on_empty`と`ActiveModel::Errors#add_on_blank`を非推奨に指定。置き換え先の機能はなし。
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### 주요 변경점

*  どのバリデータで失敗したかを調べる`ActiveModel::Errors#details`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*  `ActiveRecord::AttributeAssignment`を`ActiveModel::AttributeAssignment`にも展開。これにより、include可能なモジュールとしてすべてのオブジェクトで使えるようになる。
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   `ActiveModel::Dirty#[attr_name]_previously_changed?`と`ActiveModel::Dirty#[attr_name]_previous_change`を追加。モデルの保存後に一時記録された変更に簡単にアクセスできる。
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*  `valid?`と`invalid?`でさまざまなコンテキストを一度にバリデーションする機能。
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*  `validates_acceptance_of`のデフォルト値として`1`の他に`true`も指定できるようになった。
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

자세한 변경사항은 [Changelog][active-job]을 참고해주세요.

### 주요 변경점

*   `ActiveJob::Base.deserialize`をジョブクラスに委譲（delegate）。これにより、ジョブがシリアライズされたときやジョブ実行時に再度読み込まれたときに、ジョブを任意のメタデータにアタッチできるようになる。
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*  キューアダプタをジョブ単位で構成する機能を追加。ジョブ同士が影響しないように構成できる。
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*  ジェネレータのジョブがデフォルトで`app/jobs/application_job.rb`を継承するようになった。
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*  `DelayedJob`、`Sidekiq`、`qu`、`que`、`queue_classic`で、ジョブIDを`provider_job_id`として`ActiveJob::Base`に返す機能を追加。
    ([Pull Request](https://github.com/rails/rails/pull/20064)、[Pull Request](https://github.com/rails/rails/pull/20056)、[commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*  ジョブを`concurrent-ruby`スレッドプールにキューイングする簡単な`AsyncJob`プロセッサと、関連する`AsyncAdapter`を実装。
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   デフォルトのアダプタをinlineからasyncに変更。デフォルトをasyncにすることで、テストを同期的な振る舞いに依存せずに行える。
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

자세한 변경사항은 [Changelog][active-support]을 참고해주세요.

### 제거된 것들

*  非推奨の`ActiveSupport::JSON::Encoding::CircularReferenceError`を削除。
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*  非推奨の`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`メソッドと`ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`メソッドを削除。
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*  非推奨の`ActiveSupport::SafeBuffer#prepend`を削除。
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   `Kernel`、`silence_stderr`、`silence_stream`、`capture`、`quietly`から非推奨メソッドを多数削除。
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*  非推奨の`active_support/core_ext/big_decimal/yaml_conversions`ファイルを削除。
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*  非推奨の`ActiveSupport::Cache::Store.instrument`メソッドと`ActiveSupport::Cache::Store.instrument=`メソッドを削除。
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*  非推奨の`Class#superclass_delegating_accessor`を削除。
   今後は`Class#class_attribute`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*  非推奨の`ThreadSafe::Cache`を削除。今後は`Concurrent::Map`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*  Ruby 2.2 で既に実装されている`Object#itself`を削除。
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### 제거 예정

*  `MissingSourceFile`を非推奨に指定。今後は`LoadError`を使用。
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*  `alias_method_chain`を非推奨に指定。今後はRuby 2.0 で導入された`Module#prepend`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*  `ActiveSupport::Concurrency::Latch`を非推奨に指定。今後は`Concurrent::CountDownLatch` from concurrent-rubyを使用。
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*  `:prefix` option of `number_to_human_size`を非推奨に指定。置き換え先はなし。
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*  `Module#qualified_const_`を非推奨に指定。今後はビルトインの`Module#const_`メソッドを使用。
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*  コールバック定義に文字列を渡すことを非推奨に指定。
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*  `ActiveSupport::Cache::Store#namespaced_key`、`ActiveSupport::Cache::MemCachedStore#escape_key`、`ActiveSupport::Cache::FileStore#key_file_path`を非推奨に指定。
   今後は`normalize_key`を使用。

   `ActiveSupport::Cache::LocaleCache#set_cache_value`を非推奨に指定。今後は`write_cache_value`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*  `assert_nothing_raised`に引数を渡すことを非推奨に指定。
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*  `Module.local_constants`を非推奨に指定。今後は`Module.constants(false)`を使用。
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### 주요 변경점

*  `ActiveSupport::MessageVerifier`に`#verified`メソッドと`#valid_message?`メソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*  コールバックチェーンの停止方法を変更。今後は明示的に`throw(:abort)`で停止することを推奨。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*  新しい設定オプション`config.active_support.halt_callback_chains_on_return_false`を追加。ActiveRecord、ActiveModel、ActiveModel::Validationsのコールバックチェーンを、'before'コールバックで`false`を返したときに停止するかどうかを指定する。
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*  デフォルトのテスト実行順を`:sorted`から`:random`に変更。
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   `#on_weekend?`メソッド、`#on_weekday?`メソッド、`#next_weekday`メソッド、`#prev_weekday`メソッドを`Date`、`Time`、`DateTime`に追加。
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*  `Date`、`Time`、`DateTime`の`#next_week`と`#prev_week`に`same_time`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*  `Date`、`Time`、`DateTime`の`#yesterday`と`#tomorrow`に、`#prev_day`と`#next_day`に対応するメソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*  ランダムなbase58文字列を生成する`SecureRandom.base58`を追加。
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*  `file_fixture`を`ActiveSupport::TestCase`に追加。
   テストケースからサンプルファイルにアクセスするシンプルな機能を提供する。
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*  `Enumerable`と`Array`に`#without`を追加。指定の要素を除外して、列挙のコピーを返す。
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*  `ActiveSupport::ArrayInquirer`と`Array#inquiry`を追加。
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*  指定のタイムゾーンで時刻を解析する`ActiveSupport::TimeZone#strptime`を追加。
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*  `Integer#zero?`に加えて`Integer#positive?`と`Integer#negative?`クエリメソッドを追加。
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*  `ActiveSupport::OrderedOptions`に破壊的なgetメソッドを追加。値が`.blank?`の場合は`KeyError`が発生。
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*  指定の年の日数を返す`Time.days_in_year`を追加。引数がない場合は現在の年の日数を返す。
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*  ファイルのイベント監視機能を追加。アプリケーションのソースコード、ルーティング、ロケールなどの変更を非同期的に検出する。
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*  スレッドごとのクラス変数やモジュール変数を宣言するメソッド群 thread_m/cattr_accessor/reader/writer を追加。
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   `Array#second_to_last`メソッドと`Array#third_to_last`メソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*  `Date`、`Time`、`DateTime`に`#on_weekday?`メソッドを追加。
    ([Pull Request](https://github.com/rails/rails/pull/23687))

* `ActiveSupport::Executor` APIと`ActiveSupport::Reloader` APIを公開。アプリケーションコードの実行やアプリケーションの再読み込みプロセスを、コンポーネントやライブラリから管理したり参加したりできる。
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*  `ActiveSupport::Duration`でISO8601形式のフォーマットや解析をサポート。
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*  `ActiveSupport::JSON.decode`でISO8601形式のローカル時刻をサポート（`parse_json_times`を有効にした場合）。
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*  `ActiveSupport::JSON.decode`が日付の文字列ではなく`Date`オブジェクトを返すようになった。
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*  `TaggedLogging`をロガーに追加。ロガーのインスタンスを複数作成して、タグがロガー同士で共有されないようにする。
    ([Pull Request](https://github.com/rails/rails/pull/9065))

クレジット表記
-------

Railsを頑丈かつ安定したフレームワークにするために多大な時間を費やしてくださった多くの開発者については、[Railsコントリビューターの完全なリスト](http://contributors.rubyonrails.org/)을 참고해주세요.これらの方々全員に深く敬意を表明いたします。
[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
