
Active Record 기초
====================

여기에서는 Active Record의 기초에 대해서 설명합니다.

이 가이드의 내용:

* ORM (Object Relational Mapping)과 Active Record에 대해서, 그리고 Rails에서의 사용 방법
* Active Record와 MVC(Model-View-Controller) 패러다임의 친화성
* Active Record 모델을 사용해서 관계형 데이터베이스에 저장된 데이터를 조작하기
* Active Record 스키마 명명 규칙
* 데이터베이스의 마이그레이션, 유효성 검사(Validation), 콜백

--------------------------------------------------------------------------------

Active Record에 대해서
----------------------

Active Record란 [MVC](https://ko.wikipedia.org/wiki/모델-뷰-컨트롤러)에서
말하는 M, 다시 말해 모델에 해당하는 것으로, 비지니스 데이터와 비지니스 로직을
표현하기 위한 계층입니다. Active Record는 데이터베이스에 항구적으로 보존될
필요가 있는 비지니스 객체를 편하게 생성하고 사용할 수 있게 해줍니다.
Active Record는 ORM(Object Relational Mapping) 시스템에 기술되어 있는
'Active Record 패턴'을 구현한 것으로 이와 같은 이름이 붙혀져 있습니다.

### Active Record 패턴

[Active Record는 Martin Fowler가 쓴](http://www.martinfowler.com/eaaCatalog/activeRecord.html)
_Patterns of Enterprise Application Architecture_ 라는 서적에서 언급되었습니다.
Active Record에 있어서 객체란 영속적인 데이터로, 그 데이터와 데이터의 행동에
대한 것이기도 합니다. Active Record에서는 데이터에 접근하는 방식을 확실히 하는
것은, 그 객체의 사용자에게 데이터베이스에 읽고 쓰는 방법을 가르치는 것의
일부이다, 라는 의견을 채용하고 있습니다.

### O/R 매핑

객체 관계 매핑(O/R매핑이나 ORM이라고 줄여쓰기도 합니다)이란 애플리케이션이
가진 다양한 객체를 관계형 데이터베이스(RDBMS)의 테이블에 연결하는 것입니다.
ORM을 사용하는 것으로 SQL문을 직접 작성하는 대신 적은 코드를 작성하는 것으로
애플리케이션의 객체의 속성이나 관계를 데이터베이스에 저장하거나 읽어올 수
있게 됩니다.

### ORM 프레임워크로서의 Active Record

Active Record에는 다양한 기능이 구현되어있으며, 그 중에서 아래에 언급한 것들이
특히 중요합니다.

* 모델과 그의 데이터를 표현한다.
* 모델간의 관계(Association)를 표현한다.
* 관련된 모델을 이용해서 상속 계층을 표현한다.
* 데이터가 데이터베이스에 저장되기 전에 검증을 수행한다.
* 객체 지향적인 방법으로 데이터베이스를 조작한다.

Active Record에 있어서의 CoC(Convention over Configuration)
----------------------------------------------

다른 프로그래밍 언어나 프레임워크를 사용해서 애플리케이션을 개발하면, 설정을
위한 코드를 대량으로 작성하는 경우가 자주 발생합니다. 일반적인
ORM 애플리케이션에서 특히 이런 경향이 있습니다. 하지만 Rails에 적합한 규칙에
따르게 되면, Active Record 모델을 만들때 설정에 관련된 코드는 최소한으로 줄일
수 있습니다. 상황에 따라서는 설정을 위한 코드가 전혀 필요 없는 경우도 있습니다.
이것은 애플리케이션의 설정이 대부분 동일하다면, 그것을 기본값으로 설정해야
한다는 생각에 기초하고 있습니다. 다시 말해, 명시적인 설정이 필요한 경우는
표준 규칙만으로는 부족한 경우 뿐입니다.

### 명명 규칙

Active Record에는 모델과 데이터베이스의 테이블을 매핑할 때에 지켜야할 규칙이
몇 가지 있습니다. Rails에서는 데이터베이스의 테이블 이름을 찾을 때에 모델의
클래스명의 복수형을 사용합니다. 다시 말해 `Book`이라는 모델 클래스가 있을 경우,
여기에 대응하는 데이터베이스의 테이블은 복수형인 **books**이 됩니다. Rails의
복수형화 알고리즘은 무척 영리해서 불규칙 변형일 경우에도 복수형으로 변환하거나,
단수형으로 변환할 수 있습니다(person <-> people 등). 모델의 클래스명이 2단어
이상의 복합어일 경우, Ruby의 관습인 CamelCase에 따라주세요. 그리고 테이블의
이름은 소문자에 밑줄(CamelCase에 대응하는 테이블 명은 camel_cases가 됩니다)을
이용해야 합니다. 이하의 예제를 참조해주세요.

* 데이터베이스 테이블명 - 복수형, 단어는 밑줄로 구분한다. (ex: `book_clubs`)
* 모델 클래스명 - 단수형, 단어는 대문자로 시작한다. (es: `BookClub`)

| 모델 / 클래스 | 테이블 / 스키마 |
| ------------- | -------------- |
| `Post`        | `posts`        |
| `LineItem`    | `line_items`   |
| `Deer`        | `deers`        |
| `Mouse`       | `mice`         |
| `Person`      | `people`       |


### 스키마 규칙

Active Record에서는 데이터베이스의 테이블에 사용하는 컬럼명에 대해서도 사용
목적에 따른 규칙이 존재합니다.

* **Foreign keys** - 이 컬럼은 `테이블명의 단수형_id` 로 명명합니다.
(ex: `item_id`, `order_id`) 이 컬럼들은 Active Record가 모델간의 관계를
설정할 때 참조합니다.

* **Primary Keys** - 기본값으로 `id`라는 이름을 가지는 integer 형의 컬럼을
테이블의 기본키로 사용합니다. 이 컬럼은
[Active Record Migrations](active_record_migrations.html)을 사용해서
테이블을 작성할 때에 자동으로 생성됩니다.

이외에도, Active Record 인스턴스에 기능을 추가하는 컬럼이 더 있습니다. 

* `created_at` - 레코드가 생성된 시점의 시각을 자동으로 저장합니다.
* `updated_at` - 레코드가 갱신된 시점의 시각을 자동으로 저장합니다.
* `lock_version` - 모델에 [optimistic locking](http://api.rubyonrails.org/classes/ActiveRecord/Locking.html)을 추가합니다.
* `type` - 모델에 [Single Table Inheritance](http://api.rubyonrails.org/classes/ActiveRecord/Base.html#label-Single+table+inheritance)를 사용하는 경우에 추가됩니다.
* `관계명_type` - [Polymorphic Associations](association_basics.html#polymorphic-associations)의 종류를 저장합니다.
* `테이블명_count` - 관계 설정에 있어서 속해있는 객체 숫자를 캐싱하기 위해서 사용됩니다. 예를 들어 `Post` 클래스에 `comments_count`라는 컬럼이 있고, 거기에 `Comment` 인스턴스가 다수 존재한다면, 각각의 Post마다 Comment의 숫자가 캐싱됩니다.

NOTE: 이 컬럼명들은 필수는 아니지만, Active Record에 의해서 예약되어 있습니다.
어쩔 수 없는 경우가 아니라면 이 예약된 컬럼명을 사용하는 것은 피해주세요.
예를 들어 `type`라는 단어는 테이블에서 Single Table Inheritance(STI)를
지정하기 위해서 예약되어 있습니다. STI를 사용하지 않는 경우라도 예약어보다는
"context"같은, 데이터를 적절히 표현할 수 있는 단어를 검토해주세요.

Active Record 모델 만들기
-----------------------------

Active Record 모델을 만드는 것은 무척 간단합니다. 다음과 같이
`ActiveRecord::Base` 클래스의 자식 클래스를 만들기만 하면 끝입니다.

```ruby
class Product < ActiveRecord::Base
end
```

위의 코드는 `Product` 모델을 만들고, 데이터베이스의 `products` 테이블에
매핑됩니다. 거기에 테이블에 포함되어있는 각 컬럼을 만들어진 모델의 인스턴스의
속성으로 매핑합니다. 이하의 SQL문에서 `products`라는 테이블을 생성했다고
해봅시다.

```sql
CREATE TABLE products (
   id int(11) NOT NULL auto_increment,
   name varchar(255),
   PRIMARY KEY  (id)
);
```

위의 테이블 스키마에 맞추어서, 아래와 같은 코드를 작성할 수 있습니다.

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

명명 규칙을 덮어쓰기
---------------------------------

Rails 애플리케이션에서 별도의 명명 규칙을 사용하지 않으면 안되는, 예를 들어
레거시 데이터베이스를 사용해서 Rails 애플리케이션을 작성하지 않으면 곤란한
경우에는 어떻게 하면 될까요. 그런 상황에는 기본 명명 규칙을 간단하게 덮어쓸
수 있습니다.

`ActiveRecord::Base.table_name=` 메소드를 사용해서 사용할 테이블명을 명시적으로
지정할 수 있습니다.

```ruby
class Product < ActiveRecord::Base
  self.table_name = "PRODUCT"
end
```

테이블명을 지정했을 경우, 테스트 정의에서 `set_fixture_class` 메소드를 사용해
픽스쳐(클래스명.yml)에 대응하는 클래스명을 별도로 정의할 필요가 있습니다.

```ruby
class FunnyJoke < ActiveSupport::TestCase
  set_fixture_class funny_jokes: Joke
  fixtures :funny_jokes
  ...
end
```

`ActiveRecord::Base.primary_key=` 메소드를 사용해서 테이블의 기본키로 사용할
컬럼명도 덮어쓸 수 있습니다.

```ruby
class Product < ActiveRecord::Base
  self.primary_key = "product_id"
end
```

CRUD: 데이터 읽고 쓰기
------------------------------

CRUD란 4개의 데이터베이스 조작을 가리키는 **C** reate, **R** ead, **U** pdate,
**D** elete의 첫글자입니다. Active Record는 각각에 대한 메소드를 자동적으로
생성하고, 이를 이용해서 애플리케이션은 테이블에 저장되어 있는 데이터를 조작할
수 있습니다.

### Create

Active Record의 객체는 해시나 블록을 이용해서 생성할 수 있습니다. 또한 생성
후에는 속성을 수동으로 추가할 수도 있습니다. `new` 메소드를 실행하면 새로운
객체가 반환됩니다만, `create`를 실행하면 새로운 객체가 반환되고, 나아가
데이터베이스에 저장도 수행합니다.

예를 들어 `User`라는 모델에 `name`과 `occupation`라는 속성이 있다고 하면,
`create` 메소드를 실행하면 새로운 레코드가 하나 생성되고, 데이터베이스에
저장됩니다.

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

`new` 메소드를 사용한 경우에는 객체는 저장되지 않고 인스턴스로 반환되기만
합니다.

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

이 경우, `user.save`를 실행해야만 데이터베이스에 레코드가 저장됩니다.

마지막으로 `create`나 `new`에 블록을 건네주면, 새로운 객체는 초기화를 위해서
블록을 사용합니다.

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Read

Active Record는 데이터베이스의 데이터에 접근하기 위해 풍부한 API를 제공합니다.
아래는 Active Record에 의해서 제공되는 다양한 데이터 접근 메소드 중의 몇몇
예시입니다.

```ruby
# 모든 사용자 컬렉션을 반환한다
users = User.all
```

```ruby
# 첫번째 사용자를 반환한다
user = User.first
```

```ruby
# David라는 이름을 가지는 첫번째 사용자를 반환한다
david = User.find_by(name: 'David')
```

```ruby
# 이름이 David이고, 직업이 코드 아티스트인 사용자를 모두 반환하고,
# created_at 컬럼을 기준으로 내림차순으로 정렬한다.
users = User.where(name: 'David', occupation: 'Code Artist').order('created_at DESC')
```

Active Record 모델에 쿼리를 실행하는 것은
[Active Record Query Interface](active_record_querying.html)에서 자세하게
설명합니다.

### Update

Active Record 객체를 받으면 객체의 속성을 변경하고 데이터베이스에 저장할 수
있습니다.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

위의 코드를 더 짧게 하려면, 속성명과 설정할 값을 매핑하는 해시를 사용해서
다음과 같이 작성할 수 있습니다.

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

이것은 여러 속성을 한번에 변경하고 싶을 때에 편리합니다. 나아가서 여러 개의
레코드를 한 번에 변경하고 싶다면 `update_all`이라는 클래스 메소드를 사용할 수
있습니다.

```ruby
User.update_all "max_login_attempts = 3, must_change_password = 'true'"
```

### Delete

다른 메소드와 마찬가지로 Active Record 객체를 얻으면, 그 객체를 destroy하는
것으로 데이터베이스에서 삭제할 수 있습니다.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

유효성 검사(validation)
-----------

Active Record를 사용해서 모델이 데이터베이스에 저장되기 전에 모델의 상태를
검증할 수 있습니다. 모델을 검사하기 위해서 다양한 메소드들의 준비되어 있습니다.
속성이 존재하는지, 유일한 값인지, 특정한 형식에 따르고 있는지 등을 검사할 수
있습니다.

유효성 검사는 데이터베이스를 영속화하는 데에 무척 중요합니다. 이 때문에
`create`, `save`, `update` 메소드는 검증이 실패하는 경우 `false`를 반환합니다.
이런 경우에는 데이터베이스에 아무런 변경도 발생하지 않습니다. 이 3개의
메소드에는 각각 파괴적인 버전(`create!`, `save!`, `update!`)가 있으며, 검증에
실패한 경우에는 좀 더 엄격한 대응, 다시 말해서 `ActiveRecord::RecordInvalid`
예외를 발생시킵니다.

아래의 예로 간단하게 설명하겠습니다.

```ruby
class User < ActiveRecord::Base
  validates :name, presence: true
end

User.create  # => false
User.create! # => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

유효성 검사에 대한 자세한 설명은
[Active Record Validations](active_record_validations.html)를 참조해주세요.

콜백
---------

Active Record 콜백을 사용하는 것으로 모델의 라이프 사이클 중 특정 이벤트가
발생했을 때에 원하는 코드를 실행할 수 있습니다. 레코드의 생성, 갱신, 삭제 등
다양한 이벤트에 대해서 콜백을 설정할 수 있습니다. 자세한 설명은
[Active Record Callbacks](active_record_callbacks.html)를 참조해주세요.

마이그레이션
----------

Rails에는 데이터베이스 스키마를 관리하기 위한 도메인 특화
언어(DSL: Domain Specific Language)가 있으며, 마이그레이션(migration)이라고도
불립니다. 마이그레이션은 파일로 저장됩니다. `bin/rails`를 통해 Active Record가
지원하는 다양한 데이터베이스에 대한 마이그레이션을 수행할 수 있습니다.
아래는 테이블을 생성하는 마이그레이션입니다.

```ruby
class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.integer :publisher_id
      t.string :publisher_type
      t.boolean :single_issue

      t.timestamps
    end
    add_index :publications, :publication_type_id
  end
end
```

Rails는 어떤 마이그레이션 파일이 데이터베이스에 반영되어있는지 파악하고 있어서,
그 정보를 활용해 롤백 기능도 제공하고 있습니다. 테이블을 실제로 생성하기
위해서는 `bin/rails db:migrate`를 실행합니다. 롤백하기 위해서는
`bin/rails db:rollback`을 실행하면 됩니다.

위의 마이그레이션 코드는 데이터베이스에 의존하지 않는다는 점에 주목해주세요.
MySQL, PostgreSQL, Oracle 등, 다수의 데이터베이스에 대해서 실행할 수 있습니다.
마이그레이션에 대한 자세한 설명은
[Active Record Migrations](active_record_migrations.html)을 참조해주세요.

