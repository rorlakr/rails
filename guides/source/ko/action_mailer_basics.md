
Action Mailer 기초
====================

여기에서는 애플리케이션에서 메일을 주고 받기 위해서 필요한 모든 것들과 Action
Mailer에 대해 다양한 설명을 제공합니다. 또한 메일러를 테스트하기 위한 방법에
대해서도 설명합니다.

이 가이드의 내용:

* Rails 애플리케이션에서 메일을 주고 받는 방법
* Action Mailer 클래스와 메일러 뷰의 생성 및 편집 방법
* 환경에 맞게 Action Mailer를 설정하는 방법
* Action Mailer 클래스를 테스트하는 방법

--------------------------------------------------------------------------------

시작하면서
------------

Action Mailer를 사용하여 애플리케이션의 메일러 클래스나 뷰에서 메일을 전송할
수 있습니다. 메일러의 동작은 컨트롤러와 유사한 부분이 많습니다. 메일러는
`ActionMailer::Base`를 상속하고 `app/mailers`에 위치하며 `app/views`에 있는
뷰와 연결됩니다.

메일을 보내기
--------------

이 부분에서는 메일러와 뷰의 생성방법을 순서대로 살펴봅니다.

### 메일러를 생성에 필요한 작업들

#### 메일러 생성하기

```bash
$ bin/rails generate mailer UserMailer
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

이처럼 Rails의 다른 제너레이터와 마찬가지 방법으로 메일러를 생성할 수 있습니다. 메일러는 개념상 컨트롤러와 무척 유사하며, 메일러를 생성하면 (컨트롤러와 동일하게) 뷰를 위한 폴더와 테스트도 함께 생성됩니다.

제너레이터를 사용하고 싶지 않은 경우에는 app/mailers 폴더에 클래스 파일을 생성하고 `ActionMailer::Base`를 상속해주세요.

```ruby
class MyMailer < ActionMailer::Base
end
```

#### 메일러를 편집하기

메일러는 Rails의 컨트롤러와 공통되는 부분이 많습니다. 메일러에는 '액션'이라고 불리는 메소드가 있으며 메일의 내용을 구성할 때에는 뷰를 사용합니다. 컨트롤러에서 HTML 등의 메일을 생성하여 고객에게 전송하고 싶은 경우에는 그 장소에서 메일러를 사용하여 전송하고 싶은 메시지를 작성하면 됩니다.

`app/mailers/user_mailer.rb`에는 비어있는 메일러가 있습니다.

```ruby
class UserMailer < ApplicationMailer
end
```

`welcome_email` 이라는 이름의 메소드를 추가하고, 사용자가 등록한 이메일 주소에 메일을 전송하도록 해봅시다.

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
```

이 메소드의 코드에 대해서 간단하게 설명하겠습니다. 사용가능한 모든 옵션에 대해서는 'Action Mailer의 모든 메소드'에서 사용자가 변경 가능한 속성 목록을 참고해주세요.

* `default Hash` - 메일러에서 전송되는 모든 메일에서 사용될 기본값을 가지고 있는 해시입니다. 이 예제에서는 `:from` 헤더에 이 클래스에서 사용될 모든 메일에서 사용할 값을 하나 정의하고 있습니다. 이 값은 각 메일에서 재정의할 수도 있습니다.
* `mail` - 실제 메일 메시지 입니다. 여기에서는 `:to` 헤더와 `:subject` 헤더를 넘기고 있습니다.

컨트롤러와 마찬가지로 메일러의 메소드에서 정의된 모든 인스턴스 변수는 그대로 뷰에서 사용가능합니다.

#### 메일러 뷰를 생성하기

`app/views/user_mailer/` 폴더에서 `welcome_email.html.erb`라는 파일을 하나 생성해주세요. 이 파일을 HTML 형식의 메일 템플릿으로 사용합니다.

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1><%= @user.name %>님, example.com에 어서오세요.</h1>
      <p>
      example.com에 가입하셨습니다.
      당신의 username은 <%= @user.login %>입니다.<br>
    </p>
    <p>
      이 사이트에 로그인하기 위해서는 <%= @url %>을 클릭해주세요.
    </p>
    <p>가입해주셔서 감사합니다.</p>
  </body>
</html>
```

이어서 같은 내용을 텍스트 메일로도 생성해봅시다. 고객에 따라서는 HTML 형식의 메일을 원치 않는 사람도 있으므로, 텍스트 메일도 준비해두는 것이 좋습니다. 이를 위해서는 `app/views/user_mailer/` 폴더에서 `welcome_email.text.erb`라는 파일에 다음과 같은 내용을 추가해주세요.

```erb
<%= @user.name %>님, example.com에 어서오세요.
===============================================

example.com에 가입하셨습니다. 당신의 username은 <%= @user.login %>입니다.

이 사이트에 로그인하기 위해서는 <%= @url %>을 클릭해주세요.

가입해주셔서 감사합니다.
```

그리고 `mail` 메소드를 호출하면 Action Mailer에서는 2개의 템플릿(텍스트와 HTML)이 존재하는지 확인하고 `multipart/alternative` 형식의 메일을 자동으로 생성합니다.

#### 메일러 호출하기

Rails의 메일러는 뷰 랜더링과 본질적으로 동일한 작업을 수행합니다. 뷰의 랜더링에서는 HTTP 프로토콜로 전송됩니다만, 메일러에서는 메일의 프로토콜을 통해서 전송된다는 점이 다릅니다. 따라서, 가입에 성공하였을 때 메일을 전송하도록 컨트롤러로부터 메일러에게 지시하기만 하면 됩니다.

메일러의 호출은 무척 간단합니다.

우선, scaffold로 간단한 `User`를 생성해보죠.

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

사용자 모델을 생성했으므로 이어서 `app/controllers/users_controller.rb`를
편집하고, 새 사용자가 생성된 직후에 `UserMailer`의 `UserMailer.welcome_email`을
사용하여 그 사용자에게 메일이 전송되도록 합시다.

Action Mailer는 Active Job과 잘 결합되어 있으므로, Web의 요청/응답 흐름의
바깥에서 비동기로 메일을 전송합니다. 이 덕분에 사용자는 메일 전송이 끝나기를
기다릴 필요가 없습니다.

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # 저장 후에 UserMailer를 사용해서 환영 메일을 전송
        UserMailer.welcome_email(@user).deliver_later

        format.html { redirect_to(@user, notice: '사용자가 정상적으로 생성되었습니다.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

NOTE: Active Job은 기본으로 작업을 `:async` 어댑터로 실행합니다. 따라서 이
시점에서 `deliver_later`를 사용해서 메일을 전송할 수 있습니다. Active Job의
기본 어댑터는 프로세스 내의 스레드 풀을 사용하여 동작합니다. 이는 별도의
인프라를 요구하지 않으므로 개발/테스트 환경에는 잘 맞습니다만, 재시작할 때마다
쌓여있는 작업을 버리기 때문에 Production 환경에서는 그다지 적절하지 않습니다.
영속적인 백엔드가 필요하다면 Sidekiq이나 Resque 등의 백엔드 큐 시스템을
사용하도록 Active Job을 설정하면 됩니다.

메일을 cronjob 등에서 지금 바로 보내고 싶은 경우에는 `deliver_now`를
호출하면
됩니다.

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.weekly_summary(user).deliver_now
    end
  end
end
```

이 `welcome_email` 메소드는 `ActionMailer::MessageDelivery` 객체를 하나
반환합니다. 이 객체는 그 메일 자신이 전송 대상임을 `deliver_now`나
`deliver_later`에 알립니다. `ActionMailer::MessageDelivery` 객체는
`Mail::Message`를 감싸고 있습니다. 내부의 `Mail::Message` 객체를 꺼내거나
변경하고 싶은 경우에는 `ActionMailer::MessageDelivery` 객체의 `message`
메소드를 통해서 접근할 수 있습니다.

### 헤더의 값을 자동으로 인코딩하기

Action Mailer는 메일의 헤더나 본문의 멀티바이트 문자를 자동적으로 인코딩합니다.

다른 문자셋을 정의하고 싶을 때나, 사전에 직접 다른 인코딩 변환을 해두고 싶을
때에는 [Mail](https://github.com/mikel/mail) 라이브러리를 참조해주세요.

### Action Mailer의 모든 메소드

아래의 3개의 메소드를 사용하면 대부분의 메일 전송을 처리할 수 있습니다.

* `headers` - 메일에 추가하고 싶은 헤더를 지정합니다. 메일 헤더의 필드명과 값을 쌍으로 가지는 해시에 모아서 넘길 수도 있으며, `headers[:field_name] = 'value'`처럼 호출할 수도 있습니다.
* `attachments` - 메일에 파일을 첨부합니다. `attachments['file-name.jpg'] = File.read('file-name.jpg')`처럼 작성할 수 있습니다.
* `mail` - 메일을 전송합니다. 이 메소드에는 헤더의 해시를 파라미터로 넘길 수 있습니다. 메소드를 호출하면, 정의되어있는 메일 템플릿에 따라서 텍스트 메일 또는 Multipart 메일을 전송합니다.

#### 파일을 첨부하기

Action Mailer에서는 파일을 간단하게 첨부할 수 있습니다.

* 파일명과 내용물을 넘기면 Action Mailer와 [Mail gem](https://github.com/mikel/mail)이 자동적으로 mime_type을 추측하여 인코딩을 설정한 뒤, 파일을 첨부합니다.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  `mail` 메소드를 호출하면, Multipart 형식의 메일이 전송됩니다. 전송되는 메일은
Top level이 `multipart/mixed`이고, 첫번째 부분이 `multipart/alternative`라는
올바른 형식으로 중첩되어 있는 일반 텍스트 메일 또는 HTML 메일입니다.

NOTE: 메일에 첨부된 파일은 자동적으로 Base64로 인코딩됩니다. 다른 인코딩을
사용하고 싶은 경우에는 사전에 원하는 인코딩을 적용한 내용물을 `Hash`로 감싸서
`attachments`로 넘겨주세요.

* Action Mailer와 Mail는 헤더와 컨텐츠를 지정하여 파일명을 넘겨주면 그것들을
사용합니다.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTE: 인코딩의 종류를 지정하면 Mail은 내용물이 이미 인코딩 되었다고 생각하고
Base64로 인코딩을 시도하지 않습니다.

#### 파일을 인라인으로 첨부하기

Action Mailer 3.0부터 파일을 인라인으로 첨부할 수 있습니다. 이 기능은 3.0보다
이전에 이루어졌던 여러 트릭들을 바탕으로 최대한 이상적이고, 단순하게 구현한
것입니다.

* Mail에 인라인 첨부를 사용하도록 지시하려면 Mailer의 attachments 메소드에
`#inline`을 호출하기만 하면 됩니다.

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* 그러면 뷰에서 `attachments`를 해시로 참조하고, 참조할 파일을 지정할 수 있습니다. 이를 위해서 `attachments`에 대해서 `url`을 호출하고, 그 결과를 `image_tag` 메소드에 넘깁니다.

    ```html+erb
    <p>안녕하세요. 우리 사진입니다.</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* 이것은 `image_tag`에 대한 일반적인 동작이므로, 이미지 파일을 다루는 경우와 마찬가지로 첨부 URL 이외에도 옵션 해시를 하나 넘길 수 있습니다.

    ```html+erb
    <p>안녕하세요. 우리 사진입니다.</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### 메일을 여러명에게 전송하기

1개의 메일을 여러명에서 전송하는 것도 가능합니다(신규 가입자가 있다는 것을 모든 관리자에게 알리는 경우). 이를 위해서는 메일 목록을 `:to` 키를 사용합니다. 메일 리스트의 형식은 메일 주소의 베열이나, 메일 주소를 쉼표로 구분한 문자열을 사용할 수 있습니다.

```ruby
class AdminMailer < ActionMailer::Base
  default to: Proc.new { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```

CC (일반 사본)나 BCC (비공개 사본) 주소를 지정하는 경우에도 같은 방법을 사용할 수 있습니다. 각각 `:cc`와 `:bcc`를 키로 사용할 수 있습니다.

#### 메일 주소를 이름으로 표시하기

수신자의 메일 주소를 메일에서 그대로 표시하지 않고, 수진자의 이름을 보이게 하고 싶을 때도 있습니다. 이를 위해서는 메일 주소를 `"이름 <메일 주소>"` 형식으로 넘기면 됩니다.

```ruby
def welcome_email(user)
  @user = user
  email_with_name = %("#{@user.name}" <#{@user.email}>)
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
end
```

### 메일러의 뷰

메일러의 뷰는 `app/views/name_of_mailer_class` 폴더에 들어있습니다. 각각의 메일러 뷰는 그 이름이 메일러의 메소드와 동일하므로 클래스는 이 경로를 이해합니다. 위의 예시라면, `welcome_email` 메소드로 사용하는 메일러 뷰는 HTML 메일이라면 `app/views/user_mailer/welcome_email.html.erb`이 사용되며 일반 텍스트 메일이라면 `welcome_email.text.erb`이 사용됩니다.

액션에서 사용할 기본 메일러 뷰를 변경하려면 다음과 지정하면 됩니다.

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

이 코드에서는 `another`라는 이름의 템플릿을 `app/views/notifications` 폴더에서 검색합니다. `template_path`에는 경로의 베열을 넘길수도 있습니다. 이런 경우에는 배열에 들어있는 순서대로 검색하게 됩니다.

좀더 유연성있게 사용하려면 블럭을 하나 넘기고 특정 템플릿을 랜더링하거나, 템플릿을 사용하지 않고 인라인 또는 텍스트로 랜더링할 수도 있습니다.

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render text: 'Render text' }
    end
  end
end
```

이 코드는 HTML 형식을 'another_template.html.erb' 템플릿을 사용하여 랜더링하며, 텍스트일 경우에는 `:text`로 랜더링합니다. 랜더링 명령은 Action Controller에서 사용하고 있는 것과 동일하므로 `:text`, `:inline` 등의 옵션을 동일하게 사용할 수 있습니다.

#### 메일러 뷰 캐싱하기

애플리케이션 뷰처럼 메일러 뷰에서도 `cache` 메소드를 사용하며 캐싱을 할 수
있습니다.

```
<% cache do %>
  <%= @company.name %>
<% end %>
```

이 기능을 사용하기 위해서는 애플리케이션에 다음의 설정을 추가해주세요.

```
  config.action_mailer.perform_caching = true
```

### Action Mailer의 레이아웃

메일러도 컨트롤러의 뷰와 동일한 방법을 통해 레이아웃을 사용할 수 있습니다. 메일러에서 사용하는 레이아웃 이름은 메일러와 동일한 이름일 필요가 있습니다. 예를 들자면, `user_mailer.html.erb`나 `user_mailer.text.erb`라는 레이아웃은 메일러의 레이아웃으로 인식됩니다.

다른 레이아웃 팡리을 명시적으로 지정하고 싶은 경우에는 메일러에서 `layout`를 호출하면 됩니다.

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # awesome.(html|text).erb을 레이아웃으로 사용함
end
```

컨트롤러의 뷰와 마찬가지로 `yield`를 사용해서 레이아웃 내부의 뷰를 랜더링할 수 있습니다.

format 블럭에서 render 메소드를 호출할 때에 `layout: 'layout_name'` 옵션을 통해서 형식마나 다른 레이아웃을 지정할 수도 있습니다.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    mail(to: user.email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

이 코드는 HTML 형식일 경우 `my_layout.html.erb` 레이아웃 파일을 명시적으로 사용하여 랜더링하며, 텍스트 형식일 때에는 `user_mailer.text.erb`가 존재한다면 이 파일을 사용해서 레이아웃을 랜더링합니다.

### Action Mailer의 뷰에서 URL을 생성하기

메일러가 컨트롤러와 다른 점 중 하나는 메일러 인스턴스는 서버에 전달되는 HTTP 요청과는 완전히 무관계하다는 점입니다. 애플리케이션의 호스트 정보를 메일러 내부에서 사용하고 싶은 경우에는 `:host` 파라미터를 명시적으로 지정해야합니다.

`:host`에 지정할 값은 그 애플리케이션에서 공통일 경우가 많으므로 `config/application.rb`에 아래와 같이 추가하여 애플리케이션 전체에서 사용할 수 있도록 만듭니다.

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

`*_path` 헬퍼는 동작의 특징상, 메일에서는 사용할 수가 없다는 점을 주의해주세요. 메일에서 URL이 필요한 경우에는 `*_url` 헬퍼를 사용해주세요. 다음은 예시입니다.

```
<%= link_to '어서오세요', welcome_path %>
```

이 코드 대신에 아래의 코드를 사용해야합니다.

```
<%= link_to '어서오세요', welcome_url %>
```

이렇게 절대 경로의 URL을 사용하면, 메일의 URL을 정상적으로 동작시킬 수 있습니다.

#### `url_for`를 사용해서 URL 생성하기

템플릿에서 `url_for`를 사용해서 생성된 URL은 기본적으로 절대경로입니다.

`:host` 옵션을 전역에서 사용하고 있지 않은 경우에는 `url_for`에 `:host` 옵션을 명시적으로 넘길 필요가 있다는 점에 주의해주세요.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

#### 라우팅을 사용해서 URL 생성하기

메일 클라이언트는 웹서버의 환경과 분리되어 있으므로 메일에 들어가는 URL은 웹 주소의 도메인 URL 부분을 처리할 수 없습니다. 따라서, 라우팅 헬퍼에 대해서도 "*_path"가 아닌 "*_url"을 사용해야 합니다.

그러므로 `:host` 옵션을 전역으로 설정하지 않은 경우에는 "*_url" 헬퍼에 `:host` 옵션을 명시적으로 지정할 필요가 있습니다.

```erb
<%= user_url(@user, host: 'example.com') %>
```

### Multipart 메일 전송하기

어떤 액션에서 여러 개의 다른 템플릿이 있으면 Action Mailer에 의해서 자동으로 Multipart 형식의 메일이 전송됩니다. UserMailer를 예로 들겠습니다. `app/views/user_mailer` 폴더에 `welcome_email.text.erb`와 `welcome_email.html.erb`라는 템플릿이 있으면 Action Mailer는 각각의 템플릿으로부터 HTML 메일과 텍스트 메일을 생성하고, Multipart 형식의 메일로 하나로 합쳐서 전송합니다.

Multipart 메일에 포함되는 순서는 `ActionMailer::Base.default` 메소드의 `:parts_order`에 의해서 결정됩니다.

### 메일 전송시에 전송 옵션을 동적으로 결정하기

SMTP 인증 정보등의 기본 전송 옵션을 메일 전송시에 덮어쓰고 싶은 경우, 메일러의 액션에서 `delivery_method_options`을 사용해서 변경할 수 있습니다.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user, company)
    @user = user
    @url  = user_url(@user)
    delivery_options = { user_name: company.smtp_user,
                         password: company.smtp_password,
                         address: company.smtp_host }
    mail(to: @user.email,
         subject: "첨부된 이용 규약을 확인해주세요", 
         delivery_method_options: delivery_options)
  end
end
```

### 템플릿을 랜더링하지 않고 메일을 전송하기

메일 전송시에 템플릿 랜더링을 하지 않고 메일의 본문을 그냥 문자열로 보내고 싶을 경우가 있습니다. 이러한 경우에는 `:body` 옵션을 사용할 수 있습니다. 이 옵션을 사용할 경우에는 반드시 `:content_type` 옵션도 넘겨주세요. 그렇지 않은 경우에는 기본인 `text/plain`을 사용합니다.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user, email_body)
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "이미 랜더링했습니다!")
  end
end
```

메일을 수신하기
----------------

Action Mailer를 사용하는 메일의 수신과 읽어오는 작업(parsing)은 메일 전송에 비하면 복잡합니다. Rails 애플리케이션에서 메일을 받기 위해서는 그 전에 메일을 기다리고 있을 Rails 애플리케이션에게 어떤 형태로든 메일이 넘어가도록 처리해야합니다. 이를 위해서는 다음과 같은 작업이 필요합니다.

* 메일러에 `receive` 메소드를 구현하기

* `/(애플리케이션의 경로)/bin/rails runner 'UserMailer.receive(STDIN.read)'` 에서 메일 서버가 받은 메일을 애플리케이션으로 넘겨주기

일단 어떤 메일러에서 `receive` 메소드를 정의하면 수신한 메일은 Action Mailer에 의해서 처리되고, email 객체로 변환되어 디코딩된 이후, 새로운 메일러 인스턴스가 생성되고, 그 메일러의 `receive` 메소드에 넘겨집니다.

```ruby
class UserMailer < ApplicationMailer
  def receive(email)
    page = Page.find_by(address: email.to.first)
    page.emails.create(
      subject: email.subject,
      body: email.body
    )

    if email.has_attachments?
      email.attachments.each do |attachment|
        page.attachments.create({
          file: attachment,
          description: email.subject
        })
      end
    end
  end
end
```

Action Mailer의 콜백
---------------------------

Action Mailer에서는 `before_action`, `after_action` 또는 `around_action` 콜백을 사용할 수 있습니다.

* 컨트롤러와 마찬가지로, 메일러 클래스의 메소드에도 블럭이나 심볼을 통한 필터를 사용할 수 있습니다.

* `before_action` 콜백을 사용하여 mail 객체의 기본값이나 delivery_method_options을 주거나, 기본 헤더에 추가 정보를 삽입할 수도 있습니다.

* `after_action` 콜백도 `before_action` 비슷하게 사용할 수 있습니다만, 메일러 액션 내부의 인스턴스 변수를 대상으로 사용합니다.

```ruby
class UserMailer < ApplicationMailer
  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message(business, user)
    @business = business
    @user = user
    mail
  end

  def campaign_message(business, user)
    @business = business
    @user = user
  end

  private

    def set_delivery_options
      # 여기에서는 메일의 인스턴스나
      # @business나 @user 인스턴스 변수에 접근할 수 있음
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* 메일의 body에 nil 이외의 값이 설정되어 있는 경우 Mailer Filters의 처리가 중지됩니다.

Action Mailer 헬퍼를 사용하기
---------------------------

Action Mailer는 `AbstractController`를 상속하고 있으므로 Action Controller와 마찬가지로 헬퍼 메소드를 사용할 수 있습니다.

Action Mailer를 설정하기
---------------------------

다음의 설정 옵션은 environment.rb나 production.rb 등의 환경 설정 파일의 어딘가에서 사용하는 것이 좋습니다.

| 설정 | 설명 |
|---------------|-------------|
|`logger`|가능하다면 메일의 전송에 대한 정보를 생성합니다. `nil`을 설정하면 로그를 출력하지 않습니다. Ruby 자신의 `Logger` 로거나 `Log4r` 로거와 호환됩니다.|
|`smtp_settings`|`:smtp` 전송 메소드의 설정값입니다.<ul><li>`:address` - 원격 메일 서버의 사용을 허가합니다. 기본은 `"localhost"`이며, 필요에 따라서 변경하면 됩니다.</li><li>`:port` - 메일 서버가 25번 포트를 사용할 수 없는 경우 여기에서 사용할 포트를 변경할 수 있습니다.</li><li>`:domain` - HELO 도메인을 지정할 필요가 있는 경우에는 여기서 해주세요.</li><li>`:user_name` - 메일 서버에서 인증이 필요한 경우에는 여기서 사용자 이름을 지정해주세요.</li><li>`:password` - 메일 서버에서 인증이 필요한 경우에는 여기서 비밀번호를 지정해주세요.</li><li>`:authentication` - 메일서버에서 인증이 필요한 경우에는 여기서 인증의 종류를 지정해주세요. `:plain`, `:login`, `:cram_md5` 중에서 하나의 심볼을 지정하면 됩니다.</li><li>`:enable_starttls_auto` - SMTP 서버에서 STARTTLS가 활성화되어 있는지 확인하고, 필요하다면 사용합니다. 기본 값은 true입니다.</li><li>`:openssl_verify_mode` - 만약 TLS를 사용한다면 OpenSSL이 어떻게 인증서를 확인할지 설정할 수 있습니다. OpenSSL에 넘겨줄 값('none', 'peer', 'client_once', 'fail_if_no_peer_cert')을 직접 주거나 또는 상수(OpenSSL::SSL::VERIFY_NONE, OpenSSL::SSL::VERIFY_PEER, ...)를 사용해도 좋습니다.</li></ul>|
|`sendmail_settings`|`:sendmail`의 전송 옵션을 덮어씁니다.<ul><li>`:location` - sendmail를 실행할 수 있는 파일의 위치를 지정합니다. 기본값은 `/usr/sbin/sendmail`입니다.</li><li>`:arguments` - sendmail에 넘길 커맨드라인 인수를 지정합니다. 기본은 `-i -t`입니다.</li></ul>|
|`raise_delivery_errors`|메일 전송에 실패한 경우에 에러를 발생시킬지 아닐지를 설정합니다. 이 옵션은 외부의 메일 서버가 즉시 전송을 하는 경우에만 유효합니다.|
|`delivery_method`|전송 방법을 지정합니다. 다음중에서 하나를 지정할 수 있습니다.<ul><li>`:smtp` (기본값) -- `config.action_mailer.smtp_settings`에서 설정 가능</li><li>`:sendmail` -- `config.action_mailer.sendmail_settings`에서 설정 가능</li><li>`:file`: -- 메일을 파일로 저장. `config.action_mailer.file_settings`에서 설정 가능</li><li>`:test`: -- 메일을 `ActionMailer::Base.deliveries` 배열에 저장</li></ul>더 자세한 설명은 [API 문서](http://api.rubyonrails.org/classes/ActionMailer/Base.html)를 참조하세요.|
|`perform_deliveries`|Mail 메시지에 `deliver` 메소드를 호출했을 때에 실제로 메일을 전송할지 말지를 지정합니다. 기본적으로는 전송합니다만, 기능 테스트를 위해서 일시적으로 꺼야할 경우에 유용합니다.|
|`deliveries`|`delivery_method :test`를 사용해서 Action Mailer로부터 전송된 메일 배열을 저장합니다. 유닛 테스트나 기능테스트에서 유용합니다.|
|`default_options`|`mail` 메소드 옵션(`:from`, `:reply_to` 등)의 기본값을 설정합니다.|

가능한 모든 설정 옵션을 보기 위해서는 'Rails 애플리케이션을 설정하기'의
[Action Mailer를 설정하기](configuring.html#action-mailer를-설정하기)를
참조해주세요.

### Action Mailer의 설정 예시

적당한 `config/environments/$RAILS_ENV.rb` 파일에 추가할 설정의 예시입니다.

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-reply@example.com'}
```

### Gmail을 위한 Action Mailer 설정

Action Mailer에 [Mail gem](https://github.com/mikel/mail)이 도입되었으므로
`config/environments/$RAILS_ENV.rb` 파일에 아래와 같이 무척 간단해진 설정을
추가해주세요.

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            '<사용자 이름>',
  password:             '<비밀번호>',
  authentication:       'plain',
  enable_starttls_auto: true  }
```

메일러 테스트
--------------

메일러의 테스트 방법은 테스트 가이드의
[메일러 테스트하기](testing.html#메일러-테스트하기)를 참조해주세요.

메일을 전송 직전에 변경하기
-------------------

메일을 전송하기 전에 약간의 수정을 하고 싶은 경우가 있습니다. 다행히 Action
Mailer는 모든 메일을 전송하기 전에 추가작업을 하기 위한 방법을 제공합니다.
이것을 사용하여 메일이 최종적으로 전송 에이전트에게 넘기기 직전에 메일의 내용을
수정하기 위한 코드를 등록할 수 있습니다.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

인터셉터가 동작하기 위해서는 Action Mailer 프레임워크에 등록할 필요가 있습니다.
이 코드는 다음과 같이 initializer의
`config/initializers/sandbox_email_interceptor.rb` 파일에서 처리할 수 있습니다.

```ruby
ActionMailer::Base.register_interceptor(SandboxEmailInterceptor) if Rails.env.staging?
```

NOTE: 이 예제에서는 "staging"라는 환경을 사용하고 있습니다. 이것은 실제
환경(production환경)과 같은 상태에서 테스트를 하기 위한 환경입니다. Rails의
커스텀 환경에 대해서는
[Rails 환경을 생성하기](configuring.html#rails-환경을-생성하기)를 참조해주세요.
