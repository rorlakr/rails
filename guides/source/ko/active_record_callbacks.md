[Active Record Callbacks] 액티브 레코드 콜백(후처리)
=======================

본 가이드에서는 액티브 레코드 객체가 생성해서 삭제하기 까지 각 단계마다 끼어 들어들어서 처리하는 방법을 알려줍니다. [[[This guide teaches you how to hook into the life cycle of your Active Record objects.]]]

본 가이드를 읽은 후에는 아래와 같은 내용을 할 수 있을 것입니다: [[[After reading this guide, you will know:]]]

* 액티브 레코드 객체가 생성하고 삭제하기까지 일련의 과정. [[[The life cycle of Active Record objects.]]]

* 객체가 생성하고 삭제하는 과정에서 각 단계마다 해당하는 후처리 콜백 메소드를 만드는 방법. [[[How to create callback methods that respond to events in the object life cycle.]]]

* 콜백이 주요 기능 보이지 않도록 하는 특별한 클래스를 생성하는 방법. [[[How to create special classes that encapsulate common behavior for your callbacks.]]]

--------------------------------------------------------------------------------

[The Object Life Cycle] 객체 라이프 사이클(객체가 생성해서 삭제하기 까지 일련의 과정)
---------------------

레일스 애플리케이셜이 정상 동작하면서, 객체를 생성하고, 수정하고, 삭제합니다. 액티브 레코드가 <em>객체 라이프 사이클</em>의 단계마다 연력하여 사용하는 후크를 제공하여 애플리케이션과 데이타를 제어할 수 있습니다. [[[During the normal operation of a Rails application, objects may be created, updated, and destroyed. Active Record provides hooks into this <em>object life cycle</em> so that you can control your application and its data.]]]

콜백은 반사신경처럼 객체 상태가 다른 상태로 바뀌기 전과 후에 처리방법을 실행하도록 합니다. [[[Callbacks allow you to trigger logic before or after an alteration of an object's state.]]]

[Callbacks Overview] 콜백 개요
------------------

콜백이라는 메소드는 객체 라이프 사이클의 특정 시점에 실행합니다. 액티브 레코드 객체를 생성하고 저장하고, 수정하고, 삭제하고, 검증하고 데이터베이스에서 불러올 때 실행할 코드를 콜백으로 작성할 수 있습니다. [[[Callbacks are methods that get called at certain moments of an object's life cycle. With callbacks it is possible to write code that will run whenever an Active Record object is created, saved, updated, deleted, validated, or loaded from the database.]]]

### [Callback Registration] 콜백 등록

콜백을 적용하려면, 등록부터 해야합니다. 콜백을 메소드처럼 코드를 작성하고 매크로로 콜백을 등록합니다. [[[In order to use the available callbacks, you need to register them. You can implement the callbacks as ordinary methods and use a macro-style class method to register them as callbacks:]]]

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

매크로에 블럭을 넘겨줄 수 있습니다. 블럭 안에 코드가 길지 않아서 한 줄로 정도일때 이렇게 쓰는 편이 좋겠습니다: [[[The macro-style class methods can also receive a block. Consider using this style if the code inside your block is so short that it fits in a single line:]]]

```ruby
class User < ActiveRecord::Base
  validates :login, :email, presence: true

  before_create do |user|
    user.name = user.login.capitalize if user.name.blank?
  end
end
```

콜백을 'on' 뒤에 라이프 사이클의 특정 상태가 발생할 때 실행하도록 등록할 수 있습니다. [[[Callbacks can also be registered to only fire on certain lifecycle events:]]]

```ruby
class User < ActiveRecord::Base
  before_validation :normalize_name, on: :create

  # :on takes an array as well
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

콜백은 프로텍트 또는 프라이빗으로 선언하기 바랍니다. 퍼블릭이라면, 해당 모델이 아닌 곳에서 콜백을 실행할 수 있어서 객체를 캡슐에 담듯이 은닉화하는 원칙에 벗어납니다. [[[It is considered good practice to declare callback methods as protected or private. If left public, they can be called from outside of the model and violate the principle of object encapsulation.]]]

[Available Callbacks] 사용할 콜백 종류
-------------------

액티브 레코드에서 사용할 수 있는 콜백에 대한 목록을 나열하면서, 목록 순서대로 실행하겠습니다. [[[Here is a list with all the available Active Record callbacks, listed in the same order in which they will get called during the respective operations:]]]

### [Creating an Object] 객체 생성

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`

### [Updating an Object] 객체 수정

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`

### [Destroying an Object] 객체 삭제

* `before_destroy`
* `around_destroy`
* `after_destroy`

WARNING. `after_save`는 생성할 때와 수정할 때 모두 실행하지만, _after_ 를 쓰는 콜백으로 `after_create` 와 `after_update` 이 있는데, 매크로를 쓰는 순서와 관계없이 해당 콜백을 실행합니다. [[[`after_save` runs both on create and update, but always _after_ the more specific callbacks `after_create` and `after_update`, no matter the order in which the macro calls were executed.]]]

### [`after_initialize` and `after_find`] `after_initialize` 와 `after_find`

`after_initialize`을 실행할 때는 액티브 렉코드 객체를 처음 메모리에 올리는 두 가지 경우로 `new` 메소드로 생성하거나, 데이터베이스에서 레코드 하나를 가져올 때 입니다. 액티브 레코드의 `initialize` 메소드를 오버라이드하지 않아도 됩니다. [[[The `after_initialize` callback will be called whenever an Active Record object is instantiated, either by directly using `new` or when a record is loaded from the database. It can be useful to avoid the need to directly override your Active Record `initialize` method.]]]

`after_find` 콜백을 실행할 때는 액티브 레코드로 테이터베이스에서 레코드를 가져오는 경우입니다. `after_find`와 `after_initialize`를 둘 다 정의한 경우 `after_find`를 먼저 실행합니다. [[[The `after_find` callback will be called whenever Active Record loads a record from the database. `after_find` is called before `after_initialize` if both are defined.]]]

`after_initialize` 와 `after_find` 콜백은 `before_*` 로 시작하는 콜백이 없지만, 액티브 레코드의 다른 콜백처럼 등록할 수 있습니다. [[[The `after_initialize` and `after_find` callbacks have no `before_*` counterparts, but they can be registered just like the other Active Record callbacks.]]]

```ruby
class User < ActiveRecord::Base
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

[Running Callbacks] 콜백을 자동으로 실행하는 메소드
-----------------

아래의 메소드는 콜백을 자동으로 실행합니다. [[[The following methods trigger callbacks:]]]

* `create`
* `create!`
* `decrement!`
* `destroy`
* `destroy!`
* `destroy_all`
* `increment!`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `update_attribute`
* `update`
* `update!`
* `valid?`

그리고 `after_find` 콜백을 자동으로 실행하는 메소드: [[[Additionally, the `after_find` callback is triggered by the following finder methods:]]]

* `all`
* `first`
* `find`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` 콜백은 클래스의 객체를 새로 생성할 때 마다 자동으로 실행합니다. [[[The `after_initialize` callback is triggered every time a new object of the class is initialized.]]]

NOTE: `find_by_*` 와 `find_by_*!` 메소드는 레코드의 모든 속성에 대해 액티브 레코드가 알아서 만들어주는 검색 메소드입니다. [Dynamic finders section](active_record_querying.html#dynamic-finders)을 참고하세요. [[[The `find_by_*` and `find_by_*!` methods are dynamic finders generated automatically for every attribute. Learn more about them at the [Dynamic finders section](active_record_querying.html#dynamic-finders)]]]

[Skipping Callbacks] 콜백을 우회하는 방법
------------------

밸리데이션(검증)과 마찬가지로 콜백을 우회하는 방법이 있습니다. 그러나 주요 업무 규칙과 애플리케이션이 합리적으로 처리하는 방법이 콜백에 있을 수 있어서 아래의 메소드는 주의해서 사용해야 합니다. 암묵적으로 동의한 내용을 검토하지 않고 콜백을 우회하면 부적합한 데이타가 생길수도 있습니다. [[[Just as with validations, it is also possible to skip callbacks. These methods should be used with caution, however, because important business rules and application logic may be kept in callbacks. Bypassing them without understanding the potential implications may lead to invalid data.]]]

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

[Halting Execution] 콜백을 순서대로 실행하다가 멈추는 방법
-----------------

모델에 콜백을 새로 등록하면, 콜백을 실행할 큐에 담습니다. 큐에는 해당 모델의 밸리데이션과 등록한 콜백, 데이터베이스를 처리하는 모든 것이 순서대로 넣습니다. [[[As you start registering new callbacks for your models, they will be queued for execution. This queue will include all your model's validations, the registered callbacks, and the database operation to be executed.]]]

꼬리를 물듯 이어진 콜백은 하나의 트랜잭션으로 묶습니다. _before_ 콜백 메소드 중 하나가 `false`를 반환하거나 예외가 발생하면, 실행할 메소드가 맞물린 연결고리를 끊어버리고 데이터베이스를 롤백(ROLLBACK) 합니다; _after_ 콜백은 예외가 발생할때만 멈춤니다. [[[The whole callback chain is wrapped in a transaction. If any _before_ callback method returns exactly `false` or raises an exception, the execution chain gets halted and a ROLLBACK is issued; _after_ callbacks can only accomplish that by raising an exception.]]]

WARNING. 예외를 임의로 발생하면 `save`를 기다리는 코드를 멈춤니다. `ActiveRecord::Rollback` 예외는 발생하는 즉시 액티브 레코드로 롤백하도록 알려줍니다. 이 예외는 액티브 레코드 안에서 처리하고 밖에서 예외처리하도록 건내주지 않습니다. [[[Raising an arbitrary exception may break code that expects `save` and its friends not to fail like that. The `ActiveRecord::Rollback` exception is thought precisely to tell Active Record a rollback is going on. That one is internally captured but not reraised.]]]

[Relational Callbacks] 모델 관계에 대한 콜백
--------------------

콜백은 모델 관계에 대해서도 동작하며, 모델 관계에 따라 정의할 수 있습니다. 아래와 같이 사용자 user와 게시글 post가 일대다 관계(has many)라고 하겠습니다. 사용자의 게시글을 삭제해야 할 경우는 사용자를 삭제할 때 입니다. `after_destroy` 콜백을 사용자 `User` 모델에 사용하려면 게시글 `Post`와 관계를 선언한 has_many 뒤에 씁니다: [[[Callbacks work through model relationships, and can even be defined by them. Suppose an example where a user has many posts. A user's posts should be destroyed if the user is destroyed. Let's add an `after_destroy` callback to the `User` model by way of its relationship to the `Post` model:]]]

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

[Conditional Callbacks] 콜백에 조건을 걸어 분기하여 실행하는 방법
---------------------

밸리데이션과 마찬가지로, 조건식에 충족하는 콜벡 메소드를 실행할 수 있습니다. `:if` 와 `:unless` 을 사용할 수 있고, 옵션 뒤에는 심볼, 문자열, `프록` 또는 `배열`이 올 수 있습니다. `:if` 옵션으로 **반드시 실행할** 콜백을 쓰고 ***반드시 실행하지 않을** 콜백을 쓰려면 `:unless` 옵션을 사용합니다. [[[As with validations, we can also make the calling of a callback method conditional on the satisfaction of a given predicate. We can do this using the `:if` and `:unless` options, which can take a symbol, a string, a `Proc` or an `Array`. You may use the `:if` option when you want to specify under which conditions the callback **should** be called. If you want to specify the conditions under which the callback **should not** be called, then you may use the `:unless` option.]]]

### [Using `:if` and `:unless` with a `Symbol`] `:if` 와 `:unless` 옵션 뒤에 `심볼`을 쓰는 경우

`:if` 와 `:unless` 옵션 뒤에 심볼을 써서 참과 거짓을 판별하는 메소드를 쓸 수 있으며 콜백보다 먼저 실행합니다. `:if` 옵션은 메소드 실행결과 `false`이면 콜백을 실행하지 않고 `:unless` 옵션은 메소드 실행결과 `true`이면 콜백을 실행하지 않습니다. 이 옵션을 주로 많이 사용합니다. 콜백을 등록할 때 옵션을 사용하면서 판별하는 메소드를 여러 개 등록하여 콜백을 실행할지 정할 수 있습니다. [[[You can associate the `:if` and `:unless` options with a symbol corresponding to the name of a predicate method that will get called right before the callback. When using the `:if` option, the callback won't be executed if the predicate method returns false; when using the `:unless` option, the callback won't be executed if the predicate method returns true. This is the most common option. Using this form of registration it is also possible to register several different predicates that should be called to check if the callback should be executed.]]]

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### [Using `:if` and `:unless` with a String] `:if` 와 `:unless` 옵션 뒤에 문자열을 쓰는 경우

문자열을 사용할 때는 `eval` 메소드로 문자열 내용을 실행할 수 있으며 문자열 내용은 올바른 루비 코드여야 합니다. 이 옵션을 쓰는 경우는 매우 짧은 조건식을 문자열로 쓸 때로 제한해야 합니다. [[[You can also use a string that will be evaluated using `eval` and hence needs to contain valid Ruby code. You should use this option only when the string represents a really short condition:]]]

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: "paid_with_card?"
end
```

### [Using `:if` and `:unless` with a `Proc`] `:if` 와 `:unless` 옵션 뒤에 `프록`을 쓰는 경우

마지막으로, `:if` 와 `:unless` 옵션 뒤에 `프록` 객체를 사용할 수 있습니다. 이 옵션은 길지 않은 밸리데이션 메소드에 적합하며, 대체로 한 줄짜리 메소드입니다: [[[Finally, it is possible to associate `:if` and `:unless` with a `Proc` object. This option is best suited when writing short validation methods, usually one-liners:]]]

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

### [Multiple Conditions for Callbacks] 콜백을 실행할 조건을 섞어 쓰는 경우

콜백에 대한 조건식을 작성할 때 `:if` 와 `:unless` 옵션을 섞어서 사용할 수 있습니다. [[[When writing conditional callbacks, it is possible to mix both `:if` and `:unless` in the same callback declaration:]]]

```ruby
class Comment < ActiveRecord::Base
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.post.ignore_comments? }
end
```

[Callback Classes] 콜백 클래스
----------------

간혹 콜백 메소드가 다른 모델에 써도 충분히 좋을 때가 있습니다. 액티브 레코드는 콜백 메소드를 클래스로 묶어서 메소드가 캡슐 속에 숨기듯이 은닉화할 수 있으며, 재사용하기에 편리합니다. [[[Sometimes the callback methods that you'll write will be useful enough to be reused by other models. Active Record makes it possible to create classes that encapsulate the callback methods, so it becomes very easy to reuse them.]]]

아래는 `PictureFile` 모델에 `after_destroy`콜백을 클래스로 만들어서 적용한 예시 코드입니다. [[[Here's an example where we create a class with an `after_destroy` callback for a `PictureFile` model:]]]

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exists?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

위와 같이 클래스 안에서 콜백 메소드를 선언할 때, 콜백 메소드에게 모델 객체를 파라미터로 넘겨줍니다. 콜백 클래스를 모델에서 아래와 같이 사용합니다: [[[When declared inside a class, as above, the callback methods will receive the model object as a parameter. We can now use the callback class in the model:]]]

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks.new
end
```

미리 알아둘 사항으로 `PictureFileCallbacks` 객체를 생성해야 하는데, 콜백 메소드를 인스턴스 메소드로 선언했기 때문입니다. 메모리에 생성한 객체의 상태를 이용할 때는 적절한 방법입니다. 그러나 콜백 메소드를 클래스 메소드로 선언하는 편이 보편 타당하겠습니다. [[[Note that we needed to instantiate a new `PictureFileCallbacks` object, since we declared our callback as an instance method. This is particularly useful if the callbacks make use of the state of the instantiated object. Often, however, it will make more sense to declare the callbacks as class methods:]]]

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exists?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

위와 같이 콜백 메소드를 선언하면, `PictureFileCallbacks` 객체를 생성할 필요가 없습니다. [[[If the callback method is declared this way, it won't be necessary to instantiate a `PictureFileCallbacks` object.]]]

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks
end
```

콜백 클래스에 개발자가 원하는 대로 콜백을 여러 개 선언할 수 있습니다. [[[You can declare as many callbacks as you want inside your callback classes.]]]

[Transaction Callbacks] 데이터베이스 트랜잭션에 대한 콜백
---------------------

데이터베이스 트랜잭션이 끝나면 자동으로 실행하는 콜백 메소드로 `after_commit` 와 `after_rollback` 가 있습니다. `after_save` 콜백을 닮아서 데이터베이스를 커밋하거나 롤백해서 내용이 바뀔 때까지 실행하지 않고 기다립니다. 대체로 액티브 레코드 모델이 데이터베이스 트랙잭션을 담당하지 않은 외부 시스템과 연동해야 할 때 사용합니다. [[[There are two additional callbacks that are triggered by the completion of a database transaction: `after_commit` and `after_rollback`. These callbacks are very similar to the `after_save` callback except that they don't execute until after database changes have either been committed or rolled back. They are most useful when your active record models need to interact with external systems which are not part of the database transaction.]]]

이를테면, 위의 예시 중에서 `PictureFile` 모델이 해당 레코드를 데이터베이스에서 삭제한 다음 파일을 지워야하는 경우입니다. `after_destroy` 콜백을 실행한 다음 예외를 발생시켜서 데이터베이스를 롤백하는 경우, 파일은 지우겠지만 모델의 내용은 깨져버린 상태로 남겠습니다. 예를 들어, 아래와 같이 `picture_file_2` 가 적합하지 않으면 `save!` 메소드에서 예외가 발생합니다. [[[Consider, for example, the previous example where the `PictureFile` model needs to delete a file after the corresponding record is destroyed. If anything raises an exception after the `after_destroy` callback is called and the transaction rolls back, the file will have been deleted and the model will be left in an inconsistent state. For example, suppose that `picture_file_2` in the code below is not valid and the `save!` method raises an error.]]]

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

`after_commit` 콜백을 사용하여 이러한 문제를 해결할 수 있습니다. [[[By using the `after_commit` callback we can account for this case.]]]

```ruby
class PictureFile < ActiveRecord::Base
  after_commit :delete_picture_file_from_disk, :on => [:destroy]

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: `:on` 옵션으로 콜백을 실행할 시점을 정합니다. `:on` 옵션이 없으면 생성, 수정, 삭제하는 모든 경우에 콜백을 실행합니다. [[[the `:on` option specifies when a callback will be fired. If you don't supply the `:on` option the callback will fire for every action.]]]

`after_commit` 와 `after_rollback` 콜백은 모델을 생성, 수정하거나 삭제할 때 하나의 트랜잭션 블럭에서 실행하도록 보장합니다. 콜백 중 하나라도 예외가 발생하면, 예외로 중단하지 않고 일단 다음 콜백을 실행합니다. 따라서, 콜백 코드에서 예외가 발생하면, 콜백 안에서 예외를 잡아서 적절하게 처리해야 합니다. [[[The `after_commit` and `after_rollback` callbacks are guaranteed to be called for all models created, updated, or destroyed within a transaction block. If any exceptions are raised within one of these callbacks, they will be ignored so that they don't interfere with the other callbacks. As such, if your callback code could raise an exception, you'll need to rescue it and handle it appropriately within the callback.]]]
