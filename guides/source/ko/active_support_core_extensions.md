[Active Support Core Extensions] 액티브서포트 코어확장
==============================

액티브서포트는 루비온레일스의 구성요소로서 루비언어에 대한 확장, 유틸리티 그리고 기타 다양한 것들을 제공해 줍니다. [[[Active Support is the Ruby on Rails component responsible for providing Ruby language extensions, utilities, and other transversal stuff.]]]

또한, 레일스 어플리케이션을 개발할 경우와 루비온레일스 프레임워크 자체를 개발하는 경우를 대상으로 루비언어 수준에서 핵심적인 것들을 보다 풍부하게 제공해 줍니다. [[[It offers a richer bottom-line at the language level, targeted both at the development of Rails applications, and at the development of Ruby on Rails itself.]]]

본 가이드를 읽고나면 아래 사항을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* 코어확장이 무엇이지 [[[What Core Extensions are.]]]

* 모든 확장을 로드하는 방법 [[[How to load all extensions.]]]

* 원하는 확장만을 선별하는 방법 [[[How to cherry-pick just the extensions you want.]]]

* 액티브서포트가 제공하는 확장기능들 [[[What extensions Active Support provides.]]]

--------------------------------------------------------------------------------

[How to Load Core Extensions] 코어확장 로드하는 방법
---------------------------

### [Stand-Alone Active Support] 액티브서포트를 단독으로 사용하기

액티브서포트는 아무런 기능확장을 하지 않도록, 디폴트 상태에서는 아무것도 로드하지 않습니다. 여러 개의 모듈로 분리되어 있어서 필요한 것만 로드할 수 있도록 되어 있습니다. 또한 한번에 관련 확장모듈만을, 심지어 모든 것을 로드할 수 있도록 진입점을 제공해 주어 편리하게 구성되어 있습니다. [[[In order to have a near-zero default footprint, Active Support does not load anything by default. It is broken in small pieces so that you can load just what you need, and also has some convenience entry points to load related extensions in one shot, even everything.]]]

따라서, 아래와 같이 간단하게 require할 경우, [[[Thus, after a simple require like:]]]

```ruby
require 'active_support'
```

객체들은 `blank` 메소드에 대해서 반응을 하지 않게 됩니다. 이제 해당 정의를 로드하는 방법을 알아보겠습니다. [[[objects do not even respond to `blank?`. Let's see how to load its definition.]]]

#### [Cherry-picking a Definition] 특정 정의만 선별하기

`blank`를 사용하기 위한 가장 손쉬운 방법은 이에 대한 정의를 포함하는 파일만을 선별하는 것입니다. [[[The most lightweight way to get `blank?` is to cherry-pick the file that defines it.]]]

본 가이드에는 코어확장으로 정의된 모든 메소드 각각에 대해서 해당 메소드가 어디에 정의되어 있는지를 노트로 표시해 줍니다. `blank?` 메소드의 경우, 해당 노트는 아래와 같습니다. [[[For every single method defined as a core extension this guide has a note that says where such a method is defined. In the case of `blank?` the note reads:]]]

NOTE: 이 메소드는 `active_support/core_ext/object/blank.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/blank.rb`.]]]

이것은 한번만 호출하면 된다는 것을 의미합니다. [[[That means that this single call is enough:]]]

```ruby
require 'active_support/core_ext/object/blank'
```

액티브서포트는 세심하게 수정되어서 하나의 파일만을 선별할 경우 해당 의존성 파일들(존재할 경우)만을 로드하게 됩니다. [[[Active Support has been carefully revised so that cherry-picking a file loads only strictly needed dependencies, if any.]]]

#### [Loading Grouped Core Extensions] 코어확장을 그룹으로 로딩하기

다음 단계는 `Object`내의 모든 기능확장을 간단하게 로드하는 것입니다. 대개는, `SomeClass`내의 기능을 확장하기 위해서는 `active_support/core_ext/some_class`를 로딩하므로써 단번에 사용할 수 있게 됩니다. [[[The next level is to simply load all extensions to `Object`. As a rule of thumb, extensions to `SomeClass` are available in one shot by loading `active_support/core_ext/some_class`.]]]

따라서, (`blank?` 메소드를 포함하는) `Object`내의 모든 기능을 확장하기 위해서는 아래와 같이 하면 됩니다. [[[Thus, to load all extensions to `Object` (including `blank?`):]]]

```ruby
require 'active_support/core_ext/object'
```

#### [Loading All Core Extensions] 모든 코어확장 로드하기

모든 코어확장을 로드하고자 할 경우에는 아래와 같이 하나의 파일을 불러 들이면 됩니다. [[[You may prefer just to load all core extensions, there is a file for that:]]]

```ruby
require 'active_support/core_ext'
```

#### [Loading All Active Support] 모든 액티브서포트를 로드하기

그리고 마지막으로, 사용가능한 모든 액티브서포트를 불러들일 경우에는 아래와 같이 하면 됩니다. [[[And finally, if you want to have all Active Support available just issue:]]]

```ruby
require 'active_support/all'
```

이렇게 할 경우에도, 모든 액티브서포트를 메모리상에 로드하지 않는데, 일부 모듈은 `autoload`상태로 설정되기 때문에, 필요할 경우에만 로드됩니다. [[[That does not even put the entire Active Support in memory upfront indeed, some stuff is configured via `autoload`, so it is only loaded if used.]]]

### [Active Support Within a Ruby on Rails Application] 루비온레일스 어플리케이션 내에서 액티브서포트 사용하기

루비온레일스 어플리케이션은 `config.active_support.bare`이 true로 설정되어 있지 않는 한, 모든 액티브서포트를 로드하게 됩니다. 이와 같이 true로 지정된 경우에는, 레일스 프레임워크가 필요로하는 것만을 선별해서 로드하게 되고, 이전에 설명한 바와 같이, 각 단계별로 선별해서 사용할 수도 있습니다. [[[A Ruby on Rails application loads all Active Support unless `config.active_support.bare` is true. In that case, the application will only load what the framework itself cherry-picks for its own needs, and can still cherry-pick itself at any granularity level, as explained in the previous section.]]]

[Extensions to All Objects] 객체에 대한 확장 메소드
-------------------------

### [`blank?` and `present?`] `blank?` 와 `present?`

레일스 어플리케이션에서 다음과 같은 값들은 blank로 인식됩니다. [[[The following values are considered to be blank in a Rails application:]]]

* `nil` 과 `false`, [[[`nil` and `false`,]]]

* whitespace 만으로 구성된 문자열 (아래의 노트를 참고하세요.), [[[strings composed only of whitespace (see note below),]]]

* 빈 배열과 해시 [[[empty arrays and hashes, and]]]

* `empty?` 메소드가 정의되어 있어서 empty를 반환하는 기타 다른 객체들 [[[any other object that responds to `empty?` and is empty.]]]

INFO: 문자열에 대한 서술부분은 유니코드를 인식하는 캐릭터 클래스 `[:space:]` 를 사용합니다. 그래서, 예를 들면, 문단구분자인 U+2029는 whitespace로 인식되는 것입니다. [[[The predicate for strings uses the Unicode-aware character class `[:space:]`, so for example U+2029 (paragraph separator) is considered to be whitespace.]]]

WARNING: 주목할 것은 숫자에 대해서 언급하지 않았습니다. 특히, 0과 0.0은 blank가 **아닙니다**. [[[Note that numbers are not mentioned. In particular, 0 and 0.0 are **not** blank.]]]

예를 들어, `ActionDispatch::Session::AbstractStore`에 있는 아래의 메소드는 세션키의 존재여부를 확인하기 위해 `blank?`를 사용합니다. [[[For example, this method from `ActionDispatch::Session::AbstractStore` uses `blank?` for checking whether a session key is present:]]]

```ruby
def ensure_session_key!
  if @key.blank?
    raise ArgumentError, 'A key is required...'
  end
end
```

`present?` 메소드는 `!blank?`와 동일한 것입니다. 아래의 예는 `ActionDispatch::Http::Cache::Response`로부터 발췌한 것입니다. [[[The method `present?` is equivalent to `!blank?`. This example is taken from `ActionDispatch::Http::Cache::Response`:]]]

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  ...
end
```

NOTE: 이 메소드는 `active_support/core_ext/object/blank.rb`에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/blank.rb`.]]]

### `presence`

`presence` 메소드는 `present?` 결과 true 값을 반환할 경우 receiver 객체를, false 값을 반환할 경우 `nil` 객체를 반환하게 됩니다. 이것은 아래와 같은 경우 유용하게 습관적으로 사용할 수 있습니다. [[[The `presence` method returns its receiver if `present?`, and `nil` otherwise. It is useful for idioms like this:]]]

```ruby
host = config[:host].presence || 'localhost'
```

NOTE: 이 메소드는 `active_support/core_ext/object/blank.rb`에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/blank.rb`.]]]

### `duplicable?`

루비에서 몇가지 기본 객체들은 싱글레톤의 형태를 가집니다. 예를 들어, 하나의 프로그램 프로세스 동안에, 정수 1 은 항상 동일한 인스턴스를 참조합니다. [[[A few fundamental objects in Ruby are singletons. For example, in the whole life of a program the integer 1 refers always to the same instance:]]]

```ruby
1.object_id                 # => 3
Math.cos(0).to_i.object_id  # => 3
```

따라서, 이러한 객체들은 `dup`이나 `clone` 메소드를 이용하여 복제할 수 있는 방법이 없습니다. [[[Hence, there's no way these objects can be duplicated through `dup` or `clone`:]]]

```ruby
true.dup  # => TypeError: can't dup TrueClass
```

싱글레톤 형태를 취하지 않는 몇몇 숫자들도 복제할 수 없는데, 다음과 같습니다. [[[Some numbers which are not singletons are not duplicable either:]]]

```ruby
0.0.clone        # => allocator undefined for Float
(2**1024).clone  # => allocator undefined for Bignum
```

액티브서포트는 이와 같이 특정 객체가 복제가능한 가를 프로그램상에서 조회해 볼 수 있도록 `duplicable?`이라는 메소드를 제공해 줍니다. [[[Active Support provides `duplicable?` to programmatically query an object about this property:]]]

```ruby
"foo".duplicable? # => true
"".duplicable?     # => true
0.0.duplicable?   # => false
false.duplicable?  # => false
```

정의상, `nil`, `false`, `true`, 심볼, 숫자, 클래스, 모듈 객체들을 제외한 모든 객체는 `duplicable?` 메소드에 대해 true 값을 반환합니다. [[[By definition all objects are `duplicable?` except `nil`, `false`, `true`, symbols, numbers, class, and module objects.]]]

WARNING: 모든 클래스는 `dup`과 `clone` 메소드를 제거하거나 메소드 내에 예외를 발생시켜서 복제를 못하게 할 수 있습니다. 이렇게 하면 `rescue` 만이 유일하게 특정 객체가 복제가능한지를 알려 줄 수 있게 됩니다. `duplicable?` 메소드는 위에서와 같이 코딩에 따라 좌우되지만, `rescue` 보다는 훨씬 빠르게 결과를 알려 줍니다. 따라서 특정 상황에서 하드코딩된 목록으로도 충분한 경우에만 사용하기 바랍니다. [[[Any class can disallow duplication by removing `dup` and `clone` or raising exceptions from them. Thus only `rescue` can tell whether a given arbitrary object is duplicable. `duplicable?` depends on the hard-coded list above, but it is much faster than `rescue`. Use it only if you know the hard-coded list is enough in your use case.]]]

NOTE: 이 메소드는 `active_support/core_ext/object/duplicable.rb`에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/duplicable.rb`.]]]

### `deep_dup`

`deep_dup` 메소드는 특정 객체를 deep 복사해서 반환해 줍니다. 보통은, 다른 객체를 포함하는 특정 객체를 `dup` 할 때, 루비는 포함된 객체는 `dup` 하지 않게 됩니다. 따라서, 해당 객체를 shallow 복사를 하게 됩니다. 특정 문자열을 가지는 특정 배열을 예를 들면, 다음과 같습니다. [[[The `deep_dup` method returns deep copy of a given object. Normally, when you `dup` an object that contains other objects, ruby does not `dup` them, so it creates a shallow copy of the object. If you have an array with a string, for example, it will look like this:]]]

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# the object was duplicated, so the element was added only to the duplicate
array     #=> ['string']
duplicate #=> ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# first element was not duplicated, it will be changed in both arrays
array     #=> ['foo']
duplicate #=> ['foo', 'another-string']
```

알 수 있듯이, `Array` 인스턴스를 복제하면, 또 다른 배열 객체를 가지게 됩니다. 그러므로 복제한 배열 객체를 변경하면 원래의 배열 객체는 변경되지 않은 채로 있게 될 것입니다. 그러나, 배열 요소에 대해서는 이러한 사항이 해당되지 않습니다. `dup` 메소드는 deep 복사를 하지 않기 때문에, 배열내의 문자열은 여전히 동일한 객체가 되는 것입니다. [[[As you can see, after duplicating the `Array` instance, we got another object, therefore we can modify it and the original object will stay unchanged. This is not true for array's elements, however. Since `dup` does not make deep copy, the string inside the array is still the same object.]]]

특정 객체에 대해서 deep 복사를 해야할 경우에는, `deep_dup` 메소드를 사용해야 합니다. 다음에 그 예가 있습니다. [[[If you need a deep copy of an object, you should use `deep_dup`. Here is an example:]]]

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     #=> ['string']
duplicate #=> ['foo']
```

특정 객체가 복제가능하지 않을 경우에, `deep_dup` 메소드는 단지 해당 객체만을 반환해 줄 것입니다. [[[If the object is not duplicable, `deep_dup` will just return it:]]]

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTE: 이 메소드는 `active_support/core_ext/object/deep_dup.rb` 파일에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/deep_dup.rb`.]]]

### `try`

특정 객체에 대해서 `nil`이 아닐 경우에만 메소드를 호출하고자 할 때, 가장 손쉬운 방법은 좀 너저분하게 생각되지만 조건절을 사용하는 것입니다. 다른 대안으로는 `try` 메소드를 사용하는 것입니다. `try`는 `nil` 값을 보내면 `nil`을 반환하는 것만 제외하고는 `Object#send`와 동일하게 동작합니다. [[[When you want to call a method on an object only if it is not `nil`, the simplest way to achieve it is with conditional statements, adding unnecessary clutter. The alternative is to use `try`. `try` is like `Object#send` except that it returns `nil` if sent to `nil`.]]]

아래에 이에 대한 예가 있습니다. [[[Here is an example:]]]

```ruby
# without try
unless @number.nil?
  @number.next
end

# with try
@number.try(:next)
```

`ActiveRecord::ConnectionAdapters::AbstractAdapter`에서 다른 예를 볼 수 있는데, `@logger`가 `nil` 값을 가질 수 있습니다. 그래서 `try` 메소드를 이용해서 불필요한 체크를 하지 않도록 한 것을 알 수 있습니다. [[[Another example is this code from `ActiveRecord::ConnectionAdapters::AbstractAdapter` where `@logger` could be `nil`. You can see that the code uses `try` and avoids an unnecessary check.]]]

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` 메소드는 인수 대신에 코드블록을 사용하여 호출할 수 있는데, 이 코드블록은 receiver 객체가 `nil`이 아닐 경우에만 실행될 것입니다. [[[`try` can also be called without arguments but a block, which will only be executed if the object is not nil:]]]

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

NOTE: 이 메소드는 `active_support/core_ext/object/try.rb` 파일에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/try.rb`.]]]

### `class_eval(*args, &block)`

`class_eval` 메소드를 이용하면, 모든 객체의 싱글레톤 클래스 내에서 코드가 실행되도록 할 수 있습니다. [[[You can evaluate code in the context of any object's singleton class using `class_eval`:]]]

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

NOTE: 이 메소드는 `active_support/core_ext/kernel/singleton_class.rb` 파일 내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/kernel/singleton_class.rb`.]]]

### `acts_like?(duck)`

`acts_like?` 메소드는, `String` 클래스가 정의하는 것과 동일한 인터페이스를 제공하는 임의의 클래스, 즉, 이와 같이 간단한 규칙에 근거하여, 어떤 클래스가 다른 어떤 클래스처럼 동작하는지를 체크하는 방법을 제공해 줍니다. [[[The method `acts_like?` provides a way to check whether some class acts like some other class based on a simple convention: a class that provides the same interface as `String` defines]]]

```ruby
def acts_like_string?
end
```

위의 코드는 단지 하나의 표식자에 불과하며, 메소드 내의 코드나 반환값은 별개의 문제입니다. 그러면 아래와 같이 duct-type-safeness를 조회해 볼 수 있게 됩니다. [[[which is only a marker, its body or return value are irrelevant. Then, client code can query for duck-type-safeness this way:]]]

```ruby
some_klass.acts_like?(:string)
```

레일스는 `Date` 또는 `Time`처럼 동작하며 이와 같은 규칙을 따르는 클래스들을 제공해 줍니다. [[[Rails has classes that act like `Date` or `Time` and follow this contract.]]]

NOTE: 이 메소드는 `active_support/core_ext/object/acts_like.rb` 파일 내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/acts_like.rb`.]]]

### `to_param`

레일스에서 모든 객체는 `to_param` 메소드에 반응하게 되며, 해당 객체를 쿼리문자열이나 URL 일부 값을 결과값으로 반환해 줍니다. [[[All objects in Rails respond to the method `to_param`, which is meant to return something that represents them as values in a query string, or as URL fragments.]]]

디폴트로 `to_param` 메소드는 단지 `to_s` 메소드를 호출하기만 합니다. [[[By default `to_param` just calls `to_s`:]]]

```ruby
7.to_param # => "7"
```

`to_param` 메소드의 반환값은 이스케이핑되지 **안는다는 것입니다**. (역자주: 이스케이프 문자가 포함될 경우에도 그데로 문자로 반환된다는 의미로 해석) [[[The return value of `to_param` should **not** be escaped:]]]

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

레일스의 몇가지 클래스는 이 메소드를 재정의하여 사용합니다. [[[Several classes in Rails overwrite this method.]]]

예를 들어, `nil`, `true`, `false`는 자기자신을 반환합니다. `Array#to_param` 메소드는 배열 각요소에 대해서 `to_param` 메소드를 호출하여 결과를 `/`문자로 연결해서 반환해 줍니다. [[[For example `nil`, `true`, and `false` return themselves. `Array#to_param` calls `to_param` on the elements and joins the result with "/":]]]

```ruby
[0, true, String].to_param # => "0/true/String"
```

주목할 것은, 레일스 라우팅 시스템은 모델에 대해서 `to_param` 메소드를 호출하여 `:id` 값을 얻어냅니다. `ActiveRecord::Base#to_param`은 특정 모델의 `id` 값을 반환해주지만, 예를 들어, 아래와 같이, 모델 클래스에서 이 메소드를 재정의할 수도 있습니다. [[[Notably, the Rails routing system calls `to_param` on models to get a value for the `:id` placeholder. `ActiveRecord::Base#to_param` returns the `id` of a model, but you can redefine that method in your models. For example, given]]]

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

이와 같이 재정의하면 아래와 같은 결과를 얻을 수 있습니다. [[[we get:]]]

```ruby
user_path(@user) # => "/users/357-john-smith"
```

WARNING. 이와 같이 요청이 들어올 경우, `params[:id]`의 값이 "357-john-smith"가 되기 때문에 컨트롤러는 `to_param`이 재정의된 것을 알 필요가 있습니다. [[[Controllers need to be aware of any redefinition of `to_param` because when a request like that comes in "357-john-smith" is the value of `params[:id]`.]]]

NOTE: 이 메소드는 `active_support/core_ext/object/to_param.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/to_param.rb`.]]]

### `to_query`

해시를 제외하고, 이스케이프되지 않은 `key`가 주어진 상태에서 이 메소드는 해당 키를 `to_param`이 반환하는 값으로 매핑시켜 주는 쿼리문자열 일부를 생성해 줍니다. 예를 들어 아래와 같이 `to_param`이 재정의된 경우에, [[[Except for hashes, given an unescaped `key` this method constructs the part of a query string that would map such key to what `to_param` returns. For example, given]]]

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

아래와 같은 결과를 얻게 될 것입니다. [[[we get:]]]

```ruby
current_user.to_query('user') # => user=357-john-smith
```

이 메소드는 키와 값을 모두 이스케이프시키게 됩니다. [[[This method escapes whatever is needed, both for the key and the value:]]]

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

따라서 위와 같은 결과물은 쿼리문자열로 사용할 수 있는 상태가 되는 것입니다. [[[so its output is ready to be used in a query string.]]]

배열은 각요소에 대해서 `_key_[]`형태의 키로써 `to_query` 메소드를 적용하고 각각의 결과를 "&" 문자로 연결해서 결과물로 반환하게 됩니다.  [[[Arrays return the result of applying `to_query` to each element with `_key_[]` as key, and join the result with "&":]]]

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

해시도 `to_query` 메소드에 반응하지만, 다른 특징을 가지고 있습니다. 인수없이 호출하게 되면 일련의 키/값 할당문을 생성하고 각 값에 대해서 `to_query(key)`를 호출하게 됩니다. 그리고 그 결과들을 "&" 문자로 연결하여 반환합니다. [[[Hashes also respond to `to_query` but with a different signature. If no argument is passed a call generates a sorted series of key/value assignments calling `to_query(key)` on its values. Then it joins the result with "&":]]]

```ruby
{c: 3, b: 2, a: 1}.to_query # => "a=1&b=2&c=3"
```

`Hash#to_query` 메소드는 키에 대한 네임스페이스를 옵션으로 지정할 수 있습니다. [[[The method `Hash#to_query` accepts an optional namespace for the keys:]]]

```ruby
{id: 89, name: "John Smith"}.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTE: 이 메소드는 `active_support/core_ext/object/to_query.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/to_query.rb`.]]]

### `with_options`

`with_options` 메소드는 일련의 메소드 호출시 공통되는 옵션을 별도로 빼는 방법을 제공해 줍니다. [[[The method `with_options` provides a way to factor out common options in a series of method calls.]]]

디폴트 옵션 해시를 넘겨 주면, `with_options` 메소드는 코드블록으로 대리 객체를 넘겨주게 됩니다. 그러면 블록내에서 대리객체에 대해서 호출된 메소드는 넘겨 받은 옵션들을 머지해서 receiver 객체로 전달됩니다. 예를 들면, 아래의 코드에서 중복된 옵션을 제거할 수 있습니다. [[[Given a default options hash, `with_options` yields a proxy object to a block. Within the block, methods called on the proxy are forwarded to the receiver with their options merged. For example, you get rid of the duplication in:]]]

```ruby
class Account < ActiveRecord::Base
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

이 메소드를 이용하면 아래와 같이 코딩할 수 있습니다. [[[this way:]]]

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

이와 같은 관용적인 용법은 독자들을 그룹화할 수 있게도 합니다. 예를 들면, 독자들이 등록해 놓은 언어에 맞는 뉴스레터를 발송하고자 할 때 아래와 같이 메일러 내에 로케일별로 그룹화할 수 있을 것입니다. [[[That idiom may convey _grouping_ to the reader as well. For example, say you want to send a newsletter whose language depends on the user. Somewhere in the mailer you could group locale-dependent bits like this:]]]

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP: `with_options` 메소드는 호출을 자신의 recevier 객체로 전달하기 때문에 얼마든지 중첩해서 호출할 수 있습니다. 각각의 중첩레벌은 자신 뿐만아니라 상속된 디폴트 설정을 머지하게 될 것입니다. [[[Since `with_options` forwards calls to its receiver they can be nested. Each nesting level will merge inherited defaults in addition to their own.]]]

NOTE: 이 메소드는 `active_support/core_ext/object/with_options.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/with_options.rb`.]]]

### Instance Variables

액티브서포트는 인스턴스 변수를 쉽게 접근할 수 있는 다양한 메소드를 제공해 줍니다. [[[Active Support provides several methods to ease access to instance variables.]]]

#### `instance_values`

`instance_values` 메소드는 인스턴스 변수 이름에서 `@` 문자를 제거한 상태로 해당 값을 매핑해 주는 해시를 반환해 줍니다. 키들은 문자열형태를 가집니다. [[[The method `instance_values` returns a hash that maps instance variable names without "@" to their corresponding values. Keys are strings:]]]

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTE: 이 메소드는 `active_support/core_ext/object/instance_variables.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/instance_variables.rb`.]]]

### [Silencing Warnings, Streams, and Exceptions] 경고, 스트림, 예외 표시 감추기

`silence_warnings`와 `enable_warnings` 메소드는 블록내의 코드가 실행되는 동안 `$VERBOSE` 값을 변경하여 경고표시 상태를 결정하게 되는데 블록내의 코드 실행이 종료되면 다시 이전 상태로 되돌려 주게 됩니다. [[[The methods `silence_warnings` and `enable_warnings` change the value of `$VERBOSE` accordingly for the duration of their block, and reset it afterwards:]]]

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

`silence_stream` 메소드에 코드블록을 넘겨 주어 블록이 실행되는 동안 스트림으로 아무 것도 표시되지 않도록 할 수 있습니다. [[[You can silence any stream while a block runs with `silence_stream`:]]]

```ruby
silence_stream(STDOUT) do
  # STDOUT is silent here
end
```

`quietly` 메소드는 흔히 서브프로세스에서 조차도 STDOUT과 STDERR을 표시하지 않도록 할 때 사용할 수 있습니다. [[[The `quietly` method addresses the common use case where you want to silence STDOUT and STDERR, even in subprocesses:]]]

```ruby
quietly { system 'bundle install' }
```

예를 들면, railties 테스트 류들은 군데군데 이러한 메소드를 사용해서 명령 메시지가 진행상태 메시지와 혼재되어 표시되는 것을 방지해 줍니다.[[[For example, the railties test suite uses that one in a few places to prevent command messages from being echoed intermixed with the progress status.]]]

예외를 표시하지 않기 위해서는 `suppress`라는 메소드를 사용할 수 있습니다. 이 메소드는 여러개의 예외 클래스를 취할 수 있는데, 코드블록이 실행될 때 발생하는 예외가 인수로 넘겨진 예외의 `kind_of?` 클래스이면 `suppress` 메소드가 그 예외를 인지해서 표시하지 않도록 해 줍니다. 넘겨진 예외 클래스와 일치하지 않는 경우에는 해당 예외를 다시 발생시키게 됩니다. [[[Silencing exceptions is also possible with `suppress`. This method receives an arbitrary number of exception classes. If an exception is raised during the execution of the block and is `kind_of?` any of the arguments, `suppress` captures it and returns silently. Otherwise the exception is reraised:]]]

```ruby
# 해당 유저가 lock 상태일 때 increments 메소드는 값을 증가시키지 못하게 됩니다. 이것은 당연한 일이기도 합니다. 
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

코멘트 중 한역부분 [[[If the user is locked the increment is lost, no big deal.]]]

NOTE: 이 메소드는 `active_support/core_ext/kernel/reporting.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/kernel/reporting.rb`.]]]

### `in?`

`in?` 메소드는 특정 객체가 다른 객체나 객체 목록에 포함되는지를 테스트해 줍니다. 인수 하나만 넘겨지고 `include?` 메소드에 반응하지 않으면 `ArgumentError` 예외가 발생할 것입니다. [[[The predicate `in?` tests if an object is included in another object or a list of objects. An `ArgumentError` exception will be raised if a single argument is passed and it does not respond to `include?`.]]]

`in?` 메소드의 예는 아래와 같습니다. [[[Examples of `in?`:]]]

```ruby
1.in?(1,2)          # => true
1.in?([1,2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTE: 이 메소드는 `active_support/core_ext/object/inclusion.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/object/inclusion.rb`.]]]

[Extensions to `Module`] 모듈에 대한 확장 메소드
----------------------

### `alias_method_chain`

루비에서는 다른 메소드로 메소드를 감싸 줄 수 있습니다. 바로 이런 것을 _alias_chaining_ 이라고 합니다. [[[Using plain Ruby you can wrap methods with other methods, that's called _alias chaining_.]]]

예를 들어, 기능테스트에서 실제적인 요청이 있을 때 문자열을 params로 사용하기를 원하지만, 정수와 다른 형의 값들로도 사용하기를 원한다고 가정해 봅시다. 이를 구현하기 위해서는 `test/test_helper.rb` 파일내에 있는 `ActionController::TestCase#process`를 이런식으로 감싸줄 수 있을 것입니다. [[[For example, let's say you'd like params to be strings in functional tests, as they are in real requests, but still want the convenience of assigning integers and other kind of values. To accomplish that you could wrap `ActionController::TestCase#process` this way in `test/test_helper.rb`:]]]

```ruby
ActionController::TestCase.class_eval do
  # save a reference to the original process method
  alias_method :original_process, :process

  # now redefine process and delegate to original_process
  def process(action, params=nil, session=nil, flash=nil, http_method='GET')
    params = Hash[*params.map {|k, v| [k, v.to_s]}.flatten]
    original_process(action, params, session, flash, http_method)
  end
end
```

`get`, `post`등과 같은 메소드가 그 일을 위임받아 처리하게 됩니다.(역자주: 번역이 불완전합니다) [[[That's the method `get`, `post`, etc., delegate the work to.]]]

이러한 기법은 위험성이 있습니다. 예를 들어, `:original_process`를 취하게 될 때가 그런 경우입니다. 이 때 충돌을 피하기 위해서는 어떤 라벨을 선택하게 되는데, 바로 이것이 `alias chaining`이 어떤 특징이 있는지를 잘 설명해 줍니다. [[[That technique has a risk, it could be the case that `:original_process` was taken. To try to avoid collisions people choose some label that characterizes what the chaining is about:]]]

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

`alias_method_chain`은 이러한 기법를 단순화 시켜 줍니다.[[[The method `alias_method_chain` provides a shortcut for that pattern:]]]

```ruby
ActionController::TestCase.class_eval do
  def process_with_stringified_params(...)
    params = Hash[*params.map {|k, v| [k, v.to_s]}.flatten]
    process_without_stringified_params(action, params, session, flash, http_method)
  end
  alias_method_chain :process, :stringified_params
end
```

레일스는 코드 전반에 결쳐서 `alias_chain_methods`를 사용합니다. 예를 들어, 유효성검증에 특화된 별도의 모듈에서 그런식으로 감싸줌으로써 `ActiveRecord::Base#save`에 유효성 검증 기능을 추가해 주었습니다. [[[Rails uses `alias_method_chain` all over the code base. For example validations are added to `ActiveRecord::Base#save` by wrapping the method that way in a separate module specialized in validations.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/aliasing.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/aliasing.rb`.]]]

### Attributes

#### `alias_attribute`

모델 속성들은 reader, writer, predicate(논리값을 반환하는 reader)를 가집니다. 하나의 모델 속성에 별칭을 부여해서 한번에 이 세가지 메소드가 정의되도록 할 수 있습니다. 다른 별칭부여 메소스와 같이, 새로운 이름이 첫번째 인수가 되고 이전 이름이 두번째 인수가 됩니다.(이것은 할당 문법을 생각하면 쉽게 기억할 수 있습니다.)[[[Model attributes have a reader, a writer, and a predicate. You can alias a model attribute having the corresponding three methods defined for you in one shot. As in other aliasing methods, the new name is the first argument, and the old name is the second (my mnemonic is they go in the same order as if you did an assignment):]]]

```ruby
class User < ActiveRecord::Base
  # let me refer to the email column as "login",
  # possibly meaningful for authentication code
  alias_attribute :login, :email
end
```

NOTE: 이 메소드는 `active_support/core_ext/module/aliasing.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/aliasing.rb`.]]]

#### Internal Attributes

상속을 전제로 하여 클래스에서 하나의 속성을 정의할 때, 이름 충돌의 위험성이 있습니다. 이것은 라이브러리를 구축할 때 매우 심각한 일입니다. [[[When you are defining an attribute in a class that is meant to be subclassed, name collisions are a risk. That's remarkably important for libraries.]]]

액티브서프트는 `attr_internal_reader`, `attr_internal_writer`, `attr_internal_accessor` 매크로를 정의하고 있습니다. 이것들은 루비의 `attr_*` 해당 매크로와 같이 동작을 하지만 인스턴스변수명 앞에 밑줄문자가 붙여 이름 충돌을 최소한으로 피하도록 했습니다. [[[Active Support defines the macros `attr_internal_reader`, `attr_internal_writer`, and `attr_internal_accessor`. They behave like their Ruby built-in `attr_*` counterparts, except they name the underlying instance variable in a way that makes collisions less likely.]]]

`attr_internal` 매크로는 `attr_internal_accessor`와 같은 것입니다. [[[The macro `attr_internal` is a synonym for `attr_internal_accessor`:]]]

```ruby
# library
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# client code
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

이전 예에서 `:log_level`은 라이브러리의 공개 인턴페이스로 제공되지 않고 단지 개발을 위해서 사용됩니다. 이러한 이름 충돌의 가능성을 알지 못하는 클라이언트 코드에서 이 클래스를 상속해서 자신만의 `:log_level`을 정의하지만 `attr_internal` 덕분에 충돌현상을 발생하지 않게 됩니다. [[[In the previous example it could be the case that `:log_level` does not belong to the public interface of the library and it is only used for development. The client code, unaware of the potential conflict, subclasses and defines its own `:log_level`. Thanks to `attr_internal` there's no collision.]]]

디폴트 상태에서는 내부 인스턴스 변수의 이름은 위의 예에서 볼 때 `@_log_level`과 같이 이름 앞에 밑줄문자가 붙게 됩니다. 그러나 이러한 명칭 포맷은 `Module.attr_internal_naming_format`을 수정하여 변경할 수 있는데, 변수명이 위치하는 곳에 `sprintf`에서 사용하는 포맷 문자열의 앞에 `@`을 붙이고 문자열 중간에 `%s`를 삽입하면 됩니다. 디폴트는 `"@_%s"`입니다. [[[By default the internal instance variable is named with a leading underscore, `@_log_level` in the example above. That's configurable via `Module.attr_internal_naming_format` though, you can pass any `sprintf`-like format string with a leading `@` and a `%s` somewhere, which is where the name will be placed. The default is `"@_%s"`.]]]

레일스는 몇군데에서 이러한 내부 속성을 사용하는데, 뷰를 예를 들면, 다음과 같습니다. [[[Rails uses internal attributes in a few spots, for examples for views:]]]

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTE: 이 메소드는 `active_support/core_ext/module/attr_internal.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/attr_internal.rb`.]]]

#### Module Attributes

`mattr_reader`, `mattr_writer`, `mattr_accessor` 매크로는 클래스에서 정의되는 `cattr_*` 매크로에 해당하는 것입니다. [Class Attributes](#class-attributes)를 확인해 보기 바랍니다. [[[The macros `mattr_reader`, `mattr_writer`, and `mattr_accessor` are analogous to the `cattr_*` macros defined for class. Check [Class Attributes](#class-attributes).]]]

예를 들면, 의존성 메카니즘이 이것을 사용합니다. [[[For example, the dependencies mechanism uses them:]]]

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

NOTE: 이 메소드는 `active_support/core_ext/module/attribute_accessors.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/attribute_accessors.rb`.]]]

### Parents

#### `parent`

명칭이 붙은 모듈이 중첩된 경우 `parent` 메소드는 해당 모듈 상수를 포함하는 모듈을 반환해 줍니다. [[[The `parent` method on a nested named module returns the module that contains its corresponding constant:]]]

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

모듈에 명칭이 없거나 최상위에 속할 경우, `parent`는 `Object`를 반환해 줍니다. [[[If the module is anonymous or belongs to the top-level, `parent` returns `Object`.]]]

WARNING: 이럴 경우에, `parent_name`은 `nil` 값을 반환해 준다는 것을 주목하기 바랍니다. [[[Note that in that case `parent_name` returns `nil`.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/introspection.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/introspection.rb`.]]]

#### `parent_name`

모듈에 명칭이 있는 경우 중첩되어 사용될 때 `parent_name` 메소드는 해당 모듈 상수를 포함하는 모듈명을 전체 네임스페이스를 포함해서 문자열로 반환해 줍니다. [[[The `parent_name` method on a nested named module returns the fully-qualified name of the module that contains its corresponding constant:]]]

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

최상위 또는 명칭이 없는 모듈인 경우에 `parent_name`은 `nil` 값을 반환해 줍니다. [[[For top-level or anonymous modules `parent_name` returns `nil`.]]]

WARNING: 이런 경우에 `parent`는 `Object`를 반환한다는 것을 주목하기 바랍니다. [[[Note that in that case `parent` returns `Object`.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/introspection.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/introspection.rb`.]]]

#### `parents`

`parents` 메소드는 receiver에 대해서 (상속계층구조에서) `Object`에 도달할 때까지 `parent` 메소드를 호출합니다. 결과 체인은 아래서부터 최상위 순서로 배열에 담겨 반환됩니다. [[[The method `parents` calls `parent` on the receiver and upwards until `Object` is reached. The chain is returned in an array, from bottom to top:]]]

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

NOTE: 이 메소드는 `active_support/core_ext/module/introspection.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/introspection.rb`.]]]

### [Constants] 상수

`local_constants` 메소드는 receiver 모듈에 정의되어 있는 상수들의 이름을 반환해 줍니다. [[[The method `local_constants` returns the names of the constants that have been defined in the receiver module:]]]

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

이 때 상수명은 심볼로 반환됩니다. (이와 대조적으로, 이제는 더 이상 사용되지 않는 `local_constant_names` 메소드는 문자열을 반환합니다.) [[[The names are returned as symbols. (The deprecated method `local_constant_names` returns strings.)]]]

NOTE: 이 메소드는 `active_support/core_ext/module/introspection.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/introspection.rb`.]]]

#### [Qualified Constant Names] 경로를 포함하는 상수명

표준 루비 메소드인 `const_defined?`, `const_get`, `const_set`은 상수명만 인수로 받습니다. 그러나 액티브서포트는 이 표준 API의 기능을 확장해서 상대경로를 포함하는 상수명을 넘겨 받을 수 있습니다. [[[The standard methods `const_defined?`, `const_get` , and `const_set` accept bare constant names. Active Support extends this API to be able to pass relative qualified constant names.]]]

이렇게 기능이 확장된 새로운 메소드는 `qualified_const_defined?`, `qualified_const_get`, `qualified_const_set`이 있습니다. 인수는 receiver에 대한 상대경로명을 가지는 상수명이 지정됩니다. (역자주: `qualified_*`로 시작하는 메소드는 receiver로 부터의 상대경로 상의 인수를 받는다고 생각하면 될 것 같습니다.) [[[The new methods are `qualified_const_defined?`, `qualified_const_get`, and `qualified_const_set`. Their arguments are assumed to be qualified constant names relative to their receiver:]]]

```ruby
Object.qualified_const_defined?("Math::PI")       # => true
Object.qualified_const_get("Math::PI")            # => 3.141592653589793
Object.qualified_const_set("Math::Phi", 1.618034) # => 1.618034
```

인수를 상수 이름만으로 지정할 수 있습니다. [[[Arguments may be bare constant names:]]]

```ruby
Math.qualified_const_get("E") # => 2.718281828459045
```

이 메소드는 루비의 내장 코어의 카운터파트 메소드와 유사합니다. 특히, `qualified_constant_defined?` 메소드는 두번째 인수를 옵션으로 지정하여 상속계층구조상에서 조상모듈을 찾을 것인지를 선택할 수 있습니다. 이 옵션은 계층구조의 경로를 따라 갈 때 표현식에서 각각의 상수에 대해서 고려해야 합니다. [[[These methods are analogous to their builtin counterparts. In particular, `qualified_constant_defined?` accepts an optional second argument to be able to say whether you want the predicate to look in the ancestors. This flag is taken into account for each constant in the expression while walking down the path.]]]

예를 들어, 다음과 같은 모듈구조에서 [[[For example, given]]]

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

`qualified_const_defined?` 메소드는 다음과 같이 동작을 하게 됩니다. [[[`qualified_const_defined?` behaves this way:]]]

```ruby
N.qualified_const_defined?("C::X", false) # => false
N.qualified_const_defined?("C::X", true)  # => true
N.qualified_const_defined?("C::X")        # => true
```

위의 예에서와 같이, 두번째 인수의 디폴트값은, `const_defined?`에서와 같이, true 입니다. [[[As the last example implies, the second argument defaults to true, as in `const_defined?`.]]]

내장 메소드에 대한 일관성을 유지하기 위해서, 상대경로만을 취하게 됩니다. `::Math::PI`와 같은 절대경로를 사용할 경우에는 `NamedError` 예외가 발생합니다. [[[For coherence with the builtin methods only relative paths are accepted. Absolute qualified constant names like `::Math::PI` raise `NameError`.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/qualified_const.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/qualified_const.rb`.]]]

### Reachable

이름이 붙은 모듈이 해당 상수로 저장이 된 경우 그 모듈은 `reachable` 하다라고 말합니다. 다시 말해서, 그 상수를 통해서 모듈 객체에 접근할 수 있다는 의미입니다. [[[A named module is reachable if it is stored in its corresponding constant. It means you can reach the module object via the constant.]]]

이것은 일반적으로 일어나는 일인데, 하나의 모듈이 "M"으로 호출된다면 `M` 상수가 존재하게 되는 것이고 이 상수는 해당 모듈은 소유하게 되는 것입니다. [[[That is what ordinarily happens, if a module is called "M", the `M` constant exists and holds it:]]]

```ruby
module M
end

M.reachable? # => true
```

그러나 상수와 모듈이 일종의 분리상태로 된다면 모듈객체는 `unreachable`하게 됩니다. [[[But since constants and modules are indeed kind of decoupled, module objects can become unreachable:]]]

```ruby
module M
end

orphan = Object.send(:remove_const, :M)

#1 모듈 객체는 이제 상수와 모듈자체가 분리되었지만 여전히 모듈 이름을 가지고 있습니다. 
orphan.name # => "M"

#2 상수 M이 더 이상 존재하지 않기 때문에 상수 M을 통해서 접근할 수 없습니다.
orphan.reachable? # => false

#3 다시 "M"이라는 모듈을 정의해 봅시다.
module M
end

#4 이제 다시 상수 M이 존재하게 되고 이 상수가 "M"이라고 하는 모듈객체를 저장하게 되자만, 이것은 새로운 인스턴스라서 이전 것과 동일한 것을 아닙니다. 
orphan.reachable? # => false
```

위 코드내의 코멘트 1 [[[The module object is orphan now but it still has a name.]]]
위 코드내의 코멘트 2 [[[You cannot reach it via the constant M because it does not even exist.]]]
위 코드내의 코멘트 3 [[[Let's define a module called "M" again.]]]
위 코드내의 코멘트 4 [[[The constant M exists now again, and it stores a module object called "M", but it is a new instance.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/reachable.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/reachable.rb`.]]]

### [Anonymous] 익명 모듈

하나의 모듈은 이름을 가질 수도 있고, 이름이 없을 수도 있습니다. [[[A module may or may not have a name:]]]

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

`anonymous?` 메소드를 이용하여 특정 모듈이 이름을 가지고 있는지를 알아볼 수 있습니다. [[[You can check whether a module has a name with the predicate `anonymous?`:]]]

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

따라서 주목할 것은 `unreachable`하다는 것이 반드시 `anonymous`하다는 것이 아니라는 것입니다.(역자주: 모듈을 접근하기 위한 상수명을 가지는 것과 모듈객체의 이름을 가지는 것과는 별개의 것입니다. 개념을 이해하기가 까다롭습니다.) [[[Note that being unreachable does not imply being anonymous:]]]

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.reachable? # => false
m.anonymous? # => false
```

그러나 반대로, 정의상, 이름이 없는 모듈은 `unreachable` 하긴 합니다. [[[though an anonymous module is unreachable by definition.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/anonymous.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/anonymous.rb`.]]]

### [Method Delegation] 메소드의 위임

`delegate` 매크로는 메소드를 전단하기 위한 손쉬운 방법을 제공해 줍니다. [[[The macro `delegate` offers an easy way to forward methods.]]]

어떤 어플리케이션에서 유저가 로그인 정보는 `User` 모델에 가지고 있지만, 이름과 기타 다른 데이터는 별도의 `Profile` 모델에 가지고 있다고 가정해 보겠습니다. [[[Let's imagine that users in some application have login information in the `User` model but name and other data in a separate `Profile` model:]]]

```ruby
class User < ActiveRecord::Base
  has_one :profile
end
```

이러한 설정에서 유저의 이름은 자신의 프로파일을 통해서(`user.profile.name`) 얻을 수 있지만, 유저 모델에서 직접 속성처럼 접근할 수 있다면 더 편리할 수 있습니다. [[[With that configuration you get a user's name via his profile, `user.profile.name`, but it could be handy to still be able to access such attribute directly:]]]

```ruby
class User < ActiveRecord::Base
  has_one :profile

  def name
    profile.name
  end
end
```

바로 이것이 `delegate` 매크로가 하는 일입니다. [[[That is what `delegate` does for you:]]]

```ruby
class User < ActiveRecord::Base
  has_one :profile

  delegate :name, to: :profile
end
```

`delegate` 매크로를 사용하면 코드가 보다 간단해지고, 프로그래머의 의도를 더 직관적으로 알 수 있게 됩니다. [[[It is shorter, and the intention more obvious.]]]

메소드는 대상 클래스에서 public 접근자(역자주: `액션`)로 선언되어 있어야 합니다. [[[The method must be public in the target.]]]

`delegate` 매크로에 여러개의 메소드를 지정할 수 있습니다. [[[The `delegate` macro accepts several methods:]]]

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

문자열 중간에 삽입될 경우에는, `:to` 옵션은 표현식이 되어야 합니다. 그래서 이 표현식이 메소드가 전달되는 객체에 대해서 평가되어야 합니다. 이 옵션은 대개 문자열 또는 심볼을 취하게 됩니다. 이 표현식은 receiver의 입장에서 평가되어야 합니다. [[[When interpolated into a string, the `:to` option should become an expression that evaluates to the object the method is delegated to. Typically a string or symbol. Such an expression is evaluated in the context of the receiver:]]]

```ruby
#1 레일스 상수로 위임 
delegate :logger, to: :Rails

#2 receiver의 클래스로 위임 
delegate :table_name, to: :class
```

위 예의 코멘트 #1 [[[delegates to the Rails constant]]]
위 예의 코멘트 #2 [[[delegates to the receiver's class]]]


WARNING: `:prefix` 옵션이 `true`인 경우는 일반적이지 않지만 아래를 참조하기 바랍니다. [[[If the `:prefix` option is `true` this is less generic, see below.]]]

디폴트 상태에서, 메소드 위임이 `NoMethodError` 예외를 발생시키고 대상이 `nil`이면 예외가 전달됩니다. 이 때 `:allow_nil` 옵션을 사용하면 대신에 `nil` 값을 반환하도록 할 수 있습니다. [[[By default, if the delegation raises `NoMethodError` and the target is `nil` the exception is propagated. You can ask that `nil` is returned instead with the `:allow_nil` option:]]]

```ruby
delegate :name, to: :profile, allow_nil: true
```

즉, `:allow_nil` 옵션을 사용할 경우, 유저가 프로파일이 없는 경우에라도 `user.name`을 호출하면, 예외를 발생시키지 않고 `nil` 값을 반환하게 됩니다. [[[With `:allow_nil` the call `user.name` returns `nil` if the user has no profile.]]]

`:prefix` 옵션은 위임된 메소드의 이름 앞에 전두어를 추가해 줍니다. 이것은 좀 더 좋은 이름을 사용하고자 할 때 편리할 수 있습니다. [[[The option `:prefix` adds a prefix to the name of the generated method. This may be handy for example to get a better name:]]]

```ruby
delegate :street, to: :address, prefix: true
```

위의 예에서는 `street`가 아니고 `address_street`라는 메소드명을 만들어 줍니다. [[[The previous example generates `address_street` rather than `street`.]]]

WARNING: 이런 경우에 위임 메소드명이 대상 객체와 대상 메소드명의 조합으로 만들어지기 때문에, `:to` 옵션은 메소드명이 되는 것입니다. [[[Since in this case the name of the generated method is composed of the target object and target method names, the `:to` option must be a method name.]]]

또한 전두어를 변경할 수 있습니다. [[[A custom prefix may also be configured:]]]

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

위의 예에서, `delegate` 매크로는 `size`가 아니고 `avatar_size`라는 위임 메소드명을 생성하게 됩니다. [[[In the previous example the macro generates `avatar_size` rather than `size`.]]]

NOTE: 이 메소드는 `active_support/core_ext/module/delegation.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/delegation.rb`]]]

### [Redefining Methods] 메소드 재정의하기

`define_method`를 사용해서 하나의 메소드를 정의해야 할 경우가 있습니다. 그러나 미리 정의할 메소드명이 이미 존재하는 지를 알 수 없습니다. 만약 이미 정의된 메소드명을 지정하게 되면, 해당 메소드가 기능을 하게 될 때 경고메시지가 나타나게 됩니다. 당연한 것이지만, 그렇다고 깔끔하지는 못합니다. [[[There are cases where you need to define a method with `define_method`, but don't know whether a method with that name already exists. If it does, a warning is issued if they are enabled. No big deal, but not clean either.]]]

이러한 상황에서, `redefine_method` 메소드는 필요할 경우 기존의 메소드를 제거해서 그런 잠재된 경고를 방지해 줍니다. 레일스는 몇군데에서 이 메소드를 사용하는데, 예를 들면 모델 관계를 설정하는 API를 생성할 때 입니다. [[[The method `redefine_method` prevents such a potential warning, removing the existing method before if needed. Rails uses it in a few places, for instance when it generates an association's API:]]]

```ruby
redefine_method("#{reflection.name}=") do |new_value|
  association = association_instance_get(reflection.name)

  if association.nil? || association.target != new_value
    association = association_proxy_class.new(self, reflection)
  end

  association.replace(new_value)
  association_instance_set(reflection.name, new_value.nil? ? nil : association)
end
```

NOTE: 이 메소드는 `active_support/core_ext/module/remove_method.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/module/remove_method.rb`]]]

[Extensions to `Class`] `클래스`에 대한 확장 메소드
---------------------

### [Class Attributes] 클래스 속성

#### `class_attribute`

`class_attribute` 메소드는 특정 클래스의 상속계층구조상 어느 레벨에서라도 재정의될 수 있는 상속가능한 클래스 속성을 하나 또는 그 이상을 선언해 줍니다. [[[The method `class_attribute` declares one or more inheritable class attributes that can be overridden at any level down the hierarchy.]]]

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

예를 들어, `ActionMailer::Base`는 다음과 같이 정의합니다. [[[For example `ActionMailer::Base` defines:]]]

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

이 클래스 속성들은 인스턴스 레벨에서도 접근할 수 있고 재정의할 수도 있습니다. [[[They can be also accessed and overridden at the instance level.]]]

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, comes from A
a2.x # => 2, overridden in a2
```

이 때 `:instance_writer` 옵션을 `false` 값으로 지정하면 `writer` 인스턴스 메소드를 생성하지 못하게 할 수 있습니다. [[[The generation of the writer instance method can be prevented by setting the option `:instance_writer` to `false`.]]]

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false
    self.table_name_prefix = ""
  end
end
```

모델 입장에서는 이 옵션이 클래스 속성을 mass-assignment로 변경할 수 없도록 하는 유용한 방법이라고 생각할 수 있습니다. [[[A model may find that option useful as a way to prevent mass-assignment from setting the attribute.]]]

`:instance_reader` 옵션을 `false` 값으로 지정하여 `reader` 인스턴스 메소드를 생성하지 못하게 할 수 있습니다. [[[The generation of the reader instance method can be prevented by setting the option `:instance_reader` to `false`.]]]

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1 # NoMethodError
```

편리함을 위해서, `class_attribute` 메소드는 인스턴스 `reader`가 반환하는 것에 대한 논리값을 반환하는 인스턴스 `predicate`를 정의해 줍니다. 위의 예에서는 `x?`을 호출합니다. [[[For convenience `class_attribute` also defines an instance predicate which is the double negation of what the instance reader returns. In the examples above it would be called `x?`.]]]

`:instance_reader`에 `false`값이 지정되어 있는 상태에서 인스턴스 `predicate`를 호출하면 reader 메소드처럼 `NoMethodError`를 반환하게 됩니다. [[[When `:instance_reader` is `false`, the instance predicate returns a `NoMethodError` just like the reader method.]]]

인스턴스 `predicate`가 생성되기를 원치 않는다면, `instance_predicate: false`를 넘겨 주면 됩니다. [[[If you do not want the instance predicate,  pass `instance_predicate: false` and it will not be defined.]]]

NOTE: 이 메소드는 `active_support/core_ext/class/attribute.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/class/attribute.rb`]]]

#### `cattr_reader`, `cattr_writer`, and `cattr_accessor`

`cattr_reader`, `cattr_writer`, `cattr_accessor` 매크로는 `attr_*` 카운터파트 매크로와 클래스라는 것만 제외하고 유사합니다. 이 매크로들은 클래스 변수가 이전에 존재하지 않는 것이라면 `nil` 값으로 초기화하고 그 클래스변수를 접근하기 위한 해당 클래스 메소드를 생성해 줍니다. [[[The macros `cattr_reader`, `cattr_writer`, and `cattr_accessor` are analogous to their `attr_*` counterparts but for classes. They initialize a class variable to `nil` unless it already exists, and generate the corresponding class methods to access it:]]]

```ruby
class MysqlAdapter < AbstractAdapter
  # Generates class methods to access @@emulate_booleans.
  cattr_accessor :emulate_booleans
  self.emulate_booleans = true
end
```

편리를 도모하기 위해서 인스턴스 메소드가 만들어 지지만 단지 클래스 속성에 대한 대리자에 불과합니다. 그래서, 인스턴스 객체들이 클래스 속성을 변경할 수 있지만 위에서 언급되었던 `class_attribute` 처럼 재정의할 수는 없습니다. 예를 들어 다음과 같을 때, [[[Instance methods are created as well for convenience, they are just proxies to the class attribute. So, instances can change the class attribute, but cannot override it as it happens with `class_attribute` (see above). For example given]]]

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc
    @@field_error_proc = Proc.new{ ... }
  end
end
```

뷰에서 `field_error_proc` 클래스 속성을 접근할 수 있습니다. [[[we can access `field_error_proc` in views.]]]

`:instance_reader` 옵션을 `false`로 지정하여 `reader` 인스턴스 메소드의 생성을 못하게 할 수 있고, `:instance_writer` 옵션을 `false`로 지정하여 `writer` 인스턴스 메소드의 생성을 막을 수 있습니다. `:instance_accessor` 옵션을 `false`로 지정하여 이 두가지 인스턴스 메소드가 만들어지 못하도록 할 수 있습니다. 이 모든 경우에서, 값은 정확하게 `false`로 지정되어야 합니다. [[[The generation of the reader instance method can be prevented by setting `:instance_reader` to `false` and the generation of the writer instance method can be prevented by setting `:instance_writer` to `false`. Generation of both methods can be prevented by setting `:instance_accessor` to `false`. In all cases, the value must be exactly `false` and not any false value.]]]

```ruby
module A
  class B
    # No first_name instance reader is generated.
    cattr_accessor :first_name, instance_reader: false
    # No last_name= instance writer is generated.
    cattr_accessor :last_name, instance_writer: false
    # No surname instance reader or surname= writer is generated.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

모델에서 `:instance_accessor`를 `false`로 지정하면, mass-assignment를 통해 해당 클래스 속성을 변경할 수 없게 하는 유용한 방법이 될 수 있습니다. [[[A model may find it useful to set `:instance_accessor` to `false` as a way to prevent mass-assignment from setting the attribute.]]]

NOTE: 이 메소드는 `active_support/core_ext/class/attribute_accessors.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/class/attribute_accessors.rb`.]]]

### Subclasses & Descendants 

#### `subclasses`

`subclasses` 메소드는 receiver 클래스의 하위클래스들을 반환합니다. [[[The `subclasses` method returns the subclasses of the receiver:]]]

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

이 때 반환되는 클래스의 순서는 명시되지 않습니다. [[[The order in which these classes are returned is unspecified.]]]

NOTE: 이 메소드는 `active_support/core_ext/class/subclasses.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/class/subclasses.rb`.]]]

#### `descendants`

`descendants` 메소드는 receiver 클래스로부터 상속받은 모든 클래스를 반환합니다. [[[The `descendants` method returns all classes that are `<` than its receiver:]]]

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

이 때 반환되는 클래스의 순서는 명시되지 않습니다. [[[The order in which these classes are returned is unspecified.]]]

NOTE: 이 메소드는 `active_support/core_ext/class/subclasses.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/class/subclasses.rb`.]]]

[Extensions to `String`] `String`형에 대한 확장 메소드
----------------------

### Output Safety

#### Motivation

데이터를 HTML템플릿에 삽입할 때는 주의를 기울려야 합니다. 예를 들면, `@review.title`을 HTML 페이지에도 그대로 삽입할 수 없습니다. 한가지는, review title이 "Flanagan & Matz rules!"와 같다면, 문자열에 포함된 "&" 문자가 "&amp;amp;"로 특수문자 처리가 되기 때문에 결과가 제대로 보이지 않게 됩니다. 더우기, 어플리케이션에 따라서는, 유저들이 review title에 악성 HTML코드를 삽입할 수 있기 때문에 심각한 보안상의 결함을 초래할 수 있습니다. 이러한 보안상의 위험에 대해서 자세한 내용을 알고자 한다면 [Security guide](security.html#cross-site-scripting-xss)에 있는 cross-site scripting에 대한 내용을 확인해 보기 바랍니다. [[[Inserting data into HTML templates needs extra care. For example, you can't just interpolate `@review.title` verbatim into an HTML page. For one thing, if the review title is "Flanagan & Matz rules!" the output won't be well-formed because an ampersand has to be escaped as "&amp;amp;". What's more, depending on the application, that may be a big security hole because users can inject malicious HTML setting a hand-crafted review title. Check out the section about cross-site scripting in the [Security guide](security.html#cross-site-scripting-xss) for further information about the risks.]]]

#### [Safe Strings] 보안상 안전한 문자열

액티브서포트는 <i>(html) safe</i> 문자열에 관한 개념을 가지고 있습니다. 따라서 안전한 문자열이란 HTML 태그를 있는 그대로 삽입할 수 있는 상태를 말합니다. 이와 같이 안전문자열은 이스케이프 되던 안 되던간에 상관없이 신뢰성을 갖게 됩니다. [[[Active Support has the concept of <i>(html) safe</i> strings. A safe string is one that is marked as being insertable into HTML as is. It is trusted, no matter whether it has been escaped or not.]]]

문자열은 디폴트로 <i>비안전(unsafe)</i>한 것으로 간주됩니다. [[[Strings are considered to be <i>unsafe</i> by default:]]]

```ruby
"".html_safe? # => false
```

`html_safe` 메소드를 사용하면 안전문자열을 얻을 수 있습니다. [[[You can obtain a safe string from a given one with the `html_safe` method:]]]

```ruby
s = "".html_safe
s.html_safe? # => true
```

`html_safe`는 receiver 문자열이 무엇인던지 간에 상관없이 <i>특수문자를 무효화(no escaping)</i>시킨다는 것을 이해하는 것이 중요한데, 이것은 그저 하나의 주장에 불과할 뿐입니다. [[[It is important to understand that `html_safe` performs no escaping whatsoever, it is just an assertion:]]]

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

특정 문자열에 대해서 `html_safe`을 호출하는 것은 전적으로 개발자의 몫입니다. [[[It is your responsibility to ensure calling `html_safe` on a particular string is fine.]]]

안전문자열 끝에 `concat`/`<<`, or with `+`를 이용하여 추가한다면 결과는 안전문자열이 됩니다. 비안전 인수에서는 특수문자가 고유의 기능을 하게 됩니다. [[[If you append onto a safe string, either in-place with `concat`/`<<`, or with `+`, the result is a safe string. Unsafe arguments are escaped:]]]

```ruby
"".html_safe + "<" # => "&lt;"
```

안전 인수들은 직접 추가됩니다. [[[Safe arguments are directly appended:]]]

```ruby
"".html_safe + "<".html_safe # => "<"
```

이 메소드는 평상적인 뷰에서 사용해서는 안됩니다. 비안전 값에 대해서는 자동으로 특수문자가 고유의 기능을 하게 됩니다. [[[These methods should not be used in ordinary views. Unsafe values are automatically escaped:]]]

```erb
<%= @review.title %> <%# fine, escaped if needed %>
```

따라서 뷰에서는 `html_safe`을 호출하기 보다는 `raw` 헬퍼를 사용하여 있는 그대로 보이게 합니다. [[[To insert something verbatim use the `raw` helper rather than calling `html_safe`:]]]

```erb
<%= raw @cms.current_template %> <%# inserts @cms.current_template as is %>
```

또는 `<%==`와 같이 사용해도 동일한 결과를 보여 줍니다. [[[or, equivalently, use `<%==`:]]]

```erb
<%== @cms.current_template %> <%# inserts @cms.current_template as is %>
```

`raw` 헬퍼는 `html_safe`를 호출합니다. [[[The `raw` helper calls `html_safe` for you:]]]

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/output_safety.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/output_safety.rb`.]]]

#### [Transformation] 문자열 변형

대개, 위에서 설명한 바와 같이 문자열을 연결하는 것을 제외하고, 문자열을 변경하는 메소드는 비안전 문자열을 반환합니다. 이러한 메소드는 `downcase`, `gsub`, `strip`, `chomp`, `underscore` 등이 있습니다. [[[As a rule of thumb, except perhaps for concatenation as explained above, any method that may change a string gives you an unsafe string. These are `downcase`, `gsub`, `strip`, `chomp`, `underscore`, etc.]]]

`gsub!`와 같이 receiver 문자열을 변경하는 경우에, receiver 문자열은 비안전 상태로 됩니다. [[[In the case of in-place transformations like `gsub!` the receiver itself becomes unsafe.]]]

INFO: 문자열 변형이 실제로 변경하는 것과는 무관하게 안전 상태값은 항상 사라지게 됩니다. [[[The safety bit is lost always, no matter whether the transformation actually changed something.]]]

#### [Conversion and Coercion] 강제 변환

안전 문자열에 대해서 `to_s`를 호출하면 안전 문자열을 반환하지만 `to_str` 메소드로 강제로 변환하면 비안전 문자열을 반환하게 됩니다. [[[Calling `to_s` on a safe string returns a safe string, but coercion with `to_str` returns an unsafe string.]]]

#### [Copying] 복사하기

안전문자열에 대해서 `dup` 또는 `clone`을 호출하면 안전문자열을 만들어 줍니다. [[[Calling `dup` or `clone` on safe strings yields safe strings.]]]

### `squish`

`squish` 메소드는 문자열 앞뒤에 있는 whitespace를 제거해 주고 중간에 whitespace가 중복되어 나타날 때는 각각에 대해서 하나의 스페이스로 대체해 줍니다. [[[The method `squish` strips leading and trailing whitespace, and substitutes runs of whitespace with a single space each:]]]

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

또한 !(bang) 버전도 사용할 수 있습니다. [[[There's also the destructive version `String#squish!`.]]]

이 메소드는 몽고어 모음 구분자(U+180E)와 같은 ASCII와 유니코드 whitespace도 처리해 줍니다. [[[Note that it handles both ASCII and Unicode whitespace like mongolian vowel separator (U+180E).]]]

NOTE: 이 메소드는 `active_support/core_ext/string/filters.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/filters.rb`.]]]

### `truncate`

`truncate` 메소드는 receiver 문자열을 주어진 길이만큼 잘라서 반환해 줍니다. [[[The method `truncate` returns a copy of its receiver truncated after a given `length`:]]]

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

생략부호는 `:omission` 옵션으로 변경할 수 있습니다. [[[Ellipsis can be customized with the `:omission` option:]]]

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

특히 주목할 것은, 주어진 길이 만큼 문자열을 짜를 때 생략문자열의 길이를 감안한다는 것입니다. [[[Note in particular that truncation takes into account the length of the omission string.]]]

`:separator` 옵션을 사용하면 단어의 중간이 아니라 단어의 전후에서 짤리도록 할 수 있습니다. [[[Pass a `:separator` to truncate the string at a natural break:]]]

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

또한 `:separator` 옵션은 정규표현식으로 지정할 수도 있습니다. [[[The option `:separator` can be a regexp:]]]

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

위의 예에서, "dear" 단어의 중간에서 짤려야 하지만 `:separator` 옵션을 사용하였기 때문에 그 단어 앞에서 짤리는 결과를 보입니다. [[[In above examples "dear" gets cut first, but then `:separator` prevents it.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/filters.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/filters.rb`.]]]

### `inquiry`

`inguiry` 메소드는 문자열을 `StringInquirer` 객채로 변환해서 일치함을 좀 더 멋지게 확인할 수 있도록 해 줍니다. [[[The `inquiry` method converts a string into a `StringInquirer` object making equality checks prettier.]]]

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

### `starts_with?` and `ends_with?`

액티브서포트는 `String#start_with?`와 `String#end_with?` 메소드도 지원해 줍니다. [[[Active Support defines 3rd person aliases of `String#start_with?` and `String#end_with?`:]]]

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE: 이 메소드는 `active_support/core_ext/string/starts_ends_with.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/starts_ends_with.rb`.]]]

### `strip_heredoc`

`strip_heredoc` 메소드는 heredoc 내에서 들여쓰기 여백을 제거해 줍니다. [[[The method `strip_heredoc` strips indentation in heredocs.]]]

For example in

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

이와 같이 하면 사용자는 사용법 메시지를 왼쪽 마진에 정돈되어 보게 됩니다. [[[the user would see the usage message aligned against the left margin.]]]

기술적으로는, 가장 들여쓰기가 작은 라인을 찾아서 그만큼 전체 들여쓰기를 제거해 줍니다. [[[Technically, it looks for the least indented line in the whole string, and removes that amount of leading whitespace.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/strip.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/strip.rb`.]]]

### `indent`

`indent` 메소드는 receiver의 코드라인을 들여쓰기 합니다. [[[Indents the lines in the receiver:]]]

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

두번째 인수인 `indent_string`은 들여쓰기 문자로 어떤 것을 사용할 것인지를 지정할 수 있게 해 줍니다. 디폴트는 `nil`이며, 이것은 메소드로 하여금 receiver내에서 제일 처음 들여쓰기된 라인을 찾아보고 학습(들여쓰기 문자로 어떤 것이 쓰였는지를 알도록)을 하도록 하여, 들여쓰기 문자가 없다면 대신 스페이스문자로 들여쓰기를 하게 됩니다. [[[The second argument, `indent_string`, specifies which indent string to use. The default is `nil`, which tells the method to make an educated guess peeking at the first indented line, and fallback to a space if there is none.]]]

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

보통은 `indent_string`으로 스페이스나 탭문자를 사용하지만 다른 어떤 문자도 가능합니다. [[[While `indent_string` is typically one space or tab, it may be any string.]]]

세번째 인수인 `indent_empty_lines`는 빈 라인도 들여쓰기를 할지를 결정하는 표시로 디폴값은 false입니다. [[[The third argument, `indent_empty_lines`, is a flag that says whether empty lines should be indented. Default is false.]]]

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

!(bang)버전인 `indent!` 메소드는 receiver 문자열에 직접 들여쓰기를 합니다. [[[The `indent!` method performs indentation in-place.]]]

### [Access] 접근 메소드

#### `at(position)`

이 메소드는 문자열내 특정 `position`에 위치하는 문자를 반환해 줍니다. [[[Returns the character of the string at position `position`:]]]

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE: 이 메소드는 `active_support/core_ext/string/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/access.rb`.]]]

#### `from(position)`

이 메소드는 문자열내 특정 `position`부터 끝까지의 문자열 일부를 반환합니다. [[[Returns the substring of the string starting at position `position`:]]]

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => "" if < 1.9, nil in 1.9
```

NOTE: 이 메소드는 `active_support/core_ext/string/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/access.rb`.]]]

#### `to(position)`

이 메소드는 문자열내 특정 `position`까지의 문자열 일부를 반환합니다. [[[Returns the substring of the string up to position `position`:]]]

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE: 이 메소드는 `active_support/core_ext/string/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/access.rb`.]]]

#### `first(limit = 1)`

`str.first(n)`은 `n`이 0 보다 클 경우, `str.to(n-1)`와 같은 결과를 반환해 주며, 0인 경우에는 빈 문자열을 반환해 줍니다. [[[The call `str.first(n)` is equivalent to `str.to(n-1)` if `n` > 0, and returns an empty string for `n` == 0.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/access.rb`.]]]

#### `last(limit = 1)`

`str.last(n)`은 `n`이 0보다 클 경우, `str.from(n-1)`와 같은 결과를 반환해 주며, 0인 경우에는 빈 문자열을 반환해 줍니다. [[[The call `str.last(n)` is equivalent to `str.from(-n)` if `n` > 0, and returns an empty string for `n` == 0.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/access.rb`.]]]

### [Inflections] 어미/어형의 변경 메소드

#### `pluralize`

`pluralize`는 receiver 문자열의 복수형을 반환합니다. [[[The method `pluralize` returns the plural of its receiver:]]]

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

이전 예에서 알 수 있듯이, 액티브서포트는 불규칙 복수형과 불가산 명사들을 인식합니다. 내장된 변환규칙은 `config/initializers/inflections.rb`에서 확장할 수 있습니다. 이 파일은 `rails` 명령으로 생성되는데, 코멘트에 그 사용법이 소개되어 있습니다. [[[As the previous example shows, Active Support knows some irregular plurals and uncountable nouns. Built-in rules can be extended in `config/initializers/inflections.rb`. That file is generated by the `rails` command and has instructions in comments.]]]

`pluralize` 메소드는 또한 `count` 옵션을 가질 수 있는데, `count == 1`이면 단수형이 반환될 것입니다. 1 이외의 다른 값에 대해서는 복수형이 반환될 것입니다. [[[`pluralize` can also take an optional `count` parameter.  If `count == 1` the singular form will be returned.  For any other value of `count` the plural form will be returned:]]]

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

액티브서포트는 이 메소드를 이용해서 특정 모델과 연결되는 디폴트 테이블명을 산출해 냅니다. [[[Active Record uses this method to compute the default table name that corresponds to a model:]]]

```ruby
# active_record/model_schema.rb
def undecorated_table_name(class_name = base_class.name)
  table_name = class_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `singularize`

`pluralize` 메소드의 반대기능을 하는 메소드입니다. [[[The inverse of `pluralize`:]]]

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

모델간의 관계를 설정할 때 바로 이 메소드를 이용하여 해당 디폴트 클래스명을 산출하게 됩니다. [[[Associations compute the name of the corresponding default associated class using this method:]]]

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `camelize`

이 메소드는 receiver를 카멜형으로 반환해 줍니다. [[[The method `camelize` returns its receiver in camel case:]]]

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

대개는 슬래시 문자를 네임스페이로 사용하는 경로를 루비클래스나 모듈명으로 변형하고자 할 때 이 메소드를 고려해 볼 수 있습니다. [[[As a rule of thumb you can think of this method as the one that transforms paths into Ruby class or module names, where slashes separate namespaces:]]]

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

예를 들어, 액션팩은 이 메소드를 이용하여, 임의의 세션저장소를 제공하는 클래스를 로드합니다. [[[For example, Action Pack uses this method to load the class that provides a certain session store:]]]

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` 메소드는 하나의 옵션을 취할 수 있는데 `:upper`(디폴트) 또는 `:lower` 입니다. `:lower` 옵션을 사용하면 첫번째 문자가 소문자가 됩니다. [[[`camelize` accepts an optional argument, it can be `:upper` (default), or `:lower`. With the latter the first letter becomes lowercase:]]]

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

이 메소드는 예를 들어 자바스크립트와 같이 이러한 규칙을 따르는 언어에서 메소드명을 산출하는데 사용하면 편리합니다. [[[That may be handy to compute method names in a language that follows that convention, for example JavaScript.]]]

INFO: 대개는 `underscore`와 반대기능으로 `camelize` 메소드를 생각할 수 있습니다. 그러나 특수한 경우도 있습니다. 즉, `"SSLError".underscore.camelize`는 `"SslError"`값을 되돌려 주는데, 이러한 경우를 감안하여, 액티브서포트는 `config/initializers/inflections.rb` 파일내에 이러한 첨두어(Acronym)를 명시할 수 있게 해 줍니다. [[[As a rule of thumb you can think of `camelize` as the inverse of `underscore`, though there are cases where that does not hold: `"SSLError".underscore.camelize` gives back `"SslError"`. To support cases such as this, Active Support allows you to specify acronyms in `config/initializers/inflections.rb`:]]]

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize #=> "SSLError"
```

`camelize`는 `camelcase`라는 이름으로도 사용할 수 있습니다. [[[`camelize` is aliased to `camelcase`.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `underscore`

`underscore` 메소드는 카멜형으로 경로명을 산출할 때 사용하면 됩니다. [[[The method `underscore` goes the other way around, from camel case to paths:]]]

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

이 때 네이스페이스 구분자인 "::"는 "/" 로 변환됩니다. [[[Also converts "::" back to "/":]]]

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

그리고 소문자로 시작하는 문자열을 인식하기도 합니다. [[[and understands strings that start with lowercase:]]]

```ruby
"visualEffect".underscore # => "visual_effect"
```

그러나 `underscore` 메소드는 인수를 취할 수 없습니다. [[[`underscore` accepts no argument though.]]]

레일스 클래스와 모듈을 자동으로 로딩할 때 바로 이 메소드를 이용하는데, missing constant를 정의하는 모듈 파일의 확장자 없이 상대경로를 유추하게 됩니다. [[[Rails class and module autoloading uses `underscore` to infer the relative path without extension of a file that would define a given missing constant:]]]

```ruby
# active_support/dependencies.rb
def load_missing_constant(from_mod, const_name)
  ...
  qualified_name = qualified_name_for from_mod, const_name
  path_suffix = qualified_name.underscore
  ...
end
```

INFO: 대개는, `underscore`를 `camelize`의 반대기능으로 생각할 수 있습니다. 그러나, 이러한 규칙의 예외적인 상황이 있는데, 예를 들면, `"SSLError".underscore.camelize`는 `"SslError"` 값을 반환하게 됩니다. [[[As a rule of thumb you can think of `underscore` as the inverse of `camelize`, though there are cases where that does not hold. For example, `"SSLError".underscore.camelize` gives back `"SslError"`.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `titleize`

`titleize` 메소드는 receiver 단어들의 첫문자를 대문자로 만들어 줍니다. [[[The method `titleize` capitalizes the words in the receiver:]]]

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize`는 `titlecase`라는 이름으로도 사용할 수 있습니다. [[[`titleize` is aliased to `titlecase`.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `dasherize`

`dasherize` 메소드는 receiver 문자열내의 밑줄문자를 대시문자로 바꿔주는 기능을 합니다. [[[The method `dasherize` replaces the underscores in the receiver with dashes:]]]

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

모델에 대한 XML 시리얼라이저는 이 메소드를 이용하여 노드명을 변경하게 됩니다. [[[The XML serializer of models uses this method to dasherize node names:]]]

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `demodulize`

네임스페이스가 포함되어 있는 문자열에 `demodulize` 메소드를 사용하면, 가장 우측에 있는 상수명만 반환해 줍니다. [[[Given a string with a qualified constant name, `demodulize` returns the very constant name, that is, the rightmost part of it:]]]

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
```

예를 들어, 액티브레코드는 이 메소드를 이용하여 카운터 캐시로 사용하는 컬럼명을 산출해 냅니다. [[[Active Record for example uses this method to compute the name of a counter cache column:]]]

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

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `deconstantize`

네임스페이스가 포함된 상수 참조 표현식을 가지는 문자열에 `deconstantize` 메소드를 사용하면 가장 오른쪽 세그먼트를 제거한 상태의 네임스페이스만 남게 됩니다. [[[Given a string with a qualified constant reference expression, `deconstantize` removes the rightmost segment, generally leaving the name of the constant's container:]]]

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

예를 들어 액티브서포트는 `Module#qualified_const_set`에서 이 메소드를 이용합니다. [[[Active Support for example uses this method in `Module#qualified_const_set`:]]]

```ruby
def qualified_const_set(path, value)
  QualifiedConstUtils.raise_if_absolute(path)

  const_name = path.demodulize
  mod_name = path.deconstantize
  mod = mod_name.empty? ? self : qualified_const_get(mod_name)
  mod.const_set(const_name, value)
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `parameterize`

`parameterize` 메소드는 receiver 문자열을 URL에서 사용할 수 있도록 만들어 줍니다. [[[The method `parameterize` normalizes its receiver in a way that can be used in pretty URLs.]]]

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

사실, 결과로 만들어지는 문자열은 `ActiveSupport::Multibyte::Chars` 클래스의 인스턴스 형태를 띠게 됩니다. [[[In fact, the result string is wrapped in an instance of `ActiveSupport::Multibyte::Chars`.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `tableize`

`tableize` 메소드는 `underscore` 다음에 `pluralize` 메소드를 적용한 결과를 반환합니다. [[[The method `tableize` is `underscore` followed by `pluralize`.]]]

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

대개 `tableize` 메소드는 간단한 경우, 특정 모델로 연결되는 테이블명을 반환합니다. 그러나 액티브레코드에서는 직접 `tableize` 메소드를 구현하지 않는데, 클래스명에 `demodulize` 메소드를 적용한 후 몇가지 옵션을 처리하여 그에 따른 테이블명을 적절하게 만들어 주기 때문입니다. [[[As a rule of thumb, `tableize` returns the table name that corresponds to a given model for simple cases. The actual implementation in Active Record is not straight `tableize` indeed, because it also demodulizes the class name and checks a few options that may affect the returned string.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `classify`

`classify` 메소드는 `tableize` 메소드의 반대기능을 합니다. 이것은 테이블명에 해당하는 클래스명을 반환해 줍니다. [[[The method `classify` is the inverse of `tableize`. It gives you the class name corresponding to a table name:]]]

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

또한 이 메소드는 컨텍스트가 적용된 테이블명을 인식합니다. [[[The method understands qualified table names:]]]

```ruby
"highrise_production.companies".classify # => "Company"
```

주목할 것은 `classify` 메소드가 클래스명을 문자열로 반환해 준다는 것입니다. 따라서 실제 클래스 객체는 다음에 설명할 `constantize` 메소드를 적용해서 얻을 수 있습니다. [[[Note that `classify` returns a class name as a string. You can get the actual class object invoking `constantize` on it, explained next.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `constantize`

`constantize` 메소드는 receiver의 상수를 참조하는 표현식을 실체화해 줍니다. [[[The method `constantize` resolves the constant reference expression in its receiver:]]]

```ruby
"Fixnum".constantize # => Fixnum

module M
  X = 1
end
"M::X".constantize # => 1
```

receiver 문자열의 평가결과, 실존하는 상수가 아니거나 유효한 상수명이 아닌 경우 `NameError` 예외를 발생시킵니다. [[[If the string evaluates to no known constant, or its content is not even a valid constant name, `constantize` raises `NameError`.]]]

`constantize` 메소드에 의한 상수명의 실체화는 앞에 "::" 구분자가 없는 경우에도 항상 최상위 `Object`로부터 시작합니다. [[[Constant name resolution by `constantize` starts always at the top-level `Object` even if there is no leading "::".]]]

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

그렇기 때문에, 일반적으로는 동일한 시점에 루비가 작업하여 실제 상수가 평가가 되기 때문에 그 결과가 같지 않게 됩니다. [[[So, it is in general not equivalent to what Ruby would do in the same spot, had a real constant be evaluated.]]]

메일러에 대한 테스트 케이스는 메일러가 `constantize` 메소드를 이용하여 테스트 클래스로부터 검증되도록 합니다. [[[Mailer test cases obtain the mailer being tested from the name of the test class using `constantize`:]]]

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.sub(/Test$/, '').constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `humanize`

`humanize` 메소드는 모델 속성명으로부터 가독성있는 이름을 반환해 줍니다. 따라서 속성명내의 밑줄문자는 스페이스로 대체되고 속성명 끝의 "_id"는 제거되며 첫번째 단어는 첫문자가 대문자로 변환됩니다. [[[The method `humanize` gives you a sensible name for display out of an attribute name. To do so it replaces underscores with spaces, removes any "_id" suffix, and capitalizes the first word:]]]

```ruby
"name".humanize           # => "Name"
"author_id".humanize      # => "Author"
"comments_count".humanize # => "Comments count"
```

`full_messages` 헬퍼메소드는 속성명을 포함하기 위한 방법으로 `humanize` 메소드를 이용합니다. [[[The helper method `full_messages` uses `humanize` as a fallback to include attribute names:]]]

```ruby
def full_messages
  full_messages = []

  each do |attribute, messages|
    ...
    attr_name = attribute.to_s.gsub('.', '_').humanize
    attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
    ...
  end

  full_messages
end
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

#### `foreign_key`

`foreign_key` 메소드는 특정 클래스명으로부터 외부키 컬럼명을 만들어 줍니다. 따라서 receiver에 대해서 `demodulize`, `underscore` 메소드를 적용한 결과문자열 끝에 "_id"를 붙여 줍니다. [[[The method `foreign_key` gives a foreign key column name from a class name. To do so it demodulizes, underscores, and adds "_id":]]]

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

"_id" 에서 민줄문자를 제거하여 붙이고자 한다면 false 값을 넘겨 주면 됩니다. [[[Pass a false argument if you do not want the underscore in "_id":]]]

```ruby
"User".foreign_key(false) # => "userid"
```

모델간의 관계설정시 이 메소드를 이용하여 외부키를 추측하게 되는데, 예를 들어 `has_one`과 `has_many`의 경우 다음과 같이 구현합니다. [[[Associations use this method to infer foreign keys, for example `has_one` and `has_many` do this:]]]

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: 이 메소드는 `active_support/core_ext/string/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/inflections.rb`.]]]

### [Conversions] 변환 메소드

#### `to_date`, `to_time`, `to_datetime`

`to_date`, `to_time`, `to_datetime` 메소드는 기본적으로 `Date._parse`에 대한 사용상의 편의성을 제공해 줍니다. [[[The methods `to_date`, `to_time`, and `to_datetime` are basically convenience wrappers around `Date._parse`:]]]

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => Tue Jul 27 23:37:00 UTC 2010
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` 메소드는 `:utc` 또는 `:local` 옵션을 이용해서 원하는 시간대(타임존)를 지정할 수 있습니다. [[[`to_time` receives an optional argument `:utc` or `:local`, to indicate which time zone you want the time in:]]]

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => Tue Jul 27 23:42:00 UTC 2010
"2010-07-27 23:42:00".to_time(:local) # => Tue Jul 27 23:42:00 +0200 2010
```

디폴트 옵션은 `:utc`입니다. [[[Default is `:utc`.]]]

더 자세한 내용은 `Date._parse` 문서를 참조하기 바랍니다. [[[Please refer to the documentation of `Date._parse` for further details.]]]

INFO: receiver가 `blank` 인 경우에는 `nil` 값을 반환합니다. [[[The three of them return `nil` for blank receivers.]]]

NOTE: 이 메소드는 `active_support/core_ext/string/conversions.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/string/conversions.rb`.]]]

[Extensions to `Numeric`] `Numeric`형에 대한 확장 메소드
-----------------------

### Bytes

모든 숫자는 다음의 메소드에 반응합니다. [[[All numbers respond to these methods:]]]

```ruby
bytes
kilobytes
megabytes
gigabytes
terabytes
petabytes
exabytes
```

이 메소드들은 1024 변환인자에 근거해서 바이트 크기로 반환합니다. [[[They return the corresponding amount of bytes, using a conversion factor of 1024:]]]

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384
-4.exabytes   # => -4611686018427387904
```

단수형도 가능해서 다음과 같이 사용할 수 있습니다. [[[Singular forms are aliased so you are able to say:]]]

```ruby
1.megabyte # => 1048576
```

NOTE: 이 메소드는 `active_support/core_ext/numeric/bytes.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/numeric/bytes.rb`.]]]

### Time

`45.minutes + 2.hours + 4.years`과 같이 시간계산과 선언이 가능합니다. [[[Enables the use of time calculations and declarations, like `45.minutes + 2.hours + 4.years`.]]]

이 메소드들은 Time#advance를 이용해서 from_now, ago 등과 같은 메소드 뿐만 아니라 Time객체로부터 계산 결과를 더하거나 빼기를 하여 정확한 날짜 계산을 가능케 합니다. [[[These methods use Time#advance for precise date calculations when using from_now, ago, etc. as well as adding or subtracting their results from a Time object. For example:]]]

```ruby
# Time.current.advance(months: 1)와 동일함
1.month.from_now

# Time.current.advance(years: 2)와 동일함
2.years.from_now

# Time.current.advance(months: 4, years: 5)와 동일함
(4.months + 5.years).from_now
```

이 메소드들은 위와 같이 사용될 때 정확한 계산을 하게 되지만, 주의해야 할 것은, 사용전에 `months`, `years` 등의 결과가 변환된다면 정확성이 떨어지게 된다는 것입니다. [[[While these methods provide precise calculation when used as in the examples above, care should be taken to note that this is not true if the result of `months`, `years`, etc is converted before use:]]]

```ruby
# 30.days.to_i.from_now와 동일함.
1.month.to_i.from_now

# 365.25.days.to_f.from_now와 동일함.
1.year.to_f.from_now
```

이런 경우에는, 루비 코어 [Date](http://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html)와 [Time](http://ruby-doc.org/stdlib/libdoc/time/rdoc/Time.html)을 이용해서 정확한 날짜와 시간 연산을 해야 합니다. [[[In such cases, Ruby's core [Date](http://ruby-doc.org/stdlib/libdoc/date/rdoc/Date.html) and [Time](http://ruby-doc.org/stdlib/libdoc/time/rdoc/Time.html) should be used for precision date and time arithmetic.]]]

NOTE: 이 메소드는 `active_support/core_ext/numeric/time.rb` 파일내에 정의되어 있습니다.  [[[Defined in `active_support/core_ext/numeric/time.rb`.]]]

### [Formatting] 숫자의 포맷변환

이것은 다양한 방법으로 숫자의 표시형태를 달리할 수 있게 해 줍니다. [[[Enables the formatting of numbers in a variety of ways.]]]
임의의 숫자를 전화번호 포맷의 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number as a telephone number:]]]

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

임의의 숫자를 통화 포맷의 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number as currency:]]]

```ruby
1234567890.50.to_s(:currency)                 # => $1,234,567,890.50
1234567890.506.to_s(:currency)                # => $1,234,567,890.51
1234567890.506.to_s(:currency, precision: 3)  # => $1,234,567,890.506
```

임의의 숫자를 퍼센트 포맷의 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number as a percentage:]]]

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

임의의 숫자를 구분자 포맷의 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number in delimited form:]]]

```ruby
12345678.to_s(:delimited)                     # => 12,345,678
12345678.05.to_s(:delimited)                  # => 12,345,678.05
12345678.to_s(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_s(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_s(:delimited, separator: " ")  # => 12,345,678 05
```

임의의 숫자를 정밀도에 따라 반올림해서 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number rounded to a precision:]]]

```ruby
111.2345.to_s(:rounded)                     # => 111.235
111.2345.to_s(:rounded, precision: 2)       # => 111.23
13.to_s(:rounded, precision: 5)             # => 13.00000
389.32314.to_s(:rounded, precision: 0)      # => 389
111.2345.to_s(:rounded, significant: true)  # => 111
```

임의의 숫자를 바이트 단위의 가독성 있는 숫자 포맷의 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number as a human-readable number of bytes:]]]

```ruby
123.to_s(:human_size)            # => 123 Bytes
1234.to_s(:human_size)           # => 1.21 KB
12345.to_s(:human_size)          # => 12.1 KB
1234567.to_s(:human_size)        # => 1.18 MB
1234567890.to_s(:human_size)     # => 1.15 GB
1234567890123.to_s(:human_size)  # => 1.12 TB
```

임의의 숫자를 가독성 있도록 문자열로 반환해 줄 수 있습니다. [[[Produce a string representation of a number in human-readable words:]]]

```ruby
123.to_s(:human)               # => "123"
1234.to_s(:human)              # => "1.23 Thousand"
12345.to_s(:human)             # => "12.3 Thousand"
1234567.to_s(:human)           # => "1.23 Million"
1234567890.to_s(:human)        # => "1.23 Billion"
1234567890123.to_s(:human)     # => "1.23 Trillion"
1234567890123456.to_s(:human)  # => "1.23 Quadrillion"
```

NOTE: 이 메소드는 `active_support/core_ext/numeric/formatting.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/numeric/formatting.rb`.]]]

[Extensions to `Integer`] `Integer`형에 대한 확장 메소드
-----------------------

### `multiple_of?`

`multiple_of?` 메소드는 임의의 정수가 인수에 대한 배수인지를 알려 줍니다. [[[The method `multiple_of?` tests whether an integer is multiple of the argument:]]]

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: 이 메소드는 `active_support/core_ext/integer/multiple.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/integer/multiple.rb`.]]]

### `ordinal`

`ordinal` 메소드는 receiver가 정수인 경우 그에 해당하는 서수 접미 문자열을 반환합니다. [[[The method `ordinal` returns the ordinal suffix string corresponding to the receiver integer:]]]

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: 이 메소드는 `active_support/core_ext/integer/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/integer/inflections.rb`.]]]

### `ordinalize`

`ordinalize` 메소드는 receiver 정수에 해당하는 서수 문자열을 반환해 줍니다. 비교해 보면, `ordinal` 메소드는 **단지** 서수 접미 문자열만 반환한다는 것입니다. [[[The method `ordinalize` returns the ordinal string corresponding to the receiver integer. In comparison, note that the `ordinal` method returns **only** the suffix string.]]]

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: 이 메소드는 `active_support/core_ext/integer/inflections.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/integer/inflections.rb`.]]]

[Extensions to `BigDecimal`] `BigDecimal`형에 대한 확장 메소드
--------------------------

...

[Extensions to `Enumerable`] `Enumerable`형에 대한 확장 메소드
--------------------------

### `sum`

`sum` 메소드는 열거형 객체의 각요소들을 합산해 줍니다. [[[The method `sum` adds the elements of an enumerable:]]]

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

이 메소드는 각 요소들이 `+` 메소드에 대해서 반응을 보여야 하는 것으로 간주 합니다. [[[Addition only assumes the elements respond to `+`:]]]

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{a: 1, b: 2, c: 3}.sum # => [:b, 2, :c, 3, :a, 1]
```

빈 컬렉션의 합산은 디폴트로 0이지만, 이 값을 변경할 수 있습니다. [[[The sum of an empty collection is zero by default, but this is customizable:]]]

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

코드블록을 넘겨 받는 경우, `sum` 메소드는 반복연산자가 되어 컬렉션의 각요소에 대해서 블록 실행결과를 합한 값을 반환하게 됩니다. [[[If a block is given, `sum` becomes an iterator that yields the elements of the collection and sums the returned values:]]]

```ruby
(1..5).sum {|n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

아무런 값이 없는 비어있는 receiver에 대한 합산은 또한 다음과 같이 변경할 수 있습니다. [[[The sum of an empty receiver can be customized in this form as well:]]]

```ruby
[].sum(1) {|n| n**3} # => 1
```

NOTE: 이 메소드는 `active_support/core_ext/enumerable.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/enumerable.rb`.]]]

### `index_by`

`index_by` 메소드는 열거형 receiver의 각 요소를 임의의 키로 인덱싱하여 해시를 생성해 줍니다. [[[The method `index_by` generates a hash with the elements of an enumerable indexed by some key.]]]

이 메소드는 receiver 컬렉션의 각요소를 반복해서 블록으로 넘겨 줍니다. 이 때 반환되는 해시의 각 요소는 블록에서 반환하는 값을 키로 사용하게 됩니다. [[[It iterates through the collection and passes each element to a block. The element will be keyed by the value returned by the block:]]]

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

WARNING. 키들은 일반적으로 유일해야 합니다. 블록이 각기 다른 요소에 대해서 동일한 키 값을 반환하다면 해당 키에 대해서 또 다시 컬렉션이 생성되지 않을 것입니다. [[[Keys should normally be unique. If the block returns the same value for different elements no collection is built for that key. The last item will win.]]]

NOTE: 이 메소드는 `active_support/core_ext/enumerable.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/enumerable.rb`.]]]

### `many?`

`many?` 메소드는 `collection.size > 1`에 대한 단축형으로 생각하면 됩니다. [[[The method `many?` is shorthand for `collection.size > 1`:]]]

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

옵션으로 블록이 주어지면, 블록연산에서 true값을 반환하는 요소만을 카운트하게 됩니다. [[[If an optional block is given, `many?` only takes into account those elements that return true:]]]

```ruby
@see_more = videos.many? {|video| video.category == params[:category]}
```

NOTE: 이 메소드는 `active_support/core_ext/enumerable.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/enumerable.rb`.]]]

### `exclude?`

`exclude?` 메소드는 특정 객체가 receiver 컬렉션에 포함되지 **않았음**을 확인해 줍니다. 이것은 `include?` 메소드의 반대되는 기능입니다. [[[The predicate `exclude?` tests whether a given object does **not** belong to the collection. It is the negation of the built-in `include?`:]]]

```ruby
to_visit << node if visited.exclude?(node)
```

NOTE: 이 메소드는 `active_support/core_ext/enumerable.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/enumerable.rb`.]]]

[Extensions to `Array`] `Array`형에 대한 확장 메소드
---------------------

### [Accessing] 접근하기

액티브서포트는 배열에 대한 접근법을 용이하게 하기 위해 배열 API의 기능을 보강해 줍니다. 예를 들면, `to` 메소드는 넘겨준 값의 위치에 있는 요소까지의 배열일부를 반환해 줍니다. [[[Active Support augments the API of arrays to ease certain ways of accessing them. For example, `to` returns the subarray of elements up to the one at the passed index:]]]

```ruby
%w(a b c d).to(2) # => %w(a b c)
[].to(7)          # => []
```

비슷한 방법으로, `from` 메소드는 넘겨준 값의 위치에 있는 요소부터 마지막 요소까지를 반환해 줍니다. 넘겨 준 값이 배열 길이보다는 큰 경우에는 빈 배열을 반환하게 됩니다. [[[Similarly, `from` returns the tail from the element at the passed index to the end. If the index is greater than the length of the array, it returns an empty array.]]]

```ruby
%w(a b c d).from(2)  # => %w(c d)
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

확장 메소드인 `second`, `third`, `fourth`, `fifth`는 해당하는 요소를 반환해 주게 됩니다. 참고로 `first`는 루비의 내장 메소드입니다. 이를 바탕으로 `forty_two` 또한 가능하게 정의할 수 있습니다. [[[The methods `second`, `third`, `fourth`, and `fifth` return the corresponding element (`first` is built-in). Thanks to social wisdom and positive constructiveness all around, `forty_two` is also available.]]]

```ruby
%w(a b c d).third # => c
%w(a b c d).fifth # => nil
```

NOTE: 이 메소드는 `active_support/core_ext/array/access.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/access.rb`.]]]

### [Adding Elements] 배열요소 추가하기

#### `prepend`

이 메소드는 `Array#unshift`의 별칭 메소드입니다. [[[This method is an alias of `Array#unshift`.]]]

```ruby
%w(a b c d).prepend('e')  # => %w(e a b c d)
[].prepend(10)            # => [10]
```

NOTE: 이 메소드는 `active_support/core_ext/array/prepend_and_append.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/prepend_and_append.rb`.]]]

#### `append`

이 메소드는 `Array#<<`의 별칭 메소드입니다. [[[This method is an alias of `Array#<<`.]]]

```ruby
%w(a b c d).append('e')  # => %w(a b c d e)
[].append([1,2])         # => [[1,2]]
```

NOTE: 이 메소드는 `active_support/core_ext/array/prepend_and_append.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/prepend_and_append.rb`.]]]

### [Options Extraction] 옵션 추출하기

메소드 호출시 마지막 인수가 `&block` 인수가 아닌 해시인 경우, 브래킷 `{}`을 생략할 수 있습니다. [[[When the last argument in a method call is a hash, except perhaps for a `&block` argument, Ruby allows you to omit the brackets:]]]

```ruby
User.exists?(email: params[:email])
```

이러한 문법상의 달콤함은 레일스에서 많이 사용되고 있는데, 이것은 메소드로 넘겨주는 인수가 너무 많은 경우 정확한 위치에 해당 인수를 넘겨 주는 것이 힘들게 되어 대신에 파라메터에 이름을 붙여서 사용(named parameters)할 수 있도록 인터페이스를 제공해 주기 위함입니다. 특히나, 옵션을 해시 형태로 사용하는 것은 매우 흔한 일입니다. [[[That syntactic sugar is used a lot in Rails to avoid positional arguments where there would be too many, offering instead interfaces that emulate named parameters. In particular it is very idiomatic to use a trailing hash for options.]]]

메소드의 인수의 갯수가 유동적일 경우에는 메소드 인수 선언시에 `*`를 사용합니다. 그러나, 인수 배열의 마지막 항목으로 해시형태의 옵션을 지정할 때는 제대로 작동하지 않게 됩니다. [[[If a method expects a variable number of arguments and uses `*` in its declaration, however, such an options hash ends up being an item of the array of arguments, where it loses its role.]]]

이 때는 옵션 해시에 대해서 `extract_options!` 메소드로 처리해 주면 됩니다. 이 메소드는 배열의 마지막 요소를 점검하여 그것이 해시이면 꺼내서 반환해 주고 그렇지 않으면 빈 해시를 반환해 줍니다. [[[In those cases, you may give an options hash a distinguished treatment with `extract_options!`. This method checks the type of the last item of an array. If it is a hash it pops it and returns it, otherwise it returns an empty hash.]]]

예를 들어 `caches_action` 컨트롤러 매크로의 정의를 살펴 봅시다. [[[Let's see for example the definition of the `caches_action` controller macro:]]]

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  ...
end
```

이 메소드는 액션명을 임의의 갯수만큼 받게되며, 마지막 인수를 해시형태로 취하게 됩니다. `extract_options!`을 호출하게 되면, 옵션 해시를 취해서 간단하고도 명료하게 `actions`에서 빼내서 `options`에 할당하게 됩니다. [[[This method receives an arbitrary number of action names, and an optional hash of options as last argument. With the call to `extract_options!` you obtain the options hash and remove it from `actions` in a simple and explicit way.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/extract_options.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/extract_options.rb`.]]]

### [Conversions] 변환하기

#### `to_sentence`

`to_sentence` 메소드는 배열을 취해서 각 요소들을 열거하는 문자열로 변환해 줍니다. [[[The method `to_sentence` turns an array into a string containing a sentence that enumerates its items:]]]

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

이 메소드는 3가지 옵션을 가집니다. [[[This method accepts three options:]]]

* `:two_words_connector`: 배열의 길이가 2인 경우 사용하며 디폴트는 " and " 입니다. [[[What is used for arrays of length 2. Default is " and ".]]]

* `:words_connector`: 배열의 길이가 2이상인 경우 사용하며 마지막 2개의 요소에 대해서는 적용하지 않습니다. 디폴트는 ", " 입니다. [[[What is used to join the elements of arrays with 3 or more elements, except for the last two. Default is ", ".]]]

* `:last_word_connector`: 배열의 길이가 2이상인 경우 사용하며 마지막 요소들을 연결하기 위해서 사용합니다. 디폴트는 ", and " 입니다. [[[What is used to join the last items of an array with 3 or more elements. Default is ", and ".]]]

이 옵션의 디폴트 값에 로케일을 적용할 수도 있는데, 해당 로케일 키는 아래와 같습니다. [[[The defaults for these options can be localized, their keys are:]]]

| 옵션                    | I18n 키                              |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

`:connector`와 `:skip_last_comma` 옵션은 더 이상 사용되지 않습니다. [[[Options `:connector` and `:skip_last_comma` are deprecated.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/conversions.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/conversions.rb`.]]]

#### `to_formatted_s`

`to_formatted_s` 메소드는 디폴트로 `to_s`와 같이 동작합니다. [[[The method `to_formatted_s` acts like `to_s` by default.]]]

그러나 배열이 `id` 값을 얻을 수 있는 요소를 포함할 경우에는 `:db` 심볼을 인수로 넘겨 줄 수 있습니다. 이것은 대개 액티브레코드 객체들의 컬렉션에 대해서 사용하며 반환되는 문자열은 아래와 같습니다. [[[If the array contains items that respond to `id`, however, the symbol `:db` may be passed as argument. That's typically used with collections of ActiveRecord objects. Returned strings are:]]]

```ruby
[].to_formatted_s(:db)            # => "null"
[user].to_formatted_s(:db)        # => "8456"
invoice.lines.to_formatted_s(:db) # => "23,567,556,12"
```

위의 예에서 정수는 배열 각 요소에 대해서 `id`를 호출시에 반환되는 값이다. [[[Integers in the example above are supposed to come from the respective calls to `id`.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/conversions.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/conversions.rb`.]]]

#### `to_xml`

`to_xml` 메소드는 receiver객체의 XML형 출력 문자열을 반환해 줍니다. [[[The method `to_xml` returns a string containing an XML representation of its receiver:]]]

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

이를 위해서, 모든 배열요소에 차례대로 `to_xml` 메소드를 호출하여 루트 노드에 결과들을 모아 둡니다. 모든 요소는 `to_xml`을 호출할 수 있어야 하며 그렇지 않을 경우에는 예외를 발생시킵니다. [[[To do so it sends `to_xml` to every item in turn, and collects the results under a root node. All items must respond to `to_xml`, an exception is raised otherwise.]]]

디폴트로, 루트 요소의 이름은 나머지 요소들도 같은 데이터형에 속하고(`is_a?` 호출로 확인하여) 해시형이 아닐 때, 첫번째 요소의 클래스명에 대해서 `underscore`, `dasherize`, `pluralize` 메소드를 적용하여 결정됩니다. 위의 예에서는 "contributors"가 되겠습니다. [[[By default, the name of the root element is the underscorized and dasherized plural of the name of the class of the first item, provided the rest of elements belong to that type (checked with `is_a?`) and they are not hashes. In the example above that's "contributors".]]]

나머지 요소 중 첫번째 요소의 데이터형과 일치하지 않는 것이 있을 경우에는, 루트 노드명은 "objects"가 됩니다. [[[If there's any element that does not belong to the type of the first one the root node becomes "objects":]]]

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

또한 receiver객체가 해시의 배열형태로 되어 있는 경우에도 루트 노드명은 "objects"가 됩니다. [[[If the receiver is an array of hashes the root element is by default also "objects":]]]

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

WARNING. 컬렉션이 비어있을 경우에 루트 요소의 이름은 디폴트 값인 "nil-classes"가 됩니다. 미루어 알 수 있듯이, 예를 들어 contributors 목록의 루트 요소는 컬렉션이 비어있을 경우 "contributors" 가 아니고 "nil-classes" 가 되는 것입니다. 또한 `:root` 옵션을 사용할 경우 루트 노트를 일관성있게 유지할 수 있게 됩니다. [[[If the collection is empty the root element is by default "nil-classes". That's a gotcha, for example the root element of the list of contributors above would not be "contributors" if the collection was empty, but "nil-classes". You may use the `:root` option to ensure a consistent root element.]]]

자식 노드의 이름은 디폴트로 루트 노드의 단수형이 됩니다. 위의 예에서, "contributor"와 "object"를 볼 수 있습니다. `:children` 옵션은 이와 같은 자식 노드의 이름을 설정할 수 있게 해 줍니다. [[[The name of children nodes is by default the name of the root node singularized. In the examples above we've seen "contributor" and "object". The option `:children` allows you to set these node names.]]]

디폴트 XML 빌더는 `Builder::XmlMarkup`의 인스턴스 객체가 됩니다. `:builder` 옵션을 이용하면 이러한 빌더의 기능을 변경할 수 있습니다. 또한 `:dasherize` 등과 같은 옵션을 사용할 수 있으며 해당 빌더로 전달 되기도 합니다. [[[The default XML builder is a fresh instance of `Builder::XmlMarkup`. You can configure your own builder via the `:builder` option. The method also accepts options like `:dasherize` and friends, they are forwarded to the builder:]]]

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

NOTE: 이 메소드는 `active_support/core_ext/array/conversions.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/conversions.rb`.]]]

### Wrapping

`Array.wrap` 메소드는 인수가 배열(또는 배열류)이 아닌 경우 배열로 감싸 줍니다. [[[The method `Array.wrap` wraps its argument in an array unless it is already an array (or array-like).]]]

특히, [[[Specifically:]]]

* 인수가 `nil`이면 빈 목록이 반환됩니다. [[[If the argument is `nil` an empty list is returned.]]]

* 그렇지 않을 경우,  인수가 `to_ary`에 반응한다면 호출되고 `to_ary`의 결과값이 `nil`이 아닐 경우에는 그것이 반환됩니다. [[[Otherwise, if the argument responds to `to_ary` it is invoked, and if the value of `to_ary` is not `nil`, it is returned.]]]

* 그외의 인자가 있는 경우는 그것을 하나의 요소로 가지는 배열이 반환됩니다. [[[Otherwise, an array with the argument as its single element is returned.]]]

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

이 메소드는 기능적으로는 `Kernel#Array`와 비슷하지만, 약간의 차이점이 있습니다. [[[This method is similar in purpose to `Kernel#Array`, but there are some differences:]]]

* 인수가 `to_ary`에 반응을 할 경우 메소드가 호출된다는 것입니다. `Kernel#Array`은 반환값이 `nil`일 경우 계속해서 `to_a`를 호출할 것이지만, `Array.wrap`은 즉시 `nil`값을 반환합니다. [[[If the argument responds to `to_ary` the method is invoked. `Kernel#Array` moves on to try `to_a` if the returned value is `nil`, but `Array.wrap` returns `nil` right away.]]]

* `to_ary`가 반환하는 값이 `nil`이 아니거나 `Array` 객체가 아니라면, `Kernel#Array`은 예외를 발생시키는 반면, `Array.wrap`은 반대로 단지 값만 반환하게 됩니다. [[[If the returned value from `to_ary` is neither `nil` nor an `Array` object, `Kernel#Array` raises an exception, while `Array.wrap` does not, it just returns the value.]]]

* 빈 배열을 반환하기 위해 특별한 경우 `nil`인 경우가 있긴 하지만, 인수에 대해서 `to_a`를 호출하지 않습니다. [[[It does not call `to_a` on the argument, though special-cases `nil` to return an empty array.]]]

마지막 것은 열거형에 대해서 특별히 비교할 만한 가치가 있습니다. [[[The last point is particularly worth comparing for some enumerables:]]]

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

또한 splat 연산자를 사용하는 연관 용어도 있습니다. [[[There's also a related idiom that uses the splat operator:]]]

```ruby
[*object]
```

이것은 루비 1.8에서 `nil`에 대해서 `[nil]`을 반환하고 그렇지 않으면 `Array(object)`를 호출합니다. (루비 1.9에서 정확한 기능을 알고 있다면 연락 주시기 바랍니다.) [[[which in Ruby 1.8 returns `[nil]` for `nil`, and calls to `Array(object)` otherwise. (Please if you know the exact behavior in 1.9 contact fxn.)]]]

따라서, 이와 같은 경우에, `nil`에 대해서 각기 다르게 동작한다는 것이고, 위의 언급한 바와 같이 `Kernel#Array`에서의 차이점은 `object`에 대해서도 적용하게 됩니다. [[[Thus, in this case the behavior is different for `nil`, and the differences with `Kernel#Array` explained above apply to the rest of `object`s.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/wrap.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/wrap.rb`.]]]

### [Duplicating] 복제하기

`Array.deep_dup` 메소드는 자신과 내부에 있는 모든 객체를 액티브서포트 메소드인 `Object#deep_dup`를 이용하여 재귀적 복제를 합니다. 배열 내부에 있는 각 객체에 대해서 `deep_dup`메소드를 적용하여 마치 `Array#map` 처럼 동작합니다. [[[The method `Array.deep_dup` duplicates itself and all objects inside recursively with ActiveSupport method `Object#deep_dup`. It works like `Array#map` with sending `deep_dup` method to each object inside.]]]

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTE: 이 메소드는 `active_support/core_ext/array/deep_dup.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/deep_dup.rb`.]]]

### Grouping

#### `in_groups_of(number, fill_with = nil)`

`in_groups_of` 메소드는 넘겨 준 크기 만큼씩 배열 요소를 분리해서 그룹화해 줍니다. 이 메소드는 그룹을 가진 배열을 반환해 줍니다. [[[The method `in_groups_of` splits an array into consecutive groups of a certain size. It returns an array with the groups:]]]

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

또는 블록을 넘겨 주게 되면 그룹 크기만큼씩 차례대로 처리하게 됩니다. [[[or yields them in turn if a block is passed:]]]

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

첫번째 예에서는 `in_groups_of`가 마지막 그룹을 요청된 크기보다 모자라는 만큼의 `nil`요소로 채워 줍니다. 이렇게 채워주는 값을 두번째 옵션을 지정하여 변경할 수 있습니다. [[[The first example shows `in_groups_of` fills the last group with as many `nil` elements as needed to have the requested size. You can change this padding value using the second optional argument:]]]

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

그리고 또한 두번째 옵션으로 `false`를 지정하면 마지막 그룹에서 모자라는 부분을 채우지 않도록 할 수 있습니다. [[[And you can tell the method not to fill the last group passing `false`:]]]

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

따라서, `false` 값은 마지막 그룹의 모자라는 요소를 채워주는 값으로 사용할 수 없다는 결론입니다. [[[As a consequence `false` can't be a used as a padding value.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/grouping.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/grouping.rb`.]]]

#### `in_groups(number, fill_with = nil)`

`in_groups` 메소드는 배열을 지정한 갯수만큼의 그룹으로 분리합니다. 이 메소드는 그룹을 가진 배열을 반환합니다. [[[The method `in_groups` splits an array into a certain number of groups. The method returns an array with the groups:]]]

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

또는 블록을 넘겨주면 각 그룹에 대해서 차례대로 코드를 처리할 수 있습니다.[[[or yields them in turn if a block is passed:]]]

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) {|group| p group}
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

위의 예에서는 `in_groups` 메소드가 필요한 수만큼의 `nil` 요소로 그룹을 채워 줍니다. 하나의 그룹은 기껏해야 마직막 요소로 하나의 채움값을 가질 수 있습니다. 그리고 채움값을 가지는 그룹은 항상 마지막에 위치합니다. [[[The examples above show that `in_groups` fills some groups with a trailing `nil` element as needed. A group can get at most one of these extra elements, the rightmost one if any. And the groups that have them are always the last ones.]]]

두번째 옵션을 이용하면 그룹을 채우는 값을 변경할 수 있습니다.[[[You can change this padding value using the second optional argument:]]]

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

그리고 두번째 옵션으로 `false` 값을 넘겨 주면 그룹의 빈 요소를 채우지 않도록 할 수 있습니다. [[[And you can tell the method not to fill the smaller groups passing `false`:]]]

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

따라서 `false` 값은 채우는 값으로 사용할 수 없다는 결론입니다. [[[As a consequence `false` can't be a used as a padding value.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/grouping.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/grouping.rb`.]]]

#### `split(value = nil)`

`split` 메소드는 분리자로 배열을 나누어 줍니다. [[[The method `split` divides an array by a separator and returns the resulting chunks.]]]

블록이 넘어 올 경우에는, 분리자는 블록 수행결과 true 값을 반환하는 배열요소가 됩니다. [[[If a block is passed the separators are those elements of the array for which the block returns true:]]]

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

그 외에는 값을 인수로 받게 되는데, 디폴트값은 `nil`이며, 이 값이 분리자가 되는 것입니다. [[[Otherwise, the value received as argument, which defaults to `nil`, is the separator:]]]

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

TIP: 이전 예여서 주목해서 볼 것은 연속되는 구분자는 빈 배열을 반환하게 된다는 것입니다. [[[Observe in the previous example that consecutive separators result in empty arrays.]]]

NOTE: 이 메소드는 `active_support/core_ext/array/grouping.rb` 파일내에 정의되어 있습니다. [[[Defined in `active_support/core_ext/array/grouping.rb`.]]]

[Extensions to `Hash`] `Hash`형에 대한 확장 메소드
--------------------

### [Conversions] 해시 변환메소드

#### `to_xml`

`to_xml` 메소드는 receiver 해시를 XML로 변환하여 문자열로 반환합니다. [[[The method `to_xml` returns a string containing an XML representation of its receiver:]]]

```ruby
{"foo" => 1, "bar" => 2}.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

이를 위해서는, 메소드는 해시내 키/값 들에 대해서 루프를 돌면서 _value_ 에 따라 노드를 만들게 됩니다. `key`, `value` 쌍이 주어질 경우, [[[To do so, the method loops over the pairs and builds nodes that depend on the _values_. Given a pair `key`, `value`:]]]

* `value`가 해시인 경우에는 `key`를 `:root`로 하여 이 메소드를 반복호출하게 됩니다. [[[If `value` is a hash there's a recursive call with `key` as `:root`.]]]

* `value`가 배열인 경우에는 `key`를 `:root`로 하여 이 메소드를 반복호출하게 되며, 이 때 `key`는 `:children`으로 단수형을 취하게 됩니다. [[[If `value` is an array there's a recursive call with `key` as `:root`, and `key` singularized as `:children`.]]]

* [[[If `value` is a callable object it must expect one or two arguments. Depending on the arity, the callable is invoked with the `options` hash as first argument with `key` as `:root`, and `key` singularized as second argument. Its return value becomes a new node.]]]

* If `value` responds to `to_xml` the method is invoked with `key` as `:root`.

* Otherwise, a node with `key` as tag is created with a string representation of `value` as text node. If `value` is `nil` an attribute "nil" set to "true" is added. Unless the option `:skip_types` exists and is true, an attribute "type" is added as well according to the following mapping:

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

By default the root node is "hash", but that's configurable via the `:root` option.

The default XML builder is a fresh instance of `Builder::XmlMarkup`. You can configure your own builder with the `:builder` option. The method also accepts options like `:dasherize` and friends, they are forwarded to the builder.

NOTE: Defined in `active_support/core_ext/hash/conversions.rb`.

### Merging

Ruby has a built-in method `Hash#merge` that merges two hashes:

```ruby
{a: 1, b: 1}.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support defines a few more ways of merging hashes that may be convenient.

#### `reverse_merge` and `reverse_merge!`

In case of collision the key in the hash of the argument wins in `merge`. You can support option hashes with default values in a compact way with this idiom:

```ruby
options = {length: 30, omission: "..."}.merge(options)
```

Active Support defines `reverse_merge` in case you prefer this alternative notation:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

And a bang version `reverse_merge!` that performs the merge in place:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

WARNING. Take into account that `reverse_merge!` may change the hash in the caller, which may or may not be a good idea.

NOTE: Defined in `active_support/core_ext/hash/reverse_merge.rb`.

#### `reverse_update`

The method `reverse_update` is an alias for `reverse_merge!`, explained above.

WARNING. Note that `reverse_update` has no bang.

NOTE: Defined in `active_support/core_ext/hash/reverse_merge.rb`.

#### `deep_merge` and `deep_merge!`

As you can see in the previous example if a key is found in both hashes the value in the one in the argument wins.

Active Support defines `Hash#deep_merge`. In a deep merge, if a key is found in both hashes and their values are hashes in turn, then their _merge_ becomes the value in the resulting hash:

```ruby
{a: {b: 1}}.deep_merge(a: {c: 2})
# => {:a=>{:b=>1, :c=>2}}
```

The method `deep_merge!` performs a deep merge in place.

NOTE: Defined in `active_support/core_ext/hash/deep_merge.rb`.

### Deep duplicating

The method `Hash.deep_dup` duplicates itself and all keys and values inside recursively with ActiveSupport method `Object#deep_dup`. It works like `Enumerator#each_with_object` with sending `deep_dup` method to each pair inside.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: Defined in `active_support/core_ext/hash/deep_dup.rb`.

### Diffing

The method `diff` returns a hash that represents a diff of the receiver and the argument with the following logic:

* Pairs `key`, `value` that exist in both hashes do not belong to the diff hash.

* If both hashes have `key`, but with different values, the pair in the receiver wins.

* The rest is just merged.

```ruby
{a: 1}.diff(a: 1)
# => {}, first rule

{a: 1}.diff(a: 2)
# => {:a=>1}, second rule

{a: 1}.diff(b: 2)
# => {:a=>1, :b=>2}, third rule

{a: 1, b: 2, c: 3}.diff(b: 1, c: 3, d: 4)
# => {:a=>1, :b=>2, :d=>4}, all rules

{}.diff({})        # => {}
{a: 1}.diff({})    # => {:a=>1}
{}.diff(a: 1)      # => {:a=>1}
```

An important property of this diff hash is that you can retrieve the original hash by applying `diff` twice:

```ruby
hash.diff(hash2).diff(hash2) == hash
```

Diffing hashes may be useful for error messages related to expected option hashes for example.

NOTE: Defined in `active_support/core_ext/hash/diff.rb`.

### Working with Keys

#### `except` and `except!`

The method `except` returns a hash with the keys in the argument list removed, if present:

```ruby
{a: 1, b: 2}.except(:a) # => {:b=>2}
```

If the receiver responds to `convert_key`, the method is called on each of the arguments. This allows `except` to play nice with hashes with indifferent access for instance:

```ruby
{a: 1}.with_indifferent_access.except(:a)  # => {}
{a: 1}.with_indifferent_access.except("a") # => {}
```

There's also the bang variant `except!` that removes keys in the very receiver.

NOTE: Defined in `active_support/core_ext/hash/except.rb`.

#### `transform_keys` and `transform_keys!`

The method `transform_keys` accepts a block and returns a hash that has applied the block operations to each of the keys in the receiver:

```ruby
{nil => nil, 1 => 1, a: :a}.transform_keys{ |key| key.to_s.upcase }
# => {"" => nil, "A" => :a, "1" => 1}
```

The result in case of collision is undefined:

```ruby
{"a" => 1, a: 2}.transform_keys{ |key| key.to_s.upcase }
# => {"A" => 2}, in my test, can't rely on this result though
```

This method may be useful for example to build specialized conversions. For instance `stringify_keys` and `symbolize_keys` use `transform_keys` to perform their key conversions:

```ruby
def stringify_keys
  transform_keys{ |key| key.to_s }
end
...
def symbolize_keys
  transform_keys{ |key| key.to_sym rescue key }
end
```

There's also the bang variant `transform_keys!` that applies the block operations to keys in the very receiver.

Besides that, one can use `deep_transform_keys` and `deep_transform_keys!` to perform the block operation on all the keys in the given hash and all the hashes nested into it. An example of the result is:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_transform_keys{ |key| key.to_s.upcase }
# => {""=>nil, "1"=>1, "NESTED"=>{"A"=>3, "5"=>5}}
```

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

#### `stringify_keys` and `stringify_keys!`

The method `stringify_keys` returns a hash that has a stringified version of the keys in the receiver. It does so by sending `to_s` to them:

```ruby
{nil => nil, 1 => 1, a: :a}.stringify_keys
# => {"" => nil, "a" => :a, "1" => 1}
```

The result in case of collision is undefined:

```ruby
{"a" => 1, a: 2}.stringify_keys
# => {"a" => 2}, in my test, can't rely on this result though
```

This method may be useful for example to easily accept both symbols and strings as options. For instance `ActionView::Helpers::FormHelper` defines:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  ...
end
```

The second line can safely access the "type" key, and let the user to pass either `:type` or "type".

There's also the bang variant `stringify_keys!` that stringifies keys in the very receiver.

Besides that, one can use `deep_stringify_keys` and `deep_stringify_keys!` to stringify all the keys in the given hash and all the hashes nested into it. An example of the result is:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

#### `symbolize_keys` and `symbolize_keys!`

The method `symbolize_keys` returns a hash that has a symbolized version of the keys in the receiver, where possible. It does so by sending `to_sym` to them:

```ruby
{nil => nil, 1 => 1, "a" => "a"}.symbolize_keys
# => {1=>1, nil=>nil, :a=>"a"}
```

WARNING. Note in the previous example only one key was symbolized.

The result in case of collision is undefined:

```ruby
{"a" => 1, a: 2}.symbolize_keys
# => {:a=>2}, in my test, can't rely on this result though
```

This method may be useful for example to easily accept both symbols and strings as options. For instance `ActionController::UrlRewriter` defines

```ruby
def rewrite_path(options)
  options = options.symbolize_keys
  options.update(options[:params].symbolize_keys) if options[:params]
  ...
end
```

The second line can safely access the `:params` key, and let the user to pass either `:params` or "params".

There's also the bang variant `symbolize_keys!` that symbolizes keys in the very receiver.

Besides that, one can use `deep_symbolize_keys` and `deep_symbolize_keys!` to symbolize all the keys in the given hash and all the hashes nested into it. An example of the result is:

```ruby
{nil => nil, 1 => 1, "nested" => {"a" => 3, 5 => 5}}.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

#### `to_options` and `to_options!`

The methods `to_options` and `to_options!` are respectively aliases of `symbolize_keys` and `symbolize_keys!`.

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

#### `assert_valid_keys`

The method `assert_valid_keys` receives an arbitrary number of arguments, and checks whether the receiver has any key outside that white list. If it does `ArgumentError` is raised.

```ruby
{a: 1}.assert_valid_keys(:a)  # passes
{a: 1}.assert_valid_keys("a") # ArgumentError
```

Active Record does not accept unknown options when building associations, for example. It implements that control via `assert_valid_keys`.

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

### Slicing

Ruby has built-in support for taking slices out of strings and arrays. Active Support extends slicing to hashes:

```ruby
{a: 1, b: 2, c: 3}.slice(:a, :c)
# => {:c=>3, :a=>1}

{a: 1, b: 2, c: 3}.slice(:b, :X)
# => {:b=>2} # non-existing keys are ignored
```

If the receiver responds to `convert_key` keys are normalized:

```ruby
{a: 1, b: 2}.with_indifferent_access.slice("a")
# => {:a=>1}
```

NOTE. Slicing may come in handy for sanitizing option hashes with a white list of keys.

There's also `slice!` which in addition to perform a slice in place returns what's removed:

```ruby
hash = {a: 1, b: 2}
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTE: Defined in `active_support/core_ext/hash/slice.rb`.

### Extracting

The method `extract!` removes and returns the key/value pairs matching the given keys.

```ruby
hash = {a: 1, b: 2}
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

The method `extract!` returns the same subclass of Hash, that the receiver is.

```ruby
hash = {a: 1, b: 2}.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: Defined in `active_support/core_ext/hash/slice.rb`.

### Indifferent Access

The method `with_indifferent_access` returns an `ActiveSupport::HashWithIndifferentAccess` out of its receiver:

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

NOTE: Defined in `active_support/core_ext/hash/indifferent_access.rb`.

Extensions to `Regexp`
----------------------

### `multiline?`

The method `multiline?` says whether a regexp has the `/m` flag set, that is, whether the dot matches newlines.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails uses this method in a single place, also in the routing code. Multiline regexps are disallowed for route requirements and this flag eases enforcing that constraint.

```ruby
def assign_route_options(segments, defaults, requirements)
  ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option not allowed in routing requirements: #{requirement.inspect}"
  end
  ...
end
```

NOTE: Defined in `active_support/core_ext/regexp.rb`.

Extensions to `Range`
---------------------

### `to_s`

Active Support extends the method `Range#to_s` so that it understands an optional format argument. As of this writing the only supported non-default format is `:db`:

```ruby
(Date.today..Date.tomorrow).to_s
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_s(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

As the example depicts, the `:db` format generates a `BETWEEN` SQL clause. That is used by Active Record in its support for range values in conditions.

NOTE: Defined in `active_support/core_ext/range/conversions.rb`.

### `include?`

The methods `Range#include?` and `Range#===` say whether some value falls between the ends of a given instance:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support extends these methods so that the argument may be another range in turn. In that case we test whether the ends of the argument range belong to the receiver themselves:

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

NOTE: Defined in `active_support/core_ext/range/include_range.rb`.

### `overlaps?`

The method `Range#overlaps?` says whether any two given ranges have non-void intersection:

```ruby
(1..10).overlaps?(7..11)  # => true
(1..10).overlaps?(0..7)   # => true
(1..10).overlaps?(11..27) # => false
```

NOTE: Defined in `active_support/core_ext/range/overlaps.rb`.

Extensions to `Proc`
--------------------

### `bind`

As you surely know Ruby has an `UnboundMethod` class whose instances are methods that belong to the limbo of methods without a self. The method `Module#instance_method` returns an unbound method for example:

```ruby
Hash.instance_method(:delete) # => #<UnboundMethod: Hash#delete>
```

An unbound method is not callable as is, you need to bind it first to an object with `bind`:

```ruby
clear = Hash.instance_method(:clear)
clear.bind({a: 1}).call # => {}
```

Active Support defines `Proc#bind` with an analogous purpose:

```ruby
Proc.new { size }.bind([]).call # => 0
```

As you see that's callable and bound to the argument, the return value is indeed a `Method`.

NOTE: To do so `Proc#bind` actually creates a method under the hood. If you ever see a method with a weird name like `__bind_1256598120_237302` in a stack trace you know now where it comes from.

Action Pack uses this trick in `rescue_from` for example, which accepts the name of a method and also a proc as callbacks for a given rescued exception. It has to call them in either case, so a bound method is returned by `handler_for_rescue`, thus simplifying the code in the caller:

```ruby
def handler_for_rescue(exception)
  _, rescuer = Array(rescue_handlers).reverse.detect do |klass_name, handler|
    ...
  end

  case rescuer
  when Symbol
    method(rescuer)
  when Proc
    rescuer.bind(self)
  end
end
```

NOTE: Defined in `active_support/core_ext/proc.rb`.

Extensions to `Date`
--------------------

### Calculations

NOTE: All the following methods are defined in `active_support/core_ext/date/calculations.rb`.

INFO: The following calculation methods have edge cases in October 1582, since days 5..14 just do not exist. This guide does not document their behavior around those days for brevity, but it is enough to say that they do what you would expect. That is, `Date.new(1582, 10, 4).tomorrow` returns `Date.new(1582, 10, 15)` and so on. Please check `test/core_ext/date_ext_test.rb` in the Active Support test suite for expected behavior.

#### `Date.current`

Active Support defines `Date.current` to be today in the current time zone. That's like `Date.today`, except that it honors the user time zone, if defined. It also defines `Date.yesterday` and `Date.tomorrow`, and the instance predicates `past?`, `today?`, and `future?`, all of them relative to `Date.current`.

When making Date comparisons using methods which honor the user time zone, make sure to use `Date.current` and not `Date.today`. There are cases where the user time zone might be in the future compared to the system time zone, which `Date.today` uses by default. This means `Date.today` may equal `Date.yesterday`.

#### Named dates

##### `prev_year`, `next_year`

In Ruby 1.9 `prev_year` and `next_year` return a date with the same day/month in the last or next year:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_year              # => Fri, 08 May 2009
d.next_year              # => Sun, 08 May 2011
```

If date is the 29th of February of a leap year, you obtain the 28th:

```ruby
d = Date.new(2000, 2, 29) # => Tue, 29 Feb 2000
d.prev_year               # => Sun, 28 Feb 1999
d.next_year               # => Wed, 28 Feb 2001
```

`prev_year` is aliased to `last_year`.

##### `prev_month`, `next_month`

In Ruby 1.9 `prev_month` and `next_month` return the date with the same day in the last or next month:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_month             # => Thu, 08 Apr 2010
d.next_month             # => Tue, 08 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2000, 5, 31).prev_month # => Sun, 30 Apr 2000
Date.new(2000, 3, 31).prev_month # => Tue, 29 Feb 2000
Date.new(2000, 5, 31).next_month # => Fri, 30 Jun 2000
Date.new(2000, 1, 31).next_month # => Tue, 29 Feb 2000
```

`prev_month` is aliased to `last_month`.

##### `prev_quarter`, `next_quarter`

Same as `prev_month` and `next_month`. It returns the date with the same day in the previous or next quarter:

```ruby
t = Time.local(2010, 5, 8) # => Sat, 08 May 2010
t.prev_quarter             # => Mon, 08 Feb 2010
t.next_quarter             # => Sun, 08 Aug 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => Sun, 30 Apr 2000
Time.local(2000, 5, 31).prev_quarter  # => Tue, 29 Feb 2000
Time.local(2000, 10, 31).prev_quarter # => Mon, 30 Oct 2000
Time.local(2000, 11, 31).next_quarter # => Wed, 28 Feb 2001
```

`prev_quarter` is aliased to `last_quarter`.

##### `beginning_of_week`, `end_of_week`

The methods `beginning_of_week` and `end_of_week` return the dates for the
beginning and end of the week, respectively. Weeks are assumed to start on
Monday, but that can be changed passing an argument, setting thread local
`Date.beginning_of_week` or `config.beginning_of_week`.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` is aliased to `at_beginning_of_week` and `end_of_week` is aliased to `at_end_of_week`.

##### `monday`, `sunday`

The methods `monday` and `sunday` return the dates for the previous Monday and
next Sunday, respectively.

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

The method `next_week` receives a symbol with a day name in English (default is the thread local `Date.beginning_of_week`, or `config.beginning_of_week`, or `:monday`) and it returns the date corresponding to that day.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

The method `prev_week` is analogous:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week` is aliased to `last_week`.

Both `next_week` and `prev_week` work as expected when `Date.beginning_of_week` or `config.beginning_of_week` are set.

##### `beginning_of_month`, `end_of_month`

The methods `beginning_of_month` and `end_of_month` return the dates for the beginning and end of the month:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month` is aliased to `at_beginning_of_month`, and `end_of_month` is aliased to `at_end_of_month`.

##### `beginning_of_quarter`, `end_of_quarter`

The methods `beginning_of_quarter` and `end_of_quarter` return the dates for the beginning and end of the quarter of the receiver's calendar year:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter` is aliased to `at_beginning_of_quarter`, and `end_of_quarter` is aliased to `at_end_of_quarter`.

##### `beginning_of_year`, `end_of_year`

The methods `beginning_of_year` and `end_of_year` return the dates for the beginning and end of the year:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year` is aliased to `at_beginning_of_year`, and `end_of_year` is aliased to `at_end_of_year`.

#### Other Date Computations

##### `years_ago`, `years_since`

The method `years_ago` receives a number of years and returns the same date those many years ago:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

`years_since` moves forward in time:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

##### `months_ago`, `months_since`

The methods `months_ago` and `months_since` work analogously for months:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

##### `weeks_ago`

The method `weeks_ago` works analogously for weeks:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

##### `advance`

The most generic way to jump to other days is `advance`. This method receives a hash with keys `:years`, `:months`, `:weeks`, `:days`, and returns a date advanced as much as the present keys indicate:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Note in the previous example that increments may be negative.

To perform the computation the method first increments years, then months, then weeks, and finally days. This order is important towards the end of months. Say for example we are at the end of February of 2010, and we want to move one month and one day forward.

The method `advance` advances first one month, and then one day, the result is:

```ruby
Date.new(2010, 2, 28).advance(months: 1, days: 1)
# => Sun, 29 Mar 2010
```

While if it did it the other way around the result would be different:

```ruby
Date.new(2010, 2, 28).advance(days: 1).advance(months: 1)
# => Thu, 01 Apr 2010
```

#### Changing Components

The method `change` allows you to get a new date which is the same as the receiver except for the given year, month, or day:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

This method is not tolerant to non-existing dates, if the change is invalid `ArgumentError` is raised:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

#### Durations

Durations can be added to and subtracted from dates:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

#### Timestamps

INFO: The following methods return a `Time` object if possible, otherwise a `DateTime`. If set, they honor the user time zone.

##### `beginning_of_day`, `end_of_day`

The method `beginning_of_day` returns a timestamp at the beginning of the day (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

The method `end_of_day` returns a timestamp at the end of the day (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` is aliased to `at_beginning_of_day`, `midnight`, `at_midnight`.

##### `beginning_of_hour`, `end_of_hour`

The method `beginning_of_hour` returns a timestamp at the beginning of the hour (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

The method `end_of_hour` returns a timestamp at the end of the hour (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` is aliased to `at_beginning_of_hour`.

##### `beginning_of_minute`, `end_of_minute`

The method `beginning_of_minute` returns a timestamp at the beginning of the minute (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

The method `end_of_minute` returns a timestamp at the end of the minute (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` is aliased to `at_beginning_of_minute`.

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` and `end_of_minute` are implemented for `Time` and `DateTime` but **not** `Date` as it does not make sense to request the beginning or end of an hour or minute on a `Date` instance.

##### `ago`, `since`

The method `ago` receives a number of seconds as argument and returns a timestamp those many seconds ago from midnight:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

Similarly, `since` moves forward:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```

#### Other Time Computations

### Conversions

Extensions to `DateTime`
------------------------

WARNING: `DateTime` is not aware of DST rules and so some of these methods have edge cases when a DST change is going on. For example `seconds_since_midnight` might not return the real amount in such a day.

### Calculations

NOTE: All the following methods are defined in `active_support/core_ext/date_time/calculations.rb`.

The class `DateTime` is a subclass of `Date` so by loading `active_support/core_ext/date/calculations.rb` you inherit these methods and their aliases, except that they will always return datetimes:

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

The following methods are reimplemented so you do **not** need to load `active_support/core_ext/date/calculations.rb` for these ones:

```ruby
beginning_of_day (midnight, at_midnight, at_beginning_of_day)
end_of_day
ago
since (in)
```

On the other hand, `advance` and `change` are also defined and support more options, they are documented below.

The following methods are only implemented in `active_support/core_ext/date_time/calculations.rb` as they only make sense when used with a `DateTime` instance:

```ruby
beginning_of_hour (at_beginning_of_hour)
end_of_hour
```

#### Named Datetimes

##### `DateTime.current`

Active Support defines `DateTime.current` to be like `Time.now.to_datetime`, except that it honors the user time zone, if defined. It also defines `DateTime.yesterday` and `DateTime.tomorrow`, and the instance predicates `past?`, and `future?` relative to `DateTime.current`.

#### Other Extensions

##### `seconds_since_midnight`

The method `seconds_since_midnight` returns the number of seconds since midnight:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

##### `utc`

The method `utc` gives you the same datetime in the receiver expressed in UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

This method is also aliased as `getutc`.

##### `utc?`

The predicate `utc?` says whether the receiver has UTC as its time zone:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

##### `advance`

The most generic way to jump to another datetime is `advance`. This method receives a hash with keys `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, and `:seconds`, and returns a datetime advanced as much as the present keys indicate.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

This method first computes the destination date passing `:years`, `:months`, `:weeks`, and `:days` to `Date#advance` documented above. After that, it adjusts the time calling `since` with the number of seconds to advance. This order is relevant, a different ordering would give different datetimes in some edge-cases. The example in `Date#advance` applies, and we can extend it to show order relevance related to the time bits.

If we first move the date bits (that have also a relative order of processing, as documented before), and then the time bits we get for example the following computation:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

but if we computed them the other way around, the result would be different:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

WARNING: Since `DateTime` is not DST-aware you can end up in a non-existing point in time with no warning or error telling you so.

#### Changing Components

The method `change` allows you to get a new datetime which is the same as the receiver except for the given options, which may include `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```

If hours are zeroed, then minutes and seconds are too (unless they have given values):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

Similarly, if minutes are zeroed, then seconds are too (unless it has given a value):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

This method is not tolerant to non-existing dates, if the change is invalid `ArgumentError` is raised:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

#### Durations

Durations can be added to and subtracted from datetimes:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Extensions to `Time`
--------------------

### Calculations

NOTE: All the following methods are defined in `active_support/core_ext/time/calculations.rb`.

Active Support adds to `Time` many of the methods available for `DateTime`:

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

They are analogous. Please refer to their documentation above and take into account the following differences:

* `change` accepts an additional `:usec` option.
* `Time` understands DST, so you get correct DST calculations as in

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# In Barcelona, 2010/03/28 02:00 +0100 becomes 2010/03/28 03:00 +0200 due to DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* If `since` or `ago` jump to a time that can't be expressed with `Time` a `DateTime` object is returned instead.

#### `Time.current`

Active Support defines `Time.current` to be today in the current time zone. That's like `Time.now`, except that it honors the user time zone, if defined. It also defines `Time.yesterday` and `Time.tomorrow`, and the instance predicates `past?`, `today?`, and `future?`, all of them relative to `Time.current`.

When making Time comparisons using methods which honor the user time zone, make sure to use `Time.current` and not `Time.now`. There are cases where the user time zone might be in the future compared to the system time zone, which `Time.today` uses by default. This means `Time.now` may equal `Time.yesterday`.

#### `all_day`, `all_week`, `all_month`, `all_quarter` and `all_year`

The method `all_day` returns a range representing the whole day of the current time.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Analogously, `all_week`, `all_month`, `all_quarter` and `all_year` all serve the purpose of generating time ranges.

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

### Time Constructors

Active Support defines `Time.current` to be `Time.zone.now` if there's a user time zone defined, with fallback to `Time.now`:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Analogously to `DateTime`, the predicates `past?`, and `future?` are relative to `Time.current`.

If the time to be constructed lies beyond the range supported by `Time` in the runtime platform, usecs are discarded and a `DateTime` object is returned instead.

#### Durations

Durations can be added to and subtracted from time objects:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
#  => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Extensions to `File`
--------------------

### `atomic_write`

With the class method `File.atomic_write` you can write to a file in a way that will prevent any reader from seeing half-written content.

The name of the file is passed as an argument, and the method yields a file handle opened for writing. Once the block is done `atomic_write` closes the file handle and completes its job.

For example, Action Pack uses this method to write asset cache files like `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

To accomplish this `atomic_write` creates a temporary file. That's the file the code in the block actually writes to. On completion, the temporary file is renamed, which is an atomic operation on POSIX systems. If the target file exists `atomic_write` overwrites it and keeps owners and permissions. However there are a few cases where `atomic_write` cannot change the file ownership or permissions, this error is caught and skipped over trusting in the user/filesystem to ensure the file is accessible to the processes that need it.

NOTE. Due to the chmod operation `atomic_write` performs, if the target file has an ACL set on it this ACL will be recalculated/modified.

WARNING. Note you can't append with `atomic_write`.

The auxiliary file is written in a standard directory for temporary files, but you can pass a directory of your choice as second argument.

NOTE: Defined in `active_support/core_ext/file/atomic.rb`.

Extensions to `Marshal`
-----------------------

### `load`

Active Support adds constant autoloading support to `load`.

For example, the file cache store deserializes this way:

```ruby
File.open(file_name) { |f| Marshal.load(f) }
```

If the cached data refers to a constant that is unknown at that point, the autoloading mechanism is triggered and if it succeeds the deserialization is retried transparently.

WARNING. If the argument is an `IO` it needs to respond to `rewind` to be able to retry. Regular files respond to `rewind`.

NOTE: Defined in `active_support/core_ext/marshal.rb`.

Extensions to `Logger`
----------------------

### `around_[level]`

Takes two arguments, a `before_message` and `after_message` and calls the current level method on the `Logger` instance, passing in the `before_message`, then the specified message, then the `after_message`:

```ruby
logger = Logger.new("log/development.log")
logger.around_info("before", "after") { |logger| logger.info("during") }
```

### `silence`

Silences every log level lesser to the specified one for the duration of the given block. Log level orders are: debug, info, error and fatal.

```ruby
logger = Logger.new("log/development.log")
logger.silence(Logger::INFO) do
  logger.debug("In space, no one can hear you scream.")
  logger.info("Scream all you want, small mailman!")
end
```

### `datetime_format=`

Modifies the datetime format output by the formatter class associated with this logger. If the formatter class does not have a `datetime_format` method then this is ignored.

```ruby
class Logger::FormatWithTime < Logger::Formatter
  cattr_accessor(:datetime_format) { "%Y%m%d%H%m%S" }

  def self.call(severity, timestamp, progname, msg)
    "#{timestamp.strftime(datetime_format)} -- #{String === msg ? msg : msg.inspect}\n"
  end
end

logger = Logger.new("log/development.log")
logger.formatter = Logger::FormatWithTime
logger.info("<- is the current time")
```

NOTE: Defined in `active_support/core_ext/logger.rb`.

Extensions to `NameError`
-------------------------

Active Support adds `missing_name?` to `NameError`, which tests whether the exception was raised because of the name passed as argument.

The name may be given as a symbol or string. A symbol is tested against the bare constant name, a string is against the fully-qualified constant name.

TIP: A symbol can represent a fully-qualified constant name as in `:"ActiveRecord::Base"`, so the behavior for symbols is defined for convenience, not because it has to be that way technically.

For example, when an action of `PostsController` is called Rails tries optimistically to use `PostsHelper`. It is OK that the helper module does not exist, so if an exception for that constant name is raised it should be silenced. But it could be the case that `posts_helper.rb` raises a `NameError` due to an actual unknown constant. That should be reraised. The method `missing_name?` provides a way to distinguish both cases:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue MissingSourceFile => e
  raise e unless e.is_missing? "#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Defined in `active_support/core_ext/name_error.rb`.

Extensions to `LoadError`
-------------------------

Active Support adds `is_missing?` to `LoadError`, and also assigns that class to the constant `MissingSourceFile` for backwards compatibility.

Given a path name `is_missing?` tests whether the exception was raised due to that particular file (except perhaps for the ".rb" extension).

For example, when an action of `PostsController` is called Rails tries to load `posts_helper.rb`, but that file may not exist. That's fine, the helper module is not mandatory so Rails silences a load error. But it could be the case that the helper module does exist and in turn requires another library that is missing. In that case Rails must reraise the exception. The method `is_missing?` provides a way to distinguish both cases:

```ruby
def default_helper_module!
  module_name = name.sub(/Controller$/, '')
  module_path = module_name.underscore
  helper module_path
rescue MissingSourceFile => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Defined in `active_support/core_ext/load_error.rb`.
