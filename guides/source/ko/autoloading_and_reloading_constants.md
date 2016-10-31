
상수 자동 로딩과 리로딩
===================================

여기에서는 Rails의 상수 자동 로딩과 리로딩의 구조에 대해서 설명합니다.

이 가이드의 내용:

* Ruby에서 사용되는 상수의 특징
* `autoload_paths`에 대해서
* 상수가 자동으로 로딩되는 방식
* `require_dependency`에 대해서
* 상수가 리로딩되는 방식
* 리로딩에서 자주 발생하는 문제의 해결 방법

--------------------------------------------------------------------------------


들어가며
------------

Ruby on Rails에서는 코드를 변경하면 개발자가 서버를 다시 시동하지 않더라도 이미 애플리케이션이 그 정보를 읽어들인 것처럼 동작합니다.

일반 Ruby 프로그램의 클래스라면 의존 관계가 있는 프로그램을 명시적으로 읽어올 필요가 있습니다.

```ruby
require 'application_controller'
require 'post'

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rubyist로서의 본능은 위의 코드를 본 순간 여기에는 불필요한 코드가 있다는 것을 금방 눈치챌 것입니다. 클래스가 그것이 저장되어 있는 파일명과 같은 이름으로 정의되어 있다면, 어떻게 자동으로 읽어올 수 는 없을까요? 의존하는 파일을 탐색해서 그 결과를 저장해두면 됩니다만, 이러한 의존 관계는 불안정합니다.

나아가 `Kernel#require`는 파일을 한번만 읽어옵니다만, 읽어온 뒤의 파일이 변경되었을 때에 서버를 재기동하지 않고 새로운 변경사항을 반영할 수 있다면, 개발이 편해질 것입니다. 개발 중에는 `Kernel#load`를 사용하고 실제 환경에서는 `Kernel#require`를 상황에 따라서 사용하는 식으로 만들 수 있다면 편리할 것입니다.

그리고 Ruby on Rails에서는 아래와 같이 작성하는 것으로 바로 이런 기능을 편하게 이용할 수 있습니다.

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

여기에서는 이 기능의 구조에 대해서 설명합니다.


상수 갱신
-------------------

많은 프로그래밍 언어에 대해서는 상수는 그렇게 중요한 위치를 점하고 있지 않습니다만, Ruby에 있어서는 상수에 대한 화제가 무척 많습니다.

Ruby 언어에서의 상수를 설명하는 것은 이 가이드의 범주를 벗어나므로 자세하게는 설명하지 않습니다만, 상수의 몇몇 중요한 부분을 짚고 넘어가겠습니다. 이후의 설명을 잘 이해한다면, Rails에서의 상수 자동 로딩과 리로딩을 이해할 때에 좋은 무기가 될 것입니다.

### 중첩

클래스 및 모듈의 정의를 중첩하는 것으로 네임스페이스를 생성할 수 있습니다.

```ruby
module XML
  class SAXParser
    # (1)
  end
end
```

어떤 위치에서의 *중첩*은 중첩된 클래스와 모듈 객체를 중첩 안쪽에서부터 나열한 컬렉션이 됩니다. 이 예제에서의 위치 (1)의 중첩은 다음과 같습니다.

```ruby
[XML::SAXParser, XML]
```

중첩은 클래스나 모듈의 '객체'로 구성되어 있다는 점을 이해하는 것이 중요합니다. 중첩은 거기에 접근하기 위한 상수와 아무런 관계도 없으며, 중첩된 이름과도 관계가 없습니다.

예를 들어, 다음의 정의는 위의 예제와 비슷합니다.

```ruby
class XML::SAXParser
  # (2)
end
```

(2)에서 중첩을 확인한 결과는 다음과 같습니다.

```ruby
[XML::SAXParser]
```

`XML` 자체는 중첩에 포함되지 않습니다.

이 예제에서 확인할 수 있듯이, 어떤 특정 중첩에 속하는 클래스 명이나 모듈 명은 중첩의 위치에 따른 네임스페이스와 항상 연관이 있는 것은 아닙니다.

나아가 각각은 연관이 있는 것이 아니라, 완전히 독립적입니다. 다음의 예제를 생각해 봅시다.

```ruby
module X::Y
  module A::B
    # (3)
  end
end
```

위치 (3)의 중첩은 아래의 2개의 모듈 객체로 구성됩니다.

```ruby
[A::B, X::Y]
```

이 중첩은 `A`로 끝나는 것이 아니라(그 전에 이 `A`는 중첩 관계에 속해있지도 않습니다), 중첩에 `X::Y`도 포함되어 있습니다. 이 `X::Y`와 `A::B`는 서로 독립적입니다.

이 중첩은 Ruby 인터프리터에 의해서 유지되고 있는 내부 스택이며, 아래의 규칙에 따라서 변경됩니다.

* `class` 키워드 뒤에 있는 클래스 객체는 그 내용이 실행되기 전에 스택에 들어가서, 실행 완료 후에 스택에서 방출됩니다.

* `module` 키워드 뒤에 있는 모듈 객체는 그 내용이 실행되기 전에 스택에 들어가서, 실행 완료 후에 스택에서 방출됩니다.

* 싱글톤 클래스는 `class << object`로 정의 될 때 스택에 들어가며, 이후에 스택에서 방출됩니다.

* `*_eval`로 끝나는 메소드가 문자열을 하나 사용하여 호출되면, 그 리시버의 싱글톤 클래스는 eval된 코드의 중첩에 들어갑니다.

* `Kernel#load`에 의해서 해석되는 코드의 최상위에 존재하는 네스트는 빈 공간이 됩니다. 단, `load` 호출이 두번째 인수로서 true를 받은 경우를 제외합니다. 이 값이 지정되면 익명 모듈이 새롭게 생성되어 Ruby에 의해 스택에 들어갑니다.

여기서 흥미로운 점은 블럭이 스택에 아무런 영향을 주지 않는다는 점입니다. 특히 `Class.new`나 `Module.new`에 넘겨질 가능성이 있는 블럭은 `new` 메소드에 의해서 정의된 클래스나 모듈을 중첩에 집어넣지 않습니다. 이 부분이 블럭을 사용하지 않고 어떤 클래스나 모듈을 정의할 때와 다른 점 중 하나입니다.
`Module.nesting`를 사용하여 임의의 위치에 있는 중첩을 조사(inspect)할 수 있습니다.

### 클래스나 모듈의 정의란 상수 대입

아래의 코드를 실행하면 클래스가(다시 열리는 것이 아니라) 새로 생성된다고 가정합시다.

```ruby
class C
end
```

Ruby는 `Object`에 `C`라는 상수를 생성하고, 그 상수에 클래스 객체를 저장합니다. 이 클래스 인스턴스의 이름은 "C"라는 문자열이 되며, 이는 상수의 이름으로부터 붙여진 이름입니다.

다시 말해,

```ruby
class Project < ActiveRecord::Base
end
```

이 코드는 상수 대입(constant assignment)를 합니다. 이 코드는 다음과 동등합니다.

```ruby
Project = Class.new(ActiveRecord::Base)
```

이 때, 클래스 이름은 아래와 같이 사이드 이펙트로서 설정됩니다.

```ruby
Project.name # => "Project"
```

이 동작을 구현하기 위해서 상수 대입에는 하나의 특수한 규칙이 정의되어 있습니다. 대입되는 객체가 익명 클래스 또는 모듈인 경우, Ruby는 그것들의 객체 이름을 그 상수의 이름을 인용하여 명명합니다.

INFO: 익명 클래스나 익명 모듈에 이름이 부여된 이후에는 상소와 인스턴스에서 무슨 일이 진행되는가는 중요하지 않습니다. 예를 들어, 상수를 삭제할 수도 있으며, 클래스 객체를 다른 상수에 대입하거나 이를 저장하지 않을 수도 있습니다. 이름은 일단 설정되면 그 이후에는 변경되지 않게 됩니다.

`module` 키워드를 지정하여 아래와 같이 모듈을 생성한 경우에도 클래스와 마찬가지로 동작합니다.

```ruby
module Admin
end
```

이 코드는 상수 대입을 수행합니다. 이는 아래와 동등합니다.

```ruby
Admin = Module.new
```

이 때, 아래와 같이 모듈의 이름은 사이드 이펙트로서 설정됩니다.

```ruby
Admin.name # => "Admin"
```

WARNING: `Class.new`나 `Module.new`에 넘겨지는 블록의 실행 컨텍스트는 `class` 또는 `module` 키워드를 사용하는 시점의 실행 컨텍스트와 완전히 동등하지 않은 경우가 있습니다. 그러나, 상수 대입은 어떤 방식을 사용한 경우라도 동일하게 이루어집니다.

어디서인가 "`String` 클래스"라고 부른다면, 그 진짜 의미는 이렇습니다. "`String` 클래스"란 `Object`라는 상수가 있으며, 거기에 클래스 객체가 저장되어 있고, 나아가 그 중에 "String"이라는 상수가 있으며, 거기에 저장되어 있는 클래스 객체를 의미합니다. `String`은 Ruby에 많고 많은 하나의 상수에 불과하며, 해결 알고리즘이나 그에 관련된 모든 것들이 이 `String`이라는 상수에 적용되게 됩니다.

컨트롤러에 대해서도 같은 방식으로 생각할 수 있습니다.

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

이 코드에서의 `Post`는 클래스를 위한 문법이 아닌, Ruby에 존재하는 하나의 상수입니다. 문제가 없다면 이 상수는 `all` 메소드를 가지는 객체일 것이라고 평가됩니다.

이것이 바로 *상수*의 자동 로딩에 대해서 이야기하는 이유입니다. Rails는 상수를 필요에 따라서 자동으로 읽어오는 기능을 가지고 있습니다.

### 상수는 모듈에 저장된다

Ruby의 상수는 문자 그대로 '모듈에 저장되어 있습니다'. 클래스와 모듈에는 상수 테이블이 존재합니다. 이것은 해시 테이블과 비슷한 것이라고 상상해주세요.

이것이 어떤 것인지를 충분히 이해하기 위해서 하나의 예를 들어서 분석해봅시다. "이 `String` 클래스"와 같은 애매한 표현은 설명하는 쪽에서는 편리하지만, 여기에서는 이해하기 쉽도록 좀 더 엄밀하게 설명합니다.

다음과 같은 모듈 정의를 생각해봅시다.

```ruby
module Colors
  RED = '0xff0000'
end
```

처음 `module` 키워드를 처리하면 Ruby 인터프리터는 `Object` 상수에 저장된 클래스 객체의 상수 테이블에 새로운 값을 하나 추가합니다. 이 값은 "Colors"라는 이름과, 새롭게 생성된 모듈 객체를 연결합니다. 그리고 Ruby 인터프리터는 새로운 모듈 객체의 이름을 "Colors"라는 문자열로 설정합니다.

그리고 이 모듈 정의의 본체가 Ruby 인터프리터에 의해서 해석되면, `Colors` 상수에 저장된 모듈 객체의 상수 테이블에 새로운 값이 하나 추가됩니다. 이 값은 "RED"라는 이름을 "0xff0000"라는 문자열과 연결합니다.

특히 이 `Colors::RED`는 다른 클래스 객체나 모듈 객체에 존재할 지도 모르는 다른 `RED` 정소와는 아무런 관련이 없다는 점에 주목해주세요. 만약 다른 `RED` 상수가 우연히 존재한다고 한다면, 그것은 다른 상수 테이블에 또 다른 값으로 존재하고 있을 것입니다.

이 설명을 읽을 때에는 클래스 객체, 모듈 객체, 상수명, 상수 테이블에 연결되는 값 객체를 각각 혼동하지 않도록 주의해주세요.

### 해결 알고리즘

#### 상대 상수를 해결하는 알고리즘

중첩이 비어있지 않다면, 그 첫번째 요소, 비어있는 경우에는 `Object`를 코드의 임의의 장소에서 *cref*라고 합시다(역주: cref는 Ruby 내부에서의 클래스 참조(class reference)의 약어이며, Ruby의 상수가 가지는 암묵적인 컨텍스트 입니다).

여기서 자세한 설명은 하지 않습니다만, 상대적인 상수 참조를 해결하는 알고리즘은 아래와 같습니다.

1. 중첩이 존재하는 경우, 그 중첩의 요소를 순서대로 탐색합니다. 그 요소들의 부모들은 무시됩니다.

2. 발견되지 않는 경우에는 cref의 부모 체인(상속 체인)을 탐색합니다.

3. 발견되지 않는 경우에는 `Object`를 탐색합니다.

4. 발견되지 않는 경우에는 cref에 대해서 `const_missing`이 호출됩니다. `const_missing`의 기본 구현은 `NameError`를 던집니다만, 이는 재정의가 가능합니다.

Rails의 자동 로딩은 **이 알고리즘을 에뮬레이트하고 있지 않다는 점을 기억해주세요**. 단 탐색의 시작 지점은 자동 로딩되는 상수의 이름과, cref 자신입니다. 자세한 설명은 [상대참조](#상대참조)를 확인해주세요.

#### 검증된 상수를 해결하는 알고리즘

검증된(qualified) 상수는 아래와 같은 것들입니다.

```ruby
Billing::Invoice
```

`Billing::Invoice`에는 두 개의 상수가 포함되어 있습니다. 처음의 `Billing`은 상대적인 상수이며, 위에서 설명했던 알고리즘에 의해서 해결됩니다.

INFO: `::Billing::Invoice`처럼 앞에 콜론을 2개 두는 것으로 이 경로를 절대 경로로 변경할 수 있습니다. 이렇게 작성하면 `Billing`은 최상위 레벨의 상수로서 참조됩니다.

두번째의 `Invoice` 상수는 `Billing`으로 검증되어 있습니다. 이 상수를 해결하는 방법에 대해서는 나중에 설명합니다. 여기에서는 검증한 쪽의 클래스나 모듈 객체(여기에서는 `Billing`)을 *부모*로 정의합니다. 검증된 상수를 해결하는 알고리즘은 다음과 같습니다.

1. 이 상수는 그 부모와 조상들에서만 탐색됩니다.

2. 아무 것도 발견하지 못했을 경우, 부모의 `const_missing`가 호출됩니다. `const_missing`은 `NameError`를 던집니다만, 재정의할 수 있습니다.

지금까지 보았던 대로, 이 탐색 알고리즘은 상대 상수일 경우보다도 간단합니다. 특히 중첩이 아무런 영향을 주지 않는다는 점에 주목해주세요. 그리고 모듈을 특별 취급하지도 않으며, 모듈 자신 또는 모듈의 부모 어느쪽에도 상수가 없는 경우에는 `Object`를 탐색하지 않는다는 점도 다릅니다.

Rails의 자동 로딩은 **이 알고리즘을 에뮬레이트하지 않는다**는 점에 주의해주세요. 단 탐색 시작 지점은 자동 로딩이 되는 상수의 이름과 그 부모입니다. 자세한 설명은 [검증된 상수 참조](#검증된-상수-참조)를 참고해주세요.


용어 설명
----------

### 부모의 네임스페이스

상수 경로로 주어진 문자열을 사용해서 **부모의 네임스페이스**가 정의됩니다. 부모의 네임스페이스는 상수 경로로부터 오른쪽 부분을 제거한 문자열이 됩니다.

예를 들어서, "A::B::C"라는 문자열의 부모 네임스페이스는 "A::B"라는 문자열이 되며, "A::B"라는 문자열의 부모 네임스페이스는 "A", "A"의 부모 네임스페이스는 ""가 됩니다.

하지만 클래스나 모듈에 대해서 고찰하는 경우, 부모의 네임스페이스의 해석에는 특이한 부분이 있으므로 주의해야할 필요가 있습니다. 예를 들어 "A::B"라는 이름을 가지는 모듈 M에 대해서 생각해봅시다.

* 부모의 네임스페이스 "A"는 주어진 위치에서의 네스트를 반영하고 있지 않을 수 있다.

* `A`라는 상수는 이미 존재하지 않을 가능성이 있다. 이 상수는 어떠한 코드에 의해서 `Object`로부터 삭제되었을 수도 있다.

* 만약 `A`라는 상수가 존재한다고 하더라도 이전에 `A`라는 이름을 가진 클래스 또는 모듈이 이제 존재하지 않을 가능성도 있다. 예를 들어, 상수가 하나 삭제된 후에 다른 상수에 대입되었다면, 일반적으로 그것은 다른 객체를 가리키고 있을 것이라고 생각해야한다.

* 그러한 상황에서 `A`라는 같은 이름을 가지는 상수에 다시 대입하게 되면, 그 `A`는 같은 "A"라는 이름을 가지는 새로운 클래스 또는 모듈일 가능성도 있다.

* 위의 상황이 발생한 경우 `A::B`라는 이름으로 M이라는 모듈을 참조할 수 없게 되지만, M이라는 모듈 객체 자신은 "A::B"라는 이름을 가지고 삭제되지도 않은 채 어딘가에 살아있을 가능성이 있다.

이 '부모 네임스페이스'는 자동 로딩 알고리즘의 핵심이 되는 아이디어이며, 알고리즘 개발 중의 의도를 즉흥적으로 설명할 때에 도움이 됩니다만, 이 메타포만으로는 설명할 수 없는 부분이 많습니다. 실제 상황에서 어떤 일이 발생하는지 정확히 이해하기 위해서 여기에서 설명한 '부모 네임스페이스'라는 개념과 그 의미를 잘 이해한 뒤에, 이를 의식하면서 뒷부분을 읽어주세요.

### 로딩 메커니즘

`config.cache_classes`가 false일 경우 `Kernel#load`를 사용해서 로딩이 이루어집니다. 이것은 development 환경에서의 기본값입니다. 반면 `Kernel#require`를 사용한 로딩은 production 환경일 때의 기본값입니다.

[상수 리로딩](#상수-리로딩)이 활성화되어 있는 경우 `Kernel#load`가 사용되며, 파일을 반복해서 다시 읽어오게 됩니다.

여기에서는 '로딩'이라는 말을 지정된 파일이 Rails에 의해서 해석된다는 의미로 사용하고 있습니다만, 실제의 메카니즘에서는 플래그에 따라서 `Kernel#load`나 `Kernel#require`가 사용됩니다.


자동 로딩이 가능한 상황
------------------------

Rails는 적당한 환경이 준비되어 있으면 언제나 자동 로딩을 사용합니다. 예를 들어 다음의 `runner` 명령을 실행하면 자동 로딩을 사용합니다.

```
$ bin/rails runner 'p User.column_names'
["id", "email", "created_at", "updated_at"]
```

이 경우 콘솔, 테스트 세트, 애플리케이션의 모든 것들을 자동으로 로딩합니다.

production 환경에서 실행된 경우에는 기본으로 파일들을 한번에 읽어오기(eager loading) 때문에, development 환경처럼 자동 로딩이 거의 발생하지 않습니다. 단, 한번에 읽어오는 상황에서도 자동 로딩이 발생할 수 있습니다.

다음의 상황을 봅시다.

```ruby
class BeachHouse < House
end
```

`app/models/beach_house.rb`는 미리 읽어왔음에도 불구하고 `House`가 발견되지 않은 경우, Rails는 이 클래스를 자동 로딩합니다.


autoload_paths
--------------

여기에 대해서는 알고 계시는 분들이 많을 것입니다. 다음과 같이 `require`로 상대 경로를 지정했다고 합시다.

```ruby
require 'erb'
```

이 때, Ruby는 `$LOAD_PATH`로 지정되어 있는 폴더에서 이 파일을 탐색합니다. 구체적으로 Ruby는 지정된 모든 폴더에 대해서 재귀적으로 "erb.rb"나 "erb.so", "erb.dll" 등의 이름을 가지는 파일이 있는지를 확인합니다. 이에 해당하는 파일을 발견하면 Ruby 인터프리터에 파일을 읽어오고 탐색을 거기에서 종료합니다. 발견하지 못한 경우에는 목록에 있는 다른 폴더에 대해서 같은 탐색 작업을 수행합니다. 목록을 전부 탐색한 뒤에도 발견하지 못한 경우에는 `LoadError`가 발생합니다.

여기부터는 상수의 자동 로딩을 자세하게 설명합니다만, 그 핵심에 있는 아이디어는 다음과 같습니다. 예를 들어 `Post`와 같은 상수가 코드에 출현한 시점에서는 아직 정의되지 않은 상태라고 가정합니다. 이 때 `app/models` 폴더에 `post.rb`라는 파일이 있다면, Rails는 이 상수를 탐색, 평가하고 그 결과 `Post`라는 상수를 '사이드 이펙트'로서 정의합니다.

그런데, Rails에는 `post.rb`와 같은 파일을 탐색하는 `$LOAD_PATH`와 비슷한 폴더 목록이 있습니다. 이 목록은 `autoload_paths`이라고 불리고 있으며 기본으로는 다음과 같은 것들이 포함되어 있습니다.

* 실행 시점에 존재하는 애플리케이션과 엔진의 `app` 폴더 하의 모든 폴더들. `app/controllers` 등이 대상. `app` 밑에 있는 `app/workers` 등의 폴더들도 모두 `autoload_paths`에 자동적으로 포함되므로, 기본 폴더로 지정할 필요는 없습니다.

* 애플리케이션과 엔진의 모든 `app/*/concerns` 제2의 하위 폴더.

* `test/mailers/previews` 폴더

이 목록은 `config.autoload_paths`에서 변경할 수 있습니다. 예를 들어, `lib` 폴더는 이전에는 목록에 포함되어 있었습니다만, 현재는 포함되지 않습니다. 필요하다면 `config/application.rb`에 다음의 코드를 추가하여 `lib` 폴더를 autoload_paths에 추가할 수 있습니다.

```ruby
config.autoload_paths += "#{Rails.root}/lib"
```

`autoload_paths`의 값을 직접 확인해볼 수도 있습니다. 방금 생성한 Rails 애플리케이션에서는 다음과 같은 느낌입니다.

```
$ bin/rails r 'puts ActiveSupport::Dependencies.autoload_paths'
.../app/assets
.../app/controllers
.../app/helpers
.../app/mailers
.../app/models
.../app/controllers/concerns
.../app/models/concerns
.../test/mailers/previews
```

INFO: `autoload_paths`는 초기화 중에 계산되어 캐싱됩니다. 폴더의 구조가 조금이라도 변경된 경우, 이 변경을 반영하기 위해서는 애플리케이션을 다시 기동해야합니다.


자동 로딩 알고리즘
----------------------

### 상대참조

상수의 상대참조는 다음과 같이 다양한 곳에서 이루어집니다.

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

이 코드에서 사용되고 있는 3개의 상수는 모두 상대참조를 사용하고 있습니다.

#### `class`, 그리고 `module` 키워드 뒤에 있는 상수

Ruby는 `class`나 `module` 키워드의 뒤에 오는 상수를 탐색합니다. 그러한 클래스나 모듈이 그 장소에서 처음 생성된 것인지, 재정의하는 것인지를 확인하기 위해서입니다.

그 시점에서 상수가 정의되어 있지 않은 경우, Ruby는 상수가 발견되지 않았으므로, 자동 로딩을 하지 않습니다.

직전의 예제로 설명하자면, 파일이 Ruby 인터프리터에 의해서 해석되는 시점에서 `PostsController`가 정의되어 있지 않은 경우, Rails의 자동 로딩이 실행되지 않고, Ruby는 단순히 컨트롤러를 새로 정의합니다.

#### 최상위 상수

반대로 `ApplicationController`가 지금까지 출현한 적이 없었던 경우, 이 상수는 '발견되지 않았음'으로 간주되어 Rails에 의해서 자동 로딩이 실행됩니다.

Rails는 `ApplicationController`를 로딩하기 위해서 `autoload_paths`에 존재하는 경로들을 순서대로 탐색합니다. 처음에 `app/assets/application_controller.rb`가 존재하는지를 확인합니다. 발견하지 못한 경우(이것이 정상입니다), 다음 경로로 `app/controllers/application_controller.rb`를 탐색합니다.

발견한 파일에서 `ApplicationController`가 정의되어 있으면 OK입니다. 정의되지 않은 경우에는 `LoadError`를 발생시킵니다.

```
unable to autoload constant ApplicationController, expected <application_controller.rb의 전체 경로> to define it (LoadError)
```

INFO: Rails에서는 자동 로딩된 상수의 값이 클래스 객체이거나 모듈 객체일 필요는 없습니다. 예를 들어 `app/models/max_clients.rb`라는 파일에서 `MAX_CLIENTS = 100`라고 정의되어 있는 경우 `MAX_CLIENTS`의 자동 로딩은 문제없이 이루어집니다.

#### 네임스페이스

`ApplicationController`의 자동 로딩은 발생하는 시점에서의 네스트가 비어있기 때문에 `autoload_paths`의 폴더 목록에서 직접 이루어지는 것처럼 보입니다. `Post`의 경우는 이와 조금 다릅니다. 그 시점에서의 네스트는 `[PostsController]`이므로, 네임스페이스의 영향을 받기 때문입니다.

기본적인 발상은 아래에서 설명합니다.

```ruby
module Admin
  class BaseController < ApplicationController
    @@all_roles = Role.all
  end
end
```

`Role`을 자동 로딩하려면 부모의 네임스페이스나, 자기 자신에게서 `Role`이 정의가 되어있는지 아닌지를 체크합니다. 다시 말해서, 개념 상으로는 자동 로딩을 다음 순서대로 시도하게 됩니다.

```
Admin::BaseController::Role
Admin::Role
Role
```

여기가 중요합니다. 이를 실행하기 위해서 Rails는 `autoload_paths`의 경로를 파일명 순서대로 다음과 같이 탐색합니다.

```
admin/base_controller/role.rb
admin/role.rb
role.rb
```

탐색 대상이 되는 그 이외의 표준적인 폴더에 대해서는 뒤에서 설명합니다.

INFO. `'Constant::Name'.underscore`는 `Constant::Name`이 정의되어 있을 것이라고 기대되는 파일의 상대 경로를 돌려줍니다. 이 파일명에는 확장자를 포함하지 않습니다.

Rails가 `Post` 상수를 어떤식으로 다루어서 `PostsController`에서 자동으로 읽어오는지 자세히 살펴봅시다. 이 애플리케이션에서는 `app/models/post.rb`에 `Post` 모델이 있다고 가정합니다.

처음에 `autoload_paths`의 경로 중에서 `posts_controller/post.rb`가 있는지를 확인합니다.

```
app/assets/posts_controller/post.rb
app/controllers/posts_controller/post.rb
app/helpers/posts_controller/post.rb
...
test/mailers/previews/posts_controller/post.rb
```

이 탐색은 실패하므로, 다음에는 폴더의 유무를 확인합니다. 그 이유에 대해서는 [다음 절](#자동-모듈)에서 설명합니다.

```
app/assets/posts_controller/post
app/controllers/posts_controller/post
app/helpers/posts_controller/post
...
test/mailers/previews/posts_controller/post
```

이 탐색이 모두 실패하면, Rails는 부모의 네임스페이스에서 탐색을 진행합니다. 이 예제의 경우, 부모는 최상위뿐입니다.

```
app/assets/post.rb
app/controllers/post.rb
app/helpers/post.rb
app/mailers/post.rb
app/models/post.rb
```

드디어 매칭되는 파일 `app/models/post.rb`를 찾았습니다. 탐색은 여기서 종료하고, 파일을 읽어옵니다. `Post`가 이 파일에 실제로 정의되어 있다면 OK입니다. 정의되어 있지 않다면 `LoadError`를 발생시킵니다.

### 검증된 상수 참조

검증된(qualified) 상수를 찾을 수 없는 경우, 이 상수는 부모의 네임스페이스에서 탐색하지 않습니다. 단, 여기에서는 주의해야할 점이 있습니다. 상수가 발견되지 않는 경우, Rails는 그 트리거가 상대 참조인지, 검증된 상수 참조인지 알 수 없게 됩니다.

다음의 예제를 봅시다.

```ruby
module Admin
  User
end
```

그리고 다음의 코드가 있습니다.

```ruby
Admin::User
```

`User`가 발견되지 않는다면 어느 쪽이든 Rails는 "User"라는 상수가 "Admin"이라는 모듈에는 없다는 것을 이해합니다.

이 `User`가 최상위에 있다고 가정하면, 첫번째의 예제는 Ruby에 의해서 해결됩니다만, 두번째의 예제는 그렇지 않습니다. Rails는 Ruby의 상수 해결 알고리즘을 모방하지 않으므로, 이러한 경우에는 다음의 휴리스틱을 이용해서 해결을 시도합니다.

> 발견되지 않는 상수가 그 클래스, 또는 모듈의 부모 네임스페이스에도 없는 경우, Rails는 그 상수를 상대참조라고 가정한다. 그렇지 않은 경우에는 검증된 상수 참조라고 가정한다.

예를 들자면, 다음의 코드가 자동 로딩을 하고,

```ruby
Admin::User
```

`User` 상수가 `Object`에 이미 존재하는 경우, 다음의 코드에서는 같은 상황이 발생하지 않습니다.

```ruby
module Admin
  User
end
```

그렇지 않다면 Ruby는 `User`를 해결할 수 있으며, 애초에 처음 위치에서 자동로딩이 발생하지 않을 것입니다. 이러한 경우 Rails는 이 상수가 검증된 상수라고 가정하고, `admin/user.rb` 파일과 `admin/user` 폴더만이 올바른 선택지라고 생각합니다.

이 중첩이 모든 부모 네임스페이스에 각각 매칭하고, 그 규칙을 적용시킨 상수의 존재가 그 시점에서 Ruby에게 인식되어 있다면 이 방법은 실질적으로 문제없이 동작합니다.

하지만 자동 로딩은 요구에 따라서 발생하는 것입니다. 그 시점에서 운나쁘게 최상위에 `User`가 로딩되어 있지 않다면, Rails는 이 휴리스틱에 따라서 상수를 상대참조일 것이라고 가정하게 됩니다.

이러한 이름의 경합은 실제로는 거의 발생하지 않습니다만, 만약 이로 인한 문제가 발생한 경우는 `require_dependency`를 사용해서 이 휴리스틱을 발생시키는 상수를 정의해야합니다.

### 자동 모듈

모듈이 하나의 네임스페이스처럼 동작하는 경우, Rails 애플리케이션에서 그 모듈을 위한 파일을 정의할 필요가 없습니다. 그 네임스페이스에 매칭하는 폴더를 만들기만 하면 됩니다.

어떤 Rails 애플리케이션에 관리 기능이 있어, 이를 위한 컨트롤러가 `app/controllers/admin`에 저장한다고 해봅시다. 이 `Admin` 모듈이 로딩되지 않은 상태에서 `Admin::UsersController`에 대한 접근이 발생한 경우, Rails는 우선 `Admin`이라는 상수를 자동 로딩해야합니다.

`admin.rb`라는 파일이 `autoload_paths`의 경로에 포함되어 있는 경우에는 Rails가 자동으로 불러옵니다. 하지만 그런 파일이 발견되지 않고 `admin`라는 폴더가 발견 된 경우, Rails는 빈 모듈을 하나 만들고 `Admin` 상수를 거기에 대입합니다.

### 일반적인 순서

상대참조는 발견된 cref에는 발견되지 않았다고 보고됩니다. 검증된 상수 참조는 그 부모로부터 발견되지 않았다고 보고됩니다(*cref*의 정의에 대해서는 [상대 상수를 해결하는 알고리즘](#상대-상수를-해결하는-알고리)를, *부모*의 정의에 대해서는 [검증된 상수를 해결하는 알고리즘](#검증된-상수를-해결하는-알고리즘)를 참조해주세요).

임의의 상황에서 상수`C`를 자동 로딩하는 순서를 과정은 다음과 같이 표현할 수 있습니다.

```
if 상수 C가 발견되지 않은 클래스 또는 모듈 객체
  let ns = ''
else
  let M = 상수C가 발견되지 않은 클래스 또는 모듈

  if M이 익명임
    let ns = ''
  else
    let ns = M.name
  end
end

loop do
  # 일반 파일들을 탐색
  for dir in autoload_paths
    if "#{dir}/#{ns.underscore}/c.rb" 파일이 존재
      load/require "#{dir}/#{ns.underscore}/c.rb"

      if 상수C가 정의되어 있음
        return
      else
        raise LoadError
      end
    end
  end

  # 자동 모듈을 탐색
  for dir in autoload_paths
    if "#{dir}/#{ns.underscore}/c" 폴더가 존재
      if ns가 공백문자임
        let C = Module.new in Object and return
      else
        let C = Module.new in ns.constantize and return
      end
    end
  end

  if ns이 비었음
    # 상수가 발견되지 않은 채 최상위 네임스페이스에 도착
    raise NameError
  else
    if C가 부모 네임스페이스 어딘가에 존재
      # 검증된 상수의 휴리스틱
      raise NameError
    else
      # 부모의 네임스페이스에서 탐색을 재시도
      let ns = the parent namespace of ns and retry
    end
  end
end
```


require_dependency
------------------

상수의 자동 로딩은 필요에 따라서 자동적으로 이루어지므로, 사용할 때에는 정의가 되어 있는 상수도 있고, 자동 로딩을 발생시키는 상수도 있어 동작이 일정하지 않습니다. 자동 로딩은 실행 경로에 의존합니다만, 실행 경로는 애플리케이션이 실행하는 도중에 변경될 수 있으므로, 이 역시 일정하지 않습니다.

하지만 이러한 상수의 동작을 확실히 만들고 싶은 경우가 가끔 있습니다. 특정 코드를 실행할 때에 거기에 있는 상수가 존재하고 있는 것처럼 만들어서 자동 로딩이 발생하지 않도록 할수는 없을까요? 이러한 경우에는 `require_dependency`를 사용합니다. 이것은 그 시점에서 [로딩 메커니즘](#로딩-메커니즘)을 사용해서 파일을 읽어올 수 있으며, 필요에 따라서 그 파일에 정의되어 있는 상수를 이미 읽어둔 것처럼 추적할 수도 있습니다.

`require_dependency`가 필요할 경우는 흔하지 않습니다만, [자동 로딩과 STI](#자동-로딩과-STI)나 [상수가 트리거되지 않는 경우](#상수가-트리거되지-않는-경우)에서 몇가지 실제 예시를 참고해주세요.

WARNING: `require_dependency`는 자동 로딩과는 다르며, 그 파일에서 특정 상수가 정의되어 있을 것을 전제하지 않습니다. 이 동작에 의존하는 것은 좋지 않습니다만, 파일과 상수의 경로를 일치시켜둘 필요가 있습니다.


상수 리로딩
------------------

`config.cache_classes`가 false인 경우, Rails는 자동 로딩된 상수를 다시 불러오게 됩니다.

예를 들어 Rails의 콘솔 세션을 열어둔 상태에서, 몇몇 파일이 갱신된 경우, `reload!` 명령을 사용해서 상수들을 다시 읽어올 수 있습니다.

```
> reload!
```

애플리케이션을 실행하는 도중에 로직을 변경되면, 리로딩이 발생합니다. 이를 실현하기 위해서 Rails는 아래의 다양한 파일들을 감시하고 있습니다.

* `config/routes.rb`

* 로케일

* `autoload_paths`의 경로에 존재하는 Ruby 파일

* `db/schema.rb`와 `db/structure.sql` 파일

이 중에 어떤 파일이 변경되면, 미들웨어가 변경사항을 확인한 코드를 다시 읽어오게 됩니다.

자동 로딩된 상수는 자동 로딩 인프라에 의해서 감시받습니다. 리로딩의 구체적인 구현은 `Module#remove_const` 메소드를 호출하여 관련된 클래스와 모듈을 전부 삭제하는 식입니다. 이를 통해서 그 코드가 실행되면 상수가 다시 알 수 없는 상수가 되므로, 필요에 따라서 파일을 다시 불러오게 됩니다.

INFO: 이 동작은 'all-or-nothing'입니다. Rails의 클래스나 모듈 간에는 무척 미묘한 의존관계가 있기 때문에, 변경이 발생한 클래스나 모듈만이 부분적으로 리로딩되는 것이 아닙니다. 대신, 클래스나 모듈은 변경이 발생될 때마다 모두 삭제됩니다.


Module#autoload가 관여하지 않는 경우
------------------------------

`Module#autoload`는 상수를 지연 로딩하는 기능을 제공합니다. 이 기능은 Ruby의 상수 탐색 알고리즘이나 동적 상수 API등과 완전히 통합되어 있습니다. 이 동작은 굉장히 투명합니다.

Rails 내부에서는 기동 프로세스 이후의 작업을 가능한 지연시키기 위해서 이 기능을 폭넓게 사용하고 있습니다. 단, Rails의 상수 자동 로딩에서는 `Module#autoload`를 사용해서 **구현하지 않았습니다**.

구현에서 `Module#autoload`를 사용하는 한가지 방법은 예를 들어 애플리케이션의 트리를 전부 스캔하여 기존의 파일명과 기존의 상수명을 연결하기 위해서 `autoload`를 호출하는 것입니다.

하지만 Rails에서 이러한 구현을 하지 않는 데에는 몇가지 이유가 있습니다.

예를 들어, `Module#autoload`는 `require`를 사용하는 파일만을 로딩할 수 있기 때문에, 리로딩에서는 사용할 수 없습니다. 심지어, 이 모듈 내부에서는 `Kernel#require`와는 다른 `require`가 사용되고 있습니다.

이 때문에 이 모듈에서는 파일이 삭제된 경우에도 그 선언을 삭제할 방법을 제공하지 않습니다. 상수를`Module#remove_const`로 삭제하면 나중에 `autoload`를 사용할 수 없게 됩니다. 또한 이 모듈에서는 검증된 상수명을 지원하지 않습니다. 애플리케이션의 트리를 탐색하여 각각의 `autoload` 호출을 설치할 때 네임스페이스를 해석해야 합니다만, 그러한 파일의 상수 참조가 그 시점에서는 아직 구성이 되어있지 않을 가능성이 있습니다.

`Module#autoload`를 사용해서 자동 로딩을 구현했으면 좋았습니다만, 위에서 설명한 이유로 현 시점에서는 어렵습니다. Rails의 상수 자동 로딩은 현재 `Module#const_missing`를 사용해서 구현되어 있습니다. 이러한 방법을 사용한 것은 위에서 설명한 이유 때문입니다.


자주하는 실수
--------------

### 중첩과 검증된 상수

아래의 두 가지에 대해서 생각해봅시다.

```ruby
module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all
    end
  end
end
```

그리고,

```ruby
class Admin::UsersController < ApplicationController
  def index
    @users = User.all
  end
end
```

Ruby는 `User`를 해결하기 위해서 첫번째 예제에서는 `Admin`을 확인합니다만, 두번째의 예시에서는 중첩에 속해있지 않으므로 `Admin`을 확인하지 않습니다([중첩](#중첩), [해결 알고리즘](#해결 알고리즘)을 참고).

아쉽게도 Rails의 자동 로딩은 이 상수가 발견되지 않는 상황에서 중첩이 발생했는지 아닌지를 인식하지 못하므로, 일반적인 Ruby와 마찬가지로 동작하지 않습니다. 특히 `Admin::User`는 어느 경우에도 자동 로딩이 발생합니다.

몇몇 상황에서 `class` 키워드나 `module` 키워드의 검증된 상수는 자동 로딩이 동작하기는 하지만, 검증된 상수보다는 상대 상수를 사용하기를 권장합니다.

```ruby
module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all
    end
  end
end
```

### 자동 로딩과 STI

단일 테이블 상속(STI: Single Table Inheritance)는 Active Record의 기능 중 하나로, 모델의 계층구조를 하나의 테이블로 저장할 수 있습니다. 이러한 모델의 API는 계층 구조를 인식하고 자주 사용되는 요소가 거기에 캡슐화됩니다. 예를 들자면, 다음과 같은 클래스가 있다고 합시다.

```ruby
# app/models/polygon.rb
class Polygon < ActiveRecord::Base
end

# app/models/triangle.rb
class Triangle < Polygon
end

# app/models/rectangle.rb
class Rectangle < Polygon
end
```

`Triangle.create`는 삼각형을 나타내는 레코드를 하나 생성하고 `Rectangle.create`는 사각형을 나타내는 레코드를 하나 만듭니다. `id`는 기존의 레코드의 ID라면 `Polygon.find(id)`로 올바른 종류의 객체를 가져올 수 있습니다.

컬렉션에 대해서 실행되는 메소드는 계층구조도 인식합니다. 예를 들어, 삼각혀오가 사각형, 둘다 다각형(polygon)에 포함되므로 `Polygon.all`은 테이블의 모든 레코드를 가져옵니다. Active Record가ㅏ 반환한 결과에서는 결과마다 거기에 맞는 클래스 객체를 반환하도록 되어 있습니다.

종류는 필요에 따라서 자동 로딩됩니다. 예를 들어 `Polygon.first`의 결과가 사각형(rectangle)이고, `Rectangle`가 그 시점에 로딩되지 않았다면 Active Record에 의해서 `Rectangle`가 로딩되어 그 레코드는 올바르게 인스턴스로 변환됩니다.

여기까지는 아무런 문제도 없습니다. 하지만 최상위 클래스에서의 쿼리가 아닌, 어떤 하위 클래스를 사용해야만 하는 상황의 경우에는 사정이 다릅니다.

`Polygon`을 조작하려면 테이블 내의 모든 값은 polygon으로 정의되어 있으므로, 어떤 자식에 대해서도 따로 고려할 필요는 없습니다, 단 `Polygon`의 하위 클래스에서 조작을 하는 경우, Active Record가 탐색하려는 것들을 그 하위 클래스에서 사용가능하게 만들어야 합니다. 다음의 예시를 봅시다.

아래와 같이, 쿼리에 가져오고 싶은 종류 제한을 추가하면 `Rectangle.all`은 rectangle만을 가져옵니다.

```sql
SELECT "polygons".* FROM "polygons"
WHERE "polygons"."type" IN ("Rectangle")
```

이번에는 `Rectangle`의 하위 클래스를 만들어봅시다.

```ruby
# app/models/square.rb
class Square < Rectangle
end
```

`Rectangle.all`는 사각형과 정사각형을 **모두** 돌려줍니다.

```sql
SELECT "polygons".* FROM "polygons"
WHERE "polygons"."type" IN ("Rectangle", "Square")
```

단 여기에서는 주의가 필요합니다. Active Record는 `Square` 클래스의 존재를 어떤식으로 이해하고 있는 것일까요?

`app/models/square.rb`라는 파일이 존재해서 `Square`가 정의되어 있다고 하더라도, 클래스 내의 코드가 그 시점까지 사용된 적이 없었다면 `Rectangle.all`에 의해서 다음의 쿼리가 생성됩니다.

```sql
SELECT "polygons".* FROM "polygons"
WHERE "polygons"."type" IN ("Rectangle")
```

이것은 버그가 아닙니다. `Rectangle` 클래스의 그 시점에서 *알려진* 자식이 쿼리에 모두 포함되어 있습니다.

코드의 실행순서에 관계없이 항상 기대한 대로 동작하게 만드는 수단으로서, 최상위 클래스가 정의되어 있는 파일에 그 자식 클래스를 명시적으로 로딩하는 방법이 있습니다.

```ruby
# app/models/polygon.rb
class Polygon < ActiveRecord::Base
end
require_dependency ‘square’
```

이 방법으로 명시적으로 읽어와야 하는 것은 **최하위에 있는** 클래스들로 충분합니다. 직계 사직에 대해서는 미리 불러올 필요가 없습니다. 만약 계층 구조가 더 복잡하더라도, 가장 하위에 있는 클래스를 지정해두면 그 중간에 포함되어 있는 클래스들은 재귀적으로 자동 로딩됩니다.

### 자동 로딩과 `require`

자동 로딩되는 상수를 정의한 파일은 `require`를 해서는 안됩니다.

```ruby
require 'user' # 실행하지 말 것

class UsersController < ApplicationController
  ...
end
```

이는 development 환경에서 다음의 두가지 문제를 야기할 가능성이 있습니다.

1. 이 `require`가 실행되기 전에 `User`가 자동 로딩되면 `$LOADED_FEATURES`가 `load`에 의해서 갱신되지 않으므로, `app/models/user.rb`가 다시 실행되고 맙니다.

2. 이 `require`가 처음에 실행되면 Rails는 `User`를 자동 로딩 상수라고 인식하지 않기 때문에 `app/models/user.rb`의 변경사항을 반영하지 못하게 됩니다.

흐름에 따라서 '항상' 상수의 자동 로딩을 사용해주세요. 자동 로딩과 `require`는 절대로 함께 사용해서는 안됩니다. 어쩔 수 없는 사정으로 파일에서 특정 파일을 읽어오고 싶은 경우에는 마지막 수단으로 `require_dependency`를 사용해서 상수를 자동 로딩과 함께 사용할 수 있도록 해주세요. 다만, 이 옵션이 실제로 필요한 경우는 거의 없을 것입니다.

물론 일반적인 플러그인 라이브러리들은 자동 로딩될 파일 내에서도 `require`로 불러오더라도 문제 없습니다. Rails는 플러그인 라이브러리의 상수를 구별하고 있으므로, 이들을 자동 로딩 대상으로 인식하지 않기 때문입니다.

### 자동 로딩과 initializer

`config/initializers/set_auth_service.rb`에서 아래의 대입을 쓰는 상황에 대해서 생각해봅시다.

```ruby
AUTH_SERVICE = if Rails.env.production?
  RealAuthService
else
  MockedAuthService
end
```

이 설정의 목적은 `AUTH_SERVICE`에서 각 환경에 대응한 클래스를 Rails 애플리케이션에서 사용하기 위함입니다. development 환경에서는 initializer를 실행할 때에 `MockedAuthService`가 자동 로딩 됩니다. 여기서 애플리케이션에 몇몇 요청을 처리한 뒤, 구현을 변경하고, 다시 애플리케이션에 접근했다고 합시다. 놀랍게도, 변경해둔 코드가 반영되지 않습니다. 이것은 왜일까요?

[위에서도](#상수-리로딩) 언급했듯, 자동 로딩된 상수는 Rails에 의해서 삭제됩니다만, `AUTH_SERVICE`에는 원래의 클래스가 저장되어 있습니다. 이 객체는 최신의 상태가 아니므로, 원래의 상수를 사용해서 접근 할 수 없게 되었습니다만, 완전히 동작합니다.

다음은 이 상황을 정리한 것입니다.

```ruby
class C
  def quack
    'quack!'
  end
end

X = C
Object.instance_eval { remove_const(:C) }
X.new.quack # => quack!
X.name      # => C
C           # => uninitialized constant C (NameError)
```

이러한 이유로, Rails 애플리케이션의 초기화 시에 상수를 자동 로딩하는 것은 좋은 아이디어라고 말할 수 없습니다.

이러한 경우에는 다음과 같이 동적인 접근 포인트를 구현하고,

```ruby
# app/models/auth_service.rb
class AuthService
  if Rails.env.production?
    def self.instance
      RealAuthService
    end
  else
    def self.instance
      MockedAuthService
    end
  end
end
```

나아가 애플리케이션에서 `AuthService.instance`를 이용하는 방법이 있습니다. `AuthService`는 필요에 따라서 로딩되고, 자동 로딩과 잘 동작합니다.

### `require_dependency`와 initializer

이미 언급했듯, `require_dependency`는 자동 로딩과 잘 동작하도록 파일을 불러옵니다. 하지만, 이러한 호출은 initializer에서는 의미가 없는 경우가 대부분입니다.

initializer 내에서 [`require_dependency`](#require-dependency)를 호출하여, 예를 들자면 [자동 로딩과 STI](#자동-로딩과-STI)의 문제를 해결하려고 했던 것처럼 특정 상수를 확실히 불러올 수 있습니다.

이 방법의 문제는 development 환경에서는 관련한 변경이 파일 시스템 상에서 발생하지 않은 경우에 [자동 로딩된 상수가 완전히 삭제된다는](#상수-리로딩) 점입니다. initializer에서의 이러한 상수의 완전 상제는 가급적 피하고 싶은 부분입니다.

자동 로딩이 발생하는 위치에서 `require_dependency`를 사용하는 경우에는 충분히 사용법을 고민해야 합니다.

### 상수가 트리거되지 않는 경우

#### 상대참조

비행 시뮬레이터에 대해 생각해봅시다. 이 애플리케이션에는 다음의 기본 비행 모델이 하나 있습니다.

```ruby
# app/models/flight_model.rb
class FlightModel
end
```

이것은 다음과 같이 각각 비행기에 덮어 씌울 수 있습니다.

```ruby
# app/models/bell_x1/flight_model.rb
module BellX1
  class FlightModel < FlightModel
  end
end

# app/models/bell_x1/aircraft.rb
module BellX1
  class Aircraft
    def initialize
      @flight_model = FlightModel.new
    end
  end
end
```

initializer는 `BellX1::FlightModel`을 하나 생성하려고 시도하고, 중첩에는 `BellX1`가 있습니다. 얼핏 보기에는 문제가 없어보입니다. 하지만 여기서 기본 비행 모델이 로딩되고, Bell-X1의 비행 모델이 로딩되지 않았다고 해봅시다. 이때, Ruby 인터프리터는 최상위의 `FlightModel`를 해결할 수 있으므로 `BellX1::FlightModel`의 자동 로딩이 실행되지 않습니다.

이 코드의 동작은 실행 경로의 내용에 의존합니다.

이러한 애매한 해결에는 다음과 같은 검증된 상수가 도움이 되는 경우가 가끔 있습니다.

```ruby
module BellX1
  class Plane
    def flight_model
      @flight_model ||= BellX1::FlightModel.new
    end
  end
end
```

다음고 같이 `require_dependency`를 사용해서 해결할 수도 있습니다.

```ruby
require_dependency 'bell_x1/flight_model'

module BellX1
  class Plane
    def flight_model
      @flight_model ||= FlightModel.new
    end
  end
end
```

#### 검증된 상수 참조

다음의 예제에 대해서 생각해봅시다.

```ruby
# app/models/hotel.rb
class Hotel
end

# app/models/image.rb
class Image
end

# app/models/hotel/image.rb
class Hotel
  class Image < Image
  end
end
```

`Hotel::Image`는 실행 경로에 의존하므로, 이 선언에는 불명확함이 있습니다.

[위에서 언급했듯](#검증된-상수를-해결하는-알고리즘), Ruby는 `Hotel`과 그 부모 상수를 탐색합니다. `app/models/image.rb`가 로딩되어 있지만 `app/models/hotel/image.rb`가 로딩되어 있지 않은 경우, Ruby는 `Image`를 `Hotel` 내에서가 아니라 `Object`에서 찾습니다.

```
$ bin/rails r 'Image; p Hotel::Image' 2>/dev/null
Image # Hotel::Image이 아님
```

`Hotel::Image`를 평가하는 코드는(아마도 `require_dependency`를 사용해서) `app/models/hotel/image.rb`를 사전에 읽어둘 필요가 있습니다.

단, 이 방법을 사용하는 경우, Ruby 인터프리터는 다음과 같은 경고를 출력합니다.

```
warning: toplevel constant Image referenced by Hotel::Image
```

이런 놀라운 상수 해결 방법은 사실 어떤 클래스의 검증할 때에도 볼 수 있습니다.

```
2.1.5 :001 > String::Array
(irb):1: warning: toplevel constant Array referenced by String::Array
=> Array
```

WARNING: 이 문제를 실제로 발견하려면, 네임스페이스의 수식부가 클래스일 필요가 있습니다. `Object`는 모듈의 상위 클래스가 아니기 때문입니다.

### 싱글톤 클래스에서 자동 로딩하기

다음의 클래스 정의를 생각해봅시다.

```ruby
# app/models/hotel/services.rb
module Hotel
  class Services
  end
end

# app/models/hotel/geo_location.rb
module Hotel
  class GeoLocation
    class << self
      Services
    end
  end
end
```

`app/models/hotel/geo_location.rb`가 로딩되기 전에 `Hotel::Services`가 인식되어 있다면, `Services`는 Ruby에 의해서 해결됩니다. 이것은 `Hotel::GeoLocation`의 싱글톤 클래스가 열려 있을 때 `Hotel`이 중첩에 포함되어 있기 때문입니다.

하지만 `Hotel::Services`가 그 시점에서 인식되어 있지 않다면, Rails는 `Hotel::Services`를 자동 로딩하지 못하고 `NameError`를 던집니다.

그 이유는 자동 로딩은 싱글톤 클래스를 위해서 발생하기 때문입니다. 싱글톤 클래스는 익명이며, Rails는 [위에서 설명](#일반적인-순서)한대로 극단적인 상황에서는 최상위 도메인만 확인하기 때문입니다.

이 경고를 해결하는 간단한 방법으로는, 상수를 검증된 상수로 바꾸는 법이 있습니다.

```ruby
module Hotel
  class GeoLocation
    class << self
      Hotel::Services
    end
  end
end
```

### `BasicObject`에서 자동 로딩을 하기

`BasicObject`의 직계 자손에 대해서는 그 조상에 `Object`가 존재하지 않기 때문에 최상위 레벨의 상수를 해결할 수 없습니다.

```ruby
class C < BasicObject
  String # NameError: uninitialized constant C::String
end
```

여기에서 자동 로딩이 포함되면 상황이 복잡해집니다. 다음을 생각해봅시다.

```ruby
class C < BasicObject
  def user
    User # 실수
  end
end
```

Rails는 최상위 레벨의 네임스페이스를 확인하므로, 자동 로딩된 `User`는 `user` 메소드가 '처음' 호출될 때에는 문제 없이 동작합니다. 그러나 `User` 상수를 알고 있는 경우, 특히 `user`를 *2번째로* 호출한 경우에는 예외가 발생합니다.

```ruby
c = C.new
c.user # 놀랍게도 문제가 없음
c.user # NameError: uninitialized constant C::User
```

이것은 부모 네임스페이스에 이미 상수가 존재하기 때문입니다([검증된 상수 참조](#검증된-상수-참조)를 참고).

순수한 Ruby와 마찬가지로 `BasicObject`의 직계 자손 객체에는 언제나 절대 상수 경로를 사용해주세요.

```ruby
class C < BasicObject
  ::String # 올바름

  def user
    ::User # 올바름
  end
end
```

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
