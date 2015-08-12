
Active Record Query Interface
=============================

이 가이드에서는 Active Record를 사용해 데이터베이스에서 데이터를 가져오기 위한 방법을 설명합니다.

이 가이드의 내용:

* 다양한 메소드와 조건을 사용하여 레코드를 검색하기
* 검색된 레코드의 순서, 가져오고 싶은 속성, 그룹 등을 설정하기
* eager loading을 사용해서 데이터를 가져올 때 필요한 쿼리 실행횟수를 줄이기
* 동적 검색 메소드를 사용하기
* 어떤 레코드가 존재하는지 확인하기
* Active Record 모델에서 계산하기
* EXPLAIN 사용하기

--------------------------------------------------------------------------------

SQL을 사용해서 데이터베이스의 레코드를 검색하는 것에 익숙해진 사람이 Rails를 배우게 되면, 같은 작업을 무척 세련된 방식으로 실현한다는 점을 느낄 수 있을 겁니다. Active Record를 사용하게 되면 SQL을 직접 실행할 필요가 거의 없어집니다.

이 가이드의 예제에서는 아래의 모델을 사용합니다.

TIP: 따로 표기하지 않는 이상 모델의 `id`는 기본키를 가리킵니다.

```ruby
class Client < ActiveRecord::Base
  has_one :address
  has_many :orders
  has_and_belongs_to_many :roles
end
```

```ruby
class Address < ActiveRecord::Base
  belongs_to :client
end
```

```ruby
class Order < ActiveRecord::Base
  belongs_to :client, counter_cache: true
end
```

```ruby
class Role < ActiveRecord::Base
  has_and_belongs_to_many :clients
end
```

Active Record는 사용자를 대신해서 데이터베이스에 대한 쿼리를 전송합니다. 전송되는 쿼리는 많은 데이터베이스 시스템(MySQL, PostgreSQL, SQLite 등)과 호환성이 있습니다. Active Record를 이용하면, 사용하고 있는 데이터베이스 시스템의 종류에 관계 없이 같은 방식을 쓸 수 있습니다.

데이터베이스에서 객체 가져오기
------------------------------------

Active Record에서는 데이터베이스에서 객체를 가져오기 위해 다양한 검색 메소드를 제공하고 있습니다. 이러한 검색 메소드를 사용해서 SQL을 직접 작성할 필요 없이 데이터베이스에 전송할 쿼리를 만들 수 있습니다.

Active Record에서는 아래의 메소드를 지원합니다.

* `bind`
* `create_with`
* `distinct`
* `eager_load`
* `extending`
* `from`
* `group`
* `having`
* `includes`
* `joins`
* `limit`
* `lock`
* `none`
* `offset`
* `order`
* `preload`
* `readonly`
* `references`
* `reorder`
* `reverse_order`
* `select`
* `uniq`
* `where`

위의 메소드는 전부 `ActiveRecord::Relation` 인스턴스를 반환합니다.

`Model.find(options)`의 동작을 간단하게 요약해보면 아래와 같습니다.

* 주어진 옵션을 등가의 SQL 쿼리로 변환합니다.
* SQL 쿼리를 실행하고, 결과를 데이터베이스에서 가져옵니다.
* 가져온 결과를 레코드들을 각각 동등한 Ruby 객체로 변환합니다.
* 필요하다면 `after_find` 콜백을 실행합니다.

### 단일 객체를 가져오기

Active Record에는 하나의 객체를 가져오기 위한 여러가지 방법이 준비되어 있습니다.

#### 기본키를 사용하기

`Model.find(primary_key)`를 사용하면 주어진 조건에 맞는 _기본키_를 가지는 객체를 가져올 수 있습니다.

```ruby
# Find the client with primary key (id) 10.
client = Client.find(10)
# => #<Client id: 10, first_name: "Ryan">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients WHERE (clients.id = 10) LIMIT 1
```

`Model.find(primary_key)`에서 적당한 레코드를 발견하지 못했을 경우 `ActiveRecord::RecordNotFound` 예외가 발생합니다.

#### `take`

`Model.take`는 레코드를 하나 가져옵니다. 어떤 레코드를 가져올지는 지정하지 않습니다.

```ruby
client = Client.take
# => #<Client id: 1, first_name: "Lifo">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients LIMIT 1
```

모델에 레코드가 하나도 없는 경우에는 `nil`을 반환합니다. 이 때, 예외는 발생하지 않습니다.

TIP: 이 메소드가 어떤 레코드를 돌려줄지는 사용하는 데이터베이스 엔진에 따라 다를 수 있습니다.

#### `first`

`Model.first`는 기본키로 오름차순을 하고, 첫번째 레코드를 가져옵니다.

```ruby
client = Client.first
# => #<Client id: 1, first_name: "Lifo">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql 
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

모델에 레코드가 하나도 없는 경우에는 `nil`을 반환합니다. 이 때, 예외는 발생하지 않습니다.

#### `last`

`Model.last`는 기본키로 내림차순을 하고, 첫번째 레코드를 가져옵니다.

```ruby
client = Client.last
# => #<Client id: 221, first_name: "Russel">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

모델에 레코드가 하나도 없는 경우에는 `nil`을 반환합니다. 이 때, 예외는 발생하지 않습니다.

#### `find_by`

`Model.find_by`는 주어진 조건에 맞는 레코드 중 첫번째를 반환합니다.

```ruby
Client.find_by first_name: 'Lifo'
# => #<Client id: 1, first_name: "Lifo">

Client.find_by first_name: 'Jon'
# => nil
```

위의 명령은 아래와 같이 작성할 수도 있습니다.

```ruby
Client.where(first_name: 'Lifo').take
```

#### `take!`

`Model.take!`는 레코드를 하나 가져옵니다.

```ruby
client = Client.take!
# => #<Client id: 1, first_name: "Lifo">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients LIMIT 1
```

`Model.take!`에서 적당한 레코드를 발견하지 못한 경우, `ActiveRecord::RecordNotFound` 예외가 발생합니다.

#### `first!`

`Model.first!`는 기본키로 오름차순을 하고, 첫번째 레코드를 가져옵니다.

```ruby
client = Client.first!
# => #<Client id: 1, first_name: "Lifo">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql 
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

`Model.first!`에서 적당한 레코드를 발견하지 못한 경우, `ActiveRecord::RecordNotFound` 예외가 발생합니다.

#### `last!`

`Model.last!`는 기본키로 내림차순을 하고, 첫번째 레코드를 가져옵니다.

```ruby
client = Client.last!
# => #<Client id: 221, first_name: "Russel">
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

`Model.last!`에서 적당한 레코드를 발견하지 못한 경우, `ActiveRecord::RecordNotFound` 예외가 발생합니다.

#### `find_by!`

`Model.find_by!`는 주어진 조건에 맞는 레코드 중 첫번째를 반환합니다. 적당한 레코드를 발견하지 못한 경우 `ActiveRecord::RecordNotFound` 예외가 발생합니다.

```ruby
Client.find_by! first_name: 'Lifo'
# => #<Client id: 1, first_name: "Lifo">

Client.find_by! first_name: 'Jon'
# => ActiveRecord::RecordNotFound
```

위의 명령은 아래와 같은 방식으로도 표현할 수 있습니다.

```ruby
Client.where(first_name: 'Lifo').take! 
```

### 여러 개의 객체를 가져오기

#### 여럭 개의 기본키를 사용하기

`Model.find()`는 _기본키_의 배열을 받아서 주어진 _기본키_를 가지는 레코드들의 배열을 돌려줍니다.

```ruby
# Find the clients with primary keys 1 and 10.
client = Client.find([1, 10]) # Or even Client.find(1, 10)
# => [#<Client id: 1, first_name: "Lifo">, #<Client id: 10, first_name: "Ryan">]
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients WHERE (clients.id IN (1,10))
```

WARNING: `Model.find(array_of_primary_key)`는 주어진 기본키 중 하나라도 일치하는 레코드를 발견하지 못하면 `ActiveRecord::RecordNotFound` 예외를 발생시킵니다.

#### take

`Model.take(limit)`는 `limit`에 지정된 갯수만큼의 레코드를 반환합니다. 꺼내는 순서는 지정하지 않습니다.

```ruby
Client.take(2)
# => [#<Client id: 1, first_name: "Lifo">,
      #<Client id: 2, first_name: "Raf">]
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients LIMIT 2
```

#### first

`Model.first(limit)`는 기본키를 오름차순으로 `limit`에서 지정된 갯수만큼의 레코드를 반환합니다.

```ruby
Client.first(2)
# => [#<Client id: 1, first_name: "Lifo">,
      #<Client id: 2, first_name: "Raf">]
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients ORDER BY id ASC LIMIT 2
```

#### last

`Model.last(limit)`는 기본키를 내림차순으로 `limit`에서 지정된 갯수만큼의 레코드를 반환합니다.

```ruby
Client.last(2)
# => [#<Client id: 10, first_name: "Ryan">,
      #<Client id: 9, first_name: "John">]
```

이것과 등가인 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients ORDER BY id DESC LIMIT 2
```

### 여러 개의 객체를 배치로 가져오기

다수의 레코드를 반복 처리 하고 싶은 경우가 있습니다. 예를 들어 많은 유저들에게 뉴스레터를 전송하고 싶거나, 데이터를 내보내거나, 하는 경우입니다.

이런 처리를 그대로 구현한다고 하면 아래와 같이 될 겁니다.

```ruby
# 이러한 처리를 수천 건의 레코드에 대해서 실행하게 되면, 효율이 매우 떨어집니다.
User.all.each do |user|
  NewsLetter.weekly_deliver(user)
end
```

그러나 위와 같은 처리는 테이블의 크기가 커질수록 현실적이지 않은 코드가 됩니다. `User.all.each`는 Active Record에 대해서 _테이블 전체_를 한번에 꺼내오고, 심지어 매 레코드마다 객체를 생성한 뒤, 그 객체들이 저장된 배열을 메모리에 보관하기 때문입니다. 만약 막대한 양의 레코드에 대해서 이러한 작업을 하려고 하면 코드는 메모리의 용량 부족으로 제대로 동작하지 않을 것입니다.

Rails에서는 이러한 작업을 메모리를 압박하지 않는 크기의 배치 작업으로 분할해서 처리하는 방법을 2가지 제공하고 있습니다. 첫번째는 `find_each` 메소드를 사용하는 방법입니다. 이것은 레코드 뭉치를 하나씩 꺼내서 _각_ 레코드를 하나의 모델로 생성하고 넘긴 블록을 yield 합니다. 두번째 방법은 `find_in_batches` 메소드를 사용하는 방법입니다. 레코드 뭉치를 하나씩 꺼내서 _배치 전체_를 모델 배열로 만들어서 블록에 yield합니다.

TIP: `find_each` 메소드와 `find_in_batches` 메소드는 한번에 메모리에 올릴 수 없을 정도의 대량의 레코드를 순차 처리하기 위한 방법입니다. 수천개의 레코드에 대해서 단순한 반복 처리를 하는 경우라면 기존의 검색 메소드로도 충분합니다.

#### `find_each`

`find_each` 메소드는 레코드 뭉치를 하나 꺼내서, _각_ 레코드를 하나씩 객체로 만들어 개별적으로 블록의 yield를 호출합니다. 아래의 예제에서는 `find_each`에서 1000건의 레코드를 꺼냅니다. 이 숫자는 `find_each`와 `find_in_batches`에서 기본적으로 사용되는 값이며, 이어서 각 모델에 대해서 개별적으로 yield를 호출합니다. 이 작업은 모든 레코드가 처리될 때까지 반복됩니다.

```ruby
User.find_each do |user|
  NewsLetter.weekly_deliver(user)
end
```

##### `find_each`의 옵션

`find_each`는 기존의 `find` 메소드와 같은 옵션을 사용할 수 있습니다. 단, `:order`의 `:limit`는 `find_each` 내부에서 쓰기 위해서 예약되어 있으므로 사용할 수 없습니다.

기존의 옵션 이외에도 `:batch_size`와 `:start`도 사용할 수 있습니다.

**`:batch_size`**

`:batch_size` 옵션은 (블록에 개별적으로 넘겨지기 전에) 레코드 뭉치를 가져올 때에 몇 개를 가져올지를 지정합니다. 예를 들어서 매번 5000건씩을 처리하고 싶은 경우, 아래와 같이 하면 됩니다.

```ruby
User.find_each(batch_size: 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
```

**`:start`**

기본적으로 레코드는 기본키의 오름차순대로 가져오게 됩니다. 기본키는 정수이어야 합니다. 시작 시점의 몇몇 ID가 필요하지 않은 경우 `:start`를 사용해서 시퀀스의 시작 ID를 지정할 수 있습니다. 이 옵션은 중단된 배치작업을 재개하는 경우 등에 유용합니다.

예를 들어 1회의 작업에서 5000건을 가져오고, 기본키가 2000 이상인 사용자들에게만 뉴스 레터를 보내고 싶은 경우, 다음과 같이 작성합니다.

```ruby
User.find_each(start: 2000, batch_size: 5000) do |user|
  NewsLetter.weekly_deliver(user)
end
```

이외에도 같은 처리를 여러 곳에서 분산해서 작업하는 경우를 생각할 수 있습니다. `start` 옵션을 적절하게 사용해서, 각 처리 장소에서 10000개의 레코드씩을 처리하도록 만들 수도 있을겁니다.

#### `find_in_batches`

`find_in_batches` 메소드는 레코드를 뭉치로 꺼내는 점은 `find_each`와 닮아 있습니다. 다른 점은 `find_in_batches`는 _뭉치_에서 모델을 각각 꺼내서 처리하는 것이 아닌 모델의 배열로서 블록을 yield한다는 점입니다. 아래의 예제에서는 주어진 블록에 대해서 한번에 1000개의 인보이스 배열을 yield합니다. 마지막의 배열에서는 1000건씩 처리하고 남은 인보이스가 포함됩니다.

```ruby
# 1회에 add_invoices에 인보이스가 1000건이 들어있는 배열을 넘긴다.
Invoice.find_in_batches(include: :invoice_lines) do |invoices|
  export.add_invoices(invoices)
end
```

NOTE: `:include` 옵션을 사용하면 모델과 함께 가져올 관계 모델을 지정할 수 있습니다.

##### `find_in_batches`의 옵션

`find_in_batches`에서는 `find_each`과 마찬가지로 기존의 `find` 메소드에서 사용하던 옵션에 `:batch_size`나 `:start` 옵션을 사용할 수 있습니다. `:order`와 `:limit`는 `find_in_batches` 내부에서 사용하기 위해 예약되어있으므로 사용할 수 없습니다.

조건
----------

`where`는 반환되는 레코드를 필터링하기 위한 조건을 지정합니다. SQL문에서의 `WHERE`의 부분에 해당합니다. 조건은 문자열, 배열, 해시 중의 하나를 이용해서 지정할 수 있습니다.

### 문자열만을 사용하기

검색 메소드에 조건을 추가하고 싶은 경우, 예를 들어, `Client.where("orders_count = '2'")`와 같은 조건을 단순히 지정할 수 있습니다. 이 경우 `orders_count` 필드가 2인 모든 클라이언트를 검색합니다.

WARNING: 조건을 문자열만으로 구성하게 되면 SQL 주입 취약성이 발생할 수 있습니다. 예를 들어, `Client.where("first_name LIKE '%#{params[:first_name]}%'")`와 같은 사용은 위험합니다. 다음에 설명하는 방식을 사용하는 것을 권장합니다.

### 배열을 사용하기

조건에서 사용하는 값이 변경될 가능성이 있는 경우, 인수를 어떻게 넘기면 좋을까요? 이 경우는 아래와 같이 쓸 수 있습니다.

```ruby
Client.where("orders_count = ?", params[:orders])
```

Active Record는 첫번째 인자를 확인하고, 그 뒤에 추가 인자가 있다면, 첫번째 인자에 있는 물음표`(?)`를 추가 인자로 대체합니다.

여러 개의 조건을 지정하고 싶은 경우에는 아래와 같이 쓰면 됩니다.

```ruby
Client.where("orders_count = ? AND locked = ?", params[:orders], false)
```

이 예시에서, 첫번째 물음표는 `params[:orders]`로 대체되고, 두번째 물음표는 `false`를 SQL형식으로 변환된 값(변환 방식은 어댑터마다 다릅니다)으로 대체됩니다.

아래와 같은 작성 방식을 추천합니다.

```ruby
Client.where("orders_count = ?", params[:orders])
```

아래와 같은 방식은 위험하며, 사용하지 않기를 권장합니다.

```ruby
Client.where("orders_count = #{params[:orders]}")
```

조건 문자열에 변수를 직접 대입하면, 그 변수는 데이터베이스에 **그대로** 넘어가게 됩니다. 이것은 악의가 있는 인물이 필터링되지 않은 위험한 변수를 넘길 수 있게 만듭니다. 나아가서 악의가 있는 인물이 데이터베이스를 마음대로 조작할 수 있게 되어 데이터베이스 전체가 위험에 빠질 수도 있습니다. 그러므로 조건문자열에 변수를 그대로 대입하지 말아주세요.

TIP: SQL 주입 취약성에 대해서는 [Rails 보안 가이드](security.html#sqlインジェクション)를 참조해주세요.

#### 플레이스홀더를 사용하기

물음표`(?)`를 인수로 대체하는 것과 마찬가지로, 배열을 통해 키/값 해시를 지정할 수 있습니다.

```ruby
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

조건에 여러개의 변수가 사용되는 경우, 이렇게 작성하면 코드를 읽기 좋게 만들 수 있습니다.

### 해시를 사용하기

Active Record에서는 조건을 해시로 넘길수도 있습니다. 이 방식을 사용하는 것으로 조건부분의 가독성을 향상시킬 수 있습니다. 조건을 해시로 넘기는 경우, 해시의 키에는 조건을 주고 싶은 필드명을, 값에는 그 필드가 어떤 조건을 가지는 지를 지정할 수 있습니다.

NOTE: 해시에 의한 조건은 등가, 범위, 서브셋만 사용할 수 있습니다.

#### 등가 조건

```ruby
Client.where(locked: true)
```

필드명은 문자열을 사용할 수도 있습니다.

```ruby
Client.where('locked' => true)
```

belongs_to 관계의 경우, Active Record 객체가 값으로 사용되고 있다면, 외래키를 모델을 식별하기 위한 용도로 사용할 수 있습니다. 이 방법은 다형 관계에서도 사용할 수 있습니다.

```ruby
Post.where(author: author)
Author.joins(:posts).where(posts: { author: author })
```

NOTE: 값을 심볼로 사용할 수 없습니다. 예를 들어 `Client.where(status: :active)`처럼 작성할 수 없습니다.

#### 범위 조건

```ruby
Client.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

위의 예제에서는 어제 생성된 모든 클라이언트를 검색합니다. 내부에서는 SQL의 `BETWEEN`이 쓰입니다.

```sql
SELECT * FROM clients WHERE (clients.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

[조건에서 배열을 사용하기](#배열을_사용하기)에서 더 간결한 문법을 소개하고 있습니다.

#### 서브셋 조건

SQL의 `IN`을 사용해서 레코드를 검색하고 싶은 경우, 조건 해시에 이를 위한 배열을 하나 넘길 수 있습니다.

```ruby
Client.where(orders_count: [1,3,5])
```

이 코드를 실행하면 아래와 같은 SQL이 생성됩니다.

```sql
SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
```

### NOT 조건

SQL의 `NOT` 쿼리는 `where.not`으로 표현합니다.

```ruby
Post.where.not(author: author)
```

바꿔 말하자면, 이 쿼리는 `where`에 인수를 넘기지 않고 호출한 뒤, 직후에 `where` 조건에 `not`을 넘겨서 체이닝을 하는 것으로 생성됩니다.

순서
--------

데이터베이스에서 가져오는 레코드를 어떤 순서로 정렬하고 싶은 경우, `order`를 사용할 수 있습니다.

예를 들어, 한 덩어리의 레코드를 꺼내서, 그것을 테이블에 있는 `created_at`의 오름차순으로 정렬하고 싶은 경우에는 다음과 같이 쓸 수 있습니다.

```ruby
Client.order(:created_at)
# 또는
Client.order("created_at")
```

`ASC`(오름차순)이나 `DESC`(내림차순)을 지정할 수 있습니다.

```ruby
Client.order(created_at: :desc)
# 또는
Client.order(created_at: :asc)
# 또는
Client.order("created_at DESC")
# 또는
Client.order("created_at ASC")
```

복수의 필드를 지정해서 정렬할 수도 있습니다.

```ruby
Client.order(orders_count: :asc, created_at: :desc)
# 또는
Client.order(:orders_count, created_at: :desc)
# 또는
Client.order("orders_count ASC, created_at DESC")
# 또는
Client.order("orders_count ASC", "created_at DESC")
```

`order` 메소드를 여러번 호출하는 경우, 첫번째 정렬 조건의 뒤에 새로운 조건이 추가됩니다.

```ruby
Client.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM clients ORDER BY orders_count ASC, created_at DESC
```

특정 필드만을 가져오기
-------------------------

기본적으로 `Model.find`를 실행하면 결과에서 모든 필드를 가져옵니다. 내부적으로는 `select *`이 실행됩니다.

결과에서 특정 필드만을 가져오고 싶은 경우, `select` 메소드를 사용할 수 있습니다.

예를 들어 `viewable_by`컬럼과 `locked`컬럼만을 가져오고 싶은 경우, 다음처럼 할 수 있습니다.

```ruby
Client.select("viewable_by, locked")
```

이 명령으로 실행되는 SQL은 다음과 같습니다.

```sql
SELECT viewable_by, locked FROM clients
```

select를 사용하면 선택된 필드만을 사용해서 모델 객체가 초기화되기 때문에 주의해주세요. 모델 객체가 초기화 될 때에 지정하지 않았던 필드로 접근하려고 하면 아래와 같은 메시지가 나타납니다.

```bash
ActiveModel::MissingAttributeError: missing attribute: <속성명> 
```

`<속성명>`은 접근하려고 했던 속성입니다. `id` 메소드는 이 `ActiveRecord::MissingAttributeError`가 발생하지 않습니다. 관계가 정상적으로 동작하기 위해서는 `id` 메소드가 필요하기 때문에, 관계 모델을 사용하는 경우에는 주의해주세요.

특정 필드에 대해서 중복이 없는 레코드만을 가져오고 싶은 경우, `distinct`를 사용할 수 있습니다. 

```ruby
Client.select(:name).distinct
```

이 명령으로 실행되는 SQL은 다음과 같습니다.

```sql
SELECT DISTINCT name FROM clients
```

유일성 제약을 무효화할 수도 있습니다.

```ruby
query = Client.select(:name).distinct
# => 중복이 없는 이름들만이 반환된다

query.distinct(false)
# => 중복에 관계 없이 모든 이름이 반환된다
```

Limit와 Offset
----------------

`Model.find`로 실행되는 SQL에 `LIMIT`를 적용하고 싶은 경우 `limit` 메소드와 `offset` 메소드를 사용하는 것으로 `LIMIT`를 지정할 수 있습니다.

`limit` 메소드는 가져올 레코드 갯수의 상한을 지정합니다. `offset`는 레코드를 반환하기 전에 무시할 레코드의 갯수를 지정합니다.

```ruby
Client.limit(5)
```

위를 실행하면 클라이언트가 최대 5개 반환됩니다. 오프셋은 지정하지 않았으므로 테이블에서 처음 5개가 반환됩니다. 이 때 실행되는 SQL은 다음과 같습니다.

```sql
SELECT * FROM clients LIMIT 5
```

`offset`를 추가하면 이렇게 됩니다.

```ruby
Client.limit(5).offset(30)
```

이 코드는 처음 30개의 클라이언트를 무시하고 31번째부터 최대 5명의 클라이언트를 반환합니다. 이 때의 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients LIMIT 5 OFFSET 30
```

그룹
-----

검색 메소드에서 실행되는 SQL에 `GROUP BY`를 추가하고 싶은 경우에는 `group` 메소드를 사용할 수 있습니다.

예를 들어, 주문(order)의 생성일별로 분류된 컬렉션을 가져오고 싶은 경우에는 다음과 같이 할 수 있습니다.

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

이 코드에서는 데이터베이스에서 주문이 있는 날짜별로 `Order` 객체를 하나씩 생성합니다.

이 때의 SQL은 아래와 같습니다.

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

Having
------

SQL에서는 `GROUP BY` 필드에서 조건을 지정할 경우에 `HAVING`을 사용합니다. 검색 메소드에서 `:having`를 사용하면 `Model.find`에서 `HAVING`을 추가할 수 있습니다.

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").
  group("date(created_at)").having("sum(price) > ?", 100)
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
HAVING sum(price) > 100
```

위의 예제에서는 하루에 하나의 주문 객체를 돌려줍니다만, 하루에 주문 합계가 $100가 넘어가는 경우만 돌려줍니다.

조건을 덮어쓰기
---------------------

### `unscope`

`unscope`을 사용해서 특정 조건을 제거할 수 있습니다. 예를 들어,

```ruby
Post.where('id > 10').limit(20).order('id asc').unscope(:order)
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM posts WHERE id > 10 LIMIT 20

# `unscope`가 실행되기 전의 원래 쿼리
SELECT * FROM posts WHERE id > 10 ORDER BY id asc LIMIT 20

```

where에서의 한 조건에 대해서 `unscope`를 실행할 수도 있습니다. 예를 들면,

```ruby
Post.where(id: 10, trashed: false).unscope(where: :id)
# SELECT "posts".* FROM "posts" WHERE trashed = 0
```

관계에 대해서 `unscope`를 호출하게 되면, 거기에 머지되는 모든 관계에 영향을 줍니다.

```ruby
Post.order('id asc').merge(Post.unscope(:order))
# SELECT "posts".* FROM "posts"
```

### `only`

`only` 메소드를 사용하여, 조건을 덮어 쓸 수도 있습니다.

```ruby
Post.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM posts WHERE id > 10 ORDER BY id DESC

# `only`가 호출되기 전의 원래 쿼리
SELECT "posts".* FROM "posts" WHERE (id > 10) ORDER BY id desc LIMIT 20

```

### `reorder`

`reorder` 메소드는 기본 스코프의 정렬 순서를 덮어씁니다. 예를 들어,

```ruby
class Post < ActiveRecord::Base
  ..
  ..
  has_many :comments, -> { order('posted_at DESC') }
end

Post.find(10).comments.reorder('name')
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY name
```

`reorder`를 호출하지 않았을 경우에 실행되는 SQL은 아래와 같습니다.

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

`reverse_order`는 지정된 정렬 순서를 반대로 뒤집습니다.

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

SQL에서 정렬순을 지정하는 부분이 없는 경우, `reverse_order`를 실행하면 기본키의 내림차순으로 정렬됩니다.

```ruby
Client.where("orders_count > 10").reverse_order
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

이 메소드는 인수를 **받지 않습니다**.

### `rewhere`

`rewhere`는 기존의 where을 덮어씁니다. 예를 들어,

```ruby
Post.where(trashed: true).rewhere(trashed: false)
```

여기에서 실행되는 SQL은 아래와 같습니다.

```sql
SELECT * FROM posts WHERE `trashed` = 0
```

`rewhere` 대신에 `where`을 두 번 사용하게 되면 다음과 같이 됩니다.

```ruby
Post.where(trashed: true).where(trashed: false)
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT * FROM posts WHERE `trashed` = 1 AND `trashed` = 0
```

Null 관계
-------------

`none` 메소드는 연쇄가 가능한 관계(ActiveRecord::Relation)를 돌려줍니다(레코드를 돌려주지 않습니다). 이 메소드에게 받은 관계에 어떤 조건을 연결하더라도, 항상 빈 관계가 생성됩니다. 이는 메소드나 스코프에 연쇄(chain) 가능한 응답이 필요하고, 결과를 돌려주고 싶지 않은 경우에 편리합니다.

```ruby
Post.none # 빈 관계를 돌려주며, 쿼리를 생성하지 않습니다.
```

```ruby
# 아래의 visible_posts 메소드는 관계를 하나만 돌려줄 것이라고 기대됩니다.
@posts = current_user.visible_posts.where(name: params[:name])

def visible_posts
  case role
  when 'Country Manager'
    Post.where(country: country)
  when 'Reviewer'
    Post.published
  when 'Bad User'
    Post.none # => 이 경우 []나 nil을 반환하여 호출된 쪽의 코드 실행을 중지한다
  end
end
```

읽기 전용 객체
----------------

Active Record에는 반환된 어떤 객체에 대해서도 변경을 명시적으로 금지하는 `readonly` 메소드가 있습니다. 읽기 전용으로 지정된 객체에 대해서 시도된 모든 변경은 성공하지 않으며, `ActiveRecord::ReadOnlyRecord` 예외를 발생시킵니다.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

여기에서는 `client`에 대해서 명시적으로 `readonly`가 지정되어있기 때문에, _visits_ 값을 변경하고 `client.save`를 실행하면 `ActiveRecord::ReadOnlyRecord` 예외가 발생합니다.

레코드를 변경할 수 없도록 잠그기
--------------------------

잠금은 데이터베이스의 레코드를 변경할 때의 데드락을 피하고, 아토믹(atomic)하게 레코드를 변경할 때에 유용합니다.

Active Record에서는 2가지의 잠금 기능이 있습니다.

* 낙관적 잠금 (optimistic)
* 비관적 잠금 (pessimistic)

### 낙관적 잠금 (optimistic)

낙관적 잠금은 여러 명의 사용자가 같은 레코드를 편집할 수 있도록 하고, 데이터의 충돌은 최소한으로 발생한다고 가정합니다. 이 방법에서는 레코드가 공개된 뒤로 변경된 적이 있는지를 확인합니다. 만약 변경이 있었다면 `ActiveRecord::StaleObjectError`를 발생시킵니다.

**낙관적 잠금 컬럼**

낙관적 잠금을 사용하기 위해서는 테이블에 `lock_version`이라는 이름의 integer형 컬럼이 있어야 합니다. Active Record는 레코드가 변경될 때마다 `lock_version`의 값을 1씩 증가시킵니다. 변경 요청이 발생했을 때의 `lock_version`의 값이 데이터베이스 상의 `lock_version`보다 적은 경우, 변경 요청은 실패하며, `ActiveRecord::StaleObjectError` 에러를 발생시킵니다. 예를 들어,

```ruby
c1 = Client.find(1)
c2 = Client.find(1)

c1.first_name = "Michael"
c1.save

c2.name = "should fail"
c2.save # ActiveRecord::StaleObjectErrorを発生
```

예외가 발생한 후, 이 예외를 처리하여 충돌을 해결해야 합니다. 충돌의 해결 방법으로는 롤백, 병합, 또는 비지니스 로직에 알맞는 해결 방식 등을 사용해서 처리해주세요.

`ActiveRecord::Base.lock_optimistically = false`을 설정하면 이 잠금을 비활성화할 수 있습니다.

`ActiveRecord::Base`에는 `lock_version` 컬럼명을 명시적으로 지정하기 위한 `locking_column`가 있습니다.

```ruby
class Client < ActiveRecord::Base
  self.locking_column = :lock_client_column
end
```

### 비관적 잠금

비관적 잠금에서는 데이터베이스가 존재하는 잠금 기능을 사용합니다. 관계를 구축할 때에 `lock`을 사용하면, 선택한 행에 대해 배타적 잠금을 수행합니다. `lock`를 사용하는 관계는 데드락 조건을 회피하기 위해서 트랜잭션으로 처리됩니다. 예를 들어,

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save
end
```

백엔드에서 MySQL을 사용하고 있는 경우, 아래와 같은 SQL이 생성됩니다.

```sql
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

다른 종류의 잠금을 사용하고 싶은 경우, `lock` 메소드에 직접 SQL을 넘길 수도 있습니다. 예를 들어 MySQL에는 `LOCK IN SHARE MODE`라는 것이 있습니다. 이것은 레코드의 잠금 중에도 다른 쿼리로부터의 읽기를 허가합니다. 이 방식을 사용하기 위해서는 lock에 이 방식의 이름을 인수로 넘기면 됩니다.

```ruby
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
```

모델 인스턴스가 이미 있는 경우, 트랜잭션을 시작하며 그 내부 인스턴스들의 잠금을 일괄저으로 처리합니다.

```ruby
item = Item.first
item.with_lock do
  # 이 블록은 트랜잭션 내부에서 호출된다
  # item은 이미 잠긴 상태
  item.increment!(:views)
end
```

테이블 조인하기
--------------

Active Record에는 SQL에서의 `JOIN`을 사용할 수 있게 해주는 `joins` 메소드가 있습니다. `joins`에는 다양한 사용 방법이 있습니다.

### SQL 조각을 사용하기

`joins`의 인수로 SQL을 넘겨서 `JOIN`을 사용할 수 있습니다.

```ruby
Client.joins('LEFT OUTER JOIN addresses ON addresses.client_id = clients.id')
```

이 코드는 아래와 같은 SQL을 생성합니다.

```sql
SELECT clients.* FROM clients LEFT OUTER JOIN addresses ON addresses.client_id = clients.id
```

### 레일즈의 관계 배열/해시를 사용하기

WARNING: 이 메소드는 `INNER JOIN`에서만 사용할 수 있습니다.

Active Record에서는 `joins` 메소드를 사용해서 `JOIN`을 설정할 때에 모델에 정의된 [관계](association_basics.html)의 이름을 사용할 수 있습니다.

예를 들어, 아래의 `Category`, `Post`, `Comment`, `Guest`, `Tag` 모델이 있다고 해봅시다.

```ruby
class Category < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :category
  has_many :comments
  has_many :tags
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :guest
end

class Guest < ActiveRecord::Base
  belongs_to :comment
end

class Tag < ActiveRecord::Base
  belongs_to :post
end
```

이하의 모든 쿼리들은 기대하는 대로 `INNER JOIN`을 사용하는 조인 쿼리를 실행합니다.

#### 단일 관계 조인하기

```ruby
Category.joins(:posts)
```

이는 아래와 같은 SQL을 실행합니다.

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
```

이 SQL을 우리말로 적으면, 'Post에 있는 모든 카테고리를 포함하는 Category 객체를 하나 반환해'가 됩니다. 또한 같은 카테고리에 여러개의 Post가 있는 경우, 카테고리가 중복됩니다. 중복되지 않는 카테고리 목록이 필요한 경우에는 `Category.joins(:posts).uniq`를 사용할 수 있습니다.

#### 여러 개의 관계를 조인하기

```ruby
Post.joins(:category, :comments)
```

이 코드에 의해서 아래와 같은 SQL이 실행됩니다.

```sql
SELECT posts.* FROM posts
  INNER JOIN categories ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
```

이 SQL을 우리말로 적으면, '카테고리가 하나 있고, 덧글이 적어도 하나 존재하는 모든 Post를 반환해'가 됩니다. 이쪽도 덧글이 여러개 있는 경우에는 중복해서 나타나게 됩니다.

#### 중첩(Nested)된 관계를 조인하기(한 단계)

```ruby
Post.joins(comments: :guest)
```

이 명령으로 아래와 같은 SQL이 생성됩니다.

```sql
SELECT posts.* FROM posts
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

이 SQL을 우리말로 적으면 '손님이 작성한 덧글이 하나 있는 글을 전부 반환해'가 됩니다.

#### 중첩(Nested)된 관계를 조인하기(여러 단계)

```ruby
Category.joins(posts: [{ comments: :guest }, :tags])
```

이 코드에 의해서 아래와 같은 SQL이 생성됩니다.

```sql
SELECT categories.* FROM categories
  INNER JOIN posts ON posts.category_id = categories.id
  INNER JOIN comments ON comments.post_id = posts.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.post_id = posts.id
```

### 결합시에 조건 지정하기

[배열](#배열을_사용하기)과 [문자열](#문자열만을_사용하기)조건을 사용해서 조인 테이블에서 조건을 지정할 수 있습니다. [해시](#해시를_사용하기)의 경우, 조인 테이블에서 특수한 조건을 지정하는 경우에 사용합니다.

```ruby
time_range = (Time.now.midnight - 1.day).Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

더 읽기 쉽게 만들기 위해서, 해시를 중첩해서 사용할 수도 있습니다.

```ruby
time_range = (Time.now.midnight - 1.day).Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

이 코드에서는 어제 주문(order)를 신청한 모든 고객을 검색합니다. 여기에서도 SQL의 `BETWEEN`을 사용합니다.


관계를 Eager loading 하기
--------------------------

Eager loading이란, `Model.find`에 의해서 반환되는 객체에 연관된 객체를 같이 읽어오기 위한 방식으로, 쿼리의 사용 횟수를 가능한 줄일 수 있습니다.

**N + 1쿼리 문제**

아래의 코드에 대해서 생각해봅시다. 고객을 10명 검색해서 우편번호를 출력합니다.

```ruby
clients = Client.limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

이 코드는 얼핏 보기에는 아무런 문제가 없어보입니다. 그러나 실행되는 쿼리의 횟수가 너무 많다는 것이 문제입니다. 코드에서는 처음 고객을 10명 검색하는 쿼리를 실행하고, 그 후에 거기에서 주소를 가져오기 위해서 쿼리를 10번 실행하기 때문에 합계 **11**번의 쿼리를 실행합니다.

**N + 1 쿼리 문제 해결하기**

Active Record는 읽어야하는 모든 관계를 사전에 지정할 수 있습니다. 이것은 `Model.find`를 호출 할 때에 `includes`를 설정해주면 됩니다. `includes`를 사용하면 Active Record는 지정된 모든 관계들을 최소한의 쿼리 실행으로 읽어들일 수 있게 해줍니다.

위의 예시로 설명하자면, `Client.limit(10)`라는 명령을 수정하여 주소까지 한번에 읽어올 수 있도록 할 수 있습니다.

```ruby
clients = Client.includes(:address).limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

처음 예시에서는 **11**번의 쿼리가 실행되었습니다만, 여기에서는 **2**번으로 줄어듭니다.

```sql
SELECT * FROM clients LIMIT 10
SELECT addresses.* FROM addresses
  WHERE (addresses.client_id IN (1,2,3,4,5,6,7,8,9,10))
```

### 여러 개의 관계를 한번에 읽어오기

Active Record는 위와 같은 방식으로 1개의 `Model.find`에서 다른 관계를 몇 개라도 읽어올 수 있습니다. `includes`에 배열, 해시 또는 배열과 해시를 중첩시켜서 사용하면 됩니다.

#### 여러 개의 관계의 배열

```ruby
Post.includes(:category, :comments)
```

이 코드는 글과 관련된 카테고리, 덧글을 모두 가져옵니다.

#### 중첩된 해시 사용하기

```ruby
Category.includes(posts: [{ comments: :guest }, :tags]).find(1)
```

이 코드는 id=1인 카테고리를 검색하고, 관련된 모든 글과 태그, 덧글, 덧글을 작성한 손님까지 읽어옵니다.

### 조건을 지정해서 관계를 가져오기

Active Record에서는 `joins`처럼 가져오는 시점에서 조건을 지정할 수 있습니다만, [joins](#테이블 조인하기)를 사용하길 권장합니다.

하지만 이렇게 작성해야만 하는 경우에는 `where`을 사용하면 됩니다.

```ruby
Post.includes(:comments).where("comments.visible" => true)
```

이 코드는 `LEFT OUTER JOIN`을 포함하는 쿼리를 하나 생성합니다. `joins`를 사용하면 `INNER JOIN`을 사용하는 쿼리가 생성될 것입니다.

```ruby
  SELECT "posts"."id" AS t0_r0, ... "comments"."updated_at" AS t1_r5 FROM "posts" LEFT OUTER JOIN "comments" ON "comments"."post_id" = "posts"."id" WHERE (comments.visible = 1)
```

`where`이 없는 경우라면 2개의 쿼리를 생성합니다.

이 `includes` 쿼리의 경우 덧글의 존재 여부에 관계 없이 모든 글을 읽어들일 것입니다. 반면 `joins` (INNER JOIN)을 사용하는 경우, 결합조건을 **반드시** 만족해야 하므로 덧글이 없는 글은 반환되지 않습니다.

스코프
------

스코프를 설정하여 관계 객체나 모델에 대한 메소드 호출등에 참조되는, 자주 사용되는 쿼리를 지정할 수 있습니다. 스코프에는 `where`, `joins`, `includes` 같은 지금까지 등장한 모든 메소드를 사용할 수 있으며, 어떤 스코프 메소드도 언제나 `ActiveRecord::Relation`를 반환합니다. 이 객체에 대해서 별도의 스코프를 포함하는 다른 메소드를 호출할 수도 있습니다.

스코프를 설정하기 위해서는 클래스에서 `scope` 메소드를 통해 스코프가 호출될 때에 실행되어야 할 쿼리를 넘겨주면 됩니다.

```ruby
class Post < ActiveRecord::Base
  scope :published, -> { where(published: true) }
end
```

아래에서 알 수 있듯이, 스코프의 설정은 클래스 메소드를 정의하는 방법과 완전히 같기 때문에, 어느 방식을 사용할 지는 취향대로 선택해주세요.

```ruby
class Post < ActiveRecord::Base
  def self.published
    where(published: true)
  end
end
```

스코프를 스코프 내에서 연쇄(chain)시킬 수도 있습니다.

```ruby
class Post < ActiveRecord::Base
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

이 `published` 스코프를 호출하기 위해서는 클래스에서 이 스코프를 호출하면 됩니다.

```ruby
Post.published # => [published posts]
```

또는 `Post` 객체로 넘어오는 관계에서도 이 스코프를 호출할 수 있습니다.

```ruby
category = Category.first
category.posts.published # => [published posts belonging to this category]
```

### 인수를 넘기기

스코프에는 인수를 넘길 수 있습니다.

```ruby
class Post < ActiveRecord::Base
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

인수를 포함하는 스코프를 호출할 경우에는 클래스 메소드와 같은 방식으로 선언할 수 있습니다.

```ruby
Post.created_before(Time.zone.now)
```

하지만 이 스코프에서 가능한 기능은, 클래스 메소드에서의 그것과 중복됩니다.

```ruby
class Post < ActiveRecord::Base
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

스코프에서 인수를 사용해야 한다면, 클래스 메소드로 정의하는 것을 추천합니다. 클래스 메소드로 만든 경우라도 관계로 넘어온 경우에도 사용할 수 있습니다.

```ruby
category.posts.created_before(time)
```

### 스코프 병합

`where`과 마찬가지로 `AND` 조건을 사용해서 스코프를 병합할 수 있습니다.

```ruby
class User < ActiveRecord::Base
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.active.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```

`scope`와 `where` 조건을 섞어서 사용할 수도 있습니다. 이 경우, 결과로 생성되는 최종적인 SQL은 모든 조건이 AND로 연결됩니다.

```ruby
User.active.where(state: 'finished')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'finished'
```

스코프보다도 마지막 where을 우선하고 싶은 경우에는 `Relation#merge`를 사용할 수 있습니다.

```ruby
User.active.merge(User.inactive)
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

여기서 하나 주의할 점은 `default_scope`는 `scope`나 `where` 조건보다도 우선된다는 점입니다.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

이 예제에서 알 수 있듯이 `default_scope`가 `scope`와 `where`보다 우선됩니다.

### 기본 스코프를 사용하기

어떤 스코프를 모델의 모든 쿼리에 적용하고 싶은 경우, 모델의 내부에서 `default_scope`라는 메소드를 사용할 수 있습니다.

```ruby
class Client < ActiveRecord::Base
  default_scope { where("removed_at IS NULL") }
end
```

이 모델에 대해서 쿼리를 실행하면 아래와 같은 SQL을 생성합니다.

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

기본 스코프의 조건이 복잡하다면 스코프를 클래스 메소드로 정의하는 것도 한가지 방법입니다.

```ruby
class Client < ActiveRecord::Base
  def self.default_scope
    # ActiveRecord::Relationを返すようにする
  end
end
```

### 모든 스코프를 삭제하기

어떤 이유로 모든 스코프를 쓰고 싶지 않은 때에는 `unscoped`를 사용할 수 있습니다. 이 메소드는 모델에서 `default_scope`를 사용하고 있지만 특정 쿼리에 한해서 그 스코프를 적용하고 싶지 않은 경우에 유용합니다.

```ruby
Client.unscoped.load
```

이 메소드는 스코프를 모두 무시하고, 쿼리를 실행합니다.

`unscoped`에 `scope`를 이어서(chain) 사용할 수는 없으므로 주의해주세요. 이러한 경우에는 `unscoped`를 블록 형식으로 사용하는 것을 추천합니다.

```ruby
Client.unscoped {
  Client.created_before(Time.zone.now)
}
```

동적 파인더
---------------

Active Record는 테이블에 정의된 모든 필드(속성이라고도 불립니다)에 대한 검색 메소드를 자동적으로 제공합니다. 예를 들어서 `Client` 모델에 `first_name`이라는 필드가 있다고 하면, `find_by_first_name`이라는 메소드가 Active Record에 의해서 자동적으로 생성됩니다. `Client` 모델에 `locked`라는 필드가 있다면, `find_by_locked`라는 메소드도 사용가능합니다.

이 동적 검색 메소드의 뒤에 `Client.find_by_name!("Ryan")`과 같은 느낌표(`!`)를 추가하면 해당하는 레코드가 없는 경우에 `ActiveRecord::RecordNotFound` 에러를 발생시킵니다.

name과 locked를 모두 사용해서 검색하고 싶은 경우에는 2개의 필드명을 and로 연결해서 호출하면 됩니다. 이 경우, `Client.find_by_first_name_and_locked("Ryan", true)`처럼 작성할 수 있습니다.

새로운 객체를 검색하거나 만들기
--------------------------

NOTE: Rails 4.0에서는 일부 동적 검색 메소드가 비권장으로 지정되었습니다. 이것들은 Rails 4.1에서 삭제될 예정입니다. 가장 좋은 방법은 Active Record의 스코프로 대체하는 것입니다. 비권장으로 변경된 파인더 잼은 https://github.com/rails/activerecord-deprecated_finders 에서 찾아보실 수 있습니다.

레코드를 검색해보고 없다면 생성한다, 라는 것은 꽤 자주 있는 상황입니다. `find_or_create_by`나 `find_or_create_by!`를 사용하면 이러한 작업을 한번에 처리할 수 있습니다.

### `find_or_create_by`

`find_or_create_by` 메소드는 지정된 속성을 가지는 레코드가 존재하는지를 확인합니다. 레코드가 없는 경우에는 `create`가 호출됩니다. 아래의 예시를 봐주세요.

'Andy'라는 이름의 고객을 찾고, 없다면 새로 생성하고 싶다고 가정합시다. 이러한 경우에는 아래와 같이 실행하면 됩니다.

```ruby
Client.find_or_create_by(first_name: 'Andy')
# => #<Client id: 1, first_name: "Andy", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">
```

이 메소드에 의해서 생성되는 SQL은 다음과 같습니다.

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO clients (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by`는 이미 존재하는 레코드나 그렇지 않으면 새로운 레코드를 반환합니다. 이 경우, Andy라는 이름의 고객이 없었기 때문에 새 레코드를 반환하였습니다.

`create`와 마찬가지로 검증에 통과하는가, 아닌가에 따라 새로운 레코드가 데이터베이스에 저장되지 않을 수도 있습니다.

이번에는 새로운 레코드를 작성할 경우에 'locked' 속성을 `false`로 설정하고 싶은데, 그것을 쿼리에는 포함하고 싶지 않다고 가정해봅시다. 거기서 "Andy"라는 이름의 고객을 검색하거나, 그 이름을 가지는 고객이 없는 경우 "Andy"라는 고객을 생성하고, 잠금을 해제하고 싶습니다.

이것은 2가지 방법으로 구현할 수 있습니다. 첫번째는 `create_with`를 사용하는 방법입니다.

```ruby
Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

두번째는 블록을 사용하는 방식입니다.

```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

이 블록은 고객이 생성될 때에만 실행됩니다. 이 코드를 다시 실행하면, 블록은 실행되지 않습니다.

### `find_or_create_by!`

`find_or_create_by!`를 사용하면 새로운 레코드가 생성을 시도하고, 실패했을 경우에 예외를 발생시킵니다. 이 가이드에서는 검증에 대해서 설명하지 않습니다만,

```ruby
validates :orders_count, presence: true
```

이를 `Client` 모델에 추가했다고 가정합시다. `order_count`를 지정하지 않고 새로운 `Client` 모델을 생성하면 레코드가 유효하지 않다고 판단되어 예외가 발생합니다.

```ruby
Client.find_or_create_by!(first_name: 'Andy')
# => ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### `find_or_initialize_by`

`find_or_initialize_by` 메소드는 `find_or_create_by`와 같은 방식으로 동작합니다만, `create` 대신에 `new`를 호출한다는 점이 다릅니다. 다시 말해, 모델의 새로운 객체를 생성하지만, 데이터베이스에는 저장하지 않습니다. `find_or_create_by`의 예외를 조금 바꾸어서 설명해보겠습니다. 이번에는 'Nick'이라는 이름의 고객이 필요하다고 합시다.

```ruby
nick = Client.find_or_initialize_by(first_name: 'Nick')
# => <Client id: nil, first_name: "Nick", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nick.persisted?
# => false

nick.new_record?
# => true
```

객체는 아직 데이터베이스에 저장되어있지 않기 때문에 실행되는 SQL은 아래와 같습니다.

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Nick') LIMIT 1
```

이 객체를 데이터베이스에 저장하고 싶은 경우에 `save`를 호출하면 됩니다.

```ruby
nick.save
# => true
```

SQL로 검색하기
--------------

직접 SQL을 사용해서 레코드를 검색하고 싶은 경우에 `find_by_sql`를 사용할 수 있습니다. 이 `find_by_sql` 메소드는 객체 배열을 하나 반홚납니다. 쿼리가 레코드를 하나만 찾은 경우에도 배열을 돌려주기 때문에 주의해주세요. 예를 들어서 아래와 같은 쿼리를 실행한다고 가정합시다.

```ruby
Client.find_by_sql("SELECT * FROM clients
  INNER JOIN orders ON clients.id = orders.client_id
  ORDER BY clients.created_at desc")
# =>  [
  #<Client id: 1, first_name: "Lucas" >,
  #<Client id: 2, first_name: "Jan" >,
  # ...
]
```

`find_by_sql`는 데이터베이스에서 Active Record에서 제공하지 않는 쿼리를 사용하기 위한 간단한 방법을 제공하며, 인스턴스화 된 객체를 반환합니다.

### `select_all`

`find_by_sql`는 `connection#select_all`과 깊은 관계가 있습니다. `select_all`은 `find_by_sql`와 마찬가지로 커스텀 SQL을 사용해서 데이터베이스에서 결과를 가져옵니다만, 가져온 결과를 객체로 만들지 않는다는 점이 다릅니다. 대신, 해시 배열을 돌려주며, 하나의 해시가 하나의 레코드를 나타냅니다.

```ruby
Client.connection.select_all("SELECT * FROM clients WHERE id = '1'")
# => [
  {"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
  {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}
]
```

### `pluck`

`pluck`은 모델에서 사용하는 테이블로부터 1개 또는 그 이상의 컬럼을 가져올때 사용할 수 있습니다. 인수로서 컬럼명 리스트를 받고, 지정된 컬럼 값의 배열을 그에 맞는 데이터 형식으로 반환합니다.

```ruby
Client.where(active: true).pluck(:id)
# SELECT id FROM clients WHERE active = 1
# => [1, 2, 3]

Client.distinct.pluck(:role)
# SELECT DISTINCT role FROM clients
# => ['admin', 'member', 'guest']

Client.pluck(:id, :name)
# SELECT clients.id, clients.name FROM clients
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
```

`pluck`을 사용하면 아래와 같은 코드를 좀 더 간단하게 변경할 수 있습니다.

```ruby
Client.select(:id).map { |c| c.id }
  # 또는
Client.select(:id).map(&:id)
  # 또는
Client.select(:id, :name).map { |c| [c.id, c.name] }
```

```ruby
Client.pluck(:id)
  # 또는
Client.pluck(:id, :name)
```

`select`와는 다르게 `pluck`은 데이터베이스에서 받은 결과를 직접 Ruby의 배열로 변환합니다. 이를 위해 `ActiveRecord` 객체를 사전에 준비할 필요가 없습니다. 따라서, 이 메소드는 대규모의 쿼리나 사용 빈도가 높은 쿼리에서 사용하면 퍼포먼스를 향상시킬 수 있습니다. 단, 속성 접근자를 덮어쓰는 모델 메소드는 사용할 수 없습니다. 예를 들어, 다음과 같은 경우입니다.

```ruby
class Client < ActiveRecord::Base
  def name
    "저는 #{super}입니다."
  end
end

Client.select(:name).map &:name
# => ["저는 David입니다.", "저는 Jeremy입니다.", "저는 Jose입니다."]

Client.pluck(:name)
# => ["David", "Jeremy", "Jose"]
```

더불어 `pluck`는 `select` 등의 `Relation` 스코프와는 다르게, 쿼리를 직접 실행하기 때문에, 자신 뒤에 따라오는 스코프를 적용시키지 못합니다. 대신 이미 구성된 스코프를 `pluck`의 앞에 둘 수는 있습니다.

```ruby
Client.pluck(:name).limit(1)
# => NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

Client.limit(1).pluck(:name)
# => ["David"]
```

### `ids`

`ids`는 테이블의 기본키를 사용하는 모든 관계들의 ID를 가져옵니다.

```ruby
Person.ids
# SELECT id FROM people
```

```ruby
class Person < ActiveRecord::Base
  self.primary_key = "person_id"
end

Person.ids
# SELECT person_id FROM people
```

객체의 존재 확인
--------------------

객체가 존재하는지 아닌지, `exists?`로 확인할 수 있습니다.
이 메소드는 `find`와 같은 쿼리를 전송합니다만, 객체의 컬렉션을 돌려주는 대신 `true`나 `false`를 반환합니다.

```ruby
Client.exists?(1)
```

`exists?`는 여러개의 인수를 받을 수 있습니다. 단 그 값들 중 하나라도 존재한다면 다른 값이 존재하지 않더라도 `true`를 돌려줍니다.

```ruby
Client.exists?(id: [1,2,3])
  # 또는
Client.exists?(name: ['John', 'Sergei'])
```

`exists?`는 모델이나 조건절에 대해서 인수 없이 호출할 수도 있습니다.

```ruby
Client.where(first_name: 'Ryan').exists?
```

이 예제에서는 `first_name`이 'Ryan'인 고객이 한명이라도 존재하면 `true`를 반환하고, 그 이외의 경우에는 `false`를 반환합니다.

```ruby
Client.exists?
```

여기에서는 `Client` 테이블이 비어있다면 `false`를 돌려주고, 그 이외의 경우에는 `true`를 반환합니다.

모델이나 관계에서 존재 여부를 확인하는 경우에는 `any?`나 `many?`도 사용할 수 있습니다.

```ruby
# 모델을 통해서
Post.any?
Post.many?

# 스코프를 통해서
Post.recent.any?
Post.recent.many?

# 조건절을 통해서
Post.where(published: true).any?
Post.where(published: true).many?

# 관계를 통해서
Post.first.categories.any?
Post.first.categories.many?
```

계산
------------

이 절에서는 `count` 메소드를 예시로 설명합니다만, 여기에 설명되어있는 옵션은 아래의 모든 절에서도 사용가능합니다.

모든 계산 메소드는 모델에 대해서 직접 실행됩니다.

```ruby
Client.count
# SELECT count(*) AS count_all FROM clients
```

조건절에 대해서도 직접 실행됩니다.

```ruby
Client.where(first_name: 'Ryan').count
# SELECT count(*) AS count_all FROM clients WHERE (first_name = 'Ryan')
```

이외에도 다양한 검색 메소드를 사용해 복잡한 계산을 수행할 수도 있습니다.

```ruby
Client.includes("orders").where(first_name: 'Ryan', orders: { status: 'received' }).count
```

이 코드는 아래와 같은 SQL을 실행합니다.

```sql
SELECT count(DISTINCT clients.id) AS count_all FROM clients
  LEFT OUTER JOIN orders ON orders.client_id = client.id WHERE
  (clients.first_name = 'Ryan' AND orders.status = 'received')
```

### 갯수를 새기

모델 테이블에 포함되는 레코드의 갯수를 세기 위해서는 `Client.count`를 사용할 수 있습니다. 반환되는 값은 레코드의 갯수입니다. 연령 정보가 있는 고객의 숫자를 알고 싶은 경우에는 `Client.count(:age)`로 호출할 수 있습니다.

옵션에 대해서는 이 위의 [계산](#계산)을 참조해주세요.

### 평균

테이블에 포함되는 특정 수치에 대한 평균은 그 테이블을 가지는 클래스에 대해서 `average` 메소드를 호출하여 얻을 수 있습니다. 다음과 같이 호출할 수 있습니다.

```ruby
Client.average("orders_count")
```

반환되는 값은 그 필드의 평균값입니다. 보통은 3.14159265 처럼 부동소수점이 됩니다.

옵션에 대해서는 이 위의 [계산](#계산)을 참조해주세요.

### 최소값

테이블에 포함되는 특정 필드의 최소값은 그 테이블을 가지는 클래스에 대해서 `minimum` 메소드를 호출하여 얻을 수 있습니다. 다음과 같이 사용할 수 있습니다.

```ruby
Client.minimum("age")
```

옵션에 대해서는 이 위의 [계산](#계산)을 참조해주세요.

### 최대값

테이블에 포함되는 특정 필드의 최대값은 그 테이블을 가지는 클래스에 대해서 `maximum` 메소드를 호출하여 얻을 수 있습니다. 다음과 같이 사용할 수 있습니다.

```ruby
Client.maximum("age")
```

옵션에 대해서는 이 위의 [계산](#계산)을 참조해주세요.

### 합계

테이블에 포함되는 전체 레코드에서 특정 필드의 합을 얻기 위해서는 그 테이블을 가지는 클래스에 대해서 `sum` 메소드를 호출합니다. 다음과 같이 사용할 수 있습니다.

```ruby
Client.sum("orders_count")
```

옵션에 대해서는 이 위의 [계산](#계산)을 참조해주세요.

EXPLAIN 실행하기
---------------

관계(ActiveRecord::Relation)를 통해 실행되는 쿼리에서 EXPLAIN을 실행할 수 있습니다. 아래의 코드에서는,

```ruby
User.where(id: 1).joins(:posts).explain
```

아래와 같은 결과가 생성됩니다.

```
EXPLAIN for: SELECT `users`.* FROM `users` INNER JOIN `posts` ON `posts`.`user_id` = `users`.`id` WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |             |
|  1 | SIMPLE      | posts | ALL   | NULL          | NULL    | NULL    | NULL  |    1 | Using where |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------------+
2 rows in set (0.00 sec)
```

MySQL일 경우의 결과는 위와 같습니다.

Active Record는 데이터베이스의 쉘에서 볼수 있을법한 정형화된 결과를 출력합니다. PostgreSQL 어댑터를 통해서 같은 쿼리를 실행하면, 다음과 같은 결과를 얻을 수 있습니다.

```
EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "posts" ON "posts"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (posts.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on posts  (cost=0.00..28.88 rows=8 width=4)
         Filter: (posts.user_id = 1)
(6 rows)
```

Eager loading을 사용하고 있으면 내부에서 복수의 쿼리가 실행되는 경우가 있으며, 일부의 쿼리에서는 직전 쿼리의 결과를 요구하는 경우도 있습니다. 때문에 `explain`은 이 쿼리를 직접 실행하고 그 이후에 쿼리 플랜을 요구합니다. 예를 들어 아래와 같은 코드에서는,

```ruby
User.where(id: 1).includes(:posts).explain
```

다음과 같은 결과를 생성합니다.

```
EXPLAIN for: SELECT `users`.* FROM `users`  WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
| id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
|  1 | SIMPLE      | users | const | PRIMARY       | PRIMARY | 4       | const |    1 |       |
+----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
1 row in set (0.00 sec)

EXPLAIN for: SELECT `posts`.* FROM `posts`  WHERE `posts`.`user_id` IN (1)
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | posts | ALL  | NULL          | NULL | NULL    | NULL |    1 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
```

이 결과는 MySQL일 경우입니다.

### EXPLAIN의 출력 결과를 이해하기

EXPLAIN의 출력 결과에 대한 자세한 설명은 이 가이드의 범위를 벗어납니다. 다음 정보를 참조해주세요.

* SQLite3: [EXPLAIN QUERY PLAN](http://www.sqlite.org/eqp.html) (영어)

* MySQL: [EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html) (영어)

* PostgreSQL: [EXPLAIN 사용하기](https://www.postgresql.jp/document/9.3/html/using-explain.html) (일본어)

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.

