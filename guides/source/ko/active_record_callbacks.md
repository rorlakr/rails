
Active Record Callbacks
=======================

여기에서는 Active Record 객체의 생애 주기에 훅을 거는 방법에 대해서 설명합니다.

이 가이드의 내용:

* Active Record 객체의 생애 주기
* 객체의 생에주기에서 이벤트에 대한 콜백 메소드를 작성하는 방법
* 콜백에서 공통된 동작을 캡슐화하는 특수한 클래스를 작성하는 방법
--------------------------------------------------------------------------------

객체의 생애 주기
---------------------

Rails 애플리케이션을 조작하다 보면, 객체를 생성하거나 변경하거나, 제거하게 됩니다. Active Record는 이 <em>객체 생애 주기</em>에 훅을 걸 수 있는 방법을 제공하며, 이것을 사용해서 애플리케이션이나 데이터를 제어할 수 있습니다.

콜백은 객체의 상태가 바뀌기 '직전' 또는 '직후'에 호출됩니다.

콜백의 개요
------------------

콜백이란 객체의 생애 주기에서 존재하는 어떤 시점에 호출되는 메소드를 말합니다. 콜백을 이용하는 것으로 Active Record 객체가 생성, 저장, 변경, 삭제, 검증, 데이터베이스에서 읽어오기, 등의 이벤트가 발생할 때에 실행되는 코드를 작성할 수 있습니다.

### 콜백의 등록

콜백을 사용하려면, 우선 등록을 해야할 필요가 있습니다. 콜백을 구현하는 것은 일반적인 메소드를 구현하는 것과 크게 다르지 않으며, 등록할 때에는 매크로 스타일의 클래스 메소드를 사용하면 됩니다.

```ruby
class User < ActiveRecord::Base
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  protected
    def ensure_login_has_a_value
      if login.nil?
        self.login = email unless email.blank?
      end
    end
end
```

이 매크로 스타일의 클래스 메소드는 블록을 받을 수 있습니다. 아래와 같이 콜백으로 사용하고 싶은 코드가 무척 짧아서 한 줄로 줄일 수 있는 경우, 이런 스타일로 작성할 수 있습니다.

```ruby
class User < ActiveRecord::Base
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

콜백은 특정 생애 주기의 이벤트에 대해서만 호출되게끔 등록할 수도 있습니다.

```ruby
class User < ActiveRecord::Base
  before_validation :normalize_name, on: :create

  # :on에 배열을 넘겨줄 수 있습니다
  after_validation :set_location, on: [ :create, :update ]

  protected
    def normalize_name
      self.name = self.name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

콜백의 선언은 protected 또는 private 키워드 뒤에 하는 것이 바람직합니다. 콜백 메소드를 public로 두게 되면 이 메소드는 모델의 바깥에서 호출 가능해지므로, 객체의 캡슐화 원칙에 위반되기 때문입니다.

사용가능한 콜백
-------------------

Active Record에서 사용 가능한 콜백 목록은 아래와 같습니다. 이 콜백들은 실제로 사용 중에 호출되는 순서대로 나열되어 있습니다.

### 객체 생성

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`

### 객체 변경

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`

### 객체 파기

* `before_destroy`
* `around_destroy`
* `after_destroy`

WARNING: `after_save`는 생성 시와 변경 시에 호출됩니다만, 매크로 등록 순서에 관계 없이 `after_create`와 `after_update` 보다 _뒤_에 호출됩니다.

### `after_initialize`와 `after_find`

`after_initialize` 콜백은 Active Record 객체가 초기화될 때 마다 호출됩니다. 초기화는 직접 `new`를 실행해 다른 데이터베이스에서 레코드를 읽어올 때에도 실행됩니다. 이것은 Active Record의 `initialize` 메소드를 직접 오버라이드하고 싶지 않을때 사용할 수 있습니다.

`after_find` 콜백은 Active Record가 데이터베이스에서 레코드를 읽어들일 때마다 호출됩니다. `after_find`와 `after_initialize`가 모두 등록되어 있을 경우에는 `after_find`가 먼저 실행됩니다.

`after_initialize`와 `after_find` 콜백에 대칭되는 `before_*` 메소드가 존재하지 않습니다만, 다른 Active Rrecord 콜백과 마찬가지로 등록할 수 있습니다. 

```ruby
class User < ActiveRecord::Base
  after_initialize do |user|
    puts "객체가 초기화되었습니다."
  end

  after_find do |user|
    puts "객체를 찾았습니다."
  end
end

>> User.new
객체가 초기화되었습니다.
=> #<User id: nil>

>> User.first
객체를 찾았습니다.
객체가 초기화되었습니다.
=> #<User id: 1>
```

### `after_touch`

`after_touch` 콜백은 Active Record 객체가 터치될 때마다 호출됩니다.

```ruby
class User < ActiveRecord::Base
  after_touch do |user|
    puts "객체를 터치했습니다."
  end
end

>> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

>> u.touch
객체를 터치했습니다.
=> true
```

이 콜백은 `belongs_to`과 함께 사용할 수 있습니다.

```ruby
class Employee < ActiveRecord::Base
  belongs_to :company, touch: true
  after_touch do
    puts 'Employee를 터치했습니다.'
  end
end

class Company < ActiveRecord::Base
  has_many :employees
  after_touch :log_when_employees_or_company_touched

  private
  def log_when_employees_or_company_touched
    puts 'Employee/Company를 터치했습니다.'
  end
end

>> @employee = Employee.last
=> #<Employee id: 1, company_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

# @employee.company.touch를 호출합니다.
>> @employee.touch
Employee/Company를 터치했습니다.
Employee를 터치했습니다.
=> true
```

콜백의 실행
-----------------

아래의 메소드들은 콜백을 호출합니다.

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `update_attribute`
* `update`
* `update!`
* `valid?`

그리고 `after_find` 콜백은 아래의 finder 메소드를 실행하면 호출됩니다.

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` 콜백은 그 클래스의 새로운 객체가 초기화될 때 마다 호출됩니다.

NOTE: `find_by_*`메소드와 `find_by_*!` 메소드는 속성마다 자동적으로 생성되는 finder 메소드 입니다. 자세한 설명은 [Dynamic finders](active_record_querying.html#Dynamic_finders)를 참조해주세요.

콜백을 무시하기
------------------

유효성 검사를 할 때와 마찬가지로, 아래에 있는 메소드를 사용하면 콜백을 호출하지 않을 수 있습니다.

* `decrement`
* `decrement_counter`
* `delete`
* `delete_all`
* `increment`
* `increment_counter`
* `toggle`
* `touch`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`

중요한 비지니스 로직이나 애플리케이션 로직은 콜백을 사용하기 때문에 이
메소드들을 사용하는 경우에는 주의해주세요. 실수로 콜백을 우회하게 되면,
데이터 부정합이 발생할 가능성이 있습니다.

콜백 등록 취소
-----------------

모델에 새로운 콜백을 등록하면 실행 큐에 삽입됩니다. 이 큐에는 모델에 대한 모든
검증, 등록된 콜백, 실행 대기중인 데이터베이스 조작 등이 들어갑니다.

콜백 체인은 하나의 트랜잭션에 포함됩니다. _before_ 콜백 중 하나가 `false`를
반환하거나 예외를 발생시키는 경우, 전체가 정지하고 롤백됩니다. 이 경우,
_after_ 콜백은 예외를 발생시키는 경우에만 중지됩니다.

WARNING: 콜백의 체인 뒤에 발생하는 `ActiveRecord::Rollback`이나
`ActiveRecord::RecordInvalid`를 제외한 모든 예외는 Rails에 의해서 다시
발생됩니다. `ActiveRecord::Rollback`나 `ActiveRecord::RecordInvalid` 이외의
예외가 발생하면 `save`나 `update_attributes`같은 메소드처럼 예외의 발생을
고려하지 않은 코드(보통 `true`나 `false`가 반환됩니다)의 동작을 망가뜨리게
됩니다.


관계 콜백
--------------------

콜백은 모델의 관계를 통해서도 동작할 수 있습니다. 또한 관계를 사용해서 콜백을
정의하는 것도 가능합니다. 한명의 사용자가 여러개의 글을 가지고 있는 경우로 예를
들어보겠습니다. 어떤 사용자가 작성한 글은 그 사용자가 삭제되면 함께 삭제될
필요가 있습니다. `User` 모델에 `depenent`를 추가하고 `Post` 모델에
`after_destroy` 콜백을 추가하면 다음과 같이 동작합니다.

```ruby
class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
end

class Post < ActiveRecord::Base
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Post destroyed'
  end
end

>> user = User.first
=> #<User id: 1>
>> user.posts.create!
=> #<Post id: 1, user_id: 1>
>> user.destroy
Post destroyed
=> #<User id: 1>
```

조건부 콜백
---------------------

검증과 마찬가지로 주어진 조건을 만족하는 경우에만 실행되는 콜백 메소드를
작성할 수 있습니다. 이렇게 하기 위해서는 콜백에 `:if` 또는 `:unless` 옵션을
사용하면 됩니다. 이 옵션은 심볼, 문자열, `Proc` 또는 `Array`를 인수로 받습니다.
특정한 상황에서만 콜백이 실행될 필요가 있는 경우에는 `:if` 옵션을 사용합니다.
특성 상황에서 콜백이 실행되어서는 안되는 경우에 `:unless` 옵션을 사용합니다.

### `:if`와 `:unless` 에서 심볼 사용하기

`:if`와 `:unless` 옵션에 콜백 호출 직전에 호출되는 메소드(true, false 중 하나를
반환해야합니다)의 이름을 나타내는 심볼을 사용할 수 있습니다. `:if`의 경우
메소드가 false를 반환하면 콜백이 실행되지 않습니다. `:unless`를 사용하는 경우
메소드가 true를 반환하는 경우에 콜백이 실행되지 않습니다. 이것은 콜백에서 가장
많이 사용되는 방법입니다. 이렇게 여러개의 메소드를 등록하는 것으로 콜백을
호출하는 시점을 점검할 수 있습니다.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### `:if`와 `:unless` 에서 문자열 사용하기

문자열을 사용할 수도 있습니다. 이 문자열은 나중에 `evel`로 평가되기 때문에
실행 가능한 올바른 Ruby 코드를 포함해야 합니다. 문자열이 포함된 조건이 충분히
짧은 경우에만 사용해주세요.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: "paid_with_card?"
end
```

### `:if`와 `:unless`에서 `Proc`를 사용하기

마지막으로 `:if`와 `:unless`에서 `Proc` 객체를 사용할 수도 있습니다. 이 옵션은
한줄 정도로 작성 가능한 함수를 검증에 사용하는 경우에 쓸만합니다.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

### 콜백에서 조건을 여러개 지정하기

1개의 조건부 콜백 선언시에 `:if`와 `:unless`를 동시에 사용할 수도 있습니다.

```ruby
class Comment < ActiveRecord::Base
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.post.ignore_comments? }
end
```

콜백 클래스
----------------

잘 작성된 콜백 메소드를 다른 모델에서도 사용하고 싶을 때가 있습니다. Active Record는 콜백 메소드를 캡슐화 해서 클래스로 만들수 있으므로, 간단하게 재사용할 수 있습니다.

아래의 예시에서는 `PictureFile` 모델용으로 `after_destroy` 콜백을 가지는 클래스를 작성할 수 있습니다.

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

위와 같이 클래스 내에 선언하는 것으로 콜백 메소드는 모델 객체를 파라미터로 받을 수 있게 됩니다. 이걸로 이 콜백 클래스는 바로 사용할 수 있습니다.

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks.new
end
```

콜백을 인스턴스 메소드로 선언했기 때문에 `PictureFileCallbacks` 객체를 인스턴스로 생성할 필요가 있다는 점에 주의해주세요. 이것은 인스턴스화된 객채의 상태를 콜백 메소드로 이용하고 싶은 경우에 편리합니다. 단, 콜백을 클래스 메소드로 선언하는 편이 알기 쉬운 경우도 있습니다.

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

콜백 메소드를 이렇게 선언한 경우에는 `PictureFileCallbacks` 객체의 인스턴스를 넘겨줄 필요가 없습니다.

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks
end
```

콜백 클래스에는 여러개의 콜백을 선언할 수 있습니다.

트랜잭션 콜백
---------------------

데이터베이스의 트랜잭션이 종료되고나서 실행되는 콜백이 2개 있습니다. `after_commit`과 `after_rollback`입니다. 이 콜백들은 `after_save` 콜백과 무척 비슷합니다만, 데이터베이스의 변경이 적용, 또는 롤백이 완료되는 시점까지 실행되지 않는다는 점이 다릅니다. 이 메소드들은 Active Record 모델로부터 데이터베이스 트랜잭션에 포함되지 않는 외부의 시스템에 무언가 영향을 주고 싶을 경우에 유용합니다.

예를 들어 직전의 예제에서 사용했던 `PictureFile` 모델과 대응하는 레코드가 삭제된 뒤에 파일을 하나 지울 필요가 있다고 합시다. `after_destroy` 콜백 직후에 무언가의 예외가 발생해서 트랜잭션이 롤백되면, 파일이 삭제되어 모델의 일관성이 유지되지 않을 가능성이 있습니다. 이하의 코드에 있는 `picture_file_2`가 유효하지 않아서 `save!` 메소드가 에러를 발생시켰다고 가정해봅시다.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

`after_commit` 콜백을 사용하는 것으로 이러한 경우에 대응할 수 있습니다.

```ruby
class PictureFile < ActiveRecord::Base
  after_commit :delete_picture_file_from_disk, on: [:destroy]

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: 여기서 `:on` 옵션은 콜백이 호출되는 조건을 지정합니다. `:on` 옵션을
지정하지 않으면 모든 액션에서 콜백이 호출되게 됩니다.

WARNING: `after_commit` 콜백과 `after_rollback` 콜백은 1개의 트랜잭션에서
발생한 어떤 모델의 생성, 갱신, 삭제 뒤에 호출이 보장됩니다. 이 콜백들 중
어떤 것이 예외를 발생시키더라도, 나머지 콜백에 영향을 미치지 않습니다.
따라서 만약 직접 만든 콜백이 예외를 발생시킬 가능성이 있는 경우에는 자신의
콜백 내에서 rescue를 해서 적절한 예외 처리를 해야할 필요가 있습니다.

