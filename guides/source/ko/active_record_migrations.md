**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonrails.org.**

액티브 레코드 마이그레이션
========================

마이그레이션(데이터베이스 이관)이라는 기능은 데이터베이스 스키마(테이블 구성)을 조금씩 자주
바꾸거나 보태면서 개발할 수 있도록 해준다. SQL만으로 스키마 변경사항을 작성하지 않고,
간결한 루비 DSL(특정 분야 맞춤 언어)를 사용하여 테이블 변경사항을 작성하도록
해준다.

이 가이드의 내용:

* 마이그레이션을 처음 만들 때 사용하는 제너레이터.
* 데이터베이스를 변경하기 위한 액티브 레코드 메소드.
* 마이그레이션과 스키마를 변경하는 bin/rails 태스크.
* 마이그레이션을 `schema.rb` 파일에 어떻게 반영하는지.

--------------------------------------------------------------------------------

마이그레이션 개요
------------------

마이그레이션은
[테이터베이스 스키마를 자주 바꾸는](https://en.wikipedia.org/wiki/Schema_migration)
편리한 방법으로 바꾸는 중간에 꼬이지 않으며 쉽다. 마이그레이션은 루비 DSL로 작성하여,
SQL을 직접 작성하지 않고서, 스키마와 변경 사항을 데이터베이스와 분리하여 관리할 수 있도록 해준다.

마이그레이션마다 테이터베이스 '버전'이 새로 바뀐다고 볼 수 있다.
스키마는 데이터베이스가 비어있는 채로 시작한다. 마이그레이션을 하나씩 실행하면 테이블, 컬럼, 엔트리를
테이터베이스에 추가하거나 삭제한다. 액티브 레코드는 스키마를
시간 순서에 따라 어느 시점이든 최신 버전으로 마이그레이션할 과정을 안다.
액티브 레코드는 테이터베이스 최신 구조와 일치하기 위해
`db/schema.rb` 파일을 수정한다.

마이그레이션 파일의 예는 다음과 같다:

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

위 마이그레이션은 문자열 컬럼인 `name`과 텍스트 컬럼인 `description`으로
`products` 테이블을 만든다. 마이그레이션에 넣지 않아도
프라이머리 키 컬럼인 `id`를 만든다. 프라이머리 키를 따로 지정하지 않는 한 액티브
레코드 모델이 `id`를 프라이머리 키로 사용하기 때문이다. `timestamp` 매크로는 `created_at`과
`updated_at` 컬럼을 만든다. 테이블에 이 컬럼이 있으면 액티브 레코드가
관리한다.

다만, 여기서는 앞으로 실행할 변경 사항에 대해 메소드를 정의하였다.
마이그레이션을 실행하기 전까지 테이블은 없다. 실행을 하여야 테이블이
생긴다. 액티브 레코드는 마이그레이션을 어떻게 되돌릴지 안다: 위 마이그레이션을
롤백하면, 위에서 만든 테이블을 삭제한다.

테이블 스키마를 변경하는 SQL문의 트랜잭션을 지원하는 테이터베이스는,
여러 마이그레이션들을 트랜잭션 하나로 감싼다. 트랜잭션을 지원하지 않는 테이터베이스는
트랜잭션으로 감싼 마이그레이션 중 하나가 실패하면 그 전까지 실행한 마이그레이션을 롤백하지
못한다. 변경사항을 여러분이 직접 롤백하여야 한다.

NOTE: 트랜잭션으로 감쌀 수 없는 SQL문이 있다.
데이터베이스 어댑터가 DDL 트랜잭션을 지원하면 `disable_ddl_transaction!`을
실행하여 마이그레이션 하나만 실행하도록 기능을 끌 수 있다.

액티브 레코드가 아닌 여러분이 마이그레이션을
되돌리려면, `reversible`을 사용할 수 있다:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up   { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end
```

`change` 메소드를 `up`과 `down`으로 나누어 써도 된다:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

처음 만드는 마이그레이션
--------------------

### 마이그레이션 시작하기

마이그레이션은 `db/migrate` 디렉토리에 마이그레이션 클래스마다 하나씩
파일로 저장한다. 파일 이름 형식은
`YYYYMMDDHHMMSS_create_products.rb`이다. UTC 시각 뒤에
밑줄 글자로 마이그레이션 이름을 붙여써서
구분한다. 마이그레이션 클래스 이름(카멜케이스, 단어 첫글자만 대문자)은
마이그레이션 파일 뒷부분과 일치해야 한다. 파일 이름이
`20080906120000_create_products.rb`이라면 `CreateProducts` 클래스가 있어야 하고
`20080906120001_add_details_to_products.rb`이라면
`AddDetailsToProducts` 클래스가 있어야 한다. 레일스는 파일이름의
시각으로 마이그레이션 실행 순서를 정한다. 따라서 다른 곳에서
마이그레이션 파일을 복사하거나 새로 만들 때, 마이그레이션 순서가 매우 중요하다.

시각을 계산하기가 번거롭기 때문에 액티브 레코드
제너레이터는 다음과 같이 처리한다:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

제너레이터는 적절한 이름으로 마이그레이션 클래스를 만들지만 변경사항에 대한 코드를 만들지 않는다:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
  end
end
```

"AddXXXToYYY", "RemoveXXXFromYYY"과 같은 마이그레이션 이름
뒤에 컬럼 이름과 타입을 쓰면
`add_column`과 `remove_column`를 만든다.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

실행 결과

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

새로 추가할 컬럼의 인덱스도 만들려면, 다음과 같다:

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

실행 결과

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```


컬럼을 추가하듯이, 컬럼을 삭제하는 마이그레이션은 다음과 같이 실행한다:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

실행 결과

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

마이그레이션은 컬럼을 하나 더 써도 된다:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

실행 결과

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

마이그레이션 이름이 "CreateXXX"이고
마이그레이션 이름 뒤에 컬럼 이름과 타입을 나열하면
XXX 테이블과 컬럼을 만든다.

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

실행 결과

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number
    end
  end
end
```

이처럼 마이그레이션 만든 다음 시작한다. 이 마이그레이션에
추가하거나 삭제하려면
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` 파일을 편집할 수 있다.

제너레이터는 컬럼 타입으로 `references`
(`belongs_to`)를 사용할 수 있다.

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

실행 결과

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

이 마이그레이션으로 `user_id` 컬럼과 관련 인덱스를 만든다.
`add_reference` 옵셥은 [API 문서](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)를 참조한다.

테이블 두개 이상을 조인할 때 사용하는 테이블을 만들려면 마이그레이션 이름에 `JoinTable`를 쓴다.

```bash
$ bin/rails g migration CreateJoinTableCustomerProduct customer product
```

실행 결과 다음과 같은 마이그레이션을 만든다:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[5.0]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```

### 모델 제너레이터

모델과 스캐폴드 제너레이터는 모델을 새로 추가하기 위한
마이그레이션을 만든다. 마이그레이션 안에 해당 테이블을 만드는 코드가
있다. 컬럼을 더 추가하고 싶다면,
다음과 같이 할 수 있다:

```bash
$ bin/rails generate model Product name:string description:text
```

실행 결과 다음과 같은 마이그레이션을 만든다.

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

컬럼 이름/타입을 쌍으로 더 많이 붙여 넣을 수 있다.

### 모디파이어 전달

자주 사용하는 [타입 모디파이어](#컬럼-모디파이어)를 명령어에
직접 사용할 수 있다. 모디파이어는 타입 뒤에 중괄호로 감싸서 사용한다.

다음과 같이 실행한다:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

실행결과 마이그레이션은 다음과 같다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: 모디파이어는 제너레이터 도움말을 참조한다. (`rails generate model --help`)

마이그레이션 고쳐 쓰기
-------------------

제너레이터로 새로 만든 마이그레이션을
고쳐 쓸 차례다!

### 테이블 새로 만들기

`create_table` 메소드는 매우 중요하다.
모델과 스캐폴드 제너레이터를 실행하면 이 메소드를 만들어 준다. 그 예는
다음과 같다.

```ruby
create_table :products do |t|
  t.string :name
end
```

`name` 컬럼(그리고 `id` 컬럼, 아래에서 설명)을 가진 `products`
테이블을 만든다.

`create_table`은 프라이머리 키로 `id` 컬럼을 만든다.  프라이머리 키를 바꾸려면
`:primary_key` 옵션을 쓴다.(마이그레이션에 해당하는 모델도 바꾸어야 한다)
프라이머리 키를 사용하지 않으려면,
`id: false` 옵션을 쓴다. SQL문으로 테이터베이스 옵션을 따로 설정하려면
`:option` 옵션을 쓴다. 그 예는 다음과 같다:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

실행 결과 테이블을 생성하는 SQL문에 `ENGINE=BLACKHOLE` 옵션을 붙여준다.

`:comment` 옵션으로 테이블과 컬럼 설명을 전달하면
데이터베이스에 설명을 저장하고
MySQL Workbench, PgAdmin III와 같은 테이터베이스 관리 툴로 설명을 볼 수 있다. 대형 데이터베이스를 사용하는
애플리케이션의 마이그레이션에 대해 코멘트를 달면 공동 작업하는 사람들이
데이터 모델을 이해하고 문서를 작성하는데 도움이 된다.
현재 MySQL과 PostgreSQL 데이터베이스 어댑터만 코멘트를 지원한다.

### 조인 테이블 만들기

마이그레이션 메소드 `create_join_table`은 HABTM(
has and belongs to many, 다대다 관계) 조인 테이블을 만든다. 예는 다음과 같다:

```ruby
create_join_table :products, :categories
```

`category_id`와 `product_id` 컬럼이 있는 `categories_products` 테이블을 만든다.
이 컬럼은 별다른 옵션이 없으면 `:null` 옵션이 `false`이다.
옵션을 다르게 설정하려면 `:column_options` 옵션을 다음과 같이
설정한다:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

조인 테이블 이름은 create_join_table에 전달하는 아규먼트 2개를
알파벳 순서로 합친다.
조인 테이블 이름 바꾸려면, `:table_name` 옵션을 사용한다:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

`categorization` 테이블을 만든다.

`create_join_table`에 블록을 전달할 수 있다. 블록에는 인덱스를
추가하거나(그냥 인덱스를 걸어주지 않음) 다른 컬럼을 추가할 수 있다:

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### 테이블 변경하기

`create_table`과 닮은 `change_table`은 기존 테이블을 변경할 때 사용한다.
`create_table`과 비슷한 방식이지만 전달하는 블록에
다음과 같이 자세히 설정한다.

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

`description`과 `name` 컬럼을 삭제하고 `part_number` 문자열 컬럼을 새로 만들어
인덱스도 만든다. `upccode` 컬럼 이름을 변경한다.

### 컬럼을 변경하기

`remove_column`과 `add_column`처럼 레일스는 `chage_column`이라는
마이그레이션 메소드를 사용한다.

```ruby
change_column :products, :part_number, :text
```

여기서는 products 테이블의 `part_number` 컬럼 타입을 `:text`로 변경한다.
다만, `change_column`은 한번 실행하면 되돌릴 수 없다.

`change_column` 메소드 말고도 `change_column_null`과 `change_column_default`
메소드는 not null 제한을 설정하고 컬럼의
디폴트값을 변경한다.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

여기서 products 테이블의 `:name` 컬럼을 `NOT NULL`로 설정하고
`:approved` 컬럼의 디폴트값을 true에서 false로 변경한다.

NOTE: 위에서 처럼 `change_column_default` 마이그레이션을
`change_column_default :products, :approved, false`처럼 사용할 수도 있겠으나,
from, to 없이 사용하는 마이그레이션은 되돌릴 수 없다.

### 컬럼 모디파이어

컬럼을 새로 만들거나 변경할 떄 컬럼 모디파이어를 사용할 수 있다:

* `limit`는 `string/text/binary/integer` 컬럼의 최대 길이/크기를 제한한다.
* `precision`는 `decimal` 컬럼의
자리수를 정한다.
* `scale`은 `decimal` 컬럼의 소수점이하
자리수를 정한다.
* `polymorphic`은 `belongs_to` 관계의 `type` 컬럼을 추가한다.
* `null`은 컬럼의 `NULL` 값을 허용하거나 제한한다.
* `default`는 컬럼의 디폴트값을 설정한다. 단, 날짜와 같이
계속 바뀌는 값으로 디포틀값을 설정하더라도 마이그레이션을
실행하는 시점의 날짜로만 고정한다.
* `index`는 컬럼의 인덱스를 추가한다.
* `comment`는 컬럼의 코멘트를 추가한다.

데이터베이스 어댑터에 따라 다른 옵션도 쓸 수 있어서
해당 어댑터의 API 문서를 참조한다.

NOTE: `null`과 `default`는 쉘 명령어로 실행할 수 없다.

### 외래 키

외래 키가 꼭 필요하지는 않지만 외래 키를 추가하여
[참조 무결성을 깨지 않고 싶다면](#액티브-레코드와-참조-무결성) 다음과 같다.

```ruby
add_foreign_key :articles, :authors
```

여기서 `articles` 테이블의 외래 키로 `author_id` 컬럼을 추가한다.
이 외래 키는 `authors` 테이블의 `id` 컬럼을 참조한다.
컬럼 이름을 테이블 이름에서 따오지 못하면,
`:column`과 `:primary_key` 옵션을 사용할 수 있다.

레일스에서 모든 외래 키 이름은 `fk_rails_`로 시작하고
뒤에 오는 이름은 `from_table`과 `column`으로
문자 10개를 조합한다.
`:name` 옵션으로 외래 키의 이름을 다르게 설정할 수 있다.

NOTE: 액티브 레코드는 컬럼 한개만 사용하는 외래 키를 지원한다. 컬럼 두개 이상으로 조합하는 외래 키는 `execute`와
`structure.sql`을 써야 한다.
[스키마 덤프의 의미](#스키마-덤프의-의미) 참조

외래 키를 삭제하는 방법은 다음과 같다:

```ruby
# 액티브 레코드가 컬럼 이름을 유추한다.
remove_foreign_key :accounts, :branches

# 외래 키로 사용하는 컬럼 이름을 쓴다.
remove_foreign_key :accounts, column: :owner_id

# 테이터베이스 외래 키 제약조의 이름으로 외래 키를 삭제한다.
remove_foreign_key :accounts, name: :special_fk_name
```

### 헬퍼만으로 부족할 때

액티브 레코드의 헬퍼만으로 부족할 때
SQL문을 실행하는 `execute`를 사용할 수 있다:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

메소드에 대한 더 자세한 내용은
API 문서를 보라.
[`ActiveRecord::ConnectionAdapters::SchemaStatements`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html)
(`change`, `up`, `down` 메소드에 관한 내용),
[`ActiveRecord::ConnectionAdapters::TableDefinition`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html)
(`create_table` 메소드에 전달하는 블록 객체에 관한 내용)
그리고
[`ActiveRecord::ConnectionAdapters::Table`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html)
(`change_table` 메소드에 전달하는 블록 객체에 관한 내용).

### `change` 메소드 사용하기

`change` 메소드는 마이그레이션을 작성하는 첫번째 방법이다.
대부분의 경우 액티브 레코드는 마이그레이션을 되돌릴 수 있는
방법을 안다. 현재, `change` 메소드는 다음과 같은 마이그레이션만
지원한다:

* add_column
* add_foreign_key
* add_index
* add_reference
* add_timestamps
* change_column_default (:from과 :to 옵션을 써야 한다)
* change_column_null
* create_join_table
* create_table
* disable_extension
* drop_join_table
* drop_table (블록을 아규먼트로 전달해야 한다)
* enable_extension
* remove_column (타입을 써야 한다)
* remove_foreign_key (참조할 테이블 이름을 써야 한다)
* remove_index
* remove_reference
* remove_timestamps
* rename_column
* rename_index
* rename_table

`change_table` 마이그레이션은 되돌릴 수 있으나, 블록 안에서 `change`,
`change_default`, `remove`를 호출하면 되돌릴 수 없다.

`reomve_column` 마이그레이션을 되돌리려면 컬럼 타입이 필요하다.
본래 컬럼 타입을 옵션으로 주지 않으면
레일스는 롤백할 때 컬럼을 재구성하지 못한다:

```ruby
remove_column :posts, :slug, :string, null: false, default: '', index: true
```

다른 메소드를 써야 할 때,
`change` 메소드 대신 `up`과 `down` 메소드를 사용하거나 `reversible` 메소드를 사용해야 한다.

### `reversible` 사용하기

마이그레이션은 액티브 레코드가 되돌릴 방법을 알지 못할 정도로
복잡할 수 있다. `reversible`을 사용하여 스키마를 되돌려야 할 때
무엇을 해야 하는지 정할 수 있다.

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE distributors
            ADD CONSTRAINT zipchk
              CHECK (char_length(zipcode) = 5) NO INHERIT;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE distributors
            DROP CONSTRAINT zipchk
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

`reversible`을 사용할 때 실행 순서가 매우 중요하다.
위 마이그레이션을 되돌리려고 할 때,
`down` 블록을 실행하는 순서는 `home_page_url` 컬럼을 삭제한 다음과
`distributors` 테이블을 지우기 직전이다.

확실히 되돌릴 수 없는 마이그레이션을 실행할 때도 있다. 마이그레이션을 되돌리면 데이터가 지워지는 경우다. 그럴 때는 `down` 블록에서
`ActiveRecord::IrreversibleMigration` 예외를 발생시킬 수 있다.
누군가 마이그레이션을
되돌리려고 할 때, 마이그레이션을 되돌리지 못한다고
에러메시지가 뜰 것이다.

### `up`/`down` 메소드 사용하기

`change` 메소드 보다 예전 방식인 `up`과 `down` 메소드를
사용할 수 있다.
`up` 메소드는 스키마를 만들고,
`down` 메소드는 `up` 메소드로 만든 스키마를 되돌린다.
곧, `up` 다음에 `down`을 실행하면 데이터베이스 스키마는 변하지 않는다.
만약 `up` 메소드로 테이블을 만들면,
`down` 메소드로 테이블 삭제해야 한다.
`up` 메소드에서 작성한 순서와 반대로 `down` 메소드에서 작성하는 것이 좋다.
`reversible` 섹션을 `up`과 `down`으로 풀어쓰면 다음과 같다:

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # add a CHECK constraint
    execute <<-SQL
      ALTER TABLE distributors
        ADD CONSTRAINT zipchk
        CHECK (char_length(zipcode) = 5);
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      ALTER TABLE distributors
        DROP CONSTRAINT zipchk
    SQL

    drop_table :distributors
  end
end
```

마이그레이션을 되돌리지 말아야 할 때, `down` 메소드에서
`ActiveRecord::IrreversibleMigration` 예외를 발생시키야 한다. 누군가 마이그레이션을
되돌리려고 할 때, 마이그레이션을 되돌리지 못한다고
에러메시지가 뜰 것이다.

### 마이그레이션을 이전 상태로 되돌리기

마이그레이션을 롤백하려면 `revert` 메소드를 사용할 수 있다:

```ruby
require_relative '20121212123456_example_migration'

class FixupExampleMigration < ActiveRecord::Migration[5.0]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

`revert` 메소드에 되돌릴 순서를 블록으로 전달할 수 있다.
이전 마이그레이션 중 일부분만 되돌릴 때 유용하다.
`ExampleMigration`을 커밋하였다고 가정한다. 우편번호를 검증하는 `CHECK` 제약조건 대신
액티브 레코드 밸리데이션이 더 좋다고
판단하는 경우는 다음과 같다.

```ruby
class DontUseConstraintForZipcodeValidationMigration < ActiveRecord::Migration[5.0]
  def change
    revert do
      # copy-pasted code from ExampleMigration
      reversible do |dir|
        dir.up do
          # add a CHECK constraint
          execute <<-SQL
            ALTER TABLE distributors
              ADD CONSTRAINT zipchk
                CHECK (char_length(zipcode) = 5);
          SQL
        end
        dir.down do
          execute <<-SQL
            ALTER TABLE distributors
              DROP CONSTRAINT zipchk
          SQL
        end
      end

      # The rest of the migration was ok
    end
  end
end
```

`revert`를 사용하지 않은 마이그레이션을 똑같이 작성할 수도 있지만
`create_table`, `reversible`을 되돌리는 단계를 더 넣어야 한다.
`create_table`을 `drop_table`로 바꾸고 `up`을 `down`으로 바꾼다.
되돌리는 모든 단계를
`revert`로 처리한다.

NOTE: 위와 같은 CHECK 제약 조건을 추가하려면
`structure.sql`로 덤프 해야 한다.
[스키마 덤프의 의미](#스키마-덤프의-의미) 참조.

마이그레이션 실행하기
------------------

레일스 bin/rails 태스크로 마이그레이션을 실행한다.

제일 처음 실행하는 bin/rails 태스크는
`rails db:migrate`이다. 스키마를 처음 구성하기 위해 아직 실행하지 않은 마이그레이션의 `change`, `up` 메소드를 실행한다.
이미 실행했다면,
태스크를 마친다. 마이그레이션은 마이그레이션 파일 이름에 있는
날짜 순서대로 실행한다.

다만, `db:migrate` 태스크는 `db:schema:dump` 태스크도 실행하여,
`db/schema.rb` 파일을 데이터베이스 구성과 일치하도록 변경한다.

버전을 사용하면 액티브 레코드는 해당 버전까지 마이그레이션
(change, up, down)을 실행한다.
버전은 마이그레이션 파일 이름에서 숫자로 시작하는 부문이다.
200080906120000 버전으로 마이그레이션 실행하려면 다음과 같다:

```bash
$ bin/rails db:migrate VERSION=20080906120000
```

20080906120000 버전이 현재 버전보다 크면
(상위 버전으로 마이그레이션), 20080906120000을 포함한 모든 마이그레이션의 `change`(또는 `up`)
메소드를 실행하고,
20080906120000 보다 최신 버전 마이그레이션은 실행하지 않는다.
하위 버전으로 마이그레이션하면, 20080906120000 버전까지
마이그레이션의 `down` 메소드를 실행한다.

### 롤백하기

현재 마그레이션에서 한단계 뒤로 롤백하는데 자주 사용하는 태스크이다.
실수한 것을 고치고 싶을 때. 이전 마이그레이션의 버전 번호를
사용하지 않고 다음과 같이 실행한다:

```bash
$ bin/rails db:rollback
```

`change` 메소드를 되돌리거나 `down` 메소드를 실행하여 한단계 뒤로 롤백한다.
몇단계 더 뒤로 마이그레이션을 되돌아 가려면,
`STEP` 파라미터를 사용할 수 있다:

```bash
$ bin/rails db:rollback STEP=3
```

마이그레이션을 3단계 뒤로 되돌린다.

`db:migrate:redo` 태스크는 롤백하여 마이그레이션을 다시 실행한다.
`db:rollback` 태스크와 같이 `SETP` 파라미터를 사용하여 한단계 이상 뒤로 되돌아갔다가
마이그레이션을 다시 실행하려면 다음과 같다:

```bash
$ bin/rails db:migrate:redo STEP=3
```

`db:rollback`과 `db:migrate:redo` 태스크는 `db:migrate`으로도 할 수 있다.
단지 마이그레이션 버전을 사용하지 않고
간단히 실행할 수 있게 해준다.

### 데이터베이스 셋업하기

`rails db:setup` 태스크는 테이베이스를 만들고 스키마를 불러온 다음
시드 데이터로 초기화한다.

### 테이터베이스 리셋하기

`rails db:reset` 태스크는 테이터베이스를 삭제하고 다시 셋업한다.
`rails db:drop db:setup`를 실행하는 것과 같다.

NOTE: 모든 마이그레이션을 실행하지 않는다.
현재 버전의 `db/schema.rb` 또는 `db/structure.sql` 파일을 사용한다. 마이그레이션을 롤백할 수 없으면
`rails db:reset`은 도움이 안된다. 스키마를 덤프하는 내용은
[스키마 덤프의 의미](#스키마-덤프의-의미) 섹션을 참조한다.

### 마이그레이션 버전을 찍어서 실행하기

마이그레이션 버전을 찍어서 up 또는 down 메소드를 실행하려고 할 때, `db:migrate:up`과
`db:migrate:down` 태스크를 실행한다.
해당 버전과 마이그레이션의 `change`, `up`, `down` 메소드 중 하나를 선택하여
실행하려면 다음과 같다:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

20080906120000 버전 마이그레이션의 `change`
(또는 `up`) 메소드를 실행한다. 태스크는
마이그레이션을 이미 실행하였는지 확인한 다음
액티브 레코드가 이미 실행하였다고 판단하면 마이그레이션 작업을 하지 않는다.

### 다른 환경에서 마이그레이션 실행하기

환경변수를 설정하지 않고 `bin/rails db:migrate`를 실행하면 `development` 환경에서 실행한다.
다른 환경에서 마이그레이션을 실행하려면
`RAILS_ENV` 환경변수를 사용한다.
`test` 환경에서 마이그레이션 실행하려면 다음과 같다:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### 마이그레이션 실행 결과 출력 메시지를 수정하기

마이그레이션은 실행 내용과 실행 시간을 출력한다.
테이블을 만들고 인덱스를 추가하는 마이그레이션 결과는 다음과 같다.

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

마이그레이션 실행 결과 출력 메시지를 수정하는데 사용할 수 있는 메소드는 다음과 같다:

| 메소드               | 목적
| -------------------- | -------
| suppress_messages    | 출력하지 않을 내용을 블록으로 아규먼트 전달한다.
| say                  | 출력할 내용을 아규먼트로 전달한다. 두번째 아규먼트(true/false)는 들여쓰기 사용 여부이다.
| say_with_time        | 아규먼트로 전달하는 블록을 실행하는데 걸린 시간을 출력한다. 블록의 리턴 값은 블록이 처리한 열(row) 개수라고 본다.

메소드는 다음과 같이 사용한다:

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages {add_index :products, :name}
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

실행하면 다음과 같이 출력한다.

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

액티브 레코드 마이그레이션 결과 메시지를 출력하지 않으려면, `rails db:migrate
VERBOSE=false`를 실행한다.

기존 마이그레이션 변경하기
----------------------------

마이그레이션을 작성하며 때때로 실수할 수 있다.
마이그레이션을 이미 실행하였다면, 마이그레이션 파일을 편집하여 재실행할 수 없다.
레일스가 이미 마이그레이션을 실행했다고 판단하면
`rails db:migrate` 실행하여도 마이그레이션을 실행하지 않는다.
반드시 마이그레이션을 롤백(`bin/rails db:rollback`)한 다음
마이그레이션 파일을 편집하고 `rails db:migrate`를 실행하여야 한다.

기존 마이그레이션 파일을 편집하지 않는 편이 좋다.
실 서버에서 기존 마이그레이션을 실행한 경우,
기존 마이그레이션 파일을 추가로 작업한 결과는 문제를 일으킬 수 있다.
기존 파일을 편집하지 말고, 작업할 내용을 새 마이그레이션 파일로 작성해야 한다.
마이그레이션 파일을 새로 만들면 소스 저장소와
개발용 컴퓨터에도 영향을 주지 않아서 새로 만들어 편집하는 것이
상대적으로 덜 위험하다.

`revert` 메소드는 이전 마이그레이션을 전체 또는 일부분을 되돌리는
마이그레이션을 새로 작성하는데 유용하다.
[마이그레이션을 이전 상태로 되돌리기](#마이그레이션을-이전-상태로-되돌리기) 참조

스키마 덤프의 의미
----------------------

### 스키마 파일의 목적은?

마이그레이션은 강력하지만, 데이터베이스 스키마를 결정하지 않는다.
스키마를 결정하는 역할은 `db/schema.rb`와 액티브 레코드가 만든 SQL 파일로 나누어져 있다.
두 파일은 편집하여 사용할 목적이 아니라,
테이터베이스의 현재 상태를 나타나는데 있다.

앱을 새로 배포할 때 마이그레이션 전체를 실행할 필요는 없다.
현재 스키마를 데이터베이스로 불러오는 편이
훨씬 쉽고 빠르다.

테스트 데이터베이스를 만들 때, 현재 개발하는 데이터베이스를
덤프(`db/schema.rb` 또는 `db/structure.sql`)하여
테스트 데이터베이스로 불러온다.

스키마 파일은 액티브 레코드 객체가 어떤 속성을 가지고 있는지 훑어볼 때 편하다.
속성에 관한 정보는 모델 코드에는 없고,
마이그레이션 파일 여러개에 걸쳐 있지만,
스키마 파일에 모두 정리되어 있다.
[annotate_models](https://github.com/ctran/annotate_models)  젬은 모델 파일 맨 윗부분에
모델 속성 정보를 요약하여
코멘트로 달아준다.

### 스키마 덤프 유형

스키마를 덤프하는 방법은 두가지다. `config/application.rb` 파일에서
`config.active_record.schema_format`을 `:sql`
또는 `:ruby`로 설정한다.

`:ruby`로 설정하면, 스키마를 `db/schema.rb` 파일에 저장한다.
이 파일을 열면, 마이그레이션 파일 길이가
매우 길어서 놀랄 것이다.

```ruby
ActiveRecord::Schema.define(version: 20080906171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

여러가지 면에서 `db/schema.rb` 파일을 만든 것이 적절하다.
테이터베이스를 분석하고 `create_table`과 `add_index` 등으로 데이터베이스 구조를 나타내는 `db/schema.rb`를 만들었다.
이 파일은 데이터베이스와 분리하였기 때문에,
액티브 레코드를 지원하는 다른 데이터베이스에서도 이 파일을 불러올 수 있다.
테이터베이스를 여러 개 사용하는 애플리케이션을 배포할 때 유용하다.

NOTE: `db/schema.rb` 파일은 트리거,
시퀀스, 저장 프로시저, 제약조건과 같은 데이터베이스 고유 기능을 나타내지 못한다.
마이그레이션 파일에서는 이와 같은 고유 기능을 SQL문으로 실행할 수 있지만,
스키마를 덤프할 때는 고유 기능을 SQL문으로 재현하지 못한다.
고유 기능을 사용하려면, 스키마 포맷을 `:sql`로 설정하라.

액티브 레코드의 스키마 덤퍼(`db:structure:dump`)를 쓰지 않고,
데이터베이스 관리 툴로 데이터베이스 구조를 `db/structure.sql` 파일로 덤프할 수 있다.
PostgreSQL을 사용하면 `pg_dump`
유틸리티를 사용한다. MySQL과 MariaDB를 사용하면, 여러 테이블에 대한
`SHOW CREATE TABLE` 실행 결과를 `db/structure.sql` 파일에 넣는다.

스키마를 불러오는 것은 단지 SQL문을 실행하는 문제이다.
스키마에서 정의한대로, 테이터베이스의 구조를 똑같이 복제하여 만든다.
그러나 `:sql` 스키마 포맷을 사용하면
다른 RDBMS로 스키마를 불러오지 못한다.

### 스키마 덤프와 소스 버전 관리

스키마 덤프는 데이터베이스 스키마를 결정하는 근거이기 때문에,
소스 버전 관리툴로 스키마 파일을 관리하기를 강력히 추천한다.

`db/schema.rb`는 테이터베이스의 현재 버전 번호를 가지고 있다.
버전 번호는 스키마를 수정한 브랜치들을 머지할 때 충돌이 발생하도록 한다.
충돌이 발생하면, 두 버전 중에 높은 버전에 맞추어
충돌을 해결한다.

액티브 레코드와 참조 무결성
---------------------------------------

액티브 레코드 방식은 테이터베이스보다 모델이 판단하고 처리해야 한다고 주장한다.
데이터베이스가 판다하여 처리하는
트리거와 제약조건과 같이 기능은
거의 사용하지 않는다.

`validates :foreign_key, uniqueness: true`과 같은 밸리데이션을
사용하면 데이터 무결성을 지킬 수 있다. 관계 설정시 `:dependent` 옵션을
사용하면 부모 객체를 삭제할 때
자녀 객체도 삭제할 수 있다. 애플리케이션이 처리할 일들은
참조 무결성이 깨질 수 있어서 누군가는 참조 무결성이 깨지지 않도록
데이터베이스의 [외래 키 제약조건](#외래-키)을 사용한다.

액티브 레코드는 참조 무결성을 지키기 위한 툴을 모두 제공하지 않지만,
SQL문을 실행하는 `execute` 메소드를 사용할 수 있다.

마이그레이션과 시드 데이터
------------------------

레일스 마이그레이션 기능의 중요한 목적은 스키마를
수정하는 명령어를 실행하여 마이그레이션 과정을 일관되지 유지하는 것이다.
마이그레이션은 데이터를 추가하거나 수정하는데 사용할 수 있다.
기존 데이터베이스를 갈아 엎어버리거나 처음부터 다시 만들 수 없는 실서버 데이터베이스에서 마이그레이션할 때 유용하다.

```ruby
class AddInitialProducts < ActiveRecord::Migration[5.0]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

데이터베이스를 처음 만든 직후 초기 데이터를 추가할 때,
레일스는 '시드' 기능을 가지고 있어서 초기화하는데 빠르고 쉽다.
개발 및 테스트 환경처럼 테이터베이스를 자주 다시 불러올 때 유용하다.
초기 데이터를 불어오는 쉬운 방법으로 `db/seeds.rb` 파일 내용을
루비 코드로 작성하고 `rails db:seed`를 실행한다.

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

애플리케이션 테이터베이스가 비어있어서 초기화할 때 마이그레이션보다
깔끔한 방법이다.
