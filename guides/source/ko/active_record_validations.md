Active Record Validation
==========================

이 가이드에서는 Active Record의 유효성 검사(Validation) 기능을 사용해서 객체가
데이터베이스에 저장되기 전에 자신의 상태를 검증하는 방법에 대해서 설명합니다.

이 가이드의 내용:

* Active Record의 내장 검증 헬퍼 사용하기
* 커스텀 유효성 검사 메소드 만들기
* 검증 과정에서 생성된 에러 사용하기

-------------------------------------------------------------------------------

유효성 검사의 개요
---------------------

간단한 유효성 검사의 예시를 소개합니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

이상에서 알 수 있듯, 이 유효성 검사에서는 `Person`이 `name` 속성이 없는 경우에
유효하지 않은 것으로 판정합니다. 그래서 두번째 `Person`은 데이터베이스에
저장되지 않습니다.

유효성 검사를 자세히 설명하기 전에, 유효성 검사가 애플리케이션 전체에서 중요한
이유를 설명합니다.

### 유효성 검사를 하는 이유

유효성 검사는 올바른 데이터만을 데이터베이스에 저장하기 위해서 수행됩니다. 예를 들어, 애플리케이션에서 모든 유저는 반드시 이메일 주소를 가지고 있어야 한다고 가정합시다. 올바른 데이터만을 데이터베이스에 저장하려면 모델 계층에서 유효성 검사를 하는 것이 이상적입니다. 모델 계층에서의 유효성 검사는 데이터베이스에 의존하지 않으며, 일반 사용자가 우회할 수 없으며, 테스트와 유지 보수에도 편리하기 때문입니다. Rails에는 유효성 검사를 간단하게 쓸 수 있도록 일반적으로 이용가능한 내장 헬퍼가 존재하며, 직접 검증 메소드를 작성할 수도 있습니다.

이외에도 데이터를 데이터베이스에 저장하기 전에 유효성 검사를 실행하는 방법으로는 데이터베이스 자체의 제약 기능, 클라이언트에서 검증하기, 컨트롤러에서 검증하기 등, 여러가지가 있습니다. 각각의 장점과 단점은 다음과 같습니다.

* 데이터베이스 제약이나 Stored Procedure를 사용하면 검증 알고리즘이 데이터베이스에 의존하게 되므로, 테스트나 유지보수가 귀찮아집니다. 단, 데이터베이스가 (Rails 이외의) 다른 애플리케이션에서도 사용되는 거라면 데이터베이스 레벨에서 어느 정도 유효성 검사를 하는 것은 좋은 생각입니다. 또한, 데이터베이스 계층의 유효성 검사 중에는 사용 빈도가 무척 높은 테이블의 유일성(Unique) 검사 같은, 다른 방법으로는 사용이 곤란한 것들도 있습니다.
* 클라이언트 계층에서의 유효성검사는 다루기 쉽고, 편리합니다만 단독으로 사용하기에는 신뢰성이 부족합니다. JavaScript를 사용하는 유효성 검사를 사용하는 경우, 사용자가 JavaScript를 비활성화하는 것으로 간단하게 우회할 수 있기 때문입니다. 단, 다른 방법과 함께 사용하는 것이라면, 클라이언트 계층의 유효성 검사는 사용자에게 곧바로 피드백을 돌려줄 수 있기 때문에 좋은 방법이 될 것입니다.
* 컨트롤러에서의 유효성 검사는 한번 쯤은 해보고 싶어지는 방식입니다만 대부분 감당하기 힘들고, 테스트나 유지보수도 불편하기만 합니다. 가급적 컨트롤러는 가볍게 가져가는 것이 애플리케이션을 쉽고 편하게, 그리고 길게 유지보수하기 좋습니다.

필요한 상황에 따라서 위에서 설명한 다른 유효성 검사 방법을 적절히 추가해주세요. Rails 팀은 대부분의 경우, 모델 계층에서의 유효성 검사가 가장 적절하다고 생각하고 있습니다.

### 유효성 검사 실행 시의 동작

Active Record의 객체에는 2가지 종류가 있습니다. 객체가 데이터베이스의 레코드(row)에 매핑 된 것과 그렇지 않은 것입니다. 예를 들어 `new` 메소드로 생성된 객체는 아직 데이터베이스에 속해있지 않습니다. `save` 메소드를 호출해야만 적절한 데이터베이스의 테이블에 저장됩니다. Active Record의 `new_record?` 인스턴스 메소드를 사용해서 객채가 데이터베이스에 저장되었는지 확인할 수 있습니다. 다음의 간단한 Active Record 클래스를 보시죠.

```ruby
class Person < ApplicationRecord
end
```

`rails console`의 출력을 확인해봅시다.

```ruby
$ rails console
>> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>
>> p.new_record?
=> true
>> p.save
=> true
>> p.new_record?
=> false
```

새 레코드를 생성해서 저장하면 SQL의 `INSERT`가 데이터베이스로 전송됩니다. 기존의 레코드를 갱신하는 거라면 `UPDATE`가 전송됩니다. 유효성 검사는 SQL을 전송하기 전에 이루어집니다. 검사 중에 하나라도 실패하면 객채는 무효(invalid)라고 표시되며, Active Record에서 `INSERT`나 `UPDATE`는 전송되지 않습니다. 이런 식으로 유효하지 않은 객체가 데이터베이스에 저장되는 것을 방지합니다. 객체의 생성, 저장, 갱신 시에 특정 유효성 검사만을 실행하는 것도 가능합니다.

CAUTION: 데이터베이스의 객체를 변경하는 방법이 한가지만은 아닙니다. 메소드 중에는 유효성 검사를 실행하는 것과 그렇지 않은 것이 있습니다. 이 부분을 주의하지 않으면, 유효성 검사를 추가해두어도 데이터베이스에 유효하지 않은 객체가 저장될 가능성이 있습니다.

이하의 메소드에서는 유효성 검사가 실행되며, 객체가 유효한 경우에만 데이터베이스에 저장됩니다.

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

파괴적인 메소드(`save!` 같은)에서는 레코드가 유효하지 않은 경우, 예외를 발생시킵니다. 비파괴적인 메소드인 경우는 예외를 발생시키지 않습니다. 이런 경우 `save`나 `update`는 `false`를 반환하고 `create`는 원래의 객체를 그대로 반환합니다.

### 유효성 검사를 무시하기

이하의 메소드는 유효성 검사를 수행하지 않습니다. 객체가 유효하든 아니든 상관없이 객체를 저장합니다. 이 메소드들을 사용할 때에는 주의해주세요.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `toggle!`
* `touch`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`

사실 `save`에서 `validate: false`를 인수로 건네주면 `save`에서도 유효성 검사를
무시할 수 있습니다만, 사용하실 때에는 세심의 주의를 기울여주세요.

* `save(validate: false)`

### `valid?`와 `invalid?`

Rails는 Active Record 객체를 저장하기 전에 검증을 실행합니다.
만약 이 검증이 어떤 에러를 돌려준다면 Rails는 객체를 저장하지 않습니다.

직접 검증을 만들 수 도 있습니다. `valid?`는 만든 검증을 실행하고 객체에서
에러를 발견하지 못한 경우에 true를 반환하며, 그렇지 않은 경우에 false를
반환합니다.
아래와 같이 사용할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

Active Record에서 유효성 검사가 이루어진 뒤에 `errors.messages` 라는 인스턴스
메소드를 사용하면, 발생한 에러에 접근할 수 있습니다. 이 메소드는 에러 메시지의
컬렉션을 반환합니다. 기본적으로는 유효성 검사를 실한 뒤에 이 컬렉션이 아무것도
가지고 있지 않을 경우에만 객체가 유효하다고 판단합니다.

`new` 를 사용해서 생성된 객체는 유효성에 문제가 있다고 하더라도 에러가 있다고
표시되지 않으므로, 주의해야합니다. `new` 만으로는 유효성 검사가 실행되지
않습니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> p = Person.new
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {}

>> p.valid?
# => false
>> p.errors.messages
# => {name:["can't be blank"]}

>> p = Person.create
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {name:["can't be blank"]}

>> p.save
# => false

>> p.save!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

>> Person.create!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

`invalid?`는 `valid?`의 정 반대의 동작을 합니다. 이 메소드는 유효성 검사를
수행하고 객체에서 에러가 발생한 경우에 true를, 그렇지 않으면 false를
반환합니다.

### `errors[]`

`errors[:attribute]`를 사용해서 특정 객체의 속성이 유효한지를 확인합니다.
이 메소드는 `:attribute`의 모든 에러 목록을 반환합니다. 지정된 속성에서
에러가 발생하지 않았을 경우에는 빈 배열을 반환합니다.

이 메소드는 유효성 검사가 _끝난 뒤에만_ 유용합니다. 이 메소드는 에러 컬렉션을
확인하기만 하고, 유효성 검사 자체를 실행하지는 않기 때문입니다. 이 메소드는
앞에서 이야기했던 `ApplicationRecord#invalid?`와는 다르게, 객체 전체의 유효성을
확인하지 않기 때문입니다. 다시 말해, 각각의 속성에 대해서 에러가 있는지
없는지을 확인합니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> Person.new.errors[:name].any? # => false
>> Person.create.errors[:name].any? # => true
```

검증 에러에 대한 자세한 설명은 [검증 에러 다루기](#검증-에러-사용하기)를
참조해주세요. 지금부터는 Rails가 제공하는 내장 검증 헬퍼를 설명합니다.

### `errors.details`

부정한 속성에 대해서 어떤 검증이 실패했는지를 확인하려면
`errors.details[:attribute]`를 사용하세요. 이는 `:error`라는 키를 통해서
검증자의 심볼을 얻어올 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> person = Person.new
>> person.valid?
>> person.errors.details[:name] # => [{error: :blank}]
```

검증 에러에 대한 자세한 설명은 [검증 에러 다루기](#검증-에러-사용하기)를
참조해주세요. 지금부터는 Rails가 제공하는 내장 검증 헬퍼를 설명합니다.

검증 헬퍼
------------------

Active Record에서는 클래서 정의에서 직접 사용가능한 검증 헬퍼가 다수 있습니다.
이 헬퍼들은 공통의 검증 규칙을 제공합니다. 검증이 실패할 때마다 객체의 `errors`
컬렉션에 에러 메시지가 추가되며, 그 메시지는 검증 대상인 속성과 연관되어
저장됩니다.

어느 헬퍼도 검증 가능한 속성 갯수에는 제한을 두지 않으므로, 한줄의 코드를
작성하는 것만으로도 많은 속성에 대해서 같은 검증 규칙을 적용할 수 있습니다.

`:on` 옵션과 `:message` 옵션은 어느 헬퍼에서도 사용할 수 있습니다. 이 옵션들은
각각 유효성 검사가 실행되는 시점과 검증이 실패했을 때에 `errors` 컬렉션에
추가될 메시지를 지정합니다. `:on` 옵션은 `:create`나 `:update`를 값으로
취합니다. 검증 헬퍼에는 각각 기본 에러 메시지가 준비되어 있습니다. `:message`
옵션을 사용하지 않는 경우에는 기본 에러 메시지가 사용됩니다. 사용 가능한
헬퍼를 하나씩 알아봅시다.

### `acceptance`

이 메소드는 양식이 전송되었을 때에 유저 인터페이스에서 체크박스에 체크가
되어있는지 아닌지를 확인합니다. 유저가 서비스 이용 약관에 대한 동의,
사용자에게 문서를 읽어야 한다는 것 같은 무언가의 동의를 요구할 때 등에 사용할
수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

이 검사는 `terms_of_service`가 `nil`인지만을 확인합니다.
이 헬퍼의 기본 에러 메시지는 _"must be accepted"_ 입니다.
`message` 옵션을 통해서 전용 메시지를 사용할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true, message: 'must be abided'
end
```

이 헬퍼에서는 `:accept` 옵션을 사용할 수 있습니다. 이 옵션은 `체크됨`을
나타내는 값을 지정할 수 있습니다. 기본값은 `["1", true]`입니다만, 간단하게
변경할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

이 검증은 웹 애플리케이션에 있어서 매우 명확하며, 이 'acceptance'는
데이터베이스에 저장될 필요가 없습니다. 만약 해당하는 필드를 가지고 있지 않다면
헬퍼는 가상 속성을 생성합니다. 만약 데이터베이스에 해당하는 속성이 존재하지
않는다면, `accept` 옵션이 설정되거나, `true`를 넘기지 않으면 검증이 동작하지
않을 것입니다.

### `validates_associated`

모델이 다른 모델과 관계가 설정되어있고, 양 쪽의 모델에 대해서 유효성 검사를 실행할 필요가 있는 경우에는 이 헬퍼를 사용합니다. 객체를 저장할때 관계가 설정된 객체마다 `valid?`가 호출됩니다.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

이 검증은 어떤 종류의 관계에라도 사용할 수 있습니다.

CAUTION: `validates_associated`은 한쪽에서만 호출해주세요. 만약 관계가 설정된
두 모델 모두 이 헬퍼를 사용하면 무한루프에 빠집니다.

`validates_associated`의 기본 에러메시지는 _"is invalid"_ 입니다. 관계가
설정된 객체는 자신의 `errors` 컬렉션에 에러를 저장하므로, 검증을 실행한
모델에서 직접 그 에러를 확인할 수는 없습니다.

### `confirmation`

이 헬퍼는 2개의 텍스트 필드가 완전히 일치하는 내용을 가져야할 때 사용할 수
있습니다. 예를 들어, 이메일 주소와 이메일 주소 확인 필드를 만든다고 합시다.
이 검증 헬퍼는 가상의 속성을 생성합니다. 그 속성의 이름은 확인하고 싶은
속성명에 "_confirmation"을 추가하면 됩니다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

뷰 템플릿에서는 아래와 같이 작성합니다.

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

이 검증은 `email_confirmation`가 `nil`이 아닌 경우에만 수행됩니다. 필수로 확인하기 위해서는 확인용의 속성값을 받아야 한다는 검증을 추가해주세요(아래와 같이 설정하면 됩니다. `presence`에 대해서는 아래에서 설명합니다).

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

`:case_sensitive` 옵션을 사용하여 확인시에 대소문자를 구별할지 아닐지를
결정할 수 있습니다. 이 옵션의 기본값은 true입니다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

이 헬퍼의 기본 에러 메시지는 _"doesn't match confirmation"_ 입니다.

### `exclusion`

이 헬퍼는 주어진 집합의 속성의 값이 포함되어있지 '않은지' 검사합니다(블랙
리스트). 집합은 임의의 열거 가능한 객체를 사용할 수 있습니다.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value}는 예약어입니다." }
end
```

`exclusion` 헬퍼의 `:in` 옵션에는 검증시에 포함하면 안되는 값들의 집합을
넘겨줍니다. `:in` 옵션에는 `:within`이라는 동의어도 있으므로, 편의에 맞춰서
어느 쪽이든 사용할 수 있습니다. 위의 예제에서는 `:message` 옵션에서 속성 값을
어떻게 사용하는지를 보여주고 있습니다.

기본 에러 메시지는 _"is reserved"_ 입니다.

### `format`

이 헬퍼는 `with`옵션으로 주어진 정규표현식과 속성의 값이 매칭되는지 확인합니다.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "영문자만 사용할수 있습니다." }
end
```

반대로, 매칭되어서는 안되는 정규 표현식을 `:without` 옵션으로 넘길 수 있습니다.

기본 에러 메시지는 _"is invalid"_ 입니다.

### `inclusion`

이 헬퍼는 주어진 집합에 속성값이 포함되어있는지 확인합니다.
집합으로서 임의의 열거 가능한 객체를 사용할 수 있습니다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} 사이즈는 존재하지 않습니다." }
end
```

`inclusion` 헬퍼에는 `:in` 옵션이 있으며, 사용 가능한 값들을 지정합니다(화이트
리스트). `:in` 옵션에는 `:within`이라는 동의어가 있으며, 편한 것을 사용하면
됩니다. 위의 예제에서는 `:message` 옵션에서 어떻게 속성 값을 사용하는 지를
보여주고 있습니다.

이 헬퍼의 기본 에러 메시지는 _"is not included in the list"_ 입니다.

### `length`

이 헬퍼는 속성값의 길이를 검사합니다. 여러가지 옵션이 있어서, 다양한 방식으로 길이 제한을 설정할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

사용 가능한 옵션은 다음과 같습니다.

* `:minimum` - 이 값보다 작은 길이를 사용할 수 없습니다.
* `:maximum` - 이 값보다 큰 길이를 사용할 수 없습니다.
* `:in` 또는 `:within` - 속성의 길이는 주어진 구간 내에 존재해야하며, Range 객체를 넘겨주어야 합니다.
* `:is` - 속성의 길이는 주어진 값과 동일해야합니다.

기본 에러 메시지는 실행된 검사에 따라서 다릅니다. `:wrong_length`, `:too_long`,
`:too_short` 옵션을 사용해서 변경할 수 있으며, `%{count}`를 길이 제한을
나타내는 플레이스 홀더로 사용할 수 있습니다. `:message` 옵션을 사용해서
에러 메시지를 지정할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

기본 에러 메시지가 복수형이라는 점을 주의하세요(e.g. "is too short (minimum
is %{count} characters)"). 이런 이유로 `:minimum`이 1인 경우에는 별도의
메시지를 넘겨주거나 `presence: true`를 사용하세요. `:in`이나 `:within`이 1보다
작은 제한을 사용한다면 이 역시 별도의 메시지를 쓰거나 `length`보다 `presence`를
사용하세요.

### `numericality`

이 헬퍼는 속성에 숫자가 사용되는지를 확인합니다. 기본값으로는 정수, 또는 부동소수점만을 허가합니다. 맨 앞에 부호(+나 -)가 붙어 있는 경우도 가능합니다. 정수만을 유효하게 하고 싶은 경우에는 `:only_integer`를 true로 설정합니다.

`:only_integer`를`true`로 설정하면,

```ruby
/\A[+-]?\d+\Z/
```

위의 정규표현을 사용해서 속성값을 검증합니다. 그렇지 않은 경우에는 값을
`Float`로 변환해서 검증을 시도합니다.

WARNING: 위의 정규표현식은 맨 뒤에 개행 기호가 있어도 유효합니다.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

이 헬퍼는 `:only_integer` 이외에도 아래와 같은 옵션을 사용할 수 있습니다.

* `:greater_than` - 이 옵션으로 넘겨진 값보다 검사하는 값이 커야합니다. 기본 에러 메시지는 _"must be greater than %{count}"_ 입니다.
* `:greater_than_or_equal_to` - 검사하는 값의 최소값을 지정합니다. 기본 에러 메시지는 _"must be greater than or equal to %{count}"_ 입니다.
* `:equal_to` - 지정된 값과 검사하는 값이 같아야합니다. 기본 에러 메시지는 _"must be equal to %{count}"_ 입니다.
* `:less_than` - 이 옵션으로 넘겨진 값보다 검사하는 값이 작아야 합니다. 기본 에러 메시지는 _"must be less than %{count}"_ 입니다.
* `:less_than_or_equal_to` - 검사하는 값의 최대값을 지정합니다. 기본 에러 메시지는 _"must be less than or equal to %{count}"_ 입니다.
* `:other_than` - 이 옵션으로 넘겨진 값이 아니기를 기대합니다. 기본 에러 메시지는 _"must be other than %{count}"_ 입니다.
* `:odd` - true로 설정하면, 값이 홀수인지 확인합니다. 기본 에러 메시지는 _"must be odd"_ 입니다.
* `:even` - true로 설정하면, 값이 짝수인지 확인합니다. 기본 에러 메시지는 _"must be even"_ 입니다.

NOTE: `numericality`는 `nil`을 허가하지 않습니다. 필요하다면
`allow_nil: true` 옵션을 사용하세요.

기본 에러 메시지는 _"is not a number"_ 입니다.

### `presence`

이 헬퍼는 지정된 속성이 비어있는지 확인합니다. 값이 `nil`이나 공백 문자가
아닌 것을 확인 하기 위해서 `blank?` 메소드를 사용합니다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

관계 자체의 존재를 확인하기 위해서는, 관계가 설정된 객체가 존재하는지 확인할 필요가 있습니다.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, presence: true
end
```

자신에게 속한 객체의 존재가 존재하는지 확인해야 하는 경우, 이를 위해서는 관계 설정 시에 `:inverse_of` 옵션을 지정할 필요가 있습니다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

이 헬퍼를 사용해서, `has_one` 또는 `has_many` 관계를 통해서 연관된 객체의 존재를 검증할 때에는 `blank?`와 `marked_for_destruction?` 모두 false를 반환하는지 확인합니다.

`false.blank?`는 언제나 true 이므로 Boolean을 사용하는 값에 대해서 Boolean인지
검증하려면 다음의 방법을 사용하세요.

```ruby
validates :boolean_field_name, inclusion: { in: [true, false] }
validates :boolean_field_name, exclusion: { in: [nil] }
```

위 검증 중 하나를 사용하는 것으로 값이 `nil`이 넘어가서 `NULL` 값이 되는
경우를 피할 수 있습니다.

### `absence`

이 헬퍼는 지정된 속성이 비어있는지 봅니다. 값이 `nil`이거나 공백문자인지 확인하기 위해서 `present?` 메소드를 사용합니다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

관계가 없는지를 확인하고 싶은 경우에는, 관계가 있는 객체가 존재하는지를 확인하고 그 객체에 맵핑된 외래키의 존재 여부를 확인해야 합니다.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

관계된 레코드가 존재해서는 안되는 경우, 이를 검증하기 위해서는 관계 설정시에 `:inverse_of` 옵션을 지정해야할 필요가 있습니다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

이 헬퍼를 사용해서 `has_one` 또는 `has_many` 관계에 있는 객체가 존재하는지
검증할 때에는 `presence?`와 `marked_for_destruction?`가 모두 false 를
반환하는지 확인합니다.

`false.present?`는 언제나 false이므로, Boolean에 대해서 이 메소드를 사용하면
올바른 결과를 얻을 수 없습니다. 이러한 경우에는
`validates :field_name, exclusion: { in: [true, false] }`을 사용하면 됩니다.

기본 에러 메시지는 _"must be blank"_ 입니다.

### `uniqueness`

이 헬퍼는 객체가 저장되기 전에 속성값이 유일한지(unique) 확인합니다. 이 헬퍼는
데이터베이스 자체에 유일성 제약을 추가한 것이 아니기 때문에, 하나의
데이터베이스에 접속한 2개의 접속에서 유일하기를 바라는 어떤 값을 2개 생성하는
상황이 발생할 수 도 있습니다. 이를 피하기 위해서는 데이터베이스에도 유일성
제약을 설정해둘 필요가 있습니다.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

이 검증은 모델의 테이블에 대해서, 그 속성과 같은 값을 가지는 기존의 레코드가 존재하는지 확인하는 SQL 쿼리를 실행합니다.

이 헬퍼에는 유일성 체크의 기간을 제한하기 위해 사용 가능한 `:scope` 옵션이 있습니다.

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "년에 1회만 사용할 수 있습니다." }
end
```

`:scope` 옵션을 통해서 발생할 수 있는 잘못된 유일성 제약 처리를 피하기 위해
데이터베이스 제약을 사용하고 싶은 경우에는 두 컬럼 모두에 유일성 제약을 걸어야
합니다. [MySQL 매뉴얼](http://dev.mysql.com/doc/refman/5.7/en/multiple-column-indexes.html)의
다중 컬럼 인덱스나 [PostgreSQL 매뉴얼](http://www.articlegresql.org/docs/current/static/ddl-constraints.html)의
여러 컬럼에 걸친 유일성 제약에 대한 예제를 참고하세요.

이 헬퍼에는 `:case_sensitive`라는 옵션도 있습니다. 이것은 제약조건을 검사할
때에 대소문자를 구분할지를 지정합니다. 이 옵션의 기본값은 true입니다.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING: 데이터베이스에 따라서, 검색시에 대소문자를 구별하지 않게끔 설정되어있는 경우도 있습니다.

기본 에러 메시지는 _"has already been taken"_ 입니다.

### `validates_with`

이 헬퍼는 검증 전용의 클래스에 레코드를 넘깁니다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "이 사람은 나쁜 사람입니다."
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

NOTE: `record.errors[:base]`에 추가되는 에러는 특정 속성에 대한 것이 아닌,
그 레코드 전체의 상태에 대한 것입니다.

`validates_with`는 유효성 검사에 사용하는 하나의 클래스, 또는 클래스의 목록을
인수로 받습니다. `validates_with`에는 기본 에러 메시지가 없으며, 필요하다면
넘긴 검증용 클래스에서 레코드의 에러 컬렉션에 직접 추가해야합니다.

검증 메소드를 구현하기 위해서는 `record` 파라미터를 받아야 하며, 이 파라미터를
통해 검증될 레코드가 넘겨지게 됩니다.

다른 유효성 검사와 마찬가지로 `validates_with` 헬퍼에서도 `:if`, `:unless`,
`:on` 옵션을 사용할 수 있습니다. 이외의 옵션을 넘길 경우, 검증용 클래스에
`options` 해시로 넘겨지게 됩니다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any?{|field| record.send(field) == "Evil" }
      record.errors[:base] << "이 사람은 나쁜 사람입니다."
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

이 검증용 클래스는 애플리케이션의 생애 주기 내에서 *단 한번만 초기화*된다는
점을 기억해주세요. 검증이 이루어질 때마다 초기화되지 않으므로, 인스턴스 변수를
사용할 경우에는 충분히 주의해주세요.

작성한 검증용 클래스가 복잡해져서 인스턴스 변수를 사용하고 싶어질 경우에는,
루비 객체를 그냥 사용할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors[:base] << "이 사람은 나쁜 사람입니다."
    end
  end

  # ...
end
```

### `validates_each`

이 헬퍼는 1개의 블록에 대해서 속성을 검사합니다. 정의되어 있는 검증용 함수는
없으므로 블록을 사용하는 검사를 직접 작성하고, `validates_each`에 넘기는 모든
속성에 대해서 블록을 통해 테스트를 수행합니다. 아래의 예제에서는 성과 이름이
대문자로만 시작하도록 하고 있습니다.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[a-z]/
  end
end
```

이 블록은 레코드와 속성의 이름, 그리고 속성의 값을 넘겨줍니다. 블록에서
이것들을 사용해 데이터가 올바른지를 체크할 수 있습니다. 검증에 실패한 경우에는
모델에 에러메시지를 추가하여 검증이 무효가 되도록 해주세요.

공통의 검증 옵션
-------------------------

유효성 검사에서 공통적으로 사용 가능한 옵션에 대해 설명합니다.

### `:allow_nil`

`:allow_nil` 옵션은 대상의 값이 `nil`인 경우에 검증을 시도하지 않습니다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value}은(는) 유효한 값이 아닙니다." }, allow_nil: true
end
```

### `:allow_blank`

`:allow_blank` 옵션은 `:allow_nil` 옵션과 비슷합니다. 이 옵션을 사용하면,
속성의 값이 `blank?`에 해당하는 경우 검증을 시도하지 않습니다. `blank?`로
true를 반환하는 값은 `nil`과 공백문자를 포함합니다.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end

Topic.create(title: "").valid?  # => true
Topic.create(title: nil).valid? # => true
```

### `:message`

이전에도 보였듯, 검증에 실패 했을 때 `errors` 컬렉션에 추가될 에러 메시지를
`:message` 옵션으로 설정할 수 있습니다. 이 옵션을 사용하지 않는 경우,
Active Record는 검증 헬퍼의 기본 에러 메시지를 사용합니다. `:message` 옵션은
`String`이나 `Proc`을 받습니다.

문자열 `:message` 값은 `%{value}`, `%{attribute}`, `%{model}`를 받을 수 있으며
이것들은 검증이 실패했을 때에 자동으로 각각의 값으로 대체됩니다.

`Proc`을 `:message` 값으로 사용하는 경우 내부에 검증되는 객체와 `:model`,
`:attribute`, `:value`가 들어 있는 해시 객체를 넘깁니다.

```ruby
class Person < ApplicationRecord
  # Hard-coded message
  validates :name, presence: { message: "must be given please" }

  # 메시지는 동적인 값입니다. %{value}는 속성의 실제 값으로 대체되며,
  # %{attribute}와 %{model}도 사용 가능합니다.
  validates :age, numericality: { message: "%{value} seems wrong" }

  # Proc
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}!, #{data[:value]} is taken already! Try again #{Time.zone.tomorrow}"
      end
    }
end
```

### `:on`

`:on` 옵션은 유효성 검사의 실행 타이밍을 지정합니다. 기본적으로 내장 검증 헬퍼는 저장할 때에 실행됩니다. 이것은 레코드의 생성할 때, 갱신할 때 모두 실행됩니다. 실행 타이밍을 변경하고 싶은 경우 `on: :create`를 지정하면 레코드가 생성될 때만 검증이 수행되며 `on: :update`를 지정하면 레코드를 변경할 때만 검증이 수행됩니다.

```ruby
class Person < ApplicationRecord
  # 값이 중복되어 있어도 email을 변경할 수 있음
  validates :email, uniqueness: true, on: :create

  # 새 레코드를 저장할 때에 숫자가 아닌 나이 표현을 사용할 수 있음
  validates :age, numericality: true, on: :update

  # 기본 (생성할 때와 변경할 때 모두 검증을 사용한다)
  validates :name, presence: true
end
```

또는 별도의 컨텍스트를 넘길수도 있습니다. 이를 사용하려면 `valid?`와
`invalid?`, `save` 호출 시에 명시적으로 해당 컨텍스트 이름을 넘겨야 합니다.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end

person = Person.new
```

`person.valid?(:account_setup)`는 모델을 저장하지 않고 위의 두 검증을
실행합니다. 그리고 `person.save(context: :account_setup)`는 `person`을
저장하기 전에 `account_setup` 컨텍스트 하에서 검증합니다. 이러한 명시적인
컨텍스트 지정을 사용하는 경우에는 해당하는 컨텍스트의 검증과 컨텍스트가
존재하지 않는 검증만을 사용합니다.

엄격한 유효성 검사
------------------

객체가 유효하지 않을 경우에 `ActiveModel::StrictValidationFailed`가
발생하도록 할 수 있습니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end

Person.new.valid?  # => ActiveModel::StrictValidationFailed: 반드시 이름을 입력해야 합니다.
```

다른 예외를 `:strict` 옵션으로 추가할 수도 있습니다.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

Person.new.valid?  # => TokenGenerationException: 토큰이 공백일 수 없습니다.
```

조건부 유효성 검사
----------------------

특정 조건을 만족하는 경우에만 검증을 실행하고 싶을 때가 있습니다.
`:if` 옵션이나 `:unless` 옵션을 사용하는 것으로 조건을 지정할 수 있습니다.
인수로는 심볼, 문자열, `Proc`이나 `Array`를 사용할 수 있습니다. `:if` 옵션은
특정 조건을 만족하는 경우에 유효성 검사를 **실행해야 하는** 경우에 사용합니다.
특정 조건을 만족하는 경우에 유효성 검사를 **실행하면 안되는** 경우에는
`:unless` 옵션을 사용합니다.

### `:if`나 `:unless`에서 심볼 사용하기

유효성 검사를 실행하기 직전에 호출될 메소드의 이름을 심볼의 형태로 `:if`나
`:unless`에 지정할 수 있습니다. 이것은 가장 빈번하게 사용되는 방식입니다.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### `:if`나 `:unless`에서 문자열 사용하기

문자열을 사용하는 것도 가능합니다. 이 문자열은 나중에 `eval`을 통해 평가되므로,
실행 가능한 올바른 Ruby 코드를 포함해야 합니다. 이 방법은 문자열이 충분히 짧은
경우에만 사용하는 것이 좋습니다.

```ruby
class Person < ApplicationRecord
  validates :surname, presence: true, if: "name.nil?"
end
```

### `:if`나 `:unless`에서 Proc 사용하기

호출하고 싶은 `Proc` 객체를 `:if`나 `:unless`에서 사용할 수 있습니다.
`Proc` 객체를 사용하면 각각의 메소드를 지정하는 대신, 바로 조건을 적을 수
있다는 장점이 있습니다. 한 줄로 해결 가능한 경우에 많이 사용합니다.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

### 조건부 유효성 검사를 그룹화하기

때때로 1개의 조건을 여러 유효성 검사에서 사용할 수 있다면 편리한 경우가
있습니다. 이것은 `with_options` 를 사용하면 간단하게 구현할 수 있습니다.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options` 블록에 있는 모든 유효성 검사는 `if: :is_admin?`라는 조건이
포함됩니다.

### 유효성 검사의 조건을 결합하기

반대로 유효성 검사의 실행 조건을 여러개 정의하고 싶은 경우, `Array`를 사용할
수 있습니다. 동일한 유효성 검사에 대해서 `:if`와 `:unless`를 모두 사용할 수
있습니다.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: ["market.retail?", :desktop?]
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

여기에서는 `:if` 조건이 모두 `true`이고, `:unless` 조건이 하나도 `true`가 아닌
경우에만 실행됩니다.

커스텀 유효성 검사를 실행하기
-----------------------------

내장 검증 헬퍼만으로는 부족한 경우, 원하는 유효성 검증자나 검증 메소드를 작성할 수 있습니다.

### 커스텀 유효성 검증자

커스텀 유효성 검증자(validator)는 `ActiveModel::Validator`을 확장한 클래스입니다. 여기에서는 `validate` 메소드를 구현할 필요가 있습니다. 이 메소드는 레코드를 하나를 인수로 받고, 받은 레코드에 대해서 검증을 수행합니다. 커스텀 유효성 검증자는 `validates_with` 메소드를 이용해서 호출할 수 있습니다.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.starts_with? 'X'
      record.errors[:name] << '이름이 X로 시작해야 합니다.' 
    end
  end
end

class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

각각의 속성을 검증하기 위한 커스텀 유효성 검증자를 추가하기 위해서는
`ActiveModel::EachValidator`를 사용하는 것이 가장 간단하고 쉽습니다. 이 경우,
커스텀 유효성 검증자는 `validate_each` 메소드를 구현해야할 필요가 있습니다.
이 메소드는 그 인스턴스에 대응하는 레코드, 속성의 이름과 그 값을 인자로 넘겨
받습니다.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "은(는) 올바른 이메일 주소가 아닙니다.")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

위의 예제에서 볼 수 있듯, 기존의 유효성 검사와 커스텀 검사를 동시에 사용할 수 있습니다.

### 커스텀 메소드

모델의 상태를 확인하고, 유효하지 않은 경우에 `errors` 컬렉션에 에러 메시지를
추가하는 메소드를 만들 수도 있습니다. 이 메소드를 통해 유효성 검사를 하기
위해서는 `validate`([API](http://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate))
클래스 메소드에 검증 메소드를 가리키는 심볼을 넘길 필요가 있습니다.

하나의 `validate` 메소드에는 여러 개의 심볼을 넘길 수 있습니다. 이 메소드들은
등록된 순서대로 실행됩니다.

`valid?` 매소드는 errors 컬렉션이 비어있는지 확인하므로, 커스텀 검증 메소드는
검증이 실패하기 바라는 경우에 에러를 추가해야 합니다.

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, ": 과거의 날짜는 사용할 수 없습니다.")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "합계보다 클 수 없습니다.")
    end
  end
end
```

이 검증들은 `valid?`가 호출될 때 실행됩니다. 커스텀 유효성 검사가 실행되는
시점은 `:on` 옵션을 통해서 변경할 수 있습니다. 예를 들어, `validate`에 대해서
`on: :create` 또는 `on: :update`를 설정할 수 있습니다.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

검증 에러 사용하기
------------------------------

Rails에는 이미 설명한 `valid?`나 `invalid?` 메소드 이외에도, `errors` 컬렉션을
다루는 메소드가 여럿 있습니다.

아래는 자주 사용되는 메소드 목록입니다. 사용가능한 모든 메소드 목록에 대해서는
`ActiveModel::Errors` 문서를 참조해주세요.

### `errors`

모든 에러를 포함하는 `ActiveModel::Errors` 클래스의 인스턴스를 하나 반환합니다.
키는 속성명, 값은 모든 에러 문자열의 배열입니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.messages
 # => {:name=>["을 비워둘 수 없습니다.", "이 너무 짧습니다. (최소 3글자)"]}

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors.messages # => {}
```

### `errors[]`

`errors[]` 는 어떤 속성에 대한 에러 메시지를 확인하고 싶을 때에 사용하며, 어떤
속성에 대한 모든 에러 메시지를 포함하는 문자열 배열을 반환합니다. 하나의
문자열 당 하나의 에러 메시지입니다. 속성에 관한 에러가 없는 경우, 빈 배열을
반환합니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors[:name] # => []

person = Person.new(name: "JD")
person.valid? # => false
person.errors[:name] # => ["이 너무 짧습니다(최소 3글자)."]

person = Person.new
person.valid? # => false
person.errors[:name]
# => ["공백으로 둘 수 없습니다.", "이 너무 짧습니다(최소 3글자)."]
```

### `errors.add`

`add` 메소드를 사용해서, 어떤 속성에 대한 메시지를 직접 추가할 수 있습니다.
인수로 속성명과 에러 메시지를 받습니다.

`errors.full_messages`나 `errors.to_a` 메소드를 사용해서, 사용자가 실제로 보게
될 양식에 에러 메시지를 출력할 수 있습니다. 이 경우, 각각의 메시지에는
각 속성명이 추가되며, 그 첫번째 글자는 대문자로 변경됩니다. `add` 메소드는
에러 메시지를 추가하고 싶은 속성명, 그리고 메시지의 내용을 인자로
넘겨받습니다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, "에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors[:name]
# => ["에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+="]

person.errors.full_messages
# => ["Name 에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+="]
```

`errors#add` 대신에 `<<`를 사용하여 `errors.messages`에 에러를 추가할 수도
있습니다.

```ruby
  class Person < ApplicationRecord
    def a_method_used_for_validation_purposes
      errors.messages[:name] << "에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+="
    end
  end

  person = Person.create(name: "!@#")

  person.errors[:name]
   # => ["에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+="]

  person.errors.to_a
   # => ["Name 에는 다음의 문자를 포함할 수 없습니다. !@#%*()_-+="]
``

### `errors.details`

`errors.add` 메소드를 사용하여 에러를 반환한 검증자의 정보를 추가할 수
있습니다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters)
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters}]
```

`errors.details`에 에러 메시지를 좀 더 자세하게 작성하고 싶다면, `errors.add`에
추가로 정보를 넘기면 됩니다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters, not_allowed: "!@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters, not_allowed: "!@#%*()_-+="}]
```

모든 Rails의 내장 검증자는 details 해시에 그에 맞는 검증자 형식과 함께 에러를
추가합니다.

### `errors[:base]`

개별 속성에 대한 메시지를 추가하는 대신, 객체 자체에 대한 에러 메시지를 추가할
수도 있습니다. 속성의 값에 관계 없이 객체를 유효하지 않다고 판정하고 싶은
경우에 사용할 수 있습니다. `errors[:base]` 는 배열이므로 여기에 문자열을
추가하기만 하면 됩니다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors[:base] << "이 사람은 다음과 같은 이유로 가입할 수 없습니다. 이하 생략"
  end
end
```

### `errors.clear`

`clear` 메소드는 `errors` 컬렉션에 포함되는 메시지를 모두 삭제하고 싶을 경우에
사용할 수 있습니다. 유효하지 않은 객체에 대해서 `errors.clear`를 호출하더라도
유효한 객체가 되지 않음을 주의해 주세요. `errors`의 값은 없어집니다만,
`valid?`나 객체를 저장하는 어떤 메소드(save, update, ...)가 호출 될 경우에
유효성 검사가 재실행되기 때문입니다. 그 때 다시 검증에 실패하면 `errors`
컬렉션에 다시 에러 메시지가 쌓이게 됩니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors[:name]
# => ["은 공백일 수 없습니다.", "이 너무 짧습니다 (최소 3글자)"]

person.errors.clear
person.errors.empty? # => true

p.save # => false

p.errors[:name]
# => ["은 공백일 수 없습니다.", "이 너무 짧습니다 (최소 3글자)"]
```

### `errors.size`

`size` 메소드는 그 객체가 가지고 있는 에러 메시지의 전체 갯수를 반환합니다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.size # => 2

person = Person.new(name: "Andrea", email: "andrea@example.com")
person.valid? # => true
person.errors.size # => 0
```

검증 에러를 뷰에서 출력하기
-------------------------------------

모델을 만들고, 유효성 검사를 추가한 뒤, 웹페이지에서 양식을 사용해서 그 모델을
생성할 수 있게 되면 그 모델의 검증이 실패했을 때에 에러 메시지를 표시할 수
있길 바랄 겁니다.

에러 메시지의 표시 방법은 애플리케이션마다 다르기 때문에, Rails에서는 이런
메시지를 직접 생성하는 뷰 헬퍼를 제공하지 않습니다. 대신 Rails는 일반적인
검증 메소드가 여럿 제공되므로 커스텀 메소드를 만드는 것도 비교적 간단합니다.
또한, scaffold를 사용해서 뷰를 생성하게 되면, 그 모델의 에러 메시지를 전부
표시할 수 있는 ERB가 `_form.html.erb`에 추가됩니다.

`@article`라는 이름의 인스턴스 변수에 보존된 모델이 있다고 가정합시다.

```ruby
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> 때문에 이 글을 저장할 수 없습니다:</h2>

    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

그리고 Rails의 양식 헬퍼를 사용해서 양식을 생성하는 경우, 어떤 필드에서
검증 에러가 발생하면 그 필드 를 감싸는 `<div>` 태그가 자동적으로 추가됩니다.

```
<div class="field_with_errors">
<input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

이 div 태그에 원하는 스타일을 적용할 수 있습니다. Rails가 생성하는
scaffold에 의해서 아래와 같은 css 규칙이 추가됩니다.

```
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

이 CSS는 에러를 포함하는 항목을 2 픽셀의 외각선으로 둘러쌉니다.
