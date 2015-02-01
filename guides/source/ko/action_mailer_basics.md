[Action Mailer Basics] 액션메일러 기본
====================

이 가이드에서는 어플리케이션으로부터 이메일을 보내고 받는 것에 대한 것과 액션메일러 내부에 대한 내용을 제공해 줍니다. 또한 메일러를 테스트하는 방법에 대해서도 다루게 됩니다. [[[This guide provides you with all you need to get started in sending and receiving emails from and to your application, and many internals of Action Mailer. It also covers how to test your mailers.]]]

이 가이드를 읽은 후에는 아래와 같은 사항을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* 레일스 어플리케이션내에서 이메일을 보내고 받는 방법 [[[How to send and receive email within a Rails application.]]]

* 액션메일러 클래스와 메일러 뷰를 생성하고 수정하는 방법 [[[How to generate and edit an Action Mailer class and mailer view.]]]

* 개발환경에 맞도록 액션메일러를 설정하는 방법 [[[How to configure Action Mailer for your environment.]]]

* 액션메일러 클래서를 테스트하는 방법 [[[How to test your Action Mailer classes.]]]

--------------------------------------------------------------------------------

[Introduction] 개요
------------

액션메일러를 이용하면, 메일러 클래스와 뷰를 사용하여 어플리케이션으로부터 이메일을 발송할 수 있습니다. 메일러는 컨트롤러와 매우 흡사하게 동작을 합니다. 메일러는 `ActionMailer::Base`로부터 상속을 받아 `app/mailers` 디렉토리에 위치하게 되며 `app/views` 디렉토리에 있는 뷰 파일들과 연결됩니다. [[[Action Mailer allows you to send emails from your application using mailer classes and views. Mailers work very similarly to controllers. They inherit from `ActionMailer::Base` and live in `app/mailers`, and they have associated views that appear in `app/views`.]]]

[Sending Emails] 이메일 발송하기
--------------

여기에서는 메일러와 뷰를 생성하는 방법을 단계별로 소개할 것입니다. [[[This section will provide a step-by-step guide to creating a mailer and its views.]]]

### [Walkthrough to Generating a Mailer] 메일러 생성방법

#### [Create the Mailer] 메일러 생성

```bash
$ rails generate mailer UserMailer
create  app/mailers/user_mailer.rb
invoke  erb
create    app/views/user_mailer
invoke  test_unit
create    test/mailers/user_mailer_test.rb
```

보다시피, 일반적인 제너레이터를 사용할 때와 같이 메일러를 생성할 수 있습니다. 메일러는 개념적으로 컨트롤러와 비슷하기 때문에, 하나의 메일러와 이와 연결되는 뷰 디렉토리와 테스트 셋를 가지게 됩니다. [[[As you can see, you can generate mailers just like you use other generators with
Rails. Mailers are conceptually similar to controllers, and so we get a mailer,
a directory for views, and a test.]]]

제너레이터를 사용하지 않을 경우에는, app/mailers 디렉토리내에 직접 파일을 생성할 수 있으며, 이 때 메일러가 `ActionMailer::Base`로부터 상속 받도록 하면 됩니다. [[[If you didn't want to use a generator, you could create your own file inside of app/mailers, just make sure that it inherits from `ActionMailer::Base`:]]]

```ruby
class MyMailer < ActionMailer::Base
end
```

#### [Edit the Mailer] 메일러 수정하기

메일러는 컨트롤러와 매우 흡사합니다. 따라서 "액션"이고 부르는 메소드를 가지게 됩니다. 컨트롤러가 클라이언트로 보내게 되는 컨테츠를 생성하는 곳에, 메일러는 이메일로 발송하게 될 메시지를 생성하게 되는 것입니다. [[[Mailers are very similar to Rails controllers. They also have methods called "actions" and use views to structure the content. Where a controller generates content like HTML to send back to the client, a Mailer creates a message to be delivered via email.]]]

`app/mailers/user_mailer.rb` 파일에는 내용이 없는 메일러 클래스가 있습니다. [[[`app/mailers/user_mailer.rb` contains an empty mailer:]]]

```ruby
class UserMailer < ActionMailer::Base
  default from: 'from@example.com'
end
```

`welcome_email`이라는 메소드를 정의해 보겠습니다. 이것은 유저가 등록한 이메일 주소로 이메일을 발송하게 될 것입니다. [[[Let's add a method called `welcome_email`, that will send an email to the user's registered email address:]]]

```ruby
class UserMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
```

위의 메소드에 보여지는 항목들에 대해서 간단하게 설명을 해 보겠습니다. 사용할 수 있는 모든 옵션에 대한 전체 목록을 보기 위해서는 아래의 액션메일러 사용자 설정 속성 목록을 참고하기 바랍니다. [[[Here is a quick explanation of the items presented in the preceding method. For a full list of all available options, please have a look further down at the Complete List of Action Mailer user-settable attributes section.]]]

* `default 해시` - 이 옵션은 이 메일러로부터 발송하게 되는 이메일에 대한 디폴트 값들에 대한 해시를 지정합니다. 이 경우에는 이 클래스에서 발송하게 되는 모든 메시지에 대한 `:from` 헤더를 특정 값으로 지정하게 될 것입니다. 이 값은 이메일 각각에 대해서 변경할 수도 있습니다. [[[`default Hash` - This is a hash of default values for any email you send from this mailer. In this case we are setting the `:from` header to a value for all messages in this class. This can be overridden on a per-email basis.]]]

* `mail` - 실제로 보내지게 되는 이메일 메시지이며 `:to`와 `:subject` 헤더를 넘겨주게 됩니다. [[[`mail` - The actual email message, we are passing the `:to` and `:subject` headers in.]]]

컨트롤러와 같이 이 메소드에서 정의하게 되는 모든 인스턴스 변수는 메일러 뷰 파일에서도 사용할 수 있게 됩니다. [[[Just like controllers, any instance variables we define in the method become available for use in the views.]]]

#### [Create a Mailer View] 메일러 뷰 생성하기

`app/views/user_mailer/` 디렉토리에 `welcome_email.html.erb`라는 파일을 생성합니다. 이 파일은 이메일에 사용될 HTML 포맷의 템플릿이 될 것입니다. [[[Create a file called `welcome_email.html.erb` in `app/views/user_mailer/`. This will be the template used for the email, formatted in HTML:]]]

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Welcome to example.com, <%= @user.name %></h1>
    <p>
      You have successfully signed up to example.com,
      your username is: <%= @user.login %>.<br/>
    </p>
    <p>
      To login to the site, just follow this link: <%= @url %>.
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```

이 이메일에 대한 텍스트 버전도 만들어 보겠습니다. 모든 클라이언트가 HTML포맷의 이메일을 원치 않을 것이기 때문에 두개의 포맷을 발송하는 것이 최선의 방법입니다. 이를 위해서는 `app/views/user_mailer/` 디렉토리에 `welcome_email.text.erb`이라는 파일을 생성합니다. [[[Let's also make a text part for this email. Not all clients prefer HTML emails, and so sending both is best practice. To do this, create a file called `welcome_email.text.erb` in `app/views/user_mailer/`:]]]

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```

이제 `mail` 메소드를 호출하게 되면, 액션메일러가 텍스트와 HTML 포맷의 두가지 템블릿을 인식하고 자동으로 `multipart/alternative` 이메일을 생성하게 될 것입니다. [[[When you call the `mail` method now, Action Mailer will detect the two templates (text and HTML) and automatically generate a `multipart/alternative` email.]]]

#### [Calling the Mailer] 메일러 호출하기 

메일러는 뷰를 렌더링하는 또 다른 방법에 불과합니다. 뷰를 렌더링하여 HTTP 프로토콜로 발송하는 대신에, 이메일 프로토콜로 발송할 뿐입니다. 따라서, 유저가 생성될 때 이메일을 발송하도록 컨트롤러가 메일러에게 알려주도록 하는 것은 자연스러운 것입니다. [[[Mailers are really just another way to render a view. Instead of rendering a view and sending out the HTTP protocol, they are just sending it out through the Email protocols instead. Due to this, it makes sense to just have your
controller tell the Mailer to send an email when a user is successfully created.]]]

이를 위한 설정 매우 간단합니다. [[[Setting this up is painfully simple.]]]

우선, 간단한 `User` scaffold를 생성합니다. [[[First, let's create a simple `User` scaffold:]]]

```bash
$ rails generate scaffold user name email login
$ rake db:migrate
```

이제 작업할 user 모델이 준비되었으므로, `app/controllers/users_controller.rb` 파일내의 create 액션이, 유저 정보가 성공적으로 저장된 직후에, `UserMailer.welcome_email`을 호출하도록 수정하여, 새로운 유저가 생성될 때 UserMailer가 이메일을 발송하도록 할 것입니다. [[[Now that we have a user model to play with, we will just edit the `app/controllers/users_controller.rb` make it instruct the UserMailer to deliver an email to the newly created user by editing the create action and inserting a call to `UserMailer.welcome_email` right after the user is successfully saved:]]]

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # Tell the UserMailer to send a welcome Email after save
        UserMailer.welcome_email(@user).deliver

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

`welcome_email` 메소드는 `Mailer::Message` 객체를 반환하게 되고, 이 객체는 자신을 발송하기 위해 `deliver` 메소드를 호출하게 됩니다. [[[The method `welcome_email` returns a `Mail::Message` object which can then just be told `deliver` to send itself out.]]]

### [Auto encoding header values] 자동 인코딩 헤더 값

액션메일러는 header와 body에 포함되어 있는 multibyte 문자들을 자동으로 인코딩합니다. [[[Action Mailer handles the auto encoding of multibyte characters inside of headers and bodies.]]]

대체 문자셋을 정의하거나 자체 인코딩 텍스트 우선과 같은 복잡한 경우에 대해서는 [Mail](https://github.com/mikel/mail) 라이브러리를 참고하기 바랍니다. [[[For more complex examples such as defining alternate character sets or self-encoding text first, please refer to the [Mail](https://github.com/mikel/mail) library.]]]

### [Complete List of Action Mailer Methods] 액션메일러 메소드 전체목록

이메일 메시지를 발송하기 위해서는 단 3가지 메소드만 있으면 됩니다. [[[There are just three methods that you need to send pretty much any email message:]]]

* `headers` - 이메일상에 원하는 헤더를 명시합니다. 헤더 필드명과 값 조합을 해시형태로 넘기거나 `headers[:field_name] = 'value'` 와 같이 호출할 수 있습니다. [[[`headers` - Specifies any header on the email you want. You can pass a hash of header field names and value pairs, or you can call `headers[:field_name] = 'value'`.]]]

* `attachments` - 이메일에 첨부파일을 추가할 수 있도록 해 줍니다. 예를 들어, `attachments['file-name.jpg'] = File.read('file-name.jpg')`와 같이 할 수 있습니다. [[[`attachments` - Allows you to add attachments to your email. For example, `attachments['file-name.jpg'] = File.read('file-name.jpg')`.]]]
  
* `mail` - 실제로 메일 자체를 발송합니다. 메일 메소드에 대한 해시를 헤더에 파라미터로 넘겨주면, mail 메소드는 작성해 놓은 이메일 템플릿에 따라 텍스트 또는 multipart 이메일을 생성하게 될 것입니다. [[[`mail` - Sends the actual email itself. You can pass in headers as a hash to the mail method as a parameter, mail will then create an email, either plain text, or multipart, depending on what email templates you have defined.]]]

#### [Adding Attachments] 파일 첨부하기

액션메일러는 매우 손쉽게 파일첨부를 할 수 있게 해 줍니다. [[[Action Mailer makes it very easy to add attachments.]]]

* 파일명과 내용을 넘겨주면 액션메일러와 [Mail gem](https://github.com/mikel/mail)이 자동으로 mime_type을 결정하고 인코딩을 설정한 후에 첨부할 파일을 생성하게 됩니다. [[[Pass the file name and content and Action Mailer and the [Mail gem](https://github.com/mikel/mail) will automatically guess the mime_type, set the encoding and create the attachment.]]]

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  `mail` 메소드가 호출되면 파일이 첨부된 multipart 이메일을 발송하게 됩니다. 이 때 이메일은 top level이 `multipart/mixed`로, first part는 `multipart/alternative`로 텍스트와 HTML 이메일 메시지를 포함하게 됩니다. [[[When the `mail` method will be triggered, it will send a multipart email with an attachment, properly nested with the top level being `multipart/mixed` and the first part being a `multipart/alternative` containing the plain text and HTML email messages.]]]

NOTE: 메일은 자동으로 첨부파일을 Base64로 인코딩할 것입니다. 다른 것으로 인코딩을 하고자한 한다면, 먼저 메일 컨텐츠를 인코딩한 후 인코딩된 컨텐츠와 인코딩을 `attachments` 메소드로 해시 형태로 넘겨 주면 됩니다. [[[Mail will automatically Base64 encode an attachment. If you want something different, encode your content and pass in the encoded content and encoding in a `Hash` to the `attachments` method.]]]

* 파일명을 넘겨주고 헤더값과 내용을 지정해 주면 액션메일러와 메일은 넘겨 받은 설정값을 사용할 것입니다. [[[Pass the file name and specify headers and content and Action Mailer and Mail will use the settings you pass in.]]]

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {mime_type: 'application/x-gzip',
                                   encoding: 'SpecialEncoding',
                                   content: encoded_content }
    ```

NOTE: 인코딩을 지정해 줄 경우, 메일은 메일내용이 이미 인코딩된 것으로 가정하고 Base64 인코딩을 시도하기 않게 됩니다. [[[If you specify an encoding, Mail will assume that your content is already encoded and not try to Base64 encode it.]]]

#### [Making Inline Attachments] 인라인 파일첨부하기

액션메일러 3.0에서는 인라인 파일첨부를 훨씬 간단하게 할 수 있습니다. 이것은 3.0 이전버전에서 해킹이 많았던 것과 관련이 있었습니다. [[[Action Mailer 3.0 makes inline attachments, which involved a lot of hacking in pre 3.0 versions, much simpler and trivial as they should be.]]]

* 먼저, 메일에게 첨부파일을 인라인 방식으로 변경하라고 알려주어야 하는데, 메일러내에서 attachements 메소드에 `#inline`을 호출하면 됩니다. [[[First, to tell Mail to turn an attachment into an inline attachment, you just call `#inline` on the attachments method within your Mailer:]]]

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* 그리고나서 뷰에서는, 해시형태로 `attachments`를 참조하는데, 이때 보여줄 첨부파일명을 명시한 후에 `url` 메소드를 호출하여 `image_tag` 메소드로 결과를 넘겨주면 됩니다. [[[Then in your view, you can just reference `attachments` as a hash and specify which attachment you want to show, calling `url` on it and then passing the result into the `image_tag` method:]]]

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* 이것은 `image_tag` 메소드에 대한 일반적인 호출방법이기 때문에 첨부파일 URL 이후에 옵션을 해시형태로 추가할 수 있습니다. [[[As this is a standard call to `image_tag` you can pass in an options hash after the attachment URL as you could for any other image:]]]

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo',
                                                class: 'photos' %>
    ```

#### [Sending Email To Multiple Recipients] 여러사람에게 이메일 발송하기

`:to` 키에 이메일 목록을 지정해 주면 (예를 들어, 새로운 사용자 등록이 모든 관리자에게 알려 줄 경우) 하나의 이메일로 한사람 이상의 수신자에게 메일을 발송할 수 있게 됩니다. 이메일 목록은 이메일 주소들에 대한 배열형태나 콤마로 구분되는 여러개의 이메일로 구성된 하나의 문자열 형태를 가질 수 있습니다. [[[It is possible to send email to one or more recipients in one email (e.g., informing all admins of a new signup) by setting the list of emails to the `:to` key. The list of emails can be an array of email addresses or a single string with the addresses separated by commas.]]]

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

동일한 포맷을 이용하여 carbon copy(Cc:)와 blind carbon copy(Bcc:) 수신자를 지정할 수 있으며, 이 때 `:cc`와 `:bcc` 키를 각각 사용합니다. [[[The same format can be used to set carbon copy (Cc:) and blind carbon copy (Bcc:) recipients, by using the `:cc` and `:bcc` keys respectively.]]]

#### [Sending Email With Name] 이메일을 수신자명과 함께 발송하기 

때때로 수신자들이 이메일을 받을 때 이메일 주소대신에 각자의 이름이 보여지도록 하고 싶은 경우가 있습니다. 이를 위해서, `"Full Name <email>"`와 같은 형태로 이메일 주소의 포맷을 지정해 주면 됩니다. [[[Sometimes you wish to show the name of the person instead of just their email address when they receive the email. The trick to doing that is to format the email address in the format `"Full Name <email>"`.]]]

```ruby
def welcome_email(user)
  @user = user
  email_with_name = "#{@user.name} <#{@user.email}>"
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
end
```

### [Mailer Views] 메일러 뷰

메일러 뷰 파일들은 `app/views/name_of_mailer_class` 디렉토리에 위치합니다. 특정 메일러 뷰는 메일러 메소드와 동일한 이름을 가지기 때문에 해당 메일러 클래스에서 알고 있습니다. 위의 예제에서, `welcome_mail` 메소드에 대한 메일러 뷰는, HTML 버전에 대해서는 `app/views/user_mailer/welcome_email.html.erb`, 텍스트 버전에 대해서는 `welcome_email.text.erb` 파일에 위치하게 됩니다. [[[Mailer views are located in the `app/views/name_of_mailer_class` directory. The specific mailer view is known to the class because its name is the same as the mailer method. In our example from above, our mailer view for the `welcome_email` method will be in `app/views/user_mailer/welcome_email.html.erb` for the HTML version and `welcome_email.text.erb` for the plain text version.]]]

메일러 액션에 대한 디폴트 뷰를 다른 것으로 변경하고자 한다면, 다음과 같이 할 수 있습니다. [[[To change the default mailer view for your action you do something like:]]]

```ruby
class UserMailer < ActionMailer::Base
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

이 경우에는 `another`라는 이름을 가지는 템플릿 파일을 `app/views/notifications` 디렉토리에서 찾게 될 것입니다. 또한 `template_path` 옵션에 경로들을 배열로 지정할 수 있으며 배열의 순서대로 경로를 검색하게 될 것입니다. [[[In this case it will look for templates at `app/views/notifications` with name `another`.  You can also specify an array of paths for `template_path`, and they will be searched in order.]]]

더 많은 유연성을 가지기 위해서, 하나의 블럭을 넘겨서 특정 템플릿 파일을 렌더링하거나 템플릿 파일을 사용하지 않고 인라인 또는 텍스트를 직접 렌더링하도록 할 수 있습니다. [[[If you want more flexibility you can also pass a block and render specific templates or even render inline or text without using a template file:]]]

```ruby
class UserMailer < ActionMailer::Base
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

위의 코드는 HTML 파트로 'another_template.html.erb' 템플릿을, 텍스트 파트로 텍스트를 렌더링하도록 할 것입니다. render 명령은 액션컨트롤러에서 사용하는 결과 동일한 것이어서 `:text`, `:inline` 등과 같은 모든 옵션을 동일하게 사용할 수 있습니다. [[[This will render the template 'another_template.html.erb' for the HTML part and use the rendered text for the text part. The render command is the same one used inside of Action Controller, so you can use all the same options, such as `:text`, `:inline` etc.]]]

### [Action Mailer Layouts] 액션 메일러 레이아웃

컨트롤러의 뷰와 같이 메일러 레이아웃을 사용할 수 있습니다. 레이아웃의 이름은 메일러와 동일해야 합니다. 예를 들어, `user_mail.html.erb`, `user_mail.text.erb` 파일은 해당 메일러에서 자동으로 레이아웃 파일로 인식하게 됩니다. [[[Just like controller views, you can also have mailer layouts. The layout name needs to be the same as your mailer, such as `user_mailer.html.erb` and `user_mailer.text.erb` to be automatically recognized by your mailer as a layout.]]]

다른 파일을 사용하기 위해서는, 메일러에서 `layout`을 호출하면 됩니다. [[[In order to use a different file, call `layout` in your mailer:]]]

```ruby
class UserMailer < ActionMailer::Base
  layout 'awesome' # use awesome.(html|text).erb as the layout
end
```

컨트롤러 뷰와 같이, 레이아웃내에 뷰를 렌더링하기 위해서 `yield`를 사용하면 됩니다. [[[Just like with controller views, use `yield` to render the view inside the layout.]]]

포맷 블록내에서 `layout: 'layout_name'` 옵션을 지정해서 render를 호출하면 각각 다른 포맷에 대한 별도의 레이아웃을 지정할 수 있게 됩니다. [[[You can also pass in a `layout: 'layout_name'` option to the render call inside the format block to specify different layouts for different formats:]]]

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    mail(to: user.email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

위의 코드는 HTML 파트에 대해서 `my_layout.html.erb` 파일을, 존재한다면 텍스트 파트에 대해서는 `user_mailer.text.erb` 파일을 이용해서 렌더링하게 될 것입니다. [[[Will render the HTML part using the `my_layout.html.erb` file and the text part with the usual `user_mailer.text.erb` file if it exists.]]]

### [Generating URLs in Action Mailer Views] 액션메일러 뷰에서 URL을 생성하기

일반적인 컨트롤러와는 다르게 메일러 인스턴스는 외부로부터 들어노는 요청에 대한 정보를 가지고 있지 않습니다. 따라서 직접 `:host` 파라미터를 제공해 줄 필요가 있습니다. [[[Unlike controllers, the mailer instance doesn't have any context about the incoming request so you'll need to provide the `:host` parameter yourself.]]]

`:host`는 대개 어플리케이션 전체에 대해서 동일하기 때문에, `config/application.rb` 파일에서 그 값을 전역값으로 설정해 줄 수 있습니다. [[[As the `:host` usually is consistent across the application you can configure it globally in `config/application.rb`:]]]

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

#### [generating URLs with `url_for`] `url_for`를 이용하여 URL 생성하기


`url_for` 메소드를 사용할 때는 `only_path` 옵션을 `false` 값으로 지정해 줄 필요가 있습니다. 왜냐하면 `url_for` 헬퍼 메소드는 디폴트로 `:host` 옵션이 명시적으로 지정되지 않으면 상대경로의 URL을 생성하기 때문입니다. [[[You need to pass the `only_path: false` option when using `url_for`. This will ensure that absolute URLs are generated because the `url_for` view helper will, by default, generate relative URLs when a `:host` option isn't explicitly provided.]]]

```erb
<%= url_for(controller: 'welcome',
            action: 'greeting',
            only_path: false) %>
```

전역값으로 `:host` 옵션을 설정하지 않은 경우에는 `url_for` 메소드에 이 옵션을 넘겨 주어야 합니다. [[[If you did not configure the `:host` option globally make sure to pass it to
`url_for`.]]]


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

NOTE: `:host` 옵션을 명시적으로 넘겨주게 되면 레일스는 항상 절대경로의 URL을 생성하기 때문에, `only_path: false` 옵션을 지정해 줄 필요가 없게 됩니다. [[[When you explicitly pass the `:host` Rails will always generate absolute URLs, so there is no need to pass `only_path: false`.]]]

#### [generating URLs with named routes] named 라우팅을 이용하여 URL 생성하기

이메일 클라이언트는 웹환경을 가지고 있지 않기 때문에 완전한 웹주소를 가지기 위한 base URL을 가지고 있지 않습니다. 따라서, named 라우팅 헬퍼인 "_url" 메소드를 항상 사용해야 합니다. [[[Email clients have no web context and so paths have no base URL to form complete web addresses. Thus, you should always use the "_url" variant of named route helpers.]]]

전역값으로 `:host` 옵션을 설정하기 않은 경우에는 url 헬퍼에 명시적으로 해당 옵션을 넘겨 주어야 합니다. [[[If you did not configure the `:host` option globally make sure to pass it to the url helper.]]]

```erb
<%= user_url(@user, host: 'example.com') %>
```

### [Sending Multipart Emails] Multipart 이메일 발송하기

액션 메일러는 동일한 액션에 대해서 다른 템플릿 파일을 가지고 있는 경우 multipart 이메일을 자동으로 발송해 줍니다. 따라서, UserMailer 예의 경우, `app/views/user_mailer` 디렉토리에 `welcome_email.text.erb`와 `welcome_email.html.erb` 파일이 있을 경우, 액션 메일러는 각기 다른 파트별로 자동으로 HTML과 텍스트 버전을 이용하여 multipart 이메일을 발송하게 될 것입니다. [[[Action Mailer will automatically send multipart emails if you have different
templates for the same action. So, for our UserMailer example, if you have
`welcome_email.text.erb` and `welcome_email.html.erb` in `app/views/user_mailer`, Action Mailer will automatically send a multipart email with the HTML and text versions setup as different parts.]]]

삽입되는 파트별 순서는 `ActionMailer::Base.default` 메소드내의 `:parts_order`에 의해 결정됩니다. [[[The order of the parts getting inserted is determined by the `:parts_order` inside of the `ActionMailer::Base.default` method.]]]

### [Sending Emails with Dynamic Delivery Options] 발송 옵션을 이용하여 이메일 발송하기

이메일을 발송할 때, SMTP credentails과 같은 디폴트 발송 옵션을 변경하고자 한다면 메일러 액션에서 `delivery_method_options` 을 지정하면 됩니다. [[[If you wish to override the default delivery options (e.g. SMTP credentials) while delivering emails, you can do this using `delivery_method_options` in the mailer action.]]]

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user, company)
    @user = user
    @url  = user_url(@user)
    delivery_options = { user_name: company.smtp_user,
                         password: company.smtp_password,
                         address: company.smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### [Sending Emails without Template Rendering] 템플릿을 렌더링하지 않고 이메일 발송하기

때로는 템플릿 렌더링 단계를 거치지 않고 이메일 body를 문자열로 대신하고자 할 경우가 있습니다. 이런 경우에는 `:body` 옵션을 사용하면 됩니다. 이 때는 `:content_type` 옵션을 추가할 것을 잊어서는 안 됩니다. 그렇지 않을 경우 레일스는 디플트로 `text/plain`으로 지정하게 될 것입니다. [[[There may be cases in which you want to skip the template rendering step and supply the email body as a string. You can achieve this using the `:body` option. In such cases don't forget to add the `:content_type` option. Rails will default to `text/plain` otherwise.]]]

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user, email_body)
    mail(to: user.email,
         body: email_body,
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

[Receiving Emails] 이메일 수신하기
----------------

액션 메일러 이메일을 수신하여 파싱하는 것은 다소 복잡한 과정이 필요합니다. 이메일이 레일스 어플리케이션에 도달하기 전에, 이메일을 어플리케이션으로 전달할 수 있도록 시스템에 미리 설정을 해 주어야 하는데, 이를 위해서 이메일이 도착하는지를 항상 모니터링해야 할 필요가 있습니다. 따라서 레일스 어플리케이션에서 이메일을 수신하기 위해서는 다음과 같은 조치를 취할 필요가 있습니다. [[[Receiving and parsing emails with Action Mailer can be a rather complex endeavor. Before your email reaches your Rails app, you would have had to configure your system to somehow forward emails to your app, which needs to be listening for that. So, to receive emails in your Rails app you'll need to:]]]

* 메일러에 `receive` 메소드를 작성해야 합니다. [[[Implement a `receive` method in your mailer.]]]

* 이메일 서버의 설정을 변경해서 어플리케이션에서 이메일을 수신하고자 하는 주소로부터 이메일을 `/path/to/app/bin/rails runner 'UserMailer.receive(STDIN.read)'`로 전달하도록 해야 합니다. [[[Configure your email server to forward emails from the address(es) you would like your app to receive to `/path/to/app/bin/rails runner 'UserMailer.receive(STDIN.read)'`.]]]

메일러에 `receive` 메소드가 이미 정의되어 있다면, 액션 메일러는 수신된 이메일을 파싱해서 이메일 객체로 만들게 되고 이를 디코딩해서 새로운 메일러를 만들어 줍니다. 그리고나서 이메일 객체를 이 메일러의 `receive` 인스턴스 메소드로 넘겨 주게됩니다. 아래에 예제가 있습니다. [[[Once a method called `receive` is defined in any mailer, Action Mailer will parse the raw incoming email into an email object, decode it, instantiate a new mailer, and pass the email object to the mailer `receive` instance method. Here's an example:]]]

```ruby
class UserMailer < ActionMailer::Base
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

[Action Mailer Callbacks] 액션 메일러 콜백
---------------------------

액션 메일러는 `before_action`, `after_action`, `around_action` 필터를 지정할 수 있게 해 줍니다. [[[Action Mailer allows for you to specify a `before_action`, `after_action` and `around_action`.]]]

* 이러한 필터들은 블록형태나 컨트롤러와 같이 메일러 클래스의 특정 메소드에 대한 심볼 형태로 지정할 수 있습니다. [[[Filters can be specified with a block or a symbol to a method in the mailer class similar to controllers.]]]

* `before_action` 필터를 이용해서, 이메일 객체에 디폴트 값을 전달할 수 있고, delivery_method_options을 지정하며, 디폴트 헤더와 첨부파일을 삽입해 줄 수 있습니다. [[[You could use a `before_action` to populate the mail object with defaults, delivery_method_options or insert default headers and attachments.]]]

* `after_action` 필터를 이용해서 `before_action`과 같이 비슷한 설정을 할 수 있지만, 이 때는 메일러 액션에 인스턴스 변수들을 이용해야 합니다. [[[You could use an `after_action` to do similar setup as a `before_action` but using instance variables set in your mailer action.]]]

```ruby
class UserMailer < ActionMailer::Base
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
      # You have access to the mail instance,
      # @business and @user instance variables here
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

* 메일러 필터들은 이메일 body가 nil이 아닌 값으로 설정되면 더 이상 과정을 처리하지 못하게 합니다. [[[Mailer Filters abort further processing if body is set to a non-nil value.]]]

[Using Action Mailer Helpers] 액션 메일러 헬퍼 메소드 이용하기 
---------------------------

액션 메일러는 이제 `AbstractController` 클래스로부터 상속을 받습니다. 따라서 액션 컨트롤러에서와 같은 일반적인 헬퍼 메소드를 사용할 수 있습니다. [[[Action Mailer now just inherits from `AbstractController`, so you have access to the same generic helpers as you do in Action Controller.]]]

[Action Mailer Configuration] 액션 메일러 설정
---------------------------

아래의 설정 옵션들은 environment.rb, production.rb 등과 같은 환경 파일 중의 하나에서 최상으로 구성된 것들입니다. [[[The following configuration options are best made in one of the environment files (environment.rb, production.rb, etc...)]]]

| Configuration | Description |
|---------------|-------------|
|`logger`|Generates information on the mailing run if available. Can be set to `nil` for no logging. Compatible with both Ruby's own `Logger` and `Log4r` loggers.|
|`smtp_settings`|Allows detailed configuration for `:smtp` delivery method:<ul><li>`:address` - Allows you to use a remote mail server. Just change it from its default "localhost" setting.</li><li>`:port` - On the off chance that your mail server doesn't run on port 25, you can change it.</li><li>`:domain` - If you need to specify a HELO domain, you can do it here.</li><li>`:user_name` - If your mail server requires authentication, set the username in this setting.</li><li>`:password` - If your mail server requires authentication, set the password in this setting.</li><li>`:authentication` - If your mail server requires authentication, you need to specify the authentication type here. This is a symbol and one of `:plain`, `:login`, `:cram_md5`.</li><li>`:enable_starttls_auto` - Set this to `false` if there is a problem with your server certificate that you cannot resolve.</li></ul>|
|`sendmail_settings`|Allows you to override options for the `:sendmail` delivery method.<ul><li>`:location` - The location of the sendmail executable. Defaults to `/usr/sbin/sendmail`.</li><li>`:arguments` - The command line arguments to be passed to sendmail. Defaults to `-i -t`.</li></ul>|
|`raise_delivery_errors`|Whether or not errors should be raised if the email fails to be delivered. This only works if the external email server is configured for immediate delivery.|
|`delivery_method`|Defines a delivery method. Possible values are `:smtp` (default), `:sendmail`, `:file` and `:test`.|
|`perform_deliveries`|Determines whether deliveries are actually carried out when the `deliver` method is invoked on the Mail message. By default they are, but this can be turned off to help functional testing.|
|`deliveries`|Keeps an array of all the emails sent out through the Action Mailer with delivery_method :test. Most useful for unit and functional testing.|
|`default_options`|Allows you to set default values for the `mail` method options (`:from`, `:reply_to`, etc.).|

가능한 설정을 모두 보기 위해서는 레일스 어플리케이션 설정하기 가이드에 있는 [액션 메일러 설정](configuring.html#configuring-action-mailer)를 보기 바랍니다. [[[For a complete writeup of possible configurations see the [Action Mailer section](configuring.html#configuring-action-mailer) in our Configuring Rails Applications guide.]]]

### [Example Action Mailer Configuration] 액션 메일러 설정의 예

아래의 예는 적당한 환경 파일 `config/environments/$RAILS_ENV.rb`에 추가해 주면 됩니다. [[[An example would be adding the following to your appropriate 
`config/environments/$RAILS_ENV.rb` file:]]]

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i -t'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-reply@example.com'}
```

### [Action Mailer Configuration for Gmail] Gmail을 위한 액션 메일러 설정하기

액션 메일러는 Mail 젬을 사용하기 때문에, `config/environments/$RAILS_ENV.rb` 파일에 아래의 설정을 추가하기만 할 정도로 간단해 졌습니다. [[[As Action Mailer now uses the Mail gem, this becomes as simple as adding to your `config/environments/$RAILS_ENV.rb` file:]]]

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            '<username>',
  password:             '<password>',
  authentication:       'plain',
  enable_starttls_auto: true  }
```

[Mailer Testing] 메일러 테스트하기
--------------

[테스트하기 가이드](testing.html#testing-your-mailers)를 보면 메일러를 테스트하는 방법에 대해서 자세하게 나와 있습니다. [[[You can find detailed instructions on how to test your mailers in the [testing guide](testing.html#testing-your-mailers).]]]

[Intercepting Emails] 이메일 가로채기
-------------------

때로는 이메일리 발송되기 전에 수정을 해야할 필요가 있습니다. 다행이도 액션 메일러는 모든 이메일을 가로채기 위한 콜백 후크를 제공해 줍니다. interceptor를 등록해 주면, 이메일이 발송되기 직전에 메일 메시지를 수정할 수 있습니다. [[[There are situations where you need to edit an email before it's delivered. Fortunately Action Mailer provides hooks to intercept every email. You can register an interceptor to make modifications to mail messages right before they are handed to the delivery agents.]]]

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

interceptor가 제대로 동작하기 위해서는 액션 메일러 프레임워크에 먼저 등록을 해 주어야 합니다. `config/initializers/sandbox_email_interceptor.rb` 파일에서 이러한 작업을 해 주면 됩니다. 
[[[Before the interceptor can do its job you need to register it with the Action Mailer framework. You can do this in an initializer file `config/initializers/sandbox_email_interceptor.rb`]]]

```ruby
ActionMailer::Base.register_interceptor(SandboxEmailInterceptor) if Rails.env.staging?
```

NOTE: 위의 설정은 운영환경이지만 테스트 목적의 "staging"이라는 커스텀 환경을 사용합니다. 커스텀 레일스 환경에 대한 자세한 내용은 [Creating Rails environments](./configuring.html#creating-rails-environments)를 참고하기 바랍니다. [[[The example above uses a custom environment called "staging" for a production like server but for testing purposes. You can read [Creating Rails environments](./configuring.html#creating-rails-environments) for more information about custom Rails environments.]]]