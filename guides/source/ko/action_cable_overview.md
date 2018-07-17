**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonrails.org.**

액션케이블 시작하기
=====================

이 가이드에서는 액션케이블의 구조와 웹소켓을 레일스 애플리케이션에 도입하여 실시간 기능을 구현하는 방법에 관해서 설명합니다.

이 가이드의 내용:

* 액션케이블 개요, 백엔드와 프론트엔드 통합하기
* 액션케이블 설정하기
* 채널 설정하기
* 액션케이블을 위한 배포 방법과 아키텍처 구성하기

--------------------------------------------------------------------------------

들어가며
------------

액션케이블은 [웹소켓](https://en.wikipedia.org/wiki/WebSocket)
과 레일스의 다른 부분을 매끄럽게 통합합니다. 액션케이블을 통해
일반 레일스 애플리케이션과 같은 형태와 스타일로 효율성과 확장성을
계속해서 보장하는 동시에 실시간 기능을 루비로 구현할 수 있습니다.
이는 클라이언트의 자바스크립트 프레임워크와 서버의 루비 프레임워크를
동시에 제공하는풀스택 프레임워크입니다. 그러므로 액티브레코드 등의
선택하고자 하는 ORM으로 작성된 모든 도메인 모델에 접근할 수 있습니다.

Pub/Sub에 대하여
---------------

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern),
또는 발행-구독은 정보를 보낸이(이하 '발신자')으로부터
특정되지 않은 받는이(이하 '수신자')의 추상 클래스로
정보를 보내는 메시지 큐 패러다임을 말합니다. 액션케이블은
이러한 접근법으로 서버와 여러 클라이언트 간의 통신을 구현합니다.

## 서버측 컴포넌트

### 커넥션

*커넥션(Connections)* 은 클라이언트와 서버 간의 관계의 기반이 됩니다.
서버에서 웹소켓이 요청을 받을 때마다 커넥션 객체가 생성됩니다.
이 객체는 앞으로 생성되는 모든 *채널 구독* 의 부모가 됩니다.
이 커넥션 자체는 인증이나 권한 이외의 어떠한 특정 애플리케이션
로직도 다루지 않습니다. 웹소켓의 커넥션 클라이언트는 커넥션
*소비자* 라고도 불립니다. 사용자 개인이 여는 브라우저 탭, 윈도우,
기기마다 소비자-커넥션 쌍을 하나씩 생성하게 됩니다.

커넥션은 `ApplicationCable::Connection` 의 객체 입니다.
이 클래스에서는 들어온 커넥션 요청을 승인하고 인증된 사용자인 경우에
커넥션을 성립시킵니다.

#### 커넥션 설정

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

`identified_by` 는 커넥션 ID이며, 나중에 특정 커넥션을
탐색하는 경우에도 사용할 수 있습니다. ID로 선언된 정보는 그 커넥션
이외에도 생성된 모든 채널 인스턴스에 같은 이름이 자동으로 위임됩니다.

이 예제는 이미 이 애플리케이션의 다른 곳 어딘가에서 사용자의 인증을
다루고 있으며, 그것이 성공적으로 인증 되면 사용자 ID 로서 쿠키를
내려주고 있다는 사실이 전제되어 있습니다.

이 쿠키는 새로운 커넥션이 시도되었을 때 자동적으로 커넥션 인스턴스로
전송되고, 이를 통해 `current_user` 를 설정하게 됩니다. 현재
사용자와 같은 커넥션이라고 확인되면 그 사용자가 열어둔 모든 커넥션을
가지게 되며, 사용자가 삭제되었거나 인증이 불가능한 경우에는 잠정적으로
커넥션을 종료시킬 수도 있습니다.

### 채널

*채널(channel)* 일반적인 MVC에서 컨트롤러가 하는 일과 마찬가지로, 작업을 논리적인
단위로 캡슐화합니다. 레일스는 캡슐화하여 채널 간에 공유되는 로직을 위해
기본적으로 `ApplicationCable::Channel` 이라는 부모 클래스를 생성합니다.

#### 부모 채널 설정

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

이제 여러분이 사용할 자신의 Channel 클래스를 정의합니다. 예를 들어,
`ChatChannel` 이나 `AppearanceChannel` 은 다음과 같이 정의할 수 있겠습니다:

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

소비자는 *구독자(subscribers)* 처럼 활동하며 채널을 구독합니다.
그리고 이러한 소비자의 커넥션을 *구독(subscription)* 이라고 합니다.
생성된 메시지들은 케이블 소비자가 전송한 ID를 기반으로 채널 구독에 라우팅 됩니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # 소비자가 성공적으로 이 채널의
  # 구독자가 되었을 때 호출됨.
  def subscribed
  end
end
```

## 클라이언트측 컴포넌트

### 커넥션

소비자 쪽에서도 커넥션 인스턴스가 필요합니다.
이 커넥션은 레일스에 의해 기본으로 생성된 자바스크립트 코드를 통해 이뤄집니다:

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

이로써 서버의 `/cable` 에 대응해 접속하게 될 소비자가
준비되었습니다. 단, 채널을 적어도 하나 이상 구독하기
전에는 커넥션이 성립되지 않습니다.

#### 구독자

한 채널에 대해 구독을 생성하는 것으로 소비자는 구독자가 됩니다:

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
App.cable.subscriptions.create { channel: "ChatChannel", room: "Best Room" }

# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create { channel: "AppearanceChannel" }
```

위와 같이 구독을 생성할 수 있으며, 수신한 데이터에
응답하는 기능에 대해서는 나중에 설명하겠습니다.

한 명의 소비자는 특정 채널에 대한 한 명의 구독자로서 몇 번이고 행동할 수 있습니다.
예를 들어 소비자는 여러 채팅방을 동시에 구독할 수 있습니다:

```coffeescript
App.cable.subscriptions.create { channel: "ChatChannel", room: "1st Room" }
App.cable.subscriptions.create { channel: "ChatChannel", room: "2nd Room" }
```

## 클라이언트-서버간 상호작용

### 스트림

*스트림(Streams)* 은 브로드캐스트나 발행하는 내용을
구독자에게 라우팅하는 기능을 제공합니다.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

어떤 모델에 관련된 스트림을 생성하면, 그 모델과 채널로부터 브로드캐스트가
생성됩니다. 다음 예제에서는 `comments:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`
와 같은 브로드캐스트를 구독합니다.

```ruby
class CommentsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

이것으로 이 채널에 다음과 같이 브로드캐스트를 할 수 있게 됩니다:

```ruby
CommentsChannel.broadcast_to(@post, @comment)
```

### 브로드캐스팅

*브로드캐스트(broadcasting)* 는 발행자가 채널의 구독자들에게
어떤 것이든 전송할 수 있는 pub/sub 연결입니다. 각 채널은
여러 개의 브로드캐스트를 스트리밍할 수 있습니다.

브로드캐스트는 순수한 온라인 큐이며, 시간에 의존합니다.
스트리밍(한 채널에 대한 구독)하고 있지 않은 소비자는
나중에 접속할 경우 브로드캐스트를 얻을 수 없습니다.

브로드캐스트는 레일스 애플리케이션의 다른 장소에서도 호출할 수 있습니다:

```ruby
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to` 호출에서는 사용자마다 다른
브로드캐스트 이름으로 현재 구독 어댑터(production에서의 기본값은 redis이며,
개발환경과 테스트 환경에서는 async입니다) pubsub 큐에 메시지를 저장합니다.
ID가 1인 사용자라면 브로드캐스트의 이름은 `web_notifications:1` 이 사용됩니다.

received 콜백을 호출하면 이 채널은 `web_notifications:1`
이 수신하는 모든 것을 클라이언트에 직접
스트리밍하게 됩니다.

### 구독

채널을 구독한 사용자는 구독자로서 행동합니다. 이 커넥션은
구독이라 불립니다. 메시지를 받으면 사용자가 전송한 ID에
기반하여 이러한 채널로 전송합니다.

```coffeescript
# app/assets/javascripts/cable/subscriptions/chat.coffee
# 웹 알림을 보낼 수 있는 권한을 이미 요청했다고 가정
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

### 채널에 매개변수 넘기기

구독을 생성할 때 클라이언트 측에서 서버 측으로
매개 변수를 전달할 수 있습니다. 다음의 예제를 보시죠:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

`subscriptions.create` 에 첫번째 인자로 넘겨진 객체는
params 해시가 됩니다. `channel` 키워드는 생략할 수 없습니다.

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
# NewCommentJob 과 같은 애플리케이션 어딘가에서
# 다음 처럼 호출됩니다.
ActionCable.server.broadcast(
  "chat_#{room}",
  sent_by: 'Paul',
  body: 'This is a cool chat app.'
)
```

### 메시지를 재전송하기

한 클라이언트로부터 받은 메시지를 접속하고 있는 다른
클라이언트에게 *재전송(rebroadcast)* 하는 경우도 많습니다.

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

재전송을 하게 되면 접속 중인 모든 클라이언트에게 전송됩니다.
이는 전송을 요청한 클라이언트 자신도 *포함합니다*.
사용하는 매개 변수들은 채널에 구독할 때와 같습니다.

## 풀 스택 예제

다음의 설정 순서는 두 가지 예시에서 공통적으로 해당됩니다:

  1. [커넥션 설정](#connection-setup).
  2. [부모 채널 설정](#parent-channel-setup).
  3. [소비자를 연결](#connect-consumer).

### 예제 1: 사용자 접속을 표시하기

이는 사용자가 온라인인지 아닌지, 사용자가 어떤 페이지를 보고 있는지
추적하는 간단한 예제입니다. (이는 사용자들이 접속 중일 때에 그 사람
이름의 옆에 녹색 점을 표시하는 기능 등을 구현할 때에 유용합니다)

서버 측에 나타낼 채널을 생성하세요:

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

구독이 시작되면 `subscribed` 콜백이 시작되고, "현재 사용자가 접속중"
이라고 알려줄 수 있게 됩니다. 이 표시 API를 Redis나 데이터베이스
등과 연동할 수 있습니다.

클라이언트 측에 나타낼 채널 구독을 생성하세요:

```coffeescript
# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create "AppearanceChannel",
  # 구독이 가능해지면 호출됨.
  connected: ->
    @install()
    @appear()

  # 웹소켓 연결이 닫히면 호출됨.
  disconnected: ->
    @uninstall()

  # 구독이 서버로부터 거부되는 경우 호출됨.
  rejected: ->
    @uninstall()

  appear: ->
    # 서버의 `AppearanceChannel#appear(data)`를 호출.
    @perform("appear", appearing_on: $("main").data("appearing-on"))

  away: ->
    # 서버의 `AppearanceChannel#away`를 호출.
    @perform("away")


  buttonSelector = "[data-behavior~=appear_away]"

  install: ->
    $(document).on "turbolinks:load.appearance", =>
      @appear()

    $(document).on "click.appearance", buttonSelector, =>
      @away()
      false

    $(buttonSelector).show()

  uninstall: ->
    $(document).off(".appearance")
    $(buttonSelector).hide()
```

##### 클라이언트-서버간 상호작용

1. **클라이언트** 는 **서버** 에 `App.cable =
ActionCable.createConsumer("ws://cable.example.com")` 를 경유하여 연결됩니다.
**서버** 는 이 연결을 `current_user` 로 인식합니다. (위치: cable.js)

2. **클라이언트** 는 `App.cable.subscriptions.create(channel: "AppearanceChannel")`
을 경유하여 채널을 구독합니다. (위치: appearance.coffee)

3. **서버** 는 표시 채널에 새 구독이 시작된 것을
인식하고 서버의 `subscribed` 콜백을 통해 `current_user`의
`appear` 메소드를 호출합니다. (위치: appearance_channel.rb)

4. **클라이언트** 는 구독이 성립된 것을 인식하고 `connected` 를 호출합니다 (위치:
appearance.coffee). 이를 통해 @install과 @appear가 호출됩니다. @appear는
서버의 `AppearanceChannel#appear(data)` 를 통해서 데이터 해시
`{ appearing_on: $("main").data("appearing-on") }` 를
넘겨줍니다. 서버의 클래스에 선언되어 있는 (콜백을 제외한) 모든 퍼블릭
메소드가 자동적으로 노출되기 때문에 가능합니다. 공개된 퍼블릭 메소드는
perform 메소드를 사용하여 원격 프로시저로서 사용할 수 있습니다.

5. **서버** 는 `current_user` 로 확인한 커넥션의
채널에서 appear 액션에 대한 요청을 수신합니다.
(위치: appearance_channel.rb) 서버는 데이터 해시에서
`:appearing_on` 키를 사용하여 값을 꺼내어 `current_user.appear`
에 넘겨진 `:on` 키의 값으로 설정합니다.

### 예제 2: 새로운 알림을 수신하기

이 예제에서는 웹소켓을 사용하여 서버로부터 클라이언트의
기능을 원격으로 실행하는 동작을 다룹니다. 그런데
웹소켓의 멋진 점은 양방향 통신이라는 것입니다.
이번에는 서버에서 클라이언트의 액션을 호출해봅시다.

이 알림 채널은 올바른 스트림에 브로드캐스트를
할 때 클라이언트에 알림을 표시합니다.

서버의 알림 채널을 만듭니다:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

구독을 위한 클라이언트의 알림 채널을 만듭니다:

```coffeescript
# app/assets/javascripts/cable/subscriptions/web_notifications.coffee
# 클라이언트 쪽으로 알림을 보낼 수 있는 권한을
# 서버가 이미 가지고 있다고 가정합니다.
App.cable.subscriptions.create "WebNotificationsChannel",
  received: (data) ->
    new Notification data["title"], body: data["body"]
```

알림 채널 인스턴스로 어떤 내용을 브로드캐스트하는 것은
애플리케이션의 어디에서라도 가능합니다:

```ruby
# 이 코드는 애플리케이션의 어딘가(ex: NewCommentJob)에서 호출됨
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

`WebNotificationsChannel.broadcast_to` 호출에서는
현재 구독 어댑터의 pubsub 큐에 메시지를 추가합니다.
이 때 사용자마다 서로 다른 브로드캐스트 이름이 사용됩니다.
ID가 1인 사용자라면 브로드캐스트의 이름은 web_notifications:1이 됩니다.

`received` 콜백이 호출되면, 이 채널은 `web_notifications:1`
에 도착한 것을 모두 클라이언트에게 전송합니다. 인자로서 넘겨진 데이터는
서버의 브로드캐스트 호출의 두번째 인수로 넘겨지는 해시입니다.
이 해시는 JSON으로 인코딩되어 전송되며, `received` 로 수신할 때
데이터 인자로부터 복원됩니다.

### 더 자세한 예시

레일스 애플리케이션에 액션 케이블을 설정하는 방법이나 채널을 추가하는 방법에 대해서는
[rails/actioncable-examples](https://github.com/rails/actioncable-examples) 에서 전체 예시를 볼 수 있습니다.

## 설정

액션케이블에는 구독 어댑터와 허가된 요청 호스트라는 두 개의 필수 설정이 있습니다.

### 구독 어댑터

기본적으로, 액션케이블은 `config/cable.yml`을 설정 파일로 인식합니다.
이 파일은 각각의 레일스 환경마다 특정 어댑터를 지정해야고 있어야 합니다.
어댑터에 관한 추가적인 정보는 [의존성](#dependencies) 부분을 참고해주세요.

```yaml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### 어댑터 설정

아래는 최종사용자가 구독할 때에 사용할 수 있는 어댑터 목록입니다.

##### Async 어댑터

async 어댑터는 개발/테스트 환경을 위한 것으로, 실제 배포 환경에서는 사용자지 마세요.

##### Redis 어댑터

Redis 어댑터를 사용하려면 Redis 서버를 가리키는 URL을 사용자가 지정해주어야 합니다. 추가적으로, 다수의 애플리케이션이 같은
Redis 서버를 사용할 때에 채널 이름이 충돌하는 것을 방지하기 위해 `channel_prefix` 가 제공됩니다. 보다 자세한 내용은
[Redis PubSub documentation](https://redis.io/topics/pubsub#database-amp-scoping)을 참고해주세요.

##### PostgreSQL 어댑터

PostgreSQL 어댑터는 액티브레코드의 connection pool 을 사용합니다.
따라서 애플리케이션의 `config/database.yml`에서 데이터베이스를 설정해야 합니다.
이 부분은 가까운 시일 내에 변경이 있을 수도 있습니다. [#27214](https://github.com/rails/rails/issues/27214)

### 허가된 요청 호스트

액션케이블은 허가된 곳으로부터의 요청만을 받습니다.
이 호스트 목록은 배열의 형태로 서버 설정에 넘깁니다.
각 호스트는 문자열이나 정규 표현식을 사용할 수 있습니다.

```ruby
config.action_cable.allowed_request_origins = ['http://rubyonrails.com', %r{http://ruby.*}]
```

모든 요청을 허가하려면 다음을 설정하세요:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

development 환경에서 실행 중일 때, 액션케이블은 기본적으로
localhost:3000 로부터의 요청을 모두 허가합니다.

### 소비자 설정

URL을 설정하기 위해서, HTML 레이아웃의 HEAD 태그 내에 `action_cable_meta_tag` 을 추가하세요.
이렇게 하면 URL이나 경로를 보통의 방식처럼 환경 설정 파일에서 `config.action_cable.url`
을 통해 설정된 것으로 간주하여 사용하게 됩니다.

### 기타 설정

설정을 위한 그 밖의 다른 공통 옵션은 커넥션별 로거에 적용되는 로그 태그 입니다.
사용자 계정 ID를 사용할 수 있는 경우 사용 예시는 다음과 같습니다.
사용자 계정 ID를 사용할 수 없다면, 태깅 중에는 "no-account" 를 사용하세요:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

설정 옵션의 전체 목록을 보려면,
`ActionCable::Server::Configuration` 클래스를 확인하세요.

또한, 서버는 가지고 있는 worker의 개수와 동일한 수의 데이터베이스 연결을 제공해야 합니다.
기본 worker의 pool 사이즈는 4 로 설정되어 있기 때문에,
최소한 같은 수의 사용 가능한 연결을 확보해주어야 합니다.
이는 `config/database.yml`의 `pool` 속성을 통해 변경할 수 있습니다.

## 독립 케이블 서버 실행하기

### 애플리케이션에서 실행하기

액션케이블은 레일스 애플리케이션과 함께 실행할 수 있습니다.
예를 들어, `/websocket` 에서 웹소켓 요청을 수신하는 경우에는
`config.action_cable.mount_path` 로 경로를 지정할 수 있습니다:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

레이아웃에서 `action_cable_meta_tag`가 호출되고 있으면, 케이블 서버에 연결하기 위해
`App.cable = ActionCable.createConsumer()` 를 사용할 수 있습니다.
`createConsumer`의 첫 번째 인자를 통해 path를 커스텀하여 지정 할 수 있습니다.
(예시. `App.cable = ActionCable.createConsumer("/websocket")` )

생성한 서버의 모든 인스턴스와 서버가 생성한 모든 워커
인스턴스에는 액션케이블의 새로운 인스턴스도 포함됩니다.
커넥션 간의 메시지 동기화는 Redis를 통해서 이루어집니다.

### 독립된 서버에서 실행하기

애플리케이션 서버와 액션케이블 서버를 나눌 수도 있습니다.
액션케이블 서버는 Rack 애플리케이션입니다만, 독립된
애플리케이션이기도 합니다. 추천하는 기본 설정은 다음과 같습니다.

```ruby
# cable/config.ru
require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
```

이어서, `bin/cable` 의 binstub을 사용하여 서버를 시작합니다:

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

위 코드는 28080 포트에서 액션케이블 서버를 실행시킵니다.

### 메모

웹소켓 서버로부터 세션에 접근할 수 없습니다만, 쿠키에는 접근할 수 있습니다. 이를 사용해서 인증을 처리할
수 있습니다. [이 글](http://www.rubytutorial.io/actioncable-devise-authentication)에서
Devise와 함께 사용하는 방법을 확인할 수 있습니다.

## 의존성

액션케이블은 pubsub을 처리하기 위한 구독 어댑터 인터페이스를 제공합니다.
기본 사항으로 비동기, 인라인, PostgreSQL, Evented Redis,
Non-evented Redis 등의 어댑터를 탑재하고 있습니다. 새 레일스
애플리케이션의 기본 어댑터는 비동기(`async`) 어댑터입니다.

구현된 루비 코드는 [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r), [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) 에 있습니다.

## 배포

액션케이블은 웹소켓과 스레드의 조합으로 제작되어 있습니다. 두
프레임워크 내부의 흐름과 사용자 지정 채널의 동작은 루비의 기본
스레드를 통해 처리됩니다. 즉 스레드에 안전한 코드를 유지하는
한, 모든 레일즈의 정규 모델을 문제 없이 사용할 수 있습니다.

액션케이블 서버에는 Rack 소켓을 탈취(hijacking)하는 API가
구현되어 있습니다. 이를 통해서, 애플리케이션 서버의 멀티 스레드
사용 여부와 관계없이 내부의 커넥션을 멀티 스레드 패턴으로 관리합니다.

따라서 액션케이블은 Unicorn, Puma, Passenger 등의
인기 있는 서버와 문제없이 연동될 수 있습니다.
