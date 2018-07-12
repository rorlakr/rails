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

The following setup steps are common to both examples:

  1. [Setup your connection](#connection-setup).
  2. [Setup your parent channel](#parent-channel-setup).
  3. [Connect your consumer](#connect-consumer).

### 예제 1: 사용자 접속을 표시하기

Here's a simple example of a channel that tracks whether a user is online or not
and what page they're on. (This is useful for creating presence features like showing
a green dot next to a user name if they're online).

Create the server-side appearance channel:

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

When a subscription is initiated the `subscribed` callback gets fired and we
take that opportunity to say "the current user has indeed appeared". That
appear/disappear API could be backed by Redis, a database, or whatever else.

Create the client-side appearance channel subscription:

```coffeescript
# app/assets/javascripts/cable/subscriptions/appearance.coffee
App.cable.subscriptions.create "AppearanceChannel",
  # Called when the subscription is ready for use on the server.
  connected: ->
    @install()
    @appear()

  # Called when the WebSocket connection is closed.
  disconnected: ->
    @uninstall()

  # Called when the subscription is rejected by the server.
  rejected: ->
    @uninstall()

  appear: ->
    # Calls `AppearanceChannel#appear(data)` on the server.
    @perform("appear", appearing_on: $("main").data("appearing-on"))

  away: ->
    # Calls `AppearanceChannel#away` on the server.
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

1. **Client** connects to the **Server** via `App.cable =
ActionCable.createConsumer("ws://cable.example.com")`. (`cable.js`). The
**Server** identifies this connection by `current_user`.

2. **Client** subscribes to the appearance channel via
`App.cable.subscriptions.create(channel: "AppearanceChannel")`. (`appearance.coffee`)

3. **Server** recognizes a new subscription has been initiated for the
appearance channel and runs its `subscribed` callback, calling the `appear`
method on `current_user`. (`appearance_channel.rb`)

4. **Client** recognizes that a subscription has been established and calls
`connected` (`appearance.coffee`) which in turn calls `@install` and `@appear`.
`@appear` calls `AppearanceChannel#appear(data)` on the server, and supplies a
data hash of `{ appearing_on: $("main").data("appearing-on") }`. This is
possible because the server-side channel instance automatically exposes all
public methods declared on the class (minus the callbacks), so that these can be
reached as remote procedure calls via a subscription's `perform` method.

5. **Server** receives the request for the `appear` action on the appearance
channel for the connection identified by `current_user`
(`appearance_channel.rb`). **Server** retrieves the data with the
`:appearing_on` key from the data hash and sets it as the value for the `:on`
key being passed to `current_user.appear`.

### 예제 2: 새로운 알림을 수신하기

The appearance example was all about exposing server functionality to
client-side invocation over the WebSocket connection. But the great thing
about WebSockets is that it's a two-way street. So now let's show an example
where the server invokes an action on the client.

This is a web notification channel that allows you to trigger client-side
web notifications when you broadcast to the right streams:

Create the server-side web notifications channel:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Create the client-side web notifications channel subscription:

```coffeescript
# app/assets/javascripts/cable/subscriptions/web_notifications.coffee
# Client-side which assumes you've already requested
# the right to send web notifications.
App.cable.subscriptions.create "WebNotificationsChannel",
  received: (data) ->
    new Notification data["title"], body: data["body"]
```

Broadcast content to a web notification channel instance from elsewhere in your
application:

```ruby
# Somewhere in your app this is called, perhaps from a NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

The `WebNotificationsChannel.broadcast_to` call places a message in the current
subscription adapter's pubsub queue under a separate broadcasting name for each
user. For a user with an ID of 1, the broadcasting name would be
`web_notifications:1`.

The channel has been instructed to stream everything that arrives at
`web_notifications:1` directly to the client by invoking the `received`
callback. The data passed as argument is the hash sent as the second parameter
to the server-side broadcast call, JSON encoded for the trip across the wire
and unpacked for the data argument arriving as `received`.

### 더 자세한 예시

See the [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
repository for a full example of how to setup Action Cable in a Rails app and adding channels.

## 설정

Action Cable has two required configurations: a subscription adapter and allowed request origins.

### 구독 어댑터

By default, Action Cable looks for a configuration file in `config/cable.yml`.
The file must specify an adapter for each Rails environment. See the
[Dependencies](#dependencies) section for additional information on adapters.

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

Below is a list of the subscription adapters available for end users.

##### Async 어댑터

The async adapter is intended for development/testing and should not be used in production.

##### Redis 어댑터

The Redis adapter requires users to provide a URL pointing to the Redis server.
Additionally, a `channel_prefix` may be provided to avoid channel name collisions
when using the same Redis server for multiple applications. See the [Redis PubSub documentation](https://redis.io/topics/pubsub#database-amp-scoping) for more details.

##### PostgreSQL 어댑터

The PostgreSQL adapter uses Active Record's connection pool, and thus the
application's `config/database.yml` database configuration, for its connection.
This may change in the future. [#27214](https://github.com/rails/rails/issues/27214)

### 허가된 요청 호스트

Action Cable will only accept requests from specified origins, which are
passed to the server config as an array. The origins can be instances of
strings or regular expressions, against which a check for the match will be performed.

```ruby
config.action_cable.allowed_request_origins = ['http://rubyonrails.com', %r{http://ruby.*}]
```

To disable and allow requests from any origin:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

By default, Action Cable allows all requests from localhost:3000 when running
in the development environment.

### 소비자 설정

To configure the URL, add a call to `action_cable_meta_tag` in your HTML layout
HEAD. This uses a URL or path typically set via `config.action_cable.url` in the
environment configuration files.

### 기타 설정

The other common option to configure is the log tags applied to the
per-connection logger. Here's an example that uses
the user account id if available, else "no-account" while tagging:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

For a full list of all configuration options, see the
`ActionCable::Server::Configuration` class.

Also, note that your server must provide at least the same number of database
connections as you have workers. The default worker pool size is set to 4, so
that means you have to make at least that available. You can change that in
`config/database.yml` through the `pool` attribute.

## 독립 케이블 서버 실행하기

### 애플리케이션에서 실행하기

Action Cable can run alongside your Rails application. For example, to
listen for WebSocket requests on `/websocket`, specify that path to
`config.action_cable.mount_path`:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

You can use `App.cable = ActionCable.createConsumer()` to connect to the cable
server if `action_cable_meta_tag` is invoked in the layout. A custom path is
specified as first argument to `createConsumer` (e.g. `App.cable =
ActionCable.createConsumer("/websocket")`).

For every instance of your server you create and for every worker your server
spawns, you will also have a new instance of Action Cable, but the use of Redis
keeps messages synced across connections.

### 독립된 서버에서 실행하기

The cable servers can be separated from your normal application server. It's
still a Rack application, but it is its own Rack application. The recommended
basic setup is as follows:

```ruby
# cable/config.ru
require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
```

Then you start the server using a binstub in `bin/cable` ala:

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

The above will start a cable server on port 28080.

### 메모

The WebSocket server doesn't have access to the session, but it has
access to the cookies. This can be used when you need to handle
authentication. You can see one way of doing that with Devise in this [article](http://www.rubytutorial.io/actioncable-devise-authentication).

## 의존성

Action Cable provides a subscription adapter interface to process its
pubsub internals. By default, asynchronous, inline, PostgreSQL, and Redis
adapters are included. The default adapter
in new Rails applications is the asynchronous (`async`) adapter.

The Ruby side of things is built on top of [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r), and [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## 배포

Action Cable is powered by a combination of WebSockets and threads. Both the
framework plumbing and user-specified channel work are handled internally by
utilizing Ruby's native thread support. This means you can use all your regular
Rails models with no problem, as long as you haven't committed any thread-safety sins.

The Action Cable server implements the Rack socket hijacking API,
thereby allowing the use of a multithreaded pattern for managing connections
internally, irrespective of whether the application server is multi-threaded or not.

Accordingly, Action Cable works with popular servers like Unicorn, Puma, and
Passenger.
