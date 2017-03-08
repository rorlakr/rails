액티브 모델
===================

이 가이드에서는 모델 클래스를 사용하는 경우에 필요한 모든 것에 대해 설명합니다.
액티브 모델은 액션 팩 헬퍼 덕분에 일반 루비 객체와도 사용할 수 있습니다.
액티브 모델을 통해 커스텀 ORM을 만들어 레일스 프레임워크 외부에서 사용할 수도
있습니다. 

이 가이드의 내용:

* 액티브 모델의 동작.
* 콜백과 검증의 동작.
* 직렬화의 동작 방식.
* 액티브 모델과 Rails 국제화(i18n) 프레임워크의 동작

--------------------------------------------------------------------------------

들어가기 전에
------------

액티브 모델은 액티브 레코드에서 사용되는 많은 모듈을 포함하는 라이브러리입니다.
몇몇 모듈에 대해서는 아래에서 설명합니다.

### Attribute Methods

`ActiveModel::AttributeMethods` 모듈은 클래스의 메소드에 접두사, 또는 접미사를
추가할 수 있습니다. 이 모듈을 사용하려면 접두사, 또는 접미사를 정의하고 이를
적용할 메소드를 지정하세요.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

    private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end

person = Person.new
person.age = 110
person.age_highest?  # => true
person.reset_age     # => 0
person.age_highest?  # => false
```

### Callbacks

`ActiveModel::Callbacks`을 사용하여 액티브 레코드 형식의 콜백을 사용할 수 있습니다. 이를 통해 원하는 콜백을 필요한 타이밍에 실행할 수 있습닏. 콜백을 정의한 뒤, 각각 커스텀 메소드의 실행 전(before), 실행 후(after), 또는 실행 중(around)인 코드를 감쌀 수 있습니다.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # 객체에 update 메소드가 호출되면 이 메소드가 호출된다.
    end
  end

  def reset_me
    # 이 메소드는 before_update 콜백에서 정의했 듯, 객체에 update 메소드가 호출되기 전에 호출된다.
  end
end
```

### Conversion

클래스에 `persisted?` 메소드와 `id` 메소드가 정의되어 있다면, `ActiveModel::Conversion` 모듈을 include하여 해당 클래스의 객체에서 레일스의 변환 메소드를 사용할 수 있습니다.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end

person = Person.new
person.to_model == person  # => true
person.to_key              # => nil
person.to_param            # => nil
```

### Dirty

객체가 여러 번의 변경을 거치고, 저장되지 않았다면 이를 더러운 상태라고 부릅니다. `ActiveModel::Dirty` 모듈은 객체가 변경되었는지, 아닌지를 확인할 수 있게 해줍니다. 속성명에 기반한 접근 메소드도 사용할 수 있습니다. `first_name`과 `last_name`을 가지고 있는 Person 클래스를 예로 들어봅시다.

```ruby
require 'active_model'

class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # 저장한다
    changes_applied
  end
end
```

#### 변경된 모든 속성 목록을 객체로부터 바로 가져오기

```ruby
person = Person.new
person.changed? # => false 

person.first_name = "First Name"
person.first_name # => "First Name"

# 속성이 1개 이상 변경된 경우
person.changed? # => true

# 저장하기 전에 변경된 속성의 목록을 반환
person.changed # => ["first_name"]

# 원래 값으로부터 변경된 속성들의 해시를 반환
person.changed_attributes # => {"first_name"=>nil}

# 변경점 해시를 반환(해시의 키는 속성명, 해시의 값은 속성의 이전 값, 새 값의 배열)
person.changes # => {"first_name"=>[nil, "First Name"]}
```

#### 속성명에 기반한 접근 메소드

속성이 변경되었는지 확인합니다.

```ruby
# attr_name_changed?
person.first_name # => "First Name"
person.first_name_changed? # => true
```

속성의 이전 값을 반환합니다.

```ruby
# attr_name_was accessor
person.first_name_was # => "First Name"
```

변경된 속성의 이전 값과 현재 값을 모두 반환합니다. 변경이 있는 경우에는 배열을, 없는 경우에는 nil을 반환합니다.

```ruby
# attr_name_change
person.first_name_change # => [nil, "First Name"]
person.last_name_change # => nil
```

### Validations

`ActiveModel::Validations` 모듈을 사용하여 액티브 레코드 형식의 검증 기능을 추가할 수 있습니다.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end

person = Person.new(token: "2b1f325")
person.valid? # => false 
person.name = 'vishnu'
person.email = 'me'
person.valid? # => false 
person.email = 'me@vishnuatrai.com'
person.valid? # => true
person.token = nil
person.valid? # => ActiveModel::StrictValidationFailed 에러를 던짐
```

### Naming

`ActiveModel::Naming` 모듈은 네이밍이나 라우팅을 다루기 쉽게 만들어주는 클래스 메소드를 추가합니다.
이 모듈은 `model_name` 클래스 메소드를 정의하고, 여기에 `ActiveSupport::Inflector`를 사용하여
여러 접근자를 만듭니다.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### Model

`ActiveModel::Model` 모듈은 액션 팩과 액션 뷰의 기능을 사용할 수 있게 해줍니다.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

`ActiveModel::Model` 모듈을 사용하면 다음과 같은 기능을 얻을 수 있습니다.

- 모델 이름 얻어오기
- 변환
- 번역
- 검증

더불어 액티브 레코드의 객체들처럼 해시를 이용하여 객체를 초기화할 수 있게 해줍니다.

```ruby
email_contact = EmailContact.new(name: 'David',
                                 email: 'david@example.com',
                                 message: 'Hello World')
email_contact.name       # => 'David'
email_contact.email      # => 'david@example.com'
email_contact.valid?     # => true
email_contact.persisted? # => false
```

`ActiveModel::Model`를 포함하고 있는 클래스라면 `form_for`, 액티브 레코드 객체처럼
`render`와 같은 액션 뷰 헬퍼 메소드를 사용할 수 있습니다.

### Serialization

`ActiveModel::Serialization` 모듈은 객체의 기본적인 직렬화 기능을 제공합니다.
이를 위해서 직렬화하고 싶은 속성의 목록을 포함하는 해시를 선언해야 합니다. 단, 속성명은 심볼이 아닌 문자열이어야 합니다.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

이제 `serializable_hash`를 사용해서 객체의 직렬화된 해시에 접근할 수 있습니다.

```ruby
person = Person.new
person.serializable_hash   # => {"name"=>nil}
person.name = "Bob"
person.serializable_hash   # => {"name"=>"Bob"}
```

#### ActiveModel::Serializers

레일스는 `ActiveModel::Serializers::JSON` 모듈을 제공합니다.
이 모듈은 `ActiveModel::Serialization`를 포함하면 자동적으로 로드됩니다.

##### ActiveModel::Serializers::JSON

`ActiveModel::Serializers::JSON` 모듈을 사용하려면 `ActiveModel::Serialization`를
`ActiveModel::Serializers::JSON`로 변경하면 됩니다.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

`as_json` 메소드를 사용하면 해시로 표현된 모델을 얻을 수 있습니다.

```ruby
person = Person.new
person.as_json # => {"name"=>nil}
person.name = "Bob"
person.as_json # => {"name"=>"Bob"}
```

JSON 문자열로부터 모델의 속성을 정의할 수 있습니다.
클래스에 `attributes=` 메소드를 정의하세요.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    {'name' => nil}
  end
end
```

이제 `from_json`를 통해서 Person 클래스의 인스턴스에 속성을 설정할 수 있습니다.

```ruby
json = { name: 'Bob' }.to_json
person = Person.new
person.from_json(json) # => #<Person:0x00000100c773f0 @name="Bob">
person.name            # => "Bob"
```

### Translation

`ActiveModel::Translation` 모듈은 객체와 레일스의 국제화(i18n) 프레임워크를 통합해줍니다.

```ruby
class Person
  extend ActiveModel::Translation
end
```

`human_attribute_name`를 사용해서 속성명을 사람이 읽기 쉬운 형식으로 변환할 수 있습니다.
이 읽기 형식은 로케일 파일에 정의됩니다.

* config/locales/app.pt-BR.yml

  ```yml
  pt-BR:
    activemodel:
      attributes:
        person:
          name: 'Nome'
  ```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint Tests

`ActiveModel::Lint::Tests` 모듈은 객체가 액티브 모델 API와 잘 동작하는지 테스트하는 기능을 제공합니다.

* app/models/person.rb

    ```ruby
    class Person
      include ActiveModel::Model

    end
    ```

* test/models/person_test.rb

    ```ruby
    require 'test_helper'

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

객체가 액션 팩을 사용하기 위해서 모든 API를 구현해야할 필요는 없습니다.  이
모듈은 모든 기능을 구현하고 싶은 경우에 가이드라인을 제공하는 것이 목적입니다.

### SecurePassword

`ActiveModel::SecurePassword` 모듈은 암호화된 폼에서 비밀번호를 안전하게
저장하기 위한 방법을 제공합니다.
이 모듈을 사용하면 `has_secure_password` 클래스 메소드가 추가되며, 이 메소드는
`password`라는 접근자와 필요한 검증 기능을 추가합니다.

#### 요구조건

`ActiveModel::SecurePassword` 모듈은 [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt')에 의존합니다.
그러므로 `ActiveModel::SecurePassword`를 사용하고 싶다면 이 잼을 Gemfile에 추가해야 합니다.
그리고 모델에는 `password_digest`라는 접근자가 존재해야 합니다.
`has_secure_password`는 `password` 접근자에 다음과 같은 검증을 추가합니다.

1. 비밀번호는 반드시 존재해야 합니다.
2. 비밀번호는 반드시 확인용 비밀번호와 동일해야 합니다.
3. 길이는 72자 이하여야 합니다. (ActiveModel::SecurePassword가 의존하는 `bcrypt`의 요구사항입니다)

#### 예제

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  attr_accessor :password_digest
end

person = Person.new

# 비밀번호가 없을 때
person.valid? # => false

# 확인용 비밀번호가 비밀번호와 일치하지 않을 때
person.password = 'aditya'
person.password_confirmation = 'nomatch'
person.valid? # => false

# 비밀번호의 길이가 72자보다 길 때
person.password = person.password_confirmation = 'a' * 100
person.valid? # => false

# 확인용 비밀번호가 없을 때
person.password = 'aditya'
person.valid? # => true

# 모든 검증을 통과할 때
person.password = person.password_confirmation = 'aditya'
person.valid? # => true
```
