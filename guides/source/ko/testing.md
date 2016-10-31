레일스 테스트 가이드
=====================================

여기에서는 애플리케이션을 테스트하기 위해 레일스에 포함된 것들에 관해서 설명합니다.

이 가이드의 내용:

* 레일스 테스트 용어
* 단위, 기능, 통합 테스트 작성하기
* 그 외에 유명한 테스트 방법과 플러그인 소개

--------------------------------------------------------------------------------

레일스 애플리케이션에서 테스트를 만들어야 하는 이유
--------------------------------------------

레일스를 사용하면 테스트를 무척 간단하게 만들 수 있습니다. 테스트 만들기는 모델이나 컨트롤러를 만든 시점에서
테스트의 뼈대를 만드는 것부터 시작됩니다.

테스트를 만들었다면, 그 후로는 그저 실행하기만 하면 되므로 대규모 리팩토링을 하는 경우에 코드가 기대대로
동작하는지 곧바로 확인할 수 있습니다.

레일스의 테스트는 브라우저의 요청을 흉내 내므로, 브라우저를 직접 조작하지
않고 애플리케이션의 응답을 테스트할 수 있습니다.

테스트 도입하기
-----------------------

테스트에 대한 지원은 레일스의 초기 시절부터 포함되어 있습니다. 최근 테스트
기법이 유행하고 있으니 한번 도입해봤다, 처럼 즉흥적으로 도입된 것이 아닙니다.

### 레일스 테스트 준비하기

`rails new` _애플리케이션 이름_을 사용하여 프로젝트를 생성하면 `test` 폴더를
생성합니다. 이 폴더의 내용을 살펴보면 다음과 같을 겁니다.

```bash
$ ls -F test
controllers/    helpers/        mailers/        test_helper.rb
fixtures/       integration/    models/
```

`helpers`, `mailers`, `models` 폴더는 각각 뷰 헬퍼, 메일러, 모델에 대한
테스트를 관리합니다. `controllers` 폴더는 컨트롤러, 라우트, 뷰에 대한 테스트를
관리합니다. 그리고 `integration` 폴더는 컨트롤러 간의 동작에 대한 테스트를
관리합니다.

픽스쳐는 테스트 데이터를 관리하는 방법의 하나입니다. `fixtures` 폴더에서
관리합니다.

`jobs` 폴더는 관련된 테스트가 생성되는 시점에서 생성됩니다.

`test_helper.rb` 파일은 테스트에 대한 설정을 관리합니다.


### 테스트 환경

모든 레일스 애플리케이션은 개발, 테스트, 그리고 배포(production) 환경을
가집니다.

각 환경 설정은 비슷한 방법으로 변경할 수 있습니다. 테스트 환경에 대한 환경
설정은 `config/environments/test.rb`에서 찾을 수 있습니다.

NOTE: 테스트는 `RAILS_ENV=test`에서 동작합니다.

### Minitest

[레일스 시작하기](getting_started.html)에서 `rails generate model`을
사용했습니다. 첫 모델을 만들며 이와 함께 `test` 폴더에 테스트 스텁을
생성했습니다.

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

`test/models/article_test.rb`에 들어있는 기본 스텁은 이렇습니다.

```ruby
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

이 파일을 한줄씩 살펴보면 레일스의 테스트 코드와 용어를 이해하는 데에 도움이 될 겁니다.

```ruby
require 'test_helper'
```

이 파일을 통해 테스트를 실행하기 위한 `test_helper.rb`의 기본 설정을
불러옵니다. 모든 테스트 파일을 만들 때마다 이 파일을 로드하여, 이 파일에
추가된 어떤 메소드든 사용할 수 있도록 할 겁니다.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest` 클래스는 `ActiveSupport::TestCase`를 상속하고 있으므로
_테스트 케이스_를 정의합니다. 그러므로 `ArticleTest`는
`ActiveSupport::TestCase`의 모든 메소드를 사용할 수 있습니다. 앞으로
이 가이드에서는 상속을 통해 얻은 메소드에 대해서 살펴볼 겁니다.

`Minitest::Test`(`ActiveSupport::TestCase`의 부모 클래스)로부터 상속된
클래스에서 `test_`로(대소문자 구분) 시작하는 모든 메소드를 테스트라고 부릅니다.
그러므로 `test_password`나 `test_valid_password`라고 정의된 메소드는 테스트
케이스가 실행될 때 자동으로 실행되는 정상적인 테스트 이름입니다.

또한 레일스는 테스트의 이름과 블록을 받는 `test` 메소드를 추가합니다.
이 메소드는 `test_`로 시작하는 `Minitest::Unit` 메소드를 생성합니다. 그러므로
메소드의 이름을 무엇이라고 지을지 고민하지 않고 다음과 같이 작성할 수 있습니다.

```ruby
test "the truth" do
  assert true
end
```

이는 다음과 같습니다.

```ruby
def test_the_truth
  assert true
end
```

`test` 매크로는 그저 좀 더 읽기 쉬운 테스트 이름을 제공할 뿐입니다.
그러므로 기존의 메소드 정의 방식도 여전히 사용할 수 있습니다.

NOTE: 메소드 이름은 공백을 언더스코어로 대체하여 생성됩니다. 변환 결과는 유효한 루비의 식별자가 아니어도 되므로, 이름은 마침표와 같은 특수한 문자를 사용할 수 있습니다. 이는 루비가 기술적으로 어떤 문자열이든 메소드 이름으로 사용할 수 있기 때문입니다. 이는 `defind_method`와 `send`를 적절히 사용하면 됩니다만 편의상 일반적으로 이름에는 약간의 제약사항이 있습니다.

다음으로 첫 단언을 보죠.

```ruby
assert true
```

단언은 어떤 객체(혹은 표현식)가 기대한 값을 반환하는지 확인하는 코드입니다.
예를 들어, 단언은 다음과 같은 사실을 확인합니다.

* 값 A가 값 B와 같은지?
* 이 객체가 nil인지?
* 이 코드가 에러를 던지는지?
* 사용자의 비밀번호가 5자 이상인지?

모든 테스트는 하나 이상의 단언을 포함해야합니다만 몇 개의 단언을 사용해야
하는지에 대한 제약은 없습니다. 단, 모든 단언이 사실이어야만 테스트를
통과한 것으로 판단합니다.

#### 실패하는 테스트

실패한 테스트가 어떻게 보고되는지 확인하기 위해, `article_test.rb`에 실패하는 테스트를 추가합시다.

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

새로 추가한 테스트를 실행합시다(아래에서 `6`은 테스트가 정의되어 있는 줄번호입니다).

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips

```

출력에서 `F`는 실패를 의미합니다. `Failure` 밑에서 실패한 테스트의 이름을 볼
수 있습니다. 그 뒤에서 스택 트레이스와 단언의 기댓값과 실제값에 관해서
설명하는 메시지를 볼 수 있습니다. 기본 단언 메시지는 에러가 어디에 있는지
찾기에 충분한 정보를 제공합니다. 실패 메시지를 좀 더 읽기 좋게 만들려면 모든
단언이 제공하는 메시지 인수를 이용할 수 있습니다.

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

이 테스트를 실행하면 좀 더 친절한 메시지를 볼 수 있습니다.

```bash
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

이제 테스트를 통과하기 위해 모델에 _title_ 검증을 추가합시다.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

그러면 테스트가 성공할 것입니다. 테스트를 실행해서 결과를 확인해보죠.

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

지금까지 원하는 기능을 실행하지 못하고 실패하는 테스트를 작성하고, 이 테스트를
통과하는 데 필요한 기능을 구현했습니다. 소프트웨어 개발에서는 이러한 접근법을
[_테스트 주도 개발_(TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment)이라
부릅니다.

#### 에러의 보고 형태

에러가 어떻게 보고 되는지 확인하기 위해, 에러를 포함하는 테스트를 작성해봅시다.

```ruby
test "should report error" do
  # some_undefined_variable은 정의되지 않은 메소드입니다.
  some_undefined_variable
  assert true
end
```

테스트를 실행하면 좀 더 많은 출력을 확인할 수 있습니다.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

결과에 있는 'E'는 테스트에 에러가 있었다는 의미입니다.

NOTE: 각 테스트 메소드는 에러나 단언의 실패를 탐지하면 실행을 중지하고, 테스트 스위트는 다음 메소드를 실행합니다.
모든 테스트는 임의의 순서로 실행됩니다.
[`config.active_support.test_order` 옵션](configuring.html#active-support-설정하기)을
사용하여 테스트 순서를 변경할 수 있습니다.

테스트가 실패했을 때 백트레이스를 볼 수 있을 겁니다. 레일스는 실제 애플리케이션 내부의 백트레이스만을
보여주도록 결과를 필터링합니다. 이를 통해 애플리케이션 코드에 집중할 수 있기 때문입니다. 하지만 때때로
전체 백트레이스를 보고 싶은 경우가 있습니다. 이럴 때에는 `-b` (또는 `--backtrace`) 옵션을 넘기세요.

```bash
$ bin/rails test -b test/models/article_test.rb
```

이 테스트를 통과하게끔 하고 싶다면 `assert_raises`를 사용하면 됩니다.

```ruby
test "should report error" do
  # some_undefined_variable은 정의되지 않은 메소드입니다.
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

이제 테스트는 통과할 겁니다.

### 사용 가능한 단언

이제부터 사용 가능한 단언 중 일부를 살펴볼 겁니다. 단언은 테스트의 일벌과 같습니다. 이들은 애플리케이션이
계획한 대로 잘 동작하고 있는지 하나씩 확인합니다.

여기에 레일스의 기본 테스트 라이브러리인 [`Minitest`](https://github.com/seattlerb/minitest)에서
사용할 수 있는 단언 일부가 있습니다. `[msg]` 매개변수는 테스트 실패 메시지를 좀 더 명확하게 만들 때
사용하는 옵션 문자열입니다.

| 단언                                                              | 목적     |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | `test`는 참이라고 보장함.|
| `assert_not( test, [msg] )`                                      | `test`는 거짓이라고 보장함.|
| `assert_equal( expected, actual, [msg] )`                        | `expected == actual`은 참이라고 보장함.|
| `assert_not_equal( expected, actual, [msg] )`                    | `expected != actual`은 참이라고 보장함.|
| `assert_same( expected, actual, [msg] )`                         | `expected.equal?(actual)`은 참이라고 보장함.|
| `assert_not_same( expected, actual, [msg] )`                     | `expected.equal?(actual)`은 거짓이라고 보장함.|
| `assert_nil( obj, [msg] )`                                       | `obj.nil?`은 참이라고 보장함.|
| `assert_not_nil( obj, [msg] )`                                   | `obj.nil?`은 거짓이라고 보장함.|
| `assert_empty( obj, [msg] )`                                     | `obj`는 `empty?`가 참이라고 보장함.|
| `assert_not_empty( obj, [msg] )`                                 | `obj`는 `empty?`가 거짓이라고 보장함.|
| `assert_match( regexp, string, [msg] )`                          | 문자열이 정규 표현식에 매칭한다고 보장함.|
| `assert_no_match( regexp, string, [msg] )`                       | 문자열이 정규 표현식에 매칭하지 않는다고 보장함.|
| `assert_includes( collection, obj, [msg] )`                      | `obj`는 `collection`에 포함된다고 보장함.|
| `assert_not_includes( collection, obj, [msg] )`                  | `obj`는 `collection`에 포함되지 않는다고 보장함.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | 숫자 `expected`와 숫자 `actual`의 차이가 `delta` 이내라고 보장함.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | 숫자 `expected`와 숫자 `actual`의 차이가 `delta` 이상이라고 보장함.|
| `assert_throws( symbol, [msg] ) { block }`                       | 주어진 블록이 심볼을 던질 것이라고 보장함.|
| `assert_raises( exception1, exception2, ... ) { block }`         | 주어진 블록이 주어진 예외를 발생시킬 것이라고 보장함.|
| `assert_instance_of( class, obj, [msg] )`                        | `obj`는 `class`의 객체라고 보장함.|
| `assert_not_instance_of( class, obj, [msg] )`                    | `obj`는 `class`의 객체가 아니라고 보장함.|
| `assert_kind_of( class, obj, [msg] )`                            | `obj`는 `class`의 객체거나, 그로부터 상속되었다고 보장함.|
| `assert_not_kind_of( class, obj, [msg] )`                        | `obj`는 `class`의 객체가 아니거나, 그로부터 상속되지 않았다고 보장함.|
| `assert_respond_to( obj, symbol, [msg] )`                        | `obj`는 `symbol`에 반응한다는 것을 보장함.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | `obj`는 `symbol`에 반응하지 않는다는 것을 보장함.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | `obj1.operator(obj2)`는 참이라고 보장함.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | `obj1.operator(obj2)`는 거짓이라고 보장함.|
| `assert_predicate ( obj, predicate, [msg] )`                     | `obj.predicate`는 참이라고 보장함. e.g. `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | `obj.predicate`는 거짓이라고 보장함. e.g. `assert_not_predicate str, :empty?`|
| `assert_send( array, [msg] )`                                    | `array[0]`의 객체의 `array[1]`메소드를 `array[2..-1]`를 매개변수로 호출했을 때 결과가 참임을 보장함. e.g. assert_send [@user, :full_name, 'Sam Smith']|
| `flunk( [msg] )`                                                 | 실패를 보장함. 테스트가 미완성임을 표시할 때에 유용함.|

이 단언들이 미니테스트가 지원하는 것들입니다. 완전하고, 최신의 목록을 확인하려면 [Minitest API](http://docs.seattlerb.org/minitest/),
특히 [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)를 읽어보세요.

테스트 프레임워크의 모듈식 구성의 특성 덕분에 자신만의 단언을 만들 수 있습니다. 사실 그것이 바로 레일스에서
하는 방식입니다. 레일스에서는 테스트를 좀 더 쉽게 하기 위한 특별한 단언들을 포함하고 있습니다.

NOTE: 단언 만들기는 좀 더 어려운 주제이므로 이 가이드에서 다루지 않습니다.

### 레일스 전용 단언

레일스는 `minitest` 프레임워크에 더불어 몇 가지 단언을 추가로 제공합니다.

| 단언                                                                               | 목적     |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | 블록을 실행하기 전후에 평가한 표현식의 결과로 반환된 숫자의 차이를 테스트함.|
| [`assert_no_difference(expressions, message = nil, &block)`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | 블록을 실행하기 전후에 평가한 표현식의 결과로 반환된 숫자는 같다고 보장함.|
| [`assert_nothing_raised { block }`](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html#method-i-assert_nothing_raised) | 주어진 블록에서 예외가 발생하지 않는다는 것을 보장함.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | 주어진 경로를 올바르게 라우팅하고, (expected_options 해시로 넘겨진) 해석 옵션이 경로와 일치할 것이라고 보장함. 레일스는 expected_options로 받은 라우팅을 인식한다는 것을 보장함.|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | 주어진 옵션은 주어진 경로를 생성할 때에 사용된다는 것을 보장함. 이는 assert_recognizes와 정 반대임. extra 매개변수는 쿼리 문자열에 추가 정보가 있는 경우 그 매개변수의 이름과 값을 요청에 넘기기 위해서 사용함.|
| [`assert_response(type, message = nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | 응답이 특정 상태 코드와 함께 반환된다고 보장함. 200-299인 경우 `:success`, 300-399는 `:redirect`, 404는 `:missing`, 500-599는 `:error`로 표현할 수 있음. 또는 명시적으로 특정 상태 코드나 이를 가리키는 심볼을 넘길 수 있음. 더 많은 설명은 [상태 코드의 전체 목록](http://rubydoc.info/github/rack/rack/master/Rack/Utils#HTTP_STATUS_CODES-constant)과 어떻게 [맵핑](http://rubydoc.info/github/rack/rack/master/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant)이 동작하는지 확인할 것.|
| [`assert_redirected_to(options = {}, message=nil)`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | 넘겨진 옵션이 마지막에 실행된 액션의 리다이렉션과 매칭한다고 보장. 이 매칭은 부분적이어서 `assert_redirected_to(controller: "weblog")`는 `redirect_to(controller: "weblog", action: "show")`와 매칭함. 또는 `assert_redirected_to root_path`처럼 이름이 있는 라우팅 헬퍼나 `assert_redirected_to @article`처럼 액티브 레코드 객체를 넘길 수도 있음.|

다음 장에서 이러한 단언들의 사용법을 보도록 하죠.

### 테스트 케이스에 대한 간단한 설명

`Minitest::Assertions`에 들어있는 `assert_equal`과 같은 모든 기본 단언은 직접 만든 테스트
클래스에서도 사용할 수 있습니다. 사실 레일스는 상속할 수 있는 테스트 클래스를 제공합니다.

* [`ActiveSupport::TestCase`](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](http://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](http://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActionDispatch::IntegrationTest`](http://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActiveJob::TestCase`](http://api.rubyonrails.org/classes/ActiveJob/TestCase.html)

각 클래스는 `Minitest::Assertions`를 포함하여 기본적인 단언을 모두 사용할 수 있습니다.

NOTE: `Minitest`에 대한 더 자세한 설명은 [문서](http://docs.seattlerb.org/minitest)를 확인하세요.

### 레일스 테스트 러너

`bin/rails test` 명령을 통해서 모든 테스트를 한 번에 실행할 수 있습니다.

또는 `bin/rails test`에 파일명을 넘겨서 특정 파일에 있는 테스트만을 실행할 수도 있습니다.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

이는 테스트 케이스에 있는 모든 테스트 메소드를 실행합니다.

아니면 `-n`이나 `--name` 옵션을 사용해 테스트 케이스의 특정 테스트 메소드만을 실행할 수 있습니다.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

줄번호를 이용해 테스트 하나만을 실행할 수 있습니다.

```bash
$ bin/rails test test/models/article_test.rb:6 # 해당 줄의 테스트를 실행
```

경로를 지정해서 폴더에 존재하는 모든 테스트를 실행하는 것도 가능합니다.

```bash
$ bin/rails test test/controllers # 특정 폴더 내의 모든 테스트를 실행
```

테스트 러너는 빠른 실패, 테스트 출력 지연 등 많은 기능을 제공합니다. 다음 명령을 통해서 테스트 러너의
문서를 확인해보세요.

```bash
$ bin/rails test -h
minitest options:
    -h, --help                       Display this help.
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride

Usage: bin/rails test [options] [files or directories]
You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

Rails options:
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
```

테스트 데이터베이스
-----------------

거의 모든 레일스 애플리케이션은 데이터베이스와 밀접하게 동작하므로, 그 결과, 테스트에서도 데이터베이스가
필요합니다. 효율적인 테스트를 작성하기 위해서 어떻게 데이터베이스를 준비하는지, 샘플 데이터를 사용하는지
이해해야 합니다.

모든 레일스 애플리케이션은 개발, 테스트, 배포 환경을 가지고 있습니다. 각 환경에 대한 데이터베이스 설정은
`config/database.yml`에서 볼 수 있습니다.

테스트 데이터베이스는 고립된 환경에서 테스트 데이터를 준비하고 사용할 수 있도록 해줍니다. 이를 통해서
개발용 또는 배포용 데이터베이스에 있는 데이터를 걱정하지 않고, 자유롭데 데이터를 수정할 수 있습니다.


### 테스트 데이터베이스 스키마 관리하기

테스트를 실행하기 위해서, 우선 테스트 데이터베이스가 현재 스키마를 가져와야 합니다. 테스트 헬퍼는
아직 실행되지 않은 마이그레이션이 있는지 확인하고, `db/schema.rb`나 `db/structure.sql`를
불러오려고 시도합니다. 만약 실행되지 않은 마이그레이션이 있다면, 에러가 발생할 겁니다. 일반적으로
이런 경우에는 스키마가 완전히 동기되지 않은 상태일 가능성이 높습니다. 개발용 데이터베이스에 마이그레이션을
실행(`bin/rails db:migrate`)하여 스키마를 최신으로 유지합시다.

NOTE: 이미 실행된 마이그레이션에 변경이 있었다면 테스트 데이터베이스는 새로 생성되어야 합니다.
`bin/rails db:test:prepare`를 실행하여 해결할 수 있습니다.

### 픽스쳐

좋은 테스트를 위해서는 좋은 테스트 데이터를 준비해야 합니다.
레일스에서는 이것을 픽스쳐를 정의하고 수정하는 것으로 관리할 수 있습니다.
전체적인 설명은 [픽스쳐 API](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)에서 확인할 수 있습니다.

#### 픽스쳐는 뭔가요?

_픽스쳐_는 샘플 데이터를 가리키는 표현입니다. 픽스쳐는 테스트가 실행되기 전에
미리 정의한 데이터를 데이터베이스에 추가할 수 있습니다. 픽스쳐는
데이터베이스에 독립적이며 YAML로 작성됩니다. 이는 모델당 하나의 파일로
구성됩니다.

NOTE: 픽스쳐는 테스트에서 필요한 모든 객체를 생성하도록 디자인된 것이 아니며,
일반적인 상황에서 필요한 기본 데이터를 관리할 때에 유용합니다.

픽스쳐 파일은 `test/fixtures` 폴더에서 관리됩니다. `rails generate model`로
새 모델을 만들면, 레일스가 픽스쳐 스텁을 이 폴더에 자동으로 생성합니다.

#### YAML

YAML 형식의 픽스쳐는 샘플 데이터를 기술하는 인간 친화적인 방식입니다. 이 픽스쳐들은 **.yml** 확장자를
가집니다(i.e. `users.yml`).

샘플 YAML 픽스쳐를 보시죠.

```yaml
# YAML 주석은 이렇게 작성합니다.
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

각 픽스쳐는 이름과 콜론으로 시작되며, 콜론으로 구분된 키-값 쌍을 들여쓴 형태로 되어 있습니다. 일반적으로
각 레코드는 빈 줄로 구분합니다. 픽스쳐 파일에는 # 으로 시작하는 주석을 작성할 수 있습니다.

만약 [관계](/association_basics.html)를 사용하고 있다면, 간단하게 다른 픽스쳐를 이름을 사용해
참조할 수 있습니다. 다음은 `belongs_to`/`has_many` 관계를 나타내는 예제입니다.

```yaml
# In fixtures/categories.yml
about:
  name: About

# In fixtures/articles.yml
first:
  title: Welcome to Rails!
  body: Hello world!
  category: about
```

`fixtures/articles.yml`에서 `first`의 `category`가 `about`라는 값을 가지고 있습니다.
레일스는 이를 통해서 `fixtures/categories.yml`에 있는 `about`을 사용합니다.

NOTE: 이름을 사용하여 참조하는 경우에는 `id:` 속성을 사용하지 않고 픽스쳐의 이름을 사용할 수 있습니다. 레일스는 실행할 때에 일관성을 유지하게끔 자동으로 기본키를 할당합니다. 픽스쳐에서 관계(association)의 동작에 대한 자세한 설명은 [Fixtures API](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)를 참조하세요.

#### ERB

ERB는 템플릿에서 루비 코드를 작성할 수 있게 해줍니다. YAML 픽스쳐 형식의 파일은 레일스가 로드할 때에
ERB에 의한 전처리를 사용할 수 있습니다. ERB를 활용하면 루비를 사용하여 픽스쳐를 생성할 수 있습니다.
예를 들어, 다음과 같이 천 명의 사용자를 생성할 수 있습니다.

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### 픽스쳐의 동작

레일스는 `text/fixtures` 폴더에 들어있는 모든 픽스쳐를 자동으로 불러옵니다. 불러오는 작업은 다음과
같은 순서로 이루어집니다.

1. 픽스처에 대응하는 테이블에 존재하는 모든 데이터를 지웁니다.
2. 픽스쳐의 데이터를 테이블에 추가합니다.
3. 픽스쳐에 직접 접근하고 싶은 경우에 메소드에 픽스쳐 데이터를 덤프합니다.

TIP: 데이터베이스에 존재하는 데이터를 지우기 위해서 레일스는 참조 의존성 트리거(외래키나 제약 조건)를 비활성화합니다.
만약 테스트를 실행할 때 권한 에러가 발생한다면, 테스트 데이터베이스의 사용자가 이러한 트리거를
비활성화할 수 있는 권한이 있는지 확인하세요. (PostgreSQL에서는 superuser 만 이러한 트리거를
비활성화할 수 있습니다. PostgreSQL 권한에 대해서는 [여기](http://blog.endpoint.com/2012/10/postgres-system-triggers-error.html)를 참고하세요).

#### 픽스쳐는 액티브 레코드 객체

픽스쳐는 액티브 레코드 객체입니다. 위의 3번째에서 언급했듯, 픽스쳐는 테스트 케이스의 스코프에서
메소드로 불러올 수 있기 때문에, 객체에 직접 접근할 수 있습니다.

```ruby
# david라는 이름의 픽스쳐를 User 객체로 반환한다
users(:david)

# id로 호출된 david의 속성을 반환한다
users(:david).id

# User 클래스의 메소드도 사용할 수 있다
david = users(:david)
david.call(david.partner)
```

여러 픽스쳐를 한 번에 가져오고 싶은 경우, 픽스쳐의 이름 목록을 넘기면 됩니다.

```ruby
# david와 steve 픽스쳐를 포함하는 배열을 반환한다
users(:david, :steve)
```


모델 테스트하기
-------------


모델 테스트는 애플리케이션의 다양한 모델들을 테스트합니다.

레일스 모델 테스트는 `test/models` 폴더에 저장되어 있습니다. 레일스는 모델 테스트를 생성하기 위한
제너레이터를 제공합니다.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

모델 테스트는 `ActionMailer::TestCase`와 같은 부모 클래스를 가지지 않는 대신
[`ActiveSupport::TestCase`](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)를 상속합니다.


통합 테스트하기
-------------------

통합 테스트는 애플리케이션의 다양한 부분들의 상호작용을 테스트할 때 사용됩니다. 일반적으로 애플리케이션의 중요한 작업 흐름을 테스트합니다.

레일스 통합 테스트를 만들기 위해서 `test/integration` 폴더를 사용합니다. 레일스는 통합 테스트의
뼈대를 만들어주는 제너레이터를 제공합니다.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

생성된 통합 테스트 파일은 다음과 같습니다.

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

테스트는 `ActionDispatch::IntegrationTest`를 상속하고 있습니다. 이는 통합 테스트에서 유용하게
사용할 수 있는 헬퍼들을 제공해줍니다.

### 통합 테스트에서 사용할 수 있는 헬퍼

표준 테스트 헬퍼에 더해, `ActionDispatch::IntegrationTest`를 상속하면 통합 테스트를 작성할
때에 유용한 헬퍼를 사용할 수 있습니다. 간단하게 3종류의 헬퍼를 살펴봅시다.

통합 테스트 러너에 대해서는 [`ActionDispatch::Integration::Runner`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)를 참고하세요.

요청을 시도할 때, [`ActionDispatch::Integration::RequestHelpers`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)를 사용할 수 있습니다.

세션이나 통합 테스트의 상태를 수정하고 싶다면 [`ActionDispatch::Integration::Session`](http://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)를 참조하세요.

### 통합 테스트 구현하기

블로그 애플리케이션의 통합 테스트를 작성해봅시다. 새 글을 생성하는 시나리오를 고려하고, 모든 것이
잘 동작하는지 확인하겠습니다.

우선 통합 테스트의 뼈대를 생성합시다.

```bash
$ bin/rails generate integration_test blog_flow
```

이 명령은 최소한의 테스트 파일을 생성해줄 것입니다. 출력은 다음과 같습니다.

```bash
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

그럼 이제 테스트를 작성해봅시다.

```ruby
require 'test_helper'

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

`assert_select`로 요청이 돌려받은 HTML에 질의하는 법에 대해서는 "뷰 테스트하기" 절에서 살펴볼 것입니다.
이는 요청의 응답에 특정 HTML 요소와 그 내용물을 확인할 때에 쓰입니다.

루트 페이지를 방문했을 때 `welcome/index.html.erb`가 랜더링 된 모습을 볼 수 있어야 합니다.
그러므로 이 테스트는 통과할 것입니다.

#### 글 만들기

블로그에서 새 글을 만들고 그 글을 볼 수 있는지 테스트해보죠.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

이해할 수 있도록 하나씩 살펴봅시다.

우선 Articles 컨트롤러의 `:new` 액션을 실행합니다. 이 응답은 반드시 성공적이어야 합니다.

그러고 나서 Articles 컨트롤러의 `:create` 액션에 POST 요청을 생성합니다.

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

요청 뒤에 오는 두 줄은 새 글이 생성되었을 때 발생할 리다이렉션을 처리하는 코드입니다.

NOTE: 리다이렉션 이후에 추가로 요청을 실행할 생각이라면 `follow_redirect!`를 잊지 말고 호출하세요.

마지막으로 응답이 성공적인지 확인하고, 새 글이 보이는 상태인지 확인합니다.

#### 더 나아가기

블로그에 방문하고, 새 글을 생성하는 무척 작은 시나리오를 성공적으로 테스트했습니다. 더 나아가고 싶다면,
덧글 달기, 글 지우기, 덧글 수정하기 등을 테스트할 수 있을 겁니다. 통합 테스트는 애플리케이션의 모든 종류의
시나리오를 실험해볼 수 있는 훌륭한 방법입니다.


컨트롤러의 기능 테스트
-------------------------------------

레일스에서는 컨트롤러의 다양한 액션을 테스트하기 위해 기능 테스트를 작성합니다. 컨트롤러는 애플리케이션에 대한
웹 요청을 받고, 뷰를 랜더링하는 것으로 응답합니다. 기능 테스트를 만든다는 것은 액션이 요청을 어떻게 다루고
어떤 결과 또는 응답, 때때로는 HTML 뷰를 돌려줄지 테스트한다는 의미입니다.

### 기능 테스트에 포함해야 할 것

다음과 같은 내용을 테스트해야 합니다.

* 요청이 성공적이었는지?
* 사용자가 올바른 페이지로 리다이렉트 되었는지?
* 사용자가 성공적으로 인증되었는지?
* 응답 템플릿에 올바른 객체가 저장되었는지?
* 뷰에서 사용자에게 적합한 메시지를 띄웠는지?

액션에서 기능 테스트를 확인하는 가장 간단한 방법은 스캐폴드 제너레이터를 사용하여 컨트롤러를 생성하는 것입니다.

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

이 명령은 `Articles` 리소스를 위한 컨트롤러와 테스트를 생성합니다. `test/controllers` 폴더의
`articles_controller_test.rb`을 열어 생성된 내용을 확인할 수 있습니다.

이미 컨트롤러가 있어서 기본 액션들에 대한 테스트만 생성하고 싶은 경우에는 다음 명령을 사용할 수 있습니다.

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create test/controllers/articles_controller_test.rb
...
```

`articles_controller_test.rb` 파일의 `test_should_get_index`를 살펴보죠.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

레일스는 `test_should_get_index` 테스트에서 `index`라고 불리는 액션에 대한 요청을 흉내 내고,
이 요청이 성공적이고, 올바른 응답을 생성했음을 확인합니다.

`get` 메소드는 요청을 실행하고 결과를 `@response`에 생성합니다. 이 메소드는 6개의 인자를 받을 수 있습니다.

* 요청을 보낼 컨트롤러의 액션. 문자열이나 라우팅 헬퍼(i.e. `articles_url`)를 받을 수 있습니다.
* `params`: 액션에 넘겨줄 매개변수의 해시(e.g. 쿼리 문자열 매개변수나 article 변수).
* `headers`: 요청과 함께 넘길 헤더를 설정.
* `env`: 필요한 경우 요청 환경 변수를 변경할 때 사용.
* `xhr`:요청이 Ajax 요청인지 아닌지 지정. true이면 Ajax로 간주.
* `as`: 요청의 content type을 지정. `:json`은 기본으로 사용할 수 있음.

모든 키워드 인수들은 옵션입니다.

Example: `:show` 액션을 `params`의 `id`에 12를 넘기고 `HTTP_REFERER` 헤더를 설정하여 호출:

```ruby
get :show, params: { id: 12 }, headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Another example: `:update` 액션을 `params`의 `id`에 12를 넘기고 Ajax 요청으로 호출:

```ruby
patch update_url, params: { id: 12 }, xhr: true
```

NOTE: `articles_controller_test.rb`에서 `test_should_create_article` 테스트는 모델 레벨의 검증이 추가되었기 때문에 실패할 것입니다.

`articles_controller_test.rb`의 `test_should_create_article` 테스트를 변경하여 통과할 수 있게 만들어 봅시다.

```ruby
test "should create article" do
  assert_difference('Article.count') do
    post articles_url, params: { article: { body: 'Rails is awesome!', title: 'Hello Rails' } }
  end

  assert_redirected_to article_path(Article.last)
end
```

이제 모든 테스트를 통과할 수 있습니다.

### 기능 테스트에서 사용 가능한 요청의 형식

HTTP 프로토콜에 익숙하다면 `get`이 요청의 형식이라는 것을 이해하고 있을 것입니다. 레일스의 기능 테스트에서는
다음 6개의 요청을 지원합니다.

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

모든 요청의 형식은 실제로 사용하는 것들과 동등합니다. 일반적인 C.R.U.D 애플리케이션에서는
`get`, `post`, `put`, `delete`를 가장 자주 사용할 겁니다.

NOTE: 기능 테스트는 액션이 특정 요청 형식을 지원하는지 확인하기보다, 결과에 집중하기 위한 것입니다.
이러한 경우를 위해 요청 테스트가 존재하므로, 그쪽을 이용해주세요.

### XHR(AJAX) 요청 테스트하기

AJAX 요청을 테스트하기 위해서 `get`, `post`, `patch`, `put`, `delete` 메소드의 옵션에
`xhr: true`를 넘기세요.

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal 'hello world', @response.body
  assert_equal "text/javascript", @response.content_type
end
```

### 3개의 해시

요청이 만들어지고 처리되면, 3개의 해시 객체를 사용할 수 있게 됩니다.

* `cookies` - 모든 쿠키
* `flash` - flash에 포함된 모든 객체
* `session` - 세션에 들어있는 모든 객체

이들은 일반 해시 객체와 마찬가지로, 문자열 키를 사용하여 값에 접근할 수 있습니다. 또는 심볼을 사용해서도
접근할 수 있습니다.

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### 사용 가능한 인스턴스 변수

기능 테스트에서 요청이 생성된 이후에 다음의 3개의 변수를 사용할 수 있습니다.

* `@controller` - 요청을 처리한 컨트롤러
* `@request` - 요청 객체
* `@response` - 응답 객체


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
        
    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body    
  end
end
```

### 헤더와 CGI 변수 설정하기

[HTTP 헤더](http://tools.ietf.org/search/rfc2616#section-5.3)와
[CGI 변수](http://tools.ietf.org/search/rfc3875#section-4.1)는 헤더에 넘길 수 있습니다.

```ruby
# HTTP 헤더 설정하기
get articles_url, headers: { "Content-Type": "text/plain" } # 커스텀 헤더를 사용하는 요청을 흉내 낸다

# CGI 변수 사용하기
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # 커스텀 환경 변수를 사용하는 요청을 흉내 낸다
```

### `flash` 테스트하기

위에서 이야기했던 3개의 해시 중 하나가 `flash`였습니다.

블로그 애플리케이션에서 누군가가 성공적으로 새 글을 만들었을 때 `flash` 메시지를 추가하고 싶다고 합시다.

`test_should_create_article` 테스트에 이 새로운 상황을 추가해보죠.

```ruby
test "should create article" do
  assert_difference('Article.count') do
    post article_url, params: { article: { title: 'Some title' } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal 'Article was successfully created.', flash[:notice]
end
```

테스트를 실행하면 다음과 같은 실패를 볼 수 있습니다.

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

이제 컨트롤러에서 flash 메시지를 구현합시다. `:create` 액션은 이렇게 변경될 겁니다.

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = 'Article was successfully created.'
    redirect_to @article
  else
    render 'new'
  end
end
```

그러면 이제 테스트가 통과합니다.

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 통합하기

지금까지 Articles 컨트롤러에서는 `:index`, `:new`, `:create` 액션을 테스트했습니다.
이미 존재하는 데이터는 어떻게 다루면 될까요?

`:show` 액션을 위한 테스트를 작성해봅시다.

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

이전에 픽스쳐에서 했던 이야기를 떠올려보세요.
`articles()` 메소드는 Article의 픽스쳐에 접근할 수 있게 해줍니다.

존재하는 글을 지우는 것은 어떨까요?

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference('Article.count', -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

이미 존재하는 글을 변경하는 테스트를 추가할 수도 있습니다.

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # 변경된 데이터를 가져와서 제목이 변경되었는지 확인하기 위해서 리로드
  article.reload
  assert_equal "updated", article.title
end
```

지금 작성한 3개의 테스트의 중복된 부분을 발견할 수 있을 겁니다. 이들은 모두 같은 Article 픽스쳐 데이터를
사용하고 있습니다. 우리는 이 코드를 `ActiveSupport::Callbacks`에서 제공하는 `setup`과
`teardown` 메소드를 사용하여 D.R.Y.하게 만들 수 있습니다.

이제 테스트는 다음과 같은 모습이 됩니다. 여기에서는 다른 테스트들을 생략했습니다.

```ruby
require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # 모든 테스트를 실행하기 전에 호출된다
  setup do
    @article = articles(:one)
  end

  # 모든 테스트를 실행한 뒤에 호출된다
  teardown do
    # 컨트롤러가 캐시를 사용하고 있다면 테스트가 끝난 후에 캐시를 비우는 것도 좋습니다
    Rails.cache.clear
  end

  test "should show article" do
    # @article 인스턴스 변수를 재활용
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # 변경된 데이터를 가져와서 제목이 변경되었는지 확인하기 위해서 리로드
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

레일스의 다른 콜백들과 마찬가지로, `setup`과 `teardown` 메소드에는 블록이나 람다,
심볼로 된 메소드 이름을 넘길 수 있습니다.

### 테스트 헬퍼

코드 중복을 피하기 위해 자신만의 테스트 헬퍼를 추가할 수 있습니다.
로그인 헬퍼는 좋은 예제가 될 겁니다.

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require 'test_helper'

class ProfileControllerTest < ActionDispatch::IntegrationTest

  test "should show profile" do
    # 모든 컨트롤러 테스트 케이스에서 헬퍼를 사용할 수 있습니다
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

라우팅 테스트하기
--------------

레일스 애플리케이션의 다른 모든 것들과 마찬가지로, 라우트도 테스트할 수 있습니다. 라우트 테스트는 `test/controllers/`나 컨트롤러 테스트의 일부로 포함할 수 있습니다.

NOTE: 애플리케이션이 복잡한 라우트를 가지고 있다면, 레일스는 이를 위한 유용한 헬퍼를 여럿 제공합니다.

레일스에서 사용가능한 라우팅 단언에 대한 정보는 API 문서의 [`ActionDispatch::Assertions::RoutingAssertions`](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html)를 참고해주세요.

뷰 테스트하기
-------------

요청에대한 응답을 테스트하기 위해서 HTML 요소의 존재 여부나 내용물을 확인하는 것은 애플리케이션의 뷰를 테스트하는 일반적인 방법입니다.
라우팅 테스트처럼 뷰 테스트는 `test/controllers/`나 컨트롤러 테스트의 일부로 포함될 수 있습니다. `assert_select` 메소드는
간단하지만 강력한 문법을 사용하여 응답에 있는 HTML 요소에 대해 질의할 수 있습니다.

`assert_select`에는 두 가지 형태가 있습니다.

`assert_select(selector, [equality], [message])`는 셀렉터로 지정한 요소가 조건에 일치한다고 보장합니다. 셀렉터는 CSS 셀렉터 표현식 문자열이거나 대입값을 가지는 표현식일 수 있습니다.

`assert_select(element, selector, [equality], [message])`는 _주어진 요소_(`Nokogiri::XML::Node`나
`Nokogiri::XML::NodeSet`)와 그 자식 요소 내에서 셀렉터로 지정된 모든 요소가 조건에 일치한다고 보장합니다.

예를 들어 응답의 title 태그의 내용물을 검증해보죠.

```ruby
assert_select 'title', "Welcome to Rails Testing Guide"
```

`assert_select` 블럭을 중첩하여 사용할 수도 있습니다.

다음 예제에서는 외부 블록으로 선택된 모든 요소에 대해서 `li.menu_item`를 선택하는 안쪽의
`assert_select`를 실행합니다.

```ruby
assert_select 'ul.navigation' do
  assert_select 'li.menu_item'
end
```

또는, 선택된 요소의 컬렉션은 열거 가능하므로 각 요소에 대해서 `assert_select`를 반복적으로 호출할 수 있습니다.

예를 들어 응답이 2개의 순서가 있는 목록을 가지고 있고 각각이 4개의 목록 요소를 가진다고 하면,
다음 테스트는 모두 통과합니다.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

이 단언은 매우 강력합니다. 더 나아간 사용 법에 대해서는 [문서](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb)를 참고하세요.

#### 추가 뷰 기반 단언

뷰 테스트를 하기 위해서 사용되는 단언들이 더 있습니다.

| 단언                                                     | 목적     |
| ------------------------------------------------------- | ------- |
| `assert_select_email`                                   | 이메일의 본문에 대해서 단언. |
| `assert_select_encoded`                                 | 인코딩된 HTML에 대해서 단언. 각 요소의 내용물을 디코딩하고 각각에 대해서 블록을 호출합니다.|
| `css_select(selector)`나 `css_select(element, selector)` | _셀랙터_로 선택된 모든 요소를 배열로 반환합니다. 두번째 메소드의 경우, _주어진 요소_를 매칭하고, 그 요소와 자식들에 대해서 _셀랙터_ 표현식을 사용하여 매칭합니다. 매칭되는 것이 없는 경우 빈 배열을 반환합니다.|

`assert_select_email`는 다음과 같이 사용합니다:

```ruby
assert_select_email do
  assert_select 'small', 'Please click the "Unsubscribe" link if you want to opt-out.'
end
```

헬퍼 테스트하기
---------------

헬퍼는 뷰에서 사용할 수 있는 메소드들을 정의하는 간단한 모듈입니다.

헬퍼를 테스트하기 위해서는 헬퍼 메소드의 반환값이 기대한 값인지 확인하면 됩니다.
헬퍼 테스트는 `test/helpers`에 위치합니다.

다음과 같은 헬퍼가 있다고 가정합시다.

```ruby
module UserHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

이 메소드를 다음과 같이 테스트할 수 있습니다.

```ruby
class UserHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

나아가, 테스트 클래스는 `ActionView::TestCase`를 확장하므로, `link_to`나 `pluralize`와 같은
레일스의 헬퍼 메소드를 사용할 수 있습니다.


메일러 테스트하기
--------------------

메일러 클래스를 테스트하려면 몇몇 도구들이 필요합니다.

### 메일러 테스트에 대해서

메일러 클래스는 레일스 애플리케이션의 다른 모든 부분과 마찬가지로,
기대한 대로 동작하는지 보장하기 위해 테스트를 해야 합니다.

메일러 클래스를 테스트하는 경우에는 다음을 확인해야 합니다.

* 이메일이 처리(생성이나 전송)되었을 것
* 이메일의 내용(제목, 발신자, 본문 등)이 올바를 것
* 적절한 메일이 적절한 시기에 전송될 것

#### 모든 면에서 확인하기

메일러를 테스트할 때에는 단위 테스트와 기능 테스트를 할 수 있습니다. 단위 테스트에서는 고립된 환경에서
메일러를 제어된 입력을 알고 있는 출력(픽스쳐)과 비교합니다. 기능 테스트에서는 메일러에 의해서
생성된 내용물을 자세하게 확인하지 않습니다. 그 대신 컨트롤러와 모델이 메일러를 올바르게 사용하고 있는지
테스트합니다. 테스트는 적절한 메일이 적절한 시기에 전송되는지 확인해야 합니다.

### 단위 테스트하기

메일러가 기대대로 동작하는지 테스트하기 위해서는 단위 테스트를 통해 실제 생성된 메일과 미리 준비해둔
예상된 메일을 비교합니다.

#### 픽스쳐의 반격

메일러 단위 테스트를 위해서, 픽스쳐는 출력 결과가 어떻게 _보여야_ 하는지에 대한 예제를 제공합니다.
이들은 다른 픽스쳐들처럼 액티브 레코드 데이터를 사용하는 것이 아닌, 샘플 이메일이므로 다른 픽스쳐들과
분리되어 자신만의 폴더에 저장됩니다. 폴더 이름은 메일러의 이름에 대응하는 것을 사용합니다.
그러므로 메일러의 이름이 `UserMailer`라면 픽스쳐는 `test/fixtures/user_mailer`에 위치합니다.

제너레이터는 메일러를 생성할 때 각 메일러 액션마다 그에 맞는 스텁 픽스쳐를 생성합니다. 제너레이터를
사용하지 않는다면 필요한 파일들을 직접 만들어야 합니다.

#### 기본 테스트 케이스

다음은 `UserMailer`라는 이름의 메일러에서 친구에게 초대장을 전송하는 `invite` 액션의 단위 테스트입니다.
이 코드는 제너레이터에서 `invite`를 위해 생성된 기본 테스트를 기반으로 변경한 것입니다.

```ruby
require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 이메일을 만들고 이후를 위해 저장해둔다
    email = UserMailer.create_invite('me@example.com',
                                     'friend@example.com', Time.now)

    # 메일을 전송하고 큐에 등록되었는지 확인한다
    assert_emails 1 do
      email.deliver_now
    end

    # 메일의 내용물이 올바른지 확인한다.
    assert_equal ['me@example.com'], email.from
    assert_equal ['friend@example.com'], email.to
    assert_equal 'You have been invited by me@example.com', email.subject
    assert_equal read_fixture('invite').join, email.body.to_s
  end
end
```

메일을 생성하고 반환된 객체를 `email` 변수에 저장했습니다. 우선 메일이 전송되었는지 확인합니다(첫 번째 단언).
그리고 그다음에는 메일이 정말로 올바른 정보를 가졌는지 확인합니다. `read_fixture` 헬퍼는
이 파일의 내용물을 읽어옵니다.

`invite` 픽스쳐의 내용은 다음과 같습니다.

```
Hi friend@example.com,

You have been invited.

Cheers!
```

이제 메일러 테스트를 작성하는 방법에 대해서 조금 더 이해해야 할 때입니다. `config/environments/test.rb`의
`ActionMailer::Base.delivery_method = :test`는 테스트 모드에서 전송을 어떻게 할지를 지정하여
메일이 실제로 전송되지 않고(테스트 중에 사용자들에게 메일 폭격을 하지 않게 하는데 유용합니다), 대신
배열(`ActionMailer::Base.deliveries`)에 메일을 집어넣습니다.

NOTE: `ActionMailer::Base.deliveries` 배열은 `ActionMailer::TestCase`와
`ActionDispatch::IntegrationTest`에서만 자동으로 초기화됩니다. 만약 다른 테스트 클래스에서
이 배열을 초기화하고 싶은 경우에는 `ActionMailer::Base.deliveries.clear`를 통해 직접 초기화해야 합니다.

### 기능 테스트하기

메일러의 기능 테스트에서는 메일 본문이나 수신자가 올바른지 확인하는 이상의 것을 포함합니다. 메일의
기능 테스트에서는 메일 전송 메소드를 호출하고, 올바른 메일이 올바르게 전송 목록에 추가되었는지 확인합니다.
전송 메소드 자체가 자기 일을 잘한다고 가정해도 좋습니다. 애플리케이션의 비즈니스 로직에서 원하는 시점에
메일이 나가는지에 더 관심이 있을 것이기 때문입니다. 예를 들어 친구 초대 동작이 메일을 잘 보내고 있는지
확인하고 싶다고 해보죠.

```ruby
require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post invite_friend_url, params: { email: 'friend@example.com' }
    end
    invite_email = ActionMailer::Base.deliveries.last

    assert_equal "You have been invited by me@example.com", invite_email.subject
    assert_equal 'friend@example.com', invite_email.to[0]
    assert_match(/Hi friend@example.com/, invite_email.body.to_s)
  end
end
```

잡 테스트하기
------------

애플리케이션의 다른 레벨에서 잡을 큐에 등록할 수 있으므로, 잡 자신(큐에서의 동작)과 다른 곳에서
정상적으로 큐에 등록할 수 있는지를 모두 테스트해야 합니다.

### 기본 테스트 케이스

제너레이터로 잡을 생성하면, 간단한 테스트가 `test/jobs` 폴더에 생성됩니다. 청구서 잡을 예시로 들어보죠.

```ruby
require 'test_helper'

class BillingJobTest < ActiveJob::TestCase
  test 'that account is charged' do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

이 테스트는 꽤 간단합니다. 그리고 잡이 정상적으로 동작했는지 확인합니다.

`ActiveJob::TestCase`는 큐 어댑터를 `:async`로 설정하여 잡이 비동기적으로 실행되도록 만듭니다.
그리고 어떤 테스트가 실행되기 전에 이전에 실행되거나 등록된 잡들이 초기화되었을 거라고 보장합니다.
이를 통해 각 테스트가 실행되는 시점에는 큐가 깨끗하며 아무런 잡도 실행되지 않았다고 가정할 수 있습니다.

### 커스텀 단언과 다른 컴포넌트에서 잡 테스트하기

액티브 잡은 테스트의 장황함을 줄이기 위한 한 뭉치의 단언들을 제공합니다. 사용 가능한 모든 목록에 대해서는
[`ActiveJob::TestHelper`](http://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)의
API 문서를 확인하세요.

잡이 큐에 등록되고 어디에서 호출하더라도(e.g. 컨트롤러에서) 실행된다는 것을 확인하는 것은 좋은 습관입니다.
이때 액티브 잡이 제공하는 단언이 유용합니다. 예를 들어, 다음과 같이 모델과 테스트를 쉽게 할 수 있습니다.

```ruby
require 'test_helper'

class ProductTest < ActiveJob::TestCase
  test 'billing job scheduling' do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
  end
end
```

참고 자료
----------------------------

### 시간에 의존하는 코드 테스트하기

레일스는 시간에 의존하는 코드를 기대대로 동작한다고 단언할 수 있게 해주는 내장 헬퍼 메소드를 제공합니다.

다음은 [`travel_to`](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to) 헬퍼를 사용하는 예제입니다.

```ruby
# 사용자가 등록하고 한 달 뒤에 선물을 받을 자격이 생긴다고 가정합니다.
user = User.create(name: 'Gaurish', activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?
travel_to Date.new(2004, 11, 24) do
  assert_equal Date.new(2004, 10, 24), user.activation_date # `travel_to` 블록 내의 `Date.current`를 속입니다.
  assert user.applicable_for_gifting?
end
assert_equal Date.new(2004, 10, 24), user.activation_date # 변경사항은 `travel_to` 블록 내에서만 적용됩니다.
```

사용 가능한 시간 헬퍼에 대한 정보는 [`ActiveSupport::Testing::TimeHelpers` API 문서](http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html)에서 확인하세요.
