액티브 레코드 유효성 검증 {#active-record-validations}
=========================

본 가이드는 액티브 레코드의 유효성 검사 기능을 사용하여 데이터베이스로 이동하기 전에 객체의 상태를 확인하는 방법을 설명한다.

본 가이드를 읽은 후 아래의 내용을 알게 될 것이다.

* 내장된 액티브 레코드 유효성 검증 헬퍼 메소드를 사용하는 방법.
* 사용자 자신이 직접 유효성 검증 메소드를 만드는 방법.
* 유효성 검증 프로세스에서 생성된 에러 메시지를 처리하는 방법.

--------------------------------------------------------------------------------

유효성 검증 개요 {#validations-overview}
--------------------

아래에 매우 간단한 유효성 검증 예가 있다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

보다시피, 위의 유효성 검증은 `Person`이 `name` 속성 없이는 유효하지 않다는 것을 알려 준다. 두 번째 `Person` 객체는 유효하지 않으므로 데이터베이스에 저장되지 않는다.

자세한 내용을 살펴보기 전에, 유효성 검증이 애플리케이션의 큰 그림에 어떻게 적용되는지에 대해 언급할 것이다.

### 유효성 검증을 사용하는 이유 {#why-use-validations?}

유효성 검증은 유효한 데이터만 데이터베이스에 저장되도록 하는데 사용된다. 예를 들어, 모든 사용자가 유효한 전자 메일 주소와 우편 주소를 제공하도록 하는 것이 애플리케이션에 중요할 수 있다. 모델에서의 유효성 검증은 유효한 데이터만 데이터베이스에 저장되도록 하는 가장 좋은 방법이다. 데이터베이스와 무관하며 최종 사용자가 피해 갈 수 없으며 테스트 및 유지 관리가 편리하다. 레일스는 사용하기 쉽고 일반적인 요구에 맞는 내장 헬퍼 메소드를 제공하며 자신만의 검증 메소드도 만들 수 있다.

네이티브 데이터베이스 제한 조건, 클라이언트 측 유효성 검증 및 컨트롤러 레벨 유효성 검증을 포함하여, 데이터베이스에 데이터를 저장하기 전에 데이터 유효성 검증하는 몇 가지 다른 방법이 있다. 장단점은 아래와 같다.

* 데이터베이스 제약 조건 및 / 또는 저장 프로시저는 유효성 검사 메커니즘을 데이터베이스에 따라 달라지며 테스트 및 유지 관리를 더욱 어렵게 만들 수 있다. 그러나 다른 애플리케이션이 현재 애플리케이션이 사용 중인 데이터베이스를 사용하는 경우 데이터베이스 레벨에서 일부 제약 조건을 사용하는 것이 좋다. 또한 데이터베이스 레벨 유효성 검증은 다른 방법으로는 구현하기 어려운 부분(예 : 많이 사용되는 테이블의 유일성 검증)를 안전하게 처리 할 수 있다.
* 클라이언트측 유효성 검증은 유용 할 수 있지만 단독으로 사용하는 경우 일반적으로 신뢰할 수 없다. 자바스크립트를 사용하여 구현된 경우 사용자 브라우저에서 자바스크립트가 꺼져 있으면 아무런 소용이 없다. 그러나 다른 기술과 결합하면 클라이언트측 유효성 검증은 사용자가 웹사이트를 사용할 때 즉각적인 피드백을 제공하는 편리한 방법이 될 수 있다.
* 컨트롤러 레벨의 유효성 검증은 사용하기가 쉽지만 종종 다루기 어렵고 테스트 및 유지 관리가 어려워 진다. 가능할 때마다 컨트롤러를 스키니(skinny) 상태로 유지하는 것이 좋은데 장기적으로는 애플리케이션을 즐겁게 사용할 수 있기 해 주기 때문이다.

특별한 경우에만 이러한 방법을 선택하기 바란다. 레일스 팀은 대부분의 상황에서 모델 수준의 검증이 가장 적합하다고 생각한다.

### 유효성 검증이 발생하는 시점 {#when-does-validation-happen?}

데이터베이스내에의 레코드에 해당하는 객체와 그렇지 않은 객체, 두 가지 종류의 액티브 레코드 객체가 있다. 예를 들어 `new` 메소드를 사용하여 새로운 객체를 생성할 때 해당 객체는 아직 데이터베이스에 존재하지 않는다. 해당 객체에 대해 `save`를 호출하면 비로소 해당 데이터베이스 테이블에 저장된다. 액티브 레코드는`new_record?` 인스턴스 메소드를 사용하여 해당 객체가 이미 데이터베이스에 존재하는지 여부를 판단한다. 아래와 같은 간단한 액티브 레코드 클래스를 보면,

```ruby
class Person < ApplicationRecord
end
```

`rails console` 출력을 보면 작동 방식을 확인할 수 있다.

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

새 레코드를 작성하고 저장하면 SQL `INSERT` 작업이 데이터베이스로 전송된다. 기존 레코드를 업데이트하면 대신 SQL `UPDATE` 작업이 전송된다. 유효성 검증은 일반적으로 이러한 명령이 데이터베이스로 전송되기 전에 실행된다. 유효성 검증에 실패하면 객체가 유효하지 않은 것으로 표시되고 액티브 레코드는 `INSERT` 또는 `UPDATE` 작업을 수행하지 않는다. 이로써 데이터베이스에 유효하지 않은 객체를 저장하지 않게 되는 것이다. 객체를 생성, 저장 또는 업데이트 할 때 특정 유효성 검증을 실행하도록 선택할 수 있다.

CAUTION: 데이터베이스에서 객체의 상태를 변경하는 방법은 여러 가지가 있다. 일부 메소드는 유효성 검증을 트리거하지만 일부 메소드는 그렇지 않다. 따라서, 조심하지 않으면 데이터베이스의 객체를 유효하지 않은 상태로 저장할 수 있다.

아래와  같은 메소드는 유효성 검증을 트리거하고 객체가 유효한 경우에만 데이터베이스에 저장한다.

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

bang 버전 (예 : `save!`)은 레코드가 유효하지 않은 경우 예외를 발생시킨다. bang 이외의 버전은 그렇지 않다. 즉, `save`와 `update`는 데이터가 유효하지 않은 경우 `false`를 반환하고 `create`는 객체를 반환한다.

### 유효성 검증 피하기 {#skipping-validations}

아래의 메소드는 유효성 검증을 하지 않기 때문에 유효성 여부에 관계없이 객체를 데이터베이스에 저장한다. 따라서 주의해서 사용해야 한다.

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

`save`는 인수로 `validate: false`를 전달하면 유효성 검증 단계를 건너 뛸 수 있다. 이 방법은 주의해서 사용해야 한다.

* `save(validate: false)`

### `valid?`와 `invalid?` 메소드 {#valid?-and-invalid?}

액티브 레코드 객체를 저장하기 전에 레일스는 유효성 검증을 실행한다. 이러한 유효성 검증으로 오류가 발생하면 레일스는 객체를 저장하지 않는다.

이러한 유효성 검증을 직접 실행할 수도 있다. `valid?`는 유효성 검증을 트리거하고 객체에 오류가 없으면 true를 반환하고 그렇지 않으면 false를 반환한다. 위에서 본 것처럼,

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

액티브 레코드가 유효성 검증을 수행 한 후 발견 된 에러는 에러 모음을 반환하는`errors.messages` 인스턴스 메소드를 통해 액세스 할 수 있다. 정의에 따르면 유효성 검증을 실행 한 후 이 콜렉션이 비어 있으면 객체가 유효한 것이다.

`new` 메소드로 만들어진 객체는 기술적으로 유효하지 않더라도 에러를 보고하지 않는다. 왜냐하면 `create` 또는 `save` 메소드와 같이 객체가 저장되는 경우에만 유효성 검증이 자동으로 실행되기 때문이다.

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

`invalid?`는 단순히 `valid?`의 반대되는 메소드다. 객체에서 에러가 발견되면 true를 반환하고 그렇지 않으면 false를 반환하는 방식으로 데이터의 유효성을 검증한다.

### `errors[]`

객체의 특정 속성이 유효한지 확인하기 위해 `errors[:attribute]`를 사용할 수 있다. `:attribute`에 대한 모든 에러 배열을 반환한다. 지정된 속성에 에러가 없으면 빈 배열이 반환된다.

이 방법은 에러 컬렉션만 검사하고 유효성 검증 자체를 트리거하지 않기 때문에 유효성 검사가 실행된 _이후_ 에만 유용하다. 객체의 유효성을 전체적으로 검증하지 않기 때문에 위에서 설명한 `ActiveRecord::Base#invalid?` 메소드와 다르다. 단지 객체의 개별 속성에 에러가 있는지 여부만 확인한다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> Person.new.errors[:name].any? # => false
>> Person.create.errors[:name].any? # => true
```

[Working with Validation Errors](#working-with-validation-errors) 섹션에서 유효성 검증 에러에 대해 자세히 설명한다.

### `errors.details`

어떤 속성이 유효하지 않은 속성에서 실패했는지 확인하려면 `errors.details[:attribute]`를 사용하면 된다. 이것은 유효성 검사기의 심볼을 얻기 위해`:error` 키를 포함하는 해시 배열을 반환한다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> person = Person.new
>> person.valid?
>> person.errors.details[:name] # => [{error: :blank}]
```

사용자 지정 유효성 검사기에서 `details`를 사용하는 방법은 [Working with Validation Errors](#working-with-validation-errors) 섹션에서 다룬다.

유효성 검증 헬퍼 메소드 {#validation-helpers}
------------------

액티브 레코드는 클래스 정의 내에서 직접 사용할 수 있는 사전 정의 된 많은 검증 헬퍼를 제공한다. 이러한 헬퍼 메소드는 일반적인 유효성 검증 규칙을 제공한다. 유효성 검증이 실패 할 때마다 에러 메시지가 개체의 `errors` 컬렉션에 추가되고 이 메시지는 유효성이 검증되는 속성과 연관된다.

각 헬퍼 메소드는 다수의 속성 이름을 허용하므로 한 줄 코드로 여러 종류의 속성에 동일한 종류의 유효성 검증을 추가 할 수 있다.

이들 모두는 `:on` 및 `:message` 옵션을 허용하는데, 이 옵션은 유효성 검증을 언제 실행할지, 실패할 경우 에러 컬렉션에 어떤 메시지를 추가해야 하는지 정의한다. `:on` 옵션은 `:create` 또는 `:update` 값 중 하나를 사용한다. 유효성 검증 헬퍼 메소드 각각에 대한 기본 에러 메시지가 있다. 이 메시지는 `:message` 옵션이 지정되지 않은 경우에 사용된다. 사용 가능한 헬퍼 메소드 각각을 살펴 보도록 한다.

### `acceptance`

이 메소드는 폼을 서밋할 때 사용자 인터페이스의 체크박스가 선택되었는지 확인한다. 일반적으로 사용자가 애플리케이션의 서비스 약관에 동의하거나 일부 텍스트를 읽었는지 또는 유사한 상황을 확인해야 할 때 사용된다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

이 검사는 `terms_of_service`가 `nil`이 아닌 경우에만 수행된다. 이 헬퍼 메소드의 기본 에러 메시지는 _"must be accepted"_ 이다. `message` 옵션을 통해 사용자 정의 메시지를 전달할 수도 있다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

수락하는 것으로 간주될 값을 결정하는`:accept` 옵션도 지정할 수 있다. 기본값은 `['1 ', true]`이며 쉽게 변경할 수 있다.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

이 유효성 검증은 웹 애플리케이션에만 적용되며 이 '수락'은 데이터베이스의 어느 곳에나 기록할 필요가 없다. 해당 필드가 없으면 헬퍼 메소드는 가상 속성만 만들게 된다. 해당 필드가 데이터베이스에 존재하면 `accept` 옵션을 true로 설정하거나 포함해야 한다. 그렇지 않으면 유효성 검증이 실행되지 않는다.

### `validates_associated`

모델이 다른 모델과 연관되어 있고 유효성을 검증해야하는 경우에는 이 헬퍼 메소드를 사용해야 한다. 그러면 객체를 저장할 때 연관된 객체 각각에 대해 `valid?` 메소드를 호출하게 된다.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

이 유효성 검증은 모든 연관 형태에서 작동한다.

CAUTION: 서로간에 연관이 정의된 모델 양쪽에 `validates_associated`를 사용하지 않도록 한다. 각 모델에서 서로를 호출하여 무한 루프에 빠지기 때문이다.

`validates_associated`의 기본 에러 메시지는 _"is invalid"_ 이다. 연결된 각 객체는 자체에 `errors` 컬렉션를 포함한다. 그러나 이 에러 컬렉션은 호출 모델에 영향을 미치지 않는다.

### `confirmation`

정확히 동일한 내용을 수신해야하는 두 개의 텍스트 필드가있는 경우 이 헬퍼 메소드를 사용해야 한다. 이메일 주소나 비밀번호를 예로 들 수 있다. 이 유효성 검증은 확인되어야 하는 필드 이름 끝에 "_confirmation"이 추가된 가상 속성을 생성한다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

뷰 템플릿 파일에서는 아래와 같이 사용할 수 있다.

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

이것은 `email_confirmation`이 `nil`이 아닌 경우에만 수행된다. 확인을 요구하려면 확인 속성에 대한 존재 여부을 추가해야 한다 (이 안내서의 뒷부분에서 `presence` 옵션에 대해서 살펴 볼 것이다).

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

또한 `:case_sensitive` 옵션을 추가하면 확인 제약 조건이 대소 문자를 구분할지 여부를 정의하는 데 사용할 수 있다. 이 옵션의 기본값은 true이다.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

이 헬퍼 메소드의 기본 에러 메시지는 _"doesn't match confirmation"_ 이다.

### `exclusion`

이 헬퍼 메소드는 속성 값이 주어진 세트에 포함되지 않았는지 검증한다. 실제로 이 세트는 열거 가능한(enumerable) 객체일 수 있다.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

`exclusion` 헬퍼는 검증이 필요한 속성에 허용되지 않는 값들을 받는`:in` 옵션을 가지고 있다. `:in` 옵션에는 원한다면 같은 목적으로 사용할 수 있는`:within`이라는 별칭도 있다. 위의 예제는 `:message` 옵션을 사용하여 속성 값을 포함하는 방법을 보여 준다. 메시지 인수에 대한 전체 옵션은 [message documentation](#message)를 참조한다.

기본 에러 메시지는 _"is reserved"_ 이다.

### `format`

이 헬퍼는 속성 값이 `:with` 옵션을 사용하여 지정한 정규 표현식과 일치하는지 테스트하여 속성 값의 유효성을 검증한다.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

또는 `:without` 옵션을 사용하여 지정된 속성이 정규 표현식과 일치하지 _않도록_ 요구할 수 있다.

기본 에러 메시지는 _"is invalid"_ 이다.

### `inclusion`

이 헬퍼는 속성 값이 주어진 집합에 포함되어 있는지 확인합니다. 실제로 이 세트는 열거 가능한(enumerable) 객체일 수 있다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

`inclusion` 헬퍼에서는 `:in` 옵션을 사용하여 허용되는 값들을 지정할 수 있다. `:in` 옵션에는 원한다면 같은 목적으로 사용할 수 있는 `:within`이라는 별칭도 있다. 이전 예제는`:message` 옵션을 사용하여 속성 값을 포함하는 방법을 보여 준다. 전체 옵션은 [message documentation](#message)를 참조한다.

이 헬퍼의 기본 에러 메시지는 _"is not included in the list"_ 이다.

### `length`

이 헬퍼는 속성 값의 길이를 검사한다. 다양한 옵션을 제공하므로 여러가지 방법으로 길이 제한을 지정할 수 있다.

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

사용 가능한 길이 제한 옵션은 아래와 같다. 

* `:minimum` - 해당 속성은 지정된 길이보다 작을 수 없다.
* `:maximum` - 해당 속성은 지정된 길이보다 길 수 없다.
* `:in` (or `:within`) - 해당 속성의 길이는 주어진 구간에 포함되어야 한다. 이 옵션의 값은 range 형이어야 한다.
* `:is` - 해당 속성 길이는 주어진 값과 같아야 한다.

기본 에러 메시지는 사용하는 길이 유효성 검증 형태에 따라 다르다. `:wrong_length`,  `:too_long`, `:too_short` 옵션과 사용 중인 길이 제한 조건에 해당하는 숫자의 placeholder로 사용하는 `%{count}`를 사용하여 이러한 메시지를 개인화할 수 있다. 여전히 `:message` 옵션을 사용하여 에러 메시지를 지정할 수 있다.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

기본 에러 메시지는 복수형(예 : "is too short (minimum is %{count} characters)")이라는 것에 주의한다. 이러한 이유로 `:minimum`이 1 인 경우 사용자 지정 메시지를 제공하거나 `presence: true`를 대신 사용해야 한다. `:in` 또는 `:within`의 하한이 1 인 경우, 사용자 지정 메시지를 제공하거나 `length` 이전에 `presence`를 호출해야 한다.

### `numericality`

이 헬퍼 메소드는 속성에 숫자 값만 있는지 확인한다. 기본적으로 추가로 지정할 수 있는 부호와 이후의 정수 또는 부동 소수점 숫자가 일치하는지 검사할 것이다. 정수만 허용하도록 지정하려면 `:only_integer`를 true로 설정한다.

`:only_integer`를 true로 지정하면 아래와 같은 정규표현식을 사용하여

```ruby
/\A[+-]?\d+\z/
```

속성 값을 검사할 것이다. 그렇지 않을 경우 속성 값을 `Float`를 사용하여 실수로 변환할 것이다.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

`:only_integer` 외에도 아래의 옵션을 사용하여 속성 값에 제약 조건을 추가한다.

* `:greater_than` - 속성 값이 특정 값보다 커야 함을 지정한다. 이 옵션의 기본 에러 메시지는 _"must must be greater than %{count}"_ 이다.
* `:greater_than_or_equal_to` - 속성 값이 특정 값보다 크거나 같아야 함을 지정한다. 이 옵션의 기본 에러 메시지는 _"must be greater than or equal to %{count}"_ 이다.
* `:equal_to` - 속성 값이 특정 값과 같아야 함을 지정한다. 이 옵션의 기본 에러 메시지는 _"must be equal to %{count}"_ 이다.
* `:less_than` - 속성 값이 특정 값보다 작아야 함을 지정한다. 이 옵션의 기본 에러 메시지는 _"must be less than %{count}"_ 이다.
* `:less_than_or_equal_to` - 속성 값이 특정 값보다 작거나 같아야 함을 지정한다. 이 옵션의 기본 에러 메시지는 _"must be less than or equal to %{count}"_ 이다.
* `:other_than` - 속성 값이 특정 값 이외의 값이어야 한다. 이 옵션의 기본 애로 메시지는 _"must be other than %{count}"_ 이다.
* `:odd` - 속성 값이 true로 설정되면 값이 홀수이어야 한다. 이 옵션의 기본 에러 메시지는 _ _"must be odd"_ 이다.
* `:even` - 속성 값이 true로 설정되면 값이 짝수이어야 한다. 이 옵션의 기본 에러 메시지는 _"must be even"_ 이다.

NOTE: 기본적으로 `numericality`는 `nil` 값을 허용하지 않는다. 그러나, `allow_nil: true` 옵션을 사용하면 허용할 수 있다.

기본 에러 메시지는 _"is not a number"_ 이다.

### `presence`

이 헬퍼는 지정된 속성이 비어 있지 않은지 확인한다. `blank?` 메소드를 사용하여 값이 `nil` 인지 또는 빈 문자열인지, 즉 비어 있거나 공백으로 구성된 문자열인지 확인한다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

모델간의 관계가 정의되어 있는지 확인하려면 관계 설정에 사용하는 외래 키가 아니라 관련 객체 자체가 있는지 테스트해야 한다. 이런 식으로 외래 키가 비어 있지 않을 뿐만 아니라 참조 된 객체가 존재하는지 확인한다.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, presence: true
end
```

반드시 존재해야 하는 연관 레코드의 유효성을 검증하려면 해당 관계 정의에 대해`:inverse_of` 옵션을 지정해야 한다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

`has_one` 또는 `has_many` 관계를 통해 연관된 객체가 있는지 검증할 경우에는 해당 객체가 `blank?` 또는 `marked_for_destruction?`이 아닌지 확인한다.

`false.blank?`가 true 값을 반환하기 때문에 논리값 데이터형을 가지는 필드의 존재를 검증하려면 아래의 검증 중 하나를 사용해야 한다.

```ruby
validates :boolean_field_name, inclusion: { in: [true, false] }
validates :boolean_field_name, exclusion: { in: [nil] }
```

이러한 유효성 검사 중 하나를 사용하면, 속성 값이 대부분의 경우 `NULL` 값을 가지는 `nil`이 **아님**을 확인한다.

### `absence`

이 헬퍼는 지정된 속성이 존재하지 않음을 검증한다. `present?` 메소드를 사용하여 값이 nil이 아니거나 빈 문자열, 즉 비어 있거나 공백으로 구성된 문자열이 아닌지 확인한다.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

모델간의 관계 정의가 존재하지 않음을 확인하려면, 관계 정의에 사용하는 외래 키가 아니라 관련 객체 자체가 존재하지 않음을 테스트해야 한다.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

존재해서는 안되는 연관 레코드의 유효성을 검증하려면 관계 정의에 `:inverse_of` 옵션을 지정해야 한다.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

`has_one` 또는 `has_many` 모델 관계를 통해 연관된 객체가 존재하지 않는 것을 검증하면 해당 객체가 `present?` 가 아니거나  `marked_for_destruction?`이 아님을 확인하게 된다.

`false.present?`가 false이므로 논리값을 가지는 필드가 존재하지 않음을 확인하려면`validates :field_name, exclusion: {in: [true, false]}`를 사용해야 한다.

기본 에러 메시지는 _"must be blank"_ 이다.

### `uniqueness`

이 헬퍼는 객체가 저장되기 직전에 유일한 속성값을 가지는지 확인한다. 데이터베이스에서 유일성 제한 조건을 작성하지 않으므로 서로 다른 두 개의 데이터베이스 연결이 유일한 값을 가져야 하는 특정 컬럼에 대해 동일한 값을 가지는 두 개의 레코드를 작성할 수 있게 된다. 따라서 이를 피하려면 데이터베이스의 해당 레코드에 유일한 인덱스를 작성해야 한다.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

해당 속성에서 동일한 값을 가진 기존 레코드를 검색하기 위해 모델 테이블에 대한 SQL 쿼리를 시행하므로써 유효성 검증이 발생하게 된다.

`:scope` 옵션을 이용하면 유일성 검사를 제한하는 데 사용되는 하나 이상의 속성을 지정할 수 있다.

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

`:scope` 옵션을 사용하여 유일성 검증의 위반 방지를 위해 데이터베이스 제한 조건을 작성하려면 데이터베이스의 두 컬럼 모두에 유일한 색인을 작성해야 한다. 다중 컬럼 인덱스에 대한 자세한 내용은 [the MySQL manual](https://dev.mysql.com/doc/refman/5.7/en/multiple-column-indexes.html)을 참조하거나 컬럼 그룹을 참조하는 유일성 제한 조건의 예는 [the PostgreSQL manual](https://www.postgresql.org/docs/current/static/ddl-constraints.html)을 참조한다.

`:case_sensitive` 옵션을 이용하면, 유일성 제약 조건이 대소 문자를 구분하는지 여부를 정의하는 데 사용할 수 있다. 이 옵션의 기본값은 true이다.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING. 일부 데이터베이스는 대소 문자를 구분하지 않는 검색을 수행하도록 설정되어 있다는 것에 주의한다.

기본 에러 메시지는 _"has already been taken"_ 이다.

### `validates_with`

이 헬퍼는 유효성 검증을 위해 별도의 클래스로 레코드를 전달한다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

NOTE: `record.errors[:base]`에 추가 된 에러는 특정 속성이 아니라 레코드의 전체 상태와 관련이 있다.

`validates_with` 헬퍼는 하나의 클래스 또는 클래스 목록을 취해서 유효성 검증에 사용한다. `validates_with`에 대한 기본 에러 메시지는 없다. 유효성 검증기 클래스의 레코드 에러 콜렉션에 수동으로 에러를 추가해야 한다.

`validate` 메소드를 구현하려면 검증 할 레코드인 `record` 매개 변수가 정의되어 있어야 한다.

다른 모든 유효성 검증과 마찬가지로 `validates_with`는 `:if`, `:unless` 및`:on` 옵션을 사용한다. 다른 옵션을 전달하면 해당 옵션을 유효성 검증 클래스에 `options`로 보낸다.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any?{|field| record.send(field) == "Evil" }
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

유효성 검증 클래스는 매 유효성 검증 실행마다가 아닌 전체 애플리케이션 수명주기 동안 *단 한 번만* 초기화되므로 내부에서 인스턴스 변수를 사용하는 데 주의해야 한다.

유효성 검증 클래스가 인스턴스 변수를 원할 정도로 복잡하다면 대신 **PORO**(Plain Old Ruby Object, 상속 받지 않는 단순 루비 객체, 譯註)를 손쉽게 사용할 수 있다.

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
      @person.errors[:base] << "This person is evil"
    end
  end

  # ...
end
```

### `validates_each`

이 헬퍼는 블록으로 넘겨 준 속성에 대해서 유효성을 검증한다. 사전 정의된 유효성 검증 기능은 없다. 블록을 사용하여 검증 기능을 작성해야 하며, `validates_each`에 전달된 모든 속성에 대해서 유효성을 검증하게 된다. 아래의 예에서는 이름과 성이 대문자로 시작하는지 검증한다.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end
```

블록은 레코드, 속성 이름 및 속성 값을 넘겨 받는다. 블록 내에서 유효한 데이터를 확인하려는 모든 작업을 수행 할 수 있다. 유효성 검증에 실패하면 모델에 에러 메시지를 추가하여 데이터가 유효하지 않게 된다.

일반적인 유효성 검증 옵션 {#common-validation-options}
-------------------------

아래는 일반적인 유효성 검사 옵션들이다.

### `:allow_nil`

`:allow_nil` 옵션은 검증되는 값이 `nil`인 경우 검증을 건너 뛴다.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

메시지 인수에 대한 전체 옵션은 [message documentation](#message)를 참조한다.

### `:allow_blank`

`:allow_blank` 옵션은`:allow_nil` 옵션과 유사하다. 이 옵션은 속성 값이`nil` 또는 빈 문자열과 같은 `blank?`인 경우 유효성 검증을 통과시킨다.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end

Topic.create(title: "").valid?  # => true
Topic.create(title: nil).valid? # => true
```

### `:message`

앞에서 본 것처럼 `:message` 옵션을 사용하면 유효성 검증에 실패할 때 `errors` 컬렉션에 추가될 메시지를 지정할 수 있다. 이 옵션을 사용하지 않으면 액티브 레코드는 각 유효성 검증 헬퍼에 대해 각각의 기본 에러 메시지를 사용한다. `:message` 옵션에 `String` 또는 `Proc`를 사용할 수 있다.

`String` `:message` 값은 `%{value}`, `%{attribute}`, `%{model}` 중 일부 또는 전부를 선택적으로 포함할 수 있으며, 유효성 검증에 실패하면 동적으로 대체된다. 이것은 I18n 젬을 사용하여 수행되며 placeholder는 정확히 일치해야 하고 공백은 허용되지 않는다.

`Proc` `:message` 값에는 두 개의 인수, 즉 검증되는 객체와, `:model`, `:attribute`, `:value` 세 개의 키-값 쌍이 있는, 해시가 제공된다.

```ruby
class Person < ApplicationRecord
  # 하드 코딩된 메시지
  validates :name, presence: { message: "must be given please" }

  # 동적 속성 값을 포함하는 메시지. 
  # %{value}는 속성의 실제 값으로 대체된다. 
  # %{attribute}, %{model}도 사용 가능하다.
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

`:on` 옵션을 사용하면 유효성 검증 시기를 지정할 수 있다. 내장된 모든 유효성 검증 헬퍼의 기본 동작은 저장시(새 레코드를 만들 때와 업데이트 할 때) 실행된다. 변경하려면 `on: :create`를 사용하여 새 레코드가 생성될 때만 유효성 검증을 실행하거나 `on: :update`를 사용하여 레코드가 업데이트될 때만 유효성 검증을 실행할 수 있다.

```ruby
class Person < ApplicationRecord
  # 이메일을 중복된 값으로 업데이트(update) 할 수 있다.
  validates :email, uniqueness: true, on: :create

  # 레코드를 생성(create)할 때는 연령 값이 숫자가 아니어도 된다.
  validates :age, numericality: true, on: :update

  # 기본 상태 (create, update 모두에서 유효성을 검증한다.)
  validates :name, presence: true
end
```

`on:`을 사용하여 사용자 정의 컨텍스트를 정의할 수 도 있다. 컨텍스트 이름을 `valid?`, `invalid?` 또는 `save`에 전달하여 사용자 정의 컨텍스트를 명시적으로 트리거해야 한다.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end

person = Person.new(age: 'thirty-three')
person.valid? # => true
person.valid?(:account_setup) # => false
person.errors.messages
 # => {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)`은 모델을 저장하지 않고 두 가지 유효성 검증을 모두 실행한다. `person.save(context: :account_setup)`은 저장하기 전에 `account_setup` 컨텍스트에서 `person`을 검증한다.

명시적 컨텍스트에 의해 유효성 검증이 트리거되면 해당 컨텍스트에 대한 유효성 검증과 컨텍스트가 없는 상태의 유효성 검증이 실행된다.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end

person = Person.new
person.valid?(:account_setup) # => false
person.errors.messages
 # => {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}
```

엄격한 유효성 검증 {#strict-validations}
------------------

유효성 검증을 엄격하게 지정하면 해당 객체가 유효하지 않은 경우 `ActiveModel::StrictValidationFailed`를 발생시킬 수도 있다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end

Person.new.valid?  # => ActiveModel::StrictValidationFailed: Name can't be blank
```

`:strict` 옵션에 사용자 정의 예외를 전달하는 기능도 있다.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

Person.new.valid?  # => TokenGenerationException: Token can't be blank
```

조건부 유효성 검증 {#conditional-validation}
----------------------

때로는 해당 predicate 메소드(true/false를 반환하는 메소드)가 만족될 때만 특정 객체에 대한 유효성 검증을 하는 것이 타당할 경우도 있을 것이다. `:if` 와 `:unless` 옵션에 심볼, `Proc` 또는 `Array`를 지정하여 이를 수행할 수 있다. 유효성 검증이 발생**해야** 하는 시기를 지정할 경우 `:if` 옵션을 사용할 수 있다. 유효성 검증이 발생하지 **않아야 하는** 시기를 지정할 경우 `:unless` 옵션을 사용할 수 있다.

### Using a Symbol with `:if` and `:unless`

`:if` 및 `:unless` 옵션을 유효성 검증이 발생하기 직전에 호출될 메소드 이름에 해당하는 심볼과 연결할 수 있다. 가장 일반적으로 사용되는 옵션이다.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Using a Proc with `:if` and `:unless`

`:if` 와 `:unless` 옵션을 호출될 `Proc` 객체와 연관시킬 수도 있다. `Proc` 객체를 사용하면 별도의 메소드 대신 인라인 조건을 작성할 수 있다. 이 옵션은 한줄 코딩에 가장 적합하다.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

`람다(Lambda)`는 `Proc`의 한 유형이므로 인라인 조건을 더 짧은 방식으로 작성하는 데에도 사용할 수 있다.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### 조건부 유효성 검증 그룹화하기 {#grouping-conditional-validations}

여러 검증에서 하나의 조건을 사용하는 것이 유용한 경우도 있다. `with_options`를 사용하면 쉽게 구현할 수 있다.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options` 블록 안의 모든 유효성 검사는 자동으로 `if: :is_admin?` 조건을 만족한 상태가 될 것이다.

### 유효성 검증 조건 결합하기 {#combining-validation-conditions}

반면, 여러 조건이 결합하여 유효성 검증 수행 여부를 결정할 때 `배열`을 사용할 수 있다. 또한 동일한 유효성 검증에 `:if` 와 `:unless`를 둘 다 적용 할 수 있다.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

유효성 검증은 모든 `:if` 조건이 `true`로 평가되고  모든 `:unless` 조건이 `false`로 평가되는 경우에만 실행된다.

사용자 정의 유효성 검증하기 {#performing-custom-validations}
-----------------------------

내장된 유효성 검증 헬퍼가 충분하지 않은 경우 직접 유효성 검증 클래스 또는 유효성 검증 메소드를 작성할 수 있다.

### 사용자 정의 유효성 검증 클래스 {#custom-validators}

사용자 정의 유효성 검증 클래스는 `ActiveModel::Validator`에서 상속된다. 이 클래스는 레코드를 인수로 사용하며 유효성을 검증하는 `validate` 메소드를 구현해야 한다. 커스텀 유효성 검증 클래스는 `validates_with` 메소드를 사용하여 호출한다.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.starts_with? 'X'
      record.errors[:name] << 'Need a name starting with X please!'
    end
  end
end

class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

개별 속성을 검증하기 위해 사용자 정의 유효성 검증 클래스를 추가하는 가장 쉬운 방법은 편리한 `ActiveModel::EachValidator`를 상속받아 사용하는 것이다. 이 경우 사용자 정의 유효성 검증 클래스는 레코드, 속성, 값의 세 가지 인수를 사용하는 `validate_each` 메서드를 구현해야 한다. 이들은 각각 인스턴스, 유효성을 검증할 속성, 전달된 인스턴스 내의 속성 값에 해당한다.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

예제에 표시된 것처럼 표준 유효성 검증을 사용자 정의 유효성 검증 클래스와 결합 할 수도 있다.

### 사용자 정의 유효성 검증 메소드 {#custom-method}

모델의 상태를 확인하는 메소드를 작성하여 유효하지 않은 경우 에러 컬렉션에 메시지를 추가할 수도 있다. 그런 다음 `validate` ([API](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate)) 클래스 메소드를 사용하여 유효성 검증 메소드명을 심볼로 등록해야 한다.

각 클래스 메소드에 대해 둘 이상의 심볼을 전달할 수 있으며 각 유효성 검증 메소드는 등록된 순서대로 실행된다.

`valid?` 메소드는 에러 컬렉션이 비어 있는지 확인하므로 사용자 정의 유효성 검증 메소드는 유효성 검증에 실패할 때 에러를 추가해  주어야 한다.

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

기본적으로 이러한 유효성 검사는 'valid?'를 호출하거나 객체를 저장할 때마다 실행된다. 그러나 `:create` 또는 `:update`와 함께 `validate` 메소드에 `:on` 옵션을 제공하여 이러한 사용자 지정 유효성 검증을 실행할 시기를 제어 할 수도 있다.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

유효성 검증 에러 발생시 처리 {#working-with-validation-errors}
------------------------------

레일스는 앞에서 설명한 `valid?` 와 `invalid?` 메소드 외에도  `errors` 컬렉션을 처리하는 메소드와 객체의 유효성을 검증하는 여러가지 메소드를 함께 제공한다.

아래는 가장 일반적으로 사용되는 메소드의 목록이다. 사용 가능한 모든 메소드 목록은 `ActiveModel::Errors` 문서를 참조한다.

### `errors`

이것은 모든 에러를 포함하는 `ActiveModel::Errors` 클래스의 인스턴스를 반환한다. 각 키는 속성 이름이고 값은 모든 에러를 포함하는 문자열 배열이다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.messages
 # => {:name=>["can't be blank", "is too short (minimum is 3 characters)"]}

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors.messages # => {}
```

### `errors[]`

`errors[]`는 특정 속성에 대한 에러 메시지를 확인하려고 할 때 사용한다. 주어진 속성에 대한 모든 에러 메시지가 포함된 문자열 배열을 반환하며 각 문자열은 하나의 에러 메시지에 해당한다. 속성과 관련된 에러가 없으면 빈 배열을 반환한다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors[:name] # => []

person = Person.new(name: "JD")
person.valid? # => false
person.errors[:name] # => ["is too short (minimum is 3 characters)"]

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.add`

`add` 메소드를 사용하면 특정 속성과 관련된 에러 메시지를 추가할 수 있다. 속성 및 에러 메시지를 인수로 사용한다.

`errors.full_messages` 메소드(또는 이에 상응하는 `errors.to_a`)는 아래 예제와 같이 대문자로 된 속성 이름이 각 메시지 앞에 추가되어 사용자에게 친숙한 형식으로 에러 메시지를 반환한다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, "cannot contain the characters !@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors[:name]
 # => ["cannot contain the characters !@#%*()_-+="]

person.errors.full_messages
 # => ["Name cannot contain the characters !@#%*()_-+="]
```

### `errors.details`

`errors.add` 메소드를 사용하여 반환된 에러 세부 사항 해시에 유효성 검증 유형을 지정할 수 있다.

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

예를 들어 허용되지 않는 문자 세트를 포함하도록 에러 세부 사항을 개선하기 위해 `errors.add`에 추가 키를 전달할 수 있다.

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

내장된 모든 레일스 유효성 검증 클래스나 메소드는 세부 정보 해시를 해당 유효성 검증 유형으로 채운다.

### `errors[:base]`

특정 속성과 관련되지 않고 객체의 상태와 관련된 에러 메시지를 추가 할 수 있다. 속성 값에 관계없이 객체가 유효하지 않다고 말하고 싶을 때 이 방법을 사용할 수 있다. `errors[:base]`는 배열이므로 단순히 문자열을 추가하면 에러 메시지로 사용할 수 있게 된다.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors[:base] << "This person is invalid because ..."
  end
end
```

### `errors.clear`

`clear` 메소드는 의도적으로 `errors` 컬렉션의 모든 메시지를 지우고자 할 때 사용한다. 물론 유효하지 않은 객체에 대해 `errors.clear`를 호출하면 실제로는 객체를 유효하게 만들 수 없다. `errors` 컬렉션이 비어 있지만 다음에 `valid?`를 호출하거나 이 객체를 데이터베이스로 저장하려고 시도하는 메소드를 호출할 경우 유효성 검증이 다시 실행된다. 유효성 검증 중 하나라도 실패하면 `errors` 컬렉션이 다시 채워진다.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]

person.errors.clear
person.errors.empty? # => true

person.save # => false

person.errors[:name]
# => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.size`

`size` 메소드는 해당 객체에 대한 총 에러 메시지 수를 반환한다.

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

유효성 검증 에러를 뷰에 표시하기 {#displaying-validation-errors-in-views}
-------------------------------------

모델을 생성한 후 유효성 검증을 추가하면, 해당 모델이 웹 폼을 통해 생성될 때 유효성 검증 중 하나가 실패할 때 에러 메시지를 뷰에 표시할 수 있다.

모든 애플리케이션은 이러한 종류의 작업을 다르게 처리하기 때문에 레일스는 이러한 메시지를 직접 생성하는 데 도움이 되는 뷰 헬퍼를 포함하고 있지 않다. 그러나 레일스가 일반적으로 유효성 검증과 상호 작용할 수 있는 다양한 메소드를 제공해 주어 자신 만의 헬퍼 메소드를 작성하기가 매우 쉽다. 또한 스카폴드를 생성할 때 레일스는 ERB를 `_form.html.erb`에 추가하여 해당 모델의 전체 에러 목록을 표시하도록 해 준다.

`@article`라는 인스턴스 변수에 저장된 모델이 있다고 가정하면 아래와 같다.

```ruby
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

또한 레일스 폼 헬퍼를 사용하여 폼을 생성할 때필드에서 유효성 검증 에러가 발생하면 항목 주위에 추가 `<div>`가 생성된다.

```
<div class="field_with_errors">
 <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

그런 다음 원하는 대로 이 div의 스타일을 지정할 수 있다. 예를 들어 레일스가 생성하는 기본 스카 폴드는 아래의 CSS 규칙을 추가한다.

```
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

이것은 에러가 있는 필드가 2 픽셀의 빨간색 테두리로 끝나는 것을 의미한다.
