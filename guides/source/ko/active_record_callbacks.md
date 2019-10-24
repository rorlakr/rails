액티브 레코드 콜백 {#active-record-callbacks}
=======================

본 가이드는 액티브 레코드 객체의 생명주기에 후크(hook, https://ko.wikipedia.org/wiki/후킹) 을 거는 방법을 알려 준다.

본 가이드를 읽은 후 아래와 같은 내용을 알게 될 것이다.

* 액티브 레코드 객체의 생명주기.
* 객체 생명주기의 이벤트에 응답하는 콜백 메소드를 만드는 방법.
* 콜백의 일반적인 동작을 캡슐화하는 별도의 클래스를 만드는 방법.

--------------------------------------------------------------------------------

액티브 레코드 객체의 생명주기 {#the-object-life-cycle}
---------------------

레일스 애플리케이션이 정상적으로 작동하는 동안 객체가 생성, 업데이트, 파괴될 수 있다. 액티브 레코드는 이 객체 생명주기에 대한 후크를 제공하므로써 애플리케이션과 데이터를 제어할 수 있다.

콜백을 사용하면 액티브 레코드 객체의 상태 변경 전후에 로직을 트리거할 수 있다.

콜백 개요 {#callbacks-overview}
------------------

콜백은 객체 생명주기의 특정 순간에 호출되는 메소드이다. 콜백을 사용하면 데이터베이스에서 액티브 레코드 객체를 생성, 저장, 업데이트, 삭제, 검증 또는 로드할 때마다 실행될 코드를 작성할 수 있다.

### 콜백 등록 {#callback-registration}

가용한 콜백을 사용하려면 콜백을 등록해야 한다. 콜백을 일반 메소드로 구현한 후 매크로 스타일 클래스 메소드를 사용하여 콜백으로 등록할 수 있다.

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.nil?
        self.login = email unless email.blank?
      end
    end
end
```

매크로 스타일 클래스 메소드는 블록을 받을 수도 있다. 블록 내부의 코드가 너무 짧아 한 줄에 들어가는 경우 이 스타일을 사용한다.

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

콜백은 특정 생명주기 이벤트에서만 발생하도록 등록할 수도 있다.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on takes an array as well
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

콜백 메소드를 private로 선언하는 것이 좋다. public 상태로 둘 경우 모델 외부에서 호출하여 객체 캡슐화 원칙을 위반할 수 있기 때문이다.

가용한 콜백 {#available-callbacks}
-------------------

다음은 사용 가능한 모든 액티브 레코드 콜백 목록이며 각 동작 중에 호출되는 순서와 동일한 순서로 나열되어 있다.

### 액티브 레코드 객체 생성하기 {#creating-an-object}

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`
* `after_commit/after_rollback`

### 액티브 레코드 객체 업데이트하기 {#updating-an-object}

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`
* `after_commit/after_rollback`

### 액티브 레코드 객체 삭제하기 {#destroying-an-object}

* `before_destroy`
* `around_destroy`
* `after_destroy`
* `after_commit/after_rollback`

WARNING. `after_save`는 create와 update 모두에서 실행되지만 해당 매크로 호출이 실행된 순서에 관계없이 항상 구체적인 콜백 `after_create` 와 `after_update` _직후_ 에 실행된다.

NOTE: `before_destroy` 콜백은 `dependent: :destroy` 관계 선언 전에 위치해야 하며(또는 `prepend: true` 옵션을 사용한다.), 레코드가 `dependent: :destroy`에 의해 삭제되기 전에 실행되도록 해야 한다.

### `after_initialize` 와 `after_find` {#after_initialize-and-after_find}

`after_initialize` 콜백은 `new`를 직접 사용하거나 데이터베이스에서 레코드를 로드할 때 액티브 레코드 객체가 인스턴스화될 때마다 호출된다. 액티브 레코드 `initialize` 메소드를 직접 오버라이드할 필요가 없기 때문에 유용 할 수 있다.

`after_find` 콜백은 Active Record가 데이터베이스에서 레코드를 로드할 때마다 호출된다. 둘 다 정의 된 경우 `after_find`는 `after_initialize` 전에 호출된다.

`after_initialize` 와 `after_find` 콜백에는 `before_*` 대응 콜백이 없지만 다른 액티브 레코드 콜백처럼 등록할 수 있다.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
  end
end

>> User.new
You have initialized an object!
=> #<User id: nil>

>> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

### `after_touch`

`after_touch` 콜백은 액티브 레코드 객체가 touch될 때마다 호출된다.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end

>> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

>> u.touch
You have touched an object
=> true
```

`belongs_to`와 함께 사용할 수 있다.

```ruby
class Employee < ApplicationRecord
  belongs_to :company, touch: true
  after_touch do
    puts 'An Employee was touched'
  end
end

class Company < ApplicationRecord
  has_many :employees
  after_touch :log_when_employees_or_company_touched

  private
    def log_when_employees_or_company_touched
      puts 'Employee/Company was touched'
    end
end

>> @employee = Employee.last
=> #<Employee id: 1, company_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

# triggers @employee.company.touch
>> @employee.touch
An Employee was touched
Employee/Company was touched
=> true
```

콜백 실행하기 {#running-callbacks}
-----------------

아래의 메소드는 콜백을 트리거한다.

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

또한, 아래의 finder 메소드는 `after_find` 콜백을 트리거한다.

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

특정 클래스의 새로운 객체가 초기화될 때마다 `after_initialize` 콜백이 트리거된다. 

NOTE: `find_by_*` 와 `find_by_*!` 메소드는 모든 속성에 대해서 자동으로 생성되는 동적 finder 들이다. [Dynamic finders section](active_record_querying.html#dynamic-finders)에서 이에 관한 더 많은 것을 배울 수 있다.

콜백 건너뛰기 {#skipping-callbacks}
------------------

유효성 검증과 같이, 아래의 메소드를 사용할 때도 콜백을 트리거하지 않을 수 있다. 

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `increment!`
* `increment_counter`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`

그러나 중요한 비즈니스 규칙과 애플리케이션 논리가 콜백에 보관될 수 있으므로 이러한 메소드들은 주의해서 사용해야 한다. 잠재적인 영향을 이해하지 않고 이를 무시하면 유효하지 않은 데이터가 발생할 수 있다.

실행 중단 {#halting-execution}
-----------------

모델에 콜백을 새로 등록하기 시작하면 실행 대기 상태가 된다. 이 대기열에는 모든 모델의 유효성 검사, 등록된 콜백 및 실행할 데이터베이스 작업이 포함된다.

전체 콜백 체인은 트랜잭션으로 래핑된다. 콜백에서 예외가 발생하면 실행 체인이 중지되고 ROLLBACK이 발생된다. 의도적으로 체인 사용을 중지하려면,

```ruby
throw :abort
```

WARNING. 콜백 체인이 정지된 후 `ActiveRecord::Rollback` 또는 `ActiveRecord::RecordInvalid` 가 아닌 예외는 레일스에 의해 다시 발생한다. `ActiveRecord::Rollback` 또는 `ActiveRecord::RecordInvalid` 이외의 예외가 발생하면 코드가 깨지게 되어(보통 `true` 또는 `false`를 반환하려고 시도하는) `save` 및 `update` 와 같은 메소드가 예외를 발생시키지 않게 된다. 

관계형 콜백 {#relational-callbacks}
--------------------

콜백은 모델 관계를 통해 작동하며 이를 정의할 수도 있다. 사용자에게 많은 기사(읽은거리)가 있는 예를 가정한다. 사용자가 삭제되면 사용자의 기사도 폐기해야 한다. `Article` 모델과의 관계를 통해 `after_destroy` 콜백을`User` 모델에 추가해 보면 아래와 같다. 

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end

>> user = User.first
=> #<User id: 1>
>> user.articles.create!
=> #<Article id: 1, user_id: 1>
>> user.destroy
Article destroyed
=> #<User id: 1>
```

조건부 콜백 {#conditional-callbacks}
---------------------

유효성 검증과 마찬가지로 주어진 predicate 메소드(true/false 를 반환하는 메소드)의 만족도에 따라 콜백 메소드 호출을 조건부로 작성할 수도 있다. `:if` 및 `:unless` 옵션을 사용하여 이 작업을 수행 할 수 있다. 이 옵션은 심볼,  `Proc`, `Array` 형태로 지정하여 사용할 수 있다. 콜백이 호출**되어야 하는** 조건을 지정할 때 `:if` 옵션을 사용할 수 있다. 콜백이 호출되지 **않아야 하는** 조건을 지정하려면 `:unless` 옵션을 사용할 수 있다.

### 심볼을 사용하여 조건을 지정할 때 {#using-if-and-unless-with-a-symbol}

`:if` 및 `:unless` 옵션을 콜백 직전에 호출될 predicate 메소드의 이름에 해당하는 심볼과 연관시킬 수 있다. `:if` 옵션을 사용하는 경우, predicate 메소드가 false를 리턴하면 콜백이 실행되지 않는다. `:unless` 옵션을 사용할 때, predicate 메소드가 true를 리턴하면 콜백이 실행되지 않는다. 이것이 가장 일반적인 옵션이다. 이러한 등록 폼을 사용하면 콜백 실행 여부를 확인하기 위해 호출해야 하는 여러 가지 predicate 메소드를 등록 할 수도 있다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### `Proc`를 사용하여 조건을 지정할 때  {#using-if-and-unless-with-a-proc}

`:if` 와 `:unless`를 `Proc` 객체와 연관시킬 수 있다. 이 옵션은 짧은 유효성 검증 메소드(일반적으로 한줄 코딩에 적합한)을 작성할 때 가장 적합합니다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

proc는 해당 객체의 특정 컨텍스에서 평가되므로 아래와 같이 작성할 수도 있다.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### 다중 조건부 콜백 {#multiple-conditions-for-callbacks}

조건부 콜백을 작성할 때 동일한 콜백 선언에서 `:if` 와 `:unless`를 함께 사용할 수 있다. 

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.article.ignore_comments? }
end
```

### 콜백 조건 결합하기 {#combining-callback-conditions}

여러 조건이 결합하여 콜백 발생 여부를 결정할 때 `Array`를 사용할 수 있다. 또한 동일한 콜백에 `:if` 와 `:unless`를 함께 적용할 수 있다.

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author,
    if: [Proc.new { |c| c.user.allow_send_email? }, :author_wants_emails?],
    unless: Proc.new { |c| c.article.ignore_comments? }
end
```

콜백은 모든 `:if` 조건이 `true`로 평가되고 `:unless` 조건 중 어느 것도 `true`로 평가되지 않는 경우에만 실행된다.

콜백 클래스 {#callback-classes}
----------------

때로는 작성하는 콜백 메소드가 다른 모델에서 재사용하기에도 충분할 정도로 유용할 때가 있다. 액티브 레코드를 사용하면 콜백 메소드를 캡슐화하는 클래스를 작성할 수 있으므로 재사용이 매우 쉬워진다.

아래의 예는 `PictureFile` 모델에 대한 `after_destroy` 콜백을 사용하여 클래스를 만드는 것이다.

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

위와 같이 클래스 내에서 선언되면 콜백 메서드는 모델 객체를 매개 변수로 받는다. 이제 모델에서 콜백 클래스를 사용할 수 있다.

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks.new
end
```

콜백을 인스턴스 메소드로 선언했기 때문에 `PictureFileCallbacks` 객체를 새로 인스턴스화해야 했었던 것에 주의한다. 이는 콜백이 인스턴스화된 객체의 상태를 사용하는 경우 특히 유용하다. 그러나 종종 콜백을 클래스 메소드로 선언하는 것이 더 합리적일 때가 있다. 

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

콜백 메소드가 이런 식으로 선언되면 `PictureFileCallbacks` 객체를 인스턴스화 할 필요가 없다.

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks
end
```

콜백 클래스 내에서 원하는 만큼의 콜백을 선언 할 수 있다.

트랜잭션 콜백 {#transaction-callbacks}
---------------------

데이터베이스 트랜잭션이 완료되면 트리거되는 `after_commit` 과`after_rollback` 의 두 가지 추가 콜백이 있다. 이 콜백은 데이터베이스 변경이 커밋되거나 롤백 될 때까지 실행되지 않는다는 점을 제외하면 `after_save` 콜백과 매우 유사하다. 액티브 레코드 모델이 데이터베이스 트랜잭션의 일부가 아닌 외부 시스템과 상호 작용해야 할 때 가장 유용하다.

예를 들어, 해당 레코드가 삭제된 후 `PictureFile` 모델이 파일을 삭제해야 하는 이전 예를 돌이켜 보자. `after_destroy` 콜백이 호출되고 트랜잭션이 롤백된 후 예외가 발생하면 파일이 삭제되고 모델이 일관성이 없는 상태로 남게 된다. 예를 들어, 아래 코드의 `picture_file_2`가 유효하지 않아 `save!` 메소드에서 에러가 발생한다고 가정하자.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

`after_commit` 콜백을 사용하여 이 경우를 설명 할 수 있다.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: `:on` 옵션은 콜백 발생 시점을 지정한다. `:on` 옵션을 지정하지 않으면 모든 동작에 대해 콜백이 발생한다.

create, update 또는 delete에서만 `after_commit` 콜백을 사용하는 것이 일반적이므로 해당 작업에 대한 별칭이 있다.

* `after_create_commit`
* `after_update_commit`
* `after_destroy_commit`

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

WARNING. 트랜잭션이 완료되면 해당 트랜잭션 내에서 생성, 업데이트 또는 삭제된 모든 모델에 대해 `after_commit` 또는 `after_rollback` 콜백이 호출된다. 그러나 이러한 콜백 중 하나에서 예외가 발생하면 예외가 파급되어 나머지 `after_commit` 또는`after_rollback` 메소드는 실행되지 _않게_ 된다. 따라서 콜백 코드에서 예외가 발생할 수 있는 경우 다른 콜백을 실행하려면 이를 구조화하고 콜백 내에서 처리해야 한다.

WARNING. `after_commit` 또는 `after_rollback` 콜백 내에서 실행되는 코드 자체는 트랜잭션 내에 포함되지 않는다.

WARNING. 동일한 모델에서 `after_create_commit` 과 `after_update_commit` 를 모두 사용하면 정의된 마지막 콜백만 적용되고 다른 콜백은 모두 무시된다.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end

# prints nothing
>> @user = User.create

# updating @user
>> @user.save
=> User was saved to database
```

create 와 update를 함께 사용하기 위한 `after_commit` 콜백 별명도 있다.

* `after_save_commit`

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end

# creating a User
>> @user = User.create
=> User was saved to database

# updating @user
>> @user.save
=> User was saved to database
```

초벌번역 : 2019-10-24 시작 2019-10-25 종료
