[Form Helpers] 폼 헬퍼
============

웹 어플리케이션에서 폼은 사용자의 입력을 위한 필수 인터페이스입니다. 하지만 폼 마크업을 작성하고 수정하는것은 폼 컨트롤의 이름짓기와 많은 속성들로인해 금방 지루해집니다. 레일스는 이러한 복잡한작업을 위해 폼 마크업을 생성하는 뷰헬퍼를 제공합니다. 하지만 다양한 유즈케이스가 있기에 사용하기전에는 헬퍼 메소드의 다른점과 유사점을 알아야할 필요가 있습니다. [[[Forms in web applications are an essential interface for user input. However, form markup can quickly become tedious to write and maintain because of form control naming and their numerous attributes. Rails does away with these complexities by providing view helpers for generating form markup. However, since they have different use-cases, developers are required to know all the differences between similar helper methods before putting them to use.]]]

본 가이드를 읽고나면 다음의 내용들을 이해할 수 있습니다: [[[After reading this guide, you will know:]]]

* 검색폼과 모델에 특정되지 않는 유사한 일반적인 폼의 생성 방법 [[[How to create search forms and similar kind of generic forms not representing any specific model in your application.]]]

* 특정 데이터베이스 레코드를 생성하거나 수정하는 모델중심의 폼 생성 방법. [[[How to make model-centric forms for creation and editing of specific database records.]]]

* 여러종류의 데이터를 표현하는 select 박스 생성 방법. [[[How to generate select boxes from multiple types of data.]]]

* 레일스가 제공하는 날짜, 시간 헬퍼. [[[The date and time helpers Rails provides.]]]

* 파일 업로드 폼을 다르게하는 것. [[[What makes a file upload form different.]]]

* 외부 리소스와 연결하는 폼 생성 방법 [[[Some cases of building forms to external resources.]]]

* 복잡한 폼 생성 방법. [[[How to build complex forms.]]]

--------------------------------------------------------------------------------

NOTE: 본 가이드는 폼 헬퍼와 인수에대한 완전한 문서를 목표로 하지 않습니다. 완전한 문서를 참고하려면 [the Rails API documentation](http://api.rubyonrails.org/) 링크를 방문하세요. [[[This guide is not intended to be a complete documentation of available form helpers and their arguments. Please visit [the Rails API documentation](http://api.rubyonrails.org/) for a complete reference.]]]


[Dealing with Basic Forms] 기본폼 다루기
------------------------

가장 일반적인 폼 헬퍼는 `form_tag` 입니다. [[[The most basic form helper is `form_tag`.]]]

```erb
<%= form_tag do %>
  Form contents
<% end %>
```

인수없이 위와 같이 호출하는경우, `<form>` 태그를 생성하고 전송하는경우 현재 페이지에 POST 요청을 합니다. 예를들어, 현재 페이지가 `/home/index` 인경우 생성되는 HTML은 다음과 같습니다.(가독성을 위해 개행문자가 일부 추가되었습니다.) [[[When called without arguments like this, it creates a `<form>` tag which, when submitted, will POST to the current page. For instance, assuming the current page is `/home/index`, the generated HTML will look like this (some line breaks added for readability):]]]

```html
<form accept-charset="UTF-8" action="/home/index" method="post">
  <div style="margin:0;padding:0">
    <input name="utf8" type="hidden" value="&#x2713;" />
    <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  </div>
  Form contents
</form>
```

HTML이 몇개의 추가 요소를 가지고 있는것을 확인할 수 있습니다: 2개의 숨겨진 input 요소를 포함한 `div`. 추가된 div 는 중요한데, 이것 없이는 폼이 받아들여지지 않기 때문입니다. 첫번째 input 요소는 `utf8`이라는 이름을 가지고 있으며 폼이 "GET"이나 "POST" 요청을 할때 브라우저가 문자열 인코딩을 제대로 다루도록 합니다. 두번째 input 요소는 `authenticity_token`이라는 이름을 가지고 있으며 레일스에서 **cross-site request forgery protection**라고 부르는 보안기능으로 폼 헬퍼는 GET 요청을 제외한 모든 폼에 생성합니다(이 보안기능이 활성화 되어 있을때 제공). 자세한 내용은 [레일스 어플리케이션 보안](./security.html#cross-site-request-forgery-csrf)을 확인합니다. [[[Now, you'll notice that the HTML contains something extra: a `div` element with two hidden input elements inside. This div is important, because the form cannot be successfully submitted without it. The first input element with name `utf8` enforces browsers to properly respect your form's character encoding and is generated for all forms whether their actions are "GET" or "POST". The second input element with name `authenticity_token` is a security feature of Rails called **cross-site request forgery protection**, and form helpers generate it for every non-GET form (provided that this security feature is enabled). You can read more about this in the [Security Guide](./security.html#cross-site-request-forgery-csrf).]]]

NOTE: 본가이드의 샘플코드에서 `div`의 숨겨진 input 요소는 간결성을 위해 제외됩니다. [[[Throughout this guide, the `div` with the hidden input elements will be excluded from code samples for brevity.]]]

### [A Generic Search Form] 검색 폼

웹에서 가장 기본적인 폼중 하나는 검색 폼입니다. 이 폼은 다음을 포함합니다: [[[One of the most basic forms you see on the web is a search form. This form contains:]]]

* "GET" 메소드를 가진 폼, [[[a form element with "GET" method,]]]

* input을 위한 라벨, [[[a label for the input,]]]

* text input 요소, [[[a text input element, and]]]

* submit 요소. [[[a submit element.]]]

이 폼을 만들기 위해 `form_tag`, `label_tag`, `text_field_tag`, `submit_tag`를 사용해야 할것입니다. 다음과 같은: [[[To create this form you will use `form_tag`, `label_tag`, `text_field_tag`, and `submit_tag`, respectively. Like this:]]]

```erb
<%= form_tag("/search", method: "get") do %>
  <%= label_tag(:q, "Search for:") %>
  <%= text_field_tag(:q) %>
  <%= submit_tag("Search") %>
<% end %>
```

다음과 같은 HTML을 생성합니다: [[[This will generate the following HTML:]]]

```html
<form accept-charset="UTF-8" action="/search" method="get">
  <label for="q">Search for:</label>
  <input id="q" name="q" type="text" />
  <input name="commit" type="submit" value="Search" />
</form>
```

TIP: 모든 폼의 input에 ID 속성값은 name 속성값으로 생성됩니다(예제의 경우 "q"). 이러한 ID들은 CSS 스타일링이나 자바스크립트를 이용한 폼 처리에 매우 유용합니다. [[[For every form input, an ID attribute is generated from its name ("q" in the example). These IDs can be very useful for CSS styling or manipulation of form controls with JavaScript.]]]

`text_field_tag`, `submit_tag` 외에도 HTML의 _모든_ 폼 컨트롤에 대하여 비슷한 헬퍼가 있습니다. [[[Besides `text_field_tag` and `submit_tag`, there is a similar helper for _every_ form control in HTML.]]]

IMPORTANT: 검색 폼에 대해서는 항상 "GET"을 사용합니다. 이렇게 하면 사용자가 특정 검색어를 즐겨찾기해서 다시 찾아올수 있게 합니다. 일반적으로 레일스는 액션에 알맞는 HTTP verb를 사용하도록 권장합니다. [[[Always use "GET" as the method for search forms. This allows users to bookmark a specific search and get back to it. More generally Rails encourages you to use the right HTTP verb for an action.]]]

### [Multiple Hashes in Form Helper Calls] 폼 헬퍼를 호출시 다양한 인수

`form_tag` 헬퍼는 2개의 인수를 받습니다: 액션의 경로와 옵션 해쉬. 이 해쉬는 폼의 속성이나 HTML class와 같은 옵션에 해당합니다. [[[The `form_tag` helper accepts 2 arguments: the path for the action and an options hash. This hash specifies the method of form submission and HTML options such as the form element's class.]]]

`link_to` 헬퍼는 경로 인수는 문자열이 아니어도 됩니다; 레일스 라우팅 매커니즘이 이해하고 알맞은 URL로 변환되는 해쉬도 가능합니다. 하지만 `form_tag`의 경우 경로를 설정할때 두개의 인수를 지정하는경우 문제를 발생시킬수 있습니다. 예를 들어 다음과 같이 적는다면: [[[As with the `link_to` helper, the path argument doesn't have to be a string; it can be a hash of URL parameters recognizable by Rails' routing mechanism, which will turn the hash into a valid URL. However, since both arguments to `form_tag` are hashes, you can easily run into a problem if you would like to specify both. For instance, let's say you write this:]]]

```ruby
form_tag(controller: "people", action: "search", method: "get", class: "nifty_form")
# => '<form accept-charset="UTF-8" action="/people/search?method=get&class=nifty_form" method="post">'
```

`method`와 `class`는 URL의 쿼리문자열에 추가된것을 볼수 있습니다. 2개의 해쉬를 의미하는것이 었다면 하나를 명시해야합니다. 루비에게 첫번째 해쉬인지를(혹은 둘다) 중괄호로 분리해서 알려주어야 합니다. 이는 당신이 예상한 HTML을 만들것입니다: [[[Here, `method` and `class` are appended to the query string of the generated URL because even though you mean to write two hashes, you really only specified one. So you need to tell Ruby which is which by delimiting the first hash (or both) with curly brackets. This will generate the HTML you expect:]]]

```ruby
form_tag({controller: "people", action: "search"}, method: "get", class: "nifty_form")
# => '<form accept-charset="UTF-8" action="/people/search" method="get" class="nifty_form">'
```

### [Helpers for Generating Form Elements] 폼 요소를 생성하는 헬퍼

레일스는 체크박스, 텍스트 필드, 라디오버튼과 같은 폼 요소를 생성하는 일련의 헬퍼를 제공합니다. 이러한 기본 헬퍼는 "_tag"라는 이름으로 끝나고(`text_field_tag`나 `check_box_tag`와 같이), 하나의 `<input>` 요소를 생성합니다. 첫번째 변수는 항상 input의 name입니다. 폼이 전송될때 name은 폼 데이터와 함께 전송되며 사용자의 입력값이 컨트롤러의 `params` 해쉬를 생성합니다. 예를들어 폼에 `<%= text_field_tag(:query) %>`이 있다며 컨트롤러에서 이 필드의 값은 `params[:query]`를 이용해 가져옵니다. [[[Rails provides a series of helpers for generating form elements such as checkboxes, text fields, and radio buttons. These basic helpers, with names ending in "_tag" (such as `text_field_tag` and `check_box_tag`), generate just a single `<input>` element. The first parameter to these is always the name of the input. When the form is submitted, the name will be passed along with the form data, and will make its way to the `params` hash in the controller with the value entered by the user for that field. For example, if the form contains `<%= text_field_tag(:query) %>`, then you would be able to get the value of this field in the controller with `params[:query]`.]]]

input 이름을 지을때 array, hash와 같은 non-scalar 값들을 `params`에서 사용하기위해 레일스는 약간의 관례를 사용합니다. 이에 대한 자세한 것은 [본 가이드의 챕터 7](#understanding-parameter-naming-conventions)를 읽어봅니다. 헬퍼의 정확한 사용방법을 자세히 알고 싶다면 [API documentation](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)를 참고합니다. [[[When naming inputs, Rails uses certain conventions that make it possible to submit parameters with non-scalar values such as arrays or hashes, which will also be accessible in `params`. You can read more about them in [chapter 7 of this guide](#understanding-parameter-naming-conventions). For details on the precise usage of these helpers, please refer to the [API documentation](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).]]]

#### [Checkboxes] 체크박스

체크박스는 사용자가 여러개의 옵션을 활성화하거나 비활성화할 수 있도록 하는 폼 컨트롤입니다.: [[[Checkboxes are form controls that give the user a set of options they can enable or disable:]]]

```erb
<%= check_box_tag(:pet_dog) %>
<%= label_tag(:pet_dog, "I own a dog") %>
<%= check_box_tag(:pet_cat) %>
<%= label_tag(:pet_cat, "I own a cat") %>
```

위의 코드는 다음과 같이 생성됩니다: [[[This generates the following:]]]

```html
<input id="pet_dog" name="pet_dog" type="checkbox" value="1" />
<label for="pet_dog">I own a dog</label>
<input id="pet_cat" name="pet_cat" type="checkbox" value="1" />
<label for="pet_cat">I own a cat</label>
```

`check_box_tag`의 첫번째 변수는 당연히 input의 name입니다. 두번째 변수는 input의 값입니다. 이 값은 체크박스가 체크된경우 폼 데이터에 포함됩니다(그리고 `params`에 제공됩니다). [[[The first parameter to `check_box_tag`, of course, is the name of the input. The second parameter, naturally, is the value of the input. This value will be included in the form data (and be present in `params`) when the checkbox is checked.]]]

#### [Radio Buttons] 라디오 버튼

라디오 버튼은 체크박스와 비슷하게 여러개의 옵션을 베타적으로 선택할수 있게하는 폼 컨트롤입니다(예를들어 사용자는 한개만 선택가능): [[[Radio buttons, while similar to checkboxes, are controls that specify a set of options in which they are mutually exclusive (i.e., the user can only pick one):]]]

```erb
<%= radio_button_tag(:age, "child") %>
<%= label_tag(:age_child, "I am younger than 21") %>
<%= radio_button_tag(:age, "adult") %>
<%= label_tag(:age_adult, "I'm over 21") %>
```

결과물: [[[Output:]]]

```html
<input id="age_child" name="age" type="radio" value="child" />
<label for="age_child">I am younger than 21</label>
<input id="age_adult" name="age" type="radio" value="adult" />
<label for="age_adult">I'm over 21</label>
```

`check_box_tag`와 같이 `radio_button_tag`의 두번째 변수는 input의 값입니다. 라디오 버튼은 같은 이름(age)을 공유하고 있기 때문에 사용자는 하나만 선택할 수 있고, `params[:age]`는 "child", "adult"중 하나의 값만 가지게 됩니다. [[[As with `check_box_tag`, the second parameter to `radio_button_tag` is the value of the input. Because these two radio buttons share the same name (age) the user will only be able to select one, and `params[:age]` will contain either "child" or "adult".]]]

NOTE: 체크박스와 라디오버튼에는 항상 라벨을 사용합니다. 특정 옵션과 연결된 텍스트는 클릭가능 영역을 늘려주고 사용자가 input을 쉽게 클릭할 수 있도록 합니다. [[[Always use labels for checkbox and radio buttons. They associate text with a specific option and, by expanding the clickable region, make it easier for users to click the inputs.]]]

### [Other Helpers of Interest] 흥미로운 다른 헬퍼들

textarea, 비밀번호 필드, 숨김 필드, 검색 필드, 전화번호 필드, 날짜 필드, 시간 필드, 색상 필드, datetime-local 필드, month 필드, week 필드, URL 필드, 이메일 필드는 언급할 만한 가치가 있는 폼 컨트롤입니다. [[[Other form controls worth mentioning are textareas, password fields, hidden fields, search fields, telephone fields, date fields, time fields, color fields, datetime fields, datetime-local fields, month fields, week fields, URL fields and email fields:]]]

```erb
<%= text_area_tag(:message, "Hi, nice site", size: "24x6") %>
<%= password_field_tag(:password) %>
<%= hidden_field_tag(:parent_id, "5") %>
<%= search_field(:user, :name) %>
<%= telephone_field(:user, :phone) %>
<%= date_field(:user, :born_on) %>
<%= datetime_field(:user, :meeting_time) %>
<%= datetime_local_field(:user, :graduation_day) %>
<%= month_field(:user, :birthday_month) %>
<%= week_field(:user, :birthday_week) %>
<%= url_field(:user, :homepage) %>
<%= email_field(:user, :address) %>
<%= color_field(:user, :favorite_color) %>
<%= time_field(:task, :started_at) %>
```

Output:

```html
<textarea id="message" name="message" cols="24" rows="6">Hi, nice site</textarea>
<input id="password" name="password" type="password" />
<input id="parent_id" name="parent_id" type="hidden" value="5" />
<input id="user_name" name="user[name]" type="search" />
<input id="user_phone" name="user[phone]" type="tel" />
<input id="user_born_on" name="user[born_on]" type="date" />
<input id="user_meeting_time" name="user[meeting_time]" type="datetime" />
<input id="user_graduation_day" name="user[graduation_day]" type="datetime-local" />
<input id="user_birthday_month" name="user[birthday_month]" type="month" />
<input id="user_birthday_week" name="user[birthday_week]" type="week" />
<input id="user_homepage" name="user[homepage]" type="url" />
<input id="user_address" name="user[address]" type="email" />
<input id="user_favorite_color" name="user[favorite_color]" type="color" value="#000000" />
<input id="task_started_at" name="task[started_at]" type="time" />
```

숨김 필드는 사용자에게 보이지 않지만 다른 문자열 input 필드처럼 데이터를 가지고 있습니다. 이 값은 자바스크립트에 의해 변경될 수 있습니다. [[[Hidden inputs are not shown to the user but instead hold data like any textual input. Values inside them can be changed with JavaScript.]]]

IMPORTANT: 검색, 전화번호, 날짜, 시간, 색상, datetime, datetime-local, month, week, URL, 이메일 input은 HTML5 컨트롤입니다. 만약 당신의 앱이 오래된 브라우저를 지원해야 한다면 HTML5 polyfill(CSS 또는 자바스크립트에 의해 제공되는)이 필요할것입니다. 현재 인기 있는 툴 [Modernizr](http://www.modernizr.com/)과 [yepnope](http://yepnopejs.com/)은 감지된 HTML5 기능의 존재 여부에 따라 기능을 추가 할 수있는 간단한 방법을 제공하지만 이것은 확실히 [부족함이 없는 해결 방법](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills)입니다. [[[The search, telephone, date, time, color, datetime, datetime-local, month, week, URL, and email inputs are HTML5 controls. If you require your app to have a consistent experience in older browsers, you will need an HTML5 polyfill (provided by CSS and/or JavaScript). There is definitely [no shortage of solutions for this](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), although a couple of popular tools at the moment are [Modernizr](http://www.modernizr.com/) and [yepnope](http://yepnopejs.com/), which provide a simple way to add functionality based on the presence of detected HTML5 features.]]]

TIP: 비밀번호 input 필드를 사용한다면(어떠한 목적이던지), 이 변수가 로그에 남지 않도록 어플리케이션 설정을 해야합니다. 자세한 내용은 [Security Guide](security.html#logging)에서 배울수 있습니다. [[[If you're using password input fields (for any purpose), you might want to configure your application to prevent those parameters from being logged. You can learn about this in the [레일스 어플리케이션 보안](security.html#logging).]]]

[Dealing with Model Objects] 모델객체와 연결된 폼 다루기
--------------------------

### [Model Object Helpers] 모델객체 헬퍼

폼의 일반적인 작업은 모델객체를 수정하거나 생성하는것입니다. `*_tag` 헬퍼들은 다소 장황하지만 각 태그들에 알맞은 변수명을 강제하고 적절한 input 기본값을 설정해 이러한 작업에 사용할 수 있습니다. 레일스는 이러한 작업에 맞추어진 헬퍼를 제공합니다. 이러한 헬퍼들은 `text_field`, `text_area` 처럼 _tag 접미사가 제외됩니다. [[[A particularly common task for a form is editing or creating a model object. While the `*_tag` helpers can certainly be used for this task they are somewhat verbose as for each tag you would have to ensure the correct parameter name is used and set the default value of the input appropriately. Rails provides helpers tailored to this task. These helpers lack the _tag suffix, for example `text_field`, `text_area`. ]]]

이 헬퍼들의 첫번째 인수는 인스턴스 변수의 이름이고 두번째 인수는 객체의 메소드 이름(대개는 속성)입니다. 레일스는 객체 메소드의 반환값을 input의 값으로 하고 알맞은 input 이름을 설정합니다. 만약 컨트롤러에 `@person` 변수가 정의되어 있고 사람의 이름이 Henry인 경우 폼은 다음과 같습니다: [[[For these helpers the first argument is the name of an instance variable and the second is the name of a method (usually an attribute) to call on that object. Rails will set the value of the input control to the return value of that method for the object and set an appropriate input name. If your controller has defined `@person` and that person's name is Henry then a form containing:]]]

```erb
<%= text_field(:person, :name) %>
```

다음과 같은 결과를 생성합니다 [[[will produce output similar to]]]

```erb
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

폼 전송시 사용자가 입력한 값은 `params[:person][:name]`에 저장됩니다. `params[:person]` 해쉬는 `Person.new`의 인수 또는 `@person`이 Person 인스턴스인경우 `@person.update`의 인수로 전달하기 알맞습니다. 헬퍼의 두번째 인수로 속성의 이름이 사용되는것이 강제적인것은 아닙니다. 위의 경우 person 객체가 `name` 혹은 `name=` 메소드를 가지고 있다면 레일스의 헬퍼는 동작합니다. [[[Upon form submission the value entered by the user will be stored in `params[:person][:name]`. The `params[:person]` hash is suitable for passing to `Person.new` or, if `@person` is an instance of Person, `@person.update`. While the name of an attribute is the most common second parameter to these helpers this is not compulsory. In the example above, as long as person objects have a `name` and a `name=` method Rails will be happy.]]]

WARNING: `person` 또는 `"person"` 처럼 인스턴스 변수의 이름을 전달해야지 모델 인스턴스를 전달하는것이 아닙니다. [[[You must pass the name of an instance variable, i.e. `:person` or `"person"`, not an actual instance of your model object.]]]

레일스는 모델 객체와 연동된 검증 오류를 표시하는 헬퍼를 제공합니다. 이것들은 [Active Record Validations](./active_record_validations.html#displaying-validation-errors-in-views)가이드에 자세히 설명되어 있습니다. [[[Rails provides helpers for displaying the validation errors associated with a model object. These are covered in detail by the [Active Record Validations](./active_record_validations.html#displaying-validation-errors-in-views) guide.]]]

### [Binding a Form to an Object] 객체에 폼 바인딩

이것은 완벽함과 멀어지면서 편리함을 증가시킵니다. 만약 Person의 많은 속성을 수정하는 경우 변경하려는 객체의 이름을 반복해서 적어야 합니다. 우리가 원하는것은 폼을 모델객체에 바인딩 하는것인데 `form_for`가 정확히 그런 동작을 합니다. [[[While this is an increase in comfort it is far from perfect. If Person has many attributes to edit then we would be repeating the name of the edited object many times. What we want to do is somehow bind a form to a model object, which is exactly what `form_for` does.]]]

articles을 다루는 컨트롤러 `app/controllers/articles_controller.rb`를 가정했을때: [[[Assume we have a controller for dealing with articles `app/controllers/articles_controller.rb`:]]]

```ruby
def new
  @article = Article.new
end
```

`form_for`를 사용하는 뷰 `app/views/articles/new.html.erb`는 다음과 같습니다: [[[The corresponding view `app/views/articles/new.html.erb` using `form_for` looks like this:]]]

```erb
<%= form_for @article, url: {action: "create"}, html: {class: "nifty_form"} do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body, size: "60x12" %>
  <%= f.submit "Create" %>
<% end %>
```

여기 주의할 몇가지 사항이 있습니다: [[[There are a few things to note here:]]]


* `@article`은 수정하려는 실제 객체이다. [[[`@article` is the actual object being edited.]]]

* 옵션은 단일 해쉬이다. 라우팅 옵션은 `:url` 해쉬, HTML 옵션은 `:html` 해쉬에 전달된다. 또한 `:namespace` 옵션을 제공해 폼이 유일한 id 값을 가지게할 수 있다. namespace 속성값은 밑줄문자를 추가후 생성된 HTML id 값에 접두사로 사용된다. [[[There is a single hash of options. Routing options are passed in the `:url` hash, HTML options are passed in the `:html` hash. Also you can provide a `:namespace` option for your form to ensure uniqueness of id attributes on form elements. The namespace attribute will be prefixed with underscore on the generated HTML id.]]]

* `form_for` 메소드는 **폼 빌더** 객체를 yields 한다(`f` 변수). [[[The `form_for` method yields a **form builder** object (the `f` variable).]]]

* 폼 컨트롤을 생성하는 메소드는 폼 빌더 오브젝트 `f`의 **on** 메소드를 호출한다. [[[Methods to create form controls are called **on** the form builder object `f`]]]

HTML 결과는 다음과 같다: [[[The resulting HTML is:]]]

```html
<form accept-charset="UTF-8" action="/articles/create" method="post" class="nifty_form">
  <input id="article_title" name="article[title]" type="text" />
  <textarea id="article_body" name="article[body]" cols="60" rows="12"></textarea>
  <input name="commit" type="submit" value="Create" />
</form>
```

`form_for` 컨트롤에 전달된 name은 `params`의 키로 폼의 값에 접근할 수 있다. `article`의 모든 input은 `article[속성이름]`과 같은 name을 가진다. `create` 액션에서 `params[:article]` 해쉬는 `:title`, `:body` 키를 가진다. parameter_names 섹션에서 보다 자세한 input name에 대한 내용을 알 수 있다. [[[The name passed to `form_for` controls the key used in `params` to access the form's values. Here the name is `article` and so all the inputs have names of the form `article[attribute_name]`. Accordingly, in the `create` action `params[:article]` will be a hash with keys `:title` and `:body`. You can read more about the significance of input names in the parameter_names section.]]]

폼 빌더에 의해 호출된 헬퍼 메소드는 이미 폼 빌더에 의해 관리되어 어떤 객체가 수정되는지 필요하지 않을때를 제외하고는 모델 객체의 헬퍼와 동일하다. [[[The helper methods called on the form builder are identical to the model object helpers except that it is not necessary to specify which object is being edited since this is already managed by the form builder.]]]

`fields_for` 헬퍼를 이용해 실제 `<form>` 태그를 생성하는 대신 바인딩을 생성할 수 있다. 이는 같은 폼 안에서 또 다른 모델객체를 수정할 때 유용하다. 예를들어 만약 Pserson 모델과 연관된 ContactDetail 모델을 가지고 있을때 다음과 같이 둘다 포함하는 폼을 생성할 수 있다: [[[You can create a similar binding without actually creating `<form>` tags with the `fields_for` helper. This is useful for editing additional model objects with the same form. For example if you had a Person model with an associated ContactDetail model you could create a form for creating both like so:]]]

```erb
<%= form_for @person, url: {action: "create"} do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for @person.contact_detail do |contact_details_form| %>
    <%= contact_details_form.text_field :phone_number %>
  <% end %>
<% end %>
```

다음과 같은 결과를 생성한다: [[[which produces the following output:]]]

```html
<form accept-charset="UTF-8" action="/people/create" class="new_person" id="new_person" method="post">
  <input id="person_name" name="person[name]" type="text" />
  <input id="contact_detail_phone_number" name="contact_detail[phone_number]" type="text" />
</form>
```

`fields_for`에 의해 yield된 객체는 `form_for`에 yield된 폼 빌더와 비슷하다(사실 `form_for` 내부에서는 `fields_for`를 호출). [[[The object yielded by `fields_for` is a form builder like the one yielded by `form_for` (in fact `form_for` calls `fields_for` internally).]]]

### [Relying on Record Identification] 레코드 식별에 의지하기

사용자 어플리케이션에서 Article 모델을 사용 하려면 **리소스**에 선언 해야한다. [[[The Article model is directly available to users of the application, so — following the best practices for developing with Rails — you should declare it **a resource**:]]]

```ruby
resources :articles
```

리소스를 선언하는것은 몇가지 사이드 이팩트가 있다. [Rails Routing From the Outside In](routing.html#resource-routing-the-rails-default)에서 리소스 설정과 사용에 대해 보다 자세한 정보를 얻을수 있다. [[[TIP: Declaring a resource has a number of side-affects. See [Rails Routing From the Outside In](routing.html#resource-routing-the-rails-default) for more information on setting up and using resources.]]]

RESTful 리소스를 다룰때, **레코드 식별**에 의지해 `form_for`를 사용하면 상당히 쉬워진다. 모델 인스턴스를 전달하는 것으로 레일스는 모델이름과 rest를 알아낸다. [[[When dealing with RESTful resources, calls to `form_for` can get significantly easier if you rely on **record identification**. In short, you can just pass the model instance and have Rails figure out model name and the rest:]]]

```ruby
## Creating a new article
# long-style:
form_for(@article, url: articles_path)
# same thing, short-style (record identification gets used):
form_for(@article)

## Editing an existing article
# long-style:
form_for(@article, url: article_path(@article), html: {method: "patch"})
# short-style:
form_for(@article)
```

`form_for`의 간략버전은 레코드가 신규인지 기존에 존재하던것인지와 무관하게 동일한 것을 편리하게 한다. 레코드 식별은 `record.new_record?` 메소드를 통해 신규 레코드인지 알아낸다. 또한 정확한 경로에 폼을 전송하고 객체의 클래스에 기반에 이름을 정한다. [[[Notice how the short-style `form_for` invocation is conveniently the same, regardless of the record being new or existing. Record identification is smart enough to figure out if the record is new by asking `record.new_record?`. It also selects the correct path to submit to and the name based on the class of the object.]]]

레일스는 또한 알맞은 `class`, `id`를 자동으로 설정한다: article을 생성하는 폼은 `id`, `class`에 `new_article`를 가진다. 만약 id 23번 article를 수정한다면 `class`는 `edit_article`, `id`는 `edit_article_23`가 된다. 이 속성은 가이드의 간결성을 위해 생략한다. [[[Rails will also automatically set the `class` and `id` of the form appropriately: a form creating an article would have `id` and `class` `new_article`. If you were editing the article with id 23, the `class` would be set to `edit_article` and the id to `edit_article_23`. These attributes will be omitted for brevity in the rest of this guide.]]]

WARNING: STI(단일 테이블 상속)을 모델과 함께 사용한다면, 상위 리소스만 선언된경우 서브클래스는 레코드 식별에 의지할수 없다. 이경우 모델 이름, `:url`, `:method`를 명시해야한다. [[[When you're using STI (single-table inheritance) with your models, you can't rely on record identification on a subclass if only their parent class is declared a resource. You will have to specify the model name, `:url`, and `:method` explicitly.]]]

#### [Dealing with Namespaces] 네임스페이스 다루기

네임스페이스 라우트를 생성하면 `form_for`는 9개의 약칭을 가집니다. 만약 당신의 어플리케이션이 admin 네임스페이스를 가진다면 [[[If you have created namespaced routes, `form_for` has a nifty shorthand for that too. If your application has an admin namespace then]]]

```ruby
form_for [:admin, @article]
```

admin 네임스페이스안의 articles 컨트롤러로 전송하는 폼을 만들게 됩니다(업데이트의 경우 `admin_article_path(@article)`에 전송). 만약 몇개의 네임스페이스 레벨을 가지는 구문은 비슷합니다: [[[will create a form that submits to the articles controller inside the admin namespace (submitting to `admin_article_path(@article)` in the case of an update). If you have several levels of namespacing then the syntax is similar:]]]

```ruby
form_for [:admin, :management, @article]
```

레일스 라우팅 시스템과 관련규칙에 관한 더 자세한 정보는 [routing guide](routing.html)를 참고합니다. [[[For more information on Rails' routing system and the associated conventions, please see the [routing guide](routing.html).]]]


### [How do forms with PATCH, PUT, or DELETE methods work?] 폼의 PATCH, PUT, DELETE 메소드는 어떻게 동작하는가?

레일스 프레임워크는 RESTful 디자인을 장려합니다. 이는 많은 "PATCH", "DELETE" 요청("GET", "POST"외에)을 사용하는것을 의미합니다. 하지만 대부분의 브라우저는 폼을 전송할때 "GET", "POST" 메소드 이외에는 _지원하지 않습니다_. [[[The Rails framework encourages RESTful design of your applications, which means you'll be making a lot of "PATCH" and "DELETE" requests (besides "GET" and "POST"). However, most browsers _don't support_ methods other than "GET" and "POST" when it comes to submitting forms.]]]

레일스는 이 이슈를 POST의 숨겨진 input `"_method"` 이름으로 다른 메소드를 에뮬레이팅하여 원하는 메소드를 반영하도록합니다. [[[Rails works around this issue by emulating other methods over POST with a hidden input named `"_method"`, which is set to reflect the desired method:]]]

```ruby
form_tag(search_path, method: "patch")
```

결과: [[[output:]]]

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <div style="margin:0;padding:0">
    <input name="_method" type="hidden" value="patch" />
    <input name="utf8" type="hidden" value="&#x2713;" />
    <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  </div>
  ...
```

POST 데이터를 파싱할때, 레일스는 HTTP 메소드가 내부의 지정된 하나인 경우(예제는 "PATCH") `_method` 특수 파라미터를 고려해 동작하도록 합니다. [[[When parsing POSTed data, Rails will take into account the special `_method` parameter and acts as if the HTTP method was the one specified inside it ("PATCH" in this example).]]]

[Making Select Boxes with Ease] Select 박스 쉽게 만들기
-----------------------------

HTML에서의 Select 박스는 많은 마크업(각각의 선택 항목마다 한개의 `OPTION`)을 필요로 하기 때문에 동적으로 생성하는것이 의미가 있습니다. [[[Select boxes in HTML require a significant amount of markup (one `OPTION` element for each option to choose from), therefore it makes the most sense for them to be dynamically generated.]]]

다음과 같은 마크업이 있습니다: [[[Here is what the markup might look like:]]]

```html
<select name="city_id" id="city_id">
  <option value="1">Lisbon</option>
  <option value="2">Madrid</option>
  ...
  <option value="12">Berlin</option>
</select>
```

여기 유저에게 보여질 도시 이름 목록이 있습니다. 어플리케이션 내부적으로는 옵션의 value 속성에 있는 ID 값만을 사용합니다. 레일스에서 이부분을 어떻게 쉽게 해주는지 살펴 보겠습니다. [[[Here you have a list of cities whose names are presented to the user. Internally the application only wants to handle their IDs so they are used as the options' value attribute. Let's see how Rails can help out here.]]]

### [The Select and Option Tags] Select, Option 태그

가장 일반적인 헬퍼는 `select_tag` 이며, 옵션의 문자열을 감싸는 `SELECT` 태그를 생성합니다. [[[The most generic helper is `select_tag`, which — as the name implies — simply generates the `SELECT` tag that encapsulates an options string:]]]

```erb
<%= select_tag(:city_id, '<option value="1">Lisbon</option>...') %>
```

이것은 시작에 불과하며 option 태그를 동적으로 생성하지는 않습니다. `options_for_select` 헬퍼를 이용해 option 태그를 생성할 수 있습니다: [[[This is a start, but it doesn't dynamically create the option tags. You can generate option tags with the `options_for_select` helper:]]]

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ...]) %>

결과: [[[output:]]]

<option value="1">Lisbon</option>
<option value="2">Madrid</option>
...
```

`options_for_select`의 첫번째 인수는 각 항목마다 두개의 항목을 가진 중첩된 배열 입니다: 각 항목은 option 문자열(도시 이름)과 option 값(도시 id)로 이루어졌습니다. option 값은 컨트롤러에 전달됩니다. 이값은 데이터베이스 객체의 id에 상응하는 경우가 보통이지만 상황에따라 아닐수있습니다. [[[The first argument to `options_for_select` is a nested array where each element has two elements: option text (city name) and option value (city id). The option value is what will be submitted to your controller. Often this will be the id of a corresponding database object but this does not have to be the case.]]]

이것을 알면 `select_tag`, `options_for_select`을 이용해 원하는 마크업을 만들수 있습니다: [[[Knowing this, you can combine `select_tag` and `options_for_select` to achieve the desired, complete markup:]]]

```erb
<%= select_tag(:city_id, options_for_select(...)) %>
```

`options_for_select`에 옵션값을 전달해 사전에 선택될 옵션을 지정할 수 있습니다. [[[`options_for_select` allows you to pre-select an option by passing its value.]]]

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ...], 2) %>

output:

<option value="1">Lisbon</option>
<option value="2" selected="selected">Madrid</option>
...
```

레일스는 option의 값을 확인해 전달된 값과 일치하면 `selected` 속성을 옵션에 추가합니다. [[[Whenever Rails sees that the internal value of an option being generated matches this value, it will add the `selected` attribute to that option.]]]

TIP: `options_for_select`의 두번째 인수는 내부에서 사용하는 값과 동일해야합니다. 값은 숫자 2인데 인수로 문자열 "2"를 `options_for_select`에 전달할 수 없으며 숫자 2를 전달해야합니다. `params` 해쉬로부터 추출된 값은 모두 문자열이라는것을 유의해야합니다. [[[The second argument to `options_for_select` must be exactly equal to the desired internal value. In particular if the value is the integer 2 you cannot pass "2" to `options_for_select` — you must pass 2. Be aware of values extracted from the `params` hash as they are all strings.]]]

WARNING: `:include_blank` 또는 `:prompt`가 제공되지 않는다면, select의 `required` 속성이 true 인경우 `:include_blank`는 true로 설정되며, `size`는 한개가 되고, `multiple`는 true가 아니게 됩니다. [[[when `:include_blank` or `:prompt` are not present, `:include_blank` is forced true if the select attribute `required` is true, display `size` is one and `multiple` is not true.]]]

해쉬를 이용해 option에 임의의 속성을 추가할 수 있습니다: [[[You can add arbitrary attributes to the options using hashes:]]]

```html+erb
<%= options_for_select([['Lisbon', 1, {'data-size' => '2.8 million'}], ['Madrid', 2, {'data-size' => '3.2 million'}]], 2) %>

결과: [[[output:]]]

<option value="1" data-size="2.8 million">Lisbon</option>
<option value="2" selected="selected" data-size="3.2 million">Madrid</option>
...
```

### [Select Boxes for Dealing with Models] 모델과 연동되는 Select 박스

대부분의 경우 폼 컨트롤은 특정 데이터베이스 모델에 연동되고 레일스는 그 목적을 위한 헬퍼를 제공합니다. 다른 폼 헬퍼와 동일하게 모델과 연동하는경우 `select_tag`에서 `_tag` 접미사를 제거합니다. [[[In most cases form controls will be tied to a specific database model and as you might expect Rails provides helpers tailored for that purpose. Consistent with other form helpers, when dealing with models you drop the `_tag` suffix from `select_tag`:]]]

```ruby
# controller:
@person = Person.new(city_id: 2)
```

```erb
# view:
<%= select(:person, :city_id, [['Lisbon', 1], ['Madrid', 2], ...]) %>
```

세번째 변수(options의 배열)는 `options_for_select`에 전달하는 인수와 동일합니다. 한가지 이점은 사전에 선택될 도시이름에 대해 신경쓰지 않아도 유저가 이미 가지고 있는 도시를 선택합니다 - 레일스는 `@person.city_id` 값으로부터 이를 수행합니다. [[[Notice that the third parameter, the options array, is the same kind of argument you pass to `options_for_select`. One advantage here is that you don't have to worry about pre-selecting the correct city if the user already has one — Rails will do this for you by reading from the `@person.city_id` attribute.]]]

`@person` 영역을 가지는 폼 빌더헬퍼에서 `select` 헬퍼를 사용하고자 한다면 다음과 같습니다: [[[As with other helpers, if you were to use the `select` helper on a form builder scoped to the `@person` object, the syntax would be:]]]

```erb
# select on a form builder
<%= f.select(:city_id, ...) %>
```

WARNING: `belongs_to` association을 설정하기위해 `select`(또는 비슷한 헬퍼인 `collection_select`, `select_tag`)를 사용할때는 assosiation 이름이 아니라 외부키의 이름을 전달해야 합니다.(위의 예제에서는 `city_id`) `city_id`가 아니라 `city`를 사용하면 `params` 해쉬를 `Person.new`나 `update`에 전달할때 Active Record는 ` ActiveRecord::AssociationTypeMismatch: City(#17815740) expected, got String(#1138750) ` 에러를 발생시킵니다. 이를 살펴볼수 있는 또다른 방법은 폼 헬퍼의 속성만을 수정하는것입니다. 사용자가 외부키를 직접 변경하는 잠재적인 보안 문제에 대해 알아야합니다. [[[If you are using `select` (or similar helpers such as `collection_select`, `select_tag`) to set a `belongs_to` association you must pass the name of the foreign key (in the example above `city_id`), not the name of association itself. If you specify `city` instead of `city_id` Active Record will raise an error along the lines of ` ActiveRecord::AssociationTypeMismatch: City(#17815740) expected, got String(#1138750) ` when you pass the `params` hash to `Person.new` or `update`. Another way of looking at this is that form helpers only edit attributes. You should also be aware of the potential security ramifications of allowing users to edit foreign keys directly.]]]

### [Option Tags from a Collection of Arbitrary Objects] 임의의 객체 모음을 위한 option 태그

`options_for_select`를 이용한 option 태그 생성은 각 option의 문자열과 값으로 이루어진 배열을 필요로 합니다. 하지만 City 모델(아마도 Active Record)을 가지고 있고 이들 객체 모음으로부터 option 태그를 생성하고 싶다면 어떻게 해야할까요? 여기에 중첩배열을 만들어내는 한가지 해결방법이 있습니다: [[[Generating options tags with `options_for_select` requires that you create an array containing the text and value for each option. But what if you had a City model (perhaps an Active Record one) and you wanted to generate option tags from a collection of those objects? One solution would be to make a nested array by iterating over them:]]]

```erb
<% cities_array = City.all.map { |city| [city.name, city.id] } %>
<%= options_for_select(cities_array) %>
```

이것은 완벽히 유효한 해결방법이지만 레일스는 간결한 대안인 `options_from_collection_for_select`를 제공합니다. 이 헬퍼는 임의의 객체 모음이 2개의 인수(option의 **value**, **text** 에 접근하는 메서드 이름)를 가지고 있다고 가정합니다: [[[This is a perfectly valid solution, but Rails provides a less verbose alternative: `options_from_collection_for_select`. This helper expects a collection of arbitrary objects and two additional arguments: the names of the methods to read the option **value** and **text** from, respectively:]]]

```erb
<%= options_from_collection_for_select(City.all, :id, :name) %>
```

이름에서 알 수 있듯이, 이것은 option 태그만을 생성합니다. select 박스와 함께 사용하려면 `options_for_select`처럼 `select_tag`와 같이 사용합니다. 모델 객체와 사용하는경우, `select`가 `select_tag`, `options_for_select` 하나로 합친것처럼, `collection_select`는 `select_tag`, `options_from_collection_for_select` 하나로 합친것처럼 동작합니다. [[[As the name implies, this only generates option tags. To generate a working select box you would need to use it in conjunction with `select_tag`, just as you would with `options_for_select`. When working with model objects, just as `select` combines `select_tag` and `options_for_select`, `collection_select` combines `select_tag` with `options_from_collection_for_select`.]]]

```erb
<%= collection_select(:person, :city_id, City.all, :id, :name) %>
```

정리해보면, `options_for_select`가 `select`로 되는것처럼 `options_from_collection_for_select`는 `collection_select`으로 됩니다. [[[To recap, `options_from_collection_for_select` is to `collection_select` what `options_for_select` is to `select`.]]]

NOTE: `options_for_select`에 전달되는 배열의 쌍은 첫번째는 문자열 두번째는 값입니다. 하지만 `options_from_collection_for_select`는 첫번째 인수는 값 메소드, 두번째는 문자열 메소드입니다. [[[Pairs passed to `options_for_select` should have the name first and the id second, however with `options_from_collection_for_select` the first argument is the value method and the second the text method.]]]

### [Time Zone and Country Select] 시간대와 국가 선택

레일스에서 시간대 지원을 사용하려면 사용자에게 어떤 시간대에 있는지 질의해야합니다. 이를 위해 미리 지정되어 있는 TimeZone 객체들을 `collection_select`를 이용해 select option을 생성해야 합니다. 하지만 `time_zone_select` 헬퍼를 이용해 쉽게 사용할 수 있습니다. [[[To leverage time zone support in Rails, you have to ask your users what time zone they are in. Doing so would require generating select options from a list of pre-defined TimeZone objects using `collection_select`, but you can simply use the `time_zone_select` helper that already wraps this:]]]

```erb
<%= time_zone_select(:person, :time_zone) %>
```

또한 좀더 자세한 설정을 위해 `time_zone_options_for_select` 헬퍼가 있습니다. 이 두가지 메소드의 인수에 대한 자세한 내용은 API 문서를 읽어보기 바랍니다. [[[There is also `time_zone_options_for_select` helper for a more manual (therefore more customizable) way of doing this. Read the API documentation to learn about the possible arguments for these two methods.]]]

레일스는 국가를 선택하기위해 `country_select` 헬퍼를 _사용_합니다. 하지만 이것은 [country_select plugin](https://github.com/stefanpenner/country_select)으로 분리되어 있습니다. 이것을 사용할때 특정이름을 목록에 포함하거나 제외하는것은 논란의 여지가 있다는것을 인식해야합니다.(이것은 레일스로부터 분리된 이유이기도 합니다) [[[Rails _used_ to have a `country_select` helper for choosing countries, but this has been extracted to the [country_select plugin](https://github.com/stefanpenner/country_select). When using this, be aware that the exclusion or inclusion of certain names from the list can be somewhat controversial (and was the reason this functionality was extracted from Rails).]]]

Using Date and Time Form Helpers
--------------------------------

You can choose not to use the form helpers generating HTML5 date and time input fields and use the alternative date and time helpers. These date and time helpers differ from all the other form helpers in two important respects:

* Dates and times are not representable by a single input element. Instead you have several, one for each component (year, month, day etc.) and so there is no single value in your `params` hash with your date or time.
* Other helpers use the `_tag` suffix to indicate whether a helper is a barebones helper or one that operates on model objects. With dates and times, `select_date`, `select_time` and `select_datetime` are the barebones helpers, `date_select`, `time_select` and `datetime_select` are the equivalent model object helpers.

Both of these families of helpers will create a series of select boxes for the different components (year, month, day etc.).

### Barebones Helpers

The `select_*` family of helpers take as their first argument an instance of Date, Time or DateTime that is used as the currently selected value. You may omit this parameter, in which case the current date is used. For example

```erb
<%= select_date Date.today, prefix: :start_date %>
```

outputs (with actual option values omitted for brevity)

```html
<select id="start_date_year" name="start_date[year]"> ... </select>
<select id="start_date_month" name="start_date[month]"> ... </select>
<select id="start_date_day" name="start_date[day]"> ... </select>
```

The above inputs would result in `params[:start_date]` being a hash with keys `:year`, `:month`, `:day`. To get an actual Time or Date object you would have to extract these values and pass them to the appropriate constructor, for example

```ruby
Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
```

The `:prefix` option is the key used to retrieve the hash of date components from the `params` hash. Here it was set to `start_date`, if omitted it will default to `date`.

### Model Object Helpers

`select_date` does not work well with forms that update or create Active Record objects as Active Record expects each element of the `params` hash to correspond to one attribute.
The model object helpers for dates and times submit parameters with special names; when Active Record sees parameters with such names it knows they must be combined with the other parameters and given to a constructor appropriate to the column type. For example:

```erb
<%= date_select :person, :birth_date %>
```

outputs (with actual option values omitted for brevity)

```html
<select id="person_birth_date_1i" name="person[birth_date(1i)]"> ... </select>
<select id="person_birth_date_2i" name="person[birth_date(2i)]"> ... </select>
<select id="person_birth_date_3i" name="person[birth_date(3i)]"> ... </select>
```

which results in a `params` hash like

```ruby
{:person => {'birth_date(1i)' => '2008', 'birth_date(2i)' => '11', 'birth_date(3i)' => '22'}}
```

When this is passed to `Person.new` (or `update`), Active Record spots that these parameters should all be used to construct the `birth_date` attribute and uses the suffixed information to determine in which order it should pass these parameters to functions such as `Date.civil`.

### Common Options

Both families of helpers use the same core set of functions to generate the individual select tags and so both accept largely the same options. In particular, by default Rails will generate year options 5 years either side of the current year. If this is not an appropriate range, the `:start_year` and `:end_year` options override this. For an exhaustive list of the available options, refer to the [API documentation](http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html).

As a rule of thumb you should be using `date_select` when working with model objects and `select_date` in other cases, such as a search form which filters results by date.

NOTE: In many cases the built-in date pickers are clumsy as they do not aid the user in working out the relationship between the date and the day of the week.

### Individual Components

Occasionally you need to display just a single date component such as a year or a month. Rails provides a series of helpers for this, one for each component `select_year`, `select_month`, `select_day`, `select_hour`, `select_minute`, `select_second`. These helpers are fairly straightforward. By default they will generate an input field named after the time component (for example "year" for `select_year`, "month" for `select_month` etc.) although this can be overridden with the  `:field_name` option. The `:prefix` option works in the same way that it does for `select_date` and `select_time` and has the same default value.

The first parameter specifies which value should be selected and can either be an instance of a Date, Time or DateTime, in which case the relevant component will be extracted, or a numerical value. For example

```erb
<%= select_year(2009) %>
<%= select_year(Time.now) %>
```

will produce the same output if the current year is 2009 and the value chosen by the user can be retrieved by `params[:date][:year]`.

Uploading Files
---------------

A common task is uploading some sort of file, whether it's a picture of a person or a CSV file containing data to process. The most important thing to remember with file uploads is that the rendered form's encoding **MUST** be set to "multipart/form-data". If you use `form_for`, this is done automatically. If you use `form_tag`, you must set it yourself, as per the following example.

The following two forms both upload a file.

```erb
<%= form_tag({action: :upload}, multipart: true) do %>
  <%= file_field_tag 'picture' %>
<% end %>

<%= form_for @person do |f| %>
  <%= f.file_field :picture %>
<% end %>
```

Rails provides the usual pair of helpers: the barebones `file_field_tag` and the model oriented `file_field`. The only difference with other helpers is that you cannot set a default value for file inputs as this would have no meaning. As you would expect in the first case the uploaded file is in `params[:picture]` and in the second case in `params[:person][:picture]`.

### What Gets Uploaded

The object in the `params` hash is an instance of a subclass of IO. Depending on the size of the uploaded file it may in fact be a StringIO or an instance of File backed by a temporary file. In both cases the object will have an `original_filename` attribute containing the name the file had on the user's computer and a `content_type` attribute containing the MIME type of the uploaded file. The following snippet saves the uploaded content in `#{Rails.root}/public/uploads` under the same name as the original file (assuming the form was the one in the previous example).

```ruby
def upload
  uploaded_io = params[:person][:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'w') do |file|
    file.write(uploaded_io.read)
  end
end
```

Once a file has been uploaded, there are a multitude of potential tasks, ranging from where to store the files (on disk, Amazon S3, etc) and associating them with models to resizing image files and generating thumbnails. The intricacies of this are beyond the scope of this guide, but there are several libraries designed to assist with these. Two of the better known ones are [CarrierWave](https://github.com/jnicklas/carrierwave) and [Paperclip](http://www.thoughtbot.com/projects/paperclip).

NOTE: If the user has not selected a file the corresponding parameter will be an empty string.

### Dealing with Ajax

Unlike other forms making an asynchronous file upload form is not as simple as providing `form_for` with `remote: true`. With an Ajax form the serialization is done by JavaScript running inside the browser and since JavaScript cannot read files from your hard drive the file cannot be uploaded. The most common workaround is to use an invisible iframe that serves as the target for the form submission.

Customizing Form Builders
-------------------------

As mentioned previously the object yielded by `form_for` and `fields_for` is an instance of FormBuilder (or a subclass thereof). Form builders encapsulate the notion of displaying form elements for a single object. While you can of course write helpers for your forms in the usual way, you can also subclass FormBuilder and add the helpers there. For example

```erb
<%= form_for @person do |f| %>
  <%= text_field_with_label f, :first_name %>
<% end %>
```

can be replaced with

```erb
<%= form_for @person, builder: LabellingFormBuilder do |f| %>
  <%= f.text_field :first_name %>
<% end %>
```

by defining a LabellingFormBuilder class similar to the following:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    label(attribute) + super
  end
end
```

If you reuse this frequently you could define a `labeled_form_for` helper that automatically applies the `builder: LabellingFormBuilder` option.

The form builder used also determines what happens when you do

```erb
<%= render partial: f %>
```

If `f` is an instance of FormBuilder then this will render the `form` partial, setting the partial's object to the form builder. If the form builder is of class LabellingFormBuilder then the `labelling_form` partial would be rendered instead.

Understanding Parameter Naming Conventions
------------------------------------------

As you've seen in the previous sections, values from forms can be at the top level of the `params` hash or nested in another hash. For example in a standard `create`
action for a Person model, `params[:person]` would usually be a hash of all the attributes for the person to create. The `params` hash can also contain arrays, arrays of hashes and so on.

Fundamentally HTML forms don't know about any sort of structured data, all they generate is name–value pairs, where pairs are just plain strings. The arrays and hashes you see in your application are the result of some parameter naming conventions that Rails uses.

TIP: You may find you can try out examples in this section faster by using the console to directly invoke Racks' parameter parser. For example,

```ruby
Rack::Utils.parse_query "name=fred&phone=0123456789"
# => {"name"=>"fred", "phone"=>"0123456789"}
```

### Basic Structures

The two basic structures are arrays and hashes. Hashes mirror the syntax used for accessing the value in `params`. For example if a form contains

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

the `params` hash will contain

```erb
{'person' => {'name' => 'Henry'}}
```

and `params[:person][:name]` will retrieve the submitted value in the controller.

Hashes can be nested as many levels as required, for example

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

will result in the `params` hash being

```ruby
{'person' => {'address' => {'city' => 'New York'}}}
```

Normally Rails ignores duplicate parameter names. If the parameter name contains an empty set of square brackets [] then they will be accumulated in an array. If you wanted people to be able to input multiple phone numbers, you could place this in the form:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

This would result in `params[:person][:phone_number]` being an array.

### Combining Them

We can mix and match these two concepts. For example, one element of a hash might be an array as in the previous example, or you can have an array of hashes. For example a form might let you create any number of addresses by repeating the following form fragment

```html
<input name="addresses[][line1]" type="text"/>
<input name="addresses[][line2]" type="text"/>
<input name="addresses[][city]" type="text"/>
```

This would result in `params[:addresses]` being an array of hashes with keys `line1`, `line2` and `city`. Rails decides to start accumulating values in a new hash whenever it encounters an input name that already exists in the current hash.

There's a restriction, however, while hashes can be nested arbitrarily, only one level of "arrayness" is allowed. Arrays can be usually replaced by hashes, for example instead of having an array of model objects one can have a hash of model objects keyed by their id, an array index or some other parameter.

WARNING: Array parameters do not play well with the `check_box` helper. According to the HTML specification unchecked checkboxes submit no value. However it is often convenient for a checkbox to always submit a value. The `check_box` helper fakes this by creating an auxiliary hidden input with the same name. If the checkbox is unchecked only the hidden input is submitted and if it is checked then both are submitted but the value submitted by the checkbox takes precedence. When working with array parameters this duplicate submission will confuse Rails since duplicate input names are how it decides when to start a new array element. It is preferable to either use `check_box_tag` or to use hashes instead of arrays.

### Using Form Helpers

The previous sections did not use the Rails form helpers at all. While you can craft the input names yourself and pass them directly to helpers such as `text_field_tag` Rails also provides higher level support. The two tools at your disposal here are the name parameter to `form_for` and `fields_for` and the `:index` option that helpers take.

You might want to render a form with a set of edit fields for each of a person's addresses. For example:

```erb
<%= form_for @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address do |address_form|%>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Assuming the person had two addresses, with ids 23 and 45 this would create output similar to this:

```html
<form accept-charset="UTF-8" action="/people/1" class="edit_person" id="edit_person_1" method="post">
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

This will result in a `params` hash that looks like

```ruby
{'person' => {'name' => 'Bob', 'address' => {'23' => {'city' => 'Paris'}, '45' => {'city' => 'London'}}}}
```

Rails knows that all these inputs should be part of the person hash because you called `fields_for` on the first form builder. By specifying an `:index` option you're telling Rails that instead of naming the inputs `person[address][city]` it should insert that index surrounded by [] between the address and the city. If you pass an Active Record object as we did then Rails will call `to_param` on it, which by default returns the database id. This is often useful as it is then easy to locate which Address record should be modified. You can pass numbers with some other significance, strings or even `nil` (which will result in an array parameter being created).

To create more intricate nestings, you can specify the first part of the input name (`person[address]` in the previous example) explicitly, for example

```erb
<%= fields_for 'person[address][primary]', address, index: address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

will create inputs like

```html
<input id="person_address_primary_1_city" name="person[address][primary][1][city]" type="text" value="bologna" />
```

As a general rule the final input name is the concatenation of the name given to `fields_for`/`form_for`, the index value and the name of the attribute. You can also pass an `:index` option directly to helpers such as `text_field`, but it is usually less repetitive to specify this at the form builder level rather than on individual input controls.

As a shortcut you can append [] to the name and omit the `:index` option. This is the same as specifying `index: address` so

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produces exactly the same output as the previous example.

Forms to external resources
---------------------------

If you need to post some data to an external resource it is still great to build your form using rails form helpers. But sometimes you need to set an `authenticity_token` for this resource. You can do it by passing an `authenticity_token: 'your_external_token'` parameter to the `form_tag` options:

```erb
<%= form_tag 'http://farfar.away/form', authenticity_token: 'external_token') do %>
  Form contents
<% end %>
```

Sometimes when you submit data to an external resource, like payment gateway, fields you can use in your form are limited by an external API. So you may want not to generate an `authenticity_token` hidden field at all. For doing this just pass `false` to the `:authenticity_token` option:

```erb
<%= form_tag 'http://farfar.away/form', authenticity_token: false) do %>
  Form contents
<% end %>
```

The same technique is also available for `form_for`:

```erb
<%= form_for @invoice, url: external_url, authenticity_token: 'external_token' do |f| %>
  Form contents
<% end %>
```

Or if you don't want to render an `authenticity_token` field:

```erb
<%= form_for @invoice, url: external_url, authenticity_token: false do |f| %>
  Form contents
<% end %>
```

Building Complex Forms
----------------------

Many apps grow beyond simple forms editing a single object. For example when creating a Person you might want to allow the user to (on the same form) create multiple address records (home, work, etc.). When later editing that person the user should be able to add, remove or amend addresses as necessary.

### Configuring the Model

Active Record provides model level support  via the `accepts_nested_attributes_for` method:

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses
end

class Address < ActiveRecord::Base
  belongs_to :person
end
```

This creates an `addresses_attributes=` method on `Person` that allows you to create, update and (optionally) destroy addresses.

### Building the Form

The following form allows a user to create a `Person` and its associated addresses.

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


When an association accepts nested attributes `fields_for` renders its block once for every element of the association. In particular, if a person has no addresses it renders nothing. A common pattern is for the controller to build one or more empty children so that at least one set of fields is shown to the user. The example below would result in 3 sets of address fields being rendered on the new person form.

```ruby
def new
  @person = Person.new
  3.times { @person.addresses.build}
end
```

`fields_for` yields a form builder that names parameters in the format expected the accessor generated by `accepts_nested_attributes_for`. For example when creating a user with 2 addresses, the submitted parameters would look like

```ruby
{
    :person => {
        :name => 'John Doe',
        :addresses_attributes => {
            '0' => {
                :kind  => 'Home',
                :street => '221b Baker Street',
            },
            '1' => {
                :kind => 'Office',
                :street => '31 Spooner Street'
            }
        }
    }
}
```

The keys of the `:addresses_attributes` hash are unimportant, they need merely be different for each address.

If the associated object is already saved, `fields_for` autogenerates a hidden input with the `id` of the saved record. You can disable this by passing `include_id: false` to `fields_for`. You may wish to do this if the autogenerated input is placed in a location where an input tag is not valid HTML or when using an ORM where children do not have an id.

### The Controller

As usual you need to
[whitelist the parameters](action_controller_overview.html#strong-parameters) in
the controller before you pass them to the model:

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

### Removing Objects

You can allow users to delete associated objects by passing `allow_destroy: true` to `accepts_nested_attributes_for`

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

If the hash of attributes for an object contains the key `_destroy` with a value of '1' or 'true' then the object will be destroyed. This form allows users to remove addresses:

```erb
<%= form_for @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= check_box :_destroy%>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Don't forget to update the whitelisted params in your controller to also include
the `_destroy` field:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Preventing Empty Records

It is often useful to ignore sets of fields that the user has not filled in. You can control this by passing a `:reject_if` proc to `accepts_nested_attributes_for`. This proc will be called with each hash of attributes submitted by the form. If the proc returns `false` then Active Record will not build an associated object for that hash. The example below only tries to build an address if the `kind` attribute is set.

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda {|attributes| attributes['kind'].blank?}
end
```

As a convenience you can instead pass the symbol `:all_blank` which will create a proc that will reject records where all the attributes are blank excluding any value for `_destroy`.

### Adding Fields on the Fly

Rather than rendering multiple sets of fields ahead of time you may wish to add them only when a user clicks on an 'Add new child' button. Rails does not provide any builtin support for this. When generating new sets of fields you must ensure the the key of the associated array is unique - the current javascript date (milliseconds after the epoch) is a common choice.
