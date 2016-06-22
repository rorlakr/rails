
Rails 애플리케이션 설정
==============================

이 가이드에서는 Rails 애플리케이션에서 사용 가능한 설정과 초기화기능에 대해서 설명합니다.

이 가이드의 내용:

* Rails 애플리케이션의 동작을 변경하는 방법
* 애플리케이션 시작 시에 함께 실행할 코드를 추가하는 방법

--------------------------------------------------------------------------------

초기화 코드를 둘 수 있는 장소
---------------------------------

Rails에는 초기화 코드를 둘 수 있는 장소는 4곳이 있습니다.

* `config/application.rb`
* 환경에 따른 설정 파일
* initializer
* after initializer

Rails 실행 전에 코드를 실행하기
-------------------------

애플리케이션으로 어떤 코드를 Rails 자체가 로드되기 전에 실행되어야 할 때가 있습니다. 그러한 경우에는 실행하고 싶은 코드를 `config/application.rb` 파일의 `require 'rails/all'` 보다 앞에 위치시켜 주세요.

Rails 컴포넌트를 구성하기
----------------------------

일반적으로 Rails의 설정 작업이란 Rails 자신을 설정하는 것과 동시에, Rails의 컴포넌트를 설정하는 것이기도 합니다. `config/application.rb`와 환경 고유의 설정 파일(`config/environments/production.rb` 등)에 설정을 정리하여 Rails의 모든 컴포넌트에 각 환경에 맞는 설정 정보를 넘겨줄 수 있습니다.

예를 들자면 `config/application.rb` 파일에는 다음과 같은 설정이 포함되어 있습니다.

```ruby
config.autoload_paths += %W(#{config.root}/extras)
```

이는 Rails 자신을 위한 설정입니다. 설정을 모든 Rails 컴포넌트에 넘기고 싶은 경우에는 `config/application.rb` 내부에 같은 `config` 객체를 사용해서 처리할 수 있습니다.

```ruby
config.active_record.schema_format = :ruby
```

이 설정은 특히 Active Record의 설정에서 자주 사용됩니다.

### Rails 전반에 대한 설정

Rails 전체에 걸친 설정을 하기 위해서는 `Rails::Railtie` 객체를 호출하던가, `Rails::Engine`나 `Rails::Application`의 자식 클래스를 호출합니다.

* `config.after_initialize` 에는 블럭도 넘길 수 있습니다. 이 블럭은 Rails에 의한 애플리케이션 초기화가 종료된 _직후_에 실행됩니다. 애플리케이션 초기화 작업에는 프레임워크 자체의 초기화, 엔진의 초기화, 그리고 `config/initializers`에 기술되어 있는 모든 애플리케이션 initializer의 실행도 포함됩니다. 여기서 넘기는 블럭은 rake Task로서 _실행된다_는 점을 주의해주세요. 이 블록은 다른 initializer에 의해서 정의되는 값을 설정할 때에 편리합니다.

    ```ruby
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags.delete 'div'
    end
    ```

* `config.asset_host`은 애셋을 저장할 호스트를 지정합니다. 이 설정은 애셋을 저장할 장소가 CDN(Contents Delivery Network)일 때나, 다른 도메인을 사용하여 브라우저에서 동시 실행 제한을 피하고 싶은 경우에도 유용합니다. 이 메소드는 `config.action_controller.asset_host`를 줄인 것입니다.

* `config.autoload_once_paths`는 서버가 요청 받을 때마다 초기화되지 않는 상수들을 읽어오기 위한 경로들이 들어있는 배열을 받습니다. `config.cache_classes`가 false 인 경우에 유효하지 않으며, development 모드일 경우에는 기본적으로 false로 동작합니다. `config.cache_classes`가 true인 경우, 모든 `config.autoload_once_paths`는 단 한번만 자동으로 읽어와집니다. `config.autoload_once_paths`의 배열에 포함되는 요소는 다음에 설명할 `autoload_paths`에서도 완전히 동일한 방식으로 호출되어야 합니다. 기본값은 빈 배열입니다.

* `config.autoload_paths`는 Rails가 상수를 자동으로 읽어올 때에 사용할 경로를 포함하는 배열을 인수로 받습니다. `config.autoload_paths`의 기본 값은 `app` 에 존재하는 모든 폴더 입니다(역주: Rails3부터는 autoload_path의 기본값이 빈 배열로 설정되어 있습니다).

* `config.cache_classes`는 애플리케이션의 클래스나 모듈을 요청할 때에 다시 읽어올지(=캐싱되어 있는지 아닌지)를 결정합니다. `config.cache_classes`의 기본값은 development 모드에서는 false이므로 코드의 변경사항이 바로 반영되며, test와 production 모드에서는 true로 설정되어, 동작하는 속도를 빠르게 만듭니다.

* `config.action_view.cache_template_loading`는 요청마다 뷰 템플릿을 다시 읽어올지 아닐지를 결정합니다. 기본값은 `config.cashe_classes`와 같습니다.

* `config.beginning_of_week`는 애플리케이션에서의 일주일의 첫번째 날을 지정합니다. 인수로는 요일을 가리키는 올바른 심볼을 넘겨주세요(`:monday` 등).

* `config.cache_store`는 Rails에서의 캐시 처리에 사용할 캐시 저장소를 결정합니다. 지정 가능한 옵션으로는 `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`중 하나이며, 또는 캐시 API를 구현하고 있는 객체입니다. `tmp/cache` 폴더가 존재하는 경우 기본값으로 `:file_store`로 설정되며, 그 이외의 경우에는 `:memory_store`로 설정됩니다.

* `config.colorize_logging`는 출력할 로그 정보에 ANSI 색상 정보를 추가할지 말지를 결정합니다. 기본은 true입니다.

* `config.consider_all_requests_local`는 플래그입니다. 이 플래그가 true인 경우, 어떤 에러가 발생한 경우에도 상세한 디버그 정보가 HTTP 응답으로 출력되며, `/rails/info/properties`안의 애플리케이션 실행시의 컨텍스트가 `Rails::Info` 컨트롤러에 의해서 출력됩니다. 이 플래그는 development 모드와 test 모드에서는 true, production 모드에서는 false로 설정됩니다. 좀 더 세밀하게 제어하고 싶은 경우에는 이 플래그를 false로 지정한 후, 컨트롤러에서 `local_request?` 메소드를 구현하고, 에러가 발생했을 경우에 어떤 디버그 정보를 출력할지를 지정해주세요.

* `config.console`를 사용하면 콘솔에서 `rails console`를 실행했을 때에 사용될 클래스를 커스터마이즈 할 수 있습니다. 이 메소드는 `console` 블럭과 함께 사용할 때가 편리합니다.

    ```ruby
    console do
      # 이 블럭은 콘솔에서 실행될 때에만 호출된다.
      # 따라서 여기에서 pry를 호출해도 문제 없음
      require "pry"
      config.console = Pry
    end
    ```

* `config.dependency_loading`를 false로 설정하면 상수의 자동 불러오기 설정이 꺼집니다. 이 옵션이 유효한 경우는 `config.cache_classes`가 true인 경우 뿐입니다(`config.cache_classes`는 production 모드에서 기본으로 true입니다). `config.threadsafe!`를 사용하면 이 플래그는 false가 됩니다.

* `config.eager_load`를 true로 설정하면 `config.eager_load_namespaces`에 등록되어 있는 사전에 불러오기로 정의되어 있는 네임스페이스를 모두 불러 옵니다. 여기에는 애플리케이션, 엔진, Rails 프레임워크를 포함하는 모든 등록된 네임스페이스가 포함됩니다.

* `config.eager_load_namespaces`를 사용하여 등록한 이름은 `config.eager_load`가 true일 때에 불러와집니다. 등록된 네임스페이스는 반드시 `eager_load!` 메소드에 반응해야합니다.

* `config.eager_load_paths`는 경로의 배열을 인수로 받습니다. Rails는 cache_classes가 활성화 되어 있을 경우에 이 경로들을 미리 읽어오게(eager load)됩니다. 기본값으로 애플리케이션의 app 폴더에 존재하는 모든 폴더들이 여기에 포함됩니다.

* `config.encoding`은 애플리케이션 전체에서 적용할 인코딩을 지정합니다. 기본 값은 UTF-8입니다.

* `config.exceptions_app`는 예외가 발생한 경우에 ShowException 미들웨어에 의해서 호출되는 애플리케이션 예외를 지정합니다. 기본값은 `ActionDispatch::PublicExceptions.new(Rails.public_path)`입니다.

* `config.file_watcher`는 `config.reload_classes_only_on_change`가 true인 경우에 파일 시스템 상에서 파일 갱신이 있는지를 확인할 때 사용할 클래스를 지정합니다. 이 클래스는 `ActiveSupport::FileUpdateChecker` API에 따를 필요가 있습니다.

* `config.filter_parameters`는 비밀번호나 신용카드번호 등, 로그에 출력하고 싶지 않은 파라미터 값을 필터링으로 제외하기 위해서 사용합니다. 비밀번호를 제외하는 애플리케이션 필터를 추가하기 위해서는 `config/initializers/filter_parameter_logging.rb`에 `config.filter_parameters+=[:password]`를 추가합니다.

* `config.force_ssl`는 `ActionDispatch::SSL` 미들웨어를 사용해서 모든 요청을 HTTPS 프로토콜로 처리하도록 강제합니다.

* `config.log_formatter`는 Rails 로거의 형식을 정의합니다. 이 옵션의 기본값은 `ActiveSupport::Logger::SimpleFormatter`의 인스턴스를 사용합니다. 단, production 모드에서만 `Logger::Formatter`를 기본으로 사용합니다.

* `config.log_level`은 Rails에서 로그 출력을 얼마나 자세하게 내보낼지를 지정합니다. 기본값은 `:debug`로 지정되어 있으며, production 모드에서만 기본값으로 `:info`를 사용합니다.

* `config.log_tags`는 `request` 객체가 응답하는 메소드의 목록을 인수로 받습니다. 이것은 로그에 디버깅 정보를 태그로 붙일때 편리합니다. 예를 들자면, 서브도메인이나 요청 id를 지정하여 production 모드인 애플리케이션을 디버깅할 때 유용합니다.

* `config.logger`는 사용할 로거를 지정합니다. 지정되는 로거는 Log4r 또는 Ruby의 기본 `Logger` 클래스의 인스턴스와 동일한 인터페이스를 가지고 있어야 합니다. 기본값으로는 `ActiveSupport::Logger`의 인스턴스가 지정되어 있습니다.

* `config.middleware`는 애플리케이션에서 사용할 미들웨어를 커스터마이즈할 수 있습니다. 자세한 설명은 [미들웨어 설정하기](#미들웨어-설정하기)를 참조해주세요.

* `config.reload_classes_only_on_change`는 감시하고 있는 파일이 변경되었을 경우에만 클래스를 다시 불러올지 아닐지를 지정합니다. 기본으로는 autoload_path에 지정되어있는 모든 파일이 감시 대상이며, 기본값으로는 true로 설정되어 있습니다. `config.cache_classes`가 on인 경우에는 이 옵션이 무시됩니다.

`secrets.secret_key_base` 메소드는 변조 방지를 위해서 애플리케이션의 세션에 기존의 비밀키와 비교하기 위한 키를 지정할 때에 사용합니다. 애플리케이션은 `secrets.secret_key_base`를 사용하여 `config/secrets.yml` 등에 저장되어 있는 키를 사용해 초기화합니다.

* `config.serve_static_assets`는 정적인 애셋을 다룰지 아닐지를 지정합니다. 기본값으로는 true로 지정되어 있습니다만, production 환경에서는 애플리케이션을 실행하는 Nginx나 Apache등의 서버가 정적인 애셋을 다룰 필요가 있으므로 비활성화됩니다. 기본의 설정과는 다르게 WEBrick을 사용해서 애플리케이션을 production 모드로 실행하거나(절대로 이렇게 사용하지 말아 주세요) 테스트를 하는 경우에는 true로 설정됩니다. 그렇지 않으면 페이지 캐시가 유효하지 않게 되며 public 폴더에 저장되어 있는 정적인 애셋 파일들에 대한 요청은 매번 Rails 애플리케이션을 통하여 처리됩니다.

* `config.session_store`는 일반적으로 `config/initializers/session_store.rb`에서 정의되어 있으며, 세션을 저장할 클래스를 지정합니다. 지정 가능한 값은 `:cookie_store`(기본값), `:mem_cache_store`, `:disabled`입니다. `:disabled`를 지정하면, Rails에서 세션을 사용할 수 없게 됩니다. 커스텀 세션 저장소를 지정할 수도 있습니다.

    ```ruby
    config.session_store :my_custom_store
    ```

커스텀 스토어는 `ActionDispatch::Session::MyCustomStore`로 정의할 필요가 있습니다.

* `config.time_zone`은 애플리케이션의 기본 시간대를 설정하여 Active Record에서 인식할 수 있도록 해줍니다.

### 애셋 설정하기

* `config.assets.enabled`는 애셋 파이프라인을 사용할지 아닐지를 지정합니다. 기본값은 true입니다.

* `config.assets.raise_runtime_errors`를 `true`로 지정하면, 런타임 에러 체크가 활성화됩니다. 이 옵션은 `production` 환경에서 사용하면 배포시에 생각치않은 동작을 발생시킬 가능성이 있으므로 development 환경(`config/environments/development.rb`)에서만 사용하기를 추천합니다.

* `config.assets.compress`는 컴파일된 애셋을 압축할지 아닐지를 지정하는 플래그입니다. `config/environments/production.rb`에서는 명시적으로 true로 지정되어 있습니다.

* `config.assets.css_compressor`는 CSS 압축시에 사용할 프로그램을 지정합니다. 이 옵션은 기본으로 `sass-rails`를 사용하도록 지정되어 있습니다. `:yui`라는 일견 특이해보이는 옵션도 지정할 수 있으며, 이 옵션은 `yui-compressor` gem을 의미합니다.

* `config.assets.js_compressor`는 JavaScript 압축을 수행할 프로그램을 지정합니다. 지정 가능한 값으로는 `:closure`, `:uglifier`, `:yui`입니다. 각각 `closure-compiler`, `uglifier`, `yui-compressor` gem에 대응합니다.

* `config.assets.paths`에는 애셋 검색 시에 사용할 경로를 지정합니다. 이 설정 옵션을 경로에 추가하면, 애셋을 검색할때에 찾을 경로 목록에 추가됩니다.

* `config.assets.precompile`은 `application.css`와 `application.js` 이외에 추가하고 싶은 애셋이 있는 경우에 지정합니다. 이것들은 `rake assets:precompile`을 실행할 때에 함께 컴파일 됩니다.

* `config.assets.prefix`는 애셋을 저장할 폴더를 지정합니다. 기본은 `/assets`입니다.

* `config.assets.digest`는 애셋 이름을 이용하는 MD5 핑거프린트를 사용할지 말지를 지정합니다. `production.rb`에서는 기본으로 `true`로 설정되어 있습니다.

* `config.assets.debug`는 애셋의 연결 및 압축을 무효화할지를 지정합니다. `development.rb`에서는 기본으로 `true`로 지정됩니다.

* `config.assets.cache_store`는 Sprockets에서 사용하는 캐시 저장소를 정의합니다. 기본으로는 Rails의 파일 저장소를 사용합니다.

* `config.assets.version`는 MD5 해시 생성에 사용되는 옵션 문자열입니다. 이 값을 변경하면 모든 애셋 파일이 강제적으로 다시 컴파일 됩니다.

* `config.assets.compile`는 production 환경에서 동적인 Sprockets 컴파일을 할지 말지를 true/false로 지정합니다.

* `config.assets.logger`는 로거를 인수로 받습니다. 이 로거는 Log4의 인터페이스나 Ruby의 `Logger` 클래스의 인터페이스를 따라야 합니다. 기본으로 `config.logger`와 동일한 설정이 사용됩니다. `config.assets.logger`를 false로 사용하면 애셋의 로그 출력을 하지 않게 됩니다.

### 제너레이터 설정하기

`config.generators` 메소드를 사용해서 Rails에서 사용되는 제너레이터를 변경할 수 있습니다. 이 메소드는 블럭을 하나 받습니다.

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

블럭에서 사용가능한 메소드의 목록은 아래와 같습니다.

* `assets`는 scaffold를 생성할지 안할지를 지정합니다. 기본값은 `true`입니다.
* `force_plural`는 모델명을 복수형으로 할지 안할지를 지정합니다. 기본값은 `false`입니다.
* `helper`는 헬퍼를 생성할지 안할지를 지정합니다. 기본값은 `true`입니다.
* `integration_tool`는 사용할 통합 툴을 정의합니다. 기본값은 `nil`입니다.
* `javascripts`는 생성 시 JavaScript 파일에 대한 훅을 활성화할지 아닐지를 지정합니다. 이 설정은 `scaffold` 제너레이터의 실행중에 사용됩니다. 기본값은 `true`입니다.
* `javascript_engine`은 애셋 생성시에(coffee 등에서) 사용할 엔진을 지정합니다. 기본값은 `nil`입니다.
* `orm`은 사용할 ORM(Object Relational Mapping)을 지정합니다. 기본값은 `false`이며, 이 경우 Active Record를 사용합니다.
* `resource_controller`는 `rails generate resource`를 실행했을 때에 어떤 제너레이터를 사용하여 컨트롤러를 생성할지 지정합니다. 기본값은 `:controller`입니다.
* `scaffold_controller`는 `resource_controller`와 동일하지 않습니다. `scaffold_controller`는 _scaffold_시에 어떤 제너레이터를 사용하여 컨트롤러를 생성할 지(`rails generate scaffold`를 실행했을 때)를 지정합니다. 기본값은 `:scaffold_controller`입니다.
* `stylesheets`는 제너레이터에서 스타일시트 생성시에 훅을 사용할지 아닐지를 지정합니다. 이 설정은 `scaffold` 제너레이터 실행시에 사용됩니다만, 다른 제너레이터를 실행할 때에도 사용됩니다. 기본값은 `true`입니다.
* `stylesheet_engine`는 애셋 생성시에 사용할, sass같은 스타일시트 엔진을 지정합니다. 기본값은 `:css`입니다.
* `test_framework`는 사용할 테스트용 프레임워크를 지정합니다. 기본값은 `false`이며, 이 경우 Test::Unit이 사용됩니다.
* `template_engine`은 뷰 템플릿 엔진(ERB나 Haml 등)을 지정합니다. 기본값은 `:erb`입니다.

### 미들웨어 설정하기

어떤 Rails 애플리케이션이든 그 뒤에는 몇개의 표준적인 미들웨어가 동작하고 있습니다. development 환경에서는 다음과 같은 순서대로 미들웨어를 사용합니다.

* `ActionDispatch::SSL`는 모든 요청에게 HTTPS 프로토콜을 사용할 것을 강요합니다. 이것은 `config.force_ssl`를 `true`로 설정했을 경우에만 유효합니다. 넘길 옵션 값들은 `config.ssl_options`에서 설정할 수 있습니다.
* `ActionDispatch::Static`는 정적 애셋을 처리합니다. `config.serve_static_assets`를 `false`로 하면 사용하지 않습니다.
* `Rack::Lock`는 애플리케이션을 뮤텍스로 감싸서 1번에 하나의 스레드만 호출되도록 만듭니다. 이 미들웨어는 `config.cache_classes`가 `false`로 설정되어 있을 경우에만 유효합니다.
* `ActiveSupport::Cache::Strategy::LocalCache`는 기본적인 메모리 백업 방식의 캐시로 기능합니다. 이 캐시는 스레드간에 안전하지 않으며, 단일 스레드용의 일시적인 메모리 캐시로서만 동작하도록 설계되었다는 점을 주의해주세요.
* `Rack::Runtime`는 `X-Runtime` 헤더를 설정합니다. 이 헤더에는 요청을 처리하는데 얼마나 시간이 걸렸는지(초)가 포함됩니다.
* `Rails::Rack::Logger`는 요청 처리가 시작되었음을 로그에 알립니다. 요청이 끝나면 모든 로그를 파일에 출력합니다.
* `ActionDispatch::ShowExceptions`는 애플리케이션이 반환하는 모든 예외를 rescue하고, 요청이 로컬이거나, `config.consider_all_requests_local`이 `true`로 설정되어 있는 경우에 적절한 예외 페이지를 출력합니다. `config.action_dispatch.show_exceptions`이 `false`로 설정되어 있으면 언제나 예외를 출력합니다.
* `ActionDispatch::RequestId`는 응답에서 사용할 수 있는 X-Request-Id 헤더를 생성하고, `ActionDispatch::Request#uuid` 메소드를 활성화합니다.
* `ActionDispatch::RemoteIp`는 IP 스푸핑 공격이 있었던 것은 아닌지 확인하고, 요청 해더에서 올바른 `client_ip`를 가져옵니다. 이 설정은 `config.action_dispatch.ip_spoofing_check` 옵션과 `config.action_dispatch.trusted_proxies` 옵션에서 변경 가능합니다.
* `Rack::Sendfile`은 body가 하나의 파일로부터 생성된 응답을 가로채서 서버에 설정되어 있는 X-Sendfile 헤더로 변경하고 전송합니다. 이 동작은 `config.action_dispatch.x_sendfile_header`에서 변경가능합니다.
* `ActionDispatch::Callbacks`은 요청에 응답하기 전에 정의되어 있는 콜백을 실행합니다.
* `ActiveRecord::ConnectionAdapters::ConnectionManagement`는 `rack.test`의 값이 `true`인 경우가 아니라면, 요청마다 살아있는 커넥션을 종료시킵니다.
* `ActiveRecord::QueryCache`는 요청에 따라 생성된 모든 SELECT 쿼리를 캐싱합니다. INSERT 또는 UPDATE가 발생하면 캐시가 비워집니다.
* `ActionDispatch::Cookies`는 요청에 대응하는 cookie를 저장합니다.
* `ActionDispatch::Session::CookieStore`는 세션을 cookie에 저장하는 역할을 담당합니다. `config.action_controller.session_store`의 값이 변경되면 다른 미들웨어를 사용할 수 있습니다. 여기에 넘기는 옵션은 `config.action_controller.session_options`에서 변경할 수 있습니다.
* `ActionDispatch::Flash`는 `flash` 값을 지정합니다. 이는 `config.action_controller.session_store`에 값이 설정되어 있을 때에만 유효합니다.
* `ActionDispatch::ParamsParser`는 요청으로부터 파라미터를 추출하여 `params`에 저장합니다.
* `Rack::MethodOverride`는 `params[:_method]`가 설정되어 있는 경우에 메소드를 재정의합니다. 이는 HTTP에서 PATCH, PUT, DELETE 메소드를 덮어쓰기 위한 미들웨어입니다.
* `ActionDispatch::Head`는 HEAD 요청을 GET 요청으로 변환하여 HEAT 요청이 정상적으로 동작하도록 해줍니다.

`config.middleware.use` 메소드를 사용하면, 위에서 언급한 것 이외의 미들웨어를 추가할 수 있습니다.

```ruby
config.middleware.use Magical::Unicorns
```

이를 통해 `Magical::Unicorns` 미들웨어가 실행 스택의 가장 마지막에 추가됩니다. 특정 미들웨어의 앞에 다른 미들웨어를 추가하고 싶은 경우에는 `insert_before`를 사용하세요.

```ruby
config.middleware.insert_before ActionDispatch::Head, Magical::Unicorns
```

어떤 미들웨어의 뒤에 다른 미들웨어를 추가하고 싶은 경우에는 `insert_after`를 사용하세요.

```ruby
config.middleware.insert_after ActionDispatch::Head, Magical::Unicorns
```

아예 다른 것으로 바꿀수도 있습니다.

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

마찬가지로 미들웨어를 스택에서 제거할 수도 있습니다.

```ruby
config.middleware.delete "Rack::MethodOverride"
```

### i18n 설정하기

아래의 옵션은 모두 `i18n`(internationalization: 국제화) 라이브러리를 위한 것들입니다.

* `config.i18n.available_locales`는 애플리케이션에서 사용할수 있는 로케일을 화이트리스트로 만들어 줍니다. 기본으로 로케일 파일에 있는 로케일 키는 모두 유효하게 됩니다만, 새로운 애플리케이션의 경우, 일반적으로 `:en`만이 포함되어 있습니다.

* `config.i18n.default_locale`는 애플리케이션의 i18n에서 사용할 기본 로케일을 설정합니다. 기본값은 `:en`입니다.

* `config.i18n.enforce_available_locales`이 활성화 되어 있으면 `available_locales` 목록에서 선언되어 있지 않은 로케일을 i18n에 넘길 수 없습니다. 이용할 수 없는 로케일이 있는 경우에는 `i18n::InvalidLocale` 예외가 발생합니다. 기본값은 `true`입니다. 이 옵션은 사용자 입력 로케일이 잘못되었을 경우에 보안 대책이므로, 특별한 이유가 없다면 끄지 말아 주세요.

* `config.i18n.load_path`는 로케일 파일의 검색 경로를 지정합니다. 기본값은 `config/locales/*.{yml,rb}`입니다.

### Active Record 설정하기

`config.active_record`에는 많은 옵션이 포함되어 있습니다.

* `config.active_record.logger`는 Log4r의 인터페이스 또는 Ruby Logger 클래스를 따르는 로거를 인수로 받습니다. 이 로거는 이후 생성되는 모든 새로운 데이터베이스 커넥션에서 사용됩니다. Active Record 모델 클래스 또는 모델 인스턴스에 대해서 `logger` 메소드를 호출하면 이 로거를 받아올 수 있습니다. 로그 출력을 무효화하기 위해서는 `nil`로 설정합니다.

* `config.active_record.primary_key_prefix_type`는 기본키 컬럼의 명명법을 변경할 때에 사용합니다. Rails에서는 기본키 컬럼의 이름의 기본값으로  `id`를 사용합니다(또한 `id`을 사용하고 싶은 경우에는 별도로 설정할 필요가 없습니다). `id` 이외로는 다음의 두가지를 선택할 수 있습니다.
** `:table_name`를 지정하면, 예를 들어, Customer 클래스의 기본키는 `customerid`가 됩니다.
** `:table_name_with_underscore`를 지정하면, 예를 들어, Customer 클래스의 기본키는 `customer_id`가 됩니다.

* `config.active_record.table_name_prefix`는 테이블 이름의 앞에 전역으로 추가할 문자열을 지정할 수 있습니다. 예를 들어, `northwest_`를 지정하면 Customer 클래스는 `northwest_customers` 테이블을 검색합니다. 기본값은 빈 문자열입니다.

* `config.active_record.table_name_suffix`는 테이블 이름의 뒤에 전역으로 추가하고 싶은 문자열을 지정할 수 있습니다. 예를 들면, `_northwest`를 지정하면 Customer는 `customers_northwest` 테이블을 검색합니다. 기본값은 빈 문자열입니다.ㄴ

* `config.active_record.schema_migrations_table_name`는 스키마 마이그레이션 테이블의 이름으로 사용할 문자열을 지정할 수 있습니다.

* `config.active_record.pluralize_table_names`는 Rails가 찾는 데이터베이스 테이블 이름을 단수형으로 할지, 복수형으로 할지를 지정할 수 있습니다. true로 지정하면, Customer 클래스가 사용하는 테이블 이름은 복수형인 `customers`가 됩니다(기본값). false로 설정하면 Customer 클래스가 사용하는 테이블 이름은 단수형인 `customer`가 됩니다.

* `config.active_record.default_timezone`은 데이터베이스로부터 날짜/시각을 가져왔을때 시간대를 `Time.local`(`:local`을 지정했을 경우)와 `Time.utc`(`:utc`를 지정했을 경우)중 어느 것을 쓸지 지정합니다. 기본값은 `:utc`입니다.

* `config.active_record.schema_format`은 데이터베이스 스키마를 파일로 내보낼 때에 사용할 형식을 지정합니다. 기본값은 `:ruby`로 데이터베이스에 의존하지 않고, 마이그레이션에 의존합니다. `:sql`로 지정하면 SQL문으로 내보냅니다만, 이 경우 잠재적으로 데이터베이스에 의존할 가능성이 있습니다.

* `config.active_record.timestamped_migrations`는 마이그레이션 파일의 이름에 시리얼 번호와 타임스탬프 중 어느것을 사용할지를 지정합니다. 기본값은 true로 타임스탬프가 사용됩니다. 개발자가 여러 명인 경우에는 타임스탬프를 추천합니다.

* `config.active_record.lock_optimistically`는 Active Record에서 낙관적 잠금을 사용할지를 지정합니다. 기본값은 true(사용함)입니다.

* `config.active_record.cache_timestamp_format`는 캐시 키에 포함되는 타임스탬프 값의 형식을 지정합니다. 기본값은 `:number`입니다.

* `config.active_record.record_timestamps`는 모델에서 발생하는 `create`나 `update`에 타임스탬프를 추가할지 아닐지를 지정합니다. 기본값은 `true`입니다.

* `config.active_record.partial_writes`는 부분적으로 쓸지 안쓸지('dirty'라고 지정되어 있는 속성만을 갱신할지)를 지정합니다. 데이터베이스에서 부분 읽기/쓰기를 사용하는 경우에는 `config.active_record.lock_optimistically`에서 낙관적 잠금을 활성화할 필요가 있습니다. 이것은 동시에 갱신이 발생했을 경우에 오래된 정보를 사용해서 값을 변경하려 시도할 수 있기 때문입니다. 기본값은 `true`입니다.

* `config.active_record.maintain_test_schema`는 테스트 실행시에 Active Record가 테스트용 데이터베이스 스키마를 `db/schema.rb`(또는 `db/structure.sql`)에 기초해 최신 상태를 사용할지 아닐지를 지정합니다. 기본값은 `true`입니다.

* `config.active_record.dump_schema_after_migration`는 마이그레이션 실행시에 스키마 덤프(`db/schema.rb`또는 `db/structure.sql`)를 할지 안할지를 지정합니다. 이 옵션은 Rails가 생성하는 `config/environments/production.rb`에서는 false로 설정되어 있습니다. 이 옵션이 지정되어 있지 않은 경우에는 기본값으로 true를 사용합니다.

MySQL 어댑터를 사용하면 아래의 옵션이 하나 추가됩니다.

* `ActiveRecord::ConnectionAdapters::MysqlAdapter.emulate_booleans`는 Active Record가 MySQL 데이터베이스의 모든 `tinyint(1)` 형식의 컬럼을 기본으로 boolean으로 취급할지 아닐지를 지정합니다. 기본값은 true입니다.

스키마 덤퍼(Schema Dumper)는 아래의 옵션을 추가합니다.

* `ActiveRecord::SchemaDumper.ignore_tables`는 테이블 이름이 들어있는 배열을 하나 인수로 받습니다. 어떤 스키마 파일에도 _포함하고 싶지 않은_ 테이블 이름이 있는 경우에는 이 배열에 테이블 명을 추가하면 됩니다. 이 설정은 `config.active_record.schema_format == :ruby`가 '아닌' 경우에는 무시됩니다.

### Action Controller 설정하기

`config.action_controller`에는 다수의 설정이 포함되어 있습니다.

* `config.action_controller.asset_host`는 애셋을 저장할 호스트를 지정합니다. 이것은 애셋을 호스팅하는 장소로, 애플리케이션 서버 대신 CDN(Content Delivery Networks)을 사용하는 경우에 편리합니다.

* `config.action_controller.perform_caching`은 애플리케이션에서 캐싱을 사용할지 안할지를 지정합니다. development 모드에서는 false, production 모드에서는 true로 설정합니다.

* `config.action_controller.default_static_extension`은 캐시된 페이지에 부여할 확장자를 지정합니다. 기본값은 `.html`입니다.

* `config.action_controller.default_charset`은 모든 화면 출력에서 사용할 기본 문자셋을 지정합니다. 기본값은 "utf-8"입니다.

* `config.action_controller.logger`는 Log4r 인터페이스나 기본 Ruby Logger 클래스에 따르는 로거를 인수로 받습니다. 이 로거는 Action Controller로부터 정보를 내보내기 위해서 사용합니다. 로그 출력을 하지 않고싶은 경우에는 `nil`로 설정하세요.

* `config.action_controller.request_forgery_protection_token`는 RequestForgery 대책을 위한 파라미터 이름을 지정합니다. `protect_from_forgery`를 호출하면 기본값으로 `:authenticity_token`가 설정됩니다.

* `config.action_controller.allow_forgery_protection`은 CSRF 보호 기능을 켤지를 지정합니다. test 모드의 기본값은 `false`이며, 그 이외에는 `true`로 설정됩니다.

* `config.action_controller.relative_url_root`는 [하위 폴더에 배포하기](configuring.html#하위-폴더에-배포하기-상대url경로-사용하기)를 할 것이라고 Rails에게 알리기 위해서 사용합니다. 기본값은 `ENV['RAILS_RELATIVE_URL_ROOT']`입니다.

* `config.action_controller.permit_all_parameters`는 일괄 할당(Mass Assignment)되는 모든 파라미터를 허가하도록 합니다. 기본값은 `false`입니다.

* `config.action_controller.action_on_unpermitted_parameters`는 명시적으로 허가되지 않은 파라미터를 발견한 경우에 로그로 보고할지, 예외를 발생시킬지를 지정합니다. 이 옵션은 `:log` 또는 `:raise`를 지정하면 활성화됩니다. test 환경과 development 환경에서의 기본값은 `:log`이며, 그 이외의 환경에서는 `false`가 사용됩니다.

* `config.action_controller.always_permitted_parameters`는 파라미터 필터링시에 사용할 화이트 리스트을 지정합니다. 기본값은 `['controller', 'action']`입니다.

### Action Dispatch 설정하기

* `config.action_dispatch.session_store`는 세션 데이터 저장소의 이름을 지정합니다. 기본값은 `:cookie_store`입니다. 그 외에도 `:active_record_store`, `:mem_cache_store`, 또는 커스텀 클래스 이름을 사용할 수 있습니다.

* `config.action_dispatch.default_headers`는 HTTP 헤더에서 사용되는 해시입니다. 이 헤더는 기본으로 모든 응답에 추가됩니다. 이 옵션은 기본값으로 아래와 같은 정보를 가지고 있습니다.

    ```ruby
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff'
    }
    ```

* `config.action_dispatch.tld_length`는 애플리케이션에서 사용하는 탑 레벨 도메인(TLD)의 길이를 지정합니다. 기본값은 `1`입니다.

* `config.action_dispatch.http_auth_salt`는 HTTP Auth의 salt값(역주: 해시의 안전성을 강화하기 위해서 추가되는 임의의 값)을 설정합니다. 기본값은 `'http authentication'`입니다.

* `config.action_dispatch.signed_cookie_salt`는 cookie 서명시에 사용할 salt값을 설정합니다. 기본값은 `'signed cookie'`입니다.

* `config.action_dispatch.encrypted_cookie_salt`는 암호화된 cookie의 salt값을 설정합니다. 기본값은 `'encrypted cookie'`입니다.

* `config.action_dispatch.encrypted_signed_cookie_salt`는 서명 및 암호화가 된 cookie를 위한 salt값을 설정합니다. 기본값은 `'signed encrypted cookie'`입니다.

* `config.action_dispatch.perform_deep_munge`는 파라미터에 대해서 `deep_munge` 메소드를 실행할지 말지를 설정합니다. 자세한 설명은 [보안 가이드](security.html#안전하지-않은-쿼리-생성하기)를 참조해주세요. 기본값은 `true`입니다.

* `config.action_dispatch.rescue_responses`는 각 예외에 대해서 어떤 HTTP 상태 코드를 돌려주어야 하는지를 정의합니다. 에러와 상태 코드를 키/값 쌍으로 가지는 해시를 사용할 수 있으며, 기본값은 다음과 같습니다.

    ```ruby
    config.action_dispatch.rescue_responses = {
      'ActionController::RoutingError'              => :not_found,
      'AbstractController::ActionNotFound'          => :not_found,
      'ActionController::MethodNotAllowed'          => :method_not_allowed,
      'ActionController::UnknownHttpMethod'         => :method_not_allowed,
      'ActionController::NotImplemented'            => :not_implemented,
      'ActionController::UnknownFormat'             => :not_acceptable,
      'ActionController::InvalidAuthenticityToken'  => :unprocessable_entity,
      'ActionController::InvalidCrossOriginRequest' => :unprocessable_entity,
      'ActionDispatch::ParamsParser::ParseError'    => :bad_request,
      'ActionController::BadRequest'                => :bad_request,
      'ActionController::ParameterMissing'          => :bad_request,
      'ActiveRecord::RecordNotFound'                => :not_found,
      'ActiveRecord::StaleObjectError'              => :conflict,
      'ActiveRecord::RecordInvalid'                 => :unprocessable_entity,
      'ActiveRecord::RecordNotSaved'                => :unprocessable_entity
    }
    ```

여기에 명시되지 않은 모든 예외는 500 Internal Server Error로 처리됩니다.

* `ActionDispatch::Callbacks.before`는 요청이 처리되기 전에 실행하고 싶은 코드 블럭을 하나 받습니다.

* `ActionDispatch::Callbacks.to_prepare`는 요청보다 먼저, 그리고 `ActionDispatch::Callbacks.before`보다는 뒤에 실행하고 싶은 코드 블럭을 하나 받습니다. 이 블럭은 `development` 모드에서는 모든 요청에서 실행됩니다만, `production` 모드나, `cache_classes`이 `true`로 설정되어 있는 경우에는 한번만 실행됩니다.

* `ActionDispatch::Callbacks.after`는 요청을 처리한 후에 실행하고 싶은 코드 블럭을 하나 받습니다.

### Action View 설정하기

`config.action_view`에도 몇가지 변경할 수 있는 설정이 있습니다.

* `config.action_view.field_error_proc`는 Active Record에서 발생한 에러를 표시할 때 사용할 HTML 제너레이터를 지정합니다. 기본값은 아래와 같습니다.

    ```ruby
    Proc.new do |html_tag, instance|
      %Q(<div class="field_with_errors">#{html_tag}</div>).html_safe
    end
    ```

* `config.action_view.default_form_builder`는 Rails에서 기본으로 사용할 폼 빌더를 지정합니다. 기본값은 `ActionView::Helpers::FormBuilder`입니다. 폼 빌더를 초기화 작업 이후에 불러오고 싶은 경우(이렇게 하는 것으로 development 환경에서 폼 빌더가 요청이 들어올 때마다 다시 로드됩니다), `String`으로 넘길 수도 있습니다.

* `config.action_view.logger`는 Log4r 또는 기본 Ruby Logger 클래스의 인터페이스를 따르는 로거를 인수로 사용합니다. 이 로거는 Action View로부터 생성된 정보를 로그에 출력할 때에 사용됩니다. 로그 출력을 하고 싶지 않은 경우에는 `nil`을 사용하세요.

* `config.action_view.erb_trim_mode`는 ERB에서 사용할 트림 모드를 지정합니다. 기본은 `'-'`로, `<%= -%>` 또는 `<%= =%>`의 경우 어미에 띄어쓰기 문자를 제거하고 개행합니다. 자세한 설명은 [Erubis 문서](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces)를 참ㅗ하세요.

* `config.action_view.embed_authenticity_token_in_remote_forms`는 폼에서 `:remote => true`를 사용한 경우에 `authenticity_token`의 기본 동작을 정의합니다. 기본값은 `false`이며, 이 경우 리모트 폼에는 `authenticity_token`가 포함되지 않습니다. 이는 폼에서 Fragment 캐시를 사용하고 있는 경우에 편리합니다. 리모트 폼은 `meta` 태그로부터 인증을 받으므로, JavaScript가 동작하지 않는 브라우저를 지원해야하는 것이 아니라면, 폼 안에 삽입할 필요는 없습니다. 그러한 경우에는 `:authenticity_token => true`를 폼 옵션으로 넘기거나, 이 옵션을 `true`로 설정해주세요.

* `config.action_view.prefix_partial_path_with_controller_namespace`는 네임스페이스화된 컨트롤러로부터 출력된 템플릿에 어떤 하위 폴더의 파셜(부분 템플릿)을 탐색할지 말지를 지정합니다. 예를 들어, `Admin::PostsController`라는 컨트롤러가 있고 아래와 같은 템플릿을 랜더링한다고 해봅시다.

    ```erb
    <%= render @post %>
    ```

이 설정의 기본값은 `true`이며, `/admin/posts/_post.erb`에 있는 파셜을 사용하게 됩니다. 만약 `false`로 변경하게 되면 `/posts/_post.erb`를 사용하여 랜더링합니다. 이 동작은 `PostsController` 등에 네임스페이스화되지 않은 컨트롤러를 랜더링할 때와 동일한 것입니다.

* `config.action_view.raise_on_missing_translations`은, i18n에서 번역이 존재하지 않은 경우에 에러를 발생시킬지 아닐지를 지정합니다.

### Action Mailer 설정하기

`config.action_mailer`에는 다양한 옵션이 존재합니다.

* `config.action_mailer.logger`는 Log4r이나 기본 Ruby Logger 클래스의 인터페이스를 따르는 로거를 인수로 받습니다. 이 로거는 Action Mailer가 주는 정보를 로그로 쓸 때 사용됩니다. 로그 출력을 하고 싶지 않은 경우에는 `nil`을 설정해주세요.

* `config.action_mailer.smtp_settings`는 `:smtp` 방식에 대해서 세밀하게 설정할 때 사용할 수 있습니다. 해시를 인수로 받으며, 아래의 옵션을 포함할 수 있습니다.
    * `:address` - 원격 메일 서버를 지정합니다. 기본값은 "localhost"입니다.
    * `:port` - 사용할 메일 서버의 포트가 25번이 아니라면 변경해주세요.
    * `:domain` - HELO 도메인 지정이 필요한 경우에 사용해주세요.
    * `:user_name` - 메일 서버에서 인증이 요구되는 경우, 여기서 사용자 이름을 설정합니다.
    * `:password` - 메일 서버에서 인증이 요구되는 경우, 여기서 비밀번호를 설정합니다.
    * `:authentication` - 메일 서버에서 인증이 요구되는 경우, 여기서 그 종류를 지정합니다. `:plain`, `:login`, `:cram_md5` 중 하나를 사용할 수 있습니다.

* `config.action_mailer.sendmail_settings`를 통해 `:sendmail` 방식에 대해서 세밀하게 설정을 할 수 있습니다. 해시를 인수로 받으며, 아래의 옵션을 포함할 수 있습니다.
    * `:location` - sendmail 실행 파일의 위치. 기본값은 `/usr/sbin/sendmail`입니다.
    * `:arguments` - 커맨드라인에 넘겨줄 인수. 기본값은 `-i -t`입니다.

* `config.action_mailer.raise_delivery_errors`는 메일 전송에 실패했을 경우에 에러를 발생시킬지를 지정합니다. 기본값은 `true`입니다.

* `config.action_mailer.delivery_method`는 전송 방법을 지정합니다. 기본값은 `:smtp`입니다. 자세한 설명은 [Action Mailer 가이드](action_mailer_basics.html#Action-Mailer를-설정하기)를 참조해주세요.

* `config.action_mailer.perform_deliveries`는 메일을 실제로 전송할지 말지를 지정합니다. 기본값은 `true`입니다. 테스트를 하는 경우, 실제 전송을 막고 싶을 때에 유용합니다.

* `config.action_mailer.default_options`은 Action Mailer 옵션의 기본값을 지정합니다. 모든 메일러의 `from`나 `reply_to`를 같게 설정하는 경우에 사용해주세요. 기본값은 다음과 같습니다.

    ```ruby
    mime_version:  "1.0",
    charset:       "UTF-8",
    content_type: "text/plain",
    parts_order:  ["text/plain", "text/enriched", "text/html"]
    ```

  해시를 하나 지정해서 옵션을 추가할 수도 있습니다.

    ```ruby
    config.action_mailer.default_options = {
      from: "noreply@example.com"
    }
    ```

* `config.action_mailer.observers`는 메일을 전송했을 경우에 통지를 받을 옵저버를 지정합니다.

    ```ruby
    config.action_mailer.observers = ["MailObserver"]
    ```

* `config.action_mailer.interceptors`로 메일을 전송하기 전에 호출될 인터셉터를 등록합니다.

    ```ruby
    config.action_mailer.interceptors = ["MailInterceptor"]
    ```

* `config.action_mailer.preview_path`는 메일러의 미리보기들의 위치를 지정합니다.

    ```ruby
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
    ```

* `config.action_mailer.show_previews`는 메일러의 미리보기를 활성화하거나 끌 수 있습니다. development 환경에서 기본값은 `true`입니다.

    ```ruby
    config.action_mailer.show_previews = false
    ```

### Active Support 설정하기

Active Support에도 몇가지 설정이 있습니다.

* `config.active_support.bare`는 Rails를 실행할 때에 `active_support/all`를 불러올지 말지를 지정합니다. 기본값은 `nil`이며, 이 경우 `active_support/all`를 읽어옵니다.

* `config.active_support.escape_html_entities_in_json`는 JSON 직렬화에 포함되는 HTML 코드를 이스케이프할지를 지정합니다. 기본값은 `false`입니다.

* `config.active_support.use_standard_json_time_format`는 ISO 8601 형식에 따른 날짜의 직렬화를 처리할지 말지를 지정합니다. 기본값은 `true`입니다.

* `config.active_support.time_precision`는 JSON 인코딩된 시간값의 정밀도를 지정합니다. 기본값은 `3`입니다.

* `ActiveSupport::Logger.silencer`를 `false`로 지정하면, 블럭 내에서 로그 출력을 제어하는 기능이 비활성화됩니다. 기본값은 `true`입니다.

* `ActiveSupport::Cache::Store.logger`는 캐시 저장소 조작에서 사용할 로거를 지정합니다.

* `ActiveSupport::Deprecation.behavior`는 `config.active_support.deprecation`에 대응하는 또 하나의 Setter이며, Rails의 Deprecated 경고 메시지를 어떻게 보여줄지 설정합니다.

* `ActiveSupport::Deprecation.silence`는 블럭을 하나 받으며, 모든 Deprecated 메시지를 무시합니다.

* `ActiveSupport::Deprecation.silenced`는 Deprecated 메시지를 표시할지 말지를 지정합니다.


### 데이터베이스 설정하기

거의 대부분의 Rails 애플리케이션은 어떤 형태로든 데이터베이스에 접속하게 됩니다. 데이터베이스에 대한 접속 정보는 환경변수 `ENV['DATABASE_URL']`를 설정하거나, `config/database.yml`라는 파일을 통해서 설정합니다.

`config/database.yml` 파일을 사용하여 데이터베이스 접속에 필요한 정보를 지정할 수 있습니다.

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

이 설정을 사용하면 `postgresql`을 사용하여 `blog_development`라는 이름의 데이터베이스에 접속합니다. 같은 접속정보를 URL로 만들어 아래와 같은 환경변수로 저장할 수도 있습니다.

```ruby
> puts ENV['DATABASE_URL']
postgresql://localhost/blog_development?pool=5
```

`config/database.yml` 파일은 Rails가 기본으로 실행할 수 있는 서로 다른 3개의 환경에 대해서 기술하고 있습니다.

* `development` 환경은 로컬의 개발환경에서 애플리케이션과 수동으로 작업을 진행할 때에 사용합니다.
* `test` 환경은 자동화된 테스트를 실행하기 위해서 사용합니다.
* `production` 환경은 애플리케이션을 전세계에 공개하는 실제 환경에서 사용합니다.ㄴ

필요하다면 `config/database.yml`에 URL을 직접 지정할 수도 있습니다.

```
development:
  url: postgresql://localhost/blog_development?pool=5
```

`config/database.yml` 파일에는 ERB 태그 `<%= %>`를 사용할 수 있습니다. 태그에 포함된 것은 모두 Ruby 코드로서 평가됩니다. 이 태그를 사용해서 환경변수로부터 접속 정보를 가져오거나, 접속 정보를 생성할때에 필요한 작업들을 수행할 수 있습니다.


TIP: 데이터베이스의 접속 설정을 손으로 직접 갱신할 필요는 없습니다. 애플리케이션의 제네레이터의 옵션을 확인해보면 `--database`라는 옵션이 있습니다. 이 옵션에서는 관계형 데이터베이스에서 가장 자주 사용되는 어댑터 목록으로부터 값을 선택할 수 있습니다. 나아가, `cd .. && rails new blog --database=mysql`와 같이, 제네레이터를 반복해서 실행할 수도 있습니다. `config/database.yml` 파일을 덮어쓰게 되면, 애플리케이션의 설정은 SQLite 용으로부터 MySQL 용으로 변경됩니다. 자주 사용되는 데이터베이스 접속 방법의 예제에 대해서는 이후에 설명합니다.


### 접속 설정

환경변수를 사용해서 데이터베이스 접속 설정을 하는 방법은 2가지가 있으므로, 이 두가지가 어떤식으로 상효작용하는지를 이해해두는 것도 중요합니다.

`config/database.yml` 파일이 비어있고, 환경변수 `ENV['DATABASE_URL']`가 설정되어 있는 경우, 데이터베이스에 접속할 때에는 환경변수를 사용합니다.

```
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

`config/database.yml` 파일이 있고, 환경변수 `ENV['DATABASE_URL']`가 설정되어 있지 않은 경우에는 `config/database.yml` 파일을 사용해서 데이터베이스에 접속하게 됩니다.

```
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

`config/database.yml` 파일과 환경변수 `ENV['DATABASE_URL']`가 모두 존재하는 경우, 양쪽의 설정을 병합해서 사용합니다. 아래의 예제를 참조해주세요.

제공된 접속 정보가 중복되어 있을 경우, 환경변수가 우선됩니다.

```
$ cat config/database.yml
development:
  adapter: sqlite3
  database: NOT_my_database
  host: localhost

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ rails runner 'puts ActiveRecord::Base.configurations'
{"development"=>{"adapter"=>"postgresql", "host"=>"localhost", "database"=>"my_database"}}
```

이 실행결과에서 사용되는 접속 정보는 `ENV['DATABASE_URL']`의 내용과 일치합니다.

제공된 복수의 정보가 중복되지 않은 경우에도 언제나 환경변수 쪽의 설정이 우선됩니다.

```
$ cat config/database.yml
development:
  adapter: sqlite3
  pool: 5

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ rails runner 'puts ActiveRecord::Base.configurations'
{"development"=>{"adapter"=>"postgresql", "host"=>"localhost", "database"=>"my_database", "pool"=>5}}
```

pool은 `ENV['DATABASE_URL']`에서 제공되는 정보에 포함되지 않으므로, 병합되어 있습니다. adpter는 중복되어 있으므로 `ENV['DATABASE_URL']`의 접속 정보를 우선합니다.

`ENV['DATABASE_URL']`의 정보보다도 database.yml의 정보를 우선해서 사용하는 유일한 방법은 database.yml에서 `"url"` 서브키를 사용해서 명시적으로 URL 접속 정보를 지정하는 것입니다.

```
$ cat config/database.yml
development:
  url: sqlite3:NOT_my_database

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ rails runner 'puts ActiveRecord::Base.configurations'
{"development"=>{"adapter"=>"sqlite3", "database"=>"NOT_my_database"}}
```

이번에는 `ENV['DATABASE_URL']`의 접속 정보가 무시되었습니다. 어댑터와 데이터베이스 이름이 다른 것을 확인할 수 있습니다.

`config/database.yml`에는 ERB 태그도 사용할 수 있으므로 database.yml에서 명시적으로 `ENV['DATABASE_URL']`를 사용하는 것이 가장 좋은 방법입니다. 이것은 특별히 production 환경에서 유용합니다. 데이터베이스 접속에 필요한 비밀번호 같은 비밀 정보를 버전 관리 시스템에 직접 저장하는것은 피하는 것이 좋기 때문입니다.

```
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

이상의 설명으로 동작이 명확해졌습니다. 접속 정보는 절대 database.ytml에 직접 작성하지 말고, 항상 `ENV['DATABASE_URL']`에 저장한 값을 이용해주세요.

#### SQLite3 데이터베이스 설정하기

Rails에는 [SQLite3](http://www.sqlite.org)의 지원 기능이 내장되어 있습니다. SQLite는 경량이며 전용 서버를 필요로 하지 않는 데이터베이스 애플리케이션입니다. SQLite는 개발용, 테스트용으로는 문제없이 사용할 수 있습니다만, 실제 환경에서는 문제가 될 가능성이 있습니다. Rails에서는 새 프로젝트를 생성할 때 기본값으로 SQLite를 지정하고 있습니다만, 이것은 언제든지 변경할 수 있습니다.

다음은 기본 접속 설정 파일(`config/database.yml`)에 포함되는 개발 환경용 접속 설정입니다.

```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

NOTE: Railsdp서 데이터 저장용으로 SQLite3 데이터베이스를 채용하고 있는 이유는 설정 없이도 쉽게 사용할 수 있기 때문입니다. Rails에서는 SQLite 대신에 MySQL이나 PostgrreSQL 등을 사용할 수도 있습니다. 또한, 데이터베이스 접속용으로 많은 플러그인이 존재합니다. production 환경에서 어떤 데이터베이스를 사용하는 경우, 그를 위한 어뎁터는 대부분 금방 찾을 수 있습니다.

#### MySQL 데이터베이스 설정하기

Rails同梱のSQLite3に代えてMySQLを採用した場合、`config/database.yml`の記述方法を少し変更します。developmentセクションの記述は以下のようになります。

```yaml
development:
  adapter: mysql2
  encoding: utf8
  database: blog_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
```

開発環境のコンピュータにMySQLがインストールされており、ユーザー名root、パスワードなしで接続できるのであれば、上の設定で接続できるようになるはずです。接続できない場合は、`development`セクションのユーザー名またはパスワードを適切なものに変更してください。

#### PostgreSQL 데이터베이스 설정하기

PostgreSQL을 사용하는 경우에는 `config/database.yml`를 다음과 같이 작성하세요.

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
```

PostgreSQL의 Prepared Statements는 기본으로 켜져 있는 상태입니다. `prepared_statements`를 `false`로 설정하면 이 기능을 끌 수 있습니다.

```yaml
production:
  adapter: postgresql
  prepared_statements: false
```

Prepared Statements를 켜면 Active Record는 기본으로 데이터베이스를 접속할 때마다 최대 `1000` 개의 Prepared Statements를 생성합니다. 이 숫자를 변경하고 싶은 경우에는 `statement_limit`를 설정하면 됩니다.

```
production:
  adapter: postgresql
  statement_limit: 200
```

Prepared Statements를 더 많이 사용할 수록 데이터베이스에서 필요로 하는 메모리 크기도 커집니다. PostgreSQL 데이터베이스의 메모리 사용량이 사용 제한에 도달한 경우에는 `statement_limit`를 더 작은 값으로 설정하거나 Prepared Statements를 비활성화해주세요.

#### JRuby 플랫폼에서 SQLite3 데이터베이스 설정하기

JRuby 환경에서 SQLite3을 사용하는 경우 `config/database.yml`의 작성방법이 조금 다릅니다. development는 다음과 같이 작성합니다.

```yaml
development:
  adapter: jdbcsqlite3
  database: db/development.sqlite3
```

#### JRuby 플랫폼에서 MySQL 데이터베이스 설정하기

JRuby 환경에서 MySQL을 사용하는 경우 `config/database.yml`의 작성방법이 조금 다릅니다. development는 다음과 같이 작성합니다.

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### JRuby 플랫폼에서 PostgreSQL 데이터베이스 설정하기

JRuby 환경에서 PostgreSQL을 사용하는 경우 `config/database.yml`의 작성방법이 조금 다릅니다. development는 다음과 같이 작성합니다.

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

`development`에서 사용자 이름과 비밀번호는 적절한 값으로 변경해주세요.

### Rails 환경 생성하기

Rails에 기본으로 포함되어 있는 환경은 "development", "test", "production"의 3개입니다. 일반적으로 이 3개로 충분할 것입니다만, 상황에 따라서는 더 추가하고 싶은 경우가 있을 것입니다.

예를 들어, production 환경과 동일하게 맞춘 서버가 있고, 이 서버를 테스트 목적으로만 사용하고 싶은 경우를 생각해봅니다. 이러한 서버는 보통 '스테이징 서버(staging server)'라고 불립니다. "staging" 환경을 서버에 추가하고 싶다면, `config/environments/staging.rb`라는 파일을 생성하기만 하면 됩니다. 그 경우에는 `config/environments`에 있는 기존 파일을 활용해서 필요한 부분만을 변경하여주세요.

이렇게 추가된 환경은 기본으로 제공되는 다른 3개의 환경과 동일한 방식으로 사용할 수 있습니다. `rails server -e staging`를 실행하면 스테이징 환경에서 서버를 실행할 수 있으며, `rails console staging`이나 `Rails.env.staging?` 같은 메소드도 사용할 수 있게 됩니다.


### 하위 폴더에 배포하기(상대url경로 사용하기)

Rails 애플리케이션은 루트 폴더(`/` 등)에서 실행하는 것을 전제로 합니다. 이 절에서는 애플리케이션을 하위 폴더에서 실행하는 방법에 대해서 설명합니다.

여기에서는 애플리케이션을 "/app1" 폴더에 배포하고 싶다고 가정합니다. 이를 위해서는 Rails가 적절한 라우팅을 생성할 수 있도록 이 위치를 알려줄 필요가 있습니다.

```ruby
config.relative_url_root = "/app1"
```

또는 `RAILS_RELATIVE_URL_ROOT` 환경변수를 사용할 수도 있습니다.

이를 통해 링크가 생성 될 때에 "/app1"를 추가합니다.

#### Passenger 사용하기

Passenger 를 사용하면 애플리케이션을 하위 폴더에 간단하게 실행할 수 있습니다. 자세한 설정 방법에 대헤서는 [passenger 매뉴얼](http://www.modrails.com/documentation/Users%20guide%20Apache.html#deploying_rails_to_sub_uri)을 참조해주세요.

#### 리버스 프록시를 사용하기

리버스 프록시를 통해서 애플리케이션을 배포하는 것은 그렇지 않은 전통적인 방식보다 확실한 장점이 있습니다. 이 방식은 컴포넌트들을 레이어 형태로 제공하여 애플리케이션에 대한 좀 더 많은 권한을 제공합니다.

많은 모던 웹 서버들은 애플리케이션 서버나 캐싱 서버같은 서드파티 요소들을 관리하는 프록시 서버처럼 동작할 수 있습니다.

그 중 리버스 프록시 뒤에서 사용할 수 있는 애플리케이션 서버로는 [Unicorn](http://unicorn.bogomips.org/)이 있습니다.

이 경우, 우선 프록시 서버(NGINX, Apache, etc)를 사용하여 들어온 접속을 애플리케이션 서버(Unicorn)으로 연결시켜줄 필요가 있습니다. 기본적으로 Unicorn은 8080번 포트에서 들어오는 TCP 연결을 기다립니다만, 이 포트는 변경할 수 있으며, 또는 그 대신 소켓을 사용할 수도 있습니다.

더 많은 정보는 [Unicorn readme](http://unicorn.bogomips.org/README.html)에서 볼 수 있으며, 거기에 담긴 [철학](http://unicorn.bogomips.org/PHILOSOPHY.html)을 이해할 수도 있습니다.

일단 애플리케이션 서버 설정을 마치고 나면, 그 후로는 프록시 요청을 해야합니다. 예를 들자면, NGINX 설정을 다음과 같이 구성할 수 있습니다.

```
upstream application_server {
  server 0.0.0.0:8080
}
 
server {
  listen 80;
  server_name localhost;
 
  root /root/path/to/your_app/public;
 
  try_files $uri/index.html $uri.html @app;
 
  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://application_server;
  }
 
  # some other configuration
}
```

반드시 최신 정보는 NGINX 문서를 참조하여주세요.

#### 하위 폴더에 배포하는 경우의 검토사항

실제 환경에서 Rails를 하위 폴더에 배호가게 되면 Rails의 많은 부분에 영향이 발생합니다.

* 개발 환경
* 테스트 환경
* 정적 애셋 제공하기
* 애셋 파이프라인

Rails 환경 설정
--------------------------

일부 설정에 대해서는 Rails 외부로부터 환경 변수를 넣어줄 수도 있습니다. 아래의 환경변수는 Rails의 많은 부분에서 사용됩니다.

* `ENV["RAILS_ENV"]`는 Rails가 실행되는 환경(production, development, teest 등)을 정의합니다.

* `ENV["RAILS_RELATIVE_URL_ROOT"]`는 [애플리케이션을 하위 폴더에 배포할](configuring.html#하위-폴더에-배포하기-상대url경로-사용하기) 때에 라우팅 시스템이 URL을 인식할 수 있게 만들 때 사용합니다.

* `ENV["RAILS_CACHE_ID"]`와 `ENV["RAILS_APP_VERSION"]`는 Rails의 캐시를 사용하는 코드에서 확장 캐시를 생성할 때에 사용됩니다. 이를 통해 하나의 애플리케이션에서 복수의 독립된 캐시를 다룰 수 있게 됩니다.

Initializer 파일 사용하기
-----------------------

Rails는 프레임워크를 불러오는 것과 모든 gem 불러오기 작업이 종료된 이후에 initializer를 불러옵니다. initializer란 애플리케이션의 `config/initializers` 폴더에 저장되어 있는 Ruby 파일을 의미합니다. 예를 들자면 각 컴포넌트들의 설정 정보를 initializer에 저장하고, 이를 프레임워크와 gem이 모두 준비된 이후에 적용할 수 있습니다.

NOTE: initializer를 보관하는 위치에 하위 폴더를 생성하여 initializer를 정리해도 좋습니다. Rails는 initializer를 위해서 사용하는 폴더를 재귀적으로 탐색하여 실행해줍니다.

TIP: initializer의 실행 순서를 지정하고싶은 경우에는 initializer 파일 이름을 사용해서 실행 순서를 제어할 수 있습니다. 각 폴더의 initializer는 알파벳 순서로 호출됩니다. 예를 들어 `01_critical.rb`를 읽고, `02_normal.rb`를 다음으로 불러옵니다.

초기화 이벤트
---------------------

Rails에는 훅 가능한 초기화 이벤트가 5개 있습니다. 아래에 소개된 그 이벤트들은 실제로 실행되는 순서로 설명되어 있습니다.

* `before_configuration`: 이것은 `Rails::Application`으로부터 애플리케이션 상수를 상속한 뒤에 실행됩니다. `config` 호출은 이 이벤트보다 먼저 실행되므로 주의해주세요.

* `before_initialize`: 이것은 `:bootstrap_hook` initializer를 포함하는 초기화 프로세스 직전에 실행됩니다. `:bootstrap_hook`는 Rails 애플리케이션의 초기화 프로세스 중 비교적 먼저 실행되는 쪽입니다.

* `to_prepare`: 이것은 Railties 용의 initializer와 애플리케이션 자신의 initializer가 모두 실행 된 이후, 그리고 일괄 로딩(eager loading)과 미들웨어 스택이 구성되기 전에 실행됩니다(역주: Railties는 Rails의 코어 라이브러리 중 하나로 Rails Unilities라는 의미입니다). 중요한 점은 `development` 모드에서는 서버에 요청을 할 때마다 실행됩니다만, `production` 모드와 `test` 모드에서는 애플리케이션이 기동할 때에만 실행된다는 점입니다.

* `before_eager_load`: 일괄 로딩이 발생하기 전에 실행됩니다. `production` 환경에서는 동작하지만, `development` 환경에서는 그렇지 않습니다.

* `after_initialize`: 애플리케이션의 초기화 작업이 종료되고, `config/initializers`에 있는 initializer가 실행된 이후에 실행됩니다.

이런 이벤트들을 정의하기 위해서는 `Rails::Application`, `Rails::Railtie`, 또는 `Rails::Engine`의 자식 클래스에 블럭 형태로 작성하면 됩니다.

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # initialization code goes here
    end
  end
end
```

또는 `Rails.application` 객체에 대해서 `config` 메소드를 실행해서 선언할 수도 있습니다.

```ruby
Rails.application.config.before_initialize do
  # initialization code goes here
end
```

WARNING: 애플리케이션의 일부, 특히 라우팅에서는 `after_initialize` 블럭이 호출된 시점에서는 설정이 완료되지 않은 상태입니다.

### `Rails::Railtie#initializer`

Rails에서는 `Rails::Railtie`에 포함되는 `initializer` 메소드를 사용하여 모든 것을 정의하고, 기동시에 실행되는 몇몇 initializer가 있습니다. 아래에서는 Action Controller의 `set_helpers_path` initializer에서 가져온 예시입니다.

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

이 `initializer` 메소드는 3개의 인수를 받습니다. 첫번째로는 initializer의 이름, 두번째로는 옵션 해시(위 예시에서는 쓰고 있지 않습니다), 세번째로는 블럭입니다. 옵션 해시에 포함되는 `:before` 키를 사용해서, 새로운 initializer보다 먼저 실행하고 싶은 initializer를 지정할 수 있습니다. 마찬가지로 `:after` 키를 사용하여 새로운 initializer보다 _나중에_ 실행하고 싶은 initializer를 지정할 수 있습니다.

`initializer` 메소드를 사용해서 정의된 initializer는 정의된 순서대로 실행됩니다. 단 `:before`나 `:after`를 사용한 경우를 제외합니다.

WARNING: initializer가 실행되는 순서는 논리적으로 모순이 발생하지 않는 경우를 제외하고, before나 after를 사용해서 어떤 식으로든 변경할 수 있습니다. 예를 들자면 "one"으로부터 "four"까지 4개의 initializer가 순서대로 정의되어 있다고 가정합니다. 여기에서 "four"를 "four"보다 _먼저_ 그리고 "three"보다 _이후에_ 실행하도록 하면, 모순이 발생하여 initializer의 실행 순서를 결정할 수 없게 됩니다.

`initializer` 메소드의 블록이 넘겨받는 인수는 애플리케이션 자체의 인스턴스입니다. 위 예제에서도 볼 수 있듯이, `config` 메소드를 사용하여 애플리케이션 설정에 접근할 수 있습니다.

사실 `Rails::Application`은 `Rails::Railtie`를 간접적으로 상속하고 있습니다. 그 덕분에 `config/application.rb`에서 `initializer` 메소드를 사용하여 애플리케이션의 initializer를 정의할 수 있습니다.

### Initializer

다음은 Rails에서 있는 모든 initializer를 정의된 순서대로 작성한 목록입니다.

* `load_environment_hook` 는 플레이스 홀더로서 `:load_environment_config`를 정의하고 initializer보다도 이전에 실행할 경우에 사용합니다.

* `load_active_support`는 Active Support의 기본 부분을 설정하는 `active_support/dependencies`를 요구합니다. 기본인 `config.active_support.bare`를 신용할 수 없는 경우에는 `active_support/all`도 필요합니다.

* `initialize_logger`는 이보다 앞에서 `Rails.logger`를 정의하고 초기화하지 않은 경우, 애플리케이션의 로거(`ActiveSupport::Logger` 객체)를 초기화하고, `Rails.logger`를 사용할 수 있게 만들어 줍니다.

* `initialize_cache`는 `Rails.cache`가 설정되어 있지 않은 경우, `config.cache_store`의 값을 참조하여 캐시를 초기화한뒤, 그 결과를 `Rails.cache`로 저장합니다. 그 객체가 `middleware` 메소드에 응답하는 경우, 그 미들웨어를 미들웨어 스택의 `Rack::Runtime` 앞에 삽입됩니다.

* `set_clear_dependencies_hook`은 `active_record.set_dispatch_hooks`에 대한 훅을 제공합니다. 이 initializer보다 먼저 실행됩니다. 이 initializer는 `cache_classes`가 `false`인 경우에만 실행됩니다. 그리고 이 initializer는 `ActionDispatch::Callbacks.after`를 사용하여 객체 공간으로부터 요청에서 참조된 상수를 제거하여 이후 요청에서 다시 로드하도록 만듭니다.

* `initialize_dependency_mechanism`는 `config.cache_classes`이 true인 경우 `ActiveSupport::Dependencies.mechanism`에 의존성을 (`load`가 아닌) `require`로 설정합니다.

* `bootstrap_hook`은 모든 정의된 `before_initialize` 블럭을 실행합니다.

* `i18n.callbacks`는 development 환경인 경우 `to_prepare` 콜백을 설정합니다. 이 콜백은 마지막에 요청이 발생한 뒤에 로케일이 변경되면 `I18n.reload!`를 호출합니다. production 모드인 경우, 이 콜백은 첫번째 요청때에만 실행됩니다.

* `active_support.deprecation_behavior`는 환경에 대한 Deprecated 리포팅 출력을 어떻게 할 지 설정합니다. development 환경에서는 기본으로 `:log`,  환경에서는 `:notify`, test 환경에서는 `:stderr`가 사용됩니다. `config.active_support.deprecation`에 값이 설정되어 있지 않은 경우, 이 initializer는 현재 환경에 대응하는 `config/environments` 파일의 값을 설정하도록 메시지를 출력합니다. 값의 배열을 설정할 수도 있습니다.

* `active_support.initialize_time_zone`은 `config.time_zone`의 설정에 기반하여 애플리케이션의 기본 시간대를 설정합니다. 기본값은 "UTC"입니다.

* `active_support.initialize_beginning_of_week`는 `config.beginning_of_week`의 값을 기반으로 애플리케이션의 기본 주의 시작요일을 설정합니다. 기본값은 `:monday`입니다.

* `action_dispatch.configure`는 `ActionDispatch::Http::URL.tld_length`를 `config.action_dispatch.tld_length`의 값(탑 레벨 도메인의 길이)으로 설정합니다.

* `action_view.set_configs`는 `config.action_view`의 설정값을 `ActionView::Base`에 메소드 이름을 전송하여 값을 넘겨서 Action View를 설정합니다.

* `action_controller.logger`는 `Rails.logger`에 대한 설정이 없는 경우에 `ActionController::Base.logger`를 설정합니다.

* `action_controller.initialize_framework_caches`는 `Rails.cache`에 대한 설정이 없는 경우에 `ActionController::Base.cache_store`를 설정합니다.

* `action_controller.set_configs`는 `config.action_controller`의 설정값을 `ActionController::Base`에 메소드 이름을 전송하여 값을 넘겨서 Action Controller를 설정합니다.

* `action_controller.compile_config_methods`는 지정한 설정용 메소드를 초기화하고, 좀 더 빠르게 접근할 수 있게 해줍니다.

* `active_record.initialize_timezone`는 `ActiveRecord::Base.time_zone_aware_attributes`를 true로 설정하고 `ActiveRecord::Base.default_timezone`을 UTC로 설정합니다. 속성을 데이터베이스로부터 가져온 경우, 그 속성은 `Time.zone`에서 지정한 시간대로 변환됩니다.

* `active_record.logger`가 설정되어 있지 않은 경우에 `ActiveRecord::Base.logger`를 `Rails.logger`를 설정합니다.

* `active_record.set_configs`는 `config.active_record`의 설정값을 `ActiveRecord::Base`에 메소드 이름을 전송하여 값을 넘겨서 Action Record를 설정합니다.

* `active_record.initialize_database`는 데이터베이스 설정을 `config/database.yml`(기본값을 불러오는 곳)으로부터 불러오며, 현재의 환경에서의 접속을 확립합니다.

* `active_record.log_runtime`는 요청에서 Active Record를 호출하는 시간을 로거에 전달하는 역할을 하는 `ActiveRecord::Railties::ControllerRuntime`를 포함합니다.

* `active_record.set_dispatch_hooks`는 `config.cache_classes`가 `false`로 설정되어 있는 경우, 다시 읽어올 수 있는 데이터베이스 접속을 모두 초기화시킵니다.

* `action_mailer.logger`는 설정이 되어 있지 않은 경우에 `ActionMailer::Base.logger`를 `Rails.logger`로 설정합니다.

* `action_mailer.set_configs`는 `config.action_mailer`의 설정값을 `ActiveMailer::Base`에 메소드 이름을 전송하여 값을 넘겨서 Action Mailer를 설정합니다. 설정을 사용해서 Action Mailer를 설정합니다.

* `action_mailer.compile_config_methods`는 지정된 설정용 메소드를 초기화하고, 좀 더 빠르게 사용할 수 있도록 만듭니다.

* `set_load_path`는 `bootstrap_hook`보다 먼저 실행됩니다. `vendor`, `lib`, `app` 밑에 있는 모든 폴더, `config.load_paths`에 지정된 모든 경로가 `$LOAD_PATH`에 추가됩니다.

* `set_autoload_paths`는 `bootstrap_hook`보다 먼저 실행됩니다. `app` 밑에 있는 모든 하위 폴더와 `config.autoload_paths`에서 지정한 모든 경로가 `ActiveSupport::Dependencies.autoload_paths`에 추가됩니다.

* `add_routing_paths`는 기본으로 모든 `config/routes.rb` 파일(애플리케이션, railties, 엔진 모두에서)을 읽어오고, 애플리케이션의 라우팅을 설정합니다.

* `add_locales`는 `config/locales`에 있는 파일을 `I18n.load_path`에 추가하고 그 경로에 지정된 장소에 있는 사전에 접근할 수 있게 합니다. 이 `config/locales`는 애플리케이션 뿐만이 아니라, railties나 엔진에 있는 것도 포함합니다.

* `add_view_paths`는 애플리케이션이나 railties나 엔진에 있는 `app/views`에 대한 경로를 뷰 파일의 참조 경로에 추가합니다.

* `load_environment_config`는 현재 환경의 `config/environments`를 읽어옵니다.

* `append_asset_paths` 애플리케이션과 거기에 추가되어 있는 railties에 포함되어 있는 애셋 경로를 찾고, `config.static_asset_paths`에서 지정되어 있는 폴더를 감시합니다.

* `prepend_helpers_path`는 애플리케이션이나 railties, 엔진에 포함되는 `app/helpers` 폴더를 헬퍼의 참조 경로에 추가합니다.

* `load_config_initializers` 애플리케이션이나 railties, 엔진에 포함되는 `config/initializers`에 있는 Ruby 파일을 모두 읽어옵니다. 이 폴더에 포함되어 있는 파일은, 프레임워크 로딩이 모두 끝난 이후에 처리하고 싶은 설정입니다.

* `engines_blank_point`는 엔진 로딩이 종료된 이후에 처리하고 싶은 작업이 있는 경우에 사용할 수 있는 훅을 제공합니다. 초기화 처리가 여기까지 진행되면 railties나 엔진의 initializer는 이미 처리된 이후입니다.

* `add_generator_templates`는 애플리케이션이나 railties나 엔진에 있는 `lib/templates` 폴더에 존재하는 제너레이터 용 템플릿을 찾고, 그것들을 `config.generators.templates`에 추가합니다. 이 설정을 통해 모든 제너레이터가 템플릿을 참조할 수 있게 됩니다.

* `ensure_autoload_once_paths_as_subset`는 `config.autoload_once_paths`에 `config.autoload_paths` 이외의 경로가 포함되지 않도록 처리합니다. 그 이외의 경로가 포함되어 있는 경우에는 예외를 발생시킵니다.

* `add_to_prepare_blocks`는 애플리케이션이나 railties, 엔진의 모든 `config.to_prepare`의 블록이 Action Dispatch의 `to_prepare`에 추가됩니다. 이는 development 모드에서는 요청마다 실행되며, production 모드에서는 처음의 요청에만 실행됩니다.

* `add_builtin_route`는 애플리케이션이 development 환경에서 동작하고 있는 경우 `rails/info/properties`에 대한 라우팅을 애플리케이션의 라우팅에 추가합니다. 이 라우팅에 접근하면, 기본 Rails의 애플리케이션에서 `public/index.html`에 나타나는 것과 동일한 상세 정보(Rails나 Ruby의 버전 등)가 표시됩니다.

* `build_middleware_stack`는 애플리케이션의 미들웨어 스택을 구성하고, 요청에 대한 Rack 환경 객체를 인수로 받는 `call` 메소드를 가지는 객체를 반환합니다.

* `eager_load!`는 `config.eager_load`가 true인 경우 `config.before_eager_load` 훅을 실행하고, 이어서 `eager_load!`를 호출하여 모든 `config.eager_load_namespaces`가 불러옵니다.

* `finisher_hook`은 애플리케이션 초기화 프로세스가 완료된 이후에 실행되는 훅을 제공하며, 애플리케이션이나 railties, 엔진의 `config.after_initialize` 블록을 모두 실행합니다.

* `set_routes_reloader`는 `ActionDispatch::Callbacks.to_prepare`을 사용하여 라우팅을 다시 읽어오기 위한 Action Dispatch를 구성합니다.

* `disable_dependency_loading`는 `config.eager_load`가 true인 경우에 자동 의존성 로딩(automatic dependency loading)이 무효화됩니다.

데이터베이스 커넥션 풀
----------------

Active Record의 데이터베이스 접속은 `ActiveRecord::ConnectionAdapters::ConnectionPool`를 통해 관리됩니다. 이것은 접속수에 대한이 있는 데이터베이스에 접속할 경우에 스레드 숫자와 접속 풀의 숫자를 동기화하기 위한 방법입니다. 최대 접속 가능 숫자는 기본으로 5로 설정되어 있습니다만, `database.yml`에서 변경할 수 있습니다.

```ruby
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

커넥션 풀은 기본값으로 Active Record 내부에서 처리되기 때문에 애플리케이션 서버는 Thin이나 mongrel, unicorn 등 어떤 것을 사용하더라도 같은 동작을 하게 됩니다. 처음에는 데이터베이스 커넥션 풀은 비어 있으며, 필요에 따라서 추가 커넥션을 생성하고, 커넥션 풀의 상한에 도달할 때까지 계속 추가됩니다.

하나의 요청에서 커넥션은 항상 데이터베이스 접근에 필요한 커넥션을 확보하고, 그 후는 그 커넥션이 있는지를 확인합니다. 요청 처리가 끝나면 큐에 대기하고 있는 다음 요청을 위해서 사용가능한 커넥션이 하나 추가되게 됩니다.

이용가능한 숫자보다 많은 커넥션을 사용하려고 시도하면 Active Record는 이를 막고 풀이 넘겨주는 커넥션을 기다립니다. 커넥션을 얻을 수 없는 경우에는 아래와 같은 타임 아웃 에러를 던집니다.

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5 seconds. The max pool size is currently 5; consider increasing it:
```

이 에러가 발생하는 경우에는 `database.yml`의 `pool` 옵션에 설정되어 있는 숫자를 더 큰 숫자로 변경하여 접속 풀의 크기를 키워 문제의 해결을 노려볼 수 있습니다.

NOTE: 애플리케이션을 멀티 스레드 환경에서 실행하고 있는 경우에는 많은 스레드가 동시에 접속할 가능성이 있습니다. 현 시점의 요청에 걸린 부하에 따라서 제한된 요청 가능 숫자를 여러 스레드가 경쟁적으로 요구할 가능성이 있습니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
