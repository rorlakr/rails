
Ruby on Rails 4.1 릴리스 노트
===============================

Rails 4.1 주요 변경점

* 애플리케이션 로더 Spring
* `config/secrets.yml`
* Action Pack Variant
* Action Mailer 프리뷰

이 릴리스 노트는 주요한 변경점만을 설명합니다. 자잘한 버그 수정이나 변경에 대해서는 CHANGELOG를 참고하거나, GitHub의 Rails 저장소에 있는 [커밋 목록](https://github.com/rails/rails/commits/master)을 참조해주세요.

--------------------------------------------------------------------------------

Rails 4.1로 업그레이드
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것은 좋은 생각입니다. 애플리케이션이 Rails 4.0까지 업그레이드되지 않았을 경우에는 이부터 시작하고, 애플리케이션이 정상적으로 동작하는 것을 충분히 확인한 뒤에 Rails 4.1으로 업데이트 해주세요. 업그레이드의 주의점에 대해서는 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#rails-4-0에서-Rails-4-1로-업그레이드)를 참고해주세요.


주요 변경점
--------------

### 'Spring' 애플리케이션 로더

Spring은 Rails 애플리케이션을 위한 로더입니다. 애플리케이션을 백그라운드에서 상주시켜두는 것으로 개발 속도를 향상시키며, 테스트나 rake 태스크, 마이그레이션을 실행할 때마다 Rails를 기동하지 않아도 됩니다.

Rails 4.1 애플리케이션에 포함되는 bunstub은 'spring화'되어있습니다. 이러한 애플리케이션의 최상단 폴더에서 `bin/rails`와 `bin/rake`를 실행하면 자동적으로 spring 환경을 미리 로딩합니다.

**rake 태스크를 실행:**

```
bin/rake test:models
```

**Rails 명령을 실행:**

```
bin/rails console
```

**Spring의 상태 확인:**

```
$ bin/spring status
Spring is running:

1182 spring server | my_app | started 29 mins ago
3656 spring app    | my_app | started 23 secs ago | test mode
3746 spring app    | my_app | started 10 secs ago | development mode
```

Spring의 모든 기능에 대해서는 [Spring README](https://github.com/rails/spring/blob/master/README.md)를 참고해주세요.

[Ruby on Rails 업그레이드가이드](upgrading_ruby_on_rails.html#spring)에서는 이 기능을 기존의 애플리케이션에 통합하는 방법에 대해서 설명합니다.

### `config/secrets.yml`

Rails 4.1에서는 `config` 폴더에 새롭게 `secrets.yml` 파일이 생성되었습니다. 기본으로 이 파일에는 애플리케이션의 `secret_key_base`가 포함되어 있습니다만, 외부 API용의 접근 키 등의 비밀키도 여기에 저장합니다.

이 파일에 저장되어있는 비밀키는 `Rails.application.secrets`를 통해서 접근할 수 있습니다. 예를 들어, 다음의 `config/secrets.yml`를 확인해봅시다.

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

이 설정을 한 경우 development 환경에서 `Rails.application.secrets.some_api_key`를 실행하면 `SOMEKEY`가 반환됩니다.

기존의 애플리케이션에 이 기능을 사용하는 방법에 대해서는 [Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#config-secrets-yml)를 참고해주세요.

### Action Pack Variant

스마트폰, 타블렛, 데스크탑 브라우저마다 다른 HTML/JSON/XML 템플릿을 사용하고 싶은 경우가 자주 있습니다. Variant를 사용하여 이를 간단하게 실현할 수 있습니다.

요청 variant는 `:tablet`, `:phone`, `:desktop`와 같은 요청 형식을 특수화한 것입니다.

`before_action`에 다음의 variant를 설정합니다.

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

액션에서는 형식의 응답과 같은 요령으로 variant에 응답할 수 있습니다.

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # renders app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

포맷마다, variant마다 개별의 템플릿을 준비해주세요.

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

다음의 인라인 문법을 사용하여 variant 정의를 간단하게 사용할 수도 있습니다.

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Action Mailer 프리뷰

Action Mailer 프리뷰는 특정 URL에 접근하여 전송될 메일이 어떤 모습으로 보이게 될 지 미리 볼 수 있게 해줍니다.

확인하고 싶은 메일 객체를 반환하는 메소드를 가지는 프리뷰 클래스를 정의해주세요.

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

프리뷰를 출력하려면 http://localhost:3000/rails/mailers/notifier/welcome 에 접속합니다. 프리뷰의 목록은 http://localhost:3000/rails/mailers 에 있습니다.

기본 프리뷰 클래스는 `test/mailers/previews`에 위치합니다.
`preview_path` 옵션을 통해 이를 변경할 수 있습니다.

자세한 설명은 [문서](http://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html)를 참조해주세요.

### Active Record enums

데이터베이스의 값을 integer로 사상하고 싶은 경우에는 enum 속성을 선언합니다만, 이름으로 쿼리를 요청할 수도 있습니다.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Relation for all archived Conversations

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

자세한 설명은 [메뉴얼](http://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)을 참고해주세요.

### 메시지 검증자

메시지 검증자(message verifier)는 서명된 메시지를 생성 및 대조할 때에 사용합니다. 이 기능은 '패스워드를 저장(remember me)' 토큰이나 친구 목록 같은 비밀 데이터를 안전하게 전송할 때에 편리합니다.

`Rails.application.message_verifier` 메소드는 secret_key_base를 사용하여 생성된 키로 새로운 메시지 검증자 이름과 서명된 메시지를 반환합니다.

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# ActiveSupport::MessageVerifier::InvalidSignature를 던진다.
```

### Module#concerning

자연스럽고 보기 좋도록, 클래스에서 책임을 분리합니다.

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      ...
    end

    private
      def some_internal_method
        ...
      end
  end
end
```

이 예제는 `EventTracking` 모듈을 인라인으로 정의하고 `ActiveSupport::Concern`으로 extend하여 `Todo` 클래스에 믹스인한 것과 동등합니다.

자세한 설명 및 적당한 사용 예제에 대해서는 [메뉴얼](http://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)을 참조해주세요.

### 원격 `<script>` 태그에 CSRF 보호를 적용

JavaScript 응답을 동반하는 GET 요청도 크로스 사이트 리퀘스트 포저리(CSRF) 보호 대상이 되었습니다. 이 보호를 통해 제3자 사이트가 중요한 데이터를 탈취를 위해 자신의 사이트의 JavaScript URL을 참조할 수 없게 됩니다.

이는 `xhr`를 사용하지 않는 경우 `.js` URL에 해당하는 모든 테스트는 CSRF 보호에 의해서 실패하게 된다는 의미입니다. `XmlHttpRequests`를 명시적으로 사용하도록 테스트를 개선해주세요. `post :create, format: :js` 대신에 명시적으로 `xhr :post, :create, format: :js`를 사용해주세요.


Railties
--------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)를 참고해주세요.

### 삭제된 것들

* `update:application_controller` rake task가 삭제되었습니다.

* Deprecated였던 `Rails.application.railties.engines`이 삭제되었습니다.

* Deprecated였던 `threadsafe!`가 Rails Config에서 삭제되었습니다.

* Deprecated였던 `ActiveRecord::Generators::ActiveModel#update_attributes`가 삭제되었습니다. `ActiveRecord::Generators::ActiveModel#update`를 사용해주세요.

* Deprecated였던 `config.whiny_nils` 옵션이 삭제되었습니다.

* Deprecated였던 태스트 실행용 rake 태스크 `rake test:uncommitted`와 `rake test:recent`가 삭제되었습니다.

### 주요 변경점

* [Spring 애플리케이션 로더](https://github.com/rails/spring)는 신규 애플리케이션에 기본으로 설치됩니다. Gemfile의 develop 그룹에 설치되며, production 그룹에는 설치되지 않습니다([Pull Request](https://github.com/rails/rails/pull/12958)).

* 테스트에 실패했을 때에 필터링되지 않는 백트레이스를 출력하는 `BACKTRACE` 환경 변수([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553)).

* `MiddlewareStack#unshift`가 환경구성용으로 공개되었습니다([Pull Request](https://github.com/rails/rails/pull/12479)).

* 메시지 검증자를 반환하는 `Application#message_verifier` 메소드([Pull Request](https://github.com/rails/rails/pull/12995)).

* 기본으로 생성된 테스트 헬퍼에 require된 `test_help.rb` 파일은 `db/schema.rb`(또는 `db/structure.sql`)을 사용하여 자동적으로 테스트 데이터베이스를 최신 상태로 유지합니다. 스키마를 다시 읽더라도 적용되지 않은 마이그레이션이 남아있는 경우에는 에러가 발생합니다. `config.active_record.maintain_test_schema = false`를 지정하여 에러를 회피할 수 있습니다([Pull Request](https://github.com/rails/rails/pull/13528)).

* `Gem::Version.new(Rails.version)`을 반환하는 편의 메소드로서 `Rails.gem_version`가 도입되었습니다. 이전보다 신뢰할 수 있는 버전 비교법을 제공합니다([Pull Request](https://github.com/rails/rails/pull/14103)).


Action Pack
-----------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)를 참고해주세요.

### 삭제된 것들

* Deprecated된 통합 테스트용 Rails 애플리케이션 폴백이 삭제되었습니다. `ActionDispatch.test_app`를 대신 사용해주세요.

* Deprecated된 `page_cache_extension` config가 삭제되었습니다.

* Deprecated된 `ActionController::RecordIdentifier`가 삭제되었습니다. `ActionView::RecordIdentifier`를 대신 사용해주세요.

* 다음의 Deprecated된 상수가 Action Controller에서 삭제되었습니다.

| 삭제됨                            | 대체품                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### 주요 변경점

* `protect_from_forgery`에 의해서 동일 도메인 `<script>` 태그도 사용할 수 없게 되었습니다. 테스트를 업데이트하여 `get :foo, format: :js` 대신에 `xhr :get, :foo, format: :js`를 사용해주세요([Pull Request](https://github.com/rails/rails/pull/13345)).

* `#url_for`는 옵션 해시를 배열에서 사용할 수 있게 되었습니다([Pull Request](https://github.com/rails/rails/pull/9599)).

* `session#fetch` 메소드가 추가되었습니다. 이 동작은 [Hash#fetch](http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch)와 비슷합니다만, 반환값이 언제나 세션에 저장된다는 점이 다릅니다([Pull Request](https://github.com/rails/rails/pull/12692)).

* Action View는 Action Pack에서 완전히 분리되었습니다([Pull Request](https://github.com/rails/rails/pull/11032)).

* deep_munge에 영향받은 키가 로그에 출력됩니다([Pull Request](https://github.com/rails/rails/pull/13813)).

* 보안 취약점 CVE-2013-0155에 대응하기 위해서 파라미터의 deep_munge화를 피하는 `config.action_dispatch.perform_deep_munge` config 옵션이 새로 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/13188)).

* 서명과 암호화된 cookies jar의 직렬화를 지정하는 `config.action_dispatch.cookies_serializer` config 옵션이 새롭게 추가되었습니다(Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [자세한 설명](upgrading_ruby_on_rails.html#cookies-직렬화)).

* `render :plain`, `render :html`, `render :body`가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/14062) / [자세한 설명](upgrading_ruby_on_rails.html#문자열에서-컨텐츠-추출하기)).


Action Mailer
-------------

자세한 변경에 대해서는 [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)를 참고해주세요.

### 주요 변경점

* 37 Signals사의 mail_view gem을 기반으로 메일러의 프리뷰 기능이 추가되었습니다([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261)).

* Action Mailer 메시지 생성 시간이 측정할 수 있게 되었습니다. 이 생성 시간이 로그에 기록됩니다([Pull Request](https://github.com/rails/rails/pull/12556)).


Active Record
-------------

자세한 변경에 대해서는 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)를 참고해주세요.

### 삭제된 것들

* Deprecated된 `SchemaCache` 메소드(`primary_keys`, `tables`, `columns`, `columns_hash`)에 nil을 넘기는 기능이 삭제되었습니다.

* Deprecated된 블럭 필터가 `ActiveRecord::Migrator#migrate`로부터 삭제되었습니다.

* Deprecated된 String 생성자가 `ActiveRecord::Migrator`로부터 삭제되었습니다.

* `scope`에서 호출 가능한 객체를 넘기지 않는 방식이 삭제되었습니다.

* Deprecated된 `transaction_joinable=`이 삭제되었습니다. `:joinable` 옵션과 함께 `begin_transaction`를 사용해주세요.

* Deprecated된 `decrement_open_transactions`이 삭제되었습니다.

* Deprecated된 `increment_open_transactions`이 삭제되었습니다.

* Deprecated된 `PostgreSQLAdapter#outside_transaction?` 메소드가 삭제되었습니다. 대신에 `#transaction_open?`을 사용해주세요.

* Deprecated된 `ActiveRecord::Fixtures.find_table_name`가 삭제되었습니다. `ActiveRecord::Fixtures.default_fixture_model_name`를 사용해주세요.

* Deprecated된 `columns_for_remove`가 `SchemaStatements`에서 삭제되었습니다.

* Deprecated된 `SchemaStatements#distinct`가 삭제되었습니다.

* Deprecated된 `ActiveRecord::TestCase`가 Rails 테스트 셋으로 옮겨졌습니다. 이 클래스는 public하지 않으며, Rails 테스트 내에서만 사용됩니다.

* Association에서의 `:dependent`는 Deprecated된 `:restrict` 옵션을 더이상 지원하지 않습니다.

* Association에서 Deprecated된 `:delete_sql`, `:insert_sql`, `:finder_sql`, `:counter_sql` 옵션이 삭제되었습니다.

* Column에서 Deprecated된 `type_cast_code`가 삭제되었습니다.

* Deprecated된 `ActiveRecord::Base#connection` 메소드가 삭제되었습니다. 이 메소드에는 클래스를 경유하여 사용해주세요.

* `auto_explain_threshold_in_seconds`의 Deprecated 경고가 삭제되었습니다.

* `Relation#count`에서 Deprecated된 `:distinct` 옵션이 삭제되었습니다.

* Deprecated된 `partial_updates`, `partial_updates?`, `partial_updates=`가 삭제되었습니다.

* Deprecated된 `scoped` 메소드가 삭제되었습니다.

* Deprecated된 `default_scopes?`가 삭제되었습니다.

* 4.0에서 Deprecated였던 암묵 결합 참조가 삭제되었습니다.

* 의존관계로서의 `activerecord-deprecated_finders`가 삭제되었습니다. 상세한 설명은 [gem README](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)를 참조해주세요.

* `implicit_readonly`의 용법이 삭제되었습니다. 명시적으로 `readonly` 메소드를 사용하여 레코드를 `readonly`로 설정해주세요([Pull Request](https://github.com/rails/rails/pull/10769)).

### Deprecated

* `quoted_locking_column` 메소드는 Deprecated되었습니다. 현재 사용되는 곳은 없습니다.

* `ConnectionAdapters::SchemaStatements#distinct`는 내부에서 사용되지 않기 때문에 Deprecated되었습니다([Pull Request](https://github.com/rails/rails/pull/10556)).

* `rake db:test:*` 태스크는 Deprecated되었습니다. 데이터베이스는 자동적으로 관리됩니다. railties의 릴리스 노트를 참고해주세요([Pull Request](https://github.com/rails/rails/pull/13528)).

* 사용되지 않는 `ActiveRecord::Base.symbolized_base_class`, 그리고 `ActiveRecord::Base.symbolized_sti_name`가 Deprecated되었습니다. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### 주요 변경점

기본 스코프는 조건을 연쇄시킨 경우 재정의할 수 없게 변경되었습니다.

  이번 변경에 의해서 이전 모델에서 `default_scope`를 정의하고 있는 경우 같은 필드에서 조건이 연쇄되는 경우에 재정의하지 않게 되었습니다. 현재는 다른 스코프들과 마찬가지로 병합됩니다. [자세한 설명](upgrading_ruby_on_rails.html#기본-스코프의-변경)

* 모델의 속성이나 메소드로부터 파생되는 "깔끔한" URL용으로 `ActiveRecord::Base.to_param`가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/12891)).

* `ActiveRecord::Base.no_touching`가 추가되었습니다. 모델에 대한 터치를 무시합니다([Pull Request](https://github.com/rails/rails/pull/12772)).

* `MysqlAdapter`와 `Mysql2Adapter`에 의해서 형변환의 판정이 통일되었습니다. `type_cast`는 `true`인 경우에 `1`을, `false`의 경우에 `2`를 반환합니다([Pull Request](https://github.com/rails/rails/pull/12425)).

* `.unscope`를 지정하면 `default_scope`로 지정된 조건이 삭제됩니다([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade)).

* `ActiveRecord::QueryMethods#rewhere`이 추가되었습니다. 현재의 이름있는 where 조건을 재정의합니다([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2)).

* `ActiveRecord::Base#cache_key`가 확장되어 timestamp 속성 목록을 옵션으로 받을 수 있게 되었습니다. timestamp 속성 목록에서 최대값이 사용됩니다([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329)).

* enum 속성을 선언하는 `ActiveRecord::Base#enum`가 추가되었습니다. enum 속성은 데이터베이스의 integer에 사상합니다만, 이름으로 쿼리할 수 있습니다([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5)).

* json값이 저장될 때에 형변환됩니다. 이를 통해서 데이터베이스에서 꺼낸 값과 일관되게 유지합니다([Pull Request](https://github.com/rails/rails/pull/12643)).

* hstore값이 저장될 때에 형변환됩니다. 이를 통해서 데이터베이스에서 꺼낸 값과 일관되게 유지합니다([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d)).

* 서드파티에서 만든 제너레이터를 위해 `next_migration_number`가 접근 가능하게 변경되었습니다([Pull Request](https://github.com/rails/rails/pull/12407)).

* 인수를 `nil`로 해서 `update_attributes`를 호출하면 항상 `ArgumentError` 에러가 발생합니다. 구체적으로는 넘겨진 인수가 `stringify_keys`에 응답하지 않는 경우에 에러가 발생합니다([Pull Request](https://github.com/rails/rails/pull/9860)).

* `CollectionAssociation#first`/`#last` (`has_many` 등)에 의한 결과로 컬렉션 전체를 불러오는 쿼리 대신에 한정적인 쿼리가 사용되게 됩니다([Pull Request](https://github.com/rails/rails/pull/12137)).

* Active Record 모델 클래스의 `inspect`는 새로운 접속을 초기화하지 않습니다. 다시 말해, 데이터베이스가 발견되지 않은 상태에서 `inspect`를 호출한 경우에 예외가 발생하지 않습니다([Pull Request](https://github.com/rails/rails/pull/11014)).

* `count` 컬럼 제약이 삭제되었습니다. SQL이 무효인 경우에는 데이터베이스에서 에러가 발생됩니다([Pull Request](https://github.com/rails/rails/pull/10710)).

* Rails가 역관계를 자동으로 검출하게 되었습니다. Association에서 `:inverse_of` 옵션을 설정하지 않은 경우, Active Record는 휴리스틱으로 역관계를 추측합니다([Pull Request](https://github.com/rails/rails/pull/10886)).

* ActiveRecord::Relation의 속성의 별칭을 다룰수 있게 되었습니다. 심볼 키를 사용하면 ActiveRecord는 별칭을 사용해서 데이터베이스 상의 실제 컬럼명을 선택합니다([Pull Request](https://github.com/rails/rails/pull/7839)).

* 픽스처의 ERB 파일은 메인 객체의 컨텍스트에서 평가되지 않습니다. 복수의 픽스쳐에서 사용되고 있는 헬퍼 메소드는 `ActiveRecord::FixtureSet.context_class`에서 포함되는 모듈상에 정의해야합니다([Pull Request](https://github.com/rails/rails/pull/13022)).

* RAILS_ENV가 명시적으로 지정되어 있는 경우에 테스트 데이터베이스의 create나 drop을 사용하지 않습니다([Pull Request](https://github.com/rails/rails/pull/13629)).

`Relation`에는 `#map!`나 `#delete_if` 등의 변경 메소드(mutator method)가 포함되지 않게 되었습니다. 이러한 메소드를 사용하고 싶은 경우에는 `#to_a`를 호출하여 `Array`로 변경해주세요([Pull Request](https://github.com/rails/rails/pull/13314)).

* `find_in_batches`, `find_each`, `Result#each`, 그리고 `Enumerable#index_by`는 자신의 사이즈를 계산 가능한 `Enumerator`를 반환하게 되었습니다([Pull Request](https://github.com/rails/rails/pull/13938)).

* `scope`, `enum`과 Associations에서 "dangerous" 이름 충돌이 발생하게 되었습니다([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896)).

* `second`에서 `fifth`까지의 메소드도 `first` 파인더와 동일한 방식으로 동작합니다([Pull Request](https://github.com/rails/rails/pull/13757)).

* `touch`가 `after_commit`과 `after_rollback` 콜백을 실행하도록 변경되었습니다([Pull Request](https://github.com/rails/rails/pull/12031)).

* `sqlite >= 3.8.0`에서 파셜 인덱스가 활성화되었습니다([Pull Request](https://github.com/rails/rails/pull/13350)).

* `change_column_null`가 복원 가능해졌습니다([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96)).

* 마이그레이션 후 무효화된 스키마 덤프에 플래그가 추가되었습니다. 이는 새로운 애플리케이션의 production 환경에서는 기본으로 `false`로 설정됩니다([Pull Request](https://github.com/rails/rails/pull/13948)).

Active Model
------------

자세한 변경은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)를 참조하세요.

### Deprecated

* `Validator#setup`는 Deprecated되었습니다. 이후에는 검증자의 생성자에서 수동으로 처리해야합니다([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a)).

### 주요 변경점

* `ActiveModel::Dirty`에 상태를 제어하는 새로운 API인 `reset_changes`와 `changes_applied`가 추가되었습니다.

* 검증을 정의할 때에 복수의 컨텍스트를 지정할 수 있게 되었습니다([Pull Request](https://github.com/rails/rails/pull/13754)).

* `attribute_changed?`가 해시를 받을 수 있게 되었으며, 속정이 주어진 값으로 변경되었거나(또는 주어진 값으로 변경되었는지)를 확인할 수 있게 되었습니다([Pull Request](https://github.com/rails/rails/pull/13131)).


Active Support
--------------

자세한 변경사항은 [Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)을 참고해주세요.


### 삭제된 것들

* `MultiJSON` 의존이 제거되었습니다. 이를 통해 `ActiveSupport::JSON.decode`는 `MultiJSON`의 옵션 해시를 받지 않게 되었습니다([Pull Request](https://github.com/rails/rails/pull/10576) / [자세한 설명](upgrading_ruby_on_rails.html#json-취급-방식의-변경점)).

* 커스텀 객체를 JSON으로 인코딩하는 `encode_json` 훅의 지원이 삭제되었습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem으로 분리되었습니다.

* Deprecated된 `ActiveSupport::JSON::Variable`가 삭제되었습니다.

* Deprecated된 `String#encoding_aware?` 코어 확장기능 (`core_ext/string/encoding`)이 삭제되었습니다.

* Deprecated된 `Module#local_constant_names`이 삭제되었습니다. 대신 `Module#local_constants`를 사용합니다.

* Deprecated된 `DateTime.local_offset`가 삭제되었습니다. `DateTime.civil_from_format`를 사용합니다.

* Deprecated된 `Logger` 코어 확장기능(`core_ext/logger.rb`)이 삭제되었습니다.

* Deprecated된 `Time#time_with_datetime_fallback`, `Time#utc_time`, `Time#local_time`이 삭제되었습니다. `Time#utc`와 `Time#local`를 사용합니다.

* Deprecated된 `Hash#diff`가 삭제되었습니다.

* Deprecated된 `Date#to_time_in_current_zone`가 삭제되었습니다. 대신 `Date#in_time_zone`를 사용합니다.

* Deprecated된 `Proc#bind`가 삭제되었습니다.

* Deprecated된 `Array#uniq_by`와 `Array#uniq_by!`가 삭제되었습니다. 원래의 `Array#uniq`와 `Array#uniq!`를 사용해주세요.

* Deprecated된 `ActiveSupport::BasicObject`가 삭제되었습니다. 대신 `ActiveSupport::ProxyObject`를 사용해주세요.

* Deprecated된 `BufferedLogger`가 삭제되었습니다. 대신 `ActiveSupport::Logger`를 사용해주세요.

* Deprecated된 `assert_present` 메소드와 `assert_blank` 메소드가 삭제되었습니다. 대신 `assert object.blank?`와 `assert object.present?`를 사용해주세요.

* 필터 객체용으로 Deprecated되었던 `#filter` 메소드가 삭제되었습니다. 대응하는 다른 메소드를 사용해주세요(before filter의 `#before` 등).

* 기본 활용형으로부터 불규칙 활용인 'cow' => 'kine'가 삭제되었습니다([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9)).

### Deprecated

* 시간 표현 `Numeric#{ago,until,since,from_now}`이 Deprecated되었습니다. 이 값은 AS::Duration으로 명시적으로 변환해주세요. 예: `5.ago` => `5.seconds.ago`([Pull Request](https://github.com/rails/rails/pull/12389))

* require 경로 `active_support/core_ext/object/to_json`가 Deprecated되었습니다. `active_support/core_ext/object/json`를 대신에 require해주세요([Pull Request](https://github.com/rails/rails/pull/12203)).

* `ActiveSupport::JSON::Encoding::CircularReferenceError`가 Deprecated되었습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem으로 분리되었습니다. ([Pull Request](https://github.com/rails/rails/pull/10785) / [자세한 설명](upgrading_ruby_on_rails.html#json-취급-방식의-변경점))

* `ActiveSupport.encode_big_decimal_as_string` 옵션이 Deprecated되었습니다. 이 기능은 [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem으로 분리되었습니다.
([Pull Request](https://github.com/rails/rails/pull/13060) / [자세한 설명](upgrading_ruby_on_rails.html#json-취급-방식의-변경점))

* 커스텀 `BigDecimal` 직렬화가 Deprecated되었습니다([Pull Request](https://github.com/rails/rails/pull/13911)).

### 주요 변경점

* `ActiveSupport`의 JSON 인코더가 재작성되었으며 pure-Ruby의 커스텀 인코딩이 아닌 JSON gem을 사용하게 되었습니다.
([Pull Request](https://github.com/rails/rails/pull/12183) / [자세한 설명](upgrading_ruby_on_rails.html#json-취급-방식의-변경점))

* JSON gem과의 호환성이 향상되었습니다.
([Pull Request](https://github.com/rails/rails/pull/12862) / [자세한 설명](upgrading_ruby_on_rails.html#json-취급-방식의-변경점))

* `ActiveSupport::Testing::TimeHelpers#travel`과 `#travel_to`가 추가되었습니다. 이 메소드들은 `Time.now`와 `Date.today`를 스텁화하여 현재시각을 지정된 시각, 또는 시간으로 변환합니다.

* `ActiveSupport::Testing::TimeHelpers#travel_back`가 추가되었습니다. 이 메소드는 `travel`과 `travel_to` 메소드에 의해서 추가된 스텁을 제거하여 현재시각을 원래대로 되돌립니다([Pull Request](https://github.com/rails/rails/pull/13884)).

* `Numeric#in_milliseconds`가 추가되었습니다. `1.hour.in_milliseconds`처럼 사용할 수 있으며, 이를 `getTime()`등의 JavaScript 함수에 넘길 수도 있습니다([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643)).

* `Date#middle_of_day`, `DateTime#middle_of_day`, `Time#middle_of_day` 메소드가 추가되었습니다. 별칭으로 `midday`, `noon`, `at_midday`, `at_noon`, `at_middle_of_day`도 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/10879)).

* 기간을 생성하는 `Date#all_week/month/quarter/year`가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/9685)).

* `Time.zone.yesterday`와 `Time.zone.tomorrow`가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/12822)).

* 자주 사용되는 `String#gsub("pattern,'')`의 간결한 표현으로서 `String#remove(pattern)`가 추가되었습니다([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f)).

* 해시에서 값이 nil인 항목을 제거하기 위해서 `Hash#compact`와 `Hash#compact!`가 추가되었습니다([Pull Request](https://github.com/rails/rails/pull/13632)).

* `blank?`와 `present?`는 싱글톤을 반환합니다([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514)).

* 새로운 `I18n.enforce_available_locales` config의 기본값이 `true`입니다. 이것은 로케일에 넘겨진 `I18n`이 `available_locales` 목록에 포함되어 있어야한다는 의미입니다([Pull Request](https://github.com/rails/rails/pull/13341)).

`Module#concerning`가 도입되었습니다. 자연스럽고, 보기 좋은 방식으로 클래스에서 책임을 분리합니다([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81)).

* `Object#presence_in`가 추가되었습니다. 값의 화이트리스트화를 간략화합니다([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396)).


크레딧 표기
-------

Rails를 견고하고 안정적인 프레임워크로 만들기 위해 많은 시간을 사용해주신 많은 개발자들에 대해서는 [Rails 기여자 목록](http://contributors.rubyonrails.org/)을 참고해주세요. 이 분들에게 경의를 표합니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
