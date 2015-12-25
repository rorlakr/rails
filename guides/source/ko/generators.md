
Rails 제너레이터와 템플릿
=====================================================

Rails의 각종 제너레이터는 작업 흐름을 개선하기 위해 빠져서는 안되는 도구입니다. 이 가이드에서는 Rails 제너레이터의 생성 바업과 기존의 제너레이터를 변경하는 방법에 대해서 설명합니다.

이 가이드의 내용:

* 애플리케이션에서 사용가능한 제너레이터를 확인하는 방법
* 템플릿을 사용하여 제너레이터를 생성하는 방법
* Rails가 제너레이터를 호출하기 전에 탐색하는 방법
* Rails가 템플릿으로부터 Rails 코드를 내부적으로 생성하는 방법
* 제너레이터를 직접 만들어서 scaffold를 변경하는 방법
* 제너레이터의 템플릿을 변경하여 scaffold를 변경하는 방법
* 여러 제너레이터를 덮어쓰지 않도록 폴백을 사용하는 방법
* 애플리케이션 템플릿의 작성 방법

--------------------------------------------------------------------------------

첫 제너레이터
-------------

`rails` 명령으로 Rails 애플리케이션을 생성하면, 이것은 이미 Rails의 제너레이터를 사용한 것입니다. 이어서 `rails generate`를 입력하면, 그 시점에서 애플리케이션에서 사용 가능한 제너레이터 목록이 출력됩니다.

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

Rails에서 사용 가능한 모든 제너레이터 목록이 출력됩니다. 예를 들어, 헬퍼 제너레이터의 자세한 설명을 보고 싶은 경우에는 다음과 같이 입력하세요.

```bash
$ bin/rails generate helper --help
```

첫 제너레이터를 만들기
-----------------------------

Rails의 제너레이터는 Rails 3.0 이후로 [Thor](https://github.com/erikhuda/thor) 위에서 구축되어 있습니다. Thor는 강력한 해석 기능과 우수한 파일 조작 API를 제공합니다. 구체적인 예시로, `config/initializers` 폴더에 있는 `initializer.rb`라는 이름의 initializer 파일을 하나 생성하는 제너레이터를 만들어 봅시다.

우선 다음 내용을 가지는 `lib/generators/initializer_generator.rb`라는 파일을 하나 생성합니다.

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

NOTE: `create_file` 메소드는 `Thor::Actions`에 의해서 제공됩니다. `create_file` 그리고 다른 Thor 메소드에 대한 문서는 [Thor 문서](http://rdoc.info/github/erikhuda/thor/master/Thor/Actions.html)를 참고해주세요.

이번에 생성한 세로운 제너레이터는 무척 간단합니다. `Rails::Generators::Base`를 상속하였으며, 메소드는 하나 뿐입니다. 제너레이터가 실행되면, 제너레이터에서 정의된 메소드가 순서대로 실행됩니다. 마지막으로 `create_file` 메소드가 호출되어 지정된 내용을 가지는 파일이 지정된 폴더에 하나 생성됩니다. Rails 애플리케이션 템플릿 API에 익숙한 개발자라면, 금방 새로운 제너레이터 API에 익숙해질 수 있을겁니다.

다음을 실행하여, 이 새로운 제너레이터를 호출할 수 있습니다.

```bash
$ bin/rails generate initializer
```

다음을 진행하기 전에, 지금 생성한 제너레이터의 설명을 출력해봅시다.

```bash
$ bin/rails generate initializer --help
```

Rails에서는 제너레이터가 `ActiveRecord::Generators::ModelGenerator` 처럼 네임스페이스로 감싸져 있다면 실용적인 설명을 생성할 수 있습니다만, 이 경우에는 아쉽게도 그렇게 되지 않습니다. 이 문제는 두가지의 방법으로 해결할 수 있습니다. 첫번째 방법은 제너레이터에서 `desc` 메소드를 호출하는 것입니다.

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "이 제너레이터는 config/initializers에 initializer를 파일을 생성합니다."
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

이걸로 `--help`를 붙여서 새로운 제너레이터를 호출하면, 설명이 출력됩니다. 설명을 추가하는 또다른 방법은 제너레이터와 같은 폴더에 `USAGE`라는 이름의 파일을 생성하는 것입니다. 다음에는 이 방법을 통해서 설명문을 추가해봅시다.

제너레이터를 사용해서 제너레이터를 생성하기
-----------------------------------

Rails에는 제너레이터를 생성하기 위한 제너레이터도 존재합니다.

```bash
$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
```

위에서 생성한 제너레이터의 내용은 아래와 같습니다.

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
end
```

이 제너레이터를 보고 처음 발견할 수 있는 내용은 `Rails::Generators::Base`가 아닌 `Rails::Generators::NamedBase`를 상속하고 있다는 점입니다. 이것은 이 제너레이터를 생성하기 위해서는 적어도 하나의 인수가 필요하다는 것을 의미합니다. 이 인수는 initializer의 이름이며, 코드에서는 이 initializer의 이름을 `name`라는 변수로 참조할 수 있습니다.

세로운 제너레이터를 호출하면 설명문이 출력됩니다. 그리고 이전의 제너레이터 파일은 반드시 삭제해주세요.

```bash
$ bin/rails generate initializer --help
Usage:
  rails generate initializer NAME [options]
```

새로운 제너레이터에는 `source_root`라는 이름의 클래스 메소드가 포함되어 있습니다. 이 메소드는 제너레이터의 템플릿의 위치를 지정할 때에 사용합니다. 기본값은 생성된 위치의 `lib/generators/initializer/templates` 폴더를 지정합니다.

제너레이터의 템플릿 기능을 이해하기 위해서 `lib/generators/initializer/templates/initializer.rb`를 생성하여 아래의 내용을 추가해봅시다.

```ruby
# 초기화 내용을 여기에 추가한다.
```

이어서 제너레이터를 변경하고, 호출되었을 때에 이 템플릿을 복사하도록 합니다.

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

그러면 이 제너레이터를 실행해보죠.

```bash
$ bin/rails generate initializer core_extensions
```

`config/initializers/core_extensions.rb`에 core_extensions라는 이름의 initializer가 생성되고, 거기에 방금의 템플릿이 반영되고 있음을 확인할 수 있습니다. `copy_file` 메소드는 복사 전의 최상위 디렉토리로부터 지정된 경로에 파일을 하나 복사합니다. `file_name` 메소드는 `Rails::Generators::NamedBase`를 계승하면 자동으로 생성됩니다.

제너레이터에서 사용할 수 있는 메소드에 대해서는 이 가이드의 [마지막 절](#제너레이터-메소드)에서 다루고 있습니다.

제너레이터가 참조하는 파일
-----------------

`rails generate initializer core_extensions`를 실행할 때 Rails는 다음 파일을 위에서부터 순서대로 찾을 때까지 require를 시도합니다.

```bash
rails/generators/initializer/initializer_generator.rb
generators/initializer/initializer_generator.rb
rails/generators/initializer_generator.rb
generators/initializer_generator.rb
```

파일을 찾지 못한 경우에는 에러 메시지를 출력합니다.

INFO: 이 예제에서는 애플리케이션의 `lib` 폴더에 파일을 저장하고 있습니다만, 이러한 폴더가 `$LOAD_PATH`에 포함되어 있기 때문에 가능합니다.

작업 흐름을 변경하기
-------------------------

Rails 자신이 가지는 제너레이터는 scaffold를 유연하게 변경할 수 있습니다. 설정은 `config/application.rb`에서 할 수 있습니다. 기본값을 다음과 같습니다.

```ruby
config.generators do |g|
  g.orm :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: true
end
```

작업 흐름을 변경하기 전에는 scaffold는 다음과 같이 동작합니다.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20130924151154_create_users.rb
      create    app/models/user.rb
      invoke  test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb 
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      invoke  test_unit
      create      test/controllers/users_controller_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/users.js.coffee
      invoke    scss
      create      app/assets/stylesheets/users.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss
```

이 출력 결과로부터 Rails 3.0 이후의 제너레이터의 동작을 손쉽게 이해할 수 있게 되었습니다. 사실 scaffold 제너레이터 자신은 아무것도 생성하지 않습니다. 생성에 필요한 메소드를 순서대로 호출할 뿐입니다. 이러한 구조로 되어 있으므로 호출을 자유롭게 추가/변경/삭제할 수 있습니다. 예를 들어, scaffold 제너레이터는 scaffold_controller 라는 제너레이터를 호출합니다. 이것은 erb의 제너레이터, test_unit의 제너레이터, 그리고 헬퍼의 제너레이터를 호출합니다. 제너레이터마다 역할이 각각 하나씩 부여되어 있으므로, 코드는 재이용할 수 있으며, 코드의 중복도 피할 수 있습니다.

첫번째 변경으로 작업 흐름에서 스타일 시트와 JavaScript, 테스트 픽스쳐 파일을 scaffold에서 생성하지 않도록 변경해봅시다. 이것은 다음과 같이 설정을 변경하기만 하면 됩니다.

```ruby
config.generators do |g|
  g.orm :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
end
```

scaffold 제네레이터로 다시 리소스를 생성해보면, 이번에는 스타일 시트와 JavaScript 파일, 픽스쳐가 생성되지 않습니다. 제너레이터를 더 변경하고 싶은 경우(Active Record와 TestUnit을 DataMapper와 RSpec으로 바꾸는 등)는 필요한 gem을 애플리케이션에 추가하여 제너레이터를 설정하기만 하면 됩니다.

제너레이터의 커스터마이즈 예를 설명하기 위해, 새 헬퍼 제너레이터를 하나 생성해봅시다. 이 제너레이터는 인스턴스 변수를 읽는 메소드를 몇가지 추가하는 간단한 것입니다. 처음에 Rails의 네임스페이스의 내부에 제너레이터를 하나 생성합니다. 네임스페이스의 내부에 두는 이유는 Rails는 훅으로 사용하는 제너레이터를 네임스페이스 내에서 탐색하기 때문입니다.

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
```

이어서 `templates` 폴더와 `source_root` 클래스 메소드 호출을 사용할 필요가 없기 때문에 제너레이터에서 삭제합니다. 제너레이터에 메소드를 추가하여 다음처럼 만들어 봅시다.

```ruby
# lib/generators/rails/my_helper/my_helper_generator.rb
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<-FILE
module #{class_name}Helper
  attr_reader :#{plural_name}, :#{plural_name.singularize}
end
    FILE
  end
end
```

새롭게 생성한 제너레이터로 products의 헬퍼를 실제로 생성해봅시다.

```bash
$ bin/rails generate my_helper products
      create  app/helpers/products_helper.rb
```

이를 실행하면 `app/helpers`에 다음의 내용을 가지는 헬퍼가 생성됩니다.

```ruby
module ProductsHelper
  attr_reader :products, :product
end
```

기대대로의 결과를 얻었습니다. 위에서 생성한 헬퍼 제너레이터를 scaffold로 실제로 사용하기 위해서 이번에는 `config/application.rb`를 다음과 같이 변경해봅시다.

```ruby
config.generators do |g|
  g.orm :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
  g.helper          :my_helper
end
```

scaffold를 실행하면, 제너레이터를 호출할 때에 다음처럼 출력되는 것을 확인할 수 있습니다.

```bash
$ bin/rails generate scaffold Article body:text
      [...]
      invoke    my_helper
      create      app/helpers/articles_helper.rb
```

출력 결과가 Rails의 기본값과 달라지며, 새로운 헬퍼를 호출하는 것을 알 수 있습니다. 하지만 여기에서 하나 더 해두지 않으면 안되는 것이 있습니다. 새로운 제너레이터에도 테스트를 작성해야합니다. 이를 위해서 원래 헬퍼의 테스트 제너레이터를 다시 사용하도록 합시다.

Rails 3.0 이후에는 '훅'이라는 개념을 사용할 수 있으므로 이러한 재이용이 간단하게 이루어집니다. 지금 만든 헬퍼는 특정 테스트 프레임워크만으로 제한할 필요가 없으니 헬퍼가 훅을 하나 제공하고, 테스트 프레임워크에서 그 훅을 통해 호환성을 유지하는 것으로 충분합니다.

이를 위해서 제너레이터를 다음과 같이 변경합시다.

```ruby
# lib/generators/rails/my_helper/my_helper_generator.rb
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<-FILE
module #{class_name}Helper
  attr_reader :#{plural_name}, :#{plural_name.singularize}
end
    FILE
  end

  hook_for :test_framework
end
```

이렇게 헬퍼 제너레이터가 호출되어 TestUnit이 테스트 프레임워크로 설정되면 `Rails::TestUnitGenerator`와 `TestUnit::MyHelperGenerator`를 모두 호출하게 됩니다. 하지만 어느쪽도 정의되어 있지 않으므로, Rails의 제너레이터로서 실제로 정의되어 있는 `TestUnit::Generators::HelperGenerator`를 대신 호출하도록 제너레이터를 변경할 수 있습니다. 구체적으로는 다음과 같은 코드를 추가하세요.

```ruby
# :my_helper가 아닌 :helper를 탐색하기
hook_for :test_framework, as: :helper
```

여기서 scaffold를 다시 실행하면, 생성된 리소스에도 테스트가 포함됩니다.

제너레이터의 템플릿을 변경하여 작업 흐름을 변경하기
----------------------------------------------------------

위에서 소개한 내용에서는 생성한 헬퍼에 한 줄을 추가했을 뿐, 그 이외의 기능은 전혀 추가하지 않았습니다. 같은 작업을 좀 더 간단하게 할 수 있는 방법이 있습니다. 이를 위해서는 기존의 제너레이터(여기에서는 `Rails::Generators::HelperGenerator`)의 템플릿을 변경합니다.

Rails 3.0 이후로 제너레이터는 소스의 최상위 폴더에서 템플릿의 존재여부를 단순히 탐색하는 것이 아니라, 다른 경로에서도 템플릿을 찾습니다. `lib/templates` 폴더도 이 탐색 대상에 포함됩니다. `Rails::Generators::HelperGenerator`를 변경하려면 `lib/templates/rails/helper` 폴더에 있는 `helper.rb`라는 템플릿의 사본을 생성합니다. 이 파일을 만든 후에 다음의 코드를 추가합니다.

```erb
module <%= class_name %>Helper
  attr_reader :<%= plural_name %>, :<%= plural_name.singularize %>
end
```

다음으로 `config/application.rb`에 변경을 원래대로 돌려줍니다.

```ruby
config.generators do |g|
  g.orm :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.javascripts     false
end
```

리소스를 다시 한번 생성해보면 처음과 완전히 동일한 결과를 얻을 수 있습니다. 이 방법은 `lib/templates/erb/scaffold` 폴더에 있는 `edit.html.erb`나 `index.html.erb`를 작성하여 scaffold 템플릿이나 레이아웃을 커스터마이즈하고 싶은 경우에 유용합니다.

Rails의 scaffold 템플릿에서는 ERB 태그가 많이 사용됩니다만, 이것들이 정상적으로 생성되기 위해서는 ERB 태그를 이스케이프 해줄 필요가 있습니다.

예를 들어 템플릿에서 다음과 같은 이스케이프된 ERB 태그가 필요하다고 해봅시다(`%`문자가 하나 많다는 점을 주목해주세요).

```ruby
<%%= stylesheet_include_tag :application %>
```

이 코드는 다음의 출력을 생성합니다.

```ruby
<%= stylesheet_include_tag :application %>
```

제너레이터에 폴백을 추가하기
---------------------------

마지막으로 소개할 제너레이터의 기능은 폴백입니다. 이것은 플러그인의 제너레이터를 사용하는 경우에 유용합니다. 예를 들어 TestUnit에 [shoulda](https://github.com/thoughtbot/shoulda)와 같은 기능을 추가하고 싶다고 해봅시다. TestUnit는 Rails에서 require되는 모든 제너레이터에서 구현이 되어 있으며 shoulda에서는 그 일부를 덮어 쓰기만 하면 됩니다. 이렇듯 shoulda에서 구현할 필요가 없는 제너레이터의 기능이 몇몇 존재하므로 Rails에서는 `Shoulda`의 네임스페이스에서 발견하지 못하는 것을 모두 `TestUnit` 제너레이터에서 찾도록 지정하기만 하면 폴백을 구현할 수 있습니다.

이전에 변경했던 `config/application.rb`에 다시 변경을 하여 이 작업을 간단하게 시뮬레이션해봅시다.

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :shoulda, fixture: false
  g.stylesheets     false
  g.javascripts     false

  # 폴백을 추가한다
  g.fallbacks[:shoulda] = :test_unit
end
```

이로서 scaffold로 Comment를 생성하면 shoulda 제너레이터가 호출되고, 최종적으로 TestUnit 제너레이터에 폴백하게 됩니다.

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20130924143118_create_comments.rb
      create    app/models/comment.rb
      invoke    shoulda
      create      test/models/comment_test.rb
      create      test/fixtures/comments.yml
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      invoke    shoulda
      create      test/controllers/comments_controller_test.rb
      invoke    my_helper
      create      app/helpers/comments_helper.rb
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/comments.js.coffee
      invoke    scss
```

폴백을 사용하면 제너레이터의 일을 하나로 줄일 수 있으며, 코드의 중복을 줄이고 재사용성을 늘릴 수 있습니다.

애플리케이션 템플릿
---------------------

여기까지 Rails 애플리케이션 _내부_에서의 제너레이터 동작에 대해서 설명했습니다만, 제너레이터를 사용하여 직접 Rails 애플리케이션 자신을 생성할 수도 있다는 것을 알고 계신가요? 이러한 목적으로 사용되는 제너레이터는 '애플리케이션 템플릿'이라고 불립니다. 여기에서는 Templates API를 간단히 소개힙니다. 자세한 설명은 [Rails 애플리케이션 탬플릿](rails_application_templates.html)를 참고해주세요.

```ruby
gem "rspec-rails", group: "test"
gem "cucumber-rails", group: "test"

if yes?("Would you like to install Devise?")
  gem "devise"
  generate "devise:install"
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate "devise", model_name
end
```

이 템플릿에서는 Rails 애플리케이션이 `rspec-rails`와 `cucumber-rails` gem에 의존하도록 지정되어 있습니다. 이 설정에 따라 이 gem들은 `Gemfile`의 `test` 그룹에 추가됩니다. 이어서 `Devise` gem을 설치할지를 사용자에게 묻습니다. 사용자가 "y" 또는 "yes"를 입력하면 `Gemfile`에 `Devise` gem이 추가되며(특정 gem 그룹에 포함시키지 않습니다), `devise:install` 제너레이터를 실행합니다. 나아가 사용자 입력을 받고 `devise` 제너레이터에 그 입력 결과를 넘겨서 제너레이터를 실행합니다.

이 템플릿이 `template.rb`라는 이름의 파일에 포함되어 있다고 가정합니다. `-m` 옵션으로 템플릿 파일명을 넘겨서 `rails new` 명령의 실행 결과를 변경할 수 있습니다.

```bash
$ rails new thud -m template.rb
```

이 명령을 실행하면 `Thud`라는 애플리케이션이 생성되며, 그 결과에는 템플릿이 적용됩니다.

템플릿은 로컬에 저장되어 있지 않더라도 상관 없습니다. `-m`으로 지정한 템플릿의 위치는 온라인이더라도 문제 없이 동작합니다.

```bash
$ rails new thud -m https://gist.github.com/radar/722911/raw/
```

이 가이드이 마지막은 템플릿에서 자유롭게 사용가능한 메소드를 소개하고 있으므로, 이를 사용하여 자신의 취향에 맞는 템플릿을 개발해보세요. 잘 알려진 멋진 애플리케이션 템플릿들을 실제로 생성하는 방법까지 모두 소개하기에는 공간이 충분치 않으므로, 이해해주세요. 이러한 메소드는 제너레이터에서도 사용할 수 있습니다.


제너레이터 메소드
-----------------

다음의 메소드는 Rails의 제너레이터와 템플릿, 어느 쪽에서도 사용할 수 있습니다.

NOTE: Thor가 제공하는 메소드에 대해서는 설명하지 않습니다. [Thor의 문서](http://rdoc.info/github/erikhuda/thor/master/Thor/Actions.html)를 참조해주세요.

### `gem`

Rails 애플리케이션의 gem 의존성을 지정합니다.

```ruby
gem "rspec", group: "test", version: "2.1.0"
gem "devise", "1.1.5"
```

이하의 옵션을 지정할 수 있습니다.

* `:group` - gem을 추가할 `Gemfile`의 그룹을 지정합니다.
* `:version` - 사용하는 gem의 버전을 지정합니다. `version` 옵션을 명시하지 않고 메소드의 두번째 인수로 넘겨줄 수도 있습니다.
* `:git` - gem이 존재하는 git 저장소를 가리키는 URL을 넘겨줍니다.

메소드에서 이 이외의 옵션을 사용하는 경우에는 다음과 같이 메소드의 마지막에 넘겨주세요.

```ruby
gem "devise", git: "git://github.com/plataformatec/devise", branch: "master"
```

이 코드가 실행되면, `Gemfile`에는 다음의 줄이 추가됩니다.

```ruby
gem "devise", git: "git://github.com/plataformatec/devise", branch: "master"
```

### `gem_group`

gem의 엔트리에 지정한 그룹을 포함합니다.

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### `add_source`

지정한 소스를 `Gemfile`에 추가합니다.

```ruby
add_source "http://gems.github.com"
```

### `inject_into_file`

파일 내의 지정한 위치에 코드 블럭을 삽입합니다.

```ruby
inject_into_file 'name_of_file.rb', after: "# 삽입하고 싶은 코드를 다음 줄에 작성합니다. 마지막의 end\n 뒤에는 반드시 개행을 추가하세요." do <<-'RUBY'
  puts "Hello World"
RUBY
end
```

### `gsub_file`

파일 내의 텍스트를 치환합니다.

```ruby
gsub_file 'name_of_file.rb', 'method.to_be_replaced', 'method.the_replacing_code'
```

정규표현을 사용해서 치환하는 방법을 세밀하게 지정할 수 있습니다. `append_file`을 사용해서 코드를 파일의 말미에 추가하거나, `prepend_file`를 사용해서 코드를 파일의 앞부분에 삽입할 수도 있습니다.

### `application`

`config/application.rb` 파일의 애플리케이션 클래스 정의 직후에 지정한 줄을 추가합니다.

```ruby
application "config.asset_host = 'http://example.com'"
```

이 메소드에는 블록을 넘길 수도 있습니다.

```ruby
application do
  "config.asset_host = 'http://example.com'"
end
```

다음의 옵션을 사용할 수 있습니다.

* `:env` - 설정 옵션의 환경을 지정합니다. 블럭을 사용하는 경우에는 다음과 같이 작성하기를 권장합니다.

```ruby
application(nil, env: "development") do
  "config.asset_host = 'http://localhost:3000'"
end
```

### `git`

git 명령을 실행합니다.

```ruby
git :init
git add: "."
git commit: "-m First commit!"
git add: "onefile.rb", rm: "badfile.cxx"
```

인수 또는 옵션이 되는 해시의 값은 지정한 git 명령어에 전달됩니다. 위의 마지막 줄에서도 보이듯, 한행에 복수의 git 명령을 작성할 수도 있습니다만, 이 경우 명령의 실행 순서가 작성한 순서대로일거라고는 단정지을 수 없으므로 주의가 필요합니다.

### `vendor`

지정된 코드를 포함하는 파일을 `vendor` 폴더에 위치시킵니다.

```ruby
vendor "sekrit.rb", '# 비밀
```

이 메소드에는 블록을 하나 넘길 수 있습니다.

```ruby
vendor "seeds.rb" do
  "puts 'in your app, seeding your database'"
end
```

### `lib`

지정한 코드를 포함하는 파일을 `lib` 폴더에 위치시킵니다.

```ruby
lib "special.rb", "p Rails.root"
```

이 메소드에는 블록을 하나 넘길 수 있습니다.

```ruby
lib "super_special.rb" do
  puts "Super special!"
end
```

### `rakefile`

Rails 애플리케이션의 `lib/tasks` 폴더에 Rake 파일을 하나 생성합니다.

```ruby
rakefile "test.rake", "hello there"
```

이 메소드에는 블록을 하나 넘길 수 있습니다.

```ruby
rakefile "test.rake" do
  %Q{
    task rock: :environment do
      puts "Rockin'"
    end
  }
end
```

### `initializer`

Rails 애플리케이션의 `lib/initializers` 폴더에 initializer를 하나 생성합니다.

```ruby
initializer "begin.rb", "puts 'this is the beginning''"
```

이 메소드에는 블록을 하나 넘길 수 있으며 문자열이 반환됩니다.

```ruby
initializer "begin.rb" do
  "puts 'this is the beginning'"
end
```

### `generate`

지정된 제너레이터를 실행합니다. 첫번째 인수는 실행하는 제너레이터의 이름이며, 남은 인수는 제너레이터에게 넘겨집니다.

```ruby
generate "scaffold", "forums title:string description:text"
```


### `rake`

Rake 태스크를 실행합니다.

```ruby
rake "db:migrate"
```

다음의 옵션을 사용할 수 있습니다.

* `:env` - rake 태스크를 실행할 때의 환경을 지정합니다.
* `:sudo` - rake 태스크에서 `sudo`를 사용할지 결정합니다. 기본값은 `false`입니다.

### `capify!`

Capistrano의 `capify` 명령을 애플리케이션의 최상위 폴더에서 실행하여 Capistrano의 설정을 생성합니다.

```ruby
capify!
```

### `route`

`config/routes.rb` 파일에 문자열을 추가합니다.

```ruby
route "resources :people"
```

### `readme`

템플릿의 `source_path`에 있는 파일의 내용을 출력합니다. 일반적으로 이 파일은 README입니다.

```ruby
readme "README"
```

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
