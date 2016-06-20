Active Support 코어 확장 기능
==============================

Active Support는 Ruby on Rails의 구성 요소중 하나로, Ruby의 확장 기능, 유틸리티, 그 외의 작업 등을 담당하고 있습니다.

Active Support는 언어 레벨에서 다양한 기능을 추가해주며, Rails 애플리케이션의 개발과 Ruby on Rails 자체의 개발을 지원하기 위한 목적으로 만들어졌습니다.

이 가이드의 내용:

* 코어의 확장 기능에 대해서
* 모든 확장 기능을 불러오는 방법
* 필요한 확장 기능만을 사용하는 방법
* Active Support가 제공하는 확장 기능 목록

--------------------------------------------------------------------------------

코어 확장 기능을 불러오는 방법
---------------------------

### 독립적인 Active Support

흔적을 최대한 남기지 않기 위해서, Active Support는 기본적으로 아무것도 읽어들이지 않습니다. Active Support는 자잘하게 분할되어 필요한 확장 기능만 불러올 수 있도록 되어 있습니다. 또한 연관되어 있는 확장기능(상황에 따라서는 모든 확장 기능)도 동시에 불러올 때에 사용할 수 있는 엔트리 포인트도 포함하고 있습니다.

따라서 아래와 같은 require문을 실행하더라도,

```ruby
require 'active_support'
```

객체는 `blank?`에 응답하지 않습니다(역주: `black?`는 Active Support가 추가해주는 메소드 중 하나임). 이 정의가 어떤 식으로 로드되는지 확인해봅시다.

#### 필요한 정의만을 선택

`blank?` 메소드를 사용하는 가장 '가벼운' 방법은 그 메소드가 정의되어있는 파일만을 선택해서 불러오는 것입니다.

이 가이드에서는 코어 확장 기능으로 정의되어있는 모든 메소드에 대해서 그 정의 파일이 어디에 위치해 있는지를 적어두었습니다. 예를 들어 `blank?`의 경우, 아래와 같은 메모가 되어 있습니다.

NOTE: `active_support/core_ext/object/blank.rb`에 정의되어 있습니다.

다시 말해 아래와 같이 핀포인트로 require를 실행할 수도 있습니다.

```ruby
require 'active_support'
require 'active_support/core_ext/object/blank'
```

Active Support는 무척 조심스러워서, 어떤 파일을 선택했을 경우 정말로 필요한 파일들만을 동시에 불러옵니다(의존 관계가 있는 경우).

#### 코어 확장 기능을 그룹화하여 불러오기

다음 단계로 `Object`에 대한 모든 확장 기능을 불러와봅시다. 경험적으로 `SomeClass`라는 클래스가 있다면 `active_support/core_ext/some_class`라는 경로를 지정하면 한번에 읽어올 수 있습니다.

따라서, (`blank?`를 포함하여)`Object`에 대한 모든 확장기능을 불러오기 위해서는 다음과 같이 작성하면 됩니다.

```ruby
require 'active_support'
require 'active_support/core_ext/object'
```

#### 모든 확장 기능을 불러오기

모든 코어 확장 기능을 불러오고 싶다면 아래와 같이 require하면 됩니다.

```ruby
require 'active_support'
require 'active_support/core_ext'
```

#### 모든 Active Support를 읽어오기

마지막으로 사용가능한 Active Support를 모두 불러오고 싶다면 이렇게 할 수 있습니다.

```ruby
require 'active_support/all'
```

단, 이 코드를 실행하더라도 Active Support 전체가 메모리 상에 로드되는 것은 아닙니다. 일부는 `autoload`로 설정되어서, 실제로 사용하기 전까지는 로드되지 않습니다.

### Ruby on Rails 애플리케이션에서 Active Support를 사용하기

Ruby on Rails 애플리케이션에서는 기본적으로 모든 Active Support를 불러옵니다. `active_support.bare`를 true로 설정했을 때는 예외입니다. 이 옵션을 true로 설정하면 프레임워크 자체가 필요로 할 때까지 애플리케이션은 확장 기능을 불러오지 않습니다. 또한 불러올 확장 기능은 위에서 이야기했듯이 각 부분별로 그때그때 선택됩니다.

모든 객체에서 사용할 수 있는 확장 기능
-------------------------

### `blank?`와 `present?`

Rails 애플리케이션은 아래의 값을 공백(blank)라고 판단합니다.

* `nil`과 `false`

* 공백문자(whitespace)만으로 구성되어있는 문자열 (아래의 설명 참조)

* 비어있는 배열과 해시

* 그 외, `empty?` 메소드에 true를 돌려주는 모든 객체를 비어있다고 생각합니다.

INFO: 문자열을 판정하기위해, Unicode에 대응하는 문자 클래스인 `[:space:]`를 사용합니다. 그러므로 예를 들어 U+2029(단락 구분자)역시 공백 문자로 판정됩니다.

WARNING: 숫자에 대해서는 공백인지 아닌지 판단할 수 없습니다. 특히 0이나 0.0은 **공백이 아니므로** 주의해주세요.

예를 들어 `ActionController::HttpAuthentication::Token::ControllerMethods`에 있는 아래의 메소드에서는 `blank?`를 사용해서 토큰이 존재하고 있는지를 확인합니다.

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

`present?` 메소드는 `!blank?` 메소드와 동등합니다. 아래의 예시는 `ActionDispatch::Http::Cache::Response`에서 인용했습니다.

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  ...
end
```

NOTE: `active_support/core_ext/object/blank.rb`에 정의되어 있습니다.

### `presence`

`presence` 메소드는 `present?`가 true인 경우에는 자기 자신의 리시버를 반환하고, false인 경우에는 `nil`을 반환합니다. 이 메소드는 아래와 같은 경우에 편리합니다.

```ruby
host = config[:host].presence || 'localhost'
```

NOTE: `active_support/core_ext/object/blank.rb`에 정의되어 있습니다.

### `duplicable?`

Ruby에 존재하는 기본적인 객체들의 몇몇은 singleton 객체 입니다. 예를 들자면, 프로그램의 생애 주기 동안에 정수 1은 항상 같은 같은 인스턴스를 참조합니다.

```ruby
1.object_id                 # => 3
Math.cos(0).to_i.object_id  # => 3
```

따라서, 이러한 객체는 `dup` 메소드나, `clone` 메소드로 복사할 수 없습니다.

```ruby
true.dup  # => TypeError: can't dup TrueClass
```

singleton이 아닌 숫자에도 복사가 불가능한 것들이 있습니다.

```ruby
0.0.clone        # => allocator undefined for Float
(2**1024).clone  # => allocator undefined for Bignum
```

Active Support에는 객체가 프로그램 상에서 복사 가능한지 아닌지 확인하기 위한 `duplicable?` 메소드가 존재합니다..

```ruby
"foo".duplicable? # => true
"".duplicable?    # => true
0.0.duplicable?  # => false
false.duplicable? # => false
```

기본으로 `nil`, `false`, `true`, 심볼, 숫자, 클래스, 모듈, 메소드 객체를 제외한 모든 객체가 `duplicable?` #=> true입니다.

WARNING: 어떤 클래스라도 `dup` 메소드와 `clone` 메소드를 삭제하여 이 메소드들을 사용할 수 없게 만들 수 있습니다. 이때 이 메소드들을 실행하면 예외가 발생합니다. 이런 경우에는 어떤 객체에서든 그 객체가 복사 가능한지 아닌지를 확인하기 위해 `rescue`를 사용해야하는 상황이 생깁니다. `duplicable?` 메소드는 위처럼 고정된 목록에 의존합니다만, 그 대신 `rescue`보다 빠르게 동작합니다. 실제로 사용하는 경우에 저 목록으로 충분하다고 판단되는 경우에는 `duplicable?`를 사용해주세요.

NOTE: `active_support/core_ext/object/duplicable.rb`에 정의되어 있습니다.

### `deep_dup`

`deep_dup` 메소드는 주어진 객체의 '깊은 복사'를 돌려줍니다. 루비는 일반적으로 다른 객체를 포함하는 객체를 `dup`하더라도 내부에 있는 다른 객체들을 복사하지 않습니다. 이러한 사본은 '앝은 복사(shallow copy)'라고 불립니다. 예를 들자면, 아래와 같은 문자열을 포함하는 배열이 있다고 가정합시다.

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# 이 객체는 복사되었으므로, 복사 된쪽에만 객체가 추가됨
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# 첫번째 요소는 복사되지 않았으므로 한쪽을 변경하면, 양쪽 배열에 모두 변경사항이 반영됨
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

위에서 보듯, `Array` 인스턴스를 복사하여 다른 객체가 생성되었으므로, 한쪽을 변경하더라도 다른쪽은 변경되지 않게 되었습니다. 단, 배열은 복사되었습니다만, 배열 내의 요소들은 그렇지 않습니다. `dup` 메소드는 깊은 복사를 해주지 않으므로, 배열의 내부에 있는 문자열은 복사 후에도 같은 객체입니다.

객체를 깊은 복사해야할 필요가 있는 경우에는 `deep_dup`를 사용해주세요.

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

객체가 복사 불가능한 경우, `deep_dup`는 그 객체를 그대로 돌려줍니다.

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTE: `active_support/core_ext/object/deep_dup.rb`에 정의되어 있습니다.

### `try`

`nil`이 아닌 경우에만 객체의 메소드를 호출하고 싶은 경우, 가장 단순한 방법은 조건문을 추가하는 것입니다만, 아무래도 코드가 장황해지게 됩니다. 이러한 상황에서 `try`를 사용할 수 있습니다. `try`는 `Object#send`와 닮아있습니다만, `nil`에 호출되는 경우에는 `nil`을 돌려준다는 부분이 다릅니다.

```ruby
# try 메소드를 사용하지 않은 경우
unless @number.nil?
  @number.next
end

# try 메소드를 사용한 경우
@number.try(:next)
```

`ActiveRecord::ConnectionAdapters::AbstractAdapter`에 있는 다른 예시를 소개합니다. 여기에서는 `@logger`가 `nil`일 경우가 있습니다. 이 코드에서는 `try`를 사용하는 것으로 불필요한 체크를 하는 수고를 덜 수 있습니다.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` 메소드는 인수 대신 블록과 함께 호출할 수도 있습니다. 이 경우 객체가 `nil`이 아닌 경우에만 블록이 실행됩니다.

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

NOTE: `active_support/core_ext/object/try.rb`에 정의되어 있습니다.

### `class_eval(*args, &block)`

`class_eval` 메소드를 사용하여 다양한 객체의 singleton 클래스의 컨텍스트에서 코드를 실행(eval)할 수 있습니다.

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTE: `active_support/core_ext/kernel/singleton_class.rb`에 정의되어 있습니다.

### `acts_like?(duck)`

`acts_like?` 메소드는, 일부 클래스가 다른 클래스와 같은 방식으로 동작하는지에 대해서 어떤 관례에 따라서 확인합니다. `String` 클래스와 동일한 인터페이스를 제공하는 클래스가 있고, 그 중에서 아래의 메소드를 정의했다고 가정해 봅시다.

```ruby
def acts_like_string?
end
```

이 메소드는 단순한 지표이며, 메소드 자체가 돌려주는 값과 관련은 없습니다. 이에 의해서 클라이언트 코드에서는 이래와 같은 덕 타이핑(duck typing) 체크를 할 수 있게 됩니다.

```ruby
some_klass.acts_like?(:string)
```

Rails에서는 `Date` 클래스나 `Time` 클래스와 비슷하게 행동하는 클래스가 존재하며, 이 방식을 사용하고 있습니다.

NOTE: `active_support/core_ext/object/acts_like.rb`에 정의되어 있습니다.

### `to_param`

Rails의 모든 객체들에 `to_param` 메소드를 사용할 수 있습니다. 이것은 객체를 값으로 표현한 것을 반환한다는 의미입니다. 반환된 값은 쿼리 문자열이나 URL의 일부로 사용할 수 있습니다.

기본으로 `to_param` 메소드는 `to_s` 메소드를 호출하게 됩니다.

```ruby
7.to_param # => "7"
```

`to_param`에 의해서 반환된 값을 **이스케이프 해서는 안됩니다**. 취약점이 발생할 수 있습니다.

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

이 메소드는 Rails의 많은 클래스에서 재정의됩니다.

예를 들어 `nil`, `true`, `false`의 경우는 자기 자신을 반환합니다. `Array#to_param`를 실행하면 `to_param`이 배열 내의 각 요소에 대해서 실행되며, 결과가 "/"로 join됩니다.

```ruby
[0, true, String].to_param # => "0/true/String"
```

특히 Rails의 라우팅 시스템은 모델에 대해서 `to_param` 메소드를 실행해서 `:id` 플레이스홀더의 값을 얻어옵니다. `ActiveRecord::Base#to_param`은 모델의 `id`를 반환합니다만 이 메소드를 모델 내에서 재정의할 수도 있습니다. 다음처럼,

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

이래의 결과를 얻을 수 있습니다.

```ruby
user_path(@user) # => "/users/357-john-smith"
```

WARNING: 컨트롤러에서는 `to_param` 메소드가 모델쪽에서 재정의 되어있을 가능성을 항상 주의해야할 필요가 있습니다. 위와 같은 요청을 수신했을 경우, `params[:id]`의 값이 "357-john-smith"가 되기 때문입니다.

NOTE: `active_support/core_ext/object/to_param.rb`에 정의되어 있습니다.

### `to_query`

이 메소드는 이스케이프 되지 않은 `key`를 받으면, 그 키를 `to_param`이 돌려주는 값을 대응시키는 쿼리 문자열의 일부를 생성합니다. 단 해시는 예외입니다(뒤에서 설명). 예를 들자면 다음과 같은 경우,

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

아래와 같은 결과를 얻을 수 있습니다.

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

이 메소드는 키와 값, 어느쪽이든 필요한 부분을 모두 이스케이프 합니다.

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

따라서 이 결과값은 그대로 쿼리 문자열로 사용할 수 있습니다.

배열에 `to_query` 메소드를 사용한 경우 `to_query`를 배열의 각 요소에 호출하여 `_key_[]`를 키로 추가하고, 그 값들을 "&"로 연결한 결과를 반환합니다.

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

해시도 `to_query`를 사용할 수 있습니다만, 다른 방식으로 호출됩니다. 메소드에 인수가 넘겨지지 않았을 경우, 메소드는 해시의 키/값 쌍을 정렬된 순서로 생성하고, 각각의 값에 대해서 `to_query(key)`를 호출합니다. 이어서 각 결과들을 "&"로 연결합니다.

```ruby
{c: 3, b: 2, a: 1}.to_query # => "a=1&b=2&c=3"
```

`Hash#to_query` 메소드는 각 키에 대해서 네임스페이스를 옵션으로 줄 수도 있습니다.

```ruby
{id: 89, name: "John Smith"}.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTE: `active_support/core_ext/object/to_query.rb`에 정의되어 있습니다.

### `with_options`

`with_options` 메소드는 순차적으로 사용되는 여러 메소드에 대해서 공통으로 주어지는 옵션을 바깥으로 꺼내기 위한 수단을 제공합니다.

기본으로 옵션 해시가 주어지면, `with_options`은 블록에 대해서 프록시 객체를 생성합니다. 그 블록 내에서는 프록시에 대해서 호출된 메소드에 옵션을 추가한 뒤, 그 메소드를 리시버에게 보냅니다. 예를 들자면, 아래와 같은 옵션을 반복하지 않아도 됩니다.

```ruby
class Account < ActiveRecord::Base
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

이는 아래와 같이 재작성할 수 있습니다.

```ruby
class Account < ActiveRecord::Base
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

예를 들어,  이 방법을 사용하면 뉴스레터의 독자를 언어별로 _그룹화_할 수 있습니다. 독자가 원하는 언어에 따라서 다른 뉴스레터를 보내고 싶다고 해봅시다. 메일 전송용 코드의 어딘가에 아래와 같은 언어에 의존하는 부분을 그룹화 할 수 있습니다.

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP: `with_options`은 메소드를 리시버에게 전송하므로 호출을 중첩할 수도 있습니다. 각 중첩 레벨에서는 자신의 호출에 대해서 물려받은 기본 호출값을 병합합니다.

NOTE: `active_support/core_ext/object/with_options.rb`에 정의되어 있습니다.

### JSON support

Active Support가 제공하는 `to_json` 메소드의 구현은 일반적으로 `json` gem이 Ruby 객체에 제공하는 `to_json`보다도 뛰어납니다. 그 이유는 `Hash`나 `OrderedHash`, `Process::Status` 등의 클래스에서는 올바른 JSON 표현을 제공하기 위해서 특별한 처리가 필요하기 때문입니다.

NOTE: `active_support/core_ext/object/json.rb`에 정의되어 있습니다.

### 인스턴스 변수

Active Support는 인스턴스 변수에 간단히 접근하기 위한 메소드를 제공합니다.

#### `instance_values`

`instance_values` 메소드는 해시를 반환합니다. 인스턴스 변수명으로부터 "@"를 제외한 부분이 해시의 키로, 인스턴스 변수의 값이 해시의 값으로 매핑됩니다. 키는 문자열입니다.

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTE: `active_support/core_ext/object/instance_variables.rb`에 정의되어 있습니다.

#### `instance_variable_names`

`instance_variable_names` 메소드는 배열을 반환합니다. 배열의 인스턴스명에는 "@" 기호가 포함됩니다.

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTE: `active_support/core_ext/object/instance_variables.rb`에 정의되어 있습니다.

### 경고, 스트림, 예외 무시하기

`silence_warnings` 메소드와 `enable_warnings` 메소드는 블록이 살아있는 동안 `$VERBOSE`을 변경하고, 그 후 초기화합니다.

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

마찬가지로 `silence_stream`을 통해서 특정 스트림에 대한 출력을 무시할 수도 있습니다.

```ruby
silence_stream(STDOUT) do
  # STDOUT is silent here
end
```

`quietly` 메소드는 STDOUT과 STDERR에 대한 출력을 무시하길 원하는 경우에 사용할수 있는 일반적인 방법입니다. 이는 서브 프로세스에서도 유효합니다.

```ruby
quietly { system 'bundle install' }
```

예를 들어, railities 테스트 중 몇몇에서는 테스트 진행 상태를 알려주는 메시지를 방해하지 않도록 내부 출력을 무시합니다.

`suppress` 메소드를 사용하면 예외의 발생을 막을 수도 있습니다. 이 메소드는 예외 클래스를 가리키는 임의의 숫자를 받습니다. `suppress`는 블록을 실행할 때에 예외가 발생하고, 그 예외가 (`kind_of?`에 의한 판정을 통해) 넘겨받은 인수와 일치하는 경우, 그것을 잡아서 예외를 발생시키지 않고 돌려보냅니다. 일치하지 않는 경우에는 예외를 처리하지 않습니다.

```ruby
#  잠긴 사용자의 경우, 증분은 발생하지 않지만, 이 손실이 중요하지 않을 때
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTE: `active_support/core_ext/kernel/reporting.rb`에 정의되어 있습니다.

### `in?`

메소드 `in?`는 어떤 객체가 다른 객체에 포함되어있는지를 테스트합니다. 넘겨받은 인수에 `include?`를 호출할 수 없는 경우에는 `ArgumentError` 예외를 발생시킵니다.

`in?`의 예시를 보시죠.

```ruby
1.in?([1,2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTE: `active_support/core_ext/object/inclusion.rb`에 정의되어 있습니다.

`Module` 확장
----------------------

### `alias_method_chain`
확장되지 않은 순수한 Ruby를 사용하여 메소드를 다른 메소드로 감쌀 수 있습니다만, 이는 _alias chaining_이라고 불립니다.

예를 들자면, 기능 테스트를 할 때에 파라미터가(실제 요청과 마찬가지로) 문자열이길 기대한다고 합시다. 그러나 필요하다면 정수 등의 다른 타입의 값을 가질 수 있도록 하고 싶습니다. 이를 실현하기 위해서는 `ActionController::TestCase#process`를 아래와 같이 `test/test_helper.rb`에서 감쌉니다.

```ruby
ActionController::TestCase.class_eval do
  # 본래의 프로세스 메소드의 참조를 저장
  alias_method :original_process, :process

  # 프로세스를 재정의 하여 original_process에 위임
  def process(action, params=nil, session=nil, flash=nil, http_method='GET')
    params = Hash[*params.map {|k, v| [k, v.to_s]}.flatten]
    original_process(action, params, session, flash, http_method)
  end
end
```

이는 `get`, `post` 메소드 등이 작업을 위임할 때에 사용되는 방식입니다.

이 방법에는 `:original_process`가 의도치 않은 방식으로 사용될 위험이 있습니다. alias chain을 사용할 때에 명명으로 인한 사용자들의 혼란을 피하기 위해서는 다음과 같이 사용할 수 있습니다.

```ruby
ActionController::TestCase.class_eval do
  def process_with_stringified_params(...)
    params = Hash[*params.map {|k, v| [k, v.to_s]}.flatten]
    process_without_stringified_params(action, params, session, flash, http_method)
  end
  alias_method :process_without_stringified_params, :process
  alias_method :process, :process_with_stringified_params
end
```

`alias_method_chain` 메소드를 사용하면 이와 같은 패턴을 더 간단하게 사용할 수 있습니다.

```ruby
ActionController::TestCase.class_eval do
  def process_with_stringified_params(...)
    params = Hash[*params.map {|k, v| [k, v.to_s]}.flatten]
    process_without_stringified_params(action, params, session, flash, http_method)
  end
  alias_method_chain :process, :stringified_params
end
```



NOTE: `active_support/core_ext/module/aliasing.rb`에 정의되어 있습니다.

### 속성

#### `alias_attribute`

모델의 속성에는 읽기 접근자(reader), 쓰기 접근자(writer), 술어(predicate)가 있습니다. 이에 대응하는 3개의 메소드를 가지는 모델의 속성의 별명(alias)를 한번에 작성할 수 있습니다. 다른 별명 생성용 메소드와 마찬가지로 첫번째 인수로 새 이름, 두번째로 원래의 이름을 지정합니다(변수에 대입할 때와 같은 순서라고 기억해두는 방법도 있습니다).

```ruby
class User < ActiveRecord::Base
  # email 컬럼을 "login"이라는 이름으로 참조하고 싶음
  # 이것으로 인증 코드의 가독성을 올릴 수 있음
  alias_attribute :login, :email
end
```

NOTE: `active_support/core_ext/module/aliasing.rb`에 정의되어 있습니다.

#### 내부 속성

어떤 클래스에서 속성을 정의하면, 나중에 그 클래스의 서브 클래스를 선언할 때 이름이 충돌할 수 있는 위험성이 발생합니다. 이는 라이브러리에 있어서 가장 중요한 문제입니다.

Active Support에서는 `attr_internal_reader`, `attr_internal_writer`, `attr_internal_accessor`라는 매크로가 정의되어 있습니다. 이 매크로는 Ruby에 내장되어있는 `attr_*`와 동일한 동작을 수행합니다만, 내부의 인스턴스 변수의 이름이 충돌하기 어렵도록 고려되어 있다는 점이 다릅니다.

`attr_internal` 매크로는 `attr_internal_accessor`와 동일합니다.

```ruby
# 라이브러리
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# 클라이언트 코드
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

이 예시에서는 `:log_level`은 라이브러리의 퍼블릭 인터페이스에 속해있지 않고 개발용으로만 사용됩니다. 클라이언트의 코드에서는 충돌의 가능성을 고려하지 않고 독자적인 `:log_level`을 자식 클래스에 정의하고 있습니다. 라이브러리에서 `attr_internal`을 사용하고 있는 덕분에 충돌이 발생하는 것을 회피할 수 있습니다.

이 때, 내부 인스턴스 변수의 이름에는 기본으로 언더스코어가 추가됩니다. 위의 예제에서라면 `@_log_level`이 됩니다. 이 동작은 `Module.attr_internal_naming_format`을 사용해서 변경할 수도 있습니다. `sprintf`와 마찬가지로 포맷 문자열을 넘기고, 첫부분에 `@`를 두고, 나머지 부분을 위치시킬 장소에 `%s`를 추가합니다. 기본 값은 `"@_%s"`입니다.

Rails에서는 이 내부 속성을 몇몇 코드에서 사용하고 있습니다. 예를 들자면 뷰에서는 다음처럼 사용합니다.

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTE: `active_support/core_ext/module/attr_internal.rb`에 정의되어 있습니다.

#### 모듈 속성

`mattr_reader`, `mattr_writer`, `mattr_accessor`라는 3개의 매크로는 클래스 용으로 정의되어 있는 `cattr_*` 매크로돠 동일한 동작을 수행합니다. 실제로 `cattr_*` 매크로의 별칭으로 `mattr_*`를 사용하고 있을 뿐입니다. [클래스 속성](#class속성)을 참고해주세요.

예를 들자면, 이 매크로는 아래의 Dependencies 모듈에서 사용하고 있습니다.
たとえば、これらのマクロは以下のDependenciesモジュールで使用されています。

```ruby
module ActiveSupport
  module Dependencies
    mattr_accessor :warnings_on_first_load
    mattr_accessor :history
    mattr_accessor :loaded
    mattr_accessor :mechanism
    mattr_accessor :load_paths
    mattr_accessor :load_once_paths
    mattr_accessor :autoloaded_constants
    mattr_accessor :explicitly_unloadable_constants
    mattr_accessor :logger
    mattr_accessor :log_activity
    mattr_accessor :constant_watch_stack
    mattr_accessor :constant_watch_stack_mutex
  end
end
```

NOTE: `active_support/core_ext/module/attribute_accessors.rb`에 정의되어 있습니다.

### 부모

#### `parent`

`parent` 메소드는 이름을 가지는 중첩된 모듈에 대해서 실행할 수 있으며, 대응하는 상수를 가지는 모듈을 반환합니다.

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parent # => X::Y
M.parent       # => X::Y
```

모듈에 이름이 없거나, 최상위인 경우, `parent`는 `Object`를 반환합니다.

WARNING: `parent_name`는 그 경우 `nil`을 돌려줍니다.

NOTE: `active_support/core_ext/module/introspection.rb`에 정의되어 있습니다.

#### `parent_name`

`parent_name` 메소드는 이름을 가지는 모듈들이 중첩되어 있는 경우에 실행할 수 있으며, 대응하는 상수를 가지는 모듈의 이름을 반환합니다.

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parent_name # => "X::Y"
M.parent_name       # => "X::Y"
```

모듈의 이름이 없거나, 최상위인 경우, `parent_name`은 `nil`을 반환합니다.

WARNING: `parent`는 그 경우에 `Object`를 돌려줍니다.

NOTE: `active_support/core_ext/module/introspection.r에 정의되어 있습니다.

#### `parents`

`parents` 메소드는 리시버에 대해서 `parent`를 호출하며, `Object`에 도달할때까지의 경로를 거슬로 올라갑니다. 연쇄적인 모듈은 하위부터 상위의 순서로 배열에 저장되어 반환됩니다.

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.parents # => [X::Y, X, Object]
M.parents       # => [X::Y, X, Object]
```

NOTE: `active_support/core_ext/module/introspection.rb`에 정의되어 있습니다.

### 상수

`local_constants` 메소드는 리시버 모듈에 정의된 상수를 반환합니다.

```ruby
module X
  X1 = 1
  X2 = 2
  module Y
    Y1 = :y1
    X1 = :overrides_X1_above
  end
end

X.local_constants    # => [:X1, :X2, :Y]
X::Y.local_constants # => [:Y1, :X1]
```

상수명은 심볼로 돌아옵니다.

NOTE: `active_support/core_ext/module/introspection.rb`에 정의되어 있습니다.

#### 정규 상수명

표준 메소드인 `const_defined?`, `const_get`, `const_set`에서는 순수한 상수명만을 사용할 수 있습니다. Active Support는 이 API를 확장하여 전체 경로에 가까운(qualified) 상수명을 넘길 수 있게 해줍니다.

이 메소드들은 `qualified_const_defined?`, `qualified_const_get`, `qualified_const_set`입니다. 넘긴 인수는 리시버를 기준으로 경로를 포함한 상수 명일 것이라는 전제를 가집니다.

```ruby
Object.qualified_const_defined?("Math::PI")       # => true
Object.qualified_const_get("Math::PI")            # => 3.141592653589793
Object.qualified_const_set("Math::Phi", 1.618034) # => 1.618034
```

경로를 포함하지 않는 순수한 정수명도 사용할 수 있습니다.

```ruby
Math.qualified_const_get("E") # => 2.718281828459045
```

이러한 메소드들은 내장된 메소드와 무척 닮아있습니다. 특히 `qualified_constant_defined?` 메소드는 옵션으로 리시버의 부모에서도 해당하는 상수를 검색할 것인지를 지정하는 두번째 인수를 받을 수 있습니다. 이 플래그는 주어진 모든 상수에 대해서 메소드로 경로를 따라 내려가며 적용됩니다.

아래의 예시를 확인해주세요.

```ruby
module M
  X = 1
end

module N
  class C
    include M
  end
end
```

`qualified_const_defined?`는 다음과 같이 동작합니다.

```ruby
N.qualified_const_defined?("C::X", false) # => false
N.qualified_const_defined?("C::X", true)  # => true
N.qualified_const_defined?("C::X")        # => true
```

마지막 예제에서 볼 수 있듯, `const_defined?` 메소드와 마찬가지로 두번째 인수는 기본으로 true로 설정되어 있습니다.

내장 메소드와 호환성을 위해 상대 경로 이외에는 사용할 수 없습니다. `::Math::PI`와 같은 절대 경로를 사용한 상수명을 사용하면 `NameError`가 발생합니다.

NOTE: `active_support/core_ext/module/qualified_const.rb`에 정의되어 있습니다.

### 도달 가능

이름을 가지는 모듈이 대응하는 상수에 저장되어 있는 경우에 도달 가능(reachable)이라고 표현합니다. 이것은 상수를 사용하여 모듈 객체에 접근할 수 있다는 의미입니다.

"M"이라는 모듈이 있을 경우, `M`이라는 상수가 존재하고, 거기에 모듈이 저장됩니다.

```ruby
module M
end

M.reachable? # => true
```

그러나 상수와 모듈이 분리되면, 그 모듈 객체는 도달 불가능(unreachable)하게 됩니다.

```ruby
module M
end

orphan = Object.send(:remove_const, :M)

# 이 모듈은 고립되어 있지만 이름을 가지고 있음
orphan.name # => "M"

# 상수 M은 존재하지 않으므로 상수 M을 통하여 사용할 수 없음
orphan.reachable? # => false

# "M"이라는 이름을 모듈에 재정의
module M
end

# 상수 M은 다시 존재하므로 모듈 객체 "M"을 저장하고 있지만
# 원래와는 다른 인스턴스임
orphan.reachable? # => false
```

NOTE: `active_support/core_ext/module/reachable.rb`에 정의되어 있습니다.

### 익명 모듈

모듈에 이름을 지정하지 않을 수도 있습니다.

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

`anonymous?`를 사용해서 모듈에 이름이 있는지 없는지 확인할 수 있습니다.

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

도달 불가능(unreachable)하더라도 반드시 익명(anonymous)이라고 볼 수는 없습니다.

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.reachable? # => false
m.anonymous? # => false
```

반대로 익명 모듈은, 정의 구조상 반드시 도달 불가능합니다.

NOTE: `active_support/core_ext/module/anonymous.rb`에 정의되어 있습니다.

### 메소드 위임

`delegate` 매크로를 사용하면 메소드를 간단하게 위임할 수 있습니다.

어떤 애플리케이션의 `User` 모델에 로그인 정보가 있고, 거기에 연관된 이름 등의 정보가 `Profile` 모델에 있다고 가정해봅시다.

```ruby
class User < ActiveRecord::Base
  has_one :profile
end
```

이 구성에서는 `user.profile.name` 처럼 프로파일을 통해 사용자의 이름을 얻어올 수 있습니다. 이러한 속성에 직접 접근할 수 있다면 좀 더 편리할 것입니다.

```ruby
class User < ActiveRecord::Base
  has_one :profile

  def name
    profile.name
  end
end
```

`delegate`는 이를 가능하게 해줍니다.

```ruby
class User < ActiveRecord::Base
  has_one :profile

  delegate :name, to: :profile
end
```

이 방법을 사용하면 선언이 좀 더 짧아지고, 의미도 확실해집니다.

단, 사용할 메소드가 대상 클래스에서 공개되어있어야 합니다.

`delegate` 매크로에는 복수의 메소드를 지정할 수 있습니다.

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

`:to` 옵션에 문자열을 넘겨주게 되면, 메소드를 위임할 상대 객체를 평가하는 식이 됩니다. 일반적으로는 문자열 또는 심볼을 사용합니다. 그러한 식은 리시버의 컨텍스트에서 실행됩니다.

```ruby
# Rails의 상수에 위임한다
delegate :logger, to: :Rails

# 리시버의 클래스에 위임한다.
delegate :table_name, to: :class
```

WARNING: `:prefix` 옵션이 `true`인 경우는 일반적이지 않습니다(아래에서 설명).

위임할 때에 `NoMethodError`가 발생한 경우에 대상이 `nil`인 경우, 예외가 넘겨집니다. `:allow_nil` 옵션을 사용하면 예외 대신에 `nil`을 돌려받을 수 있습니다.

```ruby
delegate :name, to: :profile, allow_nil: true
```

`:allow_nil`을 사용하면 사용자의 프로파일이 없는 경우 `user.name`를 호출하면 `nil`을 돌려줍니다.

`:prefix` 옵션은 생성된 메소드의 이름에 접두어를 추가합니다. 이것은 가독성을 높이고 싶을 때에 편리합니다.

```ruby
delegate :street, to: :address, prefix: true
```

이 예제에서는 `street`가 아닌 `address_street`가 발생합니다.

WARNING: 이 경우, 생성된 메소드의 이름에서는 대상의 객체명과 메소드명이 사용됩니다. `:to` 옵션으로 넘기는 것은 메소드명이어야 합니다.

접두어를 변경할 수도 있습니다.

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

여기에서는 매크로를 사용해 `size` 대신에 `avatar_size`가 생성됩니다.

NOTE: `active_support/core_ext/module/delegation.rb`에 정의되어 있습니다.

### 매소드 재정의

`define_method`를 사용해서 메소드를 제정의할 필요가 있지만, 그 이름이 이미 사용되고 있는지 아닌지 알 수 없는 경우가 있습니다. 유효한 이름이 이미 존재한다면 경고를 보여줍니다. 동작에 큰 문제는 없지만 깔끔하지 못한 방식입니다.

`redefine_method` 메소드를 사용하면 필요에 따라서 기존의 메소드를 삭제하므로 이러한 경고 메시지를 제어할 수 있습니다.

NOTE: `active_support/core_ext/module/remove_method.rb`에 정의되어 있습니다.

`Class`의 확장
---------------------

### Class 속성

#### `class_attribute`

`class_attribute` 메소드는 1개 이상의 상속 가능한 클래스의 속성을 선언합니다. 그 클래스 속성은 자식 클래스에서 재정의할 수 있습니다.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

예를 들자면, `ActionMailer::Base`에 아래의 정의가 있다고 해봅시다.

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

이 속성들은 인스턴스 레벨에서 접근 또는 재정의할 수 있습니다.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1 (A의 값이 사용된다)
a2.x # => 2 (a2에서 재정의된 값)
```

`:instance_writer`를 `false`로 주면 writer 인스턴스 메소드가 생성되지 않습니다.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false
    self.table_name_prefix = ""
  end
end
```

위 옵션은 모델의 속성 설정시에 일괄 저장(Mass Assignment)을 막을 때 유용합니다.

`:instance_reader`를 `false`로 주면 reader 인스턴스 메소드가 생성되지 않습니다.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1 # NoMethodError
```

편의를 위해서 `class_attribute`는 인스턴스의 reader가 돌려주는 값을 '이중부정'하는 인스턴스 존재 확인 메소드도 정의합니다. 위의 예제로 설명하자면, `x?`가 바로 그것입니다.

`:instance_reader`가 `false`인 경우, 이는 reader 메소드와 마찬가지로 `NoMethodError`를 돌려줍니다.

인스턴스 존재 확인 메소드가 필요 없는 경우, `instance_predicate: false`를 사용하면 됩니다.

NOTE: `active_support/core_ext/class/attribute.rb`에 정의되어 있습니다.

#### `cattr_reader`, `cattr_writer`, `cattr_accessor`

`cattr_reader`, `cattr_writer`, `cattr_accessor` 매크로는 `attr_*`와 유사합니다만 클래스용으로 사용한다는 점이 다릅니다. 이 메소드에서는 클래스 변수를 `nil`로 설정(클래스 변수가 이미 존재하는 경우를 제외)하고, 대응하는 클래스 메소드를 생성하여 사용할 수 있도록 만들어줍니다.

```ruby
class MysqlAdapter < AbstractAdapter
  # @@emulate_booleans에 접근 가능한 클래스 메소드를 생성함
  cattr_accessor :emulate_booleans
  self.emulate_booleans = true
end
```

사용성을 위해서, 이 때 인스턴스 메소드도 생성됩니다만, 이것들은 실제로는 클래스 속성의 프록시입니다. 따라서 인스턴스로부터 클래스 속성을 변경할 수 있습니다만, `class_attribute`에서처럼 재정의할 수는 없습니다(위를 참조). 예를 들자면,

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc
    @@field_error_proc = Proc.new{ ... }
  end
end
```

뷰에서 `field_error_proc`에 접근할 수 있습니다.

마찬가지로 `cattr_*`에 블록을 넘겨서 속성의 기본값을 줄 수도 있습니다.

```ruby
class MysqlAdapter < AbstractAdapter
  # @@emulate_booleans의 기본값을 true로 만들고, 이에 접근하기 위한 클래스 메소드를 생성
  cattr_accessor(:emulate_booleans) { true }
end
```

`:instance_reader`를 `false`로 주면, reader 인스턴스 메소드가 생성되지 않습니다. 마찬가지로 `:instance_writer`를 `false`로 주면, writer 인스턴스 메소드가 생성되지 않습니다. `:instance_accessor`를 `false`로 주면 두 인스턴스 메소드가 모두 생성되지 않습니다. 어느 경우에도 사용 가능한 값은 `false` 뿐입니다. 'nil' 등의 다른 값을 사용할 수는 없습니다.

```ruby
module A
  class B
    # first_name 인스턴스 reader는 생성되지 않음
    cattr_accessor :first_name, instance_reader: false
    # last_name= 인스턴스 writer는 생성되지 않음
    cattr_accessor :last_name, instance_writer: false
    # surname 인스턴스 reader도 surname= 인스턴스 writer도 생성되지 않음
    cattr_accessor :surname, instance_accessor: false
  end
end
```

`:instance_accessor`를 `false`로 주면 모델의 속성 설정시에 일괄 저장(Mass Assignment) 를 막을 수 있어 유용합니다.

NOTE: `active_support/core_ext/module/attribute_accessors.rb`에 정의되어 있습니다.

### Subclasses & Descendants

#### `subclasses`

`subclasses` 메소드는 리시버의 자식 클래스를 돌려줍니다.

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

돌려받는 순서는 명시되지 않습니다.

NOTE: `active_support/core_ext/class/subclasses.rb`에 정의되어 있습니다.

#### `descendants`

`descendants` 메소드는 그 리시버를 상속받은 모든 클래스를 돌려줍니다.

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

돌려받는 순서는 명시되지 않습니다.

NOTE: `active_support/core_ext/class/subclasses.rb`에 정의되어 있습니다.

`String`의 확장 메소드
----------------------

### 안전한 출력

#### 구현 동기

HTML 템플릿에 데이터를 삽입하는 방법은 무척 신중하게 구현해야 합니다. 예를 들어, `@review.title`를 아무런 조치도 취하지 않고 그대로 HTML에 내보내서는 안됩니다. 만약 이 리뷰의 제목이 "Flanagan & Matz rules!"이었다면, 올바른 HTML이라고 할 수 없습니다. 이를 올바르게 만들려면 "&amp;amp;"처럼 이스케이프를 해야 합니다. 나아가 사용자가 리뷰의 타이틀에 악의있는 HTML을 포함시켜 저장하게 되면, 엄청난 보안문제를 야기할 수 있습니다. 이 위험성에 대해서는 [보안 가이드](security.html#크로스-사이트-스크립팅-xss)의 크로스 사이트 스크립팅을 참조해주세요.

#### 안전한 문자열

Active Support에는 '(html 기준으로)안전한 문자열'이라는 개념이 존재합니다. 안전한 문자열이란 HTML으로 그대로 출력하더라도 문제가 없다는 표시가 되어 있는 문자열을 말합니다. 이 표시가 되어 있다면, '실제로 이스케이프 되어있는지, 아닌지에 관계 없이' 그 문자열을 신뢰합니다.

문자열은 기본으로 _unsafe_로 표시되어있습니다.

```ruby
"".html_safe? # => false
```

주어진 문자열에 `html_safe`메소드를 사용하면 안전한 문자열을 얻을 수 있습니다.

```ruby
s = "".html_safe
s.html_safe? # => true
```

여기서 주의해야하는 부분은 `html_safe` 메소드 자체는 어떤 이스케이프 작업도 수행하지 않는다는 점입니다. 그저 안전하다는 표시를 해줄 뿐입니다.

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

따라서 특정 문자열에 대해서 `html_safe` 메소드를 호출할 때에는 그 문자열이 정말로 안전한지 확인할 의무가 있습니다.

안전하다고 판단된 문자열에 대해서 안전하지 않은 문자열을 `concat`/`<<` 또는 `+` 같은 파괴적인 메소드를 통해 추가를 하게 되면, 결과는 여전히 안전한 문자열입니다. 안전하지 않은 인수는 추가될 때에 이스케이프 처리됩니다.

```ruby
"".html_safe + "<" # => "&lt;"
```

안전한 인수라면 이스케이프 작업 없이 직접 추가됩니다.

```ruby
"".html_safe + "<".html_safe # => "<"
```

기본적으로 이 메소드는 일반적인 뷰에서는 사용하지 말아주세요. 현재 Rails의 뷰에서는 안전하지 않은 값은 자동적으로 이스케이프되기 때문입니다.

```erb
<%= @review.title %> <%# 필요에 따라 이스케이프되므로 문제 없음 %>
```

특별한 이유가 있어서, 이스케이프되지 않은 문자열을 사용하고 싶은 경우에는 `html_safe` 대신 `raw` 헬퍼를 사용해주세요.

```erb
<%= raw @cms.current_template %> <%# @cms.current_template를 그대로 사용 %>
```

또는 `raw`와 동일한 동작을 하는 `<%==`를 사용하세요.

```erb
<%== @cms.current_template %> <%# @cms.current_template를 그대로 사용 %>
```

`raw` 헬퍼는 내부에서 `html_safe`를 호출합니다.

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE: `active_support/core_ext/string/output_safety.rb`에 정의되어 있습니다.

#### 각종 변환

보통 위에서 설명한 문자열 연결(concatenation) 작업을 제외하고 어떤 메소드라도 잠재적으로 문자열을 안전하지 않은 것으로 변환할 가능성이 있다는 점을 주의해야 합니다. `downcase`, `gsub`, `strip`, `chomp`, `underscore` 등이 그렇습니다.

`gsub!` 같은 파괴적인 변환을 하는 메소드를 사용하면 리시버 자체가 안전하지 않게 됩니다.

INFO: 이런 메소드를 사용하면, 실제로 변환이 발생했는가, 아닌가에 관계없이 안전함을 알려주던 표시가 무효화됩니다.

#### 변환과 강제

안전한 문자열에 대해서 `to_s`를 실행한 경우에는 안전한 문자열이 반환됩니다. 그러나 `to_str`에 의한 강제적인 변환을 실행한 경우에는 안전하지 않은 문자열이 반환됩니다.

#### 복사

안전한 문자열에 대해서 `dup` 또는 `clone`를 실행한 경우에는 안전한 문자열이 생성됩니다.

### `remove`

`remove` 메소드를 실행하면, 해당하는 모든 패턴이 삭제됩니다.

```ruby
"Hello World".remove(/Hello /) # => "World"
```

이 메소드에는 파괴적인 버전(`String#remove!`)이 존재합니다.

NOTE: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.

### `squish`

`squish` 메소드는 어두와 어미의 공백 문자를 제거하고, 연속된 공백을 하나로 줄여줍니다.

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

이 메소드도 파괴적인 버전(`String#squish!`)이 존재합니다.

이 메소드는 ASCII와 Unicode의 공백문자를 처리합니다.

NOTE: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.

### `truncate`

`truncate` 메소드는 문자열 처음부터 지정된 `length`만큼 복사하여 반환합니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

`:omission`를 통해 생략문자열(...)를 변경할 수 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

문자열을 자를 때에는 생략문자열의 길이도 포함된다는 점에 주의해주세요.

`:separator`를 사용하면 자연스럽게 보이는 위치에서 문자열을 자를 수 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

`:separator`에는 정규표현을 사용할 수도 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

이 예제에서는 `:separator`를 통해 "dear"라는 단어가 잘리지 않도록 하고 있습니다.

NOTE: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.

### `truncate_words`

`truncate_words` 메소드는 지정된 단어 수 뒤에 나오는 문자열을 잘라낸 사본을 반환합니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

`:omission`를 통해 생략문자열(...)를 변경할 수 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

`:separator`를 사용하면 자연스럽게 보이는 위치에서 문자열을 자를 수 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

`:separator`에는 정규표현을 사용할 수도 있습니다.

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

NOTE: `active_support/core_ext/string/filters.rb`에 정의되어 있습니다.

### `inquiry`

`inquiry`는 문자열을 `StringInquirer` 객체로 변환합니다. 이 객체를 사용하면 동일 여부를 좀 더 보기 좋게 비교할 수 있습니다.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

### `starts_with?`와 `ends_with?`

Active Support에서는 `String#start_with?`와 `String#end_with?`를 영어 기준으로 3인칭일때 사용하는 형태(starts、ends)로 만든 별칭 메소드를 정의해두고 있습니다.

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE: `active_support/core_ext/string/starts_ends_with.rb`에 정의되어 있습니다.

### `strip_heredoc`

`strip_heredoc` 메소드는 히어독(Heredoc)의 들여쓰기를 제거합니다.

다음은 예시입니다.

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

이 USAGE 메시지는 좌측에 정렬되어 표시됩니다.

기술적으로는 들여쓰기가 가장 적게 되어있는 행을 찾아, 그만큼만 전체 행의 앞 부분에서 제거합니다.

NOTE: `active_support/core_ext/string/strip.rb`에 정의되어 있습니다.

### `indent`

이 메소드는 리시버의 각 행에 들여쓰기를 추가합니다.

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

두번째 인수 `indent_string`는 들여쓰기에 사용될 문자열을 넘겨받습니다. 기본은 `nil`이며 이 경우에는 첫번째 들여쓰기가 발생한 행을 찾아서 그 때 사용된 문자를 참조하여 사용할 문자를 결정합니다. 들여쓰기가 전혀 없는 경우에는 띄어쓰기 1개를 사용합니다.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

`indent_string`에는 1문자의 띄어쓰기 또는 탭문자를 사용하는 것이 일반적입니다만, 다른 문자도 사용할 수 있습니다.

3번째 인수인 `indent_empty_lines`는 빈 줄도 들여쓰기를 할지 말지를 결정하는 플래그입니다. 기본은 false입니다.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

`indent!` 메소드는 들여쓰기를 파괴적으로 수행합니다.

NOTE: `active_support/core_ext/string/indent.rb`에 정의되어 있습니다.

### Access

#### `at(position)`

대상이 되는 문자열에서 `position`으로 넘겨받은 위치에 있는 문자를 반환합니다.

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.

#### `from(position)`

문자열에서 `position`으로 넘겨받은 위치로부터 시작되는 부분 문자열을 반환합니다.

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTE: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.

#### `to(position)`

문자열에서 `position`으로 넘겨받은 위치를 마지막으로 하는 부분 문자열을 반환합니다.

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.

#### `first(limit = 1)`

`str.first(n)`은 `n` > 0일 때 `str.to(n-1)`와 동등합니다. `n` == 0인 경우에는 빈 문자열을 반환합니다.

NOTE: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.

#### `last(limit = 1)`

`str.last(n)`은 `n` > 0일때 `str.from(-n)`와 동등합니다. `n` == 0인 경우에는 빈 문자열을 반환합니다.

NOTE: `active_support/core_ext/string/access.rb`에 정의되어 있습니다.

### 활용형

#### `pluralize`

`pluralize` 메소드는 리시버의 복수형을 반환합니다.

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

이 예제에서도 볼 수 있듯, Active Support는 불규칙 복수형이나 불가산명사에 대해서도 어느 정도 이해하고 있습니다. `config/initializers/inflections.rb`에 존재하는 내장 규칙을 확장할 수 있습니다. 이 파일은 `rails` 명령으로 확장 가능하며, 방법은 주석에서 확인할 수 있습니다.

`pluralize` 메소드에서는 `count` 파라미터를 사용할 수 있습니다. 만약 `count == 1`이라면 단수형이 반환됩니다. `count`가 그 이외의 값일 경우에는 복수형을 반환합니다(역주: 영어에서는 갯수가 0이거나 소수인 경우도 복수형을 사용합니다).

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record에서는 모델 이름과 대응하는 테이블의 이름을 추측할 때 이 메소드를 사용합니다.

```ruby
# active_record/model_schema.rb
def undecorated_table_name(class_name = base_class.name)
  table_name = class_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `singularize`

`pluralize`와 반대의 동작을 합니다.

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Rails의 Association에서 관계가 정의된 클래스에 대응하는 이름을 구할 때 이 메소드를 사용합니다.

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `camelize`

`camelize` 메소드는 리시버의 낙타 표기법(각 단어 첫번째 글자를 대문자로 만들고 띄어쓰기를 제거하는 것)으로 변환해줍니다.

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

이 메소드는 경로를 Ruby의 클래스로 변환할 때 자주 사용됩니다. '/'로 구분되어있는 경로는 '::'로 구분됩니다.

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

예를 들어, Action Pack은 특정 세션 스토어를 제공하는 클래스를 읽어올 때에 이 메소드를 사용하고 있습니다.

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` 메소드는 옵션으로 하나의 값을 받습니다. 사용 가능한 것은 `:upper`(기본값)나, `:lower`입니다. 후자를 사용하면 문자열의 첫번째 글자를 소문자로 처리합니다.

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

이 메소드는 그러한 작명법(카멜 표기법)을 따르는 언어(JavaScript 등)에서 사용하는 이름을 얻어올 때 유용합니다.

INFO: `camerize` 메소드의 동작은 `underscore` 메소드와 반대의 동작을 한다고 생각하면 알기 쉽습니다. 단 완전히 반대의 동작을 하는 것은 아닙니다. 예를 들어 `"SSLError".underscore.camelize`를 실행한 결과는 `"SslError"`이 되어 원래대로 되돌릴 수 없습니다. 이러한 경우를 위해서 Active Support는 `config/initializers/inflections.rb`에서 접두어를 지정할 수 있게 해줍니다.

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize`는 `camelcase`의 다른 이름입니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `underscore`

`underscore` 메소드는 위와 반대로 카멜 표기법을 경로로 변환합니다.

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

"::"도 "/"로 역변환됩니다.

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

소문자로 시작하는 문자열도 변환 가능합니다.

```ruby
"visualEffect".underscore # => "visual_effect"
```

단, `underscore`는 인수를 받지 않습니다.

Rails에서 자동적으로 읽어들이는 클래스와 모듈은 `underscore` 메소드를 사용하여 파일의 확장자를 제외한 상대 경로를 추측하고, 해당하는 경로에 존재하지 않는 경우에 새로 정의합니다.

```ruby
# active_support/dependencies.rb
def load_missing_constant(from_mod, const_name)
  ...
  qualified_name = qualified_name_for from_mod, const_name
  path_suffix = qualified_name.underscore
  ...
end
```

INFO: `underscore` 메소드의 동작은 `camelize` 메소드와 반대의 동작을 한다고 생각하면 이해하기 쉽습니다. 단 완전히 반대의 동작을 수행하는 것은 아닙니다. 예를 들어 `"SSLError".underscore.camelize`를 실행한 결과는 `"SslError"`가 됩니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `titleize`

`titleize` 메소드는 리시버에 존재하는 단어들의 첫번째 글자를 대문자로 만듭니다.

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` 메소드는 `titlecase`의 다른 이름입니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `dasherize`

`dasherize` 메소드는 리시버의 언더스코어 문자를 '-'로 변환합니다(역주: 여기서 말하는 '-'는 유니코드로 'U+002D'입니다).

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

모델의 XML 시리얼라이저에서는 이 메소드를 사용하여 노드명을 변환합니다.

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `demodulize`

`demodulize` 메소드는 전체 경로명을 받아 경로 부분을 제외하고 마지막 실제 상수 이름만을 남겨줍니다.

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""

```

다음 Active Record의 예제에서는 이 메소드를 사용해서 counter_cache용 컬럼의 이름을 가져옵니다.

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `deconstantize`

`deconstantize` 메소드는 전체 경로명을 받아, 실제 상수의 이름을 제거합니다.

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

다음의 Active Record 예시에서는 `Module#qualified_const_set`에서 이 메소드를 사용하고 있습니다.

```ruby
def qualified_const_set(path, value)
  QualifiedConstUtils.raise_if_absolute(path)

  const_name = path.demodulize
  mod_name = path.deconstantize
  mod = mod_name.empty? ? self : qualified_const_get(mod_name)
  mod.const_set(const_name, value)
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `parameterize`

`parameterize` 메소드는 리시버를 URL에서 사용가능한 형태로 정규화합니다.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

실제로 얻는 문자열은 `ActiveSupport::Multibyte::Chars`의 인스턴스로 래핑되어있습니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `tableize`

`tableize`메소드는 `underscore`를 실행한 뒤, `pluralize`를 실행한 것과 동일합니다.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

보통은 모델명에 `tableize`를 사용하면 그 모델을 위한 테이블 이름을 얻을 수 있습니다. 실제 Active Record는 클래스 이름에 `demodulize`를 호출하고, 변환된 문자열에 영향을 줄 수 있는 가능성이 있는 옵션을 몇가지 더 확인하기 때문에, 실제로는 `tableize`를 호출하는 것 뿐만 아니라 그 이외의 작업들도 처리합니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `classify`

`classify` 메소드는 `tableize`와 반대의 동작을 합니다. 주어진 테이블 이름에 대응하는 클래스 이름을 반환합니다.

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

이 메소드는 컨텍스트가 적용된 테이블 이름도 처리 가능합니다.

```ruby
"highrise_production.companies".classify # => "Company"
```

`classify`가 돌려주는 클래스 이름은 문자열입니다. 얻은 문자열에 대해서 `constantize`를 호출하는 것으로 실제 클래스 객체를 얻을 수 있습니다.

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `constantize`

`constantize` 메소드는 리시버의 값을 참조하여 실제 객체를 반환합니다.

```ruby
"Fixnum".constantize # => Fixnum

module M
  X = 1
end
"M::X".constantize # => 1
```

주어진 문자열을 `constantize` 메소드로 평가하더라도 기존의 상수와 매치되지 않는, 또는 지정된 상수명이 올바르지 않은 경우에는 `NameError`가 발생합니다.

`constantize` 메소드에 의한 상수 이름 평가는 항상 최상위의 `Object`로부터 시작됩니다. 이것은 상수 이름이 절대경로("::"로 시작)가 아닐 경우에도 동일합니다.

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

따라서 이 메소드는 같은 위치에서 Ruby가 상수를 평가할 때의 값과 항상 동일하다고 말할 수 없습니다.

메일러(mailer)의 테스트 케이스에서는 테스트할 클래스의 이름으로부터 태스트 대상 메일러를 얻어오기 위해서 `constantize` 메소드를 사용합니다.

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.sub(/Test$/, '').constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `humanize`

`humanize` 메소드는 속성명을 (영어 기준으로) 읽기 쉽게 변환해줍니다.

구체적으로는 다음과 같은 작업을 수행합니다.

  * 인수에 (영어의) 활용 규칙을 적용합니다(inflection).
  * 말머리에 언더스코어가 있는 경우 제거합니다.
  * 어미에 "_id"가 있는 경우에 제거합니다.
  * 그 이외의 언더스코어는 띄어쓰기로 치환합니다.
  * 약어를 제외하고 모든 단어를 소문자로 변환합니다(downcase).
  * 첫 단어만 첫글자를 대문자로 변환합니다(capitalize).

`capitalize` 옵션을 false로 지정하면 첫단어의 첫글자를 대문자로 변환하지 않습니다(기본값은 true).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

"SSL"이 접두어로 정의되어 있는 경우에는 아래와 같이 변환됩니다.

```ruby
'ssl_error'.humanize # => "SSL error"
```

헬퍼 메소드 `full_messages`에서는 속성명을 메시지에 포함할 때 `humanize`를 사용합니다.

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  ...
end
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

#### `foreign_key`

`foreign_key` 메소드는 클래스의 이름으로부터 외래키의 이름을 구할 때 사용합니다. 구체적으로는 `demodulize`, `underscore`를 실행하고 어미에 "_id"를 추가합니다.

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

어미에 "_id"의 언더스코어가 불필요한 경우에는 인수를 통해 `false`를 넘겨주면 됩니다.

```ruby
"User".foreign_key(false) # => "userid"
```

Association에서 외래키의 이름을 추측할 때 이 메소드를 사용합니다. 예를 들어 `has_one`과 `has_many`에서는 다음과 같은 처리를 합니다.

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: `active_support/core_ext/string/inflections.rb`에 정의되어 있습니다.

### Conversions

#### `to_date`, `to_time`, `to_datetime`

`to_date`, `to_time`, `to_datetime` 메소드는 `Date._parse`를 래핑하여 사용하기 편하게 해줍니다.

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => Tue Jul 27 23:37:00 UTC 2010
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time`은 옵션으로 `:utc`나 `:local`을 인수로 받아 시간대를 지정할 수 있습니다.

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => Tue Jul 27 23:42:00 UTC 2010
"2010-07-27 23:42:00".to_time(:local) # => Tue Jul 27 23:42:00 +0200 2010
```

기본값은 `:utc`입니다.

더 자세한 내용은 `Date._parse`의 문서를 참조해주세요.

INFO: 3개의 메소드는 어느 것이든 리시버가 blank인 경우에는 `nil`을 반환합니다.

NOTE: `active_support/core_ext/string/conversions.rb`에 정의되어 있습니다.

`Numeric` 확장
-----------------------

### 바이트

모든 숫자에 다음 메소드를 사용할 수 있습니다.

```ruby
bytes
kilobytes
megabytes
gigabytes
terabytes
petabytes
exabytes
```

이 메소드는 대응하는 바이트 수를 돌려줄 때에 1024를 곱해줍니다.

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384
-4.exabytes   # => -4611686018427387904
```

단수형으로도 사용할 수 있습니다.

```ruby
1.megabyte # => 1048576
```

NOTE: `active_support/core_ext/numeric/bytes.rb`에 정의되어 있습니다.

### Time

예를 들어 `45.minutes + 2.hours + 4.years`와 같이 시간을 계산하고 싶을 때가 있습니다.

이런 메소드에서는 from_now나 ago등을 사용하거나, 또는 Time 객체로부터 얻은 결과를 더하거나 뺄 때에 Time#advance를 사용하여 정확한 날짜 계산을 수행합니다. 아래는 예제입니다.

```ruby
# Time.current.advance(months: 1)와 동등
1.month.from_now

# Time.current.advance(years: 2)와 동등
2.years.from_now

# Time.current.advance(months: 4, years: 5)와 동등
(4.months + 5.years).from_now
```

### 형식 변환

숫자는 다양한 방법으로 나타낼 수 있습니다.

숫자를 전화번호 형식의 문자열로 변환할 수 있습니다.

```ruby
5551234.to_s(:phone)
# => 555-1234
1235551234.to_s(:phone)
# => 123-555-1234
1235551234.to_s(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_s(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_s(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_s(:phone, country_code: 1)
# => +1-123-555-1234
```

통화 형식으로 변환할 수 있습니다.

```ruby
1234567890.50.to_s(:currency)                 # => $1,234,567,890.50
1234567890.506.to_s(:currency)                # => $1,234,567,890.51
1234567890.506.to_s(:currency, precision: 3)  # => $1,234,567,890.506
```

백분율로 변환할 수 있습니다.

```ruby
100.to_s(:percentage)
# => 100.000%
100.to_s(:percentage, precision: 0)
# => 100%
1000.to_s(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_s(:percentage, precision: 5)
# => 302.24399%
```

구분자를 추가하여 문자열로 변환할 수 있습니다.

```ruby
12345678.to_s(:delimited)                     # => 12,345,678
12345678.05.to_s(:delimited)                  # => 12,345,678.05
12345678.to_s(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_s(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_s(:delimited, separator: " ")  # => 12,345,678 05
```

특정 자리수를 가지는 문자열로 변환할 수 있습니다.

```ruby
111.2345.to_s(:rounded)                     # => 111.235
111.2345.to_s(:rounded, precision: 2)       # => 111.23
13.to_s(:rounded, precision: 5)             # => 13.00000
389.32314.to_s(:rounded, precision: 0)      # => 389
111.2345.to_s(:rounded, significant: true)  # => 111
```

사람에게 가독성이 좋은 바이트 형식으로 변환할 수 있습니다.

```ruby
123.to_s(:human_size)            # => 123 Bytes
1234.to_s(:human_size)           # => 1.21 KB
12345.to_s(:human_size)          # => 12.1 KB
1234567.to_s(:human_size)        # => 1.18 MB
1234567890.to_s(:human_size)     # => 1.15 GB
1234567890123.to_s(:human_size)  # => 1.12 TB
```

사람에게 가독성이 좋은 숫자 단위를 사용할 수 있습니다.

```ruby
123.to_s(:human)               # => "123"
1234.to_s(:human)              # => "1.23 Thousand"
12345.to_s(:human)             # => "12.3 Thousand"
1234567.to_s(:human)           # => "1.23 Million"
1234567890.to_s(:human)        # => "1.23 Billion"
1234567890123.to_s(:human)     # => "1.23 Trillion"
1234567890123456.to_s(:human)  # => "1.23 Quadrillion"
```

NOTE: `active_support/core_ext/numeric/conversions.rb`에 정의되어 있습니다.

`Integer` 확장
-----------------------

### `multiple_of?`

`multiple_of?` 메소드는 리시버의 정수가 인자로 넘긴 숫자의 배수인지 테스트합니다.

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: `active_support/core_ext/integer/multiple.rb`에 정의되어 있습니다.

### `ordinal`

`ordinal` 메소드는 리시버의 정수에 대응하는 서수 어미를 반환합니다.

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: `active_support/core_ext/integer/inflections.rb`에 정의되어 있습니다.

### `ordinalize`

`ordinalize` 메소드는 리시버의 정수에 대응하는 서수 문자열을 추가한 것을 반환합니다. 직전에 소개한 `ordinal`은 서수 문자열**만을** 반환한다는 점이 다릅니다.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: `active_support/core_ext/integer/inflections.rb`에 정의되어 있습니다.

`BigDecimal` 확장
--------------------------
### `to_s`

이 `to_s` 메소드는 `to_formatted_s`의 별명입니다. 이 메소드는 부동소수점 표기법의 BigDecimal값을 간단하게 표시할 때 유용합니다.

```ruby
BigDecimal.new(5.00, 6).to_s  # => "5.0"
```

### `to_formatted_s`

이 `to_formatted_s` 메소드는 기본 수식자(specifier) "F"를 사용합니다. 다시말해 `to_formatted_s` 또는 `to_s`를 호출하면 엔지니어링 표기법(ex: '0.5E1')이 아닌 부동소수점 표현을 얻을 수 있습니다.

```ruby
BigDecimal.new(5.00, 6).to_formatted_s  # => "5.0"
```

또한 심볼을 사용하여 지정할 수도 있습니다.

```ruby
BigDecimal.new(5.00, 6).to_formatted_s(:db)  # => "5.0"
```

엔지니어링 표기법도 지원합니다.

```ruby
BigDecimal.new(5.00, 6).to_formatted_s("e")  # => "0.5E1"
```

`Enumerable` 확장
--------------------------

### `sum`

`sum` 메소드는 enumerable에 있는 요소의 합을 반환합니다.

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

`+`에 응답하는 요소만이 덧셈의 대상이 됩니다.

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{a: 1, b: 2, c: 3}.sum # => [:b, 2, :c, 3, :a, 1]
```

빈 컬렉션은 기본으로 0을 반환합니다만, 이 동작은 바꿀 수 있습니다.

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

블럭을 넘긴 경우 `sum`은 이터레이터가 되어서 컬렉션의 요소를 yield하며, 거기서 돌려받은 값의 합을 반환합니다.

```ruby
(1..5).sum {|n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

블럭을 주는 경우에도 리시버가 비어있을 때의 기본값을 지정할 수 있습니다.

```ruby
[].sum(1) {|n| n**3} # => 1
```

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.

### `index_by`

`index_by` 메소드는 어떤 키에 의해서 인덱싱된 enumerable의 요소를 가지는 해시를 생성합니다.

이 메소드는 컬렉션을 돌며 각 요소를 블럭에 넘겨줍니다. 이 요소는 블럭으로부터 반환된 값에 의해서 인덱싱됩니다.

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

WARNING: 키는 유일해야합니다. 다른 요소로부터 같은 값이 반환되면 가장 마지막 항목만이 저장됩니다.

NOTE: `active_support/core_ext/enumerable.rb에 정의되어 있습니다.

### `many?`

`many?` 메소드는 `collection.size > 1`의 축약형입니다.

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

`many?`는 블럭을 넘길 수 있는데 이 블럭에서 true를 반환하는 것들만 세서 판정합니다.

```ruby
@see_more = videos.many? {|video| video.category == params[:category]}
```

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.

### `exclude?`

`exclude?`는 주어진 객체가 그 컬렉션에 속해 있지 **않은지** 테스트합니다. 다시 말해, `include?`의 반대 동작입니다.

```ruby
to_visit << node if visited.exclude?(node)
```

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.

### `without`

`without` 메소드는 지정한 요소를 제외한 enumerable의 사본을 반환합니다.


```ruby
["David", "Rafael", "Aaron", "Todd"].without("Aaron", "Todd") # => ["David", "Rafael"]
```

NOTE: `active_support/core_ext/enumerable.rb`에 정의되어 있습니다.

`Array` 확장
---------------------

### Accessing

Active Support에는 배열에 여러가지 API를 추가하며, 이는 배열을 편리하게 사용할 수 있도록 해줍니다. 예를 들어 `to` 메소드는 배열의 첫번째 요소부터 넘겨받은 인덱스가 가리키는 요소까지의 범위를 반환합니다.

```ruby
%w(a b c d).to(2) # => %w(a b c)
[].to(7)          # => []
```

마찬가지로 `from` 메소드는 배열에서 인덱스가 가리키는 요소로부터 마지막 요소까지를 반환합니다. 넘겨받은 인덱스가 배열의 길이보다 길 경우에는 빈 배열을 반환합니다.

```ruby
%w(a b c d).from(2)  # => %w(c d)
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

`second`, `third`, `fourth`, `fifth`는 대응하는 요소를 반환합니다(`first`는 원래 내장되어 있는 메소드입니다). 재미를 위해 지금은 `forty_two`도 사용할 수 있습니다(역주: [Rails 2.2 이후](https://github.com/rails/rails/commit/9d8cc60ec3845fa3e6f9292a65b119fe4f619f7e)로 사용 가능합니다. '42'에 대해서는 Wikipedia의 [이 문서](https://ko.wikipedia.org/wiki/%EC%9D%80%ED%95%98%EC%88%98%EB%A5%BC_%EC%97%AC%ED%96%89%ED%95%98%EB%8A%94_%ED%9E%88%EC%B9%98%ED%95%98%EC%9D%B4%EC%BB%A4%EB%A5%BC_%EC%9C%84%ED%95%9C_%EC%95%88%EB%82%B4%EC%84%9C_(%EC%86%8C%EC%84%A4))의 줄거리를 참조해주세요.).

```ruby
%w(a b c d).third # => c
%w(a b c d).fifth # => nil
```

NOTE: `active_support/core_ext/array/access.rb`에 정의되어 있습니다.

### 요소를 추가하기

#### `prepend`

이 메소드는 `Array#unshift`의 별명입니다.

```ruby
%w(a b c d).prepend('e')  # => %w(e a b c d)
[].prepend(10)            # => [10]
```

NOTE: `active_support/core_ext/array/prepend_and_append.rb`에 정의되어 있습니다.

#### `append`

이 메소드는 `Array#<<`의 별명입니다.

```ruby
%w(a b c d).append('e')  # => %w(a b c d e)
[].append([1,2])         # => [[1,2]]
```

NOTE: `active_support/core_ext/array/prepend_and_append.rb`에 정의되어 있습니다.

### 옵션을 전개하기

Ruby에서는 메소드에 주어진 마지막 인수가 해시인 경우, 그것이 `&block` 인수인 경우를 제외하고 해시의 중괄호를 생략할 수 있습니다.

```ruby
User.exists?(email: params[:email])
```

이러한 편의 문법(Syntax sugar)은 인수들이 순서에 의존하지 않도록 만들고, 이름을 가지는 파라미터를 에뮬레이트하는 인터페이스를 제공하기 위해 Rails에서 빈번하게 사용되고 있습니다. 특히 말미에 옵션의 해시를 두는 것은 무척 일반적입니다.

그러나 어떤 메소드가 받는 인수의 숫자는 고정적이지 않으며, 메소드 선언에서 `*`가 사용될 경우 중괄호가 생략된 옵션 해시는 인수 배열의 마지막 원소가 되어버려서 해시로 처리되지 않습니다.

이런한 경우, `extract_options!`를 사용해서 배열 마지막 요소의 타입을 체크하고, 그것이 해시인 경우 그 해시를 꺼내 반환합니다. 해시가 아닌 경우에는 빈 해시를 돌려줍니다.

`caches_action` 컨트롤러 매크로에서 사용된 예시를 확인해봅시다.

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  ...
end
```

이 메소드는 여러개의 액션명을 인수로 받을 수 있으며, 인수의 마지막 항목에 옵션 해시를 사용할 수 있습니다. `extract_options!` 메소드를 사용하면 그 옵션 해시를 꺼내고, `actions`로부터는 제거하는 작업까지 간단하고 명시적으로 처리할 수 있습니다.

NOTE: `active_support/core_ext/array/extract_options.rb`에 정의되어 있습니다.

### Conversions

#### `to_sentence`

`to_sentence` 메소드는 배열을 변환하여 각 요소를 열거하는 영어 문장으로 변환합니다.

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

이 메소드는 3개의 옵션을 사용할 수 있습니다.

* `:two_words_connector`: 항목이 2개일 경우의 접속사를 지정합니다. 기본값은 " and "입니다.
* `:words_connector`: 3개 이상의 요소가 존재하는 경우 마지막 2개를 제외한 나머지에서 사용될 접속사를 지정합니다. 기본값은 ", "입니다.
* `:last_word_connector`: 3개 이상의 요소가 존재하는 경우 마지막 2개의 요소를 연결할 때 사용할 접속사를 지정합니다. 기본값은 ", and "입니다.

이러한 값들은 국제화를 쉽게 할 수 있습니다. 사용되는 키는 다음과 같습니다.

| 옵션                 | I18n 키                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTE: `active_support/core_ext/array/conversions.rb`에 정의되어 있습니다.

#### `to_formatted_s`

`to_formatted_s` 메소드는 기본으로 `to_s`와 동일한 동작을 합니다.

그러나 배열 내부에 `id`에 응답하는 항목이 존재하는 경우 `:db`라는 심볼을 넘길 수 있습니다. 이 방법은 Active Record 객체의 컬렉션을 다룰때 자주 사용됩니다. 반환되는 문자열은 다음과 같습니다.

```ruby
[].to_formatted_s(:db)            # => "null"
[user].to_formatted_s(:db)        # => "8456"
invoice.lines.to_formatted_s(:db) # => "23,567,556,12"
```

이 예제에서의 값은 `id`를 호출하여 받아온 값입니다.

NOTE: `active_support/core_ext/array/conversions.rb`에 정의되어 있습니다.

#### `to_xml`

`to_xml` 메소드는 리시버를 XML 표현으로 변환한 결과를 문자열로 반환합니다.

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

실제로는 `to_xml`를 모든 요소에게 호출하고, 결과를 루트 노드에 모읍니다. 이 메소드는 모든 요소가 `to_xml`에 응답해야할 필요가 있으며, 그렇지 않은 경우 예외를 발생시킵니다.

기본적으로 루트 요소의 이름은 첫번째 요소의 클래스 이름을 언더스코어화(underscorize), 대시화(dasherize), 마지막으로 복수형으로 변환(pluralize)합니다. 나머지 요소들이 첫번째 요소와 같은 타입(`is_a?`로 테스트됩니다)이고, 해시가 아닐것이 전제 조건입니다. 이 예제에서는 "contributors"입니다.

첫번째 요소와 같은 타입을 가지지 않는 요소가 하나라도 있을 경우, 루트 노드에는 `objects`가 사용됩니다.

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

리시버가 해시의 배열인경우, 루트 요소는 기본적으로 `objects`가 됩니다.

```ruby
[{a: 1, b: 2}, {c: 3}].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

WARNING: 컬렉션이 비어있는 경우, 루트 요소는 기본으로 "nil-classes"가 됩니다. 여기에서도 알 수 있듯, 예를 들어 위의 예제에서 contributors 목록의 루트 요소는 컬렉션이 만약 비어 있다면 "contributors"가 아닌 "nil-classes"가 됩니다. `:root` 옵션을 통해 일관성 있는 루트 요소를 사용할 수도 있습니다.

자식 노드의 이름은 기본으로는 루트 요소의 단수형이 사용됩니다. 위 예제라면 "contributor"나 "object"입니다. `:children` 옵션을 사용하면, 다른 노드명을 지정할 수 있습니다.

기본 XML 빌더는 `Builder::XmlMarkup`으로부터 직접 생성된 인스턴스입니다. 옵션 `:builder`를 사용해서 독자적인 빌더를 구성할 수도 있습니다. 이 메소드에서는 `:dasherize`와 다른 옵션들을 마찬가지로 사용할 수 있으며 자동으로 빌더에 전송됩니다. 

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

NOTE: `active_support/core_ext/array/conversions.rb`에 정의되어 있습니다.

### Wrapping

`Array.wrap` 메소드는 배열에 어떤 인수가 배열(또는 배열 같은)이 아닌 경우, 이를 배열로 감싸줍니다.

특징:

* 인수가 `nil`인 경우에 빈 배열을 반환합니다.
* 위를 제외한 상황에서 인수에 `to_ary`를 호출할 수 있는 경우 `to_ary`가 호출되며, `to_ary`의 값이 `nil`이 아닌 경우에 그 값을 사용합니다.
* 그 이외의 경우 인수를 가지는 배열(요소가 1개인 배열)이 반환됩니다.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

이 메소드의 목적은 `Kernel#Array`와 비슷합니다만, 몇가지 다른 점이 있습니다.

* 인수에서 `to_ary`를 호출할 수 있는 경우, 그 메소드를 호출합니다. `nil`이 반환된 경우 `Kernel#Array`는 `to_a`를 시도합니다만 `Array.wrap`는 그러지 않고 곧바로 단일 요소를 가지는 배열을 만들어 반환합니다.
* `to_ary`로부터 반환된 값이 `nil`이 아니고, `Array` 객체도 아닌 경우 `Kernel#Array`는 예외를 발생시킵니다만, `Array.wrap`은 예외를 발생시키지 않고 그 값을 그대로 반환합니다.
* 빈 배열을 반환하는 nil을 제외하고, 인수에 대해서 `to_a`를 호출하지 않습니다.

마지막 점은 열거형끼리 비교하는 경우에 유용합니다.

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

이 동작은 splat 연산사를 사용하는 기법과도 관련이 있습니다.

```ruby
[*object]
```

이는 Ruby 1.8일 경우 `nil`에 대해서 `[nil]`을 반환하며, 그 이외의 경우에는 `Array(object)`를 호출합니다(역주: Ruby 1.9 이후로는 빈 배열을 반환합니다).

따라서 이 경우 `nil`에 대한 동작만이 다르며, 위에서 설명된 `Kernel#Array`에 대해서도 이 다른 동작이 나머지 `object`에도 적용됩니다.

NOTE: `active_support/core_ext/array/wrap.rb`에 정의되어 있습니다.

### 복제

`Array.deep_dup` 메소드는 자기 자신을 복사함과 동시에 그 내부에 있는 모든 객체를 Active Support의 `Object#deep_dup` 메소드를 사용하여 재귀적으로 복사합니다. 이 동작은 `Array#map`을 사용하여 `deep_dup` 메소드를 내부의 각 객체에 대해서 호출합니다.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTE: `active_support/core_ext/object/deep_dup.rb`에 정의되어 있습니다.

### 그룹화

#### `in_groups_of(number, fill_with = nil)`

`in_groups_of` 메소드는 지정한 크기에서 배열을 연속되는 그룹으로 분할합니다. 분할된 그룹을 내포하는 배열을 하나 반환합니다.

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

블럭을 넘긴 경우에는 yield를 호출합니다.

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

첫번째 예제에서는 `in_groups_of` 메소드는 마지막 그룹을 가급적 `nil` 요소로 채워서 요구받은 크기를 맞추려고 합니다. 이 빈 길이 만큼을 채울때 사용하는 요소를 인수로 지정할 수 있습니다.

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

두번째 옵션의 인수로 `false`를 넘겨주면 마지막 요소의 남는 길이를 채우지 않습니다.

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

따라서 `false`는 빈 공간을 채우는 값으로 사용할 수 없습니다.

NOTE: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.

#### `in_groups(number, fill_with = nil)`

`in_groups`은 배열을 지정한 갯수로 나누고, 분할된 그룹들을 가지고 있는 배열을 하나 반환합니다.

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

블럭을 넘겼을 경우에는 yield를 호출합니다.

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) {|group| p group}
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

이 예제에서는 `in_groups`는 일부 그룹들의 뒤에 필요에 따라서 `nil` 요소로 채우고 있습니다. 하나의 그룹에는 이러한 여분의 요소가 각 그룹의 마지막에 필요한 만큼 최대 하나가 추가될 수 있습니다. 그러한 값을 가지는 그룹은 항상 전체에서 마지막에 존재하게 됩니다.

공백을 채우는 값은 두번째 옵션 인수로 지정할 수 있습니다.

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

만약 `false`를 넘기면 요소의 갯수가 부족한 경우에도 채우지 않습니다.

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

따라서 `false`는 빈 공간을 채우는 값으로 사용할 수 없습니다.

NOTE: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.

#### `split(value = nil)`

`split` 메소드는 지정된 구분자로 배열을 나누고, 분할된 결과를 반환합니다.

블럭을 넘긴 경우에는 배열의 요소중 블록이 true를 돌려주는 요소가 구분자로 사용됩니다.

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

블록을 넘기지 않은 경우, 인수로 받은 값을 구분자로 사용합니다. 기본 구분자는 `nil`입니다.

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

TIP: 이 예제에서 알 수 있듯, 구분자가 연속되면 빈 배열이 발생합니다.

NOTE: `active_support/core_ext/array/grouping.rb`에 정의되어 있습니다.

`Hash` 확장
--------------------

### Conversions

#### `to_xml`

`to_xml` 메소드는 리시버를 XML 표현으로 변환한 결과를 문자열로 반환합니다.

```ruby
{"foo" => 1, "bar" => 2}.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

구체적으로는 이 메소드에 주어진 것들로부터 _값_에 대응하는 노드를 생성합니다. 키와 값을 사용해서 다음과 같은 동작을 수행합니다.

* 값이 해시일 때 키를 `:root`로 하여 재귀적으로 호출됩니다.

* 값이 배열일 때 키를 `:root`로 키를 단수형으로(singularize)만든 것을 `:children`에 지정해서 재귀적으로 호출됩니다.

* 값이 호출 가능한(callable) 객체인 경우, 인수가 하나 또는 두 개 필요합니다. 인수의 갯수에 따라서(arity 메소드로 확인) 객체를 옵션 해시와 함께 호출합니다. 옵션 해시의 첫번째 인수에는 `:root`에 사용되는 값이며, 두번째 인수에는 키를 단수형으로 만든 값이 사용됩니다. 반환값은 새 노드가 됩니다.

* `value`이 `to_xml` 메소드를 호출 가능한 경우 `:root`에 키를 사용합니다.

* 그 이외의 경우 `key`를 태그로 사용해서 `value`를 문자열 형식으로 변환한 텍스트 노드가 생성됩니다. `value`가 `nil`인 경우, "nil" 속성이 "true"로 설정된 노드가 추가됩니다. `:skip_types` 옵션이 true가 아닌 경우(또는 `:skip_types` 옵션이 없는 경우) 아래와 같은 맵핑을 통해서 "type" 속성이 추가됩니다.

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Fixnum"     => "integer",
  "Bignum"     => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

기본으로 루트 노드는 "hash"가 됩니다만, `:root` 옵션을 통해 변경할 수 있습니다.

기본 XML 빌더는 `Builder::XmlMarkup`로부터 직접 생성된 인스턴스입니다. `:builder` 옵션으로 직접 구성한 빌더를 사용할 수 있으며, 이 메소드에서는 `:dasherize`와 그 동족들, 그리고 다른 옵션들도 사용할 수 있습니다. 이 옵션들은 자동으로 빌더에 넘겨집니다.

NOTE: `active_support/core_ext/hash/conversions.rb`에 정의되어 있습니다.

### 병합

Ruby에는 2개의 해시를 병합하는 내장 메소드 `Hash#merge`가 있습니다.

```ruby
{a: 1, b: 1}.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support에서는 이외에도 편리하게 해시를 병합할 수 있는 몇가지 방법을 제공합니다.

#### `reverse_merge`と`reverse_merge!`

`merge`에서는 키가 충돌하는 경우, 인수로 받은 해시의 키가 우선됩니다. 다음과 같은 방법을 사용하는 것으로 기본값을 가지는 옵션 해시를 간단하게 사용할 수 있습니다.

```ruby
options = {length: 30, omission: "..."}.merge(options)
```

Active Support에서는 다른 방법을 사용하는 경우를 위해 `reverse_merge`도 정의하고 있습니다.

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

병합을 리시버에서 직접 수행하는 파괴적인 메소드 `reverse_merge!`도 있습니다.

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

WARNING: `reverse_merge!`는 호출한 쪽의 해시값을 변경할 수 있다는 점을 주의해주세요. 그것이 의도된 동작이든 아니든, 조심해야 합니다.

NOTE: `active_support/core_ext/hash/reverse_merge.rb`에 정의되어 있습니다.

#### `reverse_update`

`reverse_update` 메소드는 위에서 설명한 `reverse_merge!`의 별명입니다.

WARN: `reverse_update`에는 파괴적인 버전이 존재하지 않습니다.

NOTE: `active_support/core_ext/hash/reverse_merge.rb`에 정의되어 있습니다.

#### `deep_merge`와 `deep_merge!`

위의 예제에서 설명했듯이, 키가 리시버와 인수 양쪽에서 중복되어 있을 경우, 인수의 값이 우선됩니다.

Active Support 에서는 `Hash#deep_merge`가 정의되어 있습니다. `deep_merge`에서는 양쪽에 같은 키가 존재하고, 나아가 둘 다 해시를 값으로 가지고 있는 경우에, 그 하위의 해시를 _병합_한 것을 최종적인 값으로 사용합니다.

```ruby
{a: {b: 1}}.deep_merge(a: {c: 2})
# => {:a=>{:b=>1, :c=>2}}
```

`deep_merge!` 메소드는 같은 동작을 파괴적으로 수행합니다.

NOTE: `active_support/core_ext/hash/deep_merge.rb`에 정의되어 있습니다.

### Deep Duplicate

`Hash.deep_dup` 메소드는 자기 자신을 복사하고, 나아가 그 내부의 모든 키와 값을 재귀적으로 복사합니다. 복사를 할 때에는 Active Support의 `Object#deep_dup` 메소드를 사용합니다. 이 동작은 `Enumerator#each_with_object`를 사용하여 내부에 존재하는 모든 객체에 대해서 `deep_dup`를 보내는 것과 유사합니다.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: `active_support/core_ext/object/deep_dup.rb`에 정의되어 있습니다.

### 해시 키 조작하기

#### `except`와 `except!`

`except` 메소드는 인수로 지정된 키가 존재한다면 리시버의 해시에서 그 키를 제거합니다.ㄴ

```ruby
{a: 1, b: 2}.except(:a) # => {:b=>2}
```

리시버에서 `convert_key`가 호출 가능한 경우, 그 메소드는 모든 인수에 대해서 호출 됩니다. 그 덕분에 `except` 메소드가 예를 들어 _with_indifferent_access_와도 잘 동작합니다.

```ruby
{a: 1}.with_indifferent_access.except(:a)  # => {}
{a: 1}.with_indifferent_access.except("a") # => {}
```

리시버로부터 키를 제거하는 파괴적인 `except!`도 있습니다

NOTE: `active_support/core_ext/hash/except.rb`에 정의되어 있습니다.

#### `transform_keys`와 `transform_keys!`

`transform_keys` 메소드는 블럭을 하나 받고, 해시를 하나 반환합니다. 반환되는 해시는 리시버의 각각의 키에 대해서 블럭으로 넘겨진 작업을 적용한 결과를 포함합니다.

```ruby
{nil => nil, 1 => 1, a: :a}.transform_keys { |key| key.to_s.upcase }
# => {"" => nil, "A" => :a, "1" => 1}
```

키가 중복되는 경우에는 그중 하나의 값이 우선됩니다. 우선되는 값은 같은 해시가 주어진 경우라도 같은 결과를 준다고 보장하지 않습니다.

```ruby
{"a" => 1, a: 2}.transform_keys { |key| key.to_s.upcase }
# 어떻게 될지는 알 수 없음
# => {"A"=>2}
# 또는
# => {"A"=>1}
```

이 메소드는 특수한 변환을 하고 싶을 때에 편리합니다. 예를 들어 `stringify_keys`와 `symbolize_keys`에서는 키를 변환할 때에 `transform_keys`를 사용합니다.

```ruby
def stringify_keys
  transform_keys { |key| key.to_s }
end
...
def symbolize_keys
  transform_keys { |key| key.to_sym rescue key }
end
```

리시버 자체의 키에 대해서 파괴적인 작업을 하는 `transform_keys!` 메소드도 있습니다.

또한 `deep_transform_keys`나 `deep_transform_keys!`를 사용해서 주어진 해시의 모든 키와 그 내부에 중첩되어있는 모든 해시에 대해서 블럭의 작업을 수행할 수도 있습니다.

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_transform_keys { |key| key.to_s.upcase }
# => {""=>nil, "1"=>1, "NESTED"=>{"A"=>3, "5"=>5}}
```

NOTE: `active_support/core_ext/hash/keys.rb`에 정의되어 있습니다.

#### `stringify_keys`와 `stringify_keys!`

`stringify_keys` 메소드는 리시버의 해시 키를 문자열로 변환한 해시를 돌려줍니다. 구체적으로는 리시버의 해시 키에 대해서 `to_s`를 호출합니다.

```ruby
{nil => nil, 1 => 1, a: :a}.stringify_keys
# => {"" => nil, "a" => :a, "1" => 1}
```

키가 중복되는 경우, 한 쪽의 값이 우선됩니다. 우선되는 값은 같은 해시가 주어진 경우에도 항상 같다고 보장하지 않습니다.

```ruby
{"a" => 1, a: 2}.stringify_keys
# 어떤 값이 돌아올지 알 수 없음
# => {"a"=>2}
# 또는
# => {"a"=>1}
```

이 메소드는 심볼과 문자열이 모두 포함되어 있는 해시를 옵션으로 받을 때에 유용합니다. 예를 들어 `ActionView::Helpers::FormHelper`에는 아래와 같은 메소드가 있습니다.

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  ...
end
```

stringify_keys 메소드 덕분에 두번째 줄에서 키 "type"를 안전하게 사용할 수 있습니다. 그러므로 메소드의 사용자는 `:type`과 같은 심볼과 "type"같은 문자열을 취향대로 사용할 수 있습니다.

리시버의 키를 직접 문자열로 바꾸는 `stringify_keys!`도 있습니다.

또한 `deep_stringify_keys`나 `deep_stringify_keys!`를 사용해서 주어진 해시의 모든 키를 모두 문자열로 변환하고, 그 내부에 중첩되어 있는 모든 해시의 키 역시 문자열로 변환할 수 있습니다.

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: `active_support/core_ext/hash/keys.rb`에 정의되어 있습니다.

#### `symbolize_keys`와 `symbolize_keys!`

`symbolize_keys` 메소드는 리시버의 해시 키를 심볼로 변환하여 돌려줍니다. 구체적으로는 리시버의 해시 키에 대해서 `to_sym`를 호출합니다.

```ruby
{nil => nil, 1 => 1, "a" => "a"}.symbolize_keys
# => {1=>1, nil=>nil, :a=>"a"}
```

WARNING: 이 예제에서는 3개의 키중 마지막 하나만 심볼로 변환되지 않았다는 점에 주목하세요. 숫자와 nil은 심볼로 변환할 수 없습니다.

키가 중복되는 경우, 한 쪽의 값이 우선됩니다. 우선되는 값은 같은 해시가 주어진 경우에도 항상 같다고 보장하지 않습니다.

```ruby
{"a" => 1, a: 2}.symbolize_keys
# 어떤 값이 돌아올지 알 수 없음
# => {:a=>2}
# 또는
# => {:a=>1}
```

이 메소드는 심볼과 문자열이 모두 포함되어 있는 해시를 옵션으로 받을 때에 유용합니다. 예를 들어 `ActionController::UrlRewriter`에는 아래와 같은 메소드가 있습니다.

```ruby
def rewrite_path(options)
  options = options.symbolize_keys
  options.update(options[:params].symbolize_keys) if options[:params]
  ...
end
```

symbolize_keys 메소드 덕분에 두번째 줄에서 `:params` 키에 안전하게 접근할 수 있습니다. 메소드를 사용하는 사람은 `:params`와 같은 심볼과 "params" 같은 문자열 중에서 취향껏 고를 수 있습니다.

리시버의 키를 직접 심볼로 변환하는 파괴적인 `symbolize_keys!`도 있습니다.

나아가 `deep_symbolize_keys`나 `deep_symbolize_keys!`를 사용해서 주어진 해시의 모든 키와 그 안에 중첩되어있는 모든 해시의 키를 심볼로 변환할 수도 있습니다.

```ruby
{nil => nil, 1 => 1, "nested" => {"a" => 3, 5 => 5}}.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTE: `active_support/core_ext/hash/keys.rb`에 정의되어 있습니다.

#### `to_options`와 `to_options!`

`to_options` 메소드와 `to_options!` 메소드는 각각 `symbolize_keys` 메소드와 `symbolize_keys!` 메소드의 별명입니다.

NOTE: `active_support/core_ext/hash/keys.rb`에 정의되어 있습니다.

#### `assert_valid_keys`

`assert_valid_keys` 메소드는 임의의 갯수의 인수를 받을 수 있으며, 화이트리스트에 포함되어 있지 않은 키가 리시버에 존재하는지 테스트합니다. 그러한 키가 발견되었을 경우 `ArgumentError`를 발생시킵니다.

```ruby
{a: 1}.assert_valid_keys(:a)  # 넘어간다
{a: 1}.assert_valid_keys("a") # ArgumentError 발생
```

Active Record는 예를 들어 Association을 만들 때 잘 모르는 옵션들을 받지 않습니다. 이는 `assert_valid_keys`를 사용하여 구현되고 있습니다.

NOTE: `active_support/core_ext/hash/keys.rb`에 정의되어 있습니다.

### 값을 조작하기

#### `transform_values`와 `transform_values!`

`transform_values` 메소드는 블럭을 하나 받고 해시를 하나 반환합니다. 반환되는 해시에는 리시버의 각각의 값에 대해서 블럭의 작업을 수행한 결과가 포함됩니다.

```ruby
{ nil => nil, 1 => 1, :x => :a }.transform_values { |value| value.to_s.upcase }
# => {nil=>"", 1=>"1", :x=>"A"}
```

리시버 자체의 키에 대해서 파괴적으로 동작하는 `transform_values!` 메소드도 있습니다.

NOTE: `active_support/core_ext/hash/transform_values.rb`에 정의되어 있습니다.

### 자르기

Ruby에는 문자열이나 배열을 나누어 일부를 꺼내는 내장 메소드가 있습니다. Active Support는 이 동작을 해시에서도 동작하도록 확장합니다.

```ruby
{a: 1, b: 2, c: 3}.slice(:a, :c)
# => {:c=>3, :a=>1}

{a: 1, b: 2, c: 3}.slice(:b, :X)
# => {:b=>2} # 존재하지 않는 키는 무시
```

리시버에서 `convert_key`가 호출 가능한 경우 키를 정규화합니다.

```ruby
{a: 1, b: 2}.with_indifferent_access.slice("a")
# => {:a=>1}
```

NOTE: 나누는 작업은 키의 화이트리스트를 사용하여 옵션 해시를 깨끗하게 만들때 유용합니다.

파괴적인 나누기 작업을 하는 `slice!` 메소드도 있습니다. 이 메소드의 반환값은 삭제된 요소입니다.

```ruby
hash = {a: 1, b: 2}
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTE: `active_support/core_ext/hash/slice.rb`에 정의되어 있습니다.

### 추출

`extract!` 메소드는 주어진 키와 일치하는 키/값 쌍을 추출합니다.

```ruby
hash = {a: 1, b: 2}
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

`extract!` 메소드는 리시버의 해시의 자식 클래스와 동일한 클래스로 돌려줍니다.

```ruby
hash = {a: 1, b: 2}.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: `active_support/core_ext/hash/slice.rb`에 정의되어 있습니다.

### 해시 키가 심볼이든 문자열이든 동일하기 다루기(indifferent access)

`with_indifferent_access` 메소드는 리시버에 대해서 `ActiveSupport::HashWithIndifferentAccess`를 실행한 결과를 반환합니다.

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

NOTE: `active_support/core_ext/hash/indifferent_access.rb`에 정의되어 있습니다.

### Compacting

`compact` 메소드와 `compact!` 메소드는 해시로부터 `nil` 값을 제거한 뒤 반환합니다.

```ruby
{a: 1, b: 2, c: nil}.compact # => {a: 1, b: 2}
```

NOTE: `active_support/core_ext/hash/compact.rb`에 정의되어 있습니다.

`Regexp` 확장
----------------------

### `multiline?`

`multiline?` 메소드는 정규표현에 `/m` 플래그가 설정되어 있는지를 확인합니다. 이 플래그가 설정되어 있으면 마침표(.)를 개행으로 인식하고, 여러줄을 처리할 수 있게 해줍니다.

```ruby
%r{.}.multiline? # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails는 이 메소드를 라우팅에서 사용하고 있습니다. 라우팅에서는 정규표현에서 여러줄을 다루는 것을 용납하지 않기 때문에 이러한 플래그를 통해서 제한을 추가하고 있습니다.

```ruby
def assign_route_options(segments, defaults, requirements)
  ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option not allowed in routing requirements: #{requirement.inspect}"
  end
  ...
end
```

NOTE: `active_support/core_ext/regexp.rb`에 정의되어 있습니다.

`Range` 확장
---------------------

### `to_s`

Active Support는 `Range#to_s` 메소드를 확장해서 포맷 인수를 옵션으로 받을 수 있습니다. 이 가이드를 작성하는 시점에서는 기본이 아닌 포맷으로서 지원되고 있는 것은 `:db` 뿐입니다.

```ruby
(Date.today..Date.tomorrow).to_s
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_s(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

이 예제에서도 알 수 있듯이, 포맷에 `:db`를 지정하면 SQL의 `BETWEEN` 절이 생성됩니다. 이 포맷은 Active Record에서 조건의 값의 Range를 처리하기 위해서 사용됩니다.

NOTE: `active_support/core_ext/range/conversions.rb`에 정의되어 있습니다.

### `include?`

`Range#include?` 메소드와 `Range#===` 메소드는 주어진 인스턴스의 Range에 값이 포함되는 지를 확인합니다.

```ruby
(2..3).include?(Math::E) # => true
```

Active Support에서는 이러한 메소드를 확장하여 Range 객체를 인수로 받을 수 있게끔 만들었습니다. 이 경우 인수의 범위가 리시버의 범위에 포함되는 지를 확인합니다.

```ruby
(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false

(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false
```

NOTE: `active_support/core_ext/range/include_range.rb`에 정의되어 있습니다.

### `overlaps?`

`Range#overlaps?` 메소드는 주어진 2개의 (비어있지 않은) 범위가 겹치는지를 확인합니다.

```ruby
(1..10).overlaps?(7..11)  # => true
(1..10).overlaps?(0..7)   # => true
(1..10).overlaps?(11..27) # => false
```

NOTE: `active_support/core_ext/range/overlaps.rb`에 정의되어 있습니다.

`Date` 확장
--------------------

### 계산

NOTE: 다음 메소드들은 모두 같은 파일 `active_support/core_ext/date/calculations.rb`에 위치하고 있습니다.

INFO: 다음 계산 방법들 중의 일부에서는 1582년 10월을 극단적인 예외로서 사용하고 있습니다. 이 달에는 율리우스 력으로부터 그레고리 력으로 변경이 이루어져서 10월 5일부터 10월 14일까지가 존재하지 않습니다. 이 가이드에서는 이 특수한 달에 대해서 길게 이야기하지 않습니다만, 메소드가 이 달에서도 기대대로 동작한다는 점을 설명해두고 싶습니다. 구체적인 예시로는 `Date.new(1582, 10, 4).tomorrow`를 실행하면 `Date.new(1582, 10, 15)`가 반환됩니다. 기대대로 동작한다는 것은 Active Support의 `test/core_ext/date_ext_test.rb`용의 테스트 코드에서 확인하실 수 있습니다.

#### `Date.current`

Active Support에서는 `Date.current`를 정의하고 현재의 시간대에 맞는 '오늘'을 돌려줍니다. 이 메소드는 `Date.today`와 유사합니다만, 사용자가 정의한 시간대이 있는 경우에 그것을 고려한다는 점이 다릅니다. Active Support에서는 `Date.yesterday` 메소드와 `Date.tomorrow`도 정의하고 있습니다. 인스턴스에서는 `past?`, `today?`, `future?`를 사용할 수 있으며, 이들은 모두 `Date.current`를 기준으로 계산됩니다.

사용자가 정의한 시간대를 사용하는 메소드를 통해 날짜를 비교하고 싶은 경우 `Date.today` 대신 `Date.current`를 반드시 사용해주세요. 이후에 사용자가 정의한 시간대와 시스템의 시간대를 비교해야하는 상황이 있을 수도 있습니다. 시스템의 시간대에서는 `Date.today`가 사용됩니다. 다시 말해서 `Date.today`가 `Date.yesterday`와 같은 상황도 존재할 수 있습니다.

#### 이름이 있는 날짜

##### `prev_year`, `next_year`

Ruby 1.9의 `prev_year` 메소드와 `next_year` 메소드는 각각 작년과 올해를 동일한 일자와 월로 반환합니다.

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_year              # => Fri, 08 May 2009
d.next_year              # => Sun, 08 May 2011
```

윤년의 2월 29일인 경우, 작년과 올해의 날짜는 모두 2월 28일로 변경됩니다.

```ruby
d = Date.new(2000, 2, 29) # => Tue, 29 Feb 2000
d.prev_year               # => Sun, 28 Feb 1999
d.next_year               # => Wed, 28 Feb 2001
```

`prev_year`는 `last_year`의 별명입니다.

##### `prev_month`, `next_month`

Ruby 1.9의 `prev_month` 메소드와 `next_month` 메소드는 각각 전월과 다음 달의 같은 일자를 반환합니다.

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_month             # => Thu, 08 Apr 2010
d.next_month             # => Tue, 08 Jun 2010
```

같은 일자가 존재하지 않는 경우, 그 달의 마지막 날짜를 사용합니다.

```ruby
Date.new(2000, 5, 31).prev_month # => Sun, 30 Apr 2000
Date.new(2000, 3, 31).prev_month # => Tue, 29 Feb 2000
Date.new(2000, 5, 31).next_month # => Fri, 30 Jun 2000
Date.new(2000, 1, 31).next_month # => Tue, 29 Feb 2000
```

`prev_month`는 `last_month`의 별명입니다.

##### `prev_quarter`, `next_quarter`

`prev_month`와 `next_month`는 기본적으로 같은 방식으로 동작합니다. 전 분기, 또는 후 분기의 같은 일자를 반환합니다.

```ruby
t = Time.local(2010, 5, 8) # => Sat, 08 May 2010
t.prev_quarter             # => Mon, 08 Feb 2010
t.next_quarter             # => Sun, 08 Aug 2010
```

같은 일자가 존재하지 않는 경우, 그 경우에는 그 달의 마지막 일자를 돌려줍니다.

```ruby
Time.local(2000, 7, 31).prev_quarter  # => Sun, 30 Apr 2000
Time.local(2000, 5, 31).prev_quarter  # => Tue, 29 Feb 2000
Time.local(2000, 10, 31).prev_quarter # => Mon, 30 Oct 2000
Time.local(2000, 11, 31).next_quarter # => Wed, 28 Feb 2001
```

`prev_quarter`는 `last_quarter`의 별명입니다.

##### `beginning_of_week`, `end_of_week`

`beginning_of_week` 메소드와 `end_of_week` 메소드는 각각 해당 주간의 첫번째 날짜와 마지막 날짜를 반환합니다. 주의 시작은 기본적으로 월요일입니다만, 인수를 통해 변경할 수 있습니다. 그때에 스레드의 로컬에 `Date.beginning_of_week` 또는 `config.beginning_of_week`을 설정합니다.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week`는 `at_beginning_of_week`의 별명, `end_of_week`는 `at_end_of_week`의 별명입니다.

##### `monday`, `sunday`

`monday` 메소드와 `sunday` 메소드는 각각 직전의 월요일, 직후의 일요일을 반환합니다.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

##### `prev_week`, `next_week`

`next_week` 메소드는 영어표기(기본으로 스레드 로컬의 `Date.beginning_of_week` 또는 `config.beginning_of_week` 또는 `:monday`)의 날짜를 심볼로 받아서 거기에 대응하는 날짜를 돌려줍니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

`prev_week`도 마찬가지입니다.

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week`는 `last_week`의 별명입니다.

`Date.beginning_of_week` 또는 `config.beginning_of_week`가 설정되어 있다면, `next_week`와 `prev_week`는 어느쪽도 기대한대로 동작합니다.

##### `beginning_of_month`, `end_of_month`

`beginning_of_month` 메소드와 `end_of_month` 메소드는 각각 해당하는 달의 첫번째 날짜와 마지막 날짜를 반환합니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month`는 `at_beginning_of_month`의 별명, `end_of_month`는 `at_end_of_month`의 별명입니다.

##### `beginning_of_quarter`, `end_of_quarter`

`beginning_of_quarter` 메소드와 `end_of_quarter` 메소드는 리시버의 달력의 연도를 기준으로 각 분기의 첫번째 날, 마지막 날을 반환합니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter`는 `at_beginning_of_quarter`의 별명, `end_of_quarter`는 `at_end_of_quarter`의 별명입니다.

##### `beginning_of_year`, `end_of_year`

`beginning_of_year` 메소드와 `end_of_year` 메소드는 해당 년도의 첫번째 날과 마지막 날을 반환합니다.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year`는 `at_beginning_of_year`의 별명, `end_of_year`는 `at_end_of_year`의 별명입니다.

#### 그 이외의 날짜 계산 메소드

##### `years_ago`, `years_since`

`years_ago` 메소드는 년수를 받아 그 년만큼 이전의 같은 월, 일의 날짜를 반환합니다.

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

`years_since`도 마찬가지의 방법으로 그 만큼 이후의 동일한 날짜를 반환합니다.

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

같은 날짜가 존재하지 않는 경우에는 그 달의 마지막 날짜를 사용합니다.

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

##### `months_ago`, `months_since`

`months_ago` 메소드와 `months_since` 메소드는 위와 같은 방법을 달에 대해서 수행합니다.

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

같은 날이 존재하지 않는 경우에는 그 달의 마지막 날짜를 사용합니다.

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

##### `weeks_ago`

`weeks_ago` 메소드는 위와 같은 방법을 주간에 대해서 적용합니다.

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

##### `advance`

날짜를 계싼하는 가장 일반적인 방법은 `advance` 메소드를 사용하는 것입니다. 이 메소드는 `:years`, `:months`, `:weeks`, `:days`를 키로 가지는 해시를 받으며, 날짜를 가능한 상세한 형식으로, 현재의 키에서 요구하는대로 돌려줍니다.

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

예제에서 볼 수 있듯, 값으로는 음수도 사용할 수 있습니다.

계산의 순서는 우선 연도를 계산하고, 다음에 월, 마지막으로 일을 계산합니다. 이 순서로 계산한다는 점은 특히 월을 계산할 때에 중요합니다. 예를 들어 현재가 2010년 2월 마지막 날로, 거기에서 1개월과 1일 뒤로 가고 싶다고 합시다.

`advance` 메소드는 우선 한달을 더하고, 하루를 더합니다. 결과로 다음을 얻을 수 있습니다.

```ruby
Date.new(2010, 2, 28).advance(months: 1, days: 1)
# => Sun, 29 Mar 2010
```

계산의 순서가 다를 경우, 같은 결과를 얻을수 없을 수도 있습니다.

```ruby
Date.new(2010, 2, 28).advance(days: 1).advance(months: 1)
# => Thu, 01 Apr 2010
```

#### change

`change` 메소드는 주어진 년, 월, 일에 대해서 리시버의 날짜를 변경하고, 주어지지 않은 부분을 그대로 반환합니다.

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

존재하지 않는 날짜를 지정하면 `ArgumentError`를 발생시킵니다.

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

#### 기간

날짜에 대해서 기간을 계산할 수 있습니다.

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

이러한 계산은 내부에서 `since` 메소드나 `advance` 메소드를 통해서 처리됩니다. 예를 들어, 달력이 변경되는 때에도 올바르게 계산됩니다.

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

#### 타임스탬프

INFO: 다음 메소드들은 가능하다면 `Time` 객체를 반환하고, 그 이외의 경우에는 `DateTime`을 반환합니다. 시간대를 설정해 놓으면 이를 반영합니다.

##### `beginning_of_day`, `end_of_day`

`beginning_of_day` 메소드는 그 날의 시작 시점(00:00:00)의 타임스탬프를 반환합니다.

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

`end_of_day` 메소드는 그 날의 마지막 시각(23:59:59)의 타임스탬프를 반환합니다.

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day`는 `at_beginning_of_day`, `midnight`, `at_midnight`와 같습니다.

##### `beginning_of_hour`, `end_of_hour`

`beginning_of_hour` 메소드는 그 시각의 시작 지점(hh:00:00)의 타임스탬프를 돌려줍니다.

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

`end_of_hour` 메소드는 그 시각의 마지막 지점(hh:59:59)의 타임스탬프를 돌려줍니다.

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour`는 `at_beginning_of_hour`의 별명입니다.

##### `beginning_of_minute`, `end_of_minute`

`beginning_of_minute`는 해당 분의 시작 지점(hh:mm:00)의 타임스탬프를 돌려줍니다.

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

`end_of_minute`는 해당 분의 마지막 지점(hh:mm:59)의 타임스탬프를 돌려줍니다.

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute`는 `at_beginning_of_minute`의 별명입니다.

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute`, `end_of_minute`는 `Time` 또는 `DateTime`를 위한 구현입니다. `Date` 인스턴스에서는 시간이나 분, 초를 물어본다는 것이 의미가 없기 때문입니다.

##### `ago`, `since`

`ago` 메소드는 초를 인수로 받아, 0시를 기준으로 그 초만큼을 뺀 타임스탬프를 반환합니다.

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

`since` 메소드는 마찬가지로 초를 받아 그만큼을 더합니다.

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```

#### 그 이외의 시간 계산

### Conversions

`DateTime` 확장
------------------------

WARNING: `DateTime`는 섬머타임(DST)에 대해서 모릅니다. DST에 의한 시간대 변경이 이루어 졌을 경우, 메소드의 일부는 생각한대로 동작하지 않을 수 있습니다. 예를 들어 `seconds_since_midnight` 메소드가 반환하는 초수가 실제의 값과 다를 수 있습니다.

### 계산

NOTE: 이것들은 모두 `active_support/core_ext/date_time/calculations.rb`에 있습니다.

`DateTime` 클래스는 `Date`의 자식클래스이며 `active_support/core_ext/date/calculations.rb`를 읽는 것으로 이러한 메소드를 별도로 상속할 수 있습니다. 단 이들이 항상 datetime을 반환하게 된다는 점을 주의하세요.

```ruby
yesterday
tomorrow
beginning_of_week (at_beginning_of_week)
end_of_week (at_end_of_week)
monday
sunday
weeks_ago
prev_week (last_week)
next_week
months_ago
months_since
beginning_of_month (at_beginning_of_month)
end_of_month (at_end_of_month)
prev_month (last_month)
next_month
beginning_of_quarter (at_beginning_of_quarter)
end_of_quarter (at_end_of_quarter)
beginning_of_year (at_beginning_of_year)
end_of_year (at_end_of_year)
years_ago
years_since
prev_year (last_year)
next_year
```

이하의 메소드는 모두 재정의되기 때문에 이들을 사용하기 위해서 `active_support/core_ext/date/calculations.rb`를 불러올 필요는 **없습니다**.

```ruby
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
ago
since (in)
```

반면 `advance`와 `change`도 정의됩니다만, 좀 더 많은 옵션을 사용할 수 있게 됩니다. 이에 대해서는 나중에 다시 설명하겠습니다.

다음 메소드는 `active_support/core_ext/date_time/calculations.rb`에서만 구현되어 있습니다. 이들은 `DateTime` 인스턴스가 아니면 의미가 없기 때문입니다.

```ruby
beginning_of_hour (at_beginning_of_hour)
end_of_hour
```

#### 이름을 가지는 Datetime

##### `DateTime.current`

Active Support에서는 `DateTime.current`를 `Time.now.to_datetime`과 같은 방식으로 정의하고 있습니다. 단 `DateTime.current`는 사용자의 시간대가 정의되어 있을 경우를 처리해준다는 점이 다릅니다. Active Support에서는 `Date.yesterday`와 `Date.tomorrow`도 정의되어 있습니다. 인스턴스에서는 `past?`와 `future?`도 사용할 수 있습니다.

#### 그 이외의 확장

##### `seconds_since_midnight`

`seconds_since_midnight` 메소드는 자정을 기준으로 몇초가 경과했는지를 알려줍니다.

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

##### `utc`

`utc` 메소드는 리시버의 날짜를 UTC로 변환합니다.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

`getutc`는 이 메소드의 별명입니다.

##### `utc?`

`utc?`는 리시버가 UTC시간을 가지고 있는지를 확인합니다.

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?          # => false
now.utc.utc?      # => true
```

##### `advance`

날자를 바꾸는 가장 일반적인 방법은 `advance` 메소드를 사용하는 것입니다. 이 메소드는 `:years`,`:months`, `:weeks`, `:days`, `:hours`, `:minutes` 그리고 `:seconds`를 키로 가지는 해시를 받아서 날짜를 가능한 자세한 형태로 옵션이 지정하는대로 변환하여 반환합니다.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

이 메소드는 우선 위에서 설명되어 있는 `Date#advance`에 대응하는 년수(`:years`), 달수(`:months`), 주수(`:weeks`), 일수(`days`)로 변경할 날짜를 계산합니다. 이어서 그 날짜에 `since` 메소드를 사용해서 변경된 초를 보정합니다. 이 실행 순서에는 의미가 있습니다. 극단적인 상황으로 순서가 달라지면 계산 결과가 달라지는 경우가 있기 때문입니다. 이것은 위에서의 `Date#advance`에서 보여준 예제와 동일합니다. 상대적인 시간 계산에서도 계산 순서는 중요합니다.

만약 일자 부분을 먼저 계산하고 이어서 시간 부분을 계산하게 되면 아래와 같은 계산 결과를 얻을 수 있습니다.

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

계산 순서를 바꾸어보면, 결과가 달라집니다.

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

WARNING: `DateTime`는 섬머 타임(DST)을 고려하지 않습니다. 계산된 시간이 최종적으로 존재하지 않는 시간이 되더라도 경고나 에러는 발생하지 않습니다.

#### 요소 변경하기

`change` 메소드를 사용해서 리시버의 날짜/시각의 일부를 변경하여 새로운 날짜를 만들 수 있습니다. 변경 가능한 요소는 `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start` 등으로 지정할 수 있습니다.

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```

시각(hour)이 0인 경우 분과 초가 지정되어 있지 않으면 함께 0이 됩니다.

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

마찬가지로 분이 0인 경우, 초가 지정되지 않으면 함께 0이 됩니다.

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

존재하지 않는 날짜를 지정하면 `ArgumentError`가 발생합니다.

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

#### 기간

날짜에 대해 기간을 계산할 수 있습니다.

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

이러한 계산은 내부적으로 `since` 메소드나 `advance` 메소드를 사용합니다. 그러므로 달력이 변경되는 시점에서도 올바르게 계산 됩니다.

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

`Time` 확장
--------------------

### 계산

NOTE: 이들은 모두 `active_support/core_ext/time/calculations.rb`에 정의되어 있습니다.

Active Support는 `DateTime`에서 사용할 수 있는 메소드의 다수를 `Time`에 추가합니다.

```ruby
past?
today?
future?
yesterday
tomorrow
seconds_since_midnight
change
advance
ago
since (in)
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
beginning_of_hour (at_beginning_of_hour)
end_of_hour
beginning_of_week (at_beginning_of_week)
end_of_week (at_end_of_week)
monday
sunday
weeks_ago
prev_week (last_week)
next_week
months_ago
months_since
beginning_of_month (at_beginning_of_month)
end_of_month (at_end_of_month)
prev_month (last_month)
next_month
beginning_of_quarter (at_beginning_of_quarter)
end_of_quarter (at_end_of_quarter)
beginning_of_year (at_beginning_of_year)
end_of_year (at_end_of_year)
years_ago
years_since
prev_year (last_year)
next_year
```

이들은 동일하게 동작하며, 관련된 문서를 참조하시고, 다음과 같은 차이점에 대해서도 기억해주세요.

* `change` 메소드에 추가로 `:usec` 옵션을 사용할 수 있습니다.
* `Time`은 섬머타임(DST)을 이해합니다. 아래와 같은 DST처리도 올바르게 됩니다.

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# 바르셀로나에서는 DST에 의해서 2010/03/28 02:00 +0100이 2010/03/28 03:00 +0200가 됨
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* `since`나 `ago`로 계산 결과의 시간을 `Time`으로 표현할 수 없는 경우 `DateTime` 객체가 반환됩니다.

#### `Time.current`

Active Support 에서는 `Time.current`를 정의해서 현재의 시간대에 맞는 '오늘'을 반환합니다. 이 메소드는 `Time.now`와도 비슷합니다만, 사용자의 시간대를 고려한다는 점이 다릅니다. Active Support에서는 `past?`, `today?`, `future?`라는 메소드가 정의되어 있으며, 이것들은 내부적으로 `Time.current`를 사용합니다.

사용자의 시간대를 고려하는 메소드를 사용해서 날짜를 비교하고 싶은 경우 `Time.now`가 아닌 `Time.current`를 반드시 사용해주세요. 이후 사용자 시간대와 시스템의 시간대를 비교해야 하는 경우가 존재할 수 있습니다. 시스템의 타임존에서는 기본으로 `Time#now`이 사용됩니다. 다시 말해, `Time.now`이 `Time.currentyesterday`와 같은 상황이 있을 수 있습니다.

#### `all_day`, `all_week`, `all_month`, `all_quarter`, `all_year`

`all_day` 메소드는 현재 시각을 포함하는 하루를 Range 객체로 돌려줍니다.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

마찬가지로 `all_week`, `all_month`, `all_quarter`, `all_year`도 기간의 Range 객체를 생성합니다.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

### Time 생성자

사용자의 시간대가 정의되어 있는 경우, Active Support가 정의하는 `Time.current`의 값은 `Time.zone.now`와 동일합니다. 시간대가 정의되어 있지 않은 경우에는 `Time.now`와 같습니다.

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

`DateTime`와 마찬가지로 `past?`와 `future?`는 `Time.current`를 사용합니다.

구성된 시간이 실행 플랫폼의 `Time`에서 지원되는 범위를 넘어서는 경우에는 usec이 파기되고 `DateTime` 객체가 대신 반환됩니다.

#### 기간

Time 객체에 대해서 기간으로 계산할 수 있습니다.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
#  => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

이런 계산은 내부에서 `since` 메소드나 `advance` 메소드로 구현됩니다. 그러므로 달력 변경 시점에서도 올바르게 처리됩니다.

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File` 확장
--------------------

### `atomic_write`

`File.atomic_write` 클래스 메소드를 사용하면, 작성중인 내용을 동시에 읽지 못하게 하며 파일에 저장할 수 있습니다.

이 메소드에 파일명을 인수로 넘기면, 쓰기용으로 생성된 파일 핸들이 생성됩니다. 블럭의 작업이 완료되면 `atomic_write`는 파일 핸들을 닫고 처리를 완료합니다.

Action Pack은 이 메소드를 사용해서 `all.css`등의 캐시파일 등을 처리합니다. 

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

`atomic_write`는 코드를 실행하며 임시 파일을 생성합니다. 블럭 내의 코드가 실제로 쓰기를 수행하는 것은 이 파일입니다. 처리가 완려되면 이 임시 파일의 이름이 변경됩니다. 이름 변경은 POSIX 시스템의 아토믹 조작에 의해서 이루어집니다. 쓰기 파일이 이미 존재하는 경우 `atomic_write`는 그것을 덮어쓰고 소유자와 권한을 유지합니다. 단 `atomic_write` 메소드가 파일의 소유권과 권한을 변경할 수 없는 경우가 드물게 있습니다. 이런 에러는 무시되고 사용자의 파일 시스템을 신뢰하는 것으로 그 파일이 그것을 필요로 하는 프로세스로부터 접근할 수 있도록 합니다.

NOTE: `atomic_write`가 실행하는 chmod 조작이 원인으로, 쓰기 대상 파일이 ACL 셋을 가지고 있을 경우에 그 ACL이 재계산/변경됩니다.
WARNING: `atomic_write`는 내용을 추가(append)할 수 없습니다.

임시 파일은 시스템 표준의 임시 파일용 폴더에 생성됩니다만, 두번째의 인수로 생성될 폴더를 지정할 수도 있습니다.

NOTE: `active_support/core_ext/file/atomic.rb`에 정의되어 있습니다.

`Marshal` 확장
-----------------------

### `load`

Active Support는 `load`에 자동 읽기 기능을 추가합니다.

예를 들어 파일 캐시 저장소에서는 아래와 같은 역직렬화(deserialize)를 합니다.

```ruby
File.open(file_name) { |f| Marshal.load(f) }
```

캐시 데이터가 알수 없는 상수를 참조하고 있는 경우, 자동 읽기 기능이 호출됩니다. 읽기가 성공한 경우에는 역직렬화를 명백하게 재실행합니다.

WARNING: 인수가 `IO`인 경우 재실행을 위해서 `rewind`에 응답해야할 필요가 있습니다. 일반적인 파일은 `rewind`을 호출할 수 있습니다.

NOTE: `active_support/core_ext/marshal.rb`에 정의되어 있습니다.

`NameError` 확장
-------------------------

Active Support는 `NameError`에 `missing_name?` 메소드를 추가합니다. 이 메소드는 인수로 넘긴 이름 때문에 예외가 발생하는지를 테스트합니다.

넘긴 이름은 심볼 또는 문자열일 것입니다. 심볼을 넘긴 경우에는 단순히 상수명을 테스트하고, 문자열을 넘긴 경우에는 경로를 포함한 이름을 테스트합니다.

TIP: 심볼은 `:"ActiveRecord::Base"`에서처럼 절대경로를 포하만 상수명으로 나타낼 수 있습니다. 심볼이 그렇게 동작하는 이유는 기술적인 이유가 아니라, 편의를 위해서 입니다.

예를 들어, `ArticlesController`의 액션이 호출되면 Rails는 그 이름으로부터 바로 추측할 수 있는 `ArticleHelper`를 사용하려고 합니다. 여기에서는 그 헬퍼 모듈이 존재하지 않아도 문제가 없기 때문에 그 상수명으로 예외가 발생하더라도 무시되어야 합니다. 하지만 실제로는 존재하지 않는 상수명 때문에 `articles_helper.rb`이 `NameError`를 발생시킬 수 있습니다. 그러한 경우에는 다시 예외를 던지지 않으면 안됩니다. `missing_name?` 메소드는 이러한 경우를 구분하기 위해서 사용됩니다.

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: `active_support/core_ext/name_error.rb`에 정의되어 있습니다.

`LoadError` 확장
-------------------------

Active Support는 `is_missing?`을 `LoadError`에 추가합니다.

`is_missing?`은 경로명을 인수로 받아서, 특정 파일이 없어서 에러가 발생하는지를 테스트합니다(".rb" 확장자가 원인으로 보여지는 경우를 제외합니다).

예를 들어 `ArticlesController`의 액션이 호출되면 Rails는 `articles_helper.rb`를 읽으려고 시도합니다만, 이 파일이 존재하지 않는 경우가 있습니다. 헬퍼 모듈은 필수가 아니므로 Rails는 읽기 에러를 예외로 처리하지 않고 무시합니다. 그러나 헬퍼 모듈이 존재하지 않기 때문에 다른 라이브러리가 필요한 경우가 있는데, 그 라이브러리를 찾을 수 없는 경우도 존재합니다. Rails는 그런 경우에는 예외를 던지지 않을 수 없습니다. `is_missing?`은 이 두가지 경우를 구분하기 위해서 사용됩니다.

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: `active_support/core_ext/load_error.rb`에 정의되어 있습니다.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
