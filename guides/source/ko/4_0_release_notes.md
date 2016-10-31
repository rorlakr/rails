


Ruby on Rails 4.0 릴리스 노트
===============================

Rails 4.0의 주목할 점

* Ruby 2.0이 권장. 1.9.3 이상이 필수.
* Strong Parameters
* Turbolinks
* 러시안 인형 캐시(Russian Doll Caching)

이 릴리스 노트에서는 주요한 변경점에 대해서만 설명합니다. 다수의 버그 수정 및 변경점에 대해서는 GitHub의 Rails 저장소에 있는 [커밋 목록](https://github.com/rails/rails/commits/4-0-stable)의 CHANGELOG를 참조하세요.

--------------------------------------------------------------------------------

Rails 4.0로 업그레이드
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것은 좋은 생각입니다. 애플리케이션이 Rails 3.2까지 업그레이드되지 않았을 경우에는 이부터 시작하고, 애플리케이션이 정상적으로 동작하는 것을 충분히 확인한 뒤에 Rails 4.0으로 업데이트 해주세요. 업그레이드의 주의점에 대해서는 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#rails-3-2에서-Rails-4-0로-업그레이드)를 참고해주세요.


Rails 4.0 애플리케이션을 생성하기
--------------------------------

```
# 'rails'라는 RubyGem이 설치되어 있는지 확인해야합니다.
$ rails new myapp
$ cd myapp
```

### gem 설치하기

Rails 4.0부터는 애플리케이션의 최상위에 위치하는 `Gemfile`을 사용하여 애플리케이션의 기동에 필요한 gem을 지정하게 되었습니다. 이 `Gemfile`은 [Bundler](https://github.com/carlhuda/bundler)이라는 gem에 의해서 처리되며 의존관계로 요구되는 gem을 모두 설치합니다. 의존하는 gem을 그 애플리케이션에 설치하여 OS 환경에 있는 기존의 gem에 영향을 주지 않도록 할 수도 있습니다.

추가정보: [Bundler 홈페이지](http://gembundler.com)

### 최신 gem 사용하기

`Bundler`와 `Gemfile` 덕분에 전용 `bundle` 명령어를 한번에 Rails gem을 간단하게 사용할 수  있습니다. Git 저장소로부터 직접 bundle 하고 싶은 경우에는 `--edge` 플래그를 사용하세요.

```
$ rails new myapp --edge
```

Rails의 저장소를 로컬에 체크아웃해둔 상태이고, 그것을 사용해서 애플리케이션을 생성하고 싶은 경우에는 `--dev` 플래그를 추가하세요.

```
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

주요 변경점
--------------

[![Rails 4.0](images/rails4_features.png)](http://railsguides.jp/images/rails4_features.png)

### 업그레이드

* **Ruby 1.9.3** ([커밋](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Ruby 2.0을 추천, 1.9.3이상이 필수.
* **[이후의 Deprecated 정책](http://www.youtube.com/watch?v=z6YgD6tVPQs)** - Deprecated된 기능은 Rails 4.0에서 경고가 출력되며, Rails 4.1에서는 그 기능이 완전히 삭제됩니다.
* **ActionPack의 '페이지와 액션 캐시'(page and action caching)** ([커밋](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - 페이지와 액션 캐시는 별도의 gem으로 분리되었습니다. 페이지와 액션 캐시는 수동으로 조정해야하는 부분이 너무 많습니다(예를 들어 사용하는 모델 객체가 갱신되면 캐시를 수동으로 갱신해야할 때가 있습니다). 이후는 러시아 인형 캐시를 사용합니다.
* **ActiveRecord observers** ([커밋](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - observers(디자인 패턴)는 별도의 gem으로 분리되었습니다. observers 패턴은 페이지와 액션 캐시에서만 사용되며, 코드가 엉망이 되기 쉽기 때문입니다.
* **ActiveRecord 세션 저장소** ([커밋](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord 세션 저장소는 별도의 gem으로 분리되었습니다. 세션을 SQL에 저장하는 경우에는 비용이 상대적으로 무겁습니다. 앞으로는 cookies 세션, memcache 세션, 또는 그 외의 세션 저장소를 사용하세요.
* **ActiveModel 대량 할당 보호** ([커밋](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3의 대량할당 보호가 Deprecated되었습니다. 앞으로는 Strong Parameters를 사용하세요.
* **ActiveResource** ([커밋](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource는 별도의 gem로 분리되었습니다. ActiveResource의 사용 빈도가 낮기 때문입니다.
* **vendor/plugins의 삭제** ([커밋](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - 앞으로는 Gemfile을 통해 gem으로 설치하여 관리하세요.

### ActionPack

* **Strong Parameters** ([커밋](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - 화이트 리스트로 명시적으로 허가된 파라미터(`params.permit(:title, :text)`)를 사용하지 않으면 모델 객체를 갱신할 수 없습니다.
* **라우팅의 'concern' 기능** ([커밋](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - 라우팅용의 DSL로 공통의 중첩 라우팅(subroutes)을 제외합니다(`/posts/1/comments`와 `/videos/1/comments`에서의 `comments` 등).
* **ActionController::Live** ([커밋](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - JSON를 `response.stream`에서 스트리밍합니다.
* **'선언적(declarative)' ETag** ([커밋](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - 컨트롤러 라벨에 etag를 추가합니다. 이것은 액션에서 etag 산출에도 사용됩니다.
* **[러시안 인형 캐시](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([커밋](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - 뷰에서 중첩된 코드 조각을 캐시합니다. 각 조각은 의존관계의 조합(캐시 키)에 따라서 기한이 만료됩니다. 일반적으로 이 캐시 키에는 템플릿의 버전 번호와 모델 객체가 사용됩니다.
* **Turbolinks** ([커밋](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - 첫 HTML 페이지만을 사용해서 서비스를 제공합니다(역주: 일부만이 다른 페이지를 위해서 페이지 전체를 HTTP 전송을 하지 않도록 하는 구조). 사용자가 다른 페이지로 이동하면, pushState로 URL을 바꾸고, AJAX로 제목과 body를 변경합니다.
* **ActionController와 ActionView의 분리** ([커밋](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView는 ActionPack로부터 분리되어 Rails 4.1에서 별도의 gem으로 분리될 예정입니다.
* **ActiveModel에 의존하지 말 것** ([커밋](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack는 이제 ActiveModel을 사용하지 않습니다.

### 일반

* **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`는 일반적인 Ruby 객체에서도 ActionPack의 기능을 사용할 수 있도록(`form_for` 등)하는 플러그인.
* **새로운 '스코프 API'** ([커밋](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - scope 메소드의 인수는 항상 call 메소드로 구현해야합니다.
* **스키마 해시 덤프** ([커밋](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Rails의 기동시간을 단축하기 위해서 스키마를 데이터베이스로부터 직접 읽어오는 것이 아니고, 덤프 파일로부터 읽어옵니다.
* **트랜젝션 고립 레벨을 지정할 있도록 지원** ([커밋](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - 읽기가 빈번하게 하거나, 쓰기 성능을 중시하여 잠금을 줄일지 선택할 수 있습니다.
* **Dalli** ([커밋](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - memcache 저장소에는 Dalli의 memcache 클라이언트를 사용하세요.
* **통지 알림과 종료** ([커밋](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Support의 내부 훅 구조(instrumentation)에 의해 구독자에 대한 통지를 시작 및 종료가 보고됩니다.
* **기본으로 스레드 안전을 제공** ([커밋](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails는 추가 설정 없이 스레드로 만들어집니다.

NOTE: 추가한 gem도 마찬가지로 스레드 세이프인지 아닌지 확인해두세요.

* **PATCH 동사** ([커밋](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - 기존의 HTTP 동사인 PUT은 PATCH로 변경되었습니다. PATCH는 리소스의 부분적인 갱신에 사용됩니다.

### 보안

* **match만으로 모든 라우팅을 잡지 말 것** ([커밋](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - 라우팅 용의 DSL에 match를 사용하는 경우에는 HTTP 동사를 명시적으로 하나 또는 복수를 지정해야합니다.
* **html 요소를 기본으로 이스케이프** ([커밋](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - ERB에서 렌더링되는 문자열은 `raw`나 `html_safe` 메소드로 감싸지 않는 이상 항상 이스케이프됩니다.
* **새로운 보안 헤더** ([덧글](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails에서 전송되는 모든 HTTP 요청에 다음 헤더가 포함되게 변경되었습니다: `X-Frame-Options`(피싱을 막기 위해서 프레임 내에 페이지를 끼워넣지 못하도록 브라우저에 지시합니다), `X-XSS-Protection`(스크립트 주입을 하지 못하도록 브라우저에 지시합니다), `X-Content-Type-Options`(jpeg 파일을 exe로 열지 않도록 브라우저에 지시합니다).

외부 gem으로 분리된 기능
---------------------------

Rails 4.0에서는 많은 기능이 분리되어 gem이 되었습니다. 분리된 gem을 `Gemfile` 파일에 추가하기만 하면 이전과 마찬가지로 사용할 수 있습니다.

* 해시 기반의 동적 find 메소드([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Active Record 모델에 대량할당 보호([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Active Record Observer 패턴([GitHub](https://github.com/rails/rails-observers)、[Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [블로그 포스팅](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* 액션 캐시([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* 페이지 캐시([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets([GitHub](https://github.com/rails/sprockets-rails))
* 성능 테스트([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

문서
-------------

* 가이드는 GFM으로 새로 작성되었습니다.

* 가이드의 디자인이 반응형으로 변경되었습니다.

Railties
--------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* 테스트용 폴더가 추가되었습니다: `test/models`, `test/helpers`, `test/controllers`, `test/mailers`에 대응하는 rake 태스크가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/7878)).

* 애플리케이션의 실행파일은 `bin/` 폴더에 위치하게 되었습니다. `rake rails:update:bin`를 실행하면 `bin/bundle`, `bin/rails`, `bin/rake`를 가져옵니다.

* 기본으로 스레드 안전하게 되었습니다.

* `rails new`에 `--builder` 또는 `-b`를 넘기면 커스텀 빌더를 사용할 수 있는 기능이 삭제되었습니다. 앞으로는 애플리케이션 템플릿의 사용을 검토해주세요([Pull Request](https://github.com/rails/rails/pull/9401)).

### Deprecated

* `config.threadsafe!`는 Deprecated되었습니다. 앞으로는 `config.eager_load`를 사용해주세요. 이는 미리 읽기(eager load)의 대상을 좀 더 세밀하게 제어할 수 있습니다.

* `Rails::Plugin`는 폐기되었습니다. 앞으로는 `vendor/plugins`에 플러그인을 추가하는 대신, gem이나 bundler에 경로에 git 의존 관계를 지정해서 사용해주세요.

Action Mailer
-------------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

### Deprecated

Active Model
------------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* `ActiveModel::ForbiddenAttributesProtection`가 추가되었습니다. 허가되지 않은 속성이 넘겨진 경우에 대량할당으로부터 속성을 보호하기 위한 간단한 모듈입니다.

* `ActiveModel::Model`가 추가되었습니다. Ruby 객체를 Action Pack에서 바로 사용할 수 있도록 하기 위한 믹스인입니다.

### Deprecated

Active Support
--------------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* Deprecated된 `memcache-client` gem 대신 `ActiveSupport::Cache::MemCacheStore`의 `dalli`로 변경했습니다.

* `ActiveSupport::Cache::Entry`가 최적화되어 메모리의 사용량과 처리 오버헤드가 경감되었습니다.

* 말의 활용형(inflection)를 로케일마다 설정할 수 있게 되었으며 `singularize`이나 `pluralize` 메소드의 인수에 로케일도 지정할 수 있게 되었습니다.

* `Object#try`에 넘긴 객체에 메소드가 구현되어 있지 않은 경우에 NoMethodError를 던지는 대신 nil을 반환하게 되었습니다. 새로운 `Object#try!`를 사용하면 이전과 동일한 동작을 하게 됩니다.

* `String#to_date`에 유효하지 않은 날짜를 넘기는 경우에 발생하는 에러가 `NoMethodError: undefined method 'div' for nil:NilClass`에서 `ArgumentError: invalid date`로 변경되었습니다. 이를 통해 `Date.parse`와 동일한 동작이 되었으며, 아래와 같이 3.x보다도 날짜를 적절하게 다룰수 있게 되었습니다.

  ```ruby
  # ActiveSupport 3.x
  "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
  "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

  # ActiveSupport 4
  "asdf".to_date # => ArgumentError: invalid date
  "333".to_date # => Fri, 29 Nov 2013
  ```

### Deprecated

* `ActiveSupport::TestCase#pending` 메소드가 Deprecated되었습니다. 이후에는 MiniTest의 `skip`을 사용해주세요.

* `ActiveSupport::Benchmarkable#silence`는 스레드 안전하지 않으므로 Deprecated되었습니다. Rails 4.1에서는 삭제될 예정입니다.

* `ActiveSupport::JSON::Variable`가 Deprecated되었습니다. 커스텀 JSON 문자열 리터럴을 다루고 싶은 경우에는 `#as_json`과 `#encode_json` 메소드를 직접 정의해주세요.

* 호환용 `Module#local_constant_names` 메소드가 Deprecated되었습니다. 앞으로는 심볼을 반환하는 `Module#local_constants`를 사용해주세요.

* `BufferedLogger`가 Deprecated되었습니다. 앞으로는 `ActiveSupport::Logger` 또는 Ruby 표준 라이브러리의 로거를 사용해주세요.

* `assert_present`와 `assert_blank`는 Deprecated되었습니다. 앞으로는 `assert object.blank?`나 `assert object.present?`를 사용해주세요.

Action Pack
-----------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* development 환경에서 예외 페이지의 스타일 시트가 변경되었습니다. 그리고 예외 페이지에는 그 예외가 실제로 발생한 코드 조각을 항상 보여주게 되었습니다.

### Deprecated


Active Record
-------------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* 마이그레이션에서 `change`를 작성하는 방법이 개량되어 이전처럼 `up`이나 `down` 메소드를 사용할 필요가 없어졌습니다.

    * `drop_table` 메소드와 `remove_column` 메소드는 반대 방향의 마이그레이션(취소)가 가능해졌습니다. 단, 필요한 정보가 주어져야합니다.
      `remove_column` 메소드는 이전의 여러 컬럼을 인수로 지정할 수 있었습니다만, 앞으로는 이러한 경우에 `remove_columns` 메소드를 사용해주세요(단, 이 메소드로는 역방향 마이그레이션이 불가능합니다).
      `change_table`도 역방향 마이그레이션이 가능해졌습니다. 단, 그 블럭에서 `remove`, `change`, `change_default`가 호출되지 않아야 합니다.

    * `reversible` 메소드가 새롭게 추가되었으며, 마이그레이션(up)이나 역방향 마이그레이션(down)에 실행할 코드를 지정할 수 있게 되었습니다.
      자세한 설명은 [Active Record 마이그레이션 가이드](active_record_migrations.md#reversible-사용하기)를 참고해주세요.

    * 새로운 `revert` 메소드는 지정된 블럭이나 마이그레이션 전체를 반대로 적용합니다. 역방향 마이그레이션(down)을 실행하면, 지정된 마이그레이션이나 블럭은 일반 마이그레이션(up)이 됩니다.
      자세한 설명은 [Active Record 마이그레이션 가이드](hactive_record_migrations.md#이전-마이그레이션을-롤백하기)를 참고해주세요.

* PostgreSQL의 배열형 지원이 추가되었습니다. 배열 컬럼의 생성시에 임의의 데이터 형식을 사용할 수 있습니다. 이 데이터 형식은 풀 마이그레이션이나 스키마 덤프에서도 지원됩니다.

* `Relation#load` 메소드가 추가되었습니다. 이는 레코드를 명시적으로 읽어서 `self`를 반환합니다.

* `Model.all`이 `ActiveRecord::Relation`을 반환하게 되었습니다. 기존에는 레코드의 배열을 돌려주었습니다. 레코드의 배열이 필요한 경우에는 `Relation#to_a`를 사용해주세요. 단, 상황에 따라서 앞으로의 업그레이드에서는 정상적으로 동작하지 않을 수도 있습니다.

* `ActiveRecord::Migration.check_pending!`가 추가되었습니다. 이는 적용되지 않은 마이그레이션이 있을 경우에 에러를 발생시킵니다.

* `ActiveRecord::Store`용의 커스텀 코더 지원이 추가되었습니다. 이를 통해 다음과 같은 방식으로 다른 코더를 사용할 수 있습니다.

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* `mysql`나 `mysql2`에 접속할 때에 기본으로 `SQL_MODE=STRICT_ALL_TABLES`이 설정됩니다. 이는 데이터 손실시에 아무것도 통지되지 않는 상황을 피하기 위한 설정입니다. `database.yml` 파일에서 `strict: false`를 지정하면 이 설정을 비활성화할 수 있습니다.

* IdentityMap이 삭제되었습니다.

* EXPLAIN 쿼리의 자동실행이 삭제되었습니다. 이 `active_record.auto_explain_threshold_in_seconds` 옵션은 앞으로 사용되지 않으므로 삭제해야합니다.

* `ActiveRecord::NullRelation`와 `ActiveRecord::Relation#none`가 추가되었습니다. 이는 Relation 클래스에 null 객체 패턴을 구현한 것입니다.

* `create_join_table` 마이그레이션 헬퍼가 추가되었습니다. 이는 HABTM(Has And Belongs To Many) 결합 테이블을 생성합니다.

* PostgreSQL hstore 레코드를 생성할 수 있게 되었습니다.

### Deprecated

* 기존의 해시 기반의 find 관련 API 메소드는 Deprecated되었습니다. 이에 따라 이전에는 사용 가능했던 'find 옵션'은 지원되지 않습니다.

* 동적인 find 관련 메소드는 `find_by_...`와 `find_by_...!`를 제외하고 Deprecated되었습니다. 이하의 요령으로 코드를 고쳐주세요.

      * `find_all_by_...`는 `where(...)`로 재작성할수 있습니다.
      * `find_last_by_...`는 `where(...).last`로 재작성할수 있습니다.
      * `scoped_by_...`는 `where(...)`로 재작성할수 있습니다.
      * `find_or_initialize_by_...`는 `find_or_initialize_by(...)`로 재작성할수 있습니다.
      * `find_or_create_by_...`는 `find_or_create_by(...)`로 재작성할수 있습니다.
      * `find_or_create_by_...!`는 `find_or_create_by!(...)`로 재작성할수 있습니다.

크레딧 표기
-------

Rails를 견고하고 안정적인 프레임워크로 만들기 위해 많은 시간을 사용해주신 많은 개발자들에 대해서는 [Rails 기여자 목록](http://contributors.rubyonrails.org/)을 참고해주세요. 이 분들에게 경의를 표합니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
