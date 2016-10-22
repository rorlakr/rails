
Active Job 기초
=================

이 가이드에서는 백그라운드에서 실행하는 잡(Job)의 생성과 큐에 등록하는 방법(enqueue), 실행 방법에 대해서 설명합니다.

이 가이드의 내용:

* 잡 만들기
* 잡 등록하기
* 백그라운드에서 잡 실행하기
* 애플리케이션에서 비동기로 메일 전송하기

--------------------------------------------------------------------------------


시작하기 전에
------------

Active Job은 잡을 선언하고, 이를 이용하여 큐를 사용하는 백엔드에서 다양한
방법으로 이를 처리하는 프레임워크입니다. 여기서 잡이란 정기적으로 정기적으로
실행되는 작업이나, 인보이스 발행이나 메일 전송 등, 어떤 것이라도 가능합니다.
이 작업들을 좀 더 작은 단위로 분할해서 병렬 실행할 수도 있습니다.


Active Job의 목적
-----------------------------
Active Job의 주 목적은 Rails 애플리케이션이 곧바로 실행하는 작업일지라도,
자신만의 잡 관리 인프라를 가질 수 있도록 하는 것입니다. 이를 통해서
Delayed Job과 Resque와 같은, 다양한 잡마다의 실행 방식의 차이를 신경쓰지 않고
잡 프레임워크의 기능이나 그 이외의 gem을 탑재할 수 있게 됩니다. 백엔드에서
큐를 관리할 때에는 조작 이외에는 신경을 쓸 필요가 없게 됩니다. 또한 잡 관리
프레임워크를 변경하더라도 잡을 새로 작성할 필요가 없다는 장점도 있습니다.

NOTE: Rails는 기본으로 프로세스 내의 스레드 풀을 통해 비동기 큐를 동작시킵니다.
이를 통해서 잡이 비동기적으로 동작합니다만, 큐에 들어있는 잡들은 재시작과 함께 
초기화됩니다.

잡 만들기
--------------

여기에서는 잡의 생성 방법과 잡을 등록하는 방법에 대해서 순서대로 설명합니다.

### 잡 생성하기

Active Job은 잡 생성을 위한 Rails 제너레이터를 제공합니다. 이를 실행하면
`app/jobs`에 잡이 하나 생성됩니다.

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

아래와 같이 작성하면 특정 큐에 잡을 하나 생성합니다.

```bash
$ bin/rails generate job guests_cleanup --queue urgent
create  app/jobs/guests_cleanup_job.rb
```

이처럼, Rails에서 다른 제너레이터를 사용할 때와 완전히 동일한 방법으로 잡을
생성할 수 있습니다.

제너레이터를 사용하고 싶지 않다면, `app/jobs`의 아래에 자신의 잡 파일을 직접
생성할 수도 있습니다. 이런 경우에는 반드시 `ApplicationJob`를 상속해주세요.

생성된 잡은 아래와 같습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # 나중에 실행하고 싶은 작업을 여기에 작성한다.
  end
end
```

### 큐에 잡을 등록하기

다음과 같은 방식으로 큐에 잡을 등록할 수 있습니다.

```ruby
MyJob.perform_later record  # 큐 시스템에 여유가 생기면 잡을 등록한다
```

```ruby
MyJob.set(wait_until: Date.tomorrow.noon).perform_later(record)  # 내일 점심에 실행하고 싶은 잡을 등록한다
```

```ruby
MyJob.set(wait: 1.week).perform_later(record) # 일주일 뒤에 실행하고 싶은 잡을 등록한다
```

이상입니다.


잡 실행하기
-------------

어댑터가 설정되어 있지 않은 경우, 잡은 바로 실행됩니다.

### 백엔드

Active Job에는 Sidekiq, Resque, Delayed Job 등의 다양한 큐용 백엔드에 접속
가능한 어댑터가 내장되어 있습니다. 사용가능한 최신 어댑터 리스트에 대해서는
API 문서의 [ActiveJob::QueueAdapters](http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)를 참조해주세요.

### 백엔드 설정하기

사용하는 큐는 자유롭게 설정하고 변경할 수 있습니다.

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # 반드시 어댑터 잼을 Gemfile에 추가하고
    # 어댑터마다 반드시 인스톨과 배포하는 것을 잊지 말아주세요.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

또는 잡 별로 백엔드를 다르게 설정할 수도 있습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# `config.active_job.queue_adapter`에 어떤 백엔드를 설정했는지에 관계없이
# 이 잡은 `resque`를 백엔드로 사용할 것입니다.
```

### 백엔드 시작하기

잡은 Rails 애플리케이션에서 대해서 병렬로 실행되기 때문에 많은 큐 라이브러리는
잡을 처리하기 위한 라이브러리의 큐 서비스를 별도로 실행하기를 요구합니다.
큐 백엔드를 시작하는데에 필요한 설명은 각 라이브러리의 문서를
참조하세요. 

각 라이브러리들의 문서 목록입니다.

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)

큐
------

대부분의 어댑터에서는 다수의 큐를 사용할 수 있습니다. Active Job을 사용하면
특정 큐에 잡을 추가할 수 있습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ....
end
```

`application.rb`에서 아래와 같이 `config.active_job.queue_name_prefix`를
사용해서 큐 이름에 특정 접두어를 추가할 수 있습니다.

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end

# app/jobs/guests_cleanup.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  #....
end

# 이상으로 production 환경에서 production_low_priority 라는 큐에서 잡이
# 실행되게 되며, staging 환경에서는 staging_low_priority라는 큐에서 잡이
# 실행되게 됩니다.
```

기본 큐 이름 구분 기호는 '\_'입니다.이는 `application.rb`의
`config.active_job.queue_name_delimiter`를 통해서 변경할 수 있습니다.

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end

# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  #....
end

# 이제 잡은 production 환경이라면 production.low_priority 큐에,
# staging 환경이라면 staging.low_priority 큐에 추가됩니다.
```

잡을 추가하는 시점에서 큐를 제어하고 싶은 경우에는 #set에 `:queue` 옵션을
추가하면 됩니다.

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

잡을 동작하는 시점에서 큐를 제어하기 위해서 `#queue_as`에 블록을 넘겨줄 수도
있습니다. 넘겨진 블록은 그 잡의 컨텍스트 내에서 실행됩니다(따라서
self.arguments에도 접근할 수 있습니다). 그리고 이 블록에서는 큐의 이름을
반환해야 합니다.

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # do process video
  end
end

ProcessVideoJob.perform_later(Video.last)
```

NOTE: 설정한 큐의 이름을 큐를 관리하는 백엔드에서 '이해할 수' 있도록 해주세요.
일부 백엔드에서는 넘겨받는 큐의 이름을 지정해야 할 필요가 있습니다.


콜백
---------

Active Job은 잡의 생애 주기에 따른 훅을 제공합니다. 이를 이용해서 콜백을
사용할 수 있으므로 잡의 생애 주기의 특정 시점에 원하는 이벤트를 호출할 수
있습니다.

### 사용 가능한 콜백

* `before_enqueue`
* `around_enqueue`
* `after_enqueue`
* `before_perform`
* `around_perform`
* `after_perform`

### 사용법

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  before_enqueue do |job|
    # 잡 인스턴스로 처리해야하는 작업
  end

  around_perform do |job, block|
    # 실행 전에 해야하는 작업
    block.call
    # 실행 후에 해야하는 작업
  end

  def perform
    # 나중에 실행할 작업
  end
end
```


ActionMailer
------------

최근 웹 애플리케이션에서 자주 쓰는 잡 중의 한 가지는 요청-응답 주기 밖에서
발생하는 메일 전송일 것입니다. 이를 잡으로 처리하는 것으로 사용자가 메일
송신을 기다릴 필요가 없어집니다. Active Job은 Action Mailer와 통합되어
있으므로 비동기 메일 전송도 간단하게 처리할 수 있습니다.

```ruby
# 곧바로 전송하고 싶은 경우에는 #deliver_now를 사용
UserMailer.welcome(@user).deliver_now

# Active Job을 사용해서 나중에 메일을 전송하고 싶은 경우에는 #deliver_later를 사용
UserMailer.welcome(@user).deliver_later
```

국제화
--------

각 잡은 생성될 때의 `I18n.locale`설정을 사용합니다. 메일을 비동기로 전송하는
경우에 유용합니다.

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # Email will be localized to Esperanto.
```


GlobalID
--------
Active Job에서는 GlobalID를 파라미터로 사용할 수 있습니다. GlobalID를 사용하면,
동작 중인 Active Record 객체를 잡에 넘겨줄 때에 클래스와 id를 지정할 필요가
없어집니다. 클래스와 id를 지정하는 이전의 방법은 나중에 명시적으로
역직렬화(deserialize)를 할 필요가 있었습니다. 이전대로라면 이런 식으로
작성하던 코드를,

```ruby
class TrashableCleanupJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

지금은 아래처럼 간결하게 작성할 수 있습니다.

```ruby
class TrashableCleanupJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

이 코드는 `GlobalID::Identification`을 믹스인해둔 모든 클래스에서 동작하며,
이 모듈은 Active Model 클래스에 기본적으로 믹스인되어 있습니다.


예외
----------

Active Job에서는 잡 실행시에 발생하는 예외를 처리하기 위한 방법을 제공합니다.

```ruby

class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
   # 예외 처리를 작성한다
  end

  def perform
    # 나중에 실행하고 싶은 작업을 작성한다
  end
end
```

### 역직렬화(Deserialization)

GlobalID는 `#perform`을 통해서 넘겨진 Active Record 객체를 직렬화합니다.

만약 잡이 큐에 등록된 이후에 `#perform` 메소드라 실행되기 전에 레코드가
삭제되면, Active Job은 `ActiveJob::DeserializationError` 예외를 던집니다.

잡 테스트하기
--------------

잡을 테스트하는 방법에 대해서는 [테스팅 가이드](testing.html#잡-테스트하기)에서
자세한 설명을 확인할 수 있습니다.
