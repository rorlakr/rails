
API 문서 작성 가이드라인
============================

이 가이드에서는 Rails API 문서 작성 가이드라인에 대해서 설명합니다(역주: API 문서가 영어로 작성되어 있다는 것을 전제로 합니다. 또한, 샘플의 주석은 영어를 그대로 두었습니다).

이 가이드의 내용:

* API 문서를 효과적으로 작성하기
* 문서 작성용 스타일 가이드(Ruby 코드 개발용의 스타일 가이드와는 다름)

--------------------------------------------------------------------------------

RDoc
----

[Rails API 문서](http://api.rubyonrails.org)는 [RDoc](http://docs.seattlerb.org/rdoc/)을 사용하여 생성됩니다.

```bash
  bundle exec rake rdoc
```

생성된 HTML 파일은 `./doc/rdoc` 폴더에 저장됩니다.

RDoc 작성법에 대해서는 [markup](http://docs.seattlerb.org/rdoc/RDoc/Markup.html)을 참고해주세요. [추가 설명](http://docs.seattlerb.org/rdoc/RDoc/Parser/Ruby.html)도 참고해주세요.

어조
-------

간결하고 선언적으로 작성할 것. 간결함은 그 자체로 장점이 됩니다.

현재형으로 작성할 것. "Returned a hash that..."나 "Will return a hash that..."가 아닌 "Returns a hash that..."처럼 작성합니다.

주석의 영문은 대문자로 시작할 것. 마침표 등의 기호의 사용법은 상식에 따를 것.

```ruby
# Declares an attribute reader backed by an internally-named
# instance variable.
def attr_internal_reader(*attrs)
  ...
end
```

읽는 사람에게 현 시점의 최신 방법을 알려줄 것. 그것도 간결하고 명시적으로. 앞서나가고 있는 분야에서 권장되는 관용 표현을 사용할 것. 권장된 방법이 강조되는 절의 순서에 주의하고, 필요하다면 순서를 바꿀 것. 작성된 문서 자신이 Rails의 가장 좋은 예제가 되도록, 그리고 Rails의 최신의 방법을 사용하는 모범적인 사용 예시가 되도록 작성할 것.

문서는 간결하고, 전체를 이해하기 쉽게할 것. 예외적인 케이스에 대해서도 확인하고, 문서에 포함할 것. 어떤 모듈이 익명이면 어떻게 되는가. 어떤 컬렉션의 내용이 비어있을 경우에는 어떻게 되는가. 인수가 nil인 경우에는 어떻게 되는가.

Rails의 컴포넌트 이름은 단어 사이에 공백 문자를 하나 사용하는 것을 공식 표현으로 사용할 것(예: "Active Support"). 그리고 `ActiveRecord`는 Ruby 모듈 이름이지만 Active Record는 ORM을 가리킴. Rails 문서에서 컴포넌트를 가리킬 경우에는 항상 정식 명칭을 사용할 것. 블로그 투고나 발표에서도 이 점에 주의하여 다른 명칭으로 독자를 혼란스럽게 만들지 말 것.

올바른 용어를 사용할 것(Arel, Test::Unit, RSpec, HTML, MySQL, JavaScript, ERB 등). 대문자, 소문자에 주의할 것. 애매한 경우에는 공식 문서 등, 신뢰할 수있는 정보원을 참고할 것.

"SQL"라는 표현의 앞에는 관사 "an"를 사용할 것(例: "an SQL statement"). 마찬가지로 "an SQLite database"처럼 사용할 것.

"you"나 "your"를 사용하는 표현을 피할 것. 이하의 예문에서는 you가 3번 사용되고 있습니다.

```markdown
If you need to use `return` statements in your callbacks, it is recommended that you explicitly define them as methods.
```

다음의 스타일로 작성할 것.

```markdown
If `return` is needed it is recommended to explicitly define a method.
```

마찬가지로 설명에서 어떤 인물을 가정하여 그 인물을 대명사로 부르는 경우("a user with a session cookie" 등), he나 she와 같은 성별이 있는 대명사를 피하고, they/their/them같은 성별에 영향을 받지 않는 대명사를 사용할 것. 다음과 같이 바꿔쓰세요.

* he 또는 she -> they로 바꾸기
* him 또는 her -> them로 바꾸기
* his 또는 her -> their로 바꾸기
* his 또는 hers -> theirs로 바꾸기
* himself 또는 herself -> themselves로 바꾸기

영어
-------

미국식 영어를 사용할 것(*color*, *center*, *modularize* 등). 자세한 것은 [미국식 영어와 영국식 영어의 단어 차이](http://en.wikipedia.org/wiki/American_and_British_English_spelling_differences)(영어)를 참고해주세요.

샘플 코드
------------

의미가 있는 샘플 코드를 사용할 것. 개요와 기본을 간단하게 보일 수 있고, 흥미 깊은 점이나 함정을 바로 확인할 수 있는 것이 이상적입니다.

샘플 코드의 들여쓰기에는 공백 문자 2개를 사용할 것. 마크업용으로는 왼쪽 여백에 맞추어서 공백 2개를 사용합니다. 샘플 코드의 예시는 [Rails 코딩 규칙을 따르기](contributing_to_ruby_on_rails.html#Rails-코딩-규칙을-따르기)를 참고하세요.

짧은 문서에서는 간단한 코드를 소개할 때에 "Examples"라고 명시적으로 이름 붙일 필요는 없습니다. 단순히 따라 나오도록 만듭니다.

```ruby
# Converts a collection of elements into a formatted string by
# calling +to_s+ on all elements and joining them.
#
#   Blog.all.to_formatted_s # => "First PostSecond PostThird Post"
```

반대로 큰 절들로 구성되어 있는 문서라면 "Examples" 절을 만들어도 좋습니다.

```ruby
# ==== Examples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```

식의 실행 결과를 함께 적는 경우, 앞 부분에 "# => "를 추가해서 횡으로 정렬하세요.

```ruby
# For checking if a fixnum is even or odd.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

하나의 줄이 너무 길어지는 경우 주석을 다음 줄에 작성해도 좋습니다.

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

실행 결괴를 보이기 위해 `puts`나 `p`등의 출력 메소드 사용을 피하세요.

반대로 실행결과를 보여주지 않는 일반 주석에서 화살표를 사용하지 않을 것.

```ruby
#   polymorphic_url(record)  # same as comment_url(record)
```

논리값
--------

메소드나 플래그에서 논리값은, 정확한 값 표현보다 논리값의 의미를 우선할 것.

"true" 그리고 "false"를 Ruby의 정의대로 사용하는 경우에는 일반체로 사용할 것. 싱글톤의 `true` 그리고 `false`는 폭이 동일한 폰트로 표기할 것(역주: 싱글톤의 `true`와 `false`란 `TrueClass`와 `FalseClass`의 유일한 인스턴스를 가리킵니다). "truthy"와 같은 용어를 피해주세요. Ruby에서는 언어 레벨로 true와 false가 정의되어 있으므로 이들의 용어는 기술적으로는 엄밀한 정의가 부여되어 있으며, 표현을 바꿀 필요는 없습니다.

경험적으로 말씀드리자면, 반드시 필요한 경우를 제외하고 문서에서 싱글톤을 사용할 필요는 없습니다. 싱글톤을 피하면 `!!`나 삼항연산자 같은 인공적인 표현도 피할수 있으며, 리팩토링도 작성하기 용이해집니다. 나아가 실제로 호출되는 메소드가 돌려주는 값의 표현이 조금이라도 다르면 코드가 정상적으로 동작하지 않는다는 사태를 피할 수 있습니다.

다음에서 예제를 설명합니다.

```markdown
`config.action_mailer.perform_deliveries` specifies whether mail will actually be delivered and is true by default(번역: `config.action_mailer.perform_deliveries`는 메일을 실제로 전송할지 말지를 지정합니다. 기본 값은 true입니다).
```

이 예제에서는 플래그의 기본값의 실제 표현이 어떤지(역주: 싱글톤의 true인지, true로 평가되는 객체인지) 알 필요는 없습니다. 따라서, 논리값의 의미만을 문서에 남겨야 합니다.

다음은 예제입니다.

```ruby
# Returns true if the collection is empty.
#
# If the collection has been loaded
# it is equivalent to <tt>collection.size.zero?</tt>. if the
# collection has not been loaded, it is equivalent to
# <tt>collection.exists?</tt>. If the collection has not already been
# loaded and you are going to fetch the records anyway it is better to
# check <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

이 API는 특정 값을 커밋하지 말라는 주의가 포함되어 있으며, 메소드에는 술어와 그 의미가 적혀있습니다. 이걸로 충분합니다.

파일 이름
----------

경험적으로 파일 이름은 Rails 애플리케이션의 최상위 폴더로부터 상대 경로로 기술합니다.

```
config/routes.rb            # YES
routes.rb                   # NO
RAILS_ROOT/config/routes.rb # NO
```

폰트
-----

### 폭이 동일한 폰트

다음의 경우에 폭이 동일한 폰트를 사용할 것.

* 상수, 특히 클래스명과 모듈명
* 메소드명
* 다음 리터럴: `nil`, `false`, `true`, `self`
* 심볼
* 메소드의 파라미터
* 파일명

```ruby
class Array
  # Calls +to_param+ on all its elements and joins the result with
  # slashes. This is used by +url_for+ in Action Pack.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

WARNING: 폭이 동일한 폰트를 `+...+`라는 마크업으로 표기할 수 있는 것은 일반 메소드명, 심볼, 경로(`/`를 사용하는 것)와 같은 간단한 것들에 한정됩니다. 이보다 복잡한 것에는 반드시 `<tt>...</tt>`로 마크업을 해주세요. 특히 네임스페이스를 사용하고 있는 클래스명이나 모듈명은 필수입니다(`<tt>ActiveRecord::Base</tt>` 등).

다음의 명령으로 RDoc의 출력을 간단히 확인할 수 있습니다.

```
$ echo "+:to_param+" | rdoc --pipe
#=> <p><code>:to_param</code></p>
```

### Regular 폰트

Ruby의 키워드에는 없는, 영어의 "true"와 "false"에는 (Italic이나 Bold가 아닌) regular 폰트를 사용할 것.

```ruby
# Runs all the validations within the specified context.
# Returns true if no errors are found, false otherwise.
#
# If the argument is false (default is +nil+), the context is
# set to <tt>:create</tt> if <tt>new_record?</tt> is true,
# and to <tt>:update</tt> if it is not.
#
# Validations with no <tt>:on</tt> option will run no
# matter the context. Validations with # some <tt>:on</tt>
# option will only run in the specified context.
def valid?(context = nil)
  ...
end
```

설명 목록
-----------------

항목(옵션이나 파라미터 목록 등)과 그 설명을 하이픈으로 연결할 것. 콜론은 심볼에서 사용되므로 하이픈을 쓰는 것이 가독성에 좋습니다.

```ruby
# * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+.
```

설명문은 일반 영어로서 대문자로 시작하고, 마침표로 끝낼 것.

동적으로 생성되는 메소드
-----------------------------

`(module|class)_eval(문자열)` 메소드로 생성된 메소드는 생성된 코드의 인스턴스 근처에 주석을 둡니다. 이렇게 작성된 주석에는 공백문자 2개 만큼을 들여쓰기 합니다.

```ruby
for severity in Severity.constants
  class_eval <<-EOT, __FILE__, __LINE__
    def #{severity.downcase}(message = nil, progname = nil, &block)  # def debug(message = nil, progname = nil, &block)
      add(#{severity}, message, progname, &block)                    #   add(DEBUG, message, progname, &block)
    end                                                              # end
                                                                     #
    def #{severity.downcase}?                                        # def debug?
      #{severity} >= @level                                          #   DEBUG >= @level
    end                                                              # end
  EOT
end
```

생성된 줄이 너무 많은 경우(200줄 이상), 주석을 호출 위에 올려주세요.

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}
```

메소드의 가시성
-----------------

Rails의 문서를 쓸 때에는 사용자이 사용하는 공개적인 API와 그 내부 API의 차이를 이해하는 것도 중요합니다.

많은 라이브러리와 마찬가지로 Rails에서도 내부 API의 정의에서 private 키워드가 사용됩니다. 하지만 공개 API의 규칙은 조금 다릅니다. Rails에서는 모든 public 메소드가 사용자에게 공개되어 사용된다는 전제를 가지지 않습니다. 대신에 그 메소드가 내부에서만 사용되는 API라는 점을 알리기 위해서 `:nodoc:` 디렉티브를 사용합니다.

다시 말해, Rails에서는 메소드가 `public`이더라도 사용자에게 공개되었다고는 말할 수 없습니다.

`ActiveRecord::Core::ClassMethods#arel_table`를 예로 들겠습니다.

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table #:nodoc:
    # 뭔가 작성한다.
  end
end
```

이 메소드는 얼핏 보기에 `ActiveRecord::Core`의 공개된 메소드이며, 실제로 잘못된 말은 아닙니다. 하지만 Rails 팀은 이런 종류의 메소드에 의존하지 않기를 바라고 있습니다. 이를 위해서 `:nodoc:`을 지정하여 설명이 문서에 포함되지 않도록 하고 있습니다. 이러한 메소드는 이름이나 반환값이 변경되거나, 클래스 자체가 사라지거나 하는 경우도 있습니다. 따라서, 이러한 코드들은 외부에 아무것도 보증해주지 않으며, 여기에 의존해서는 안됩니다. 이러한 API에 의존하게 되면, Rails의 버전을 올렸을 경우에 애플리케이션이나 gem이 망가질 위험성이 있습니다.

Rails 기여자가 문서를 작성할 경우, 그 API를 외부 개발자에게 공개해도 좋은지 항상 주의를 기울일 필요가 있습니다. Rails 팀은 공개된 API에 대해서 커다란 변경을 할 경우에는 반드시 Deprecated 안내 기간을 거치도록 하고 있습니다. 내무 메소드나 내부 클래스의 가시성이 private가 아닌 경우에는 `:nodoc:` 옵션을 지정하기를 권장합니다(나아가 가시성이 private인 경우에는 마찬가지로 취급됩니다). API가 안정되면 가시성을 변경할 수도 있습니다만, 후방 호환성을 유지하면서 공개 API로 변경하는 작업은 간단하지 않습니다.

클래스나 모듈에 대해서 `:nodoc:`를 지정한 경우, 그 안의 모든 메소드가 내부 API이며, 직접 접근해서는 안된다는 것을 의미합니다.

기존의 `:nodoc:` 지정을 함부러 변경하지 마세요. 이 디렉티브를 제거할 때에는 반드시 코어 팀의 누군가나, 그 코드를 만든 사람과 상담해주세요. `:nodoc:`이 제거되는 에러는 docrails 프로젝트에서보다 대부분의 경우 풀 리퀘스트에서 발생합니다.

`:nodoc:`를 추가하는 경우에도 조심해주세요. 문서에서 그 메소드나 클래스에 대한 설명이 사라지게 됩니다. 예를 들어, 어떤 메소드의 가시성을 private로부터 public으로 바뀌었을 때, 내부의 공개 메소드에 `:nodoc:`가 지정되어 있지 않았다는 상황이 있을 수 있습니다. 이러한 경우를 발견했다면 반드시 풀 리퀘스트를 통해 논의해주세요. 직접 docrails를 변경하지 말아주세요.

정리: Rails 팀은 가시성이 public이지만 내부에서만 사용하는 메소드나 클래스에는 `:nodoc:`를 사용합니다. API의 가시성을 변경하는 것은 신중하게 이루어져야하며 풀 리퀘스트를 통해 논의해주세요.

Rails 스택
-------------------------

Rails API의 일부를 문서로 만들 때에는, 그것이 Rails 스택의 일부가 된다는 점을 의식하는 것이 중요합니다.

다시 말해, 문서로 만들려는 메소드나 클래스의 스코프나 컨텍스트에 의해서 동작이 바뀔 가능성이 있다는 점입니다.

스택 전체를 고려하게 되면, 동작이 바뀌는 부분이 여기저기에서 발견됩니다. `ActionView::Helpers::AssetTagHelper#image_tag` 등이 그 대표적인 예시입니다.

```ruby
# image_tag("icon.png")
#   # => <img alt="Icon" src="/assets/icon.png" />
```

`#image_tag`는 기본으로 항상 `/images/icon.png`를 반환합니다만, 애셋 파이프라인 등을 포함하는 Rails 풀 스택으로 통하면 위와 같은 결과를 돌려주기도 합니다.

기본 Rails 스택을 사용하는 경우, 실제로 경험한 동작만을 고려하게 됩니다.

이러한 경우, 특정 메소드의 동작 뿐만이 아니라 _프레임워크_의 동작도 문서로 만드는 것이 좋습니다.

Rails 팀이 특정 API를 다루는 법에 대한 의문이 있으시면 가벼운 마음으로 [이슈 트래커](https://github.com/rails/rails/issues)를 통해 패치를 보내주세요.

TIP: 이 가이드는 [Rails Guilde 일본어판](http://railsguides.jp)으로부터 번역되었습니다.
