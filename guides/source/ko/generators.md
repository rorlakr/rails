[Creating and Customizing Rails Generators & Templates] 레일스 제너레이터 & 템플릿을 생성과 커스터마이즈하기
=====================================================

작업 흐름을 향상시키려 한다면, 레일스 제너레이터는 필수적인 도구입니다. 이 가이드는 제너레이터를 생성과 커스터마이즈하는 방법을 알려드립니다. [[[Rails generators are an essential tool if you plan to improve your workflow. With this guide you will learn how to create generators and customize existing ones.]]]

본 가이드를 통해 다음의 내용들을 얻을 수 있습니다: [[[After reading this guide, you will know:]]]

* 어플리케이션에서 이용가능한 제너레이터를 보는 방법. [[[How to see which generators are available in your application.]]]

* 템플릿을 사용하여 제너레이터를 생성하는 방법. [[[How to create a generator using templates.]]]

* 제너레이터를 호출할때, 레일스가 제너레이터를 찾는 방법. [[[How Rails searches for generators before invoking them.]]]

* 새로운 제너레이터를 생성하여 scaffold를 커스터마이즈하는 방법. [[[How to customize your scaffold by creating new generators.]]]

* 제너레이터 템플릿을 변경하여 scaffold를 커스터마이즈하는 방법. [[[How to customize your scaffold by changing generator templates.]]]

* 수많은 제너레이터 세트들의 중복을 피하기 위한 방법. [[[How to use fallbacks to avoid overwriting a huge set of generators.]]]

* 어플리케이션 템플릿을 생성하는 방법. [[[How to create an application template.]]]

--------------------------------------------------------------------------------

첫 대면 [[[First Contact]]]
-------------

`rails` 명령어를 사용하여 어플리케이션을 생성할 때, 사실 레일즈 제너레이터를 사용하는 것입니다. 어플리케이션 생성 후, `rails generate`를 하면 사용가능한 제너레이터의 목록을 확인할 수 있습니다. [[[When you create an application using the `rails` command, you are in fact using a Rails generator. After that, you can get a list of all available generators by just invoking `rails generate`:]]]

```bash
$ rails new myapp
$ cd myapp
$ rails generate
```

레일스에 딸려 있는 모든 제너레이터 목록을 확인할 수 있습니다. 예를 들어, helper 제너레이터의 자세한 설명이 필요하다면, 아래와 같이 실행하면 됩니다. [[[You will get a list of all generators that comes with Rails. If you need a detailed description of the helper generator, for example, you can simply do:]]]

```bash
$ rails generate helper --help
```

제너레이터 생성하기 [[[Creating Your First Generator]]]
-----------------------------

레일즈 3.0 이래로, 제너레이터는 [Thor](https://github.com/wycats/thor) 기반으로 만들어졌습니다. Thor는 파일을 다루기 위한 강력한 API와 분석을 위한 멋진 옵션을 제공합니다. 예를 들어, `config/initializers` 안에 `initializer.rb` 이름의 initializer 파일을 생성하는 제너레이터를 만들어봅시다. [[[Since Rails 3.0, generators are built on top of [Thor](https://github.com/wycats/thor). Thor provides powerful options parsing and a great API for manipulating files. For instance, let's build a generator that creates an initializer file named `initializer.rb` inside `config/initializers`.]]]

첫번째 단계는 `lib/generators/initializer_generator.rb` 경로에 아래의 내용으로 파일을 생성하는 것입니다: [[[The first step is to create a file at `lib/generators/initializer_generator.rb` with the following content:]]]

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

NOTE: `create_file`는 `Thor::Actions`에 의해 제공되는 메소드입니다. 관련 문서는 [Thor's documentation](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html)에서 확인할 수 있습니다. [[[`create_file` is a method provided by `Thor::Actions`. Documentation for `create_file` and other Thor methods can be found in [Thor's documentation](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html)]]]

새 제너레이터는 매우 단순합니다: `Rails::Generators::Base`를 상속하고 하나의 메소드를 정의하였습니다. 제너레이터가 호출될 때, 제너레이터 안의 각 public 메소드는 정의된 순서대로 실행됩니다. 마침내, 주어진 내용과 함께 주어진 경로에 파일을 생성할 `create_file` 메소드를 실행하게 됩니다. 만약 Rails Application Templates API에 친숙하다면, 새로운 제너레이터 API 또한 편하게 느껴질 것입니다. [[[Our new generator is quite simple: it inherits from `Rails::Generators::Base` and has one method definition. When a generator is invoked, each public method in the generator is executed sequentially in the order that it is defined. Finally, we invoke the `create_file` method that will create a file at the given destination with the given content. If you are familiar with the Rails Application Templates API, you'll feel right at home with the new generators API.]]]

새로운 제너레이터를 호출하기 위해, 우리는 아래와 같이 실행하면 됩니다: [[[To invoke our new generator, we just need to do:]]]

```bash
$ rails generate initializer
```

실행하기에 앞서, 새롭게 만든 제너레이터의 설명을 봅시다: [[[Before we go on, let's see our brand new generator description:]]]

```bash
$ rails generate initializer --help
```

만약 제너레이터가 `ActiveRecord::Generators::ModelGenerator`와 같이 namespaced 된다면, 레일스는 보통 좋은 설명을 생성할 수 있지만, 이 경우는 예외입니다. 이 문제를 두 가지 방법으로 해결할 수 있습니다. 첫 번째는 제너레이터 안에 `desc` 메소드를 호출하는 것입니다.
[[[Rails is usually able to generate good descriptions if a generator is namespaced, as `ActiveRecord::Generators::ModelGenerator`, but not in this particular case. We can solve this problem in two ways. The first one is calling `desc` inside our generator:]]]

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", "# Add initialization content here"
  end
end
```

이제 우리는 `--help`을 호출하여 우리가 입력한 설명을 확인할 수 있습니다. 두 번째 방법은 같은 경로에 있는 USAGE 파일을 생성하는 것입니다. [[[Now we can see the new description by invoking `--help` on the new generator. The second way to add a description is by creating a file named `USAGE` in the same directory as our generator. We are going to do that in the next step.]]]

제너레이터를 이용하여 제너레이터 생성하기 [[[Creating Generators with Generators]]]
-----------------------------------

제너레이터를 위한 제너레이터를 가지고 있습니다: [[[Generators themselves have a generator:]]]

```bash
$ rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
```

이를 통해 단순한 제너레이터가 생성됩니다: [[[This is the generator just created:]]]

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
end
```

먼저, `Rails::Generators::Base` 대신에 `Rails::Generators::NamedBase`를 상속하고 있는 부분을 주의깊게 봅시다. 이것은 initializer의 이름과 코드의 변수명으로 사용될 인자가 적어도 하나 필요하다는 것을 의미합니다.
[[[First, notice that we are inheriting from `Rails::Generators::NamedBase` instead of `Rails::Generators::Base`. This means that our generator expects at least one argument, which will be the name of the initializer, and will be available in our code in the variable `name`.]]]

제너레이터를 호출하여 새로운 제너레이터의 설명을 볼 수 있습니다. (이전 제너레이터 파일을 삭제해야만 합니다.)
[[[We can see that by invoking the description of this new generator (don't forget to delete the old generator file):]]]

```bash
$ rails generate initializer --help
Usage:
  rails generate initializer NAME [options]
```

우리는 또한 새로 만든 제너레이터가 source_root 클래스 메소드를 가지는 것을 볼 수 있습니다. 이 메소드는 우리의 제너레이터 템플릿이 위치할 곳을 지정합니다, 지정하지 않으면 `lib/generators/initializer/templates`로 지정됩니다.
[[[We can also see that our new generator has a class method called `source_root`. This method points to where our generator templates will be placed, if any, and by default it points to the created directory `lib/generators/initializer/templates`.]]]

제너레이터 템플릿이 의미하는 바를 이해하기 위해서, 아래와 같이 `lib/generators/initializer/templates/initializer.rb`을 만들어봅시다. [[[In order to understand what a generator template means, let's create the file `lib/generators/initializer/templates/initializer.rb` with the following content:]]]

```ruby
# Add initialization content here
```

제너레이터 실행 시 이 템플릿을 복사하기 위해 제너레이터를 수정해봅시다. [[[And now let's change the generator to copy this template when invoked:]]]

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

이제 만든 제너레이터를 실행해보면: [[[And let's execute our generator:]]]

```bash
$ rails generate initializer core_extensions
```

이제 core_extensions으로 명시된 initializer가 템플릿 내용과 함께 `config/initializers/core_extensions.rb`에 생성되는 것을 볼 수 있습니다. `copy_file`이 우리가 설정한 destination path의 소스 루트 안에 파일을 복사하기 때문입니다. 그리고 `file_name` 메소드는 `Rails::Generators::NamedBase`로부터 상속할 때 자동적으로 생성됩니다. [[[We can see that now an initializer named core_extensions was created at `config/initializers/core_extensions.rb` with the contents of our template. That means that `copy_file` copied a file in our source root to the destination path we gave. The method `file_name` is automatically created when we inherit from `Rails::Generators::NamedBase`.]]]

제너레이터에서 이용가능한 메소드는 이 가이드의 마지막 섹션에서 다룹니다. [[[The methods that are available for generators are covered in the [final section](#generator-methods) of this guide.]]]

제너레이터 찾기[[[Generators Lookup]]]
-----------------

`rails generate initializer core_extensions`를 실행할 때, 레일스에서는 하나를 찾을 때까지 차례대로 이 파일들을 요청합니다. [[[When you run `rails generate initializer core_extensions` Rails requires these files in turn until one is found:]]]

```bash
rails/generators/initializer/initializer_generator.rb
generators/initializer/initializer_generator.rb
rails/generators/initializer_generator.rb
generators/initializer_generator.rb
```

만약 없다면 에러 메시지를 받게 됩니다. [[[If none is found you get an error message.]]]

INFO: 해당 디렉토리가 $LOAD_PATH의 속하기 때문에, 위의 예제는 어플리케이션의 lib 아래에 파일을 넣게 됩니다. [[[The examples above put files under the application's `lib` because said directory belongs to `$LOAD_PATH`.]]]

작업흐름을 커스터마이즈하기[[[Customizing Your Workflow]]]
-------------------------

레일스의 제너레이터는 당신이 scaffolding을 커스터마이즈하기 충분히 유연합니다. 그것들은 config/applications.rb 파일 안에 설정할 수 있습니다. [[[Rails own generators are flexible enough to let you customize scaffolding. They can be configured in `config/application.rb`, these are some defaults:]]]

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: true
end
```

작업흐름을 커스터마이즈하기 전에, 먼저 scaffold를 하나 만들어봅시다: [[[Before we customize our workflow, let's first see what our scaffold looks like:]]]

```bash
$ rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20091120125558_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
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
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      create        test/helpers/users_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/users.js.coffee
      invoke    scss
      create      app/assets/stylesheets/users.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss
```

이 결과에서 보면, 레일즈 3.0 이상 버전에서 제너레이터가 어떻게 동작하는지 이해하기가 쉽습니다. scaffold 제너레이터는 실제로 다른 것들을 생성하지 않습니다, 단지 다른 제너레이터 작업을 호출하는 것입니다. 이것은 우리에게 이러한 호출을 add/replace/remove 하도록 허용하는 것입니다. 예를 들어, scaffold 제너레이터는 erb, test_unit, helper 제너레이터를 호출하는 scaffold_controller 제너레이터를 호출합니다. 각 제너레이터는 개별적인 역할을 가지고 있기 때문데, 코드의 중복을 피하며 재사용하기 쉽습니다. [[[Looking at this output, it's easy to understand how generators work in Rails 3.0 and above. The scaffold generator doesn't actually generate anything, it just invokes others to do the work. This allows us to add/replace/remove any of those invocations. For instance, the scaffold generator invokes the scaffold_controller generator, which invokes erb, test_unit and helper generators. Since each generator has a single responsibility, they are easy to reuse, avoiding code duplication.]]]

작업흐름 상에서 우리의 첫 커스터마이제이션은 scaffold를 위한 stylesheets와 test fixtures 생성하지 않는 것입니다. 아래와 같이 변경을 해봅시다: [[[Our first customization on the workflow will be to stop generating stylesheets and test fixtures for scaffolds. We can achieve that by changing our configuration to the following:]]]

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
end
```

만약 scaffold 제너레이터와 함께 다른 리소스를 생성하면, 우리는 stylesheets와 fixture 생성하지 않는 것을 볼 수 있습니다. 만약 추가로 커스터마이즈하려면, 예를 들어 ActiveRecord와 TestUnit 대신에 DataMapper와 RSpec을 사용하는 것처럼, 단지 어플리케이션에 젬을 추가하고 당신의 제너레이터를 설정에 추가하기만 하면 됩니다. [[[If we generate another resource with the scaffold generator, we can see that neither stylesheets nor fixtures are created anymore. If you want to customize it further, for example to use DataMapper and RSpec instead of Active Record and TestUnit, it's just a matter of adding their gems to your application and configuring your generators.]]]

이것을 시연해보기 위해서, 인스턴스 변수 reader만 추가하는 helper 제너레이터를 생성할 것입니다. 이를 위해 첫번째, 레일스 네임스페이스 안에 제너레이터를 생성합니다, 레일스가 hook을 사용하여 제너레이터를 찾는 곳이기 때문입니다. [[[To demonstrate this, we are going to create a new helper generator that simply adds some instance variable readers. First, we create a generator within the rails namespace, as this is where rails searches for generators used as hooks:]]]

```bash
$ rails generate generator rails/my_helper
```

이 다음으로, 더이상 필요하지 않는 템플릿 디렉토리와 `source_root` 클래스 메소드를 삭제할 수 있습니다. 우리의 새로운 제너레이터는 다음과 같습니다: [[[After that, we can delete both the `templates` directory and the `source_root` class method from our new generators, because we are not going to need them. So our new generator looks like the following:]]]

```ruby
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

사용자들을 위한 helper를 만들기 위해 새로운 제너레이터를 사용해볼 수 있습니다. [[[We can try out our new generator by creating a helper for users:]]]

```bash
$ rails generate my_helper products
```

그것은 `app/helpers` 경로에 다음의 helper 파일을 생성합니다.[[[And it will generate the following helper file in `app/helpers`:]]]

```ruby
module ProductsHelper
  attr_reader :products, :product
end
```

이제 우리는 config/applications.rb 파일을 다시 수정함으로써, scaffold에 우리의 새로운 helper 제너레이터를 사용하도록 할 수 있습니다. [[[Which is what we expected. We can now tell scaffold to use our new helper generator by editing `config/application.rb` once again:]]]

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
  g.helper          :my_helper
end
```

그리고 이것은 제너레이터를 호출할 때 실행됩니다:[[[and see it in action when invoking the generator:]]]

```bash
$ rails generate scaffold Post body:text
      [...]
      invoke    my_helper
      create      app/helpers/posts_helper.rb
```

우리의 새로운 helper가 레일스 기본 helper 대신 실행되는 것을 결과물로 확인할 수 있습니다. 그러나 새로운 제너레이터를 위한 테스트와 테스트 실행 빠졌기에, 우리는 기존의 helpers test 제너레이터를 재사용할 것입니다. [[[We can notice on the output that our new helper was invoked instead of the Rails default. However one thing is missing, which is tests for our new generator and to do that, we are going to reuse old helpers test generators.]]]

레일즈 3.0 이후로, 이는 hook 컨셉 덕분에 쉬워졌습니다. 새로운 helper는 하나의 특정 테스트 프레임워크에 집중할 필요가 없습니다, 간단히 hook을 제공할 수 있고, 테스트 프레임워크는 단지 호환을 위한 hook를 적용할 필요가 있습니다.
[[[Since Rails 3.0, this is easy to do due to the hooks concept. Our new helper does not need to be focused in one specific test framework, it can simply provide a hook and a test framework just needs to implement this hook in order to be compatible.]]]

이를 위해, 아래와 같이 제너레이터를 변경합니다: [[[To do that, we can change the generator this way:]]]

```ruby
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

이제, helper 제너레이터가 호출되고 TestUnit이 테스트 프레임워크로 설정되어졌을 때, 그것은 `Rails::TestUnitGenerator`와 `TestUnit::MyHelperGenerator`를 실행하려 할 것입니다. 아무것도 정의하지 않았기 때문에, 우리의 제너레이터에 `TestUnit::Generators::HelperGenerator`을 실행할 것을 지시할 수 있습니다. 이렇게 하기 위해, 아래와 같이 추가할 필요가 있습니다: [[[Now, when the helper generator is invoked and TestUnit is configured as the test framework, it will try to invoke both `Rails::TestUnitGenerator` and `TestUnit::MyHelperGenerator`. Since none of those are defined, we can tell our generator to invoke `TestUnit::Generators::HelperGenerator` instead, which is defined since it's a Rails generator. To do that, we just need to add:]]]

```ruby
# Search for :helper instead of :my_helper
hook_for :test_framework, as: :helper
```

이제 다른 리소스를 위해 다시 scaffold를 실행할 수 있고 그것이 테스트를 잘 생성하는 것을 볼 수 있습니다. [[[And now you can re-run scaffold for another resource and see it generating tests as well!]]]

제너레이터 템플릿을 변경하여 작업흐름을 커스터마이즈하기 [[[Customizing Your Workflow by Changing Generators Templates]]]
----------------------------------------------------------

이전까지 helper에 기능 추가없이 줄만 추가하였습니다. 기능을 추가하는 쉬운 방법은 이미 존재하는 제너레이터의 템플릿을 대체하는 것입니다, 위의 경우는 `Rails::Generators::HelperGenerator`입니다. [[[In the step above we simply wanted to add a line to the generated helper, without adding any extra functionality. There is a simpler way to do that, and it's by replacing the templates of already existing generators, in that case `Rails::Generators::HelperGenerator`.]]]

레일즈 3.0 이래로, 제너레이터는 템플릿의 소스 루트만 보는 것이 아니라, 다른 경로의 템플릿도 검색합니다. 그리고 그것 중에 하나로 `lib/templates` 폴더가 있습니다. 우리는 `Rails::Generators::HelperGenerator`를 커스터마이즈하기 원하기 때문에, `helper.rb`란 이름으로 `lib/templates/rails/helper` 안에 템플릿을 만들어서 복사합니다. 이제 아래 내용과 함께 파일을 만들어봅시다: [[[In Rails 3.0 and above, generators don't just look in the source root for templates, they also search for templates in other paths. And one of them is `lib/templates`. Since we want to customize `Rails::Generators::HelperGenerator`, we can do that by simply making a template copy inside `lib/templates/rails/helper` with the name `helper.rb`. So let's create that file with the following content:]]]

```erb
module <%= class_name %>Helper
  attr_reader :<%= plural_name %>, :<%= plural_name.singularize %>
end
```

그리고 `config/application.rb`에서 변경한 내용을 되돌립니다: [[[and revert the last change in `config/application.rb`:]]]

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, fixture: false
  g.stylesheets     false
end
```

만약 다른 리소스를 생성한다면, 동일한 결과를 확인할 수 있습니다. 만약 scaffold 템플릿과 레이아웃을 커스터마이즈하길 원한다면 `lib/templates/erb/scaffold` 안에 `edit.html.erb`, `index.html.erb`를 생성하면 됩니다. [[[If you generate another resource, you can see that we get exactly the same result! This is useful if you want to customize your scaffold templates and/or layout by just creating `edit.html.erb`, `index.html.erb` and so on inside `lib/templates/erb/scaffold`.]]]

제너레이터 fallback을 추가하기 [[[Adding Generators Fallbacks]]]
---------------------------

제너레이터의 최신 기능 중에 매우 유용한 플러그인 하나는 fallback 입니다. 예를 들어, [shoulda](https://github.com/thoughtbot/shoulda) 같은 TestUnit에 더하여 기능을 추가하길 원한다고 가정해봅시다. TestUnit은 이미 레일스에 의해 모든 제너레이터에 적용되고 shoulda는 그것의 일부분을 덮어쓰길 원하기 때문에, shoulda를 다른 제너레이터에 다시 적용할 필요가 없습니다. 만약 `Shoulda` namespace에 아무것도 없다면, 레일스가 단순히 `TestUnit`을 사용할 것을 요청할 수 있습니다. [[[One last feature about generators which is quite useful for plugin generators is fallbacks. For example, imagine that you want to add a feature on top of TestUnit like [shoulda](https://github.com/thoughtbot/shoulda) does. Since TestUnit already implements all generators required by Rails and shoulda just wants to overwrite part of it, there is no need for shoulda to reimplement some generators again, it can simply tell Rails to use a `TestUnit` generator if none was found under the `Shoulda` namespace.]]]

우리는 `config/application.rb`를 변경해서 이 동작을 쉽게 시뮬레이트할 수 있습니다. [[[We can easily simulate this behavior by changing our `config/application.rb` once again:]]]

```ruby
config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :shoulda, fixture: false
  g.stylesheets     false

  # Add a fallback!
  g.fallbacks[:shoulda] = :test_unit
end
```

이제, 만약 당신이 Comment scaffold를 생성한다면, shoulda 제너레이터가 호출되는 것을 볼 수 있을 것입니다, 그리고 마지막에는 TestUnit 제너레이터로 되돌아가는 것을 볼 수 있을 것입니다. [[[Now, if you create a Comment scaffold, you will see that the shoulda generators are being invoked, and at the end, they are just falling back to TestUnit generators:]]]

```bash
$ rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20091120151323_create_comments.rb
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
      invoke      shoulda
      create        test/helpers/comments_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/comments.js.coffee
      invoke    scss
```

fallback은 당신의 제너레이터가 코드 재사용을 늘리고 중복을 감소시키면서 하나의 책임만 가지도록 해줍니다. [[[Fallbacks allow your generators to have a single responsibility, increasing code reuse and reducing the amount of duplication.]]]

어플리케이션 템플릿 [[[Application Templates]]]
---------------------


이제 제너레이터가 어플리케이션에서 어떻게 사용되는지 보았습니다, 당신은 제너레이터가 또한 어플리케이션을 만드는데도 사용될 수 있는 것을 알고 있나요? 이 제너레이터의 종류는 "template"로 불립니다. 아래는 Templates API의 짧은 개요이고 자세한 문서를 확인하려면 [Rails Application Templates guide](rails_application_templates.html) 참고하세요. [[[Now that you've seen how generators can be used _inside_ an application, did you know they can also be used to _generate_ applications too? This kind of generator is referred as a "template". This is a brief overview of the Templates API. For detailed documentation see the [Rails Application Templates guide](rails_application_templates.html).]]]

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

위의 템플릿에서 어플리케이션이 rspec-rails와 cucumber-rails gem에 의존하므로 이 젬들이 Gemfile의 test group에 추가하였습니다. 이 때, 우리는 Devise를 설치할 지 말지를 유저에게 물어봅니다. 만약 유저가 y 또는 yes로 응답하면, 템플릿은 Gemfile에 Devise를 추가하고 devise:install 제너레이터를 실행할 것입니다. 이 템플릿은 유저의 입력을 받고 답변에 따라 devise 제너레이터를 실행합니다. [[[In the above template we specify that the application relies on the `rspec-rails` and `cucumber-rails` gem so these two will be added to the `test` group in the `Gemfile`. Then we pose a question to the user about whether or not they would like to install Devise. If the user replies "y" or "yes" to this question, then the template will add Devise to the `Gemfile` outside of any group and then runs the `devise:install` generator. This template then takes the users input and runs the `devise` generator, with the user's answer from the last question being passed to this generator.]]]

이 템플릿이 template.rb 파일로 존재하는 것을 상상해봅시다. 우리는 -m 옵션과 템플릿 파일명을, rails new command의 결과를 변경하기 위해 사용할 수 있습니다. [[[Imagine that this template was in a file called `template.rb`. We can use it to modify the outcome of the `rails new` command by using the `-m` option and passing in the filename:]]]

```bash
$ rails new thud -m template.rb
```

이 command는 Thud 어플리케이션을 생성하고, 생성된 output에 템플릿을 적용할 것입니다. [[[This command will generate the `Thud` application, and then apply the template to the generated output.]]]

템플릿은 꼭 로컬 시스템에 저장될 필요는 없습니다, -m 옵션은 온라인 템플릿을 지원합니다: [[[Templates don't have to be stored on the local system, the `-m` option also supports online templates:]]]

```bash
$ rails new thud -m https://gist.github.com/radar/722911/raw/
```

이 가이드의 마지막 섹션에서는 알려진 좋은 템플릿을 생성하는 방법을 다루지 않는 반면에, 당신이 그것을 스스로 개발할 수 있기 때문에, 당신의 처리에 이용 가능한 메소드들을 확인할 수 있습니다. 이와 동일한 메소드는 제너레이터에서도 이용가능합니다. [[[Whilst the final section of this guide doesn't cover how to generate the most awesome template known to man, it will take you through the methods available at your disposal so that you can develop it yourself. These same methods are also available for generators.]]]

제너레이터 메소드 [[[Generator methods]]]
-----------------

아래는 제너레이터와 템플릿에서 사용할 수 있는 메소드들입니다. [[[The following are methods available for both generators and templates for Rails.]]]

NOTE: Thor가 제공하는 메소드들은 이 가이드에서 다루지 않습니다, 자세한 문서는 [Thor's documentation](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html) 참고하시길 바랍니다. [[[Methods provided by Thor are not covered this guide and can be found in [Thor's documentation](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html)]]]

### `gem`

어플리케이션의 gem 의존성을 지정한다. [[[Specifies a gem dependency of the application.]]]

```ruby
gem "rspec", group: "test", version: "2.1.0"
gem "devise", "1.1.5"
```

이용가능한 옵션들: [[[Available options are:]]]

* `:group` - Gem이 설치되어야할 `Gemfile`의 group [[[The group in the `Gemfile` where this gem should go.]]]
* `:version` - 사용하길 원하는 gem의 버전 [[[The version string of the gem you want to use. Can also be specified as the second argument to the method.]]]
* `:git` - git repository의 URL [[[The URL to the git repository for this gem.]]]

추가할 옵션은 줄의 끝에 넣으면 됩니다: [[[Any additional options passed to this method are put on the end of the line:]]]

```ruby
gem "devise", git: "git://github.com/plataformatec/devise", branch: "master"
```

위의 코드는 `Gemfile` 아래에 라인을 추가합니다. [[[The above code will put the following line into `Gemfile`:]]]

```ruby
gem "devise", git: "git://github.com/plataformatec/devise", branch: "master"
```

### `gem_group`

그룹 안에 gem 항목을 감싼다(해당 그룹에 항목을 추가한다.) [[[Wraps gem entries inside a group:]]]

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### `add_source`

`Gemfile`에 특정 소스를 추가합니다. [[[Adds a specified source to `Gemfile`:]]]

```ruby
add_source "http://gems.github.com"
```

### `inject_into_file`

당신의 파일 안, 명시된 위치에 코드 블록을 삽입합니다. [[[Injects a block of code into a defined position in your file.]]]

```ruby
inject_into_file 'name_of_file.rb', after: "#The code goes below this line. Don't forget the Line break at the end\n" do <<-'RUBY'
  puts "Hello World"
RUBY
end
```

### `gsub_file`

파일 안의 텍스트를 교체합니다. [[[Replaces text inside a file.]]]

```ruby
gsub_file 'name_of_file.rb', 'method.to_be_replaced', 'method.the_replacing_code'
```

이 메소드를 좀 더 정밀하게 만들기 위해 정규표현식이 사용될 수 있습니다. 당신은 또한 파일의 시작과 끝에 코드를 추가하기 위해 append_file과 prepend_file을 사용할 수 있습니다. [[[Regular Expressions can be used to make this method more precise. You can also use append_file and prepend_file in the same way to place code at the beginning and end of a file respectively.]]]

### `application`

application 클래스 선언 후, `config/application.rb`에 줄을 추가합니다. [[[Adds a line to `config/application.rb` directly after the application class definition.]]]

```ruby
application "config.asset_host = 'http://example.com'"
```

이 메소드는 또한 블록 코드를 받을 수도 있습니다. [[[This method can also take a block:]]]

```ruby
application do
  "config.asset_host = 'http://example.com'"
end
```

이용가능한 옵션들: [[[Available options are:]]]

* `:env` - 설정 옵션의 환경을 명시합니다. 만약 블록 구문과 함께 이 옵션을 사용하길 바란다면 추천하는 구문은 아래와 같습니다: [[[Specify an environment for this configuration option. If you wish to use this option with the block syntax the recommended syntax is as follows:]]]

```ruby
application(nil, env: "development") do
  "config.asset_host = 'http://localhost:3000'"
end
```

### `git`

git command를 실행한다. [[[Runs the specified git command:]]]

```ruby
git :init
git add: "."
git commit: "-m First commit!"
git add: "onefile.rb", rm: "badfile.cxx"
```

이 해쉬 값은 특정 git command를 통과합니다. 마지막 예제에서 보여지는 것처럼, 여러 git command는 한 번에 실행할 수 있습니다, 그러나 실행 순서는 지시한 순서대로 동작하리라는 보장은 되지 않습니다. [[[The values of the hash here being the arguments or options passed to the specific git command. As per the final example shown here, multiple git commands can be specified at a time, but the order of their running is not guaranteed to be the same as the order that they were specified in.]]]

### `vendor`

특정 코드를 포함하는 vendor에 파일을 추가합니다. [[[Places a file into `vendor` which contains the specified code.]]]

```ruby
vendor "sekrit.rb", '#top secret stuff'
```

이 메소드는 또한 블록 코드를 받을 수도 있습니다. [[[This method also takes a block:]]]

```ruby
vendor "seeds.rb" do
  "puts 'in ur app, seeding ur database'"
end
```

### `lib`

특정 코드를 포함하는 lib에 파일을 추가합니다. [[[Places a file into `lib` which contains the specified code.]]]

```ruby
lib "special.rb", "p Rails.root"
```

이 메소드는 또한 블록 코드를 받을 수도 있습니다. [[[This method also takes a block:]]]

```ruby
lib "super_special.rb" do
  puts "Super special!"
end
```

### `rakefile`

`lib/tasks` 경로에 Rake 파일을 생성합니다. [[[Creates a Rake file in the `lib/tasks` directory of the application.]]]

```ruby
rakefile "test.rake", "hello there"
```

이 메소드는 또한 블록 코드를 받을 수도 있습니다. [[[This method also takes a block:]]]

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

`config/initializer` 경로에 initializer를 생성합니다. [[[Creates an initializer in the `config/initializers` directory of the application:]]]

```ruby
initializer "begin.rb", "puts 'this is the beginning'"
```

이 메소드는 또한 블록 코드를 받을 수 있습니다. [[[This method also takes a block, expected to return a string:]]]

```ruby
initializer "begin.rb" do
  "puts 'this is the beginning'"
end
```

### `generate`

특정 제너레이터를 실행합니다, 첫번째 인자는 제너레이터의 이름이고 나머지는 제너레이터에 직접 넘겨집니다. [[[Runs the specified generator where the first argument is the generator name and the remaining arguments are passed directly to the generator.]]]

```ruby
generate "scaffold", "forums title:string description:text"
```


### `rake`

특정 Rake task를 실행합니다. [[[Runs the specified Rake task.]]]

```ruby
rake "db:migrate"
```

이용가능한 옵션들: [[[Available options are:]]]

* `:env` - rake task를 실행할 환경을 명시합니다. [[[Specifies the environment in which to run this rake task.]]]
* `:sudo` - `sudo`를 사용하여 실행할지 말지를 결정합니다, 기본값은 false. [[[Whether or not to run this task using `sudo`. Defaults to `false`.]]]

### `capify!`

Capistrano로부터 capify command를 실행합니다 [[[Runs the `capify` command from Capistrano at the root of the application which generates Capistrano configuration.]]]

```ruby
capify!
```

### `route`

`config/routes.rb` 파일에 텍스트를 추가합니다. [[[Adds text to the `config/routes.rb` file:]]]

```ruby
route "resources :people"
```

### `readme`

템플릿의 source_path 안의 파일의 내용을 출력합니다, 보통은 README 파일. [[[Output the contents of a file in the template's `source_path`, usually a README.]]]

```ruby
readme "README"
```
