
Action View 폼 헬퍼
============

웹 애플리케이션에서의 폼(Form)은 유저 입력을 받기 위해서는 필수인 인터페이스입니다. 하지만 폼의 각 요소들의 명명법과 수많은 속성들 탓에 폼의 마크업은 쉽게 복잡해지고, 관리하기 어려워집니다. 그래서 Rails에서는 폼 마크업을 생성하기 위한 뷰 헬퍼를 제공하고, 이런 번잡한 작업을 할 필요를 없앴습니다. 하지만 현실에서의 사용 예제는 무척 다양하기 때문에, 개발자는 이것들을 실제로 사용하기 전에 헬퍼 메서드 간에 어떤 차이가 있는지 파악해야할 필요가 있습니다.

이 가이드의 내용:

* 검색 폼, 그리고 특정 모델을 사용하지 않는 일반적인 폼의 작성법
* 특정 데이터베이스 레코드의 생성/편집을 하는 모델 중심의 폼 작성법
* 여러 종류의 데이터로부터 선택 상자를 만드는 방법
* Rails가 제공하는 날짜 관련 헬퍼
* 파일 업로드용 폼이 어떻게 다른가
* 외부로 전송하는 폼을 작성하는 방법
* 복잡한 폼을 작성하는 방법

--------------------------------------------------------------------------------

NOTE: 이 가이드에서는 폼 헬퍼와 그 인수에 대한 모든 것을 설명하지 않습니다. 완전한 레퍼런스는 [Rails API 문서](http://api.rubyonrails.org/)를 참조해주세요.


기본적인 폼 작성하기
------------------------

가장 간단한 폼 헬퍼는 `form_tag`입니다.

```erb
<%= form_tag do %>
  Form contents
<% end %>
```

이 코드처럼 인수 없이 호출하게 되면 `<form>` 태그를 생성합니다. 이 폼의 목적지는 현재 페이지로, HTTP POST가 사용됩니다. 예를 들어, 현재 페이지가 `/home/index`인 경우 아래와 같은 HTML이 생성됩니다(읽기 쉽게끔 개행을 추가 했습니다).

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="utf8" type="hidden" value="&#x2713;" />
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Form contents
</form>
```

이 폼을 잘 보면 이상한 부분이 있다는 것을 눈치채셨나요? `div` 태그 내부에 2개의 hidden input이 있습니다. 이 div는 생략할 수 없으며, 없으면 폼이 정상적으로 전송할 수 없습니다. 처음의 `utf8` hidden input은 브라우저에게 폼에서 해당하는 문자 인코딩을 사용할 것을 강제합니다. 이것은 액션이 "GET"과 "POST"의 어느쪽이라도 모두 생성됩니다.

두번째의 hidden input인 `authenticity_token`는 **cross-site fequest forgery protection**를 위한 보안기능입니다. 이 요소는 GET을 사용하지 않는 모든 폼에서 생성됩니다(보안 기능이 활성화 되어있는 경우). 자세한 설명은 [보안 가이드](security.html#cross-site-request-forgery-csrf)를 참조해주세요.


### 일반적인 검색 폼

웹에서는 검색 폼이 자주 사용됩니다. 이 폼은 아래와 같은 부분을 포함하고 있습니다.

* "GET" 메소드를 대상으로 하는 폼 요소
* 입력할 대상을 알려주는 텍스트
* 텍스트 입력 폼
* [송신] 버튼

이 폼을 만들기 위해서는 `form_tag`, `label_tag`, `text_field_tag`, `submit_tag`이 필요합니다. 아래의 예시를 보세요.

```erb
<%= form_tag("/search", method: "get") do %>
  <%= label_tag(:q, "Search for:") %>
  <%= text_field_tag(:q) %>
  <%= submit_tag("Search") %
<% end %>
```

이 코드로부터 아래의 HTML이 생성됩니다.

```html
<form accept-charset="UTF-8" action="/search" method="get">
  <input name="utf8" type="hidden" value="&#x2713;" />
  <label for="q">Search for:</label>
  <input id="q" name="q" type="text" />
  <input name="commit" type="submit" value="Search" />
</form>
```

TIP: 어떤 input 태그를 사용하더라도 id 속성은 그 이름으로부터 생성됩니다(이 예시에서는 'q'). 이것들의 id는 css를 추가하거나 JavaScript를 이용하여 폼을 제어할 때에 유용합니다.

HTML의 __모든__ 폼 태그에 대해서 `text_field_tag`나 `submit_tag`와 같은 편리한 헬퍼를 사용할 수 있습니다.

IMPORTANT: 검색을 위해서 폼을 사용하는 경우에는 반드시 "GET" 메소드를 사요해주세요. 이를 통해서 검색 쿼리가 URL의 일부가 되기 때문에, 사용자가 검색 결과를 북마크하고, 나중에 같은 검색 결과를 북마크를 통해 볼 수 있게 됩니다. Rails에서는 기본적으로 액션에 대응하는 적절한 HTTP 어휘를 선택해주세요.

### 폼 헬퍼를 호출 시에 여러 개의 해시를 사용하기

`form_tag` 헬퍼는 2개의 인수를 사용합니다. 하나는 액션에 대한 경로이고, 또 하나는 옵션을 가지는 해시입니다. 이 해시에는 폼을 전송할때의 메소드 형식과 HTML 옵션(폼 태그의 클래스 등)이 포함될 수 있습니다.

`link_to` 헬퍼와 마찬가지로 문자열 이외의 인수도 받을 수 있습니다. 예를 들어서 Rails의 라우팅에서 인식 가능한 URL 파라미터의 해시를 받아서 그것을 올바른 URL로 변환할 수도 있습니다. 단, `form_tag`의 두 인수를 모두 해시로 하게 되면 문제가 생길 수 있습니다. 예를 들어 다음과 같은 코드를 작성했다고 합시다.

```ruby
form_tag(controller: "people", action: "search", method: "get", class: "nifty_form")
# => '<form accept-charset="UTF-8" action="/people/search?method=get&class=nifty_form" method="post">'
```

이 코드에서는 생성된 URL에 `method`와 `class`가 추가되고 맙니다. 2개의 해시를 넘겨줄 요량이었지만, 실제로는 그것들이 하나의 해시인 것처럼 다루어집니다. 따라서 중괄호 { } 를 사용해서 첫번째 해시를 (또는 어느 쪽이든) 구별해 줄 필요가 있습니다. 이번에는 기대한 대로의 HTML이 생성됩니다.

```ruby
form_tag({controller: "people", action: "search"}, method: "get", class: "nifty_form")
# => '<form accept-charset="UTF-8" action="/people/search" method="get" class="nifty_form">'
```

### 폼 태그 생성에 사용하는 헬퍼

Rails에는 체크 박스/텍스트 필드/라디오 버튼같은 폼 태그를 생성하기 위한 헬퍼도 준비되어 있습니다. 이 태그들을 생성하는 기본 헬퍼의 이름은 "_tag"로 끝나며(`text_field_tag`나 `check_box_tag`처럼) 각각 1개의 `<input>` 태그를 생성합니다. 이 헬퍼들의 첫번째 파라미터는 input의 이름을 받게 됩니다. 폼이 전송되었을때, 이 이름이 폼 데이터에 포함되어서 전달되며, 사용자가 입력한 값과 함께 컨트롤러 내부에서 `params` 해시로 변환됩니다. 예를 들어, 폼에 `<%= text_field_tag(:query) %>`라는 태그를 생성한다면, 컨트롤러에서는 `params[:query]`를 통해서 해당하는 값에 접근할 수 있습니다.

Rails는 input의 명명시에 일정한 규칙을 따릅니다. 이에 따라, 배열이나 해시같은 '비 스칼라 값'의 파라미터를 폼을 사용해 전송할 수 있게 되며, 그 결과 `params`로서 컨트롤러에 접근할 수 있게 됩니다. 자세한 설명은 [이 가이드의 뒷부분](#파라미터의_명명_규칙_이해하기)을 참조해주세요. 그리고 이 헬퍼들의 정확한 사용법에 대해서는 [API 문서](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)를 참조해주세요.

#### 체크 박스

체크 박스는 폼에서 사용 가능한 태그의 한 종류로, 사용자가 옵션을 활성화, 또는 비활성화할 수 있도록 되어있습니다.

```erb
<%= check_box_tag(:pet_dog) %>
<%= label_tag(:pet_dog, "I own a dog") %>
<%= check_box_tag(:pet_cat) %>
<%= label_tag(:pet_cat, "I own a cat") %>
```

이 코드로 다음과 같은 코드가 생성됩니다.

```html
<input id="pet_dog" name="pet_dog" type="checkbox" value="1" />
<label for="pet_dog">I own a dog</label>
<input id="pet_cat" name="pet_cat" type="checkbox" value="1" />
<label for="pet_cat">I own a cat</label>
```

`check_box_tag`의 첫번째 파라미터는 말할 필요도 없이 input 태그의 이름입니다. 두번째 파라미터는 input 태그의 value 속성이 됩니다. 체크 박스를 활성화하면 이 값이 전송되는 폼 데이터를 포함되며 최종적으로 `params`로 변환됩니다.

#### 라디오 버튼

라디오 버튼도 체크 박스와 마찬가지로 옵션을 사용자가 선택할 수 있습니다만, 한번에 하나만을 선택할 수 있다는 것이 특징입니다.

```erb
<%= radio_button_tag(:age, "child") %>
<%= label_tag(:age_child, "I am younger than 21") %>
<%= radio_button_tag(:age, "adult") %>
<%= label_tag(:age_adult, "I'm over 21") %>
```

랜더링 결과는 다음과 같습니다.

```html
<input id="age_child" name="age" type="radio" value="child" />
<label for="age_child">I am younger than 21</label>
<input id="age_adult" name="age" type="radio" value="adult" />
<label for="age_adult">I'm over 21</label>
```

`check_box_tag` 헬퍼와 마찬가지로 `radio_button_tag`의 두번째 파라미터는 input 태그의 value 속성값입니다. 두번째 라디오 버튼은 같은 이름('age')를 사용하기 때문에 유저는 한가지의 값만 선택할 수 있습니다. 그리고 `params[:age]`의 값은 "child"나 "adult" 중 하나가 됩니다.

NOTE: 체크 박스와 라디오 버튼에는 반드시 label 태그를 함께 사용해주세요. label을 사용하는 것으로 그 옵션과 라벨이 연결되는 것 뿐만 아니라, label 부분까지 클릭 가능하게 되어 사용자가 클릭하기 편하게 됩니다.

### 그 이외의 헬퍼

지금까지 소개한 것 이외에도 다음과 같은 항목이 있습니다: 텍스트 영역(textarea), 패스워드, 숨김 필드, 검색 필드, 전화번호 필드, 날짜 필드, 시각 필드, 색상 필드, 날짜/시간 필드, 지역 날짜/시간 필드, 월 필드, 주 필드, URL 필드, 메일 주소 필드, 숫자 값 필드, 범위 필드.

```erb
<%= text_area_tag(:message, "Hi, nice site", size: "24x6") %>
<%= password_field_tag(:password) %>
<%= hidden_field_tag(:parent_id, "5") %>
<%= search_field(:user, :name) %>
<%= telephone_field(:user, :phone) %>
<%= date_field(:user, :born_on) %>
<%= datetime_local_field(:user, :graduation_day) %>
<%= month_field(:user, :birthday_month) %>
<%= week_field(:user, :birthday_week) %>
<%= url_field(:user, :homepage) %>
<%= email_field(:user, :address) %>
<%= color_field(:user, :favorite_color) %>
<%= time_field(:task, :started_at) %>
<%= number_field(:product, :price, in: 1.0..20.0, step: 0.5) %>
<%= range_field(:product, :discount, in: 1..100) %>
```

결과는 다음과 같이 됩니다.

```html
<textarea id="message" name="message" cols="24" rows="6">Hi, nice site</textarea>
<input id="password" name="password" type="password" />
<input id="parent_id" name="parent_id" type="hidden" value="5" />
<input id="user_name" name="user[name]" type="search" />
<input id="user_phone" name="user[phone]" type="tel" />
<input id="user_born_on" name="user[born_on]" type="date" />
<input id="user_graduation_day" name="user[graduation_day]" type="datetime-local" />
<input id="user_birthday_month" name="user[birthday_month]" type="month" />
<input id="user_birthday_week" name="user[birthday_week]" type="week" />
<input id="user_homepage" name="user[homepage]" type="url" />
<input id="user_address" name="user[address]" type="email" />
<input id="user_favorite_color" name="user[favorite_color]" type="color" value="#000000" />
<input id="task_started_at" name="task[started_at]" type="time" />
<input id="product_price" max="20.0" min="1.0" name="product[price]" step="0.5" type="number" />
<input id="product_discount" max="100" min="1" name="product[discount]" type="range" />
```

숨김 필드는 사용자에게는 보이지 않으며, 사전에 주어진 값을 종류에 관계없이 저장합니다. 숨김 필드에 포함되있는 값은 JavaScript를 사용해서 변경할 수 있습니다.

IMPORTANT: '검색, 전화번호, 날짜, 시각, 색, 날짜/시각, 지역 날짜/시각, 월, 주, URL, 메일 주소, 숫자, 범위' 필드는 HTML5부터 사용가능해진 것들입니다. 이런 필드를 구형 브라우저에서도 같은 방식으로 다루고 싶다면 CSS나 JavaScript를 사용해서 HTML5 폴리필을 사용해야합니다. 구형 브라우저에서 HTML5를 사용하기 위한 방법은 [산더미처럼](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills) 있습니다만, 현 시점에서 대표적인 것으로는 [Modernizr](http://www.modernizr.com/)가 있습니다. 이것들은 HTML5의 신기능이 사용될 경우, 이를 추가하기 위한 간단한 방법을 제공합니다.

TIP: 비밀번호 입력 필드를 사용하고 있다면, 입력된 비밀번호를 Rails의 로그에 남기고 싶지 않을 것입니다. 그 방법에 대해서는 [보안 가이드](security.html#로그출력)를 참조해주세요.

모델 객체 다루기
--------------------------

### 모델 객체 헬퍼

폼의 주요한 기능이라고 한다면, 모델 객체를 생성하거나 변경하는 것이겠죠. `*_tag` 헬퍼를 모델 객체의 생성/변경시에 사용할 수도 있습니다만, 하나 하나의 태그에 대해서 올바른 파라미터가 사용되고 있는지, 입력의 기본값은 알맞게 설정되어 있는지를 일일히 확인하며 코딩하는 것은 무척 귀찮습니다. Rails에는 바로 이러한 작업을 줄이기 위한 헬퍼가 있습니다. 또한, 이 헬퍼들에는 _tag가 붙어있지 않습니다(`text_field`, `text_area` 등).

이 헬퍼들의 첫번째 인수로는 인스턴스 변수명, 두번째 인수로는 객체를 호출하기 위한 메소드명(일반적으로 속성명을 사용합니다)을 넘겨줍니다. Rails는 객체의 해당 메소드로부터 값을 받아서 설정하며, 더불어 적절한 input 이름을 지정해줍니다. 예를 들어, 컨트롤러에서 `@person`이 정의되어 있고, 그 인물의 이름이 Henry라고 해봅시다.

```erb
<%= text_field(:person, :name) %>
```

이 때, 아래와 같은 결과를 얻을 수 있습니다.

```erb
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

이 폼을 전송하면, 사용자가 입력한 값은 `params[:person][:name]`에 저장됩니다. `params[:person]` 해시는 `Person.new`에 넘기기 쉽게 되어있습니다. `@person`이 Person 모델의 인스턴스라면 `@person.update`에도 간편하게 넘길 수 있습니다. 폼 헬퍼는 2번째 파라미터로서 속성명을 넘기는 경우가 대부분입니다만 이 헬퍼들은 그렇지 않아도 됩니다. 위의 예제라면, person 객체에 `name` 메소드와 `name=` 메소드가 있는 한 Rails는 추가 작업을 하지 않아도 됩니다.

WARNING: 헬퍼에 넘기는 것은 모델 객체의 인스턴스 자체를 넘기는 것이 아닌, 인스턴스 변수의 '이름'입니다(심볼 `:person`이나 문자열 `"person"` 등).

Rails 헬퍼에는 모델 객체와 관련된 검증(Validation) 에러를 자동적으로 표시하는 기능도 포함되어있습니다. 자세한 설명은 이 가이드의 [Active Record Validation](active_record_validations.html#검증_에러를_뷰에서_출력하기)을 참조하세요.

### 폼과 객체를 연결하기

이 방법으로 코딩이 그럭저럭 편해졌습니다만, 개선의 여지는 아직 있습니다. Person 모델에서 여러 속성을 변경해야 한다면 객체의 이름을 몇번이고 반복해서 변경하지 않으면 안됩니다. 좀 더 편하게 폼과 모델 객체를 연결해서 간단하게 만들 수 없을까. 이 고민의 결과물이 `form_for`입니다.

글을 다루는 Articles 컨트롤러 `app/controllers/articles_controller.rb`가 있다고 합시다.

```ruby
def new
  @article = Article.new
end
```

이 컨트롤러에 대응하는 뷰 `app/views/articles/new.html.erb`에서 `form_for`를 사용하면, 아래와 같은 느낌이 됩니다.

```erb
<%= form_for @article, url: {action: "create"}, html: {class: "nifty_form"} do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body, size: "60x12" %>
  <%= f.submit "Create" %>
<% end %>
```

아래의 것들에 주목해주세요.

* `@article`은 실제로 변경되는 객체 그 자체입니다(이름이 아닙니다).
* 1개의 옵션에 1개의 해시가 사용됩니다. 라우팅 옵션은 `:url`에 해시로 넘겨지며, HTML 옵션은 `:html` 해시에 넘겨집니다. `:namespace` 옵션을 사용해서 각 input 태그들의 id속성의 유일성을 보장할 수도 있습니다. 이 `:namespace` 속성의 값은 생성된 HTML의 id 속성의 접두어 형태로 언더스코어와 함께 추가됩니다.
* `form_for` 메소드로부터 **폼 빌더** 객체(여기에서는 `f`)가 생성됩니다.
* 폼에서 input 태그를 생성하는 메소드는 **폼 빌더 객체 `f`를 사용해** 호출합니다.

여기에서는 아래와 같은 HTML이 생성됩니다.

```html
<form accept-charset="UTF-8" action="/articles/create" method="post" class="nifty_form">
  <input id="article_title" name="article[title]" type="text" />
  <textarea id="article_body" name="article[body]" cols="60" rows="12"></textarea>
  <input name="commit" type="submit" value="Create" />
</form>
```

`form_for`에 넘기는 이름은 `params`를 사용해서 넘어온 폼의 정보값이 들어있는
키 이름에 영향을 줍니다. 예를 들어, 이 이름이 `article`이라면 모든 input 태그는
`article[속성명]`이라는 폼 name 속성을 가지게 됩니다. 따라서 `create`
액션에서는 `:title` 키와 `:body` 키를 가지는 하나의 해시가 `params[:article]`에
포함됩니다. input의 name 속성의 중요성에 대해서는
[파라미터의 명명 규칙 이해하기](#파라미터의-명명-규칙-이해하기)를 참조해주세요.

폼 빌더 변수에 대해서 호출되는 헬퍼 메소드는 모델 객체의 헬퍼 메소드와 같습니다. 단, 폼의 경우는 대상이 되는 객체가 이미 폼 빌더에 의해서 관리되고 있기 때문에, 어떤 객체에 대해서 생성할지 지정할 필요가 없다는 점이 다릅니다.

`fields_for` 메소드를 사용하면 `<form>` 태그를 실제로 작성하지 않고 같은 연결을 선언할 수 있습니다. 이것은 동일한 폼 내에서 다른 모델 객체를 다루기 위한 경우 등에 편리합니다. 예를 들어 Person 모델에 관계되어있는 ContactDetail 모델이 있다고 가정한다면, 아래와 같이 폼을 작성하면 됩니다.

```erb
<%= form_for @person, url: {action: "create"} do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for @person.contact_detail do |contact_details_form| %>
    <%= contact_details_form.text_field :phone_number %>
  <% end %>
<% end %>
```

다음과 같은 결과를 얻을 수 있습니다.

```html
<form accept-charset="UTF-8" action="/people/create" class="new_person" id="new_person" method="post">
  <input id="person_name" name="person[name]" type="text" />
  <input id="contact_detail_phone_number" name="contact_detail[phone_number]" type="text" />
</form>
```

`fields_for`에 의해서 생성되는 객체는 폼 빌더이며, `form_for`에서 생성되는 것과 비슷합니다(사실 `form_for`의 내부에서는 `fields_for`를 호출합니다).

### 레코드 식별에 의존하기

이제 Article 모델을 사용자가 직접 변경할 수 있게 되었습니다. 다음으로 해야하는 것은 이것을 **리소스**로 선언하는 것입니다.

```ruby
resources :articles
```

TIP: 리소스를 선언하면 자동적으로 다른 몇가지 설정이 추가됩니다. 자세한 리소스 설정 방법에 대해서는 [Rails 라우팅 가이드](routing.html#리소스 기반 라우팅-rails의 기본)을 참조해주세요.

RESTful한 리소스를 다루고 있는 경우, 레코드 식별(record identification)을 사용하면 `form_for`를 호출하는 작업이 무척 간단해집니다. 모델의 인스턴스를 넘기기만 하면, Rails가 나중에 그 인스턴스로부터 모델명 등의 필요한 정보를 꺼내서 처리해줍니다.

```ruby
## 새 글 작성하기
# 긴 방법
form_for(@article, url: articles_path)
# 짧은 방법(레코드 식별을 사용)
form_for(@article)

## 기존의 글 수정하기
# 긴 방법
form_for(@article, url: article_path(@article), html: {method: "patch"})
# 짧은 방법
form_for(@article)
```

이 짧은 `form_for` 호출은 레코드를 작성, 편집하는 모든 경우에 있어서 같은 방식으로 사용할 수 있습니다. 이것이 얼마나 편리한 지는 이해하실 거라고 생각합니다. 레코드 식별은 새 레코드일 경우 `record.new_record?`가 필요하다, 같은 적절한 추측을 해줍니다. 나아가서 전송 시에 사용해야 하는 적절한 경로를 선택하며, 객체의 클래스에 기반해서 사용할 이름도 선택해줍니다.

Rails는 폼의 `class`와 `id`를 자동적으로 설정합니다. 이 경우, 글을 생성하는 폼에는 `id`와 `new_article`이라는 `class`가 주어집니다. 만약 id가 23인 글을 편집하는 경우, `class`는 `edit_article`로 설정되며, id는 `edit_article_23`이 됩니다. 그리고, 이 속성들은 가독성을 위해서 가이드의 뒷부분에서는 생략합니다.

WARNING: 모델에서 단일 케이블 상속(STI: single-table inheritance)를 사용하고 있는 경우, 부모 클래스에서 리소스가 선언되더라도 자식 클래스에서 레코드를 식별할 수 없습니다. 그 경우에는 모델명, `:url`, `:method`를 명시적으로 지정해야 합니다.

#### 이름 공간 다루기

이름 공간(Namespace)을 사용하는 라우팅을 작성한 경우, `form_for`에서도 이를 이용하여 간결하게 작성할 수 있습니다. 애플리케이션의 라우팅에서 admin이라는 이름 공간이 선언되어 있다고 합시다.

```ruby
form_for [:admin, @article]
```

이 코드는 admin 이름 공간에 있는 `ArticlesController`에 전송할 폼을 생성합니다(예를 들어 수정하는 경우에는 `admin_article_path(@article)`로 전송됩니다). 이름 공간을 중첩해서 사용하고 있는 경우에도 같은 문법을 사용하면 됩니다.

```ruby
form_for [:admin, :management, @article]
```

Rails의 라우팅 시스템의 자세한 설명과 관련된 규칙에 대해서는 [라우팅 가이드](routing.html)을 참조해주세요.

### 폼에서의 PATCH, PUT, DELETE 메소드 동작

Rails 프레임워크는 개발자가 애플리케이션을 RESTful하게 구축하도록 만듭니다. 다시 말해서, 개발자는 GET이나 POST뿐만 아니라, PATCH나 DELETE 요청을 작성하도록 합니다. 그러나 많은 브라우저에서는 폼을 송신할 때에 GET, POST 이외의 방식을 _지원하지 않고 있습니다_.

그래서 Rails에서는 POST 메소드 위에서 다른 메소드들을 에뮬레이트하는 것으로 이 문제를 해결하고 있습니다. 구체적으로는 `"_method"`라는 이름의 숨겨진 필드를 준비하고, 이를 이용해 사용할 메소드를 지정합니다.

```ruby
form_tag(search_path, method: "patch")
```

이를 통해서 다음과 같은 코드를 얻을 수 있습니다.

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <div style="margin:0;padding:0">
    <input name="_method" type="hidden" value="patch" />
    <input name="utf8" type="hidden" value="&#x2713;" />
    <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  </div>
  ...
```

Rails는 POST로 전송된 데이터를 해석하기 위해서 이 `_method` 파라미터를 확인하고, 여기서 지정된 메소드(이 경우에는 PATCH)로 전송된 것처럼 행동합니다.

간단하게 선택 상자를 만들기
-----------------------------

HTML에서 선택 상자를 생성하기 위해서는 대량의 마크업을 작성해야합니다. 따라서 이러한 마크업을 자동으로 생성하고 싶다고 생각하는 것이 자연스러울 것입니다.

일반적으로 HTML 마크업은 다음과 같이 작성됩니다.

```html
<select name="city_id" id="city_id">
  <option value="1">Lisbon</option>
  <option value="2">Madrid</option>
  ...
  <option value="12">Berlin</option>
</select>
```

여기에서는 도시의 이름 목록이 표시됩니다. 애플리케이션 내부에서는 이 항목들의 id를 사용하면 됩니다. 이에 따라서 각각의 id를 옵션의 값으로 사용하면 됩니다. Rails의 내부에서 어떠한 처리가 이루어지는지를 봅시다.

### Select 태그와 Option 태그

가장 일반적인 헬퍼는 `select_tag`일겁니다. 이것은 이름 그대로 옵션의 문자열을 포함하는 `SELECT` 태그를 생성하는 메소드입니다.

```erb
<%= select_tag(:city_id, '<option value="1">Lisbon</option>...') %>
```

우선 위의 코드를 작성합니다만, 이것만으로는 옵션 태그를 동적으로 생성할 수 없습니다. 옵션 태그를 생성하기 위해서는 `options_for_select` 헬퍼를 사용합니다.

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ...]) %>

이 코드로부터 다음과 같은 결과를 얻을 수 있습니다.

<option value="1">Lisbon</option>
<option value="2">Madrid</option>
...
```

`options_for_select`의 첫번째 인수는 중첩된 배열이며, 배열의 각 요소는 '옵션 텍스트(city name)'과 '옵션 값(city id)'의 배열이 됩니다. 옵션의 값이 컨트롤러에게 전송되며, 전송된 id는 대응하는 데이터베이스 객체의 id인 경우가 일반적입니다만, 그렇지 않은 경우도 있습니다.

이것을 이해하면, `select_tag`와 `options_for_select`을 조합해서 원하는 마크업을 생성할 수 있습니다.

```erb
<%= select_tag(:city_id, options_for_select(...)) %>
```

`options_for_select`에는 기본값으로 사용하고 싶은 옵션 값을 넘겨줄 수 있습니다.

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ...], 2) %>

이 코드로부터 다음과 같은 결과를 얻을 수 있습니다.

<option value="1">Lisbon</option>
<option value="2" selected="selected">Madrid</option>
...
```

생성된 옵션의 값과 넘겨진 값과 일치하면 Rails는 `selected` 속성을 자동적으로 추가합니다.

TIP: `options_for_select`의 두번째 인수는 내부에서 사용하는 값과 정확하게 일치해야합니다. 예를 들어 값이 정수 2인 경우, 문자열 "2"를 `options_for_select`에 넘겨주어서는 안됩니다. 어디까지나 정수 2를 넘겨줘야합니다. `params` 해시에서 값을 꺼냈을 때에는 모두 문자열이 되므로, 주의해야 할 필요가 있습니다.

WARNING: `:include_blank`나 `:prompt`가 지정되어 있지 않을 때, 선택 속성 `required`가 `true`가 되면 `:include_blank`가 강제적으로 true로 설정되고, `size`는 `1`, `multiple`은 `true`가 아니게 됩니다.

해시를 사용하여 임의의 값을 추가할 수도 있습니다.

```html+erb
<%= options_for_select(
  [
    ['Lisbon', 1, { 'data-size' => '2.8 million' }],
    ['Madrid', 2, { 'data-size' => '3.2 million' }]
  ], 2
) %>

output:

<option value="1" data-size="2.8 million">Lisbon</option>
<option value="2" selected="selected" data-size="3.2 million">Madrid</option>
...
```

### 모델을 사용하는 선택 상자

대부분의 경우, 폼은 특정 모델과 연결되어 있으며, Rails에 이를 위한 헬퍼가 있을 거라고 기대하는 것은 당연할 것입니다. 모델을 다루는 경우, 다른 폼 헬퍼와 같은 요령으로 `select_tag`에서 `_tag`라는 접미어를 제거하고 사용할 수 있습니다.

```ruby
# controller:
@person = Person.new(city_id: 2)
```

```erb
# view:
<%= select(:person, :city_id, [['Lisbon', 1], ['Madrid', 2], ...]) %>
```

세번째 파라미터로 넘겨진 옵션 베열은 `options_for_select`에 넘겨주던 인수와 같은 것입니다. 이 헬퍼의 이점중 하나는 사용자가 이미 도시를 선택하고 있는 경우, 올바른 도시가 기본값으로 설정되었는지에 대해서 신경쓸 필요가 없다는 점입니다. Rails는 `@person.city_id` 속성을 읽어서 이 작업을 자동으로 처리합니다.

다른 헬퍼와 마찬가지로 `@person` 객체를 대상으로 하는 폼 빌더에서 `select`를 사용한다면 다음과 같이 작성합니다.

```erb
# 폼빌더에서 선택 상자를 생성한다
<%= f.select(:city_id, ...) %>
```

`select` 헬퍼에 블록을 넘길 수도 있습니다.

```erb
<%= f.select(:city_id) do %>
  <% [['Lisbon', 1], ['Madrid', 2]].each do |c| -%>
    <%= content_tag(:option, c.first, value: c.last) %>
  <% end %>
<% end %>
```

WARNING: `select` 헬퍼(또는 유사한 `collection_select`, `select_tag` 등)을 사용해서 `belongs_to`를 설정하는 경우에는 관계를 그 자체의 이름이 아닌 외부키의 이름(위 예제라면 `city_id`)를 넘겨주어야 합니다. `city_id`가 아닌 `city`를 넘겨주면 `Person.new` 또는 `Person.update`에 `params` 해시를 넘겼을 경우에 Active Record에서 `ActiveRecord::AssociationTypeMismatch: City(#17815740) expected, got String(#1138750)` 에러가 발생합니다. 나아가 속성의 편집을 하는 경우에도 주의해야할 필요가 있습니다. 사용자가 외부키를 직접 변경하는 경우 보안 상의 문제가 발생할 가능성이 있으므로, 충분히 주의해주세요.

### 임의의 객체 컬렉션에 대해 옵션 태그를 사용하기

`options_for_select`를 사용해서 옵션 태그를 생성할 때, 각 옵션의 텍스트와 값을 포함하는 배열이 생성되어 있어야 합니다. 여기에서는 City 모델이 존재한다고 가정하고, 그 객체의 컬렉션으로부터 옵션 태그를 생성하려면 어떻게 하면 좋을까요? 한가지 방법으로는 컬렉션을 탐색하면서 배열을 생성할 수 있을 겁니다.

```erb
<% cities_array = City.all.map { |city| [city.name, city.id] } %>
<%= options_for_select(cities_array) %>
```

이것은 이것대로 정상적인 방법입니다만, Rails에는 좀 더 간결한 `options_from_collection_for_select` 헬퍼가 존재합니다. 이 헬퍼는 임의의 객체의 컬렉션을 다른 2개의 인수 (**value** 옵션과 **text** 옵션을 각각 읽기 위한 메소드명)을 받습니다.

```erb
<%= options_from_collection_for_select(City.all, :id, :name) %>
```

이름이 가리키듯, 이 헬퍼가 생성하는 것은 옵션 태그 뿐입니다. 실제로 동작하는 선택 상자를 만들기 위해서는 이 메소드를 `options_for_select`와 마찬가지로 `select_tag`와 함께 사용해야합니다. 모델 객체를 사용하는 경우 `select`를 `select_tag`와 `options_for_select`를 함께 사용해야하는 것처럼 `collection_select`를 `select_tag`와 `options_from_collection_for_select`와 함께 사용합니다.

```erb
<%= collection_select(:person, :city_id, City.all, :id, :name) %>
```

정리하자면, `options_from_collection_for_select` 헬퍼는 '`options_for_select`가 `select`하는 것'처럼 '`collection_select`한다'가 됩니다.

NOTE: `options_for_select`에 넘기는 배열에서는 이름의 첫번째, 값이 두번째였습니다만, `options_from_collection_for_select`에서는 첫번째가 값을 얻어오기 위한 메소드이고, 두번째가 이름을 가져오기 위한 메소드입니다.

### 타임존과 나라 선택하기

Rails에서는 타임존을 지원하기 위해서 사용자가 지금 어떤 타임존에 있는지를 어떤 형태로든 사용자에게 물어야합니다. 이를 위해서는 `collection_select` 헬퍼를 사용해서 이미 정의되어있는 TimeZone 객체의 목록으로부터 선택 상자를 생성해야 합니다만 사실 이 기능을 구현해둔 `time_zone_select`이라는 전용의 헬퍼라 이미 준비되어 있습니다.

```erb
<%= time_zone_select(:person, :time_zone) %>
```

`time_zone_options_for_select`라는 비슷한 헬퍼도 존재하고 있으며, 여기에서는 좀 더 상세할 설정을 사용할 수 있습니다. 이 2가지의 메소드에서 사용하는 인수에 대해서는 API문서를 참조해주세요.

이전 Rails에서는 `country_select` 헬퍼를 사용해서 나라를 _선택했었습니다_만, 이 기능은 [country_select 플러그인](https://github.com/stefanpenner/country_select)으로 분리되었습니다. 이 기능을 사용하는 경우, 어떤 나라를 목록에 포함하고, 어떤 나라를 포함하지 않을 지에 결정할 때에 정치적인 이슈를 고려해야 한다는 점을 유의해주세요(이 기능이 플러그인으로 분리된 이유이기도 합니다).

날짜/시각 폼 헬퍼 사용하기
--------------------------------

HTML5 표준 날짜/시각 입력 필드를 생성하는 헬퍼 대신에 별도의 날짜/시각 헬퍼를 사용할 수도 있습니다. 어느 쪽이든 날짜/시각 헬퍼는 아래의 두가지 부분에 있어서 다른 헬퍼들과 다릅니다.

* 날짜와 시각을 한번에 표시할 수 있는 것은 없습니다. 이 때문에 년, 월, 일 등의 각각의 요소들을 조합해서 사용해야하며, 따라서 `params` 해시 내에서도 날짜/시각 정보는 한 개의 값으로 나타나지 않습니다.
* 다른 헬퍼에서는 그 헬퍼가 최소한의 기본 기능을 가지는지, 또는 모델 객체를 다루는지를 `_tag` 접미어의 유무로 표현합니다. 날짜/시각 헬퍼의 경우 `select_date`, `select_time`, `select_datetime`가 기본 헬퍼이고, `date_select`, `time_select`, `datetime_select`가 모델 객체를 사용하는 헬퍼입니다.

어느 쪽의 헬퍼를 사용하더라도, 년, 월, 일 등의 요소들의 선택 상자를 작성할 수 있습니다.

### 기본 헬퍼

`select_*`로 시작되는 날짜/시각 헬퍼에서는 Date, Time, DateTime 중 어느 한 인스턴스를 첫 번째 인수로 받고, 현재 선택중인 값으로 사용합니다. 현재 날짜가 사용되는 경우에는 이 파라미터를 생략할 수 있습니다. 예를 들어,

```erb
<%= select_date Date.today, prefix: :start_date %>
```

이 코드로부터 아래와 같은 결과를 얻을 수 있습니다(번잡함을 피하기 위해서 실제 옵션 값은 생략했습니다).

```html
<select id="start_date_year" name="start_date[year]"> ... </select>
<select id="start_date_month" name="start_date[month]"> ... </select>
<select id="start_date_day" name="start_date[day]"> ... </select>
```

위의 입력 결과는 `params[:start_date]`에 반영되며, 키는 `:year`, `:month`, `:day`가 됩니다. 이 값들로부터 실제의 Time 객체나 Date 객체를 얻기 위해서는 값을 꺼내서 적절한 생성자에 넘겨주어야합니다.

```ruby
Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
```

`:prefix` 옵션은 `params` 해시로부터 날짜 정보를 가져올때에 사용되는 키입니다. 여기에서는 `start_date`로 사용했습니다. 생략하면 `date`로 설정됩니다.

### 모델 객체 헬퍼

`select_date` 헬퍼는 Active Record 객체를 변경/생성하는 폼에서는 사용하기 어렵게 되어있습니다. Active Record는 `param` 해시에 포함되는 요소가 각각 1개의 속성에 대응될 것을 전제로 하고 있기 때문입니다.
날짜/시각용의 모델 객체 헬퍼는 특별한 이름을 사용해서 값을 전송합니다. Active Record는 이 특별한 이름을 발견하면 다른 파라미터를 위한 값이라고 추측하고, 컬럼의 종류에 맞는 생성자가 있을 것이라고 생각합니다. 예를 들어,

```erb
<%= date_select :person, :birth_date %>
```

이 코드로부터 아래와 같은 결과를 얻을 수 있습니다.

```html
<select id="person_birth_date_1i" name="person[birth_date(1i)]"> ... </select>
<select id="person_birth_date_2i" name="person[birth_date(2i)]"> ... </select>
<select id="person_birth_date_3i" name="person[birth_date(3i)]"> ... </select>
```

이 폼에서 다음과 같은 `params` 해시를 얻을 수 있습니다.

```ruby
{'person' => {'birth_date(1i)' => '2008', 'birth_date(2i)' => '11', 'birth_date(3i)' => '22'}}
```

이 값이 `Person.new`(나 `Person.update`)에 넘겨지면 Active Record는 이 값들로 부터 `birth_date` 속성을 구성하기 위해서 사용해야한다는 것을 이해하고, 어미로 붙어 있는 정보를 통해서 어떤 생성자를 호출해야 할지(예를 들면, `Date.civil` 같은)를 판단합니다.

### 공통 옵션

어느 날짜/시간 헬퍼라도 각각의 선택 태그를 생성하기 위한 핵심 기능은 공통적이므로 대부분의 옵션을 같은 방식으로 사용할 수 있습니다. 특히 Rails에서는 연도를 사용할 때 기본으로 현재 년도를 기준으로 전후 5년을 사용합니다. 이 범위가 적절하지 않은 경우 `:start_year` 옵션과 `:end_year` 옵션을 사용해서 덮어쓸 수 있습니다. 사용 가능한 모든 옵션은 [API 문서](http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html)를 참조해주세요.

경험적으로 조언하자면, 모델 객체를 다루는 경우에는 `date_select`가 편리하며, 그 이외의 경우, 예를 들어 날짜로 필터링하기 위한 검색 폼을 만드는 경우 등에는 `select_date`를 사용하는 것이 좋습니다.

NOTE: 내장된 날짜 선택(date picker) 헬퍼는 날짜와 요일이 연동되지 않는 등의 문제가 많습니다.

### 각각 별도로 사용하기

때때로, 연도만, 또는 월만 사용하고 싶은 경우가 있습니다. Rails에서는 날짜/시각을 표현하는 각각의 요소들을 다루기 위한 `select_year`, `select_month`, `select_day`, `select_hour`, `select_minute`, `select_second` 헬퍼를 지원합니다. 이 각각의 헬퍼들은 비교적 단순한 구조로 되어있습니다. 이 헬퍼들에서는 각각 날짜/시각 요소들을 속성명 그대로 입력 필드의 이름으로 사용합니다. 예를 들어, `select_year` 헬퍼를 사용하면 "year" 필드가 생성되며, `select_month`를 사용하면 "month"이 생성되는 식입니다. `:field_name` 옵션을 사용해서 이 이름을 변경할 수 있습니다. `:prefix` 옵션은 `select_date`나 `select_time`에서처럼 동작하며 기본값도 동일합니다.

첫번째 파라미터로는 선택되어야 하는 파라미터를 지정합니다. 선택할 수 있는 것은 Date, Time, DateTime 중 하나의 인스턴스이며, 인스턴스의 형식에 알맞는 요소, 또는 수치를 추출합니다. 예를 들어,

```erb
<%= select_year(2009) %>
<%= select_year(Time.now) %>
```

현재의 연도가 2009년이라면 위의 코드는 같은 결과를 생성하며, 값은 `params[:date][:year]`으로 전송됩니다.

파일 업로드
---------------

파일 업로드는 애플리케이션에서 자주 일어나는 작업 중 하나입니다(프로필 사진의 업로드나, 처리하고 싶은 CSV 파일 업로드 등). 파일 업로드에서 주의해야하는 것 중 하나는 폼 전송시의 인코딩이 **반드시** "multipart/form-data"이어야 한다는 점입니다. `form_for` 를 사용하면 이 부분은 자동적으로 처리됩니다. `form_tag`를 사용해서 파일 업로드를 하는 경우에는 아래의 예시처럼 인코딩을 명시적으로 지정해야 합니다.

아래 2개의 예제는 모두 정상적으로 파일 업로드를 할 수 있습니다.

```erb
<%= form_tag({action: :upload}, multipart: true) do %>
  <%= file_field_tag 'picture' %>
<% end %>

<%= form_for @person do |f| %>
  <%= f.file_field :picture %>
<% end %>
```

Rails에서는 다른 것들과 마찬가지로, 기본 헬퍼 `file_field_tag`와 모델 헬퍼 `file_field`가 제공됩니다. 다른 헬퍼와 유일하게 다른 점은 기본값을 줄 수 없다는 부분입니다(실제로 아무런 의미가 없습니다). 그리고 예상하시는 것처럼 업로드된 파일은 `params[:picture]`에 저장되며, 모델 헬퍼에서는 `params[:person][:picture]`로 저장됩니다.

### 업로드 가능한 파일

`params` 해시에 포함된 객체는 IO 클래스의 서브 클래스의 인스턴스입니다. 이 객체는 업로드된 파일의 사이즈에 알맞는 StringIO이거나, File 클래스의 인스턴스(이 경우, 임시 파일로 저장되어 있습니다)가 됩니다. 어느 쪽의 헬퍼를 사용하든 객체에는 `original_filename`과 `content_type` 속성이 포함됩니다. `original_filename`가 포함하는 이름은 사용자의 컴퓨터에 있었던 원래의 파일명입니다. `content_type`에는 업로드가 완료된 파일의 MIME 타입이 저장됩니다. 아래의 코드에서는 `#{Rails.root}/public/uploads`에 저장된 파일을 업로드된 파일명 그대로 저장합니다(폼은 위의 예제와 같은 것을 사용했다고 합시다).


```ruby
def upload
  uploaded_io = params[:person][:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
    file.write(uploaded_io.read)
  end
end
```

파일이 업로드된 이후에도 해야할 일이 잔뜩 있습니다. 파일을 어디에 저장(웹서버, Amazon S3 등)할지,
모델과의 관계 설정, 이미지라면 크기 변경이나 섬네일 생성 작업 등이 필요합니다. 이러한 처리들은 이 가이드의 설명 범위를 벗어나므로 다루지 않습니다만, 이러한 처리를 도와주기 위한 라이브러리가 있다는 정도는 알아두면 좋을 겁니다. 그 중에서도 [CarrierWave](https://github.com/jnicklas/carrierwave)와 [Paperclip](https://github.com/thoughtbot/paperclip)이 유명합니다.

NOTE: 사용자가 파일을 선택하지 않고 업로드를 하게 되면 빈 문자열이 파라미터로 넘어오게 됩니다.

### Ajax 사용하기

비동기 파일 업로드 폼을 생성하는 것은 다른 일반적인 폼에서 하듯 `form_for`에 `remote: true`를 추가하는 것처럼 간단하지 않습니다. Ajax 폼의 직렬화는 브라우저 내에서 실행되는 JavaScript에 의해 이루어집니다. 그리고 브라우저의 JavaScript는 (위험을 피하기 위해) 컴퓨터에 저장되어 있는 파일에 직접 접근할 수 없도록 되어있기 때문에, JavaScript에서 업로드할 파일을 읽어올 수 없습니다. 이것을 회피하는 가장 일반적인 방법은 표시되지 않는 iframe을 폼의 전송 대상으로 사용하는 것입니다.

폼 빌더를 개조하기
-------------------------

지금까지 설명한 것처럼 `form_for`, `fields_for`로 생성된 객체는 FormBuilder(또는 그 서브클래스)의 인스턴스입니다. 폼 빌더는 어떤 한 객체의 폼 요소를 생성하기 위해서 필요한 것들을 캡슐화합니다. 독자적인 폼 헬퍼를 만들 수도 있으며, FormBuilder의 서브클래스를 만들고 거기에 헬퍼를 추가할 수도 있습니다. 예를 들어,

```erb
<%= form_for @person do |f| %>
  <%= text_field_with_label f, :first_name %>
<% end %>
```

이 코드는 아래처럼 작성할 수 있습니다.

```erb
<%= form_for @person, builder: LabellingFormBuilder do |f| %>
  <%= f.text_field :first_name %>
<% end %>
```

이 코드를 위해서 아래와 같은 LabellingFormBuilder 클래스를 정의합니다.

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    label(attribute) + super
  end
end
```

이 클래스를 자주 사용한다면 `labeled_form_for` 헬퍼를 정의하고 `builder: LabellingFormBuilder` 옵션을 포함하도록 해두면 편할 겁니다.

```ruby
def labeled_form_for(record, options = {}, &block)
  options.merge! builder: LabellingFormBuilder
  form_for record, options, &block
end
```

여기서 사용되는 폼 빌더는 아래의 코드가 실행된 순간의 동작도 결정합니다.

```erb
<%= render partial: f %>
```

이 코드는 `f`가 FormBuilder의 인스턴스인 경우 `form` 파셜 템플릿을 랜더링하고, 파셜 객체를 폼 빌더로 설정합니다. 이 폼 빌더의 클래스가 LabellingFormBuilder인 경우, `labelling_form` 파셜을 랜더링합니다.

파라미터의 명명 규칙 이해하기
------------------------------------------

지금까지 설명했듯 폼에서 전송받은 값들은 `params` 해시에 바로 저장되든가, 다른 해시의 내부에 저장됩니다. 예를 들어 Person 모델의 표준적인 `create` 액션은 `params[:person]`에 전송받은 모든 값들을 해시의 형태로 저장합니다. `params` 해시에 배열이나 해시의 배열을 포함할 수도 있습니다.

원칙적으로 HTML 폼은 어떤 형태의 구조화라도 상관하지 않습니다. 폼이 생성하는 것은 모두 이름과 이에 맞는 값의 쌍이며, 이것들은 단순한 문자열입니다. 이 데이터들을 애플리케이션 쪽에서 참조할 때에 배열이나 해시의 형태인 것은 Rails에서 사용하고 있는 파라미터 명명 규칙 덕분입니다.

### 기본 구조

배열과 해시는 기본이 되는 2대 구조입니다. 해시는 `params`의 값에 접근할 때 사용되는 문법에서 사용됩니다. 예를 들어 폼에 다음과 같은 것들이 포함되어있다고 해봅시다.

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

이때 `params` 해시의 내부는 아래와 같습니다.

```erb
{'person' => {'name' => 'Henry'}}
```

따라서 컨트롤러에서 `params[:person][:name]`에 접근하면 전송된 값을 꺼내올 수 있습니다.

해시는 아래와 같이 얼마든 원하는 만큼 중첩시킬 수 있습니다.

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

이 코드에서 얻을 수 있는 `params` 해시는 다음과 같습니다.

```ruby
{'person' => {'address' => {'city' => 'New York'}}}
```

파라미터명이 중복되는 경우는 Rails에 의해서 무시됩니다. 파라미터명에 비어있는 []가 포함되어 있는 경우, 파라미터는 배열에 포함됩니다. 예를 들어 전화번호를 입력할 경우에 복수의 전화번호를 입력할 수 있도록 하고 싶은 경우, 다음과 같이 폼을 만들 수 있습니다.

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

이에 의해서 `params[:person][:phone_number]`는 전화번호의 배열이 됩니다.

### 조합해서 사용하기

이 두가지 개념을 조합해서 사용할 수도 있습니다. 예를 들어 좀 전에 보여드린 예제처럼 해시의 요소 중 하나를 배열로 받거나, 해시의 배열을 사용할 수도 있습니다. 이외에도 아래처럼 폼의 일부를 반복하는 것으로 주소를 얼마든지 추가로 받을 수 있는 폼도 생각해 볼 수 있습니다.

```html
<input name="addresses[][line1]" type="text"/>
<input name="addresses[][line2]" type="text"/>
<input name="addresses[][city]" type="text"/>
```

이 폼에 의해서 `params[:addresses]` 해시가 생성되며 `line1`, `line2`, `city`를 키로 가지게 됩니다. 입력된 이름이 현재 해시에 이미 존재하는 경우에는 새로운 해시에 값을 추가하게 됩니다.

단 여기에는 한가지 제약사항이 있습니다. 해시는 얼마든지 중첩시킬 수 있습니다만, 배열은 중첩해서 사용할 수 없습니다. 다만 대부분의 경우, 배열은 해시로 변환하여 사용할 수 있습니다. 예를 들어 모델 객체의 배열 대신에 모델 객체의 해시를 사용할 수 있습니다. 이 경우 키로는 id, 배열 인덱스 등의 값을 사용할 수 있을 겁니다.

WARNING: 배열 파라미터는 `check_box` 헬퍼와 상성이 좋지 않습니다. HTML에서는 ON이 아닌 체크 상자로부터는 값이 전송되지 않습니다. 그러나 체크 상자로부터는 언제나 값이 전송되는 것이 여러가지로 편리합니다. 그 때문에 `check_box` 헬퍼는 같은 이름으로 숨겨진 입력을 추가하는 것으로 본래 전송되지 않을 체크 상자의 값을 전송하도록 하고 있습니다. 체크 상자가 OFF일 때에는 숨겨진 값만이 전송되고, 체크 상자가 ON일 경우에는 본래의 체크 상자의 값과 숨겨진 값이 함께 전송됩니다만, 이 경우에는 본래의 체크 상자의 값이 우선됩니다. 따라서 이러한 중복된 값 전송에 대해서 배열 파라미터를 사용하게 되면 Rails가 혼란에 빠질 수 있습니다. 왜냐하면 입력값의 이름이 중복되어있는 경우, 거기에서 새로운 배열 요소를 생성하기 때문입니다. 이를 회피하기 위해서는 `check_box_tag`를 사용하거나 배열 대신 해시를 사용하여 주세요.

### 폼 헬퍼 사용하기

앞에서는 Rails의 폼 헬퍼를 전혀 사용하지 않았습니다. 물론 위와 같은 방식으로 직접 이름을 정해서 `text_field_tag` 등의 일반 헬퍼에 넘겨주어도 됩니다만, Rails는 좀 더 편한 방법을 지원해줍니다. `form_for`와 `fields_for`의 이름 파라미터, 그리고 헬퍼가 인수로 받는 `:index` 옵션이 바로 그것입니다.

여러개의 주소를 편집할 수 있는 필드를 가지는 폼을 생성할 수도 있습니다. 예:

```erb
<%= form_for @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form|%>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

여기에서는 한 명의 인물이 2개의 주소(id는 23, 45)를 가질 수 있다고 합시다. 이를 통해서 생성된 코드는 다음과 같습니다.

```html
<form accept-charset="UTF-8" action="/people/1" class="edit_person" id="edit_person_1" method="post">
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

이로부터 얻을 수 있는 `params` 해시는 아래와 같습니다.

```ruby
{'person' => {'name' => 'Bob', 'address' => {'23' => {'city' => 'Paris'}, '45' => {'city' => 'London'}}}}
```

Rails는 이 입력이 person 해시의 일부여야 한다는 점을 이해하고 있습니다. 이것이 가능한 이유는 최초의 폼 빌더에서 `fields_for`를 호출했기 때문입니다. 거기에서 `:index` 옵션을 지정하면 `person[address][city]`와 같은 이름 대신에 주소와 도시명의 사이에 []로 인덱스를 삽입합니다. 이렇게 해두면 수정해야하는 Address 객체를 간단하게 지정할 수 있기 때문에 여러가지로 편리합니다. 다른 의미를 가지는 숫자를 넘기거나, 문자열이나 `nil`을 넘길 수도 있습니다. 이것들은 작성되는 배열 파라미터에 포함됩니다.

입력명의 앞 부분(위의 예시에서라면 `person[address]`)를 명시적으로 표현하는 것으로 보다 복잡한 폼을 작성할 수도 있습니다.

```erb
<%= fields_for 'person[address][primary]', address, index: address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

이 코드로부터 다음과 같은 폼 요소를 생성할 수 있습니다.

```html
<input id="person_address_primary_1_city" name="person[address][primary][1][city]" type="text" value="bologna" />
```

Rails의 일반적인 규칙 중에는 최종적인 입력값은 `fields_for`나 `form_for`에 주어진 이름, 인덱스값, 그리고 속성명을 연결한 결과물이 됩니다. `text_field` 등의 헬퍼에 `:index` 옵션을 직접 넘겨줄 수도 있습니다만, 이것들을 하나하나 지정하는 것 보다는, 폼 빌더에서 한번 지정해 주는 것이 대부분의 경우 좀 더 간단하게 코드를 작성할 수 있습니다.

이름에 []를 추가하고 `:index`옵션을 생략하는 방법도 있습니다. 다음은 `index: address`를 지정한 것과 같은 결과를 생성합니다. 

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

외부 리소스용 폼
---------------------------

외부 리소스로 임의의 데이터를 전송하고 싶은 경우에도 Rails의 폼 헬퍼를 사용해서 폼을 생성하는 것이 편리합니다. 다만 이 때, 외부 리소스에 대해서 `authenticity_token`를 지정해야하는 경우에는 어떻게 해야할까요? 이것은 `form_tag`에 `authenticity_token: 'your_external_token'`를 주는 것으로 간단하게 설정할 수 있습니다.

```erb
<%= form_tag 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

결제 게이트웨이 등의 외부 리소스로 데이터를 전송해야하는 경우, 폼에서 사용가능한 필드는 외부 API에 따라 제한을 받습니다. 그런 경우처럼 `authenticity_token`를 위한 숨김 필드를 생성하지 않으려면 `:authenticity_token`을 `false`로 지정하면 됩니다.

```erb
<%= form_tag 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

`form_for`에서도 같은 방법을 사용할 수 있습니다.

```erb
<%= form_for @invoice, url: external_url, authenticity_token: 'external_token' do |f| %>
  Form contents
<% end %>
```

또는 `authenticity_token` 를 비활성화 할 수도 있습니다.

```erb
<%= form_for @invoice, url: external_url, authenticity_token: false do |f| %>
  Form contents
<% end %>
```

복잡한 폼을 생성하기
----------------------

처음에는 하나의 객체를 수정하기 위한 간단한 폼도 점점 커져서 복잡해지기 마련입니다. 예를 들어 Person에 한 명의 정보를 추가하는 코드라면, 같은 폼 내에서 여러개의 주소(자택, 직장 등)을 등록할 수 있도록 해주고, Person을 편집할 경우에 필요에 따라서 주소의 추가, 삭제, 변경을 할 수 있게끔 해주어야 합니다.

### 모델을 구성하기

Active Record는 `accepts_nested_attributes_for` 메소드를 통해서 모델을 중첩해 사용할 수 있도록 해줍니다.

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses
end

class Address < ActiveRecord::Base
  belongs_to :person
end
```

이 코드에 의해서 `addresses_attributes=` 메소드가 `Person` 모델에 추가되고, 이를 사용해서 주소를 생성, 갱신, 필요하다면 삭제까지 할 수 있습니다.

### 중첩된 폼

사용자는 아래의 폼을 통해 `Person`과 이에 관련된 복수의 주소를 생성할 수 있습니다.

```html+erb
<%= form_for @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


폼에서 중첩된 속성이 사용되면, `fields_for` 헬퍼는 그 관계로 연결된 모든 요소를 하나씩 출력합니다. 특히 Person에 주소가 등록되어 있지 않은 경우에는 아무것도 출력하지 않습니다. 필드의 세트가 적어도 하나 출력되도록 컨트롤러에서 1개 이상의 공백 문자를 사용하는 것은 자주 사용되는 패턴입니다. 아래의 예제에서는 Person 폼을 새로 생성할 경우에 2개의 주소 필드가 표시되도록 합니다.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build}
end
```

`fields_for` 헬퍼는 폼의 필드를 하나 생성합니다. `accepts_nested_attributes_for` 헬퍼가 받는 것은 이러한 파라미터의 이름입니다. 예를 들어 2개의 주소를 가지는 사용자를 한 명 생성할 경우, 전송된 파라미터는 아래처럼 구성됩니다.

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

여기에서 `:addresses_attributes` 해시의 키는 중복되지만 않으면 되므로 중요하지 않습니다.

관계가 정의된 객체가 이미 저장되어있는 경우, `fields_for` 메소드는 저장되어 있는 레코드의 `id`를 가지는 숨김 필드를 자동적으로 생성합니다. `fields_for`에 `include_id: false`를 넘기면 이 자동생성을 막을 수 있습니다. HTML이 유효하지 않은 곳에서는 input 태그를 자동으로 생성하고 싶지 않거나, 자식이 `id`를 가지지 않는 ORM(Object Releational Mapping)을 사용하는 경우 등, 이러한 때에 자동 생성을 끌 수 있습니다.

### 컨트롤러

컨트롤러에서 파라미터를 모델에 넘기기 전에 [파라미터의 화이트리스트 체크](action_controller_overview.html#strong-parameters)를 사용합시다.

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### 객체를 삭제하기

`accepts_nested_attributes_for`에 `allow_destroy: true`를 넘기는 것으로 관계가 설정된 객체를 사용자가 삭제할 수 있도록 허가할 수 있습니다.

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

어떤 객체의 속성값 해시에 키가 `_destroy`에 값이 `1` 또는 `true`가 들어있는 경우, 그 객체를 삭제합니다. 아래의 폼에서는 사용자가 주소를 삭제할 수 있습니다.

```erb
<%= form_for @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy%>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

컨트롤러의 화이트리스트 목록에 `_destroy` 필드를 추가해서 체크를 통과할 수 있도록 해야한다는 점을 잊지 말아주세요.

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### 필드의 공백을 무시하기

사용자가 아무것도 입력하지 않은 필드를 무시하는 것이 편리한 경우가 많습니다. 이는 `:reject_if` Proc을 `accepts_nested_attributes_for`에 넘겨두는 것을 통해서 구현할 수 있습니다. 이 Proc은 폼에서 전송된 속성값 해시 하나 하나에 대해서 호출됩니다. 이 Proc이 `false`를 반환하는 경우 Active Record는 그 해시에 관계가 설정된 객체를 작성하지 않습니다. 아래의 예제에서는 `kind` 속성에 값이 넘어왔을 경우에만 주소 객체를 생성합니다.

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda {|attributes| attributes['kind'].blank?}
end
```

또는 `:all_blank`를 넘겨도 됩니다. 이 심볼을 넘기는 경우, 모든 값이 공백인 레코드를 받지 않는 Proc이 생성됩니다. 단 `_destroy`의 경우, 어떤 값이더라도 체크를 통과합니다.

### 동적으로 필드 추가하기

필드들을 미리 생성하지 않고 [새로운 주소를 추가] 버튼을 눌렀을 경우에만 이 필드를 생성할 수 있도록 하고 싶을 때가 있습니다. 안타깝게도 Rails에서는 이를 위한 방법이 지원되지 않습니다. 필드를 직접 생성하는 경우에는, 관련된 배열의 키가 중복되지 않도록 해야한다는 점을 주의해주세요. JavaScript에서 현재 시각을 사용해 유일한 식별자를 생성하는 것이 자주 사용되는 방법입니다.
