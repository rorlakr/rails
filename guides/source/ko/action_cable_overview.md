액션케이블 개요
=====================

이 가이드에서는 액션케이블의 구조와 웹소켓을 레일스 애플리케이션에 도입하여
실시간 기능을 구현하는 방법에 관해서 설명합니다.

이 가이드의 내용:

* 액션케이블 개요, 백엔드와 프론트엔드 통합하기
* 액션케이블 설정하기
* 채널 설정하기
* 액션케이블을 위한 배포 방법과 아키텍처 구성하기

--------------------------------------------------------------------------------

들어가면서
------------

액션케이블은 [웹소켓](https://en.wikipedia.org/wiki/WebSocket)과 레일스의 다른 부분을
매끄럽게 통합합니다. 액션케이블을 도입함으로써 레일스 애플리케이션의 고효율성과 확장성에 영향을 주는 일 없이
일반 레일스 애플리케이션과 같은 스타일/방법으로 실시간 기능을 루비로 작성할 수 있습니다.
이는 클라이언트의 자바스크립트 프레임워크와 서버의 루비 프레임워크를 동시에 제공하는 풀스택 프레임워크입니다.
그러므로 액티브레코드 등의 ORM으로 작성된 모든 도메인 모델에 접근할 수 있습니다.

Pub/Sub에 대해서
---------------

[Pub/Sub](https://ko.wikipedia.org/wiki/%EB%B0%9C%ED%96%89-%EA%B5%AC%EB%8F%85_%EB%AA%A8%EB%8D%B8)은
발행/구독이라고도 불리는 메시지 큐 패러다임입니다. 발신자는 수신자들이 누구인지 알지 못하는 상태로
수신자의 추상 클래스에 정보를 전송합니다. 액션케이블에서는 이 접근 방식을 통해 서버와 여러 클라이언트 간의
통신을 구현합니다.

## 서버 컴포넌트

### 커넥션

*커넥션*(connection)은 클라이언트와 서버 간의 관계의 기반이 됩니다. 서버에서 웹소켓이 요청을 받을
때마다 커넥션 객체가 생성됩니다. 이 객체는 앞으로 생성되는 모든 *채널 구독*의 부모가 됩니다.
이 커넥션 자체는 인증이나 권한 등의 애플리케이션 로직을 다루지 않습니다. 웹소켓의 커넥션 클라이언트는
*소비자*라고도 불립니다. 사용자가 여는 브라우저 탭, 윈도우, 기기마다 소비자-커넥션 쌍이 하나씩 생성됩니다.

커넥션은 `ApplicationCable::Connection`의 인스턴스입니다. 이 클래스에서는 요청받은 커넥션을
승인하고 사용자를 인증한 경우에 커넥션을 확립합니다.

#### 커넥션 설정

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

`identified_by`는 커넥션 ID이며, 나중에 특정 커넥션을 탐색하는 경우에도 사용할 수 있습니다.
ID로 선언된 정보는 그 커넥션 이외에도 생성된 모든 채널 인스턴스에 같은 이름이 자동으로 위임됩니다.

이 예제에서는 애플리케이션의 다른 곳에서 이미 사용자의 인증을 다루고 있으며,
인증에 성공하면 사용자 ID에 서명이 완료된 쿠키가 설정되어 있다는 전제로 다루고 있습니다.

그러면 새 커넥션이 시도될 때 쿠키는 자동으로 커넥션 인스턴스로 전송되고, 이를 통해 `current_user`를
설정하게 됩니다. 현재 사용자와 같은 커넥션이라고 판명되면 그 사용자가 열어둔 모든 커넥션을 가져오거나,
또는 사용자가 삭제되어 인증이 불가능한 경우에 커넥션을 종료할 수도 있습니다.

### 채널

*채널*은 일반적인 MVC에서 컨트롤러가 하는 일과 마찬가지로, 작업을 논리적인 단위로 캡슐화합니다.
레일스는 기본으로 채널 간에 공유되는 로직을 위한 `ApplicationCable::Channel`이라는 부모 클래스를 생성합니다.

#### 부모 채널 설정

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

이 코드를 통해 사용할 Channel 클래스를 정의합니다. 예를 들어, `ChatChannel`이나
`AppearanceChannel`를 다음과 같이 정의할 수 있습니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end

# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```

이로써 소비자는 이러한 채널을 구독할 수 있게 됩니다.

#### 구독

소비자는 *구독자*처럼 채널을 구독합니다. 그리고 소비자의 커넥션은 *구독*이라고 불립니다.
생성된 메시지는 소비자가 전송한 ID를 기반으로 채널 구독에 라우팅됩니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # 소비자가 이 채널의 구독자가 되면 이 코드가 호출됨.
  def subscribed
  end
end
```

## 클라이언트 컴포넌트

### 커넥션

소비자 쪽에서도 커넥션 인스턴스는 필요합니다.
이 커넥션은 레일스가 생성하는 자바스크립트 코드로 확립됩니다.

#### 소비자 연결하기

```js
// app/assets/javascripts/cable.js
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(this);
```

이를 통해서 서버의 `/cable`에 접속하는 소비자가 준비되었습니다.
단, 채널을 적어도 하나 이상 구독하기 전까지 커넥션이 확립되지 않습니다.

#### 구독자

한 채널을 구독하는 것으로 소비자는 구독자가 될 수 있습니다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" }

# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create { channel: "AppearanceChannel" }
```

이 코드로 채널을 구독할 수 있으며, 수신한 데이터에 응답하는 기능에 대해서는 나중에 설명합니다.

소비자는 특정 채널에 대한 구독자로서 몇 번이고 행동할 수 있습니다.
예를 들자면, 소비자는 여러 채팅방을 동시에 구독할 수 있습니다.

```coffeescript
App.cable.subscriptions.create { channel: "ChatChannel", room: "1st Room" }
App.cable.subscriptions.create { channel: "ChatChannel", room: "2nd Room" }
```

## 클라이언트-서버간 동작

### 스트림

*스트림*은 브로드캐스트나 발행하는 내용을 구독자에게 라우팅하는 기능을 제공합니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

어떤 모델에 관련된 스트림을 생성하면, 그 모델과 채널로부터 브로드캐스트가 생성됩니다.
다음 예제에서는 `comments:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`와 같은 브로드캐스트를 구독합니다.

```ruby
class CommentsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end 
end
```

이것으로 이 채널에 다음과 같이 브로드캐스트를 할 수 있게 됩니다.

```ruby
CommentsChannel.broadcast_to(@post, @comment)
```

### 브로드캐스트

*브로드캐스트*(broadcasting)는 발행자가 채널의 구독자들에게 어떤 것이든 전송할 수 있는 pub/sub 연결입니다.
각 채널은 여러 개의 브로드캐스트를 스트리밍할 수 있습니다.

브로드캐스트는 순수한 온라인 큐이며, 시간에 의존합니다. 스트리밍(한 채널에 대한 구독)하고 있지 않은 소비자는
나중에 접속할 경우 브로드캐스트를 얻을 수 없습니다.

브로드캐스트는 레일스 애플리케이션의 다른 장소에서도 호출할 수 있습니다.

```ruby
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to` 호출에서는 사용자마다 다른 브로드캐스트 이름으로
현재 구독 어댑터(production에서의 기본값은 `redis`이며, 개발환경과 테스트 환경에서는 `async`입니다)
pubsub 큐에 메시지를 저장합니다. ID가 1인 사용자라면 브로드캐스트의 이름은
`web_notifications:1`이 사용됩니다.

`received` 콜백을 호출하면 이 채널은 `web_notifications:1`이 수신하는 모든 것을
클라이언트에 직접 스트리밍하게 됩니다.

### 구독

채널을 구독한 사용자는 구독자처럼 행동합니다. 이 커넥션은 구독이라 불립니다.
메시지를 받으면 사용자가 전송한 ID에 기반하여 이러한 채널로 전송합니다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
# 통지를 수신할 수 있는 권한을 서버에게 받았다고 가정
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    @appendLine(data)

  appendLine: (data) ->
    html = @createLine(data)
    $("[data-chat-room='Best Room']").append(html)

  createLine: (data) ->
    """
    <article class="chat-line">
      <span class="speaker">#{data["sent_by"]}</span>
      <span class="body">#{data["body"]}</span>
    </article>
    """
```

### 채널에 매개 변수 넘기기

구독을 생성할 때 클라이언트의 매개 변수를 서버에 넘길 수 있습니다. 다음의 예제를 보시죠.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

`subscriptions.create`에 첫번째 인자로 넘겨진 객체는 params 해시가 됩니다.
`channel` 키워드는 생략할 수 없습니다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    @appendLine(data)

  appendLine: (data) ->
    html = @createLine(data)
    $("[data-chat-room='Best Room']").append(html)

  createLine: (data) ->
    """
    <article class="chat-line">
      <span class="speaker">#{data["sent_by"]}</span>
      <span class="body">#{data["body"]}</span>
    </article>
    """
```

```ruby
# 이 코드는 애플리케이션 어딘가에서 호출된다.
# ex: NewCommentJob
ActionCable.server.broadcast(
  "chat_#{room}",
  sent_by: 'Paul',
  body: 'This is a cool chat app.'
)
```

### 메시지를 다시 브로드캐스트하기

한 클라이언트로부터 받은 메시지를 접속하고 있는 다른 클라이언트에게 *재전송*하는 경우가 많습니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.chatChannel = App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" },
  received: (data) ->
    # data => { sent_by: "Paul", body: "This is a cool chat app." }

App.chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

다시 브로드캐스트를 하게 되면 접속 중인 모든 클라이언트에게 전송합니다. 전송을 요청한 클라이언트 자신도
_예외가 아닙니다_. 사용하는 매개 변수들은 채널에 구독할 때와 같습니다.

## 풀스택 예시

다음의 설정 순서는 두 가지 예제에서 공통입니다.

  1. [커넥션을 설정](#connection-setup).
  2. [부모 채널을 설정](#parent-channel-setup).
  3. [소비자를 연결](#connect-consumer).

### 예제 1: 사용자 접속을 표시하기

이는 사용자가 온라인인지 아닌지, 사용자가 어떤 페이지를 보고 있는지 추적하는 간단한 예제입니다.
(이는 사용자들이 접속 중일 때에 그 사람 이름의 옆에 녹색 점을 표시하는 기능 등을 구현할 때에 유용합니다)

서버 채널을 다음과 같이 만듭니다.

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```

구독이 시작되면 `subscribed` 콜백이 실행되어, 그 사용자가 온라인이라고 표시됩니다.
이 표시 API를 Redis나 데이터베이스 등과 연동할 수 있습니다.

클라이언트의 채널을 만듭시다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create "AppearanceChannel",
  # 구독이 가능해지면 호출됨
  connected: ->
    @install()
    @appear()

  # 웹소켓 접속이 닫히면 호출됨
  disconnected: ->
    @uninstall()

  # 구독이 서버에서 거부되는 경우 호출됨
  rejected: ->
    @uninstall()

  appear: ->
    # 서버의 `AppearanceChannel#appear(data)`를 호출
    @perform("appear", appearing_on: $("main").data("appearing-on"))

  away: ->
    # 서버의 `AppearanceChannel#away`를 호출
    @perform("away")


  buttonSelector = "[data-behavior~=appear_away]"

  install: ->
    $(document).on "page:change.appearance", =>
      @appear()

    $(document).on "click.appearance", buttonSelector, =>
      @away()
      false

    $(buttonSelector).show()

  uninstall: ->
    $(document).off(".appearance")
    $(buttonSelector).hide()
```

##### 클라이언트-서버 간의 동작

1. **클라이언트**는 **서버**에 `App.cable = ActionCable.createConsumer("ws://cable.example.com")`
경유로 접속합니다. (`cable.js`) **서버**는 이 접속을 `current_user`로 확인합니다.

2. **클라이언트**는 채널에 `App.cable.subscriptions.create(channel: "AppearanceChannel")`를
거쳐서 접속합니다. (`appearance.coffee`)

3. **서버**는 표시 채널에 새 구독이 시작된 것을 인식하고 서버의 `subscribed` 콜백을 통해
`current_user`의 `appear` 메소드를 호출합니다. (`appearance_channel.rb`)

4. **클라이언트**는 구독이 확립된 것을 확인하고 `connected` (`appearance.coffee`)를 호출합니다.
이를 통해 `@install`과 `@appear`가 호출됩니다. `@appear`는 서버의 `AppearanceChannel#appear(data)`를
통해서 데이터 해시 `{ appearing_on: $("main").data("appearing-on") }`를 넘겨줍니다.
서버의 클래스에 선언되어 있는 (콜백을 제외한) 모든 퍼블릭 메소드가 자동적으로 노출되기 때문에 가능합니다.
공개된 퍼블릭 메소드는 `perform` 메소드를 사용하여 원격 프로시저로서 사용할 수 있습니다.

5. **서버**는 `current_user`로 확인한 커넥션의 채널에서 `appear` 액션에 대한 요청을 수신합니다.
(`appearance_channel.rb`) **서버**는 데이터 해시에서 `:appearing_on` 키를 사용하여 값을 꺼내어 
`current_user.appear`에 넘겨진 `:on`키의 값으로 설정합니다.

### 예제 2: 새로운 알림을 수신하기

이 예제에서는 웹소켓을 사용하여 서버로부터 클라이언트의 기능을 원격으로 실행하는 동작을 다룹니다.
그런데 웹소켓의 멋진 점은 양방향 통신이라는 것입니다. 이번에는 서버에서 클라이언트의 액션을 호출해봅시다.

이 알림 채널은 올바른 스트림에 브로드캐스트를 할 때 클라이언트에 알림을 표시합니다.

서버의 알림 채널을 만듭니다.

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

구독을 위한 클라이언트의 알림 채널을 만듭니다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/web_notifications.coffee
# 클라이언트에서는 알림을 보낼 수 있는 권한을 가지고 있다고 가정.
App.cable.subscriptions.create "WebNotificationsChannel",
  received: (data) ->
    new Notification data["title"], body: data["body"]
```

알림 채널 인스턴스로 어떤 내용을 브로드캐스트하는 것은 애플리케이션의 어디에서라도 가능합니다.

```ruby
# 이 코드는 애플리케이션의 어딘가(ex: NewCommentJob)에서 호출됨
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to` 호출에서는 현재 구독 어댑터의 pubsub 큐에 메시지를
추가합니다. 이 때 사용자마다 서로 다른 브로드캐스트 이름이 사용됩니다. ID가 1인 사용자라면
브로드캐스트의 이름은 `web_notifications:1`이 됩니다.

`received` 콜백이 호출되면, 이 채널은 `web_notifications:1`에 도착한 것을 모두 클라이언트에게
전송합니다. 인자로서 넘겨진 데이터는 서버의 브로드캐스트 호출의 두번째 인수로 넘겨지는 해시입니다.
이 해시는 JSON으로 인코딩되어 전송되며, `received`로 수신할 때 데이터 인자로부터 복원됩니다.

### 더 자세한 예시

레일스 애플리케이션에 액션 케이블을 설정하는 방법이나 채널을 추가하는 방법에 대해서는
[rails/actioncable-examples](https://github.com/rails/actioncable-examples)에서
전체 예시를 볼 수 있습니다.

## 설정

액션케이블에는 구독 어댑터와 허가된 요청 호스트라는 두 개의 필수 설정이 있습니다.

### 구독 어댑터

액션케이블은 `config/cable.yml` 설정 파일을 사용합니다. 레일스 환경마다 어댑터와 URL을 하나씩
설정해야 합니다. 어댑터에 대해서는 [의존성](#의존성)를 참고해주세요.

```yaml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: redis://10.10.3.153:6381
```

### 허가된 요청 호스트

액션케이블은 허가된 곳으로부터의 요청만을 받습니다. 이 호스트 목록은 배열의 형태로 서버 설정에 넘깁니다.
각 호스트는 문자열이나 정규 표현식을 사용할 수 있습니다.

```ruby
config.action_cable.allowed_request_origins = ['http://rubyonrails.com', %r{http://ruby.*}]
```

모든 요청을 허가하려면 다음을 설정하세요.

```ruby
config.action_cable.disable_request_forgery_protection = true
```

development 환경에서 실행 중일 때, 액션케이블은 localhost:3000 로부터의 요청을 모두 허가합니다.

### 소비자 설정

URL을 설정하려면 HTML 레이아웃의 HEAD에 `action_cable_meta_tag` 호출을 추가합니다.
보통 여기에서 사용하는 URL은 각 환경의 설정 파일에서 `config.action_cable.url`로 설정합니다.

### 기타 설정

이외에도 커넥션마다 로거에 태그를 설정할 수도 있습니다. 다음 예제에서는 사용자 계정 ID가 있는
경우에는 이를 사용하고, 없는 경우에는 "no-account"라는 태그를 사용합니다.

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

사용 가능한 모든 옵션은 `ActionCable::Server::Configuration` 클래스를 확인해주세요.

또한 서버가 제공하는 데이터베이스 커넥션의 갯수는 적어도 워커의 숫자보다 많아야 합니다.
기본 워커 풀의 크기는 4이므로, 데이터베이스 커넥션도 4개 이상을 준비해야 합니다.
이 값은 `config/database.yml`의 `pool`에서 변경할 수 있습니다.

## 액션케이블 전용 서버를 실행하기

### 애플리케이션에서 실행하기

액션케이블은 레일스 애플리케이션과 함께 실행할 수 있습니다.
예를 들어, `/websocket`에서 웹소켓 요청을 수신하는 경우에는
`config.action_cable.mount_path`로 경로를 지정할 수 있습니다.

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end 
```

레이아웃에서 `action_cable_meta_tag`를 호출하면 `App.cable = ActionCable.createConsumer()`에서
액션케이블 서버에 접속할 수 있게 됩니다. `createConsumer`의 첫번째 인자에는 커스텀 경로가
지정됩니다(e.g. `App.cable = ActionCable.createConsumer("/websocket")`).

생성한 서버의 모든 인스턴스와 서버가 생성한 모든 워커 인스턴스에는 액션케이블의 새로운 인스턴스도 포함됩니다.
커넥션 간의 메시지 동기화는 Redis를 통해서 이루어집니다.

### 독립된 서버에서 실행하기

애플리케이션 서버와 액션케이블 서버를 나눌 수도 있습니다.
액션케이블 서버는 Rack 애플리케이션입니다만, 독립된 애플리케이션이기도 합니다.
추천하는 기본 설정은 다음과 같습니다.

```ruby
# cable/config.ru
require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
```

이어서, `bin/cable`의 binstub을 사용하여 서버를 기동합니다.

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

28080 포트에서 액션케이블 서버가 실행됩니다.

### 메모

웹소켓 서버로부터 세션에 접근할 수 없습니다만, 쿠키에는 접근할 수 있습니다. 이를 사용해서 인증을 처리할 수 있습니다.
이 [글](http://www.rubytutorial.io/actioncable-devise-authentication)에서 Devise와
함께 사용하는 방법을 확인할 수 있습니다.

## 의존성

액션케이블은 pubsub을 처리하기 위한 구독 어댑터 인터페이스를 제공합니다.
비동기, 인라인, PostgreSQL, Evented Redis, Non-evented Redis 등의 어댑터를 사용할 수 있습니다.
새 레일스 애플리케이션의 기본 어댑터는 비동기(`async`) 어댑터입니다.

루비 코드는 [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r),
[concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) 위에서 구축되어 있습니다.

## 배포

액션케이블을 지지하고 있는 것은 웹소켓과 스레드입니다. 프레임워크 내부의 흐름이나 사용자 지정의 채널 동작은
루비의 기본 스레드를 통하여 처리됩니다. 다시 말해 스레드에 안전한 코드를 유지하는 한, 레일스의 정규 모델을
문제 없이 사용할 수 있다는 의미입니다.

액션케이블 서버에는 Rack 소켓을 탈취하는 API가 구현되어 있습니다. 이를 통해서, 애플리케이션 서버의
멀티 스레드 사용 여부와 관계없이 내부의 커넥션을 멀티 스레드 패턴으로 관리합니다.

따라서 액션케이블은 Unicorn, Puma, Passenger 등의 유명한 서버와 문제없이 연동될 수 있습니다.
