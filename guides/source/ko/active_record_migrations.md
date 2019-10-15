# 액티브 레코드 마이그레이션 {#active-record-migrations}

마이그레이션은 시간이 지남에 따라 데이터베이스 스키마를 발전시킬 수 있는 액티브 레코드의 특수한 기능이다. 순수 SQL로 스키마 수정을 작성하는 대신 마이그레이션을 통해 쉬운 루비 DSL을 사용하여 테이블의 변경 사항을 기술할 수 있다.

이 가이드를 읽은 후에는 아래의 내용을 알게 될 것이다.

- 마이그레이션을 생성할 때 사용하는 생성자
- 데이터베이스를 다루기 위해서 액티브 레코드가 제공하는 메소드
- 마이그레이션과 스키마를 다루는 레일스 명령어
- 마이그레이션이 `schema.rb`와 연관되는 방법

----------------------------------------------------------------------------------------------------------------------------

## 마이그레이션 개요 {#migration-overview}

마이그레이션은 일관되고 쉬운 방법으로 [시간이 지남에 따라 데이터베이스 스키마를 변경](https://en.wikipedia.org/wiki/Schema_migration)하는 편리한 방법이다. SQL을 직접 작성하지 않고 루비 DSL을 사용하므로 스키마와 변경 사항을 데이터베이스와 독립적으로 만들 수 있다.

각 마이그레이션을 데이터베이스의 새로운 '버전'으로 생각할 수 있다. 스키마는 아무 것도 없이 시작하며 각 마이그레이션은 테이블, 컬럼 또는 항목을 추가하거나 제거하도록 스키마를 수정한다. 액티브 레코드는 이와 같은 마이그레이션 타임 라인에 따라 스키마를 업데이트하는 방법을 알고 있으며 히스토리 상의 어느 지점에 있더라도 최신 버전으로 유지한다. 액티브 레코드는 또한 데이터베이스의 최신 구조와 일치하도록 `db/schema.rb` 파일을 업데이트 할 것이다.

마이그레이션의 예는 아래와 같다.

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

이 마이그레이션은 `name`이라는 문자열 컬럼과 `description`이라는 텍스트 컬럼으로 구성된 `products`라는 테이블을 추가한다. `id`라는 기본키 컬럼도 모든 액티브 레코드 모델의 기본 기본키이므로 암시적으로 추가된다. `timestamps` 매크로는 `created_at`와m`updated_at`의 두 컬럼을 추가한다. 이러한 특수 컬럼이 존재하는 경우 액티브 레코드에 의해 자동으로 관리된다.

앞으로 진행되기를 바라는 변경 내용을 미리 정의한다는 것에 주목한다. 이 마이그레이션이 실행되기 전에는 테이블이 존재하지 않는다. 그 후에 테이블이 존재한다. 액티브 레코드는 이 마이그레이션을 돌이키는 방법도 알고 있다. 즉, 이 마이그레이션을 롤백하면 테이블이 제거될 것이다.

스키마를 변경하는 SQL문에 트랜잭션을 지원하는 데이터베이스에서는 트랜잭션이 마이그레이션을 랩핑한다. 데이터베이스가 이를 지원하지 않으면 마이그레이션이 실패 할 때 일부 성공한 부분이 롤백되지 않는다. 이 부분에 대해서는 별도의 롤백 작업을 해야 한다.

NOTE: 트랜잭션 내에서 실행할 수 없는 특정 쿼리가 있다. 어댑터가 DDL 트랜잭션을 지원하는 경우 `disable_ddl_transaction!`을 사용하여 단일 마이그레이션에 대해 트랜잭선을 비활성화 할 수 있다.

액티브 레코드가 되돌릴 수 있는 방법을 모르는 작업을 수행하려면 `reversible` 메소드를 사용할 수 있다.

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

또는 `change` 대신 `up`과 `down`을 사용할 수 있다.

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

## 마이그레이션 작성하기 {#creating-a-migration}

### 별도의 마이그레이션 파일 작성하기 {#creating-a-standalone-migration}

마이그레이션은 각 마이그레이션 클래스마다 하나씩 `db/migrate` 디렉토리에 파일로 저장된다. 파일 이름은 `YYYYMMDDHHMMSS_create_products.rb` 형식을 가진다. 즉, 마이그레이션을 식별하는 UTC 타임 스탬프와 밑줄 그리고 마이그레이션 이름으로 구성되어 있다. 마이그레이션 클래스의 이름 (CamelCased 버전)은 파일 이름의 후반 부분과 일치해야 한다. 예를 들어`20080906120000_create_products.rb`는 `CreateProducts` 클래스를 정의하고 `20080906120001_add_details_to_products.rb`는`AddDetailsToProducts`를 정의해야 한다. 레일스는 이 타임 스탬프를 사용하여 마이그레이션을 어떤 순서로 실행할지 결정하므로 다른 애플리케이션에서 마이그레이션을 복사하거나 파일을 직접 생성하는 경우 순서에 따라 위치를 알고 있어야 한다.

물론 타임 스탬프 계산은 재미있는 작업이 아니기 때문에 액티브 레코드에서는 아래와 같은 작업을 처리 할 수 있는 생성자를 제공한다.

```bash
$ rails generate migration AddPartNumberToProducts
```

적절한 이름의 빈 마이그레이션이 생성될 것이다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
  end
end
```

이 생성자는 파일 이름에 타임 스탬프를 추가하는 것 이상을 수행 할 수 있다. 명명 규칙 및 추가 (선택적) 인수를 기반으로 마이그레이션의 불필요한 부분을 제거할 수 있다.

마이그레이션 이름이 "AddColumnToTable" 또는 "RemoveColumnFromTable" 형식이고 컬럼의 이름과 데이터형 리스트가 오는 경우 적절한 `add_column`과 `remove_column` 문이 포함된 마이그레이션이 작성될 것이다.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string
```

위와 같은 마이그레이션 명령으로 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

새 컬럼에 인덱스를 추가하려면 아래와 같이 수행한다.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string:index
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

마찬가지로 커맨드라인에서 특정 컬럼을 제거하기 위해 마이그레이션을 생성할 수 있다.

```bash
$ rails generate migration RemovePartNumberFromProducts part_number:string
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

하나의 컬럼만 제한되지 않는다. 예를 들면 아래와 같이 두개의 컬럼을 추가할 수 있다.

```bash
$ rails generate migration AddDetailsToProducts part_number:string price:decimal
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

마이그레이션 이름이 "CreateXXX" 형식이고 컬럼 이름 및 데이터형 리스트가 뒤따라 오면 행달 컬럼들이 포함된 테이블 XXX를 작성하는 마이그레이션이 생성될 것이다. 예를 들면,

```bash
$ rails generate migration CreateProducts name:string part_number:string
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

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

항상 그렇듯이 이렇게 생성된 것은 시작에 불과하다. `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb` 파일을 편집하여 원하는 대로 추가하거나 제거 할 수 있다.

또한 생성자는 컬럼 데이터형으로 `references`(또는 `belongs_to`)을 사용할 수 있다. 예를 들면,

```bash
$ rails generate migration AddUserRefToProducts user:references
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

이 마이그레이션은 `user_id` 컬럼과 적절한 인덱스를 생성할 것이다 .
`add_reference` 옵션에 대한 자세한 내용을 보기 위해서는 [API documentation](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference)을 방문한다.

이름의 일부 중 `JoinTable`이 포함되어 있는 경우 조인 테이블을 생성하는 생성자도 있다.

```bash
$ rails g migration CreateJoinTableCustomerProduct customer product
```

실행결과 아래와 같은 마이그레이션 클래스 파일이 생성될 것이다.

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

### 모델 생성자 {#model-generators}

모델 및 스카폴드 생성자는 새 모델 추가에 적합한 마이그레이션을 작성한다. 이 마이그레이션에는 관련 테이블 작성에 대한 지시 사항이 이미 포함되어 있다. 원하는 컬럼을 레일스에 알려 주면 이 컬럼을 추가하기 위한 명령문도 작성된다. 예를 들어 아래의 명령를 실행하면,

```bash
$ rails generate model Product name:string description:text
```

아래와 같은 마이그레이션 클래스를 생성할 것이다.

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

원하는 만큼 컬럼 이름/데이터형 쌍을 추가 할 수 있다.

### 데이터형 변경자 지정하기 {#passing-modifiers}

일반적으로 사용되는 몇몇 [데이터형 변경자](#column-modifiers)는 커맨드 라인에서 직접 지정할 수 있다. 중괄호로 묶고 필드 데이터형 다음에 지정한다.

예를 들어 아래와 같이 실행하면

```bash
$ rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

아래와 같은 마이그레이션 클래스 파일을 생성할 것이다.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: 자세한 내용은 생성자 도움말을 살펴 보기 바란다.

## 마이그레이션 작성하기 {#writing-a-migration}

생성자 중 하나를 사용하여 마이그레이션을 생성했다면 이제는 작업해야 할 때다.

### 테이블 생성하기 {#creating-a-table}

`create_table` 메소드는 가장 기본적인 방법 중 하나이지만 대부분의 경우 모델 또는 스카폴드 생성자를 사용할 때 생성된다. 일반적인 용도는 아래와 같다.

```ruby
create_table :products do |t|
  t.string :name
end
```

위의 메소드는 `name`이라는 컬럼이 있는 `products` 테이블을 생성한다(아래에서 설명하는 것처럼, `id` 컬럼도 암묵적으로 자동 생성된다).

기본적으로 `create_table`은 `id`라는 기본키를 생성한다. `:primary_key` 옵션을 사용하여 기본키 이름을 변경하거나 (이 경우, 해당 모델을 업데이트하는 것을 잊지 말아야 한다.) 기본키를 원하지 않으면 `id: false` 옵션을 전달할 수 있다. 데이터베이스 특정 옵션을 전달해야 하는 경우 `:options` 옵션에 SQL문 일부를 지정할 수 있다. 예를 들어,

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

위의 코드는 테이블을 생성하는데 사용되는 SQL 문에 `ENGINE=BLACKHOLE` 옵션이 추가될 것이다.

또한 테이블에 대한 설명을 `:comment` 옵션으로 전달하여 데이터베이스 자체에 저장할 수 있고 MySQL Workbench 또는 PgAdmin III과 같은 데이터베이스 관리 도구로 볼 수 있다. 데이터 모델을 이해하고 문서를 생성하는 데 도움이 될 수 있으므로 규모가 큰 데이터베이스와 연결되는 애플리케이션에 사용하는 마이그레이션에는 주석을 지정하는 것이 좋다. 현재로는 MySQL 및 PostgreSQL 어댑터 만 주석을 지원한다.

### 조인 테이블 생성하기 {#creating-a-join-table}

마이그레이션 메소드인 `create_join_table`은 HABTM(has and belongs to
many) 조인 테이블을 생성한다. 일반적인 사용법 아래와 같다.

```ruby
create_join_table :products, :categories
```

`category_id`와`product_id`라는 두 개의 컬럼이 있는 `categories_products` 테이블을 만든다. 이 컬럼에는 기본적으로 `:null` 옵션이 `false`로 설정되어 있다. `:column_options` 옵션을 지정하여 덮어 쓸 수 있다 .

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

기본적으로, 조인 테이블의 이름은 알파벳 순서로 create_join_table에 제공된 처음 두 인수를 합쳐서 만들어진다. 테이블 이름을 사용자 정의하려면 `:table_name` 옵션을 지정하면 된다.

```ruby
create_join_table :products, :categories, table_name: :categorization
```

위의 명령을 실행하면 `categorization` 테이블이 생성된다.

`create_join_table`은 (기본적으로 생성되지 않은) 인덱스 또는 컬럼을 추가하는 데 사용할 수 있는 블록도 허용한다.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### 테이블 변경하기 {#changing-tables}

`create_table`의 가까운 사촌은 `change_table`이며 기존 테이블을 변경하는 데 사용된다. `create_table`과 비슷한 방식으로 사용 되지만 블록 변수로 넘겨지는 객체는 더 많은 마술 같은 능력을 가진다. 예를 들면 아래와 같다.

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

위의 코드는 `description` 및`name` 컬럼을 제거하고 `part_number` 문자열 컬럼을 작성하고 인덱스를 추가한다. 마지막으로 `upccode` 컬럼의 이름을 변경한다.

### 컬럼 변경하기 {#changing-columns}

`remove_column` 및 `add_column`과 같이 레일스는`change_column` 마이그레이션 메소드를 제공한다.

```ruby
change_column :products, :part_number, :text
```

위의 코드를 실행하면 products 테이블의 `part_number` 컬럼이 `:text` 필드로 변경된다. `change_column` 명령은 되돌릴 수 없다는 것에 주목해야 한다.

`change_column` 외에도 `change_column_null` 및`change_column_default` 메소드는 not null 제한 조건과 컬럼의 기본값을 변경하는 데 사용된다.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

위의 코드를 실행하면 products 테이블의 `:name` 필드를 `NOT NULL` 컬럼으로 설정하고 `:approved` 필드의 기본값을 true에서 false로 설정한다.

NOTE: 위의 `change_column_default` 마이그레이션을 `change_column_default :products, :approved, false`로 작성할 수도 있지만 이전 예제와 달리 마이그레이션을 되돌릴 수 없게 만든다.

### 컬럼 변경자 {#column-modifiers}

컬럼을 만들거나 변경할 때 컬럼 변경자를 적용 할 수 있다.

- `limit` : `string/text/binary/integer` 필드의 최대 크기를 설정한다.
- `precision` : `decimal`(소수점) 필드의 정밀도를 지정하며 숫자의 총 자릿수를 표시한다.
- `scale` : 소수점 이하 자릿수를 표시하며 `decimal` 필드의 스케일을 정의한다.
- `polymorphic` : `belongs_to` 관계 설정을 위한 `type` 컬럼을 추가한다.
- `null` : 컬럼에서 `NULL` 값의 허용 여부를 지정한다.
- `default` : 컬럼에서 기본값을 설정할 수 있다. 동적 값 (예 : 날짜)을 사용할 경우 기본값은 처음 (즉, 마이그레이션이 적용된 날짜)에만 계산된다것에 주목한다.
- `comment` : 컬럼에 주석을 추가한다.

일부 어댑터는 추가 옵션을 지원할 수 있다. 자세한 정보는 어댑터 별 API 문서를 참조한다.

NOTE: `null` 및 `default`는 커맨드 라인을 통해 지정할 수 없다.

### 외래키 {#foreign-keys}

필수 사항은 아니지만, [guarantee referential integrity](#active-record-and-referential-integrity)에 외래키 제약 조건을 추가할 수 있다.

```ruby
add_foreign_key :articles, :authors
```

이로써 `articles` 테이블의`author_id` 컬럼에 새로운 외래키가 추가됐다. 이 외래키는 `authors` 테이블의 `id` 컬럼을 참조한다. 컬럼 이름을 테이블 이름에서 유추할 수 없는 경우 `:column` 및 `:primary_key` 옵션을 사용한다.

레일스가 생성하는 모든 외래키는 `fk_rails`로 시작해서 `from_table`과 `column`으로부터 만들어지는 10개의 글자가 추가되어 생성하게 된다. 필요할 경우 다른 이름을 지정할 수 있는 `:name` 옵션이 있다.

NOTE: 액티브 레코드는 단일 컬럼 외래키만 지원한다. 복합 외래키를 사용하려면 `execute` 및 `structure.sql`이 필요하다. [Schema Dumping and You](#schema-dumping-and-you)를 참조한다.
외래키를 제거하는 것도 간단하다.

```ruby
# 액티브 레코드가 컬럼 이름을 알아 내게 한다.
remove_foreign_key :accounts, :branches

# 특정 컬럼에 대한 외래키를 제거한다.
remove_foreign_key :accounts, column: :owner_id

# 이름을 지정하여 외래키를 제거한다.
remove_foreign_key :accounts, name: :special_fk_name
```

### 헬퍼 메소드가 충분히 않을 때 {#when-helpers-aren't-enough}

액티브 레코드에서 제공하는 헬퍼가 충분하지 않으면 `execute` 메소드를 사용하여 임의의 SQL을 실행할 수 있다.

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

개별 메소드의 세부 사항 및 예제는 API 문서를 확인한다.
특히, [`ActiveRecord::ConnectionAdapters::SchemaStatements`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html) ( `change`, `up`, `down` 메소드에서 사용할 수 있는 메소드를 제공하는 문서), [`ActiveRecord::ConnectionAdapters::TableDefinition`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html) (`create_table`에 의해 생성된 객체에서 사용 가능한 메소드를 제공하는 문서) 그리고 [`ActiveRecord::ConnectionAdapters::Table`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html) (`change_table`에 의해 생성 된 객체에서 사용 가능한 메소드를 제공하는 문서) 등이다.

### `change` 메소드 사용하기 {#using-the-change-method}

`change` 메소드는 마이그레이션을 작성하는 주된 방법이다. 액티브 레코드가 마이그레이션을 자동으로 되돌리는 방법을 알고 있는 경우에만 대부분 작동한다. 현재 `change` 메소드는 아래의 마이그레이션 정의만 지원한다.

- add_column
- add_foreign_key
- add_index
- add_reference
- add_timestamps
- change_column_default (:from 과 :to 옵션을 지정해야 함.)
- change_column_null
- create_join_table
- create_table
- disable_extension
- drop_join_table
- drop_table (블록을 지정해야 함.)
- enable_extension
- remove_column (데이터형을 지정해야 함.)
- remove_foreign_key (두번째 테이블을 지정해야 함.)
- remove_index
- remove_reference
- remove_timestamps
- rename_column
- rename_index
- rename_table

`change_table`은 블록이 `change`, `change_default` 또는`remove`를 호출하지 않는 한 가역적이다.

`remove_column`은 컬럼 데이터형을 세 번째 인수로 제공하면 되돌릴 수 있다. 원본의 컬럼 옵션도 제공하도록 한다. 그렇지 않으면 레일스가 롤백 할 때 컬럼을 정확하게 다시 생성할 수 없다.

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

다른 메소드를 사용해야 할 경우에는 `change` 대신 `reversible` 메소드를 사용하거나 `up` 과 `down` 메소드를 작성해야 한다.

### `reversible` 메소드 사용하기 {#using-reversible}

복잡한 마이그레이션에서는 액티브 레코드가 되돌릴 방법을 모르는 경우를 처리해야 할 필요가 있다. `reversible` 메소드를 사용하여 마이그레이션을 실행할 때 수행할 작업과 되돌릴 때 수행할 작업을 지정할 수 있다. 예를 들면 아래와 같다.

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

`reversible` 메소드를 사용할 때 명령도 올바른 순서로 실행되어야 한다. 이전 예제 마이그레이션을 되돌릴 경우 `home_page_url` 컬럼이 제거 된 후 `distributors` 테이블이 삭제되기 직전에 `down` 블록이 실행될 것이다.

때때로 마이그레이션은 돌이킬 수 없는 단순한 일을 할 것이다. 예를 들어 일부 데이터를 손상시킬 수도 있다. 이 경우 `down` 블록에서 `ActiveRecord::IrreversibleMigration` 예외를 발생시킬 수 있다. 누군가 마이그레이션을 되돌리려고 하면 수행 할 수 없다는 오류 메시지가 표시될 것이다.

### `up`/`down` 메소드 사용하기  {#using-the-up/down-methods}

`change` 메소드 대신 `up` 및 `down` 메소드를 사용하여 이전 스타일의 마이그레이션을 사용할 수도 있다.
`up` 메소드는 스키마에 적용할 변환내용을 기술해야 하며, 마이그레이션의`down` 메소드는 `up` 메소드가 수행한 변환을 되돌려야 한다. 즉, `up` 다음에`down`을 수행하면 데이터베이스 스키마는 변경되지 않아야 한다. 예를 들어, `up` 메소드에서 테이블을 작성하는 경우 `down` 메소드에서 테이블을 삭제해야한다. `up` 메소드로 만들어진 역순으로 변환을 수행하는 것이 현명하다. 아래의 예는 `reversible` 섹션에 있는 것과 동일한 내용이다.

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

마이그레이션이 되돌릴 수 없는 경우 `down` 메소드에서 `ActiveRecord::IrreversibleMigration` 예외를 발생시켜야 한다. 누군가 마이그레이션을 되돌리려고 하면 이를 수행 할 수 없다는 오류 메시지가 표시될 것이다.

### 이전 마이그레이션 되돌리기 {#reverting-previous-migrations}

`revert` 메소드를 사용하여 액티브 레코드의 마이그레이션 롤백 기능을 사용할 수 있다.

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

또한, `revert` 메소드는 되돌리기 위한 명령을 블록으로 받을 수 있다. 이것은 이전 마이그레이션에서 특정 부분을 되돌리는 데 유용 할 수 있다. 예를 들어, 이미 `ExampleMigration`을 커밋한 상황을 가정한다면, 'CHECK' 제약 조건 대신 액티브 레코드 유효성 검사를 사용하여 우편 번호를 확인하는 것이 가장 좋은 방법이 될 것이다.

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

`revert`를 사용하지 않고 동일한 마이그레이션을 작성할 수도 있겠지만 몇 가지 단계가 더 필요할 것이다. 즉, `create_table`과 `reversible` 순서를 바꾸고, `create_table`을 `drop_table`로 변경하며, 마지막으로 `up`을 `down`으로 대체하는 것이다. 이 반대로도 마찬가지다. 이것은 모두 `revert` 메소드에 의해 처리된다.

위의 예와 같이 check 제약 조건을 추가하려면 `structure.sql`을 덤프 메소드로 사용해야 한다. [Schema Dumping and You](#schema-dumping-and-you)를 참조하기 바란다.

## 마이그레이션 실행하기 {#running-migrations}

레일스는 마이그레이션 작업을 실행하기 위해 몇가지 rails 명령을 제공한다.

가장 먼저 사용할 마이그레이션 관련 rails 명령은 아마도 `rails db:migrate` 일 것이다. 가장 기본적인 형태로는, 아직 실행되지 않은 모든 마이그레이션에 대해 `change` 또는`up` 메소드만을 실행하는 것이다. 이와 같이 미실행 마이그레이션이 없으면 작업은 바로 종료된다. 이러한 마이그레이션 작업은 마이그레이션 날짜를 기준으로 순서대로 실행된다.

`db:migrate` 명령을 실행하면 `db:schema:dump` 명령이 호출되어 데이터베이스의 구조와 일치하도록 `db/schema.rb` 파일이 업데이트된다는 것을 주목한다.

대상 버전을 지정하면 액티브 레코드는 지정된 버전에 도달 할 때까지 필요한 마이그레이션(change, up, down)을 실행한다. 버전은 마이그레이션 파일 이름의 숫자 접두사에 해당한다. 예를 들어, 20080906120000 버전으로 마이그레이션하려면 아래와 같이 실행한다.

```bash
$ rails db:migrate VERSION=20080906120000
```

20080906120000 버전이 현재 버전보다 큰 경우 (즉, 위로 마이그레이션하는 경우) 20080906120000 이하의 모든 마이그레이션에서 `change` (또는 `up`) 메소드를 실행하며 이후 마이그레이션은 실행되지 않는다. 아래쪽으로 마이그레이션하는 경우 20080906120000 이전까지(포함하지 않음)의 모든 마이그레이션에서 `down` 메소드가 실행된다.

### 롤백하기 {#rolling-back}

일반적인 작업으로는 마지막 마이그레이션을 롤백하는 것이다. 예를 들어, 마이그레이션 코딩에 오류가 있어 정정하려는 경우다. 이 경우에는 이전 마이그레이션과 관련된 버전 번호를 추적할 필요없이 아래와 같이 실행할 수 있다.

```bash
$ rails db:rollback
```

이로써 `change` 메소드를 되돌리거나 `down` 메소드를 실행하여 최신 마이그레이션을 롤백한다. 여러 마이그레이션을 취소해야하는 경우는 `STEP` 매개 변수를 사용할 수 있다.

```bash
$ rails db:rollback STEP=3
```

위의 명령은 마지만 3개의 마이그레이션을 되돌릴 것이다.

`db:migrate:redo` 명령은 롤백을 수행 한 후 다시 마이그레이션하기 위한 손쉬운 방법이다. `db:rollback` 명령과 마찬가지로, 하나 이상의 버전으로 되돌아가야 하는 경우 `STEP` 옵션을 사용할 수 있다. 예를 들면 아래와 같다. 

```bash
$ rails db:migrate:redo STEP=3
```

이와 같은 rails 명령은 `db:migrate`로 할 수 있는 모든 작업을 할 수 있다. 마이그레이션할 버전을 명시적으로 지정할 필요가 없기 때문에 더 편리하다.

### 데이터베이스 셋업하기 {#setup-the-database}

`rails db:setup` 명령은 데이터베이스를 생성하고 스키마를 로드한 후 시드(seed) 데이터로 초기화 한다.

### 데이터베이스 재설정(reset)하기 {#resetting-the-database}

`rails db:reset` 명령은 데이터베이스를 삭제하고 다시 셋업한다. 이것은 `rails db:drop db:setup`과 기능상 동일하다.

NOTE: 이것은 모든 마이그레이션을 실행하는 것과 다르다. 이 명령은 현재 상태의  `db/schema.rb` 또는 `db/structure.sql` 파일의 내용만 사용한다. 마이그레이션을 롤백 할 수 없으면 `rails db:reset`이 도움이 되지 않을 수 있다. 스키마 덤프에 대한 자세한 내용은 [Schema Dumping and You](#schema-dumping-and-you) 섹션을 참조한다.

### 특정 마이그레이션 실행하기 {#running-specific-migrations}

특정 마이그레이션 up 또는 down을 실행해야 하는 경우 `db:migrate:up` 및 `db:migrate:down` 명령을 사용한다. 적절한 버전을 지정하면 해당 마이그레이션에 `change`,`up` 또는 `down` 메소드가 호출된다. 예를 들면 아래와 같다.

```bash
$ rails db:migrate:up VERSION=20080906120000
```

위의 명령을 실행하면 `change` 메소드 (또는 `up` 메소드)를 실행하여 20080906120000 마이그레이션을 실행할 것이다. 이 명령은 먼저 마이그레이션이 이미 수행되었는지 확인하고 액티브 레코드가 이미 실행 된 것으로 판단되면 아무 작업도 수행하지 않는다.

### 환경별로 마이그레이션 실행하기 {#running-migrations-in-different-environments}

기본적으로 `rails db:migrate`를 실행하면 `development` 환경에서 실행된다. 다른 환경에 대해 마이그레이션을 실행하려면 명령을 실행하는 동안`RAILS_ENV` 환경 변수를 사용하여 마이그레이션을 지정할 수 있다. 예를 들어`test` 환경에 대해 마이그레이션을 실행하려면 아래와 같이 실행할 수 있다.

```bash
$ rails db:migrate RAILS_ENV=test
```

### 마이그레이션 실행 결과 변경하기 {#changing-the-output-of-running-migrations}

기본적으로 마이그레이션은 수행 중인 작업과 소요 시간을 정확하게 알려 준다. 테이블을 작성하고 인덱스를 추가하는 마이그레이션은 아래와 같은 결과를 생성할 수 있다.

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

이 모든 것을 제어 할 수 있는 몇 가지 메소드를 마이그레이션에서 사용할 수 있다.

| Method            | Purpose                                                                                                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| suppress_messages | 블록을 인수로 사용하고 블록에서 생성 된 출력을 보이지 않도록 한다.                                                           |
| say               | 메시지 인수를 받아서 그대로 출력한다. 들여 쓰기 여부를 지정하기 위해 두 번째 논리값 인수를 전달할 수 있다.              |
| say_with_time     | 블록을 실행하는 데 걸린 시간과 함께 텍스트를 출력한다. 블록이 정수를 반환하면 영향을 받는 레코드 갯수로 가정한다. |

예를 들어, 아래의 마이그레이션 작업은 

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

아래와 같은 결과를 보일 것이다.

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

액티브 레코드가 아무 것도 출력하지 않게 하려면, `rails db:migrate VERBOSE=false`를 실행하면 모든 출력이 보이지 않게 된다.

## 기존 마이그레이션 변경하기 {#changing-existing-migrations}

때때로 마이그레이션을 작성할 때 실수를 할 수 있다. 이미 마이그레이션을 실행했다면, 마이그레이션을 편집하고 마이그레이션을 다시 실행할 수 없다. 레일스는 마이그레이션이 이미 실행 된 것으로 생각하고 `rails db:migrate`를 실행할 때 아무런 작업도 하지 않는다. 마이그레이션을 롤백 (예 : `rails db:rollback`)하고 마이그레이션을 편집한 다음 `rails db:migrate`를 실행하여 수정된 버전을 실행한다.

일반적으로 기존 마이그레이션을 변경하는 것은 좋지 않다. 기존 버전의 마이그레이션이 이미 운영 시스템에서 실행된 경우 자신과 동료를 위해 추가 작업을 작성하면 심각한 문제를 유발할 수 있다. 대신 필요한 작업을 변경하는 새 마이그레이션을 작성해야 한다. 아직 소스 컨트롤(SCM)(또는 일반적으로 개발 시스템을 넘어 전파되지 않은 경우)에 커밋하지 않은 새로 생성된 마이그레이션을 편집하는 것은 상대적으로 무해하다.

`revert` 메소드는 이전 마이그레이션 전체 또는 일부를 취소하기 위해 새 마이그레이션을 작성할 때 유용 할 수 있다(위의 [Reverting Previous Migrations](#reverting-previous-migrations) 참조).

## 스키마 덤핑과 개발자 {#schema-dumping-and-you}

### 스키마 파일의 목적 {#what-are-schema-files-for?}

마이그레이션이 강력하기는 하지만 데이터베이스 스키마의 신뢰할 수 있는 소스가 될 수는 없다. 데이터베이스는 신뢰할 수 있는 소스로서의 역할을 한다. 기본적으로 레일스는 데이터베이스 스키마의 현재 상태를 그대로 가져오는 `db/schema.rb`를 생성한다.

전체 마이그레이션 히스토리를 재생하는 것보다 `rails db:schema:load`를 통해 스키마 파일을 로드하여 애플리케이션 데이터베이스의 새 인스턴스를 작성하는 것이 더 빠르고 오류가 적은 경향이 있다. 변경될 수 있는 외부 의존성을 마이그레이션에서 사용하거나 마이그레이션과 별개로 발전되는 응용 프로그램 코드에 의존하는 경우 [이전의 오래된 마이그레이션](#old-migrations)은 올바르게 적용되지 않을 수 있다.

스키마 파일은 액티브 레코드 객체의 속성을 빠르게 보고자 할 때도 유용하다. 이 정보는 모델 코드에 포함되어 있지 않고 여러 마이그레이션에 걸쳐 흩어져 있지만 스키마 파일에 잘 요약되어 있다.

### 스키마 덤프의 형식 {#types-of-schema-dumps}

레일스가 생성한 스키마 덤프의 형식은 `config/application.rb`의`config.active_record.schema_format` 설정에 의해 조절된다. 기본적으로 형식은 `: ruby`이지만 `: sql`로 설정할 수도 있다.

`:ruby`를 선택하면 스키마는 `db/schema.rb`에 저장된다. 이 파일을 보면 매우 큰 마이그레이션 코드와 매우 흡사하다는 것을 알 수 있다.

```ruby
ActiveRecord::Schema.define(version: 2008_09_06_171750) do
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

여러면에서 이것은 바로 현재 상태 그대로를 반영하는 것이다. 이 파일은 데이터베이스를 조사한 후 `create_table`, `add_index` 등을 사용하여 구조를 표현함으로써 작성된다.

`db/schema.rb`는 트리거, 시퀀스, 저장 프로시저, check 제약 조건 등과 같은 데이터베이스가 지원할 수 있는 모든 것을 표현할 수 없다. 마이그레이션시`execute`를 사용하여 루비 마이그레이션 DSL에서 지원하지 않는 데이터베이스 구조를 작성할 수 있지만, 스키마 덤퍼가 구문을 재구성하지 못할 수 있다. 이와 같은 기능을 사용하는 경우 새 데이터베이스 인스턴스를 만드는 데 유용한 정확한 스키마 파일을 얻으려면 스키마 형식을 `: sql`로 설정해야 한다.

스키마 형식이 `: sql`로 설정되면 해당 데이터베이스에서 제공하는 도구를 사용하여 데이터베이스 구조가 `db/structure.sql`로 덤프된다. 예를 들어 PostgreSQL의 경우`pg_dump` 유틸리티가 사용된다. MySQL과 MariaDB의 경우, 이 파일에는 다양한 테이블에 대한 `SHOW CREATE TABLE`의 출력이 포함될 것이다.

`db/structure.sql`에서 스키마를 로드하려면 `rails db:structure:load`를 실행한다. 파일에 포함된 SQL 문을 실행하여 이 파일이 로드된다. 정의에 따라 데이터베이스 구조의 완벽한 복사본이 만들어진다.

### 스키마 덤프와 소스 컨트롤 {#schema-dumps-and-source-control}

스키마 파일은 일반적으로 새 데이터베이스를 생성하는데 사용되므로 스키마 파일을 소스 컨트롤 하에 두는 것이 좋다.

두 개의 브랜치에서 각각 스키마를 수정한 후 머지할 경우 스키마 파일에서 병합 충돌이 발생할 수 있다. 이러한 충돌을 해결하려면 `rails db:migrate`를 실행하여 스키마 파일을 재생성하면 된다.

## 액티브 레코드와 참조 무결성 {#active-record-and-referential-integrity}

액티브 레코드 방식에서는 논리적인 작업이 데이터베이스가 아닌 모델에 속한다고 주장한다. 따라서 일부 논리적인 작업을 데이터베이스로 가져오는 트리거 또는 제약 조건과 같은 기능은 그리 많이 사용되지는 않는다.

`validates :foreign_key, uniqueness: true`와 같은 데이터 유효성 검증은 모델이 데이터 무결성을 강화할 수 있는 한 가지 방법이다. 관계 설정시 `:dependent` 옵션은 모델이 부모가 삭제될 때 자식 객체를 자동으로 삭제하도록 한다. 애플리케이션 수준에서 작동하는 것과 마찬가지로 이것도 참조 무결성을 보장할 수 없으므로 일부 사람들은 데이터베이스의 [foreign key constraints](#foreign-keys)로 기능을 보강한다.

액티브 레코드는 이러한 기능을 직접 사용하기 위한 모든 도구를 제공하지는 않지만 `execute` 메소드를 사용하여 임의의 SQL을 실행할 수 있다.

## 마이그레이션과 시드 데이터 {#migrations-and-seed-data}

레일스의 마이그레이션 기능의 주요 목적은 일관된 프로세스를 사용하여 스키마를 수정하는 명령을 실행하는 것이다. 마이그레이션을 사용하여 데이터를 추가하거나 수정할 수도 있다. 이것은 운영 데이터베이스와 같이 파괴하거나 다시 만들 수 없는 기존 데이터베이스에 유용하다.

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

데이터베이스 생성 후 초기 데이터를 추가하기 위해 레일스에는 프로세스를 빠르고 쉽게 만드는 '시드(seed)' 기능이 내장되어 있다. 개발 및 테스트 환경에서 데이터베이스를 자주 다시 로드 할 때 특히 유용하다. 이 기능을 시작하는 것은 쉽다. 즉, 루비 코드로 `db/seeds.rb` 파일을 채우고 `rails db:seed` 명령을 실행하면된다.

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

This is generally a much cleaner way to set up the database of a blank application.

## 과거 마이그레이션 {#old-migrations}

`db/schema.rb` 또는 `db/structure.sql`은 데이터베이스의 현재 상태에 대한 스냅 샷이며 해당 데이터베이스를 재구축하기 위한 신뢰할 수 있는 소스이다. 과거 마이그레이션 파일을 삭제하는 것이 가능하다. 

`db/migrate/` 디렉토리에서 마이그레이션 파일을 삭제하면, 해당 파일이 존재하는 상태에서 `rails db:migrate`가 실행되었던 환경에는 내부 레일스 데이터베이스 테이블(`schema_migrations`) 내부에 해당 마이그레이션의 타임스탬프 참조가 포함된다. 이 테이블은 특정 환경에서 마이그레이션이 실행되었는지 여부를 추적하는 데 사용된다.

각 마이그레이션의 상태 (up 또는 down)를 표시하는 `rails db:migrate :status` 명령을 실행하면, 특정 환경에서 한 번 실행 되었지만 더 이상 `db/migrate/` 디렉토리에서 찾을 수 없는 삭제된 마이그레이션 파일 옆에 `********** NO FILE **********`이 표시된다.
