Ruby on Rails 5.0 릴리스 노트
===============================

Rails 5.0에서 주목할 점

* 액션 케이블
* Rails API
* 액션 레코드 속성 API
* 테스트 러너
* Rake 명령을 `rails` 명령으로 통일
* Sprockets 3
* Turbolinks 5
* 루비 2.2.2 이상의 버전을 요구

이 릴리스에서는 주요 변경점에 대해서만 설명합니다. 수정된 버그 및 변경점에 대해서는 Github Rails
저장소에 있는 changelog나 [커밋 목록](https://github.com/rails/rails/commits/5-0-stable)을
참고해주세요.

--------------------------------------------------------------------------------

Rails 5.0로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것이 좋습니다.
애플리케이션이 Rails 4.2로 업그레이드되지 않았다면 우선 이를 우선하고, 애플리케이션이 정상적으로
동작하는지 충분히 확인한 뒤에 Rails 5.0을 올려주세요. 업그레이드 시의 주의점에 대해서는
[Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#rails-4-2에서-rails-5-0로-업그레이드)를 참고해주세요.


주요 변경점
--------------

### 액션 케이블
[Pull Request](https://github.com/rails/rails/pull/22586)

액션 케이블은 Rails 5에서 새롭게 도입된 프레임워크로 Rails 애플리케이션에서
[웹 소켓](https://en.wikipedia.org/wiki/WebSocket)과 관련된 부분을 부드럽게 통합합니다.

액션 케이블을 도입하면, Rails 애플리케이션의 좋은 생산성과 확장 가능성을 유지하며 기존의 Rails
애플리케이션과 동일한 스타일, 방법으로 실시간 기능을 루비로 작성할 수 있습니다. 액션 케이블은 클라이언트
쪽의 자바 스크립트 프레임워크와 서버 쪽의 루비 프레임워크를 동시에 제공합니다. 액션 레코드와 같은
ORM으로 작성된 모든 도메인 모델에 접근할 수 있습니다.

자세한 설명은 [액션 케이블의 개요](action_cable_overview.html)를 참조해주세요.

### API 애플리케이션

API만을 제공하는 간단한 애플리케이션을 Rails를 사용해 생성할 수 있게 되었습니다.
[Twitter](https://dev.twitter.com) API나 [GitHub](http://developer.github.com)
API와 같은 공용 API 서버는 물론, 그 외의 애플리케이션을 위한 API 서버를 작성할 때에도 편리합니다.

API Rails 애플리케이션을 생성하려면 다음의 명령어를 사용합니다.

```bash
$ rails new my_api --api
```

이 명령은 다음 3개의 동작을 실행합니다.

- 사용하는 미들웨어를 일반적인 상황보다 적게 사용하여 서버를 실행하도록 설정합니다.
  특히 브라우저용 애플리케이션에서 유용한 미들웨어(쿠키에 대한 지원 등)를 일체 사용할 수 없게 됩니다.
- `ApplicationController`는 기존의 `ActionController::Base` 대신에
  `ActionController::API`를 상속합니다. 미들웨어와 마찬가지로 액션컨트롤러 모듈에서 브라우저용
  애플리케이션에서만 사용되는 모듈을 모두 제외합니다.
- 제너레이터가 뷰, 헬퍼, 애셋을 생성하지 않습니다.

생성된 API 애플리케이션은 API 제공하기 위한 토대가 되며, 필요에 따라서
[기능을 추가](api_app.html) 할 수 있습니다.

자세한 설명은 [Rails에서 API 전용 애플리케이션을 만들기](api_app.html)를 참고하세요.

### 액티브 레코드 속성 API

모델에 type 속성을 정의합니다. 필요하다면 기존의 속성을 덮어써도 좋습니다.
이를 사용하여 모델의 속성을 SQL로 어떻게 상호변환할지를 제어할 수 있습니다.
또한 `ActiveRecord::Base.where`에 넘겨진 값의 동작을 변경할 수도 있습니다.
이를 통하여 구현의 세부나 몽키 패치에 의존하지 않고 액티브 레코드의 대부분에서 도메인
객체를 사용할 수 있게 됩니다.

다음과 같이 사용할 수도 있습니다.

* 액티브 레코드에서 검출된 타입을 덮어쓸 수 있습니다.
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
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**커스텀 타입 만들기:**

독자적인 타입을 정의할 수 있으며, 이는 값의 타입으로 정의된 메소드에 응답하는 경우에 한해서만 가능합니다.
`deserialize` 메소드나 `cast` 메소드는 작성한 타입 객체로 호출되어 데이터베이스나 컨트롤러에게
받은 실제 입력을 인자로 사용합니다.
이는 통화 변환처럼 직접 별도의 변환을 해야하는 경우에 유용합니다.

**쿼리하기:**

`ActiveRecord::Base.where`이 호출되면 모델 클래스에 정의된 타입을 사용하여 값을 SQL로 변환하고,
그 값의 객체로 `serialize`를 호출합니다.

이를 통해서 SQL 쿼리를 실행할 때에 객체를 어떻게 변환할지를 지정할 수 있게 됩니다.

**Dirty Tracking:**

타입의 속성은 'Dirty Tracking'의 실행 방법을 변경할 수 있게 해줍니다.

자세한 내용은 [문서](http://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html)를 참고해주세요.


### 테스트 러너

새로운 테스트 러너가 도입되어, Rails에서의 테스트 실행 기능이 강화되었습니다.
`bin/rails test`로 명령하면 테스트 러너를 사용할 수 있습니다.

테스트 러너는 `RSpec`, `minitest-reporters`, `maxitest` 등으로부터 영감을 얻었습니다.
다음과 같은 많은 개선이 이루어졌습니다.

- 테스트의 줄번호를 지정하여 한 테스트만을 실행합니다.
- 테스트의 줄번호를 지정하여 여러 테스트를 실행합니다.
- 실패한 경우에 보여주는 메시지가 개선되어, 실패한 테스트를 곧장 재실행할 수 있게 되었습니다.
- `-f` 옵션을 사용하면 실패했을 때에 곧바로 테스트를 정지할 수 있습니다.
- `-d` 옵션을 사용하면 테스트가 완료될때까지 메시지 출력을 미룰 수 있습니다.
- `-b` 옵션을 사용하면 예외에 대한 전체 백트레이스를 얻을 수 있습니다.
- `Minitest`와 통합되어 `-s`로 시드 데이터를 지정, `-n`으로 특정 테스트명을 지정,
  `-v`로 자세한 메시지 출력을 활성화 하는 등 다양한 옵션을 사용할 수 있게 되었습니다.
- 테스트 출력에 색깔이 추가되었습니다.

Railties
--------

자세한 변경사항은 [Changelog][railties]를 참고해주세요.

### 제거된 것들

*  `debugger`를 지원하지 않습니다. `debugger`는 루비 2.2에서는 지원되지 않으므로 앞으로는 byebug를 사용.
    ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   제거 예정이었던 `test:all` 태스크와 `test:all:db` 태스크를 제거.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   제거 예정이었던 `Rails::Rack::LogTailer`를 제거.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   제거 예정이었던 `RAILS_CACHE` 상수를 제거.
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

*   Rails 애플리케이션을 touch `tmp/restart.txt`로 재기동하는 `bin/rails restart` 태스크가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   모든 정의된 이니셜라이져를 Rails가 실행하는 순서대로 출력하는 `bin/rails initializers` 태스크가 추가됨.
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

자세한 변경사항은 [Changelog][action-pack]를 참고해주세요.

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

*   `ActionDispatch::IntegrationTest`와 `ActionController::TestCase`에서 순서대로 들어오는 인자를 받는 방식을 제거 예정. 앞으로는 키워드 인자를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   경로 파라미터 `:controller`와 `:action`가 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   컨트롤러의 인스턴스에서 env 메소드가 제거 예정.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser`가 제거 예정이 되고, 미들웨어 스택에서 제거됨.
    앞으로 파라미터 파서가 필요한 경우에는 `ActionDispatch::Request.parameter_parsers=`를 사용.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1), [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### 주요 변경점

*   컨트롤러 액션의 외부에서 임의의 템플릿을 랜더링할 수 있는 `ActionController::Renderer`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   `ActionController::TestCase`와 `ActionDispatch::Integration`의 HTTP 요청 메소드에 키워드 인자 구문이 통합됨.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   만료 기한이 없는 응답을 캐싱하는 `http_cache_forever`가 액션컨트롤러에 추가됨.
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

*   `ActionController::TestCase`는 Rails 5.1에서 gem으로 추출될 예정. 앞으로는 `ActionDispatch::IntegrationTest`를 사용.
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails에서 기본으로 '약한' ETag를 생성함.
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   컨트롤러 액션에서 `render`가 명시적으로 호출되지 않고, 대응하는 템플릿도 없는 경우, 에러 대신에 `head :no_content`를 암묵적으로 호출하게 됨.
    (Pull Request [1](https://github.com/rails/rails/pull/19377), [2](https://github.com/rails/rails/pull/23827))

*   폼마다 CSRF 토큰을 생성할 수 있는 옵션이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   요청의 인코딩과 응답을 해석하는 부분이 통합 테스트에 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/21671))

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

*   `Response#strong_etag=`와 `#weak_etag=`와 `fresh_when`과 `stale?`에 관련된
    옵션이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

자세한 변경사항은 [Changelog][action-view]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 `AbstractController::Base::parent_prefixes`를 제거함.
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   `ActionView::Helpers::RecordTagHelper`를 제거함.
    이 기능은 [record_tag_helper](https://github.com/rails/record_tag_helper) gem에 추출되어 있음.
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   `translate`의 `:rescue_format`에 대한 i18n 지원이 중지됨에 따라 해당 옵션을 제거함.
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### 주요 변경점

*   기본 템플릿 핸들러가 `ERB`에서 `Raw`로 변경됨.
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   컬렉션 렌더링에서 여러 부분(파셜) 템플릿의 캐싱을 한번에 처리할 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/18948), [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   명시적인 의존 관계 지정 시에 와일드 카드를 사용하는 매칭 방식을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   `disable_with`를 submit 태그의 기본 동작으로 설정. 이를 통해 전송시에 버튼의 동작을 무시하여 이중 전송을 예방함.
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   부분(파셜) 템플릿 이름에서 유효하지 않은 루비 식별자가 허용됨.
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   `datetime_tag` 헬퍼에서 `datetime-local`를 지정한 input 태그를 생성할 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/25469))


Action Mailer
-------------

자세한 변경사항은 [Changelog][action-mailer]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 `*_path` 헬퍼를 email 뷰로부터 제거.
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   제거 예정이었던 `deliver` 메소드와 `deliver!`를 제거.
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### 주요 변경점

*   템플릿을 검색할 때에 기본 로케일과 i18n 폴백을 사용하게 됨.
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   제너레이터로 생성된 메일러에 `_mailer` 접미자가 추가됨. 컨트롤러나 잡과 동일한 명명 규칙을 따름.
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   `assert_enqueued_emails`와 `assert_no_enqueued_emails`가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   메일러 큐 이름을 설정하기 위한 `config.action_mailer.deliver_later_queue_name` 옵션이 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   Action Mailer 뷰에서 조각 캐시를 지원.
    템플릿에서 케시가 유효한지를 확인하기 위한 `config.action_mailer.perform_caching` 옵션이 추가.
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

자세한 변경사항은 [Changelog][active-record]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 중첩된 배열을 쿼리로 넘기는 기능이 제거됨.
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   제거 예정이었던 `ActiveRecord::Tasks::DatabaseTasks#load_schema`이 제거됨.
    이 메소드는 `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`로 대체되어 있음.
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   제거 예정이었던 `serialized_attributes`이 제거됨.
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   제거 예정이었던 `has_many :through`의 자동 카운터 캐시가 제거됨.
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   제거 예정이었던 `sanitize_sql_hash_for_conditions`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   제거 예정이었던 `Reflection#source_macro`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   제거 예정이었던 `symbolized_base_class`와 `symbolized_sti_name`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   제거 예정이었던 `ActiveRecord::Base.disable_implicit_join_references=`가 제거됨.
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   제거 예정이었던 문자열 접근자에 의한 커넥션에 접근하는 방식이 제거됨.
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   제거 예정이었던 인스턴스에 의존하는 미리 읽기 기능에 대한 지원이 제거됨.
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   제거 예정이었던 PostgreSQL에서만 사용되는 배타 하한치가 제거됨.
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   제거 예정이었던 캐시된 Arel과의 관계를 변경했을 시의 동작이 제거됨.
    앞으로는 `ImmutableRelation` 에러가 발생.
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   `ActiveRecord::Serialization::XmlSerializer`이 제거됨.
    이 기능은 [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem으로 추출됨.
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   오래된 `mysql` 데이터베이스 어댑터에 대한 지원이 제거됨.
    앞으로는 `mysql2`를 사용. 오래된 어댑터에 대한 유지 보수 담당자가 정해지면 해당 어댑터는 별도의 gem으로 분리될 예정.
    ([Pull Request 1](https://github.com/rails/rails/pull/22642), [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   `protected_attributes` 잼 지원이 종료됨.
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   PostgreSQL 9.1 이하 지원이 종료.
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   `activerecord-deprecated_finders` 잼 지원이 종료됨.
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES` 상수가 제거됨.
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### 제거 예정

*   쿼리로 클래스를 값으로 넘기는 기능이 제거 예정. 사용자는 문자열을 넘길 것.
    ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Active Record의 콜백 체인을 멈추기 위해 `false`를 반환하는 방식을 제거 예정.
    대신 `throw(:abort)`의 사용을 권장.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   `ActiveRecord::Base.errors_in_transactional_callbacks=`이 제거 예정.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   `Relation#uniq`이 제거 예정. 앞으로는 `Relation#distinct`를 사용.
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   PostgreSQL의 `:point` 타입이 제거 예정. 앞으로는 `Array`가 아닌 `Point` 객체를 반환하는 새 타입을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   true가 되는 인자를 관계용 메소드에 넘겨서 관계된 객체들을 강제적으로 새로고침하는 방법이 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   관계 `restrict_dependent_destroy` 에러의 키를 제거 예정. 앞으로는 새로운 키 이름을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   `#tables`의 동작을 통일.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `SchemaCache#tables`, `SchemaCache#table_exists?`, `SchemaCache#clear_table_cache!`이 제거 예정.
    앞으로는 새로운 데이터 소스를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   SQLite3 어댑터와 MySQL 어댑터의 `connection.tables`가 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `#tables`에 인자를 넘기는 방식이 제거 예정.
    일부 어댑터(mysql2, sqlite3)의 `#tables` 메소드는 테이블과 뷰를 모두 반환하지만, 다른 어뎁터는 테이블만을 반환함.
    동작을 통일하기 위해서, 앞으로는 `#tables`는 테이블 만을 반환할 예정.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `table_exists?`가 제거 예정.
    `#table_exists?` 메소드에서 테이블과 뷰가 확인되는 경우가 있기 때문에.
    `#tables`의 동작을 통일하기 위해서, 앞으로 `#table_exists?`는 테이블만을 체크할 예정.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   `find_nth`에 `offset`을 인자로 넘기는 방식이 제거 예정. 앞으로 관계에서는 `offset` 메소드를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   `DatabaseStatements`의 `{insert|update|delete}_sql`가 제거 예정.
    앞으로는 `{insert|update|delete}` 공개 메소드를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   `use_transactional_fixtures`가 제거 예정. 앞으로는 좀 더 명확한 `use_transactional_tests`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   `ActiveRecord::Connection#quote`에 컬럼을 넘기는 방식이 제거 예정.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   `start` 파라미터를 보완하며 어느 시점에서 배치 처리를 중단할 지 지정하는 `end` 옵션을 `find_in_batches`에 추가.
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### 주요 변경점

*   테이블 생성 중에 `foreign_key` 옵션을 `references`에 추가.
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   새 속성 API. ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   `enum`의 정의에 `:_prefix`/`:_suffix` 옵션을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   `ActiveRecord::Relation`에 `#cache_key`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   `timestamps`의 기본 `null` 값을 `false`로 변경.
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   `ActiveRecord::SecureToken`을 추가. `SecureRandom`을 사용하여 유일한 토큰을 생성하는 작업을 캡슐화.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   `drop_table`에 `:if_exists` 옵션을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   `ActiveRecord::Base#accessed_fields`을 추가.
    데이터베이스에 필요한 데이터만을 가져오고 싶은 경우에, 참조한 모델에서 어떤 필드가 접근되었는지를 쉽게 확인할 수 있음.
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   `ActiveRecord::Relation`에 `#or` 메소드를 추가. WHERE절이나 HAVING절을 결합.
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   `ActiveRecord::Base.suppress`을 추가. 지정 블럭을 실행 중에 수신자가 저장되지 않도록 함.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   관계가 존재하지 않는 경우 `belongs_to`에서 검증 에러가 발생하게 됨.
    이는 관계 마다 `optional: true`를 사용해서 비활성화 할 수 있음.
    또한 `belongs_to`의 `required` 옵션이 제거 예정. 앞으로는 `optional`을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*  `db:structure:dump`의 동작을 정의하는 `config.active_record.dump_schemas`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*  `config.active_record.warn_on_records_fetched_greater_than` 옵션을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   MySQL에서 네이티브 JSON 데이터 형식을 지원.
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   PostgreSQL에서의 인덱스 삭제를 병렬로 실행할 수 있도록 지원.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   커넥션 어댑터에 `#views` 메소드와 `#view_exists?` 메소드가 추가.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   `ActiveRecord::Base.ignored_columns`를 추가.
    컬럼의 일부를 Active Record에서는 보이지 않게 함.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   `connection.data_sources`와 `connection.data_source_exists?`.
    Active Record 모델 뒤에서 어떤 것(일반적으로는 테이블이나 뷰)을 사용할지 지정할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   픽스쳐 파일을 사용하여 모델의 클래스를 YAML 파일 내에서 그 자체를 정의할 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   데이터베이스 마이그레이션 생성시에 `uuid`를 기본키로 지정할 수 있는 기능을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   `ActiveRecord::Relation#left_joins`와 `ActiveRecord::Relation#left_outer_joins`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   `after_{create,update,delete}_commit` 콜백을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   마이그레이션 클래스에 출현하는 API 버전을 관리하고, 제거 예정인 것과 관계 있더라도 기존의 마이그레이션에 영향을 주지 않고 파라미터를 변경하거나 제거하기 위해 버전을 강제적으로 적용할 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ActionController::Base` 대신에 `ApplicationController`를 상속하는 것처럼 `ApplicationRecord`가 애플리케이션의 모든 모델의 부모 클래스로서 추가됨. 이 변경으로 애플리케이션 모델 전체에 영향을 미치는 동작을 한 곳에서 관리 가능해짐.
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   ActiveRecord에 `#second_to_last` 메소드와 `#third_to_last` 메소드를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   데이터베이스 객체(테이블, 컬럼, 인덱스)에 코멘트를 추가하여, PostgreSQL이나 MySQL의 데이터베이스 메타 데이터로 저장하는 기능을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Prepared Statement를 `mysql2` 어댑터에 추가(mysql2 0.4.4 이후 적용).
    기존의 오래된 `mysql` 어댑터에서만 지원되었었음.
    config/database.yml에 `prepared_statements: true`를 추가하면 사용할 수 있게됨.
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*  `ActionRecord::Relation#update`를 추가.
    관계 객체에 대해서 해당 관계에 있는 모든 객체의 콜백에 대해서 검증을 실행할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*  `save` 메소드에 `:touch` 옵션이 추가됨. 타임 스탬프를 변경하지 않고 레코드를 저장할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   PostgreSQL를 위한 식 인덱스와 연산자 클래스 지원을 추가.
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*   중첩된 속성의 에러에 인덱스를 추가하는 `:index_errors` 옵션을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   양방향 의존 관계 삭제를 할 수 있는 기능을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   트랜잭션 테스트에서 `after_commit` 콜백 지원을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   `foreign_key_exists?` 메소드를 추가. 테이블에 외래키가 존재하는지를 확인할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   `touch` 메소드에 `:time` 옵션을 추가. 레코드에 현재 시각 이외의 시각을 지정할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/18956))

Active Model
------------

자세한 변경사항은 [Changelog][active-model]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 `ActiveModel::Dirty#reset_#{attribute}`와 `ActiveModel::Dirty#reset_changes`를 제거.
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   XML 직렬화를 제거.
    이 기능은 [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml) gem으로 추출되었음.
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   `ActionController::ModelNaming` 모듈을 제거.
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### 제거 예정

*   Active Model의 콜백 체인을 멈추기 위해서 `false`를 반환하던 방식을 제거 예정.
    대신에 `throw(:abort)`의 이용을 추천.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   `ActiveModel::Errors#get`, `ActiveModel::Errors#set`, `ActiveModel::Errors#[]=` 메소드의 동작이 일관적이지 않아 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   `validates_length_of`의 `:tokenizer` 옵션이 제거 예정. 앞으로는 순수하게 Ruby의 기능을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   `ActiveModel::Errors#add_on_empty`와 `ActiveModel::Errors#add_on_blank`가 제거 예정. 대체 예정 없음.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### 주요 변경점

*   어떤 검증자가 실패했는지 확인하는 `ActiveModel::Errors#details`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   `ActiveRecord::AttributeAssignment`를 `ActiveModel::AttributeAssignment`로 추출하여 include 가능한 모듈로 만듬.
    이를 통해 어디서든 include하여 사용할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   `ActiveModel::Dirty#[attr_name]_previously_changed?`와 `ActiveModel::Dirty#[attr_name]_previous_change`를 추가.
    모델을 저장된 이후에 기록된 변경점에 간단하게 접근할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   `valid?`와 `invalid?`에서 다양한 컨텍스트를 한번에 검증하는 기능이 추가.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   `validates_acceptance_of`의 기본 값으로 `1` 대신에 `true`를 지정할 수 있게 변경.
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

자세한 변경사항은 [Changelog][active-job]를 참고해주세요.

### 주요 변경점

*   `ActiveJob::Base.deserialize`를 잡 클래스로 위임.
    이를 통해 잡이 직렬화되었을 때나 잡 실행시에 다시 로딩될 때에 잡에 임의의 메타 데이터를 붙일 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   큐 어댑터를 잡 단위로 구성하는 기능을 추가. 잡들이 서로 영향을 주지 않도록 구성할 수 있음.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   제터레이터의 잡이 기본으로 `app/jobs/application_job.rb`를 상속.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   `DelayedJob`, `Sidekiq`, `qu`, `que`, `queue_classic`에서 잡 ID를 `provider_job_id`로 하여 `ActiveJob::Base`에 반환하는 기능을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/20064)、[Pull Request](https://github.com/rails/rails/pull/20056)、[commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   잡을 `concurrent-ruby` 스레드 풀에 큐잉하는 간단한 `AsyncJob` 프로세서와, 이와 관련된 `AsyncAdapter`를 구현.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   기본의 어뎁터를 인라인에서 비동기로 변경. 테스트 환경에서 동기적인 상황에 의존하지 않도록 해줌.
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

자세한 변경사항은 [Changelog][active-support]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 `ActiveSupport::JSON::Encoding::CircularReferenceError`을 삭제.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   제거 예정이었던 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=` 메소드와 `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string` 메소드를 제거.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   제거 예정이었던 `ActiveSupport::SafeBuffer#prepend`을 제거.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   `Kernel`, `silence_stderr`, `silence_stream`, `capture`, `quietly`에서 제거 예정이었던 메소드를 다수 제거.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   제거 예정이었던 `active_support/core_ext/big_decimal/yaml_conversions` 파일을 제거.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   제거 예정이었던 `ActiveSupport::Cache::Store.instrument` 메소드와 `ActiveSupport::Cache::Store.instrument=` 메소드를 제거.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   제거 예정이었던 `Class#superclass_delegating_accessor`를 제거.
    앞으로는 `Class#class_attribute`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   제거 예정이었던 `ThreadSafe::Cache`을 제거. 앞으로는 `Concurrent::Map`을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Ruby 2.2에서 구현되어 있는 `Object#itself`를 제거.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### 제거 예정

*   `MissingSourceFile`가 제거 예정. 앞으로는 `LoadError`를 사용.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   `alias_method_chain`가 제거 예정. 앞으로는 Ruby 2.0에서 도입된 `Module#prepend`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   `ActiveSupport::Concurrency::Latch`가 제거 예정.
    앞으로는 `concurrent-ruby`의 `Concurrent::CountDownLatch`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   `number_to_human_size`의 `:prefix` 옵션이 제거 예정. 대체 예정 없음.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   `Module#qualified_const_`가 제거 예정. 앞으로는 내정된 `Module#const_` 메소드를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   콜백 정의에 문자열을 넘기는 기능이 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*  `ActiveSupport::Cache::Store#namespaced_key`, `ActiveSupport::Cache::MemCachedStore#escape_key`, `ActiveSupport::Cache::FileStore#key_file_path`이 제거 예정.
    앞으로는 `normalize_key`를 사용.

*   `ActiveSupport::Cache::LocaleCache#set_cache_value`가 제거 예정. 앞으로는 `write_cache_value`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   `assert_nothing_raised`에 인자를 넘기는 방식이 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   `Module.local_constants`가 제거 예정. 앞으로는 `Module.constants(false)`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### 주요 변경점

*   `ActiveSupport::MessageVerifier`에 `#verified` 메소드와 `#valid_message?` 메소드가 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   콜백 체인을 정지하는 방법이 변경. 앞으로는 명시적으로 `throw(:abort)`로 멈추는 것을 추천.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   새로운 설정 옵션 `config.active_support.halt_callback_chains_on_return_false` 이 추가.
    ActiveRecord, ActiveModel, ActiveModel::Validations의 콜백 체인을 'before' 콜벡에서 `false`를 반환할 때 멈출지를 지정.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   기본 테스트 실행 순서가 `:sorted`에서 `:random`로 변경.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` 메소드가 `Date`, `Time`, `DateTime`에 추가됨.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*  `Date`, `Time`, `DateTime`의 `#next_week`와 `#prev_week`에 `same_time`을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*  `Date`, `Time`, `DateTime`의 `#yesterday`와 `#tomorrow`에 `#prev_day`와 `#next_day`에 대응하는 메소드를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   임의의 base58 문자열을 생성하는 `SecureRandom.base58`을 추가.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   `file_fixture`를 `ActiveSupport::TestCase`에 추가.
    테스트 케이스에서 샘플 파일에 접근하는 간단한 기능을 제공.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   `Enumerable`와 `Array`에 `#without`을 추가. 지정한 요소를 제외한 사본을 반환.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   `ActiveSupport::ArrayInquirer`와 `Array#inquiry`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   지정한 타임존으로 시각을 해석하는 `ActiveSupport::TimeZone#strptime`을 추가.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   `Integer#zero?`에 더불어 `Integer#positive?`와 `Integer#negative?` 메소드를 추가.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   `ActiveSupport::OrderedOptions`에 파괴적인 get 메소드가 추가. 값이 `.blank?`인 경우에는 `KeyError`가 발생.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   지정한 년도의 일수를 반환하는 `Time.days_in_year`가 추가. 인자가 없는 경우는 현재 년도를 사용.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   파일의 이벤트 감시 기능이 추가. 애플리케이션의 소스 코드, 라우팅, 로케일 등의 변경을 비동기적으로 검출.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   스레드마다 클래스 변수나 모듈 변수를 선언하는 메소드 군 thread_m/cattr_accessor/reader/writer을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   `Array#second_to_last`와 `Array#third_to_last` 메소드가 추가.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   `ActiveSupport::Executor` API와 `ActiveSupport::Reloader` API를 공개.
    애플리케이션 코드 실행이나 애플리케이션의 리로딩 프로세스에서 컴포넌트나 라이브러리로 관리하거나 추가할 수 있게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration`에서 ISO8601 형식의 형식 및 해석을 지원.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `parse_json_times`이 유효한 경우, `ActiveSupport::JSON.decode`에서 ISO8601 형식의 로컬 시각을 지원.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode`가 날짜 문자열이 아닌 `Date` 객체를 반환하게 됨.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `TaggedLogging`를 로거에 추가. 로거 인스턴스를 복수 생성하여 태그가 로거간에 공유되지 않도록 함.
    ([Pull Request](https://github.com/rails/rails/pull/9065))

크레딧 표기
-------

Rails를 견고하고 안정적인 프레임워크로 만들기 위해 많은 시간을 사용해주신 많은 개발자들에 대해서는 [Rails 기여자 목록](http://contributors.rubyonrails.org/)을 참고해주세요. 이 분들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
