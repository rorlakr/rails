**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonrails.org.**

Ruby on Rails 5.1 릴리스 노트
===============================

Rails 5.1에서 주목할 점

* Yarn 지원
* 선택적인 웹팩(Webpack) 지원
* jQuery 더이상 기본 의존성이 아닙니다
* 시스템 테스트
* 암호화된 보안들
* 매개변수화된 메일러(Mailers)
* Direct & resolved routes
* form_for 및 form_tag 를 form_with에 통합

이 릴리스에서는 주요 변경점에 대해서만 설명합니다.
수정된 버그 및 변경점에 대해서는 Github Rails 저장소에 있는
changelog나
[커밋 목록](https://github.com/rails/rails/commits/5-1-stable)을 참고해주세요.

--------------------------------------------------------------------------------

Rails 5.1로 업그레이드하기
----------------------

기존 애플리케이션을 업그레이드한다면 그 전에 충분한 테스트 커버리지를 확보하는 것이 좋습니다.
애플리케이션이 Rails 5.0으로 업그레이드되지 않았다면 
우선 이를 우선하고, 
애플리케이션이 정상적으로 동작하는지 충분히 확인한 뒤에 Rails 5.1을 올려주세요. 
업그레이드 시의 주의점에 대해서는 
[Ruby on Rails 업그레이드 가이드](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1)
를 참고해주세요.


주요 변경점
--------------

### Yarn 지원

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1은 NPM에서 Yarn을 통해 JavaScript 종속성을 관리 할 수 있습니다.
이렇게하면 React, VueJS 또는 NPM 세계의 다른 라이브러리와 
같은 라이브러리를 쉽게 사용할 수 있습니다. 
Yarn 지원은 에셋 파이프라인과 통합되어 모든 종속성이 
Rails 5.1 앱과 원활하게 작동합니다

### 선택적인 웹팩(Webpack) 지원

[Pull Request](https://github.com/rails/rails/pull/27288)

Rails 응용 프로그램은 JavaScript asset bundler인 [Webpack](https://webpack.js.org/)과 
새로운 [Webpacker](https://github.com/rails/webpacker) 젬 사용을보다 쉽게 ​​통합 할 수 있습니다.
Webpack 통합이 가능한 새로운 응용 프로그램을 생성 할 때 
`--webpack` 플래그 사용합니다.

이는 에셋 파이프라인과 완벽하게 호환되며 이미지, 폰트, 사운드 및 기타 자산에 대해 계속 사용할 수 있습니다. 
에셋 파이프라인에 의해 관리되는 일부 JavaScript 코드 및 
Webpack을 통해 처리되는 기타 코드를 가질 수도 있습니다.
이 모든 것은 Yarn에 의해 관리됩니다, default로 활성화되어 있습니다.

### jQuery는 더이상 기본 의존성이 아닙니다

[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery는 이전 버전의 Rails에서 `data-remote`,`data-confirm` 및 
기타 Rails의 겸손한 JavaScript 제공과 같은 기능을 제공하기 위해 
기본적으로 필요했습니다. 하지만 더이상 요구되지 않는다,
plain, vanilla JavaScript를 사용하기 위해 UJS가 재작성 되었기 때문이다 
이 코드는 이제 Action View 내부에서 `rails-ujs`로 제공된다.

필요한다면 jquery를 사용해도 되지만, 이것은 더이상 default로 요구되지 않는다.

### 시스템 테스트

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1은 Capybara 테스트를 시스템 테스트의 형태로 작성하기 위해 내장된 지원을 제공한다. 
해당 테스트를 위한 Capybara와 데이터베이스 정리 전략을 구성하는 거에 대해서 
더이상 걱정하지 않아도 된다. 
Rails 5.1은 크롬에서 실패 테스트 스크린 샷과 같은 추가 기능을 사용하여 
테스트를 실행하는 래퍼를 제공한다.

### 암호화된 보안들

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails는 이제[sekrets](https://github.com/ahoward/sekrets) gem에서 영감을 얻은 안전한 방법으로 애플리케이션 비밀 정보를 관리 할 수 있다.
새로운 보안 비밀 파일을 설치하기 위해 `bin/rails secrets:setup`를 실행한다. 

이것은 또한 저장소 외부에 저장되어야하는 
마스터 키를 생성한다. 
비밀 자체는 암호화 된 형식으로 변경 관리 
시스템에 안전하게 체크인 할 수 있다.

비밀은 `RAILS_MASTER_KEY` 환경 변수 또는 키 파일에 저장된 키를 사용하여 
프로덕션에서 암호 해독된다.

### 매개변수화된 mailers

[Pull Request](https://github.com/rails/rails/pull/27825)

인스턴스 변수, 헤더 및 기타 공통 설정을 공유하기 위해 mailer 클래스의 모든 메서드에 사용되는 공통 매개 변수를 지정할 수 있다.


``` ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end
end

InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Direct & resolved routes

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1에서는 DSL를 라우팅하기 위해서 `resolve` 와 `direct` 두개의 메서드를 추가했다.
`resolve`메서드를 사용하면 모델의 다형성 매핑을 사용자 정의 할 수 있다.

``` ruby
resource :basket

resolve("Basket") { [:basket] }
```

``` erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

이것은 보통의 `/baskets/:id` 대신하여. 단일 URL `/basket`을 생성한다.

`direct`메서드는 커스텀 URL 헬퍼를 생성한다.

``` ruby
direct(:homepage) { "http://www.rubyonrails.org" }

>> homepage_url
=> "http://www.rubyonrails.org"
```

블록의 반환값은 `url_for` 메서드의 유효한 인자여야 합니다. 
따라서 유효한 문자열 URL, 해시, 배열, Active Model 인스턴스 
또는 Active Model 클래스를 전달할 수 있습니다.

``` ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### form_for 및 form_tag를 form_with로 통합

[Pull Request](https://github.com/rails/rails/pull/26976)

Rails 5.1 이전 버전에서는, HTML 양식 처리에 모델 인스턴스에 대한 `form_for`와 
커스텀 URL에 대한 `form_tag` 이렇게  두 개의 인터페이스가 있었습니다.

Rails 5.1 에서는 두 개의  인터페이스를 `form_with`로 결합하고,
스코프 혹은 모델에 기반하여 폼 태그를 생성할 수 있습니다.

URL만 사용하기:

``` erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Will generate %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

scope를 추가하면 입력 필드 이름에 접두어가 붙음:

``` erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Will generate %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

모델을 사용하면 URL과 scope를 모두 추론:

``` erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Will generate %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

존재하는 모델은 업데이트 양식을 만들고 필드 값을 채움:

``` erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Will generate %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<the title of the post>">
</form>
```

비호환성
-----------------

다음 변경에 대해서는 업그레이드 전에 대응을 해야합니다.

### 다중 연결을 사용한 Transactional tests

Transactional test들은 데이터베이스 transaction에서 
모든 Active Record 연결을 완료했습니다.

테스트가 추가적인 스레드를 생성할 때, 그리고 이런 스레드들이 데이터베이스 
연결될 때의 연결들은 이제 특별하게 처리됩니다:

이 스레드들은 Managed Transaction 내에 있는 하나의 연결을 공유할 것입니다.
모든 스레드들이 가장 바깥 쪽의 transaction을 무시하면서, 
동일한 상태의 데이터베이스를 볼 수 있도록 보장해줍니다.
이전에, 이러한 추가적인 연결들은 고정 줄로 보는 것이 불가능했습니다, 예를 들면.

스레드가 중첩된 transaction에 들어갈 때, 독립을 유지하기 위해, 
일시적으로 연결의 독점적인 사용을 얻을것입니다.

테스트가 생성된 스레드에서 별도의 transaction 
외부 연결을 얻는 데 의존하는 경우,
보다 명확한 연결 관리자로 전환할 필요가 있습니다.

당신의 테스트에서 스레드를 생성하고 이 스레드들이 명시적 데이터베이스 transaction을 사용하면서 
상호 작용하는 경우, 이 변화로 데드락이 발생할 수 있습니다.

이런 새로운 동작을 거부하는 쉬운 방법은 영향을 미치는 모든 테스트 케이스에서 
transaction test를 비활성화하는 것입니다.

Railties
--------

자세한 변경사항은 [Changelog][railties] 를 참조해 주세요.

### 제거된 것들

*   제거 예정이었던 `config.static_cache_control`이 제거.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   제거 예정이었던 `config.serve_static_files`이 제거.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   제거 예정이었던 파일 `rails/rack/debugger`이 제거.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   제거 예정이었던 태스크들 : `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` 그리고 `rails:update:bin` 이 제거.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   제거 예정이었던 `routes` 태스크에 대한 `CONTROLLER` 환경 변수가 제거.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   `rails new` 명령에서 -j(--javascript) 옵션을 제거.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### 주요 변경점

*   모든 환경에 로드되어지는 `config/secrets.yml`에 
공유 섹션을 추가
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   `config/secrets.yml` 설정 파일은 이제 심벌로서 모든 키들과 함께 로드됨.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   기본 스택에서 jquery-rails를 제거함. 
Action View와 함께 제공되는 rails-ujs는 기본 UJS 어댑터로 포함.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   yarn binstub과  package.json. 으로 새로운 앱에서 Yarn 지원을 추가. 
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   새로운 앱에서 rails/webpacker gem 
에게 위임하게 되는 옵션인 `--webpack`을 통해 Webpack 지원을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   새로운 앱 생성 시, 만약 `--skip-git` 
옵션이라면 Git 저장소를 초기화하는 것은 제공되지 않음.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   `config/secrets.yml.enc`에 암호화 된 기밀들을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   `rails initializers`에서 railtie 클래스 명을 보여줌.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

자세한 변경사항은 [Changelog][action-cable] 을 참조하세요.

### 주요 변경점

*   여러 애플리케이션에서 동일한 Redis 서버를 실행할 때, 
이름 충돌을 피하기 위해 `cable.yml`의 Redis와 이벤트 
발생 Redis어댑터에 `channel_prefix`지원을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   양방향성 데이터를 위해 `ActiveSupport::Notifications`훅을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

자세한 변경사항은 [Changelog][action-pack] 을 참조하세요.

### 제거된 것들

*   `ActionDispatch::IntegrationTest`와 `ActionController::TestCase`클래스에 속한
    `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete` 그리고 `#head`의 
    non-keyword인자들의 지원을 제거.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   제거 예정이었던 `ActionDispatch::Callbacks.to_prepare`과 
`ActionDispatch::Callbacks.to_cleanup`을 제거.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   제거 예정이었던 컨트롤러 필터와 연관된 메서드들을 제거.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

### 제거 예정

*   `config.action_controller.raise_on_unfiltered_parameters`가 제거 예정.
    Rails 5.1에선 더이상 효과가 없습니다.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### 주요 변경점

*   DSL 라우팅을 위한 `direct`와 `resolve` 메서드를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   당신의 애플리케이션에 시스템 테스트를 작성하기 위해 새로운 클래스 `ActionDispatch::SystemTestCase`
    를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

자세한 변경사항은 [Changelog][action-view]를 참조하세요.

### 제거된 것들

*   제거 예정이었던 `ActionView::Template::Error` 의 `#original_exception`이 제거.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   `strip_tags`의 잘못된 명칭 `encode_special_chars`옵션을 제거.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### 제거 예정

*   Erubis ERB 핸들러 제거 예정 앞으로는 Erubi를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### 주요 변경점

*   이제 순수한 템플릿 핸들러(기본 Rails 5의 템플릿 핸들러)는 
HTML-safe 문자열들을 출력.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   `datatime-local`필드를 생성하기 위해 
`datetime_field`와 `datetime_field_tag`를 변경.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

*   HTML 태그들(`tag.div`, `tag.br`, etc.)를 위한 새로운 Builder-style 문법.
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   `form_tag`와 `form_for`사용법을 통일하기위한 `form_with` 추가.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   `current_page?`를 위한 `check_parameters`옵션 추가.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

자세한 변경사항은 [Changelog][action-mailer]를 참조하세요.

### 주요 변경점

*   첨부 파일이 포함되고 본문이 인라인으로 설정된 경우 
사용자 지정 콘텐츠 형식을 사용.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   `default`메서드에 값으로 lambdas를 전달하는 것을 허용.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   다른 메일러 액션 사이의 필터 및 default보다 먼저 공유를 위해 메일러 호출의 
    매개변수화 지원을 추가.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   메일러 액션에 들어오는 인자들을 `args`키 아래의
`process.action_mailer`이벤트로 전달.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

자세한 변경사항은[Changelog][active-record]를 참고해주세요.

### 제거된 것들

*   인자들과 블록을 동시에 
`ActiveRecord::QueryMethods#select`에 전달하는 지원을 제거.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   제거 예정이었던  i18n스코프에서 `activerecord.errors.messages.restrict_dependent_destroy.one`과 
`activerecord.errors.messages.restrict_dependent_destroy.many`가 제거.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   제거 예정이었던 singular인자 와 collection association readers인자를 강제로 불러오는것을 제거.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   제거 예정이었던 컬럼을 `#quote`로 전달하는 지원을 제거.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   제거 예정이었던 `#tables`로부터 `name` 인자를 제거.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   제거 예정이었던 테이블과 뷰를 반환하는 
`#tables`와 `#table_exists?` 의 행동을 테이블만 반환하고 뷰는 반환하지 않기위해 제거.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   제거 예정이었던 `ActiveRecord::StatementInvalid#initialize`와 `ActiveRecord::StatementInvalid#original_exception`
    안의 `original_exception`인자를 제거.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   제거 예정이었던 질의 내에 변수를 클래스로 전달하는 지원을 제거.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   제거 예정이었던 LIMIT에서 쉼표를 사용하여 질의하는 지원을 제거.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   제거 예정이었던 `#destroy_all`의 `conditions`매개변수를 제거.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   제거 예정이었던 `#delete_all`의 `conditions`매개변수를 제거.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   제거 예정이었던 `#load_schema_for`메서드를 제거하고 앞으로는 `#load_schema`을 사용.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   제거 예정이었던 `#raise_in_transactional_callbacks`구성을 제거.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   제거 예정이었던 `#use_transactional_fixtures`구성을 제거.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### 제거 예정

*   `error_on_ignored_order_or_limit`가 제거 예정 앞으로는 
`error_on_ignored_order`를 사용.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   `sanitize_conditions`가 제거 예정 앞으로는 `sanitize_sql`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   `supports_migrations?`에 연결된 어탭터는 제거 예정
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   `Migrator.schema_migrations_table_name`는 제거 예정, 대신에`SchemaMigration.table_name`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   인용 및 타입캐스팅에서 `#quoted_id`사용을 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   `#index_name_exists?`의 `default`인자는 제거 예정.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### 주요 변경점

*   Default Primary 키를 BIGINT로 바꿈
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   MySQL 5.7.5+ 과 MariaDB 5.2.0+는 가상/생성 컬럼을 지원.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   일괄 처리의 한도에 대한 지원이 추가.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Transactional tests는 이제 모든 
Active Record connections를 데이터베이스 transactions로 감싼다.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   `mysqldump`의 기본적인 명령어의 출력에 대한 주석을 스킵.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   전달된 블록을 자동으로 무시하는 대신 인자로 전달될 때 레코더를 카운트하기 위한 
    루비의 `Enumerable#count`사용을 위해 
    `ActiveRecord::Relation#count` 를 수정.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   SQL 에러를 억제하지 않도록 `psql`명령어를 `"-v ON_ERROR_STOP=1"`플래그와 전달.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   `ActiveRecord::Base.connection_pool.stat` 추가.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   `ActiveRecord::Migration`으로부터 직접 상속하면 에러가 발생, 마이그레이션이 
    작성된 레일즈 버전을 지정할것.
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   `through`관계가 모호하게 반영된 이름을 가졌을 때 에러가 발생.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

자세한 변경사항은[Changelog][active-model]를 참고해주세요.

### 제거된 것들

*   `ActiveModel::Errors`에 제거 예정이었던 메서드 제거.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   제거 예정이었던 길이 검사 `:tokenizer`옵션이 제거.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   제거 예정이었던 반환 값이 false 일 때 콜백을 중지시키는 동작을 제거.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 주요 변경점

*   모델 속성에 할당 된 컬렉션 문자열이 
더 이상 잘못 고정되지 않습니다.
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

자세한 변경사항은[Changelog][active-job]를 참고해주세요.

### 제거된 것들

*   제거 예정이었던 어댑터 클래스를 `.queue_adapter`에 넘기는 지원을 제거.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   제거 예정이었던`ActiveJob::DeserializationError`안에 `#original_exception` 제거.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### 주요 변경점

*   `ActiveJob::Base.retry_on`와 `ActiveJob::Base.discard_on`을 경유한 선언적 예외 핸들링을 추가.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   재시도들이 실패한 후 사용자 로직의 `job.arguments`같은 것들에 액세스 하기 위해
    인스턴스를 얻을것.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

자세한 변경사항은[Changelog][active-support]를 참고해주세요.

### 제거된 것들

*   `ActiveSupport::Concurrency::Latch`클래스는 제거.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   `halt_callback_chains_on_return_false`는 제거.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   제거 예정이었던 반환 값이 false 일 때 콜백을 중지시키는 동작을 제거.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### 제거 예정

*   최상위 클래스 `HashWithIndifferentAccess`가 부드럽게 제거 예정 앞으로는
    `ActiveSupport::HashWithIndifferentAccess`를 사용.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   문자열을 `set_callback`과 `skip_callback`상의 `:if`와 `:unless`선택적 옵션에 전달을 제거 예정.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### 주요 변경점

*   DTS 변경들을 통해 일관성있게 만들기 위해 Duration 파싱과 트래벌링을 수정.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   유니코드 버전을 9.0.0으로 업데이트 됨.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Duration#before과 #after를 #ago와 #since의 별칭으로 추가.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   현재 객체에 대해 정의되지 않은 메서드호출을 프록시 객체에 위임하기 위해
    `Module#delegate_missing_to`를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   `Date#all_day`는 현재 날짜와 시간의 전체 날짜를 
나타내는 범위를 반환하는 메소드를 추가.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   `assert_changes` 과 `assert_no_changes` 메서드는 test에 도입.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   `travel`과 `travel_to`메서드는 중첩 가능.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   `DateTime#change`는 usec와 nsec를 지원.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

크레딧 표기
-----------

Rails를 견고하고 안정적인 프레임워크로 
만들기 위해 많은 시간을 사용해주신 많은 
개발자들에 대해서는 [Rails 기여자 목록](http://contributors.rubyonrails.org/)을 참고해주세요. 
이 분들에게 경의를 표합니다.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
