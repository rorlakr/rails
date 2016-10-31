
Active Record Migrations
========================

마이그레이션(migration)은 Active Record의 기능 중 하나로, 데이터베이스 스키마를 장기간에 걸쳐서 안정적으로 발전, 구축하기 위한 장치입니다. 마이그레이션 기능 덕분에 Ruby로 작성된 마이그레이션용 DSL(도메인 특화 언어)를 사용해서 테이블의 변경을 간단하게 기술할 수 있습니다. 스키마를 변경하기 위해서 SQL을 직접 작성하고 실행할 필요가 없습니다.

이 가이드의 내용:

* 마이그레이션 작성에 사용하는 제너레이터
* Active Record가 제공하는 데이터베이스 조작용 메소드 설명
* 마이그레이션의 실행과 스키마 갱신용 bin/rails task 설명
* 마이그레이션과 스키마 파일(`schema.rb`)의 관계

--------------------------------------------------------------------------------

마이그레이션의 개요
------------------

마이그레이션은 [데이터베이스 스키마의 계속적인 변경](http://en.wikipedia.org/wiki/Schema_migration)(영어)을
통합적이고 간단하게 수행하기 위한 방법입니다. 마이그레이션에서 Ruby의 DSL을
사용하고 있으므로 SQL문을 직접 작성할 필요가 없으며, 스키마와 스키마의 변경을
데이터베이스의 종류에 의존하지 않을 수 있습니다.

하나 하나의 마이그레이션은 데이터베이스의 새로운 'version'이라고 볼 수
있습니다. 스키마는 처음 아무것도 없는 상태에서 시작해서, 마이그레이션에 의한
변경이 이루어질때마다 테이블, 컬럼, 엔트리가 추가 또는 삭제됩니다.
Active Record는 시간순에 따라서 스키마를 변경하는 방법을 알고 있으므로,
어느 시점으로부터든 최신 버전의 스키마로 갱신할 수 있습니다. Active Record는
`db/schema.rb` 파일을 갱신하고, 데이터베이스의 최신 구조와 일치하도록 만듭니다.

마이그레이션의 예를 하나 들어보겠습니다.

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

위의 마이그레이션을 실행하면 `products`라는 이름의 테이블이 추가됩니다.
이 안에는 `name`이라는 string 타입의 컬럼과 `description`이라는 text 타입의
컬럼이 포함되어 있습니다. 기본키는 `id`라는 이름으로 암묵적으로 추가됩니다.
`id`는 Active Record 모델에서의 기본으로 설정된 기본키 이름입니다.
`timestamps` 매크로는 `created_at`와 `updated_at`이라는 컬럼을 추가합니다.
이런 특수한 컬럼이 존재하는 경우, Active Record에 의해서 자동적으로 관리됩니다.

마이그레이션이 새 버전에서 어떻게 변할지에 대한 동작을 정의하고 있다는 점에
주목해주세요. 마이그레이션을 실행하기 전에는 테이블이 존재하지 않습니다.
마이그레이션을 실행하면 테이블이 생성됩니다. Active Record는 이 마이그레이션의
진행을 역전시킬 방법을 알고 있습니다. 그래서 마이그레이션을 롤백하면 테이블이
삭제됩니다.

스키마 변경에 대한 명령에 대해서 데이터베이스 레벨에서 트랜잭션을 지원하는
경우, 마이그레이션은 트랜잭션의 내부에서 실행됩니다. 만약 지원되지 않는 경우,
마이그레이션 중에 일부가 실패한 경우 롤백할 수 없습니다. 그 경우에는 변경사항을
수동으로 롤백해야할 필요가 있습니다.

NOTE: 몇몇 쿼리는 트랜잭션 하에서 실행할 수 없는 경우가 있습니다. 어댑터가 DDL 트랜잭션을 지원하고 있는 경우에는 `disable_ddl_transaction!`을 사용해서 단일 마이그레이션에서 트랜잭션을 무효화할 수 있습니다.

Active Record가 되돌리는 방법을 알 수 없는 마이그레이션을 실행하고 싶은 경우에는 `reversible`을 사용할 수 있습니다.

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

`change` 대신에 `up`과 `down`을 사용할 수도 있습니다.

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

마이그레이션 작성하기
--------------------

### 마이그레이션을 직접 작성하기

마이그레이션은 `db/migrate` 폴더에 저장됩니다. 1개의 파일이 1개의 마이그레이션 클래스에 대응합니다. 마이그레이션 파일명은 `YYYYMMDDHHMMSS_create_products.rb`와 같은 형태가 됩니다. 파일명의 일시는 마이그레이션을 식별하기 위한 UTC 타임스탬프로, 밑줄을 이용해 마이그레이션명을 구분합니다. 마이그레이션 클래스명(CamelCase로 표시되는 버전)은 파일명의 둣부분과 일치시킬 필요가 있습니다. 예를 들자면 `20080906120000_create_products.rb`에는 `CreateProducts`라는 클래스가 정의되어야 하며, `20080906120001_add_details_to_products.rb`에서는 `AddDetailsToProducts`라는 클래스가 정의되어야 합니다. 그리고 Rails에서는 마이그레이션의 실행순서를 파일명의 타임스탬프로 결정합니다. 따라서 마이그레이션을 다른 애플리케이션에서 복사해오거나, 직접 마이그레이션을 생성하는 경우에는 실행순서에 주의해야할 필요가 있습니다.

타임스탬프를 계산하는 작업은 쉽지 않으므로, Active Record에는 이것을 처리하기위한 제너레이터가 준비되어 있습니다.

```bash
$ bin/rails generate migration AddPartNumberToProducts
```

이 명령으로 생성되는 마이그레이션에는 실제 코드는 존재하지 않지만 적당한 이름은 붙여져 있습니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
  end
end
```

마이그레이션의 이름이 "AddXXXToYYY"나 "RemoveXXXFromYYY"의 형식이고, 그 후에 이름이 컬럼명과 종류가 기술되어있다면 마이그레이션 내에 적절한 `add_column`와 `remove_column`이 작성됩니다.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

위를 실행하면 다음과 같이 생성됩니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

새로운 컬럼을 인덱스에 추가하고 싶은경우에는 다음처럼 쓰면 됩니다.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

실행하면 아래의 마이그레이션이 생성됩니다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

마찬가지로 컬럼을 삭제하는 마이그레이션을 터미널에서 생성하려면 다음과 같이 작성합니다.

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

실행하면 다음처럼 생성됩니다.

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

자동으로 생성되는 컬럼은 하나만이 아닙니다. 예를 들자면 아래처럼 할 수도 있습니다.

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

생성된 마이그레이션은 다음과 같습니다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

마이그레이션의 이름이 "CreateXXX"와 같은 형식이고, 그 뒤에 컬럼명과 형식이 인자로 넘어올 경우, XXX라는 이름의 테이블을 생성하고, 지정된 형식의 컬럼이 생성되게 됩니다. 예를 들자면 다음처럼 됩니다.

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

이를 실행하면 아래와 같은 마이그레이션이 생성됩니다.

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

여기까지 생성한 내용들은 출발점에 지나지 않습니다. `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` 파일을 수정하여 각 항목들을 추가, 또는 삭제할 수도 있습니다.

마찬가지로 컬럼의 형식으로 `references`(`belongs_to`도 가능)를 지정할 수도 있습니다. 예를 들면 다음처럼 쓸 수 있습니다.

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

이를 실행하면 다음과 같은 마이그레이션이 생성됩니다.

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

이 마이그레이션을 실행하면 `user_id` 컬럼이 추가되고, 적절한 인덱스가
추가됩니다.
`add_reference`의 다른 옵션에 대해서는 [API 문서](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)를 참조해주세요.

이름의 일부에 `JoinTable`이 포함되어 있으면 테이블 조인을 생성할 수도 있습니다.

```bash
$ bin/rails g migration CreateJoinTableCustomerProduct customer product
```

이를 실행하면 다음과 같은 마이그레이션을 생성합니다.

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

### 모델을 생성하기

모델의 제너레이터와 scaffold 제너레이터는 새로운 모델을 추가하는 마이그레이션을 생성합니다. 이 마이그레이션에는 매핑되는 테이블을 생성하기 위한 명령이 포함되어있습니다. 필요한 컬럼을 지정하면, 그 컬럼들을 추가하는 명령도 동시에 생성할 수 있습니다. 예를 들면 다음처럼 실행할 수 있습니다.

```bash
$ bin/rails generate model Product name:string description:text
```

다음과 같은 마이그레이션이 생성됩니다.

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

컬럼명과 형식의 쌍은 얼마든지 더 추가할 수 있습니다.

### 장식자를 넘기기

터미널에 [형장식자](#컬럼_장식자)라는 것을 직접 넘길 수도 있습니다. 이것들은 필드의 타입의 뒤에서 중괄호로 감싸 사용합니다.

예를 들자면 아래처럼 실행할 수 있습니다.

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

실행하면 아래와 같은 마이그레이션이 생성됩니다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: 자세한 내용에 대해서는 제너레이터 가이드를 참조해주세요.

마이그레이션을 작성하기
-------------------

제너레이터로 마이그레이션을 생성할 수 있게 되었다면, 이번에는 직접 작성해봅시다.

### 테이블을 생성하기

`create_table` 메소드는 가장 기본적인 메소드로서, 대부분의 경우 모델이나 scaffold로 생성할 때에 사용됩니다. 일반적인 사용법은 다음과 같습니다.

```ruby
create_table :products do |t|
  t.string :name
end
```

이에 의해서 `products`라는 테이블이 생성되고, `name`이라는 컬럼이 추가됩니다. (`id`라는 컬럼도 암묵적으로 생성됩니다만 여기에 대해서는 나중에 설명합니다).

기본적으로는 `create_table`에 의해서 `id`라는 이름의 기본키가 생성됩니다. `:primary_key` 옵션을 지정하는 것으로 기본키를 변경할 수도 있습니다(그 경우에는 반드시 대응하는 모델도 변경해주세요). 기본키를 사용하고 싶지 않은 경우에는 `id: false`옵션을 지정할 수도 있습니다. 특정 데이터베이스에서 사용하는 옵션이 필요한 경우에는 `:options`을 통해서 SQL문을 추가할 수도 있습니다. 예를 들자면 아래와 같은 식입니다.

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

위의 마이그레이션에서는 테이블을 생성하는 SQL문에 `ENGINE=BLACKHOLE` 옵션을
추가하고 있습니다(MySQL이나 MariaDB를 사용하는 경우 기본값은
`ENGINE=InnoDB`입니다).

그리고 `:comment` 옵션에 테이블에 대한 설명을 추가하고, 이를 데이터베이스에
반영할 수 있습니다. 이는 Mysql Workbench나 PgAdmin III와 같은 데이터베이스
관리 도구를 통해서 확인할 수 있습니다. 커다란 데이터베이스를 사용하는
애플리케이션 마이그레이션에서 설명을 작성하기를 추천합니다. 이는 데이터 모델을
이해하기 쉽게 만들 뿐 아니라 문서를 생성할 수도 있습니다.
현재 MySQL과 PostgreSQL 어댑터가 이 기능을 지원합니다.

### 테이블 조인을 추가하기

마이그레이션의 `create_join_table` 메소드는 has_and_belongs_to_many(HABTM)
조인을 생성합니다. 일반적으로 아래와 같이 작성합니다.

```ruby
create_join_table :products, :categories
```

이에 의해서 `categories_products` 라는 테이블이 생성되며, 그 내부에
`category_id` 컬럼과 `product_id` 컬럼이 생성됩니다. 이 컬럼들에는 `:null`
옵션이 기본적으로 포함되어 있으며, 기본값은 `false`입니다. `column_options`
옵션을 사용하는 것으로 이 값을 덮어쓸 수 있습니다.

```ruby
create_join_table :products, :categories, column_options: {null: true}
```

위에서는 `product_id`와 `category_id`가 추가되고, `:null`이 `true`로 설정됩니다.

테이블명을 변경하고 싶은 경우에는 `:table_name` 옵션을 사용할 수 있습니다. 예를 들면 다음처럼 작성합니다.

```ruby
create_join_table :products, :categories, table_name: :categorization
```

이렇게 변경하는 것으로 `categorization`이라는 테이블을 생성할 수 있습니다.

`create_join_table`에는 블록을 통해 값을 넘겨줄 수도 있습니다. 이를 통해서 인덱스를 추가하거나(기본 설정대로라면 인덱스는 추가되지 않습니다), 컬럼을 추가할 때에 사용할 수 있습니다.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### 테이블을 변경하기

기존의 테이블을 변경하는 `change_table`은 `create_table`과 무척 유사합니다. 기본적으로는 `create_table`과 같은 방법으로 사용할 수 있습니다만, 블록에 대해서 yield로 호출되는 객체에 대해서는 몇 가지 기법을 사용할 수 있습니다. 예를 들자면 이런 방식으로 사용할 수 있습니다.

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

위의 마이그레이션에서는 `description`과 `name`컬럼이 삭제되고, string 형식인 `part_number` 컬럼을 추가하고, 거기에 인덱스도 추가합니다. 마지막으로 `upccode`라는 컬럼을 `upc_code`로 이름을 바꾸었습니다.

### 컬럼을 변경하기

마이그레이션에서는 `remove_column`이나 `add_column` 이외에도 `change_column`이라는 메소드도 존재합니다.

```ruby
change_column :products, :part_number, :text
```

products 테이블에서 `part_number` 컬럼의 형식을 `:text`로 변경합니다.

`change_column` 말고도 `change_column_null` 메소드와 `change_column_default` 메소드도 있으며, 각각 not null 제약을 변경하거나, 기본값을 설정하는 등의 용도로 사용할 수 있습니다.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, false
```

이 마이그레이션은 products 테이블의 `:name` 컬럼에 `NOT NULL` 제약을 추가하고, `:approved` 컬럼에 기본값으로 false를 설정합니다.

TIP: `change_column_null`는 `change_column`(그리고 `change_column_default`)와는 다르게 가역적입니다.

### 컬럼 장식자

컬럼의 추가, 및 변경시에는 컬럼 장식자를 사용할 수 있습니다.

* `limit`는 `string/text/binary/integer` 의 최대 크기를 지정합니다.
* `precision`은 `decimal` 의 정밀도(precision)를 정의합니다. 이 정밀도는 숫자의 전체 자리수를 나타냅니다.
* `scale`은 `decimal`의 정밀도를 정의합니다. 여기의 정밀도는 소수점 이하의 자릿수를 나타냅니다.
* `polymorphic`은 `belongs_to` 관계를 통해 사용가능한 `type` 컬럼을 추가합니다.
* `null`은 컬럼에서 `NULL`의 사용을 허가, 또는 금지합니다.
* `default`는 컬럼의 기본값을 정의할 수 있도록 합니다. date처럼 동적인 값을 사용하는 경우, 기본값은 초기값(마이그레이션이 실행된 날짜)으로 처리된다는 점에 주의해주세요.
* `index` 는 컬럼에 인덱스를 추가합니다.
* `comment` 는 컬럼에 대한 설명을 추가합니다.

몇몇 어댑터에서는 이외에도 사용가능한 옵션들이 존재합니다. 자세한 설명이
필요하시면 각 어댑터의 API 문서를 참조해주세요.

NOTE: `null`과 `default` 옵션은 커맨드 라인 명령을 통해서 추가할 수 없습니다.

### 외래키

[참조 정합성의 보장](#active-record와_참조_정합성)을 위해 외래키 제약을 추가할 수도 있습니다. 반드시 해야할 필요는 없습니다.

```ruby
add_foreign_key :articles, :authors
```

새로운 외래키가 `articles` 테이블의 `author_id`라는 컬럼으로 추가됩니다. 이 키는 `authors` 테이블의 `id`를 참조합니다. 필요한 컬럼명을 테이블에서 추측할 수 없는 경우에는 `:column` 옵션과 `:primary_key` 옵션을 사용할 수 있습니다.

Rails에서는 모든 외래키의 이름은 `fk_rails_`로 시작하며, 그 뒤에 10글자의 랜덤한 문자열로 생성됩니다. 필요하다면 `:name` 옵션을 사용해서 별도의 이름을 사용할 수 있습니다.

NOTE: Active Record에서는 단일 컬럼의 외래키만 지원되고 있습니다. 복합외래키를 사용하고 싶은 경우에는 `execute`와 `structure.sql`가 필요합니다.

외래키의 제거는 아래와 같이 간단하게 할 수 있습니다.

```ruby
# Active Record에게 삭제할 컬럼명을 찾도록 하는 경우
remove_foreign_key :accounts, :branches

# 특정 컬럼을 지정해서 외래키를 삭제하는 경우
remove_foreign_key :accounts, column: :owner_id

# 외래키의 이름을 지정해서 삭제하는 경우
remove_foreign_key :accounts, name: :special_fk_name
```

### 헬퍼의 기능만으로는 부족한 경우

Active Record가 제공하는 헬퍼의 기능만으로는 충분하지 않은 경우 `execute` 메소드를 사용해서 임의의 SQL문을 실행할 수 있습니다.

```ruby
Product.connection.execute('UPDATE `products` SET `price`=`free` WHERE 1')
```

각 메소드의 자세한 내용은 API문사를 확인해주세요.
특히 [`ActiveRecord::ConnectionAdapters::SchemaStatements`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html)
(`change`, `up`, `down` 메소드에서 사용가능한 메소드를 제공), [`ActiveRecord::ConnectionAdapters::TableDefinition`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html) (`create_table`에서 생성가능한 객체에서 사용가능한 메소드를 제공), 그리고 [`ActiveRecord::ConnectionAdapters::Table`](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html) (`change_table`에서 생성되는 객체에서 사용가능한 메소드를 제공)을 참조해주세요.

### `change` 메소드 사용하기

`change` 메소드는 마이그레이선을 직접 만들때 자주 사용되는 메소드입니다. 이 메소드를 사용하면 Active Record가 마이그레이션을 역방향으로 실행(롤백)할 때 자동적으로 처리해주기 때문에 무척 유용합니다. 현 시점에서는 `change`에서 지원하는 마이그레이션 정의는 다음과 같습니다.

* `add_column`
* `add_index`
* `add_reference`
* `add_timestamps`
* `add_foreign_key`
* `create_table`
* `create_join_table`
* `drop_table` (반드시 블럭을 사용할 것)
* `drop_join_table` (반드시 블럭을 사용할 것)
* `remove_timestamps`
* `rename_column`
* `rename_index`
* `remove_reference`
* `rename_table`

`change_table`의 롤백은 `change`, `change_default`, `remove`가 호출되지 않는 경우에만 가능합니다.

이외의 메소드를 사용해야하는 경우에는 `change` 메소드가 아닌 `reversible` 메소드를 사용하거나, `up`, `down` 메소드를 사용해주세요.

### `reversible` 사용하기

마이그레이션이 복잡해지면, Active record가 마이그레이션을 롤백할 수 없는 경우가 생깁니다. `reversible` 메소드를 사용하는 것으로 마이그레이션을 적용할 때의 동작과, 롤백할 때의 동작을 지정할 수 있습니다. 예를 들자면 다음과 같은 식입니다.

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |dir|
      dir.up do
        # CHECK 제약을 추가
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

`reversible` 메소드를 사용하는 것으로, 각 명령을 올바른 순서대로 실행할 수 있게
됩니다. 위의 마이그레이션 예제에서 롤백을 수행하는 경우 `down`블록은 반드시
`home_page_url` 컬럼이 삭제된 이후, 그리고 `distributors` 테이블이 삭제되기
이전에 실행됩니다.

직접 생성한 마이그레이션에서 롤백을 해서는 안되는 경우임에도 불구하고,
롤백을 실행해서 데이터의 일부가 소실될 수도 있습니다. 그러한 경우에는 `down`
블록에서 `ActiveRecord::IrreversibleMigration`를 발생시키면 됩니다. 이렇게 하는
것으로 누군가가 나중에 마이그레이션 롤백을 호출한 경우, 에러를 통해 롤백을
실행할 수 없다는 것을 알려줄 수 있습니다.

### `up`/`down` 메소드 사용하기

`change` 대신에 종래의 `up`과 `down`을 사용할 수 있습니다. 이 때에는 `up`
메소드에는 어떻게 스키마를 변경할 지를 기술하고, `down` 메소드에는 `up`
메소드에 의해서 발생한 변경사항을 취소하는 방법을 기술할 필요가 있습니다.
다시 말해, `up` 뒤에 `down`을 실행하는 경우, 스키마가 이전과 동일한 상태를
유지할 수 있도록 해야합니다. 예를 들어, `up` 메소드에서 테이블을 추가했다면
`down` 메소드에서는 테이블을 삭제하면 됩니다. `down` 메소드에서 이루어지는 작업
순서는 `up` 메소드 내에서 이루어진 변경 순서의 정반대로 만드는 것이 좋습니다.
아까의 `reversible` 섹션의 예는 다음처럼 작성할 수 있습니다.

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # CHECK제약을 추가
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

마이그레이션에서 롤백이 불가능한 경우, `down` 메소드에는
`ActiveRecord::IrreversibleMigration`를 추가해둘 필요가 있습니다. 이렇게 해두는
것으로, 나중에 누군가가 마이그레이션을 롤백하는 경우에 실행불가능하다는 것을
알려줄 수 있습니다.

### 이전 마이그레이션을 롤백하기

`revert` 메소드를 사용하는 것으로 Active Record의 마이그레이션 롤백 기능을
사용할 수 있습니다.

```ruby
require_relative '2012121212_example_migration'

class FixupExampleMigration < ActiveRecord::Migration[5.0]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

`revert`는 블록도 받을 수 있습니다. 블록에서는 롤백을 위한 명령어 목록을 추가할 수 있습니다. 이것은 이전에 사용한 마이그레이션의 일부만을 롤백하고 싶을때에 유용합니다. 예를 들어서 `ExampleMigration`이 이미 적용되어있으며, 나중이 되어서야 우편번호를 검증하는 작업은 `CHECK` 제약보다 Active Record의 유효성검사를 먼저 하는 편이 좋다는 것을 발견한 상황이라고 가정해봅시다.

```ruby
class DontUseConstraintForZipcodeValidationMigration < ActiveRecord::Migration[5.0]
  def change
    revert do
      # copy-pasted code from ExampleMigration
      reversible do |dir|
        dir.up do
          # CHECK 제약을 추가
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

      # 이후의 마이그레이션은 그대로
    end
  end
end
```

`revert`를 사용하지 않고 기존의 방식대로 직접 작성할 수도 있습니다만, 그만큼
불필요한 노력이 더 들어갑니다(`create_table`와 `reversible`의 위치를 바꾸고,
`create_table`을 `drop_table`로 변경하고, 마지막으로 `up`과 `down`을 바꿔야
합니다).
`revert`는 이러한 작업을 간편하게 만들어줍니다.

마이그레이션을 실행하기
------------------

Rails에는 마이그레이션을 실행하기 위한 bin/rails task가 존재합니다.

가장 편하게 마이그레이션을 실행하기 위한 bin/rails task는 대부분의 경우
`bin/rails db:migrate`일 겁니다. 이 명령은 기본적으로 지금까지 실행된 적이
없는 `change` 또는 `up` 메소드를 실행합니다. 실행되지 않은 마이그레이션이 없는
경우에는 아무것도 하지 않고 종료합니다. 마이그레이션의 실행 순서는
마이그레이션의 타임스탬프에 의존합니다.

`db:migrate` 명령을 실행하면 `db:schema:dump` 작업도 동시에 호출된다는 점을 주의해주세요. 이 작업은 `db/schema.rb` 스키마 파일을 변경하고, 스키마가 데이터베이스의 구조와 일치하도록 만듭니다.

특정 버전의 마이그레이션을 지정하면, Active Record는 지정된 마이그레이션 버전이 될 때까지 마이그레이션(change/up/down)을 실행합니다. 마이그레이션의 버전은 마이그레이션 파일명의 앞부분에 쓰여있는 숫자로 표시됩니다. 예를 들어서 20080906120000이라는 버전으로 마이그레이션을 실행하고 싶은 경우에는 아래와 같이 실행합니다.

```bash
$ bin/rails db:migrate VERSION=20080906120000
```

20080906120000라는 버전이 현재의 버전보다 큰 경우(적용되지 않은 마이그레이션이 존재하는 경우) 버전이 20080906120000이 될 때까지 모든 마이그레이션의 `change`(또는 `up`) 메소드를 실행하고, 버전이 일치하면 그 이상 마이그레이션을 진행하지 않습니다. 이는 지정한 버전까지를 포함합니다. 지정한 버전이 현재 버전보다 낮은 버전일 경우, 20080906120000이 될 때까지 모든 마이그레이션의 `down` 메소드를 실행합니다만, 위와는 다르게 20080906120000 버전의 마이그레이션은 실행 대상에 포함되지 않는다는 점에 주의해주세요.

### 롤백

직전에 실행한 마이그레이션을 롤백하는 경우가 잦습니다. 예를 들어 마이그레이션에 착오가 있어서 정정하고 싶은 경우 등이 있을겁니다. 이 경우, 버전을 찾아 명시적으로 지정하지 않고, 다음을 실행하는 것으로 해결할 수 있습니다.

```bash
$ bin/rails db:rollback
```

이 명령어로, 직전의 마이그레이션이 롤백됩니다. `change` 메소드를 반대로 실행하던가, `down` 메소드를 실행합니다. 마이그레이션을 다수 롤백하고 싶은 경우에는 `STEP` 파라미터를 지정해주세요.

```bash
$ bin/rails db:rollback STEP=3
```

이렇게 마지막에 실행한 3개의 마이그레이션을 롤백할 수 있습니다.

`db:migrate:redo`는 롤백과 마이그레이션을 동시에 실행할 수 있는 단축
명령입니다. 다수의 버전에 대해서 실행하고 싶은 경우에는 `db:rollback` 때와
마찬가지로 `STEP` 파라미터를 지정하면 됩니다.

```bash
$ bin/rails db:migrate:redo STEP=3
```

단 `db:migrate`로 실행할 수 없는 작업을 이 명령을 통해 실행할 수는 없습니다.
이는 단순히, 버전을 명시적으로 지정할 필요가 없도록 `db:migrate`를 쓰기 편하게
만든 것이기 때문입니다.

### 데이터베이스 설정하기

`bin/rails db:setup`은 데이터베이스의 생성, 스키마 읽기/쓰기, 초기
데이터(seed)를 사용해 데이터베이스의 초기화 등을 수행합니다.

### 데이터베이스 리셋하기

`bin/rails db:reset`은 데이터베이스를 drop하고 재설정합니다. 이 명령은
`bin/rails db:drop db:setup`과 동등합니다.

NOTE: 이 명령은 모든 마이그레이션을 실행하는 것과 동일하지 않습니다. 이 명령은
현재의 `schema.rb`의 내용을 그대로 다시 사용하기 때문입니다. 마이그레이션을
롤백할 수 없는 경우에는 `bin/rails db:reset`를 실행해도 복구할 수 없는 경우가
있습니다. 스키마 덤프에 대해서는 [스키마 덤프의 의의](#스키마_덤프의_의의)를
참조해주세요.

### 특정 마이그레이션만을 실행하기

특정 마이그레이션의 up 또는 down 을 실행할 필요가 있는 경우에는 `db:migrate:up`
또는 `db:migrate:down`을 사용합니다. 아래에서처럼 적절한 버전 번호를 지정하는
것으로 해당하는 마이그레이션을 포함한 `change`, `up`, `down` 메소드를 호출할
수 있습니다.

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

위를 실행하면 버전 번호가 20080906120000인 마이그레이선에 포함되어있는
`change`(또는 `up`)이 실행됩니다. 이 명령은 처음에 해당 마이그레이션이 적용된
상태인지를 체크하고, Active Record에 의해서 이미 실행되었다고 판단되면 아무것도
실행하지 않습니다.

### 다른 환경에서 마이그레이션을 실행하기

기본적으로 `bin/rails db:migrate`는 `development` 환경에서 실행됩니다. 다른
환경에서 마이그레이션을 실행하고 싶은 경우에는 명령어를 실행할 때
`RAILS_ENV`라는 환경변수를 지정합니다. 예를 들어서 `test` 환경에서
마이그레이션을 실행하고 싶은 경우에는 아래와 같이 명령하면 됩니다.

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### 마이그레이션 실행 결과 출력값을 변경하기

기본적으로 마이그레이션을 실행한 후에 실행된 내용과 각각의 소요 시간이
출력됩니다. 예를 들어 테이블 작성과 인덱스를 추가하는 마이그레이션을 실행하면
아래와 같이 출력됩니다.

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

마이그레이션에는 출력 방식을 제어하기 위한 메소드가 제공되고 있습니다.

| 메소드               | 목적
| -------------------- | -------
| suppress_messages    | 인수로서 블록을 하나 받고, 그 블록에 의해서 생성된 출력을 모두 차단합니다.
| say                  | 인수로서 메시지를 하나 받고, 그 메시지를 그대로 출력합니다. 2번째 인수로 들여쓰기를 사용할지 안할지 지정하는 boolean 값을 줄 수 있습니다.
| say_with_time        | 받은 블록을 실행하는데 걸린 시간을 나타내는 텍스트를 출력합니다. 블록이 정수를 돌려주는 경우, 영향을 받은 레코드 갯수로 생각합니다.

아래의 마이그레이션을 봐주세요.

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

이 마이그레이션에 의한 출력은 다음과 같습니다.

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

Active Record에서 아무것도 출력하고 싶지 않은 경우에는
`bin/rails db:migrate VERBOSE=false`를 실행하는 것으로 출력을 완전히 막을 수
있습니다.

기존의 마이그레이션을 변경하기
----------------------------

마이그레이션을 직접 작성하다보면, 때때로 실수하는 경우가 있습니다. 이미
마이그레이션을 실행해버린 뒤라면 기존의 마이그레이션을 편집해서 다시
마이그레이션을 실행해도 의미가 없습니다. Rails는 마이그레이션이 이미
적용되었다고 생각하고 있으므로 `bin/rails db:migrate`를 실행해도 아무것도
변경되지 않습니다. 이러한 경우에는 마이그레이션을 일단
롤백(`bin/rails db:rollback` 등을 이용해서)하고 마이그레이션을 수정, 그리고
수정 완료된 버전을 실행하기 위해서 `bin/rails db:migrate`를 실행해야할 필요가
있습니다.

무엇보다 기존의 마이그레이션을 직접 변경하는 것은 일반적으로 좋은 방법이
아닙니다. 기존의 마이그레이션을 변경하면, 자신 뿐 아니라, 함께 작업하는
사람들에게도 추가 작업을 강요하는 꼴이 되기 때문입니다. 또한 기존의
마이그레이션이 이미 실 배포환경에 적용되어있을 경우, 무척 골치아플 것입니다.
이런 경우에는 기존의 마이그레이션을 직접 수정하지 말고 이를 위한
마이그레이션을 새로 생성하고, 실행하는 것이 올바른 방법입니다. 또는 아직 버전
컨트롤 시스템에 반영되지 않은 마이그레이션을 편집하는 것이 가장 무난한
방법이라고 할 수 있습니다.

`revert` 메소드는 이전에 마이그레이션 전체 또는 그 일부를 취소하기 위한
마이그레이션을 작성할 때에도 편리합니다(이미 언급한
[이전 마이그레이션을 롤백하기](#이전-마이그레이션을-롤백하기)를 참조하세요).

스키마 덤프의 의의
----------------------

### 스키마 파일의 의미

Rails의 마이그레이션은 너무 강력해서, 데이터베이스 스키마를 생성하기 위한
믿을 수 있는 정보원으로 사용하기에는 적절치 않습니다. 스키마 정보는
`db.schema.rb`나 Active Record가 데이터베이스를 검사하는 것으로 생성된
SQL파일을 사용하게 됩니다. 이 파일들은 단순히 데이터베이스의 현재 상태를
나타내는 것으로, 개발자가 편집하는 파일이 아닙니다.

애플리케이션의 새로운 인스턴스를 배포하는 경우에, 방대한 마이그레이션 이력을
모두 재실행할 필요는 없습니다. 오히려 그런 방식을 사용하면 에러가 발생하기
쉬워질 것입니다. 그 대신 현재의 스키마의 상태를 데이터베이스에게 알려주는 것이
간결하고 빠릅니다.

예를 들어 Rails에서 test 환경용의 데이터베이스를 생성하는 방법을 설명합니다.
현재 development 데이터베이스를 `db/schema.rb`나 `db/structure.sql`로 덤프를
생성하고, 이어서 이 파일을 test 환경용의 데이터베이스에 그대로 적용합니다.

스키마 파일은 Active Record 객체에 어떤 속성이 있는지 확인하기도 편리합니다.
모델은 스키마 정보를 가지고 있지 않습니다. 스키마 정보는 여러 마이그레이션
파일에 나누어져서 존재하고 있으며, 그대로는 무척 찾기 불편합니다만, 스키마
파일은 이 정보를 모아서 보관하고 있습니다. 또한
[annotate_models](https://github.com/ctran/annotate_models) 잼을 사용하면
모델 파일의 시작 부분에 스키마 정보를 요약해주는 주석을 자동적으로 추가,
갱신되므로 편리합니다.

### 스키마 덤프의 종류

스키마의 덤프 방법으로는 2가지가 있습니다. 덤프 방법은
`config/application.rb`의 `config.active_record.schema_format`에서 `:sql`
또는 `:ruby`로 지정할 수 있습니다.

`:ruby`로 지정하면, 스키마는 `db/schema.rb`에 저장됩니다. 이 파일을 열어보면
하나의 커다란 마이그레이션처럼 보일 것입니다.

```ruby
ActiveRecord::Schema.define(version: 20080906171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "part_number"
  end
end
```

이 스키마 정보는 보이는 것처럼 스키마의 내용을 단도직입적으로 나타내고
있습니다. 이 파일은 데이터베이스를 상세하게 확인하고 `create_table`이나
`add_index` 등을 이용해서 그 구조를 표현합니다. 이 스키마 정보는 데이터베이스의
종류에 의존하지 않으므로, Active Record가 지원하는 데이터베이스라면 어떤
내용이라도 포함할 수 있습니다. 이 특성은 여러 종류의 데이터베이스를 실행할 수
있는 애플리케이션을 만들 필요가 있을 때 유용합니다.

이런 유용한 특징을 얻는 대신에, 한가지 단점이 있습니다. 당연하지만,
`db/schema.rb`에서는 데이터베이스의 고유한 항목(트리거나, 프로시져 등)을
포함할 수 없습니다. 마이그레이션에는 커스텀 SQL을 포함할 수 있습니다만,
스키마를 덤프할 때에는 데이터베이스에서 구조를 재구성할 수 는 없기 때문입니다.
그러므로 데이터베이스 고유의 기능을 사용하려면 스키마의 포맷을 `:sql`로 설정할
필요가 있습니다.

이 경우 Active Record의 스키마 덤프를 이용하는 대신, 데이터베이스 고유의 툴을
사용해서 `db/structure.sql`에 덤프합니다(`db:structure:dump` 명령어를 사용).
예를 들어서 PostgreSQL의 경우 `pg_dump` 유틸리티가 있습니다. MySQL이나
MariaDB의 경우는 `SHOW CREATE TABLE`의 출력 결과가 파일에 포함됩니다.

스키마를 읽어 들일 때에는 거기에 포함되는 SQL문을 실행하기만 합니다. 이에
의해서 데이터베이스의 구조의 완전한 사본을 생성할 수 있습니다. 그 대신,
`:sql` 형식을 사용한 경우에는 그 스키마를 작성한 RDBMS 이외에는 사용할 수
없다는 제한사항도 생겨납니다.

### 스키마 덤프와 소스 코드 관리

위에서 언급한 대로 스키마 덤프는 데이터베이스 스키마에서 정보를 가져오기 때문에
신뢰할 수 있습니다. 따라서 스키마 파일을 Git 등의 버전 관리 하에 두기를 강하게
추천합니다.

`db/schema.rb`에는 데이터베이스의 현재 버전 번호가 포함되어있습니다. 이를 통해
다른 브랜치에서 스키마가 변경되어있었던 경우에도, 양자를 병합할 때 경고가
발생한다는 장점도 있습니다. 충돌이 발생했을 경우에는 수동으로 번호가 큰 버전을
남겨둘 필요가 있습니다.

Active Record의 참조정합성
---------------------------------------

Active Record는 영리하게 동작해야하는 것은 모델이지, 데이터베이스가 아니라는
컨셉에 기초하고 있습니다. 그리고 실제로 트리거나 제약 같은 고도의 데이터베이스
기능은 그렇게 많이 사용되지 않습니다.

`validates :foreign_key, uniqueness: true`같은 데이터베이스 검증기능은 데이터
정합성을 모델이 처리하고 있는 한가지 예시입니다. 모델의 관계 설정시에
`:dependent` 옵션을 지정하면 부모 객체가 삭제되었을 경우에, 자식 객체도
자동으로 삭제됩니다. 애플리케이션 레벨에서 실행되는 다른 것들과 마찬가지로
이런 모델의 기능만으로 참조정합성을 유지할 수 없기 때문에, 데이터베이스의
[외래키 제약](#외래키)을 사용해서 참조 정합성을 확보하는 개발자도 있습니다.

Active Record만으로 이런 외부 기능을 전부 제공할 수는 없습니다만, `execute`
메소드를 사용해서 임의의 SQL을 실행할 수 있습니다.

마이그레이션과 Seed 데이터
------------------------

Rails 마이그레이션은 일관적인 스키마 변경 방식을 제공하려는 목적이 있습니다.
마이그레이션은 데이터를 추가하거나 수정할 때에도 사용할 수 있습니다. 이는
실제 환경의 데이터베이스처럼 삭제하거나 재생성해서는 안되는 데이터베이스에서
유용하게 사용됩니다.

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

그런데 Rails에는 초기 데이터를 데이터베이스에 주기 위한 Seed 기능이 있습니다.
`db/seeds.rb` 파일에 약간의 루비 코드를 추가하고 `bin/rails db:seed`를
실행하기만 하면 됩니다.

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

이 방법이라면, 마이그레이션을 사용하는 것보다 깔끔하게 새 애플리케이션의
데이터베이스를 설정할 수 있습니다.

