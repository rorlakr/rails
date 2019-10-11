# 액티브 레코드 마이그레이션 {#active-record-migrations}

마이그레이션은 시간이 지남에 따라 데이터베이스 스키마를 발전시킬 수있는 액티브 레코드의 특수한 기능이다. 순수 SQL로 스키마 수정을 작성하는 대신 마이그레이션을 통해 쉬운 루비 DSL을 사용하여 테이블의 변경 사항을 기술할 수 있다.

이 가이드를 읽은 후에는 아래의 내용을 알게 될 것이다.

- 마이그레이션을 생성할 때 사용하는 생성자
- 데이터베이스를 다루기 위해서 액티브 레코드가 제공하는 메소드
- 마이그레이션과 스키마를 다루는 레일스 명령어
- 마이그레이션이 `schema.rb`와 연관되는 방법

---

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

물론 타임 스탬프 계산은 재미있는 작업이 아니기 때문에 액티브 레코드에서는 ㅇ아래와 같은 작업을 처리 할 수 있는 생성자를 제공한다.

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

필수 사항은 아니지만, [guarantee referential integrity](#active-record-and-reference-integrity)에 외래키 제약 조건을 추가할 수 있다.

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

If you're going to need to use any other methods, you should use `reversible`
or write the `up` and `down` methods instead of using the `change` method.

### Using `reversible`

Complex migrations may require processing that Active Record doesn't know how
to reverse. You can use `reversible` to specify what to do when running a
migration and what else to do when reverting it. For example:

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

Using `reversible` will ensure that the instructions are executed in the
right order too. If the previous example migration is reverted,
the `down` block will be run after the `home_page_url` column is removed and
right before the table `distributors` is dropped.

Sometimes your migration will do something which is just plain irreversible; for
example, it might destroy some data. In such cases, you can raise
`ActiveRecord::IrreversibleMigration` in your `down` block. If someone tries
to revert your migration, an error message will be displayed saying that it
can't be done.

### Using the `up`/`down` Methods

You can also use the old style of migration using `up` and `down` methods
instead of the `change` method.
The `up` method should describe the transformation you'd like to make to your
schema, and the `down` method of your migration should revert the
transformations done by the `up` method. In other words, the database schema
should be unchanged if you do an `up` followed by a `down`. For example, if you
create a table in the `up` method, you should drop it in the `down` method. It
is wise to perform the transformations in precisely the reverse order they were
made in the `up` method. The example in the `reversible` section is equivalent to:

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

If your migration is irreversible, you should raise
`ActiveRecord::IrreversibleMigration` from your `down` method. If someone tries
to revert your migration, an error message will be displayed saying that it
can't be done.

### Reverting Previous Migrations

You can use Active Record's ability to rollback migrations using the `revert` method:

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

The `revert` method also accepts a block of instructions to reverse.
This could be useful to revert selected parts of previous migrations.
For example, let's imagine that `ExampleMigration` is committed and it
is later decided it would be best to use Active Record validations,
in place of the `CHECK` constraint, to verify the zipcode.

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

The same migration could also have been written without using `revert`
but this would have involved a few more steps: reversing the order
of `create_table` and `reversible`, replacing `create_table`
by `drop_table`, and finally replacing `up` by `down` and vice-versa.
This is all taken care of by `revert`.

NOTE: If you want to add check constraints like in the examples above,
you will have to use `structure.sql` as dump method. See
[Schema Dumping and You](#schema-dumping-and-you).

## Running Migrations

Rails provides a set of rails commands to run certain sets of migrations.

The very first migration related rails command you will use will probably be
`rails db:migrate`. In its most basic form it just runs the `change` or `up`
method for all the migrations that have not yet been run. If there are
no such migrations, it exits. It will run these migrations in order based
on the date of the migration.

Note that running the `db:migrate` command also invokes the `db:schema:dump` command, which
will update your `db/schema.rb` file to match the structure of your database.

If you specify a target version, Active Record will run the required migrations
(change, up, down) until it has reached the specified version. The version
is the numerical prefix on the migration's filename. For example, to migrate
to version 20080906120000 run:

```bash
$ rails db:migrate VERSION=20080906120000
```

If version 20080906120000 is greater than the current version (i.e., it is
migrating upwards), this will run the `change` (or `up`) method
on all migrations up to and
including 20080906120000, and will not execute any later migrations. If
migrating downwards, this will run the `down` method on all the migrations
down to, but not including, 20080906120000.

### Rolling Back

A common task is to rollback the last migration. For example, if you made a
mistake in it and wish to correct it. Rather than tracking down the version
number associated with the previous migration you can run:

```bash
$ rails db:rollback
```

This will rollback the latest migration, either by reverting the `change`
method or by running the `down` method. If you need to undo
several migrations you can provide a `STEP` parameter:

```bash
$ rails db:rollback STEP=3
```

will revert the last 3 migrations.

The `db:migrate:redo` command is a shortcut for doing a rollback and then migrating
back up again. As with the `db:rollback` command, you can use the `STEP` parameter
if you need to go more than one version back, for example:

```bash
$ rails db:migrate:redo STEP=3
```

Neither of these rails commands do anything you could not do with `db:migrate`. They
are simply more convenient, since you do not need to explicitly specify the
version to migrate to.

### Setup the Database

The `rails db:setup` command will create the database, load the schema, and initialize
it with the seed data.

### Resetting the Database

The `rails db:reset` command will drop the database and set it up again. This is
functionally equivalent to `rails db:drop db:setup`.

NOTE: This is not the same as running all the migrations. It will only use the
contents of the current `db/schema.rb` or `db/structure.sql` file. If a migration can't be rolled back,
`rails db:reset` may not help you. To find out more about dumping the schema see
[Schema Dumping and You](#schema-dumping-and-you) section.

### Running Specific Migrations

If you need to run a specific migration up or down, the `db:migrate:up` and
`db:migrate:down` commands will do that. Just specify the appropriate version and
the corresponding migration will have its `change`, `up` or `down` method
invoked, for example:

```bash
$ rails db:migrate:up VERSION=20080906120000
```

will run the 20080906120000 migration by running the `change` method (or the
`up` method). This command will
first check whether the migration is already performed and will do nothing if
Active Record believes that it has already been run.

### Running Migrations in Different Environments

By default running `rails db:migrate` will run in the `development` environment.
To run migrations against another environment you can specify it using the
`RAILS_ENV` environment variable while running the command. For example to run
migrations against the `test` environment you could run:

```bash
$ rails db:migrate RAILS_ENV=test
```

### Changing the Output of Running Migrations

By default migrations tell you exactly what they're doing and how long it took.
A migration creating a table and adding an index might produce output like this

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Several methods are provided in migrations that allow you to control all this:

| Method            | Purpose                                                                                                                                  |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| suppress_messages | Takes a block as an argument and suppresses any output generated by the block.                                                           |
| say               | Takes a message argument and outputs it as is. A second boolean argument can be passed to specify whether to indent or not.              |
| say_with_time     | Outputs text along with how long it took to run its block. If the block returns an integer it assumes it is the number of rows affected. |

For example, this migration:

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

generates the following output

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

If you want Active Record to not output anything, then running `rails db:migrate VERBOSE=false` will suppress all output.

## Changing Existing Migrations

Occasionally you will make a mistake when writing a migration. If you have
already run the migration, then you cannot just edit the migration and run the
migration again: Rails thinks it has already run the migration and so will do
nothing when you run `rails db:migrate`. You must rollback the migration (for
example with `rails db:rollback`), edit your migration, and then run
`rails db:migrate` to run the corrected version.

In general, editing existing migrations is not a good idea. You will be
creating extra work for yourself and your co-workers and cause major headaches
if the existing version of the migration has already been run on production
machines. Instead, you should write a new migration that performs the changes
you require. Editing a freshly generated migration that has not yet been
committed to source control (or, more generally, which has not been propagated
beyond your development machine) is relatively harmless.

The `revert` method can be helpful when writing a new migration to undo
previous migrations in whole or in part
(see [Reverting Previous Migrations](#reverting-previous-migrations) above).

## Schema Dumping and You

### What are Schema Files for?

Migrations, mighty as they may be, are not the authoritative source for your
database schema. Your database remains the authoritative source. By default,
Rails generates `db/schema.rb` which attempts to capture the current state of
your database schema.

It tends to be faster and less error prone to create a new instance of your
application's database by loading the schema file via `rails db:schema:load`
than it is to replay the entire migration history.
[Old migrations](#old-migrations) may fail to apply correctly if those
migrations use changing external dependencies or rely on application code which
evolves separately from your migrations.

Schema files are also useful if you want a quick look at what attributes an
Active Record object has. This information is not in the model's code and is
frequently spread across several migrations, but the information is nicely
summed up in the schema file.

### Types of Schema Dumps

The format of the schema dump generated by Rails is controlled by the
`config.active_record.schema_format` setting in `config/application.rb`. By
default, the format is `:ruby`, but can also be set to `:sql`.

If `:ruby` is selected, then the schema is stored in `db/schema.rb`. If you look
at this file you'll find that it looks an awful lot like one very big migration:

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

In many ways this is exactly what it is. This file is created by inspecting the
database and expressing its structure using `create_table`, `add_index`, and so
on.

`db/schema.rb` cannot express everything your database may support such as
triggers, sequences, stored procedures, check constraints, etc. While migrations
may use `execute` to create database constructs that are not supported by the
Ruby migration DSL, these constructs may not be able to be reconstituted by the
schema dumper. If you are using features like these, you should set the schema
format to `:sql` in order to get an accurate schema file that is useful to
create new database instances.

When the schema format is set to `:sql`, the database structure will be dumped
using a tool specific to the database into `db/structure.sql`. For example, for
PostgreSQL, the `pg_dump` utility is used. For MySQL and MariaDB, this file will
contain the output of `SHOW CREATE TABLE` for the various tables.

To load the schema from `db/structure.sql`, run `rails db:structure:load`.
Loading this file is done by executing the SQL statements it contains. By
definition, this will create a perfect copy of the database's structure.

### Schema Dumps and Source Control

Because schema files are commonly used to create new databases, it is strongly
recommended that you check your schema file into source control.

Merge conflicts can occur in your schema file when two branches modify schema.
To resolve these conflicts run `rails db:migrate` to regenerate the schema file.

## Active Record and Referential Integrity

The Active Record way claims that intelligence belongs in your models, not in
the database. As such, features such as triggers or constraints,
which push some of that intelligence back into the database, are not heavily
used.

Validations such as `validates :foreign_key, uniqueness: true` are one way in
which models can enforce data integrity. The `:dependent` option on
associations allows models to automatically destroy child objects when the
parent is destroyed. Like anything which operates at the application level,
these cannot guarantee referential integrity and so some people augment them
with [foreign key constraints](#foreign-keys) in the database.

Although Active Record does not provide all the tools for working directly with
such features, the `execute` method can be used to execute arbitrary SQL.

## Migrations and Seed Data

The main purpose of Rails' migration feature is to issue commands that modify the
schema using a consistent process. Migrations can also be used
to add or modify data. This is useful in an existing database that can't be destroyed
and recreated, such as a production database.

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

To add initial data after a database is created, Rails has a built-in
'seeds' feature that makes the process quick and easy. This is especially
useful when reloading the database frequently in development and test environments.
It's easy to get started with this feature: just fill up `db/seeds.rb` with some
Ruby code, and run `rails db:seed`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

This is generally a much cleaner way to set up the database of a blank
application.

## Old Migrations

The `db/schema.rb` or `db/structure.sql` is a snapshot of the current state of your
database and is the authoritative source for rebuilding that database. This
makes it possible to delete old migration files.

When you delete migration files in the `db/migrate/` directory, any environment
where `rails db:migrate` was run when those files still existed will hold a reference
to the migration timestamp specific to them inside an internal Rails database
table named `schema_migrations`. This table is used to keep track of whether
migrations have been executed in a specific environment.

If you run the `rails db:migrate:status` command, which displays the status
(up or down) of each migration, you should see `********** NO FILE **********`
displayed next to any deleted migration file which was once executed on a
specific environment but can no longer be found in the `db/migrate/` directory.
