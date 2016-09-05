


Rails의 애플리케이션 템플릿
===========================

Rails의 애플리케이션 템플리승ㄴ 단순한 Ruby 파일이며, 신규 또는 기존의 Rails 프로젝트에 gem이나 initailizer를 추가하기 위한 DSL을 포함하고 있습니다.

이 가이드의 내용:

* 템플릿을 사용하여 Rails 애플리케이션을 생성/변경하는 방법
* Rails 템플릿 API를 사용하여 재이용 가능한 애플리케이션 템플릿을 개발하는 방법

--------------------------------------------------------------------------------

### 사용법
-----

애플리케이션 템플릿을 사용하기 위해서는 `-m` 옵션을 사용해서 템플릿의 장소를 지정해야 합니다. 전체 경로, 또는 URL, 어느 쪽이든 가능합니다.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

`app:template`를 사용해서, 기존의 Rails 애플리케이션에도 이 템플릿을 적용할 수 있습니다. 템플릿의 위치는 LOCATION 환경 변수를 사용해서 넘길 필요가 있습니다. 여기에서도 파일은 로컬 경로 또는 URL, 어느쪽이든 사용해도 좋습니다.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

템플릿 API
------------

Rails의 템플릿 API는 알기 쉽게 설계되어 있습니다. 다음은 대표적인 Rails 애플리케이션 템플릿입니다.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

다음 절에서, API에서 제공하는 주요 메소드를 간단하게 설명합니다.

### gem(*args)

생성된 `Gemfile` 파일에 지정된 `gem`을 추가합니다.

예를 들어 Rails 애플리케이션이 `bj`와 `nokogiri` gem에 의존한다고 합시다.

```ruby
gem "bj"
gem "nokogiri"
```

Gemfile에 gem을 지정한 것만으로는 설치되지 않는 다는 점을 주의해주세요. 지정한 gem을 인스톨하기 위해서는 `bundle install`을 실행해야합니다.

```bash
bundle install
```

### gem_group(*names, &block)

gem을 요구할 그룹을 지정합니다.

예를 들어 `rspec-rails` gem을 `development` 그룹과 `test` 그룹에서만 쓰이길 바란다면 다음과 같이 작성하세요.

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options = {})

생성된 `Gemfile`에 지정된 소스를 추가합니다.

예를 들어 `"http://code.whytheluckystiff.net"`에 있는 gem을 소스로 사용하고 싶은 경우에는 다음과 같이 작성하세요.

```ruby
add_source "http://code.whytheluckystiff.net"
```

### environment/application(data=nil, options={}, &block)

`config/application.rb` 파일의 `Application` 클래스에 지정된 라인을 추가합니다.

`options[:env]`이 넘겨진 경우에는 `config/environments` 폴더에 있는 그 환경의 파일에 추가합니다.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

`data` 인수 대신에 블럭을 넘길 수 있습니다.

### vendor/lib/file/initializer(filename, data = nil, &block)

생성된 Rails 애플리케이션의 `config/initializers` 폴더에 initializer를 추가합니다.

예를 들어 `Object#not_nil?`와 `Object#not_blank?`라는 메소드를 사용하고 싶은 경우에는 다음과 같이 작성하면 됩니다.

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

마찬가지로 `lib()`는 `lib/` 폴더에 `vendor()`는 `vendor/` 폴더에 각각 파일을 하나 생성합니다.

`file()` 메소드를 사용하면 `Rails.root`로부터 상대 경로를 사용해서 폴더나 파일을 자유롭게 생성합니다.

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

이 코드는 `app/components` 폴더를 생성하고, 그 안에 `foo.rb` 파일을 생성합니다.

### rakefile(filename, data = nil, &block)

지정된 태스크를 포함하는 rake 파일을 `lib/tasks`에 생성합니다.

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

이 코드는 `lib/tasks/bootstrap.rake` 파일을 생성하고, 그 안에 `boot:strap` rake 태스크를 추가합니다.

### generate(what, *args)

인수를 넘겨서 Rails 제너레이터를 실행합니다.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

임의의 명령을 실행합니다. 흔히 말하는 백포트와 동등합니다. 예를 들어, `README.rdoc` 파일을 삭제하는 경우에는 다음과 같이 실행하세요.

```ruby
run "rm README.rdoc"
```

### rake(command, options = {})

Rails 애플리케이션에 있는 rake 태스크를 지정하여 실행합니다. 예를 들어, 데이터베이스의 마이그레이션을 실행하려면 다음과 같이 작성하면 됩니다.

```ruby
rake "db:migrate"
```

Rails의 환경을 지정하여 rake 태스크를 실행할 수도 있습니다.

```ruby
rake "db:migrate", env: 'production'
```

### route(routing_code)

라우팅을 `config/routes.rb` 파일에 하나 추가합니다. 위에서는 scaffold로 person을 생성하고, 이어서 `README.rdoc`을 삭제했습니다. 이번에는 `PeopleController#index`를 애플리케이션의 기본 페이지로 지정해봅시다.

```ruby
route "root to: 'person#index'"
```

### inside(dir)

폴더를 지정하여 명령을 실행합니다. 예를 들어, edge rails의 사본이 있고, 애플리케이션으로부터 거기에 심볼릭 링크를 하나 생성해봅시다.

```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()`는 사용자로부터 입력을 받아서 템플릿에서 이용해야하는 경우에 쓸 수 있습니다. 예를 들어 추가된 새로운 라이브러리에 붙일 이름을 사용자 입력으로 받으려면 다음과 같이 작성하면 됩니다.

```ruby
lib_name = ask("라이브러리에 붙일 이름을 입력해주세요:")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) 또는 no?(question)

템플릿에서 사용자 입력을 바탕으로 처리를 변경하고 싶을 때에 사용합니다. 예를 들어, 지정된 경우에만 Rails를 freeze하고 싶은 경우에는 다음과 같이 작성할 수 있습니다.

```ruby
rake("app:freeze:gems") if yes?("Freeze rails gems?")
# no?(question)는 yes?의 반대 동작
```

### git(:command)

Rails 템플릿에서 임의의 git 명령을 실행합니다.

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### after_bundle(&block)

gem의 번들과 binstub 생성완료 후에 실행하고 싶은 콜백을 등록합니다. 생성한 파일을 버전 관리하는 부분까지 자동화 할 때 유용합니다.

```ruby
after_bundle do
  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end
```

이러한 콜백은 `--skip-bundle`이나 `--skip-spring`을 지정한 경우에도 실행됩니다.

고급 사용법
--------------

애플리케이션 템플릿은 `Rails::Generators::AppGenerator` 인스턴스의 컨텍스트에서 평가됩니다. 여기서 사용되는 `apply` 액션은 [Thor](https://github.com/erikhuda/thor/blob/master/lib/thor/actions.rb#L207)가 제공합니다. 이를 통해서 이 인스턴스를 필요에 따라서 확장하거나, 변경할 수 있습니다.

예를 들어, `source_paths` 메소드를 재정의해서 템플릿의 위치를 지정할 수 있습니다. 이를 통해, `copy_file` 등의 메소드로 템플릿의 위치로부터 상대 경로를 지정할 수 있게 됩니다.

```ruby
def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end
```

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
