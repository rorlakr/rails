


Ruby on Rails에 기여하기
=============================

이 가이드에서는 Ruby on Rails의 개발에 참여하는 방법에 대해서 설명합니다.

이 가이드의 내용:

* GitHub에서 issue를 보고하는 방법
* 마스터를 clone하여 테스트를 실행하는 방법
* 기존의 issue를 해결하는 방법
* Ruby on Rails의 문서에 기여하는 방법
* Ruby on Rails의 코드에 기여하는 방법

Ruby on Rails는 '어딘가에서 누군가가 잘 만들어주는 프레임워크'가 아닙니다. Ruby on Rails는 긴 시간에 걸쳐서 수백명의 사람들이 귀중한 기여를 받았습니다. 그 내용은 단 한 글자의 수정부터, 대규모의 아키텍쳐 변경, 중요한 문서 작성까지 다양한 영역에 걸쳐 있습니다. 그 노력은 모두 Ruby on rails를 모두에게 더 좋은 것으로 만드는 것을 목표로 하고 있습니다. 코드를 쓰거나, 문서를 작성하지 않더라도 issue를 보고하거나, 버그를 테스트하는 등, 다양한 방법으로 기여할 수 있습니다(역주: **샘플의 몇몇 문장들은 번역되어 있습니다만, 실제로는 영어를 사용해주세요**)

--------------------------------------------------------------------------------

issue 보고하기
------------------

Ruby on Rails에서는 [GitHub의 Issue 추적](https://github.com/rails/rails/issues) 기능을 사용하여 issue를 관리하고 있습니다. 주로 버그나 새로운 코드의 추가할 때에 사용됩니다. Ruby on Rails에서 버그를 발견하면, 그 시점부터 기여를 시작할 수 있습니다. Github에 issue를 올리거나, 댓걸, 풀 리퀘스트를 만들기 위해서는 우선 GitHub 계정(무료)를 만들 필요가 있습니다.

NOTE: Ruby on Rails의 최신 릴리스에서 발견한 버그는 무척 주목을 받고 있을 가능성이 높습니다. 또한 Rails 코어 팀은 _edge Rails_(그 시점에서 개발중인 Rails 코드)를 테스트해주는 사람들로부터의 피드백을 환영합니다. 테스팅 용으로 edge Rails를 받는 방법에 대해서 이후에 설명합니다.

### 버그 레포트를 작성하기

Ruby on Rails에서 어떤 문제를 발견하고 그것이 보안상의 문제가 아니라면, 우선 Github의 [issue](https://github.com/rails/rails/issues)를 탐색하여 이미 보고되었는지를 확인합시다. 해당하는 문제가 issue에서 발견되지 않는다면 [새로운 issue를 생성](https://github.com/rails/rails/issues/new)합니다. 보안과 관련된 issue를 보고하는 방법에 대해서는 다음 절에서 설명합니다.

issue 보고에는 적어도 제목과 issue에 대한 명쾌한 설명이 필요합니다. 가능한 많은 관련 정보를 포함해 주세요. 또한, 적어도 문제를 재현할 수 있는 코드 샘플을 포함해서 작성해주세요. 기대되는 동작이 이루어지지 않는다는 것을 확인시켜주는 유닛 테스트를 포함해주시면 더욱 좋습니다. 다른 사람들에게도, 자기 자신도 알기 쉽도록 버그의 재현과 의심되는 지점을 설명해주세요.

그리고 issue를 다룰 때에는 과도한 기대는 금물입니다. '지구 멸망' 수준의 중대한 문제가 아닌 이상, 보고된 issue는 다른 issue와 마찬가지로, 해결을 위해서 공동작업을 하게 됩니다. issue 보고가 자동적으로 수정 담당자를 찾아주는 것도 아니며, 다른 개발자가 자신의 작업을 방치하면서 도와주지도 않습니다. issue를 생성한다는 것은 대부분, 자신에게는 문제를 수정하기 위한 시작 지점에 서는 것이며, 다른 개발자에게는 '이쪽도 동일한 문제가 발생하고 있어요'라는 확인, 그리고 덧글을 추가할 수 있는 장소가 생긴 것에 불과합니다.

### 실행가능한 테스트를 만들기

자신의 issue를 재현하는 방법을 준비하는 것은 다른 개발자가 issue를 확인, 조사, 그리고 수정할 때에 무척 도움이 됩니다. 이를 위한 방법으로, 실행 가능한 테스트 케이스를 제공하는 법이 있습니다. 이 작업을 조금이라도 간단하게 만들기 위해서 Rails 팀은 버그 레포트의 템플릿을 여러가지 준비해두고 있습니다. 이를 바탕으로 작업을 시작할 수 있습니다.

* Active Record (모델, 데이터베이스) issue용 템플릿: [gem](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_record_gem.rb) / [master](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_record_master.rb)
* Active Record (마이그레이션) issue용 템플릿: [gem](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_record_migrations_gem.rb) / [master](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_record_migrations_master.rb)
* Action Pack (컨트롤러, 라우팅) issue용 템플릿: [gem](https://github.com/rails/rails/blob/master/guides/bug_report_templates/action_controller_gem.rb) / [master](https://github.com/rails/rails/blob/master/guides/bug_report_templates/action_controller_master.rb)
* Active Job issue용 템플릿: [gem](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_job_gem.rb) / [master](https://github.com/rails/rails/blob/master/guides/bug_report_templates/active_job_master.rb)
* 그 외의 일반적인  issue용 템플릿: [gem](https://github.com/rails/rails/blob/master/guides/bug_report_templates/generic_gem.rb) / [master](https://github.com/rails/rails/blob/master/guides/bug_report_templates/generic_master.rb)

템플릿에는 '보일러플레이트(boilerplate)'라고 불리는 일종의 기본 코드가 포함되어 있으며, 이를 사용해서 Rails의 릴리스 버전(`*_gem.rb`)이나 edge Rails(`*_master.rb`)에 대한 테스트 케이스를 설정할 수 있습니다.

해당하는 템플릿의 내용을 복사하여 `.rb` 파일에 붙여넣은 뒤, 필요한 수정 작업을 하고 issue를 재현가능하도록 만듭니다. 이 코드를 실행하려면 터미널에서 `ruby the_file.rb`를 실행하면 됩니다. 테스트 코드가 올바르게 작성되어 있다면 이 테스트 케이스는 버그가 있으므로 실패할 것입니다.

이어서, 이 실행 가능한 테스트 케이스를 Github의 [gist](https://gist.github.com)으로 공유하거나 issue의 설명에 직접 포함해주세요.

### 보안 issue를 다루는 법에 대해서

WARNING: 보안 취약점에 관련된 문제는 일반 공개되어 있는 Github의 issue 기능을 통해서 '절대로 올리지 말아주세요'. 이와 관련된 issue를 다루는 법에 대해서는 [Rails 보안 정책](http://rubyonrails.org/security)(영어)를 참조해주세요.

### 기능 요청에 대해서

GitHub의 Issue에는 '기능 요청'을 하지 말아주세요. Ruby on rails에 원하는 기능이 있다면, 자신이 직접 코드를 작성해주세요. 또는 다른 사람에게 요청하여 코드를 작성해주세요. Ruby on Rails용의 패치를 제안하는 방법에 대해서는 나중에 설명합니다. 예를 들어, GitHub의 issue에 이러한 '원하는 기능 목록'을 코드도 포함하지 않고 올리게 되면, issue를 확인한 사람에 따라서는 바로 닫아버릴 수도 있습니다.

반면, '버그'와 '기능'의 선긋기가 간단하지 않은 경우도 있습니다. 일반적으로 '기능'은 애플리케이션에 새로운 기능을 추가하는 것이며, '버그'란 기존의 동작이 기대대로 동작하지 않는 경우를 의미합니다. 코어 팀은 필요에 따라서 버그인지 기능인지를 판정하기 위해서 사람들을 모으는 경우도 있습니다. 그렇지만 버그나 기능의 다른 점은 보내진 패치(적용할지 아닐지 보다는) 어느 릴리스에 반영할 지 정도인 경우가 많습니다. 버그 수정은 빨리 릴리스되며, 기능 추가는 큰 릴리스 변경에 반영되는 식입니다. 우리들은 수정 패치와 마찬가지로, 기능 추가도 환영하고 있습니다. 보내주신 기능 추가 패치를 유지보수용 브랜치에 넣어두고 끝, 처럼은 하지 않습니다.

기능 추가 패치를 보내기 전에 자신의 아이디어에 대한 의견이 듣고 싶은 경우에는 [rails-core 메일링 리스트](https://groups.google.com/forum/?fromgroups#!forum/rubyonrails-core)에 메일을 보내주세요. 만약 아무도 답이 없다면, 자신의 아이디어에 아무도 관심이 없다는 것을 알 수 있습니다. 또는 자신의 아이디어에 흥미를 가진 사람이 답장을 해줄지도 모릅니다. 또는 '미안하지만 그 제안은 채용될 것 같지 않다'라는 답장이 올지도 모릅니다. 하지만 이 메일링 리스트는 이러한 아이디어에 대해서 의논하기 위해서 준비된 장소입니다. 반대로 GitHub의 issue는 이러한 새 아이디어를 위해 필요한 논의(때때로는 길어지거나 복잡해지는 경우도 있을 겁니다)를 하기 위한 장소가 아닙니다.


기존의 issue 해결을 돕기
----------------------------------

issue 보고에 이은 다른 기여 방법으로서 코어팀이 기존에 존재하는 issue를 해결할 수 있도록 도울 수 있습니다. GitHub의 issue에 등록되어 있는 [issue](https://github.com/rails/rails/issues)를 보면 사람들의 관심을 끌고 있는 issue가 많습니다. 스스로도 issue에 공헌할 수 있는 방법이 있을까요? 물론 방법이 있습니다. 많이요.

### 버그 레포트의 확인

기본적인 방법으로 버그 리포트를 확인하는 작업도 무척 도움이 됩니다. issue를 자신의 컴퓨터에서 재현할 수 있는지 없는지를 확인해보세요. 문제를 쉽게 재현할 수 있다면 issue의 덧글에 그 사실을 추가합시다.

재현 순서 등에 애매한 점이 있다면, 어떤 부분이 이해하기 어려운지 지적하세요. 버그를 제현하기 위한 유용한 정보를 추가하거나, 필요 없는 부분을 제거하는 것도 중요한 기여입니다.

테스트가 포함되어 있지 않은 버그 리포트가 있다면 이 역시 기여를 할 수 있는 찬스입니다. 버그가 원인으로 실패하는 테스트를 작성하여 기여할 수 있습니다. 테스트를 작성하는 방법은 기존의 테스트 파일을 자세하기 읽으며 배울 수 있습니다. 이것은 Rails의 소스 코드를 읽을 수 있는 기회도 됩니다. 작성한 테스트는 '패치' 형식으로 올려주는 것이 베스트입니다. 자세한 것은 'Rails 코드에 기여하기'에서 설명합니다.

버그 레포트는 아무튼 간결하고, 이해하기 쉽도록, 그리고 가급적 간단하게 상황을 재현할 수 있도록 작성해주세요. 버그를 수정하는 개발자에게 있어서 도움이 되는 것은 이러한 '좋은 버그 레포트'입니다. 버그 레포트를 작성하는 사람이 최종적인 패치를 작성하지 않더라도 잘 작성된 버그 레포트는 좋은 기여가 될 수 있습니다.

### 패치를 테스트하기

GitHub에서 Ruby on Rails에 보내진 풀 리퀘스트(pull request)를 확인해 주는 사람도 도움이 됩니다. 넘어온 수정 사항을 적용하려면 우선 다음과 같이 전용 브런치를 만들어주세요.

```bash
$ git checkout -b testing_branch
```

이어서 원격 브런치를 사용해서 로컬의 코드를 갱신합니다. 예를 들어 GitHub 사용자인 JohnSmith가 fork하여 https://github.com/JohnSmith/rails의 "orange"라는 토픽 브랜치에 push를 했다고 가정합시다.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

브런치를 적용한 뒤에 테스트를 해봅시다. 다음과 같은 부분을 주의하면서 진행하세요.

* 수정 사항이 유효한지.
* 이 테스트를 만족하는지. 어떤 것이 테스트되고 있는지 이해할 수 있는지. 부족한 부분은 없는지.
* 문서에 적절한 정보가 있는지. 문서 업데이트가 필요한지.
* 구현이 즐거운지. 같은 변경을 최적화하거나, 더 좋은 방법으로 고칠 수 있을지.

풀 리퀘스트에 포함되어 있는 변경 사항이 문제 없다고 생각했다면, GitHub의 issue에 찬성을 의미하는 덧글를 추가해주세요. 추가한 덧글에는 우선 변경 사항에 찬성하고 있다는 것을 알리며, 가급적 구체적으로 어떤 부분이 좋다고 생각했는지를 설명합시다. 예를 들자면 다음과 같은 식입니다.

>I like the way you've restructured that code in generate_finder_sql - much nicer. (generate_finder_sql의 코드가 무척 좋은 모습으로 재구성되어 있는 점이 좋다고 생각합니다).The tests look good too. (테스트 역시 좋습니다).

단순히 '+1'만을 덧글에 남기는 것만으로는 다른 리뷰어들은 신경써주지 않을 것입니다. 덧글을 작성하는 사람이 충분히 시간을 들여서 풀 리퀘스트를 읽었다는 점이 다른 사람들에게 전달되도록 작성하세요.

Rails의 문서에 기여하기
---------------------------------------

Ruby on Rails에는 2 종류의 문서가 있습니다. 하나는 이 가이드이며, Ruby on Rails를 배우기 위한 것입니다. 그리고 또 하나는 API 문서이며 이쪽은 레퍼런스용입니다.

누구라도 Rails 가이드에 기여할 수 있습니다. Rails 가이드에 요구되는 개선 사항은 '일관될 것', '모순이 없을 것', '읽기 쉬울 것', '정보의 추가', '사실과 다른 부분을 수정', '오타 수정', '최신 edge Rails를 반영할것' 등입니다.

[Rails](https://github.com/rails/rails)에 풀 리퀘스트를 보내거나 정기적으로 기여를 하고 싶다면 [Rails 코어 팀](http://rubyonrails.org/community/#core)에게 
docrails에 대한 커밋 권한을 요청해도 좋습니다. 단 docrails에 직접 풀 리퀘스트를 보내지 말아주세요. 자신이 작성한 변경사항에 의견을 묻고 싶은 경우에는 [Rails](https://github.com/rails/rails)에서 부탁드립니다.

docrails는 정기적으로 master에 병합되므로 Ruby on Rails 문서의 편집을 효율적으로 수행할 수 있습니다.

문서의 변경 내용에 대해서 불명확한 점이 있는 경우에는 GitHub의 [Rails](https://github.com/rails/rails/issues)에서 issue를 생성해주세요.

문서에 기여하고 싶은 경우에는 [API 문서 작성 가이드라인](api_documentation_guidelines.html)과 [Rails 가이드 작성 가이드라인](ruby_on_rails_guides_guidelines.html)을 잘 읽어 주세요.

NOTE: 앞에서 말했듯이, 코드에 패치를 하는 경우에는 문서도 그에 맞추어서 변경되어야 할 필요가 있습니다. docrails는 코딩으로부터 독립된 문서 변경만을 목적으로 하고 있습니다.

NOTE: Rails의 CI (지속적 통합: Continuous Integration) 서버에 대한 부하를 줄이기 위해서, 문서 관련 커밋 메시지는 [ci skip]으로 만들어주세요. 이를 통해 문서 관련 커밋시에 빌드를 하지 않고 넘어갈 수 있습니다. [ci skip]는 '문서만을 변경'하는 경우가 아니라면 사용해서는 안됩니다. 코드 변경시에는 절대로 사용하지 말아주세요.

WARNING: docrails에는 다음의 엄격한 정책에 따르고 있습니다. 'docrails의 코드는 한 글자라도 변경하지 않을 것', 'docrails에서 변경해도 좋은 것은 RDoc과 가이드 뿐', 'docrails의 changelog도 절대로 변경하지 않을 것' 입니다.

Rails 가이드 번역하기
------------------------

Rails 가이드를 각 언어들로 번역해주는 분들이 계신다는 점에 무척 감사하고 있습니다.
만약 다른 언어로 Rails 가이드를 번역하길 바란다면, 다음의 순서를 밟아주세요.

* 프로젝트를 fork 합니다(rails/rails).
* 그 언어를 위한 소스 폴더를 만들어 주세요. 예를 들자면, 이탈리아 어를 위해서 *guides/source/it-IT* 폴더를 추가합니다.
* *guides/source*를 복사해서 그 언어의 폴더에 넣은 뒤, 그것들을 번역해주세요.
* HTML 파일들은 자동적으로 생성되기 때문에, 번역하지 마세요.

가이드를 HTML 형식으로 생성하기 위해서는 *guides*에 들어가서 다음을 실행합니다(it-IT로 예를 듭니다).

```bash
$ bundle install
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

이는 *output*에 가이드를 생성합니다.

NOTE: 이 설명은 Rails 4 이상을 위한 것입니다. 그리고 Redcarpet gem은 JRuby에서 동작하지 않는다는 점을 주의해주세요.

현재 알려진 번역은 다음과 같습니다(버전은 서로 다를 수 있습니다):

* **Italian**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Spanish**: [http://wiki.github.com/gramos/docrails](http://wiki.github.com/gramos/docrails)
* **Polish**: [https://github.com/apohllo/docrails/tree/master](https://github.com/apohllo/docrails/tree/master)
* **French** : [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Czech** : [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turkish** : [https://github.com/ujk/docrails/tree/master](https://github.com/ujk/docrails/tree/master)
* **Korean** : [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Simplified Chinese** : [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Traditional Chinese** : [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Russian** : [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japanese** : [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)

Rails 코드에 기여하기
------------------------------

### development 환경을 구축하기

버그 리포트를 보내서 알려진 문제점 해결을 돕거나, 코드를 작성해서 Ruby on Rails에 공헌하기 위해서는 우선 테스트를 실행 가능한 환경을 만들 필요가 있습니다. 여기에서는 자신의 컴퓨터에서 테스트 환경을 구축하는 방법에 대해서 설명합니다.

#### 추천하는 방법

[Rails development box](https://github.com/rails/rails-dev-box)에 있는 development 환경을 사용하는 것을 추천합니다.

#### 귀찮은 방법

Rails development box를 사용할 수 없는 상황이라면 Rails 가이드의 [Rails 코어 개발 환경 구축 방법](development_dependencies_install.html)을 참고해주세요.

### Rails 저장소를 복사하기

코드에 공헌하기 위해서는 우선 Rails 저장소를 복사하는 것부터 시작해야합니다.

```bash
$ git clone https://github.com/rails/rails.git
```

이어서 별도의 브랜치를 만듭니다.

```bash
$ cd rails
$ git checkout -b my_new_branch
```

이 브랜치의 이름은 로컬에 있는 자신의 저장소에서만 사용되므로 어떤 이름이든 상관 없습니다. 이 이름이 Rails Git 저장소에 올라갈 일은 없습니다.

### Bundle install

필요한 gem을 설치합니다.

```bash
$ bundle install
```

### 로컬 브랜치에서 애플리케이션을 실행하기

더미 Rails 애플리케이션에서 변경을 테스트해야하는 경우에는 `rails new`에 `--dev` 플래그를 추가하면, 로컬 브랜치를 사용하는 애플리케이션이 생성됩니다.

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

`~/my-test-app`에 생성된 애플리케이션은 로컬 브랜치의 코드를 실행합니다. 서버를 재실행하면 설정의 변경사항을 애플리케이션에서 확인할 수 있습니다.

### 코드 작성하기

준비가 되었으므로, 바로 코드를 추가/수정해봅시다. 현재의 Git 브랜치에서는 어떤 코드를 작성해도 좋습니다(혹시 모를 상황을 위해 `git branch -a`를 실행해서 올바른 브랜치인지를 확인하세요). 자신의 코드를 Rails에 추가하는 경우, 다음을 주의해주세요.

* 올바른 코드를 작성할 것.
* Rails로 모두가 사용하고 있는 관례나 헬퍼 메소드를 사용할 것.
* 테스트를 작성할 것. 자신의 코드가 없으면 실패하고, 아니면 성공하는 테스트일 것.
* 관련하는 문서, 실행 예, 가이드 등, 코드가 영향을 주는 부분은 모두 갱신할 것.


TIP: 표면적인 부분에 머무르는 변경이나, Rails의 안정성/기능성/테스트의 편의성 등 근본적인 부분을 개량하지 않는 변경은 받아들여지지 않습니다. 자세한 설명은 [이러한 결정을 내린 이유](https://github.com/rails/rails/pull/13771#issuecomment-32746700) (영어)를 참조해주세요.

#### Rails 코딩 규칙을 따르기

Rails에서 코딩을 하는 경우에는 다음의 간단한 스타일 가이드를 따라주세요.

* 들여쓰기에는 공백 문자 2개를 사용할 것. 탭 문자는 쓰지 않을 것.
* 행의 마지막에는 공백을 쓰지 않을 것. 빈 행에도 공백을 쓰지 않을 것.
* private나 protected의 뒤는 들여쓰기를 할 것.
* 해시는 Ruby 1.9 이후의 방식으로 사용할 것. 다시 말해 '`{ :a => :b }`' 보다 '`{ a: :b }`'를 사용할 것.
* '`and`/`or`'보다도 '`&&`/`||`'를 권장.
* 클래스 메소드는 'self.method'보다 'class << self'를 권장.
* 인수 작성시에는 괄호+공백 문자'`my_method( my_arg )`'나 괄호 없이 '`my_method my_arg`'쓰지 않고, 공백 없는 괄호 '`my_method(my_arg)`'를 사용할 것.
* 부호의 전후에 공백을 둘 것. '`a=b`'가 아닌 '`a = b`'를 사용할 것.
* refute가 아닌 assert_not을 사용할 것.
* 한줄 블럭은 공백 없이 '`method{do_stuff}`'보다 공백이 있는 '`method { do_stuff }`'를 사용할 것.
* 그 외에도 Rails 코드에 있는 기존의 방식을 따를 것.

이는 어디까지 가이드라인이며, 가장 좋은 사용 방법에 대해서는 각자 판단해주세요.

### 벤치마킹하기

성능에 영향이 있는 변경인 경우에는 코드를 벤치마킹하고 그 영향을 측정해주세요.
결과와 함께 벤치마크에 사용한 스크립트를 공유해주세요. 미래의 기여자들이 쉽게
이에 대한 정보를 얻을 수 있도록 커밋 메시지에는 이 정보를 반드시 포함해주세요.
(예를 들어, 미래의 Ruby VM 최적화 덕분에 해당 최적화가 없어질지도 모릅니다.)

생각하고 있는 특정 시나리오에 대한 성능을 향상시키는 최적화를 만드는 것은
무척 쉽지만, 일반적인 경우에 대해서는 그렇지 않을 수 있습니다. 그러므로
대표적인 시나리오들에 대해서 테스트를 해야합니다. 이상적으로는 실제 환경에서
있었던 실제 시나리오를 기반으로 하는 것이 좋습니다.

[벤치마칭 템플릿](https://github.com/rails/rails/blob/master/guides/bug_report_templates/benchmark.rb)으로부터
시작하는 것도 좋습니다. 이는 [benchmark-ips](https://github.com/evanphx/benchmark-ips) 젬을
사용하는 벤치마킹 코드의 간단한 구현이 포함되어 있습니다. 이 템플릿은
스크립트에 변경 사항을 추가하여 테스트할 수 있도록 디자인되어 있습니다.

### 테스트 실행하기

Rails에서는 변경을 올릴 때마다 모든 테스트를 전부 실행해야한다는 관례가 있는
것은 아닙니다. 추천하는 작업 순서는 [rails-dev-box](https://github.com/rails/rails-dev-box)에서
설명했듯이 railites의 테스트가 특히 시간이 걸리며, 소스코드를 `/vagrant`에
마운트 시키면 더욱 그렇습니다.

현실적인 타협안으로서 작성한 코드에 의해 영향이 발생하는지 아닌지를 테스트해주세요. 그리고 변경이 railties에서 발생한 것이 아니라면, 영향을 받는 컴포넌트의 모든 테스트를 실행해주세요. 테스트를 모두 통과한다면 이 패치를 제안할 준비가 완료됩니다. Rails에서는 다른 장소에서 발생할지 모를 예상외의 에러가 발생하는 것을 검출하기 위해 [Travis CI](https://travis-ci.org/rails/rails)를 사용하고 있습니다.

#### Rails 전체의 테스트 실행하기

모든 테스트를 실행하는 방법은 다음과 같습니다.

```bash
$ cd rails
$ bundle exec rake test
```

#### 특정 컴포넌트의 테스트를 실행하기

Action Pack 등, 특정 컴포넌트만의 테스트를 하고 싶은 경우가 있습니다. 예를 들어, Action Mailer를 테스트하고 싶은 경우에는 다음을 실행합니다.

```bash
$ cd actionmailer
$ bundle exec rake test
```

#### 단일 테스트 실행하기

Ruby에서 단일 테스트를 실행할 때가 있습니다. 예를 들어, 다음과 같은 식입니다.

```bash
$ cd actionmailer
$ ruby -w -Itest test/mail_layout_test.rb -n test_explicit_class_layout
```

`-n` 옵션을 사용하면 파일 전체가 아닌 지정한 단일 메소드만을 실행합니다.


#### Active Record를 테스트하기

우선 필요한 데이터베이스를 준비합니다. MySQL이나 PostgreSQL을 사용한다면 SQL문 '`create database activerecord_unittest`'과 '`create database activerecord_unittest2`'로 충분합니다. SQLite3의 경우에는 필요없습니다.

SQLite3만 Active Record 테스트를 실행하려면 다음과 같습니다.

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

이것으로 `sqlite3`에서 테스트를 실행할 수 있게 됩니다. 각각에 대한 태스크는 다음과 같습니다.

```bash
test:mysql2
test:postgresql
```

마지막으로 다음을 실행하세요.

```bash
$ bundle exec rake test
```

이걸로 3개가 순서대로 실행됩니다.

단일 테스트를 각각 실행할 수도 있습니다.

```bash
$ ARCONN=sqlite3 ruby -Itest test/cases/associations/has_many_associations_test.rb
```

하나의 테스트를 모든 어댑터에 대해서 실행하려면 이렇게 작성하세요.

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

이것으로 `test_jdbcmysql`, `test_jdbcsqlite3`, `test_jdbcpostgresql`가 호출됩니다. 특정 데이터베이스 테스트에 초점을 맞추는 방법에 대해서는 `activerecord/RUNNING_UNIT_TESTS.rdoc`를 참고해주세요. CI(Continuous Integration) 서버에서 테스트를 실행하는 방법에 대해서는 `ci/travis.rb`를 참조해주세요.

### 경고

테스트 셋의 실행에는 경고 표시가 켜집니다. Ruby on rails의 테스트에서 경고가 하나도 발생하지 않는 것이 이상적입니다만, 서드 파티의 경고를 포함하여 약간의 경고가 발생하는 경우가 있습니다. 무시하는 것도 한가지 방법입니다만, 가급적 수정해주시면 감사하겠습니다. 그리고 가능하다면 새로운 경고가 발생하지 않도록 패치를 보내주시면 좋겠습니다.

출력을 보기 좋게 만들기 위해서 플래그를 덮어쓸 수도 있습니다(단, 옵션의 의미를 잘 이해하고 있을 경우에 한정합니다만).
ただしオプションの意味を十分理解したうえでですが)。

```bash
$ RUBYOPT=-W0 bundle exec rake test
```

### CHANGELOG 갱신하기

CHANGELOG는 모든 릴리스에서 중요한 위치를 차지하고 있습니다. Rails의 각 버전의 변경점을 여기에 기록합니다.

기능의 추가나 삭제, 버그 수정, Deprecated 통지의 추가를 하면, 반드시 수정한 프레임워크의 CHANGELOG의 **앞 부분에** 추가해주세요. 리팩토링이나 문서 변경인 경우에는 CHANGELOG를 변경하지 말아주세요.

CHANGELOG의 항목에는 변경 내용을 적확하게 요약한 내용을 기입하고, 마지막에 작성자의 이름을 적습니다. 필요하다면 여러줄에 걸쳐서 기입하거나, 공백문자 4개의 들여쓰기를 사용하는 코드 예제를 추가해도 좋습니다. 변경이 특정 issue와 관련있는 경우에는 issue 번호도 추가해주세요. 다음은 CHANGELOG 항목의 예제입니다(**주의: 실제 작성은 영어로 해야합니다**).

```
*  (변경 내용을 요약합니다)(여러줄에 걸쳐서 작성하는
    경우에는 80자마다 개행합니다)(필요에 따라서 들여쓰기를 포함한 코드를 추가할 수 있습니다)

        class Foo
          def bar
            puts 'baz'
          end
        end

    （코드 예제 뒤에 이어서 설명을 추가할 수 있습니다. issue 번호는 여기에 적습니다) GH#1234

    *자신의 이름*
```

코드의 예제나 여러줄로 구성된 항목을 사용하지 않는 경우, 이름은 항목의 가장 마지막에 추가하여 한줄로 정리해주세요. 그 이외의 경우에는 마지막 줄에 이름을 추가해주세요.

### Gemfile.lock 갱신하기

변경 내용에 따라서는 의존 관계도 업데이트해야하는 경우가 있습니다. 이러한 경우에는 `bundle update`를 실행해서 올바른 의존관계를 버전에 반영하고 변경된 `Gemfile.lock` 파일을 커밋해주세요.

### 건전성 체크

코드를 확인한 사람이 자신 밖에 없는 코드를 제출하는 것은 좋지 않습니다. 주변에 Rails를 사용하는 사람이 있는 경우, 제출 전에 코드 리뷰를 부탁해봅시다. 주변에 Rails를 사용하는 사람이 없다면, IRC나 rails-core 메일링 리스트에 문의해주세요. 패치를 제출하기 전에 그 코드를 확인하는 것을 패치의 '스모크 테스트'라고 부릅니다. 작성한 코드를 다른 개발자가 보았을 때 좋다고 느끼지 않는다면 Rails 코어 팀에서도 분명 같은 생각을 가질 것입니다.

### 변경을 커밋하기

자신의 PC에서 코드가 만족할 만한 수준으로 동작한다면 이 변경사항을 Git에 커밋합니다.

```bash
$ git commit -a
```

이를 통해 커밋 메시지를 작성하기 위한 에디터가 열립니다. 메시지를 작성하고 저장한 뒤에 계속 진행합시다.

커밋 메시지 서식을 올바르게 갖추고, 알기 쉽게 기술하면 다른 사람들이 변경 내용을 이해할 때에 큰 도움이 됩니다. 커밋 메시지는 충분히 시간을 들여서 작성해주세요.

좋은 커밋 메시지는 다음과 같은 느낌입니다.

```
짧은 요약문(50글자 이하가 이상적)

물론 필요하다면 좀 더 자세하게 작성해도 좋습니다. 메시지는 72번째 글자에서 개행해주세요. 메시지는 가급적 자세하게 적으세요. 커밋 내용이 명백해보이더라도, 다른 사람에게도 그럴 것이라고 단정지을 수는 없습니다. 관계된 issue에서 언급되어 있는 내용을 모두 추가하고, 이력을 찾아보지 않아도 좋도록 해야합니다.

작성할 때에는 여러 절로 나누어도 좋습니다.

코드의 예제를 포함하는 경우에는 4개의 공백 문자를 사용해서 들여쓰기 해주세요.

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

각 항목별로 작성할 수도 있습니다.

- (-) 또는 별표(*)로 시작합니다.

- 행은 72번 글자에서 개행하고, 읽기 쉽도록 그 다음부터는
  앞에 공백 문자를 2개 써서 들여쓰기 해주세요.
```

TIP: 커밋이 여러개로 나뉘어져 있는 경우에는 반드시 하나의 커밋으로 합쳐주세요. 이를 통해서 나중에 cherry-pick을 하기 쉬워지며, Git 로그도 보기 쉽게 됩니다.

### 브랜치 업데이트하기

로컬에서 작업하는 동안에 master의 업데이트가 이루어지는 경우가 있습니다. 변경된 부분을 로컬에 반영해봅시다.

```bash
$ git checkout master
$ git pull --rebase
```

이어서 최신의 변경사항이 적용된 상황에서 패치를 다시 적용해봅시다.

```bash
$ git checkout my_new_branch
$ git rebase master
```

충돌이 발생하지는 않는지, 테스트는 통과하는지, 가져온 변경에 별 문제는 없는지 확인을 한 뒤 다음으로 진행합시다.

### Fork

Rails [GitHub 저장소](https://github.com/rails/rails)를 열어서 우측 상단에 있는 [Fork]를 누릅시다.

로컬 PC상의 저장소에 새로운 원격 저장소를 추가합니다.

```bash
$ git remote add mine https://github.com:<자신의 사용자명>/rails.git
```

리모트에 변경사항을 올립니다.

```bash
$ git push mine my_new_branch
```

Fork한 저장소를 로컬에 복사하고, Rails의 원 저장소를 원격 저장소로 추가할 수도 있습니다. 이러한 경우에는 다음과 같이 진행해주세요.

Fork를 복사한 폴더에서 다음을 실행합니다.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Rails의 공식 저장소로부터 새 커밋과 브랜치를 가져옵니다.

```bash
$ git fetch rails
```

가져온 새 컨텐츠를 병합합니다.

```bash
$ git checkout master
$ git rebase rails/master
```

Fork한 저장소를 갱신합니다.

```bash
$ git push origin master
```

다른 브랜치를 갱신하고 싶은 경우에는 다음과 같이 합니다.

```bash
$ git checkout branch_name
$ git rebase rails/branch_name
$ git push origin branch_name
```


### 풀 리퀘스트 보내기

패치를 올린 Rails 저장소를 열어서 (여기에서는 https://github.com/your-user-name/rails 이라고 가정합니다), 우상단에 있는 [Pull Requests]를 클릭합니다. 다음 페이지의 우상단의 [New pull request]를 클릭합니다.

비교 대상의 브랜치를 변경하고 싶은 경우에는 [Edit]을 클릭하고 (기본은 master가 비교대상이 됩니다). [Click to create a pull request for this comparison]를 클릭합니다.

자신이 추가한 변경 사항이 포함되는 것을 확인할 수 있습니다. 보내고 싶은 패치의 상세한 설명을 추가하고, 알기 쉬운 제목을 붙입니다. 끝나면 [Send pull request]를 클릭합니다. 보내진 풀리퀘스트는 Rails 코어 팀에게 전달됩니다.

### 피드백 받기

보낸 풀 리퀘스트가 병합되기 전에는 몇번 정도 재도전이 필요할 것입니다. 풀 리퀘스트에 대해 다른 의견을 가지고 있는 기여자가 있을지도 모릅니다. 많은 경우, 풀 리퀘스트가 머지될 때까지 패치를 몇번이고 갱신해야할 수도 있습니다.

GitHub의 메일 통지 기능을 켜두고 있는 Rails 기여자도 있는 반면, 그렇지 않은 사람도 있습니다. Rails에 기여하고 있는 사람들의 대부분은 자원봉사이므로, 풀 리퀘스트에 어떤 형태로든 반응이 있을 때까지 몇일 정도 걸리는 경우도 많습니다. 그러니 포기하지 말고 풀 리퀘스트를 많이 보내주세요. 놀랄 정도로 반응을 보여줄 때도 있지만, 그렇지 않을 때도 있습니다. 그것이 오픈 소스라는 환경입니다.

일주일이 지나도 아무런 반응이 없다면 다른 방향으로 접근해보세요. [rubyonrails-core 메일링 리스트](http://groups.google.com/group/rubyonrails-core/)를 이용해주세요. 풀 리퀘스트에 덧글을 추가해보는 것도 좋습니다.

이왕이면, 풀 리퀘스트에 대한 반응을 기다리는 동안 다른 사람들의 풀 리퀘스트를 열어서 덧글을 달아보세요. 올린 패치에 대한 반응이 있었을 때와 마찬가지로 다른 사람들 역시 기쁘게 생각할 것입니다.

### 필요하다면 몇번이고 다시 도전하기

Rails에 기여할 수 있도록 활동하다보면, 풀 리퀘스트는 여기를 바꾸는 편이 좋지 않나요, 같은 피드백을 받는 경우가 생길 것입니다. 그러한 일이 있어도 풀죽지 말아주세요. 오픈 소스 프로젝트에 기여할 때에 중요한 점은 커뮤니티의 지식을 활용할 수 있다는 점입니다. 커뮤니티의 멤버가 당신의 코드를 개선하길 바란다면, 그 말대로 고칠 만한 가치가 있습니다. 그 코드는 Rails의 코드에 넣을만한 것이 아니라는 피드백을 받았다면, gem 형태로 릴리스하는 것이 나을 수도 있습니다.

#### 커밋 뭉치기

Rails에 기여하는 모든 분들에게는 반드시 '커밋을 합쳐주기를' 부탁드리고 있습니다. 커밋 합치기란 여러 개의 커밋을 하나로 만드는 것입니다. 풀 리퀘스트는 하나의 커밋으로 합쳐두는 것이 바람직 합니다. 커밋을 하나로 합치는 것으로 안정적인 버전의 브랜치에 새로운 변경을 백포트하기도 쉬워지며, 좋지 않은 커밋을 제거하기도 쉬워지고, Git의 이력도 조금 읽기 편해집니다. Rails는 거대한 프로젝트이며 그렇지 않은 커밋이 여러개 추가되면 커다란 노이즈가 발생할 가능성이 있습니다.

다음의 작업을 하려면 공식 Rails 저장소를 가리키는 Git 원격 저장소를 설정해야합니다. Git 원격 저장소는 다른 작업에서도 편리합니다만, 만약 추가하지 않았다면 다음을 먼저 실행해주세요.

```bash
$ git remote add upstream https://github.com/rails/rails.git
```

이 원격 저장소는 `upstream` 이외의 이름을 쓸 수도 있습니다. `upstream`라는 이름을 쓰고 싶지 않다면, 다음의 순서를 통해 이름을 변경할 수 있습니다.

원격 브랜치의 이름이 `my_pull_request`인 경우에는 다음을 실행합니다.

```bash
$ git fetch upstream
$ git checkout my_pull_request
$ git rebase upstream/master
$ git rebase -i

< 최초의 첫번재를 제외한 모든 커밋을 뭉칩니다 >
< 커밋 메시지를 편집해서 모든 변경을 알기 쉽게 작성합니다 >

$ git push origin my_pull_request -f
```

이상으로 GitHub상의 풀 리퀘스트를 갱신할 수 있게 되며, 실제로 갱신된 것을 확인할 수 있습니다.

#### 풀 리퀘스트를 변경하기

당신이 커밋한 코드에 대해서 변경을 요구받는 경우도 있습니다. 기존의 커밋을 그대로 수정해야하는 경우도 있습니다. 그러나 Git은 기존의 커밋을 직접 변경하여 올리는 것을 허락하지 않습니다. 이미 올린 브랜치와 로컬의 브랜치가 일치하지 않기 때문입니다. 이러한 경우에는 새로운 풀 리퀘스트를 작성하는 대신 커밋을 합치는 방법을 이용해서 자신의 브랜치를 GitHub에 강제적으로 올릴 수 있습니다.


```bash
$ git push origin my_pull_request -f
```

이를 통해 GitHub상에서의 브랜치와 풀 리퀘스트가 새 코드에 의해서 갱신됩니다. 강제적인 푸시를 하게 되면, 원격 브랜치의 커밋이 손실될 가능성이 있으므로, 주의해주세요.


### 오래된 버전의 Ruby on Rails

구 버전의 Ruby on Rails에 수정 패치를 적용하고 싶은 경우에는 설정에 따라 로컬의 작업 브랜치를 변경할 필요가 있습니다. 예를 들어 4-0-stable 브랜치로 변경하고 싶은 경우에는 다음과 같이 실행해주세요.

```bash
$ git branch --track 4-0-stable origin/4-0-stable
$ git checkout 4-0-stable
```

TIP: [쉘 프롬프트에서 Git 브랜치 명을 보여주기](http://qugstart.com/blog/git-and-svn/add-colored-git-branch-name-to-your-shell-prompt/)를 사용하면 지금 어떤 버전에서 작업하고 있는지 바로 확인할 수 있으므로 편리합니다.

#### 백포트

변경사항이 master에 병합되면, 그 변경사항은 Rails의 다음 메이저 릴리즈에서 채용됩니다. 항상은 아닙니다만, 변경을 과거의 안정판의 유지 보수 목적으로 백포트하는 경우가 있습니다. 일반적으로 보안 관련 수정 및 버그 수정이 백포트의 후보입니다. 새로운 기능이나 동작 변경 패치는 백포트의 후보에서 제외됩니다. 자신의 변경이 어느쪽에 해당하는지 알 수 없는 경우에는 필요없는 작업을 피하기 위해서라도 변경을 백포트하기 전에 Rails 팀 멤버들과 상담해주세요.

단순한 수정을 백포트하는 가장 간단한 방법은 [master와 자신의 변경의 diff를 계산해서 대상 브랜치에 적용하는](http://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git)것입니다.

우선 master와 자신의 변경의 diff 이외의 차분이 없는지를 확인합니다.

```bash
$ git log master..HEAD
```

다음으로 diff를 전개합니다.

```bash
$ git format-patch master --stdout > ~/my_changes.patch
```

대상 브랜치로 넘어가서 변경사항을 적용합니다.

```bash
$ git checkout -b my_backport_branch 4-2-stable
$ git apply ~/my_changes.patch
```

단순한 변경사항이라면 이 정도로 간단하게 백포트를 할 수 있습니다. 하지만 복잡한 변경이 이루어진 경우나 master와 대상 브랜치의 차이가 너무 큰 경우에는 추가로 작업을 해야할지도 모릅니다. 백포트가 어느 정도 복잡해질지는 상황에 따라서 크게 다릅니다. 때때로 많은 노력을 들여서 백포트할 만큼의 의미가 없는 경우도 있습니다.

충돌을 모두 해결하고 모든 테스트가 통과되는 것을 확인했다면 변경사항을 푸시하고, 백포트용의 풀 리퀘스트를 별도로 작성합니다. 그리고 오래된 브랜치에는 빌드 타겟이 master와 다른 경우도 있으므로 주의해주세요. 가능하다면 `.travis.yml`에 선언되어 있는 버전의 Ruby를 사용하여 백포트를 로컬에서 테스트하고나서 풀 리퀘스트를 보내주세요.

이상으로 설명은 끝입니다. 이제 어떤 기여를 할 수 있을지 생각해보세요!

Rails 기여자
------------------

master나 docrails에의 기여가 인정된 분들을 [Rails 기여자](http://contributors.rubyonrails.org)에 그 이름을 올리고 있습니다.

