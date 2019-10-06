# 액티브 레코드 기본 {#active-record-basics}

이 가이드는 액티브 레코드에 대한 소개이다.

이 가이드를 읽은 후 아래의 내용을 알게 될 것이다.

- Object Relational Mapping(ORM)과 액티브 레코드는 무엇이고 레일스에서 어떻게 사용되는지.
- 액티브 레코드가 모델-뷰-컨트롤러 패러다임에 어떻게 적용되는지
- 액티브 레코드 모델을 사용하여 관계형 데이터베이스에 저장된 데이터를 다루는 방법
- 액티브 레코드 스키마 명명 규칙.
  데이터베이스 마이그레이션, 유효성 검사 및 콜백의 개념

---

## 액티브 레코드란? {#what-is-active-record?}

액티브 레코드는 [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)의 M (모델)에 해당하며, 비즈니스 데이터 및 로직를 나타내는 시스템 계층이다. 액티브 레코드는 데이터베이스에 데이터를 지속적으로 저장해야 하는 비즈니스 객체의 작성 및 사용을 용이하게 한다. 이것은 Object Relational Mapping(ORM: 객체와 관계형 데이터베이스를 연결하는 작업) 시스템을 기술해 놓은 것으로 액티브 레코드 패턴을 구현한 것이다.

### 액티브 레코드 패턴 {#the-active-record-pattern}

[마틴 파울러(Martin Fowler)는 그의 저서 _Patterns of Enterprise Application Architecture_ 에서 액티브 레코드를 기술했다](https://www.martinfowler.com/eaaCatalog/activeRecord.html). 액티브 레코드에서 객체란 영구 데이터와 그 데이터를 다루는 동작을 모두 가지고 있다. 데이터 액세스 로직이 액티브 레코드 객체 내에 포함되어 있기 때문에, 그 객체를 사용하는 사람들은 객체내에 포함된 로직에 따라 데이터베이스로부터 읽고 쓰는 법을 알게 될 것이다.

### 객체 관계 매핑 {#object-relational-mapping}

NOTE: 객체를 관계형 데이터베이스로 연결하는 것을 말한다.(역주)

일반적으로 ORM이라는 약자로 일컫는 [객체 관계 매핑](https://en.wikipedia.org/wiki/Object-relational_mapping)은 애플리케이션 내의 객체를 관계형 데이터베이스 관리 시스템의 테이블에 연결하는 기술이다. ORM을 사용하면 SQL 문을 직접 작성하지 않고 전체 데이터베이스 액세스 코드를 적게 사용하고도 애플리케이션 내 객체의 특성 및 관계를 데이터베이스에서 쉽게 저장하고 검색 할 수 있다.

NOTE: 관계형 데이터베이스 관리 시스템 (RDBMS) 및 구조적 쿼리 언어 (SQL)에 대한 기본 지식은 액티브 레코드를 완전히 이해하는 데 도움이 된다. 더 많은 내용을 배우고자 할 경우, [이 튜토리얼](https://www.w3schools.com/sql/default.asp) (또는 [이것](http://www.sqlcourse.com/))을 참조하거나 다른 방법으로 학습하기 바란다.

### ORM으로서 액티브 레코드 사용하기 {#active-record-as-an-orm-framework}

액티브 레코드가 제공해 주는 여러가지 기전 중에서 가장 중요한 기능은 아래와 같다.

- 모델과 해당 데이터를 나타낸다.
- 모델 간의 연관성을 나타낸다.
- 모델 간의 연관성을 통해서 상속 계층을 나타낸다.
- 데이터베이스로 저장되기 전에 모델의 유효성 검증을 한다.
- 객체지향 방식으로 데이터베이스 작업을 수행한다.

## 액티브 레코드에서 COC 원칙 {#convention-over-configuration-in-active-record}

NOTE: Convention Over Configuration를 COC라는 약자로 말하기도 함. 설정보다는 관례를 우선시 함.

다른 프로그래밍 언어나 프레임워크를 사용하여 애플리케이션을 작성할 때 설정을 위한 많은 코드를 작성해야 할 수도 있다. 이것은 일반적으로 ORM 프레임워크에 적용된다. 그러나 레일스에서 채택한 관례를 따르는 경우 액티브 레코드 모델을 작성할 때 설정을 위한 코드를 거의 작성하지 않아도 된다(일부 경우에는 설정 코드가 전혀 필요 없음). 동일한 방식으로 애플리케이션을 설정하는 대부분의 경우 이런 방식이 기본이 되어야 한다. 따라서 표준 관례을 준수 할 수 없는 경우에만 명시적 설정이 필요하다.

### 명명 규칙 {#naming-conventions}

기본적으로 액티브 레코드는 몇 가지 명명 규칙을 사용하여 모델과 데이터베이스 테이블 간의 매핑을 만드는 방법을 찾는다. 레일스는 각 데이터베이스 테이블을 찾기 위해 클래스 이름을 복수화한다. 따라서 `Book` 클래스의 경우 **books**라는 데이터베이스 테이블이 있어야 한다. 레일스의 복수형 기전은 매우 강력하여 규칙적인 단어와 불규칙적 인 단어를 모두 복수화 (및 단일화) 할 수 있다. 둘 이상의 단어로 구성된 클래스 이름을 사용하는 경우 모델 클래스 이름은 CamelCase 형태를 사용하여 루비 규칙을 따라야 하며 테이블 이름은 밑줄로 구분 된 단어를 포함해야 한다. 예:

- 모델 클래스 - 단수형, 각 단어의 첫글자는 대문자로 시작 (예: `BookClub`).
- 데이터베이스 테이블 - 복수형, 밑줄 문자로 단어를 구분 (예: `book_clubs`).

| 모델 / 클래스 | 테이블 / 스키마 |
| ------------- | --------------- |
| `Article`     | `articles`      |
| `LineItem`    | `line_items`    |
| `Deer`        | `deers`         |
| `Mouse`       | `mice`          |
| `Person`      | `people`        |

### 스키마 규칙 {#schema-conventions}

액티브 레코드는 컬럼의 사용 목적에 따라 데이터베이스 테이블의 컬럼 명명 규칙을 사용한다.

- **Foreign keys** - `singularized_table_name_id` 패턴에 따라 명명되어야 한다(예: `item_id`, `order_id`). 모델 간 관계 설정시 액티브 레코드에서 찾는 필드이다.
- **Primary keys** - 기본적으로 액티브 레코드는 테이블 프라이머리 키로 정수형 컬럼인 `id`를 사용한다 (PostgreSQL과 MySQL용으로는 `bigint`, SQLite용으로는 `integer` 데이터형을 사용함). 테이블를 생성하기 위해 [액티브 레코드 마이그레이션](active_record_migrations.html)을 사용할 경우 이 컬럼들은 자동으로 추가될 것이다.

액티브 레코드 인스턴스에 특별한 기능을 추가 할 수 있는 선택적 컬럼 이름도 있다.

- `created_at` - 레코드를 처음으로 생성할 때 현재 날짜와 시간으로 자동 설정된다.
- `updated_at` - 레코드를 생성하거나 업데이트할 때마다 현재 날짜와 시간으로 자동 설정된다.
- `lock_version` - 모델에 [optimistic locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html)을 추가한다.
- `type` - 모델이 [Single Table Inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)를 사용하도록 지정한다.
- `(association_name)_type` - [polymorphic associations](association_basics.html#polymorphic-associations)의 형태를 저장한다.
- `(table_name)_count` - 모델간의 관계상 belonging 객체 수를 캐시하는 데 사용된다. 예를 들어, 다수의 `Comment` 인스턴스를 가지는 `Article` 클래스의 `comments_count` 컬럼은 각 기사에 올라 온 댓글 수를 캐시한다.

NOTE: 이와 같은 컬럼 이름은 옵션이지만 실제로는 액티브 레코드에 의해 예약되어 있다. 특별한 추가 기능을 필요하지 않으면 예약 키워드를 사용하지 않도록 한다. 예를 들어, `type`은 STI (Single Table Inheritance)를 사용하여 테이블을 지정하는 데 사용되는 예약 키워드이다. STI를 사용하지 않는 경우에는 "context"와 같은 유사한 키워드를 사용하더라도 모델링 중인 데이터를 정확하게 설명 할 수 있을 것이다.

## 액티브 레코드 모델 생성하기 {#creating-active-record-models}

액티브 레코드 모델을 생성하는 것은 매우 쉽다. `ApplicationRecord` 클래스를 상속하여 하위 클래스를 만들기만 하면 되며 아래와 같은 모습을 하게 된다.

```ruby
class Product < ApplicationRecord
end
```

이것은 `Product` 모델을 생성하여 데이터베이스의 `products` 테이블로 매핑할 것이다. 이로써 테이블의 각 컬럼을 모델 인스턴스의 각 속성과 매핑할 수 있게 된다. 아래와 같은 SQL문(또는 SQL 확장문 중의 하나)으로 `products` 테이블을 생성했다고 가정해 보자.

```sql
CREATE TABLE products (
   id int(11) NOT NULL auto_increment,
   name varchar(255),
   PRIMARY KEY  (id)
);
```

위의 스키마는 두 개의 컬럼 `id`와 `name`을 가지는 테이블을 선언한다. 이 테이블의 각 레코드는 두 개의 파라미터를 가진 product를 나타낸다. 따라서, 아래와 같이 코드를 작성할 수 있을 것이다.

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

## 명명 규칙 변경하기 {#overriding-the-naming-conventions}

다른 종류의 명명 규칙이 필요하거나 예전 데이터베이스로 연결하는 레일스 애플리케이션이 필요한 경우에는 어떻게 해야 할까? 별다른 어려움 없이 기본 명명 규칙을 쉽게 변경할 수 있다.

`ApplicationRecord`는 `ActiveRecord::Base`를 상속 받는데, 이것은 다수의 도움되는 메소드를 정의한다. `ActiveRecord::Base.table_name=` 메소드를 사용하여 테이블 이름을 아래와 같이 지정할 수 있다.

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

이런 경우에는, 테스트 정의 클래스에서 `set_fixture_class` 메소드를 사용하여 픽스쳐(my_products.yml)를 호스팅하는 클래스명을 직접 정의해 주어야 할 것이다.

```ruby
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  ...
end
```

또한 `ActiveRecord::Base.primary_key=` 메소드를 사용하여 테이블의 프라이머리 키를 사용할 컬럼 이름을 변경할 수 있다.

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

NOTE: 액티브 레코드는 일반 컬럼명으로 `id`를 사용하는 것을 지원하지 않는다.

## CRUD: 데이터를 읽고 쓰기 {#crud:-reading-and-writing-data}

CRUD는 데이터 조작을 위해서 사용하는 4개의 동사(**C**reate,
**R**ead, **U**pdate and **D**elete)의 첨두어이다. 액티브 레코드는 테이블로부터 데이터를 불러 들이고 조작할 수 있는 메소드를 자동으로 생성한다.

### Create 메소드 {#create-method}

액티브 레코드 객체는 해시, 블록으로 부터 만들거나 만들어 진 후에 각 속성을 수동으로 설정할 수 있다. `new` 메소드는 새 객체를 리턴하지만 `create` 메소드는 객체를 리턴하여 데이터베이스에 저장한다.

예를 들어, 속성이 `name`과 `occupation`인 모델 `User`가 주어지면 `create` 메소드 호출은 데이터베이스에 새 레코드를 작성하고 저장한다.

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

`new` 메소드를 사용하면 빈 객체를 생성할 수 있다.

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

`user.save` 메소드를 호출하면 레코드를 데이터베이스로 커밋할 것이다.

마지막으로, 블록을 지정할 경우 `create`와 `new` 메소드는 둘 다 새로운 객체를 블록으로 넘겨 주어 초기화할 수 있다.

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Read 메소드 {#read-method}

액티브 레코드는 데이터베이스 내의 데이터로 접근하기 위한 다수의 API를 제공한다. 아래에는 액티브 레코드에서 제공하는 다양한 데이터 접근 메소드의 예를 보여 준다.

```ruby
# 모든 사용자를 컬렉션으로 반환한다.
users = User.all
```

```ruby
# 첫번째 사용자를 반환한다.
user = User.first
```

```ruby
# David 라는 이름을 가진 첫번째 사용자를 반환한다.
david = User.find_by(name: 'David')
```

```ruby
# Code Artist 라는 직업을 가지면서 David 라는 이름을 가진 모든 사용자를 찾아 created_at 속성의 시간 역순으로 반환한다.
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

[Active Record Query Interface](active_record_querying.html) 가이드에서 액티브 레코드 모델 쿼리에 대한 자세한 내용을 볼 수 있다.

### Update 메소드 {#update-method}

액티브 레코드 객체를 검색하여 찾게 되면 해당 속성을 수정하여 데이터베이스에 저장할 수 있다.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

이에 대한 간략한 설명은 아래와 같이 속성 이름을 원하는 값으로 매핑하는 해시를 사용하는 것이다.

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

이와 같은 방법은 한 번에 여러 속성을 업데이트 할 때 가장 유용하다. 반면에 여러 레코드를 대량으로 업데이트하려면 `update_all` 클래스 메소드가 유용 할 수 있다.

```ruby
User.update_all "max_login_attempts = 3, must_change_password = 'true'"
```

### Delete 메소드 {#delete-method}

마찬가지로, 검색으로 찾은 액티브 레코드 객체를 삭제하므로써 데이터베이스에서 제거 할 수 있다.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

여러 레코드를 대량으로 삭제하려면 `destroy_by` 또는`destroy_all` 메소드를 사용할 수 있다.

```ruby
# David 라는 이름을 가진 모든 사용자를 찾아 삭제한다.
User.destroy_by(name: 'David')

# 모든 사용자를 삭제한다.
User.destroy_all
```

## 유효성 검증 {#validations}

액티브 레코드를 사용하면 모델이 데이터베이스에 기록되기 전에 모델의 상태를 확인할 수 있다. 모델을 확인하고 속성 값이 비어 있지 않고 유일하며 데이터베이스에 아직 미등록된 자료인지, 특정 형식을 따르는 지 등을 검증하는 데 사용할 수 있는 몇 가지 방법이 있다.

유효성 검사는 데이터베이스에 지속될 때 고려해야 할 매우 중요한 문제이므로, `save` 및 `update` 메소드는 실행할 때 이를 고려한다. 유효성 검사에 실패하면 `false`를 반환하고 실제로는 데이터베이스에 아무런 작업을 수행하지 않는다. 이 메소드는 모두 각각 뱅(!) 버전 (즉, `save!` 및 `update!`)을 가지며, 이는 유효성 검사에 실패할 경우 `ActiveRecord :: RecordInvalid` 예외를 발생시켜 더 엄격하게 검증을 한다. 아래에 예시를 위한 간단한 예문을 보여 준다.

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end

user = User.new
user.save  # => false
user.save! # => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

유효성 검사에 대한 자세한 내용은 [Active Record Validations](active_record_validations.html) 가이드에서 확인할 수 있다.

## 콜백 {#callbacks}

액티브 레코드 콜백을 사용하면 모델 수명주기의 특정 이벤트에 코드를 첨부 할 수 있다. 이를 통해 새 레코드 작성, 업데이트, 삭제 등의 이벤트가 발생할 때 코드를 투명하게 실행하여 모델에 동작을 추가 할 수 있다. 콜백에 대한 자세한 내용은 [Active Record Callbacks](active_record_callbacks.html) 가이드에서 확인할 수 있다.

## 마이그레이션 {#migrations}

레일스는 마이그레이션이라는 데이터베이스 스키마를 관리하기 위한 도메인 언어(DSL)를 제공한다. 마이그레이션은 파일로 저장되며 `rake` 명령을 사용하여 액티브 레코드가 지원하는 모든 데이터베이스에 대해 실행된다. 테이블을 생성하는 마이그레이션 코드는 아래와 같다.

```ruby
class CreatePublications < ActiveRecord::Migration[5.0]
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

레일스는 데이터베이스에 커밋된 파일을 추적하고 롤백 기능을 제공한다. 실제로 테이블을 생성하려면 `rails db:migrate`를 실행하고 `rails db:rollback` 명령을 실행하여 롤백한다.

위 코드는 데이터베이스에 구애받지 않으며 MySQL, PostgreSQL, Oracle 등에서 실행된다. [Active Record Migrations](active_record_migrations.html) 가이드에서 마이그레이션에 대해 자세히 알아볼 수 있다.
