**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonrails.org.**

[Active Job Basics] 액티브 잡 기초
=================

이 가이드는 백그라운드 잡을 생성하고, 큐에 등록하고, 실행하는데 필요한 모든 내용을 다룬다. [[[This guide provides you with all you need to get started in creating, enqueueing and executing background jobs.]]]

이 가이드에서 다루게 될 내용을 아래와 같다. [[[After reading this guide, you will know:]]]

* 잡 생성법 [[[How to create jobs.]]]

* 잡 큐 등록법 [[[How to enqueue jobs.]]]

* 백그라운드 잡 실행법[[[How to run jobs in the background.]]]

* 애플리케이션에서 비동기적 이메일 발송법 [[[How to send emails from your application async.]]]

--------------------------------------------------------------------------------


[Introduction] 개요
------------

액티브 잡이란, 잡을 선언하여 다양한 큐 백엔드에서 실행되도록 하는 하나의 프레임워크다. 정규적으로 실행하는 시스템 정비작업, 요금청구작업, 이메일 발송작업 등 모든 것에 대한 잡을 선언할 수 있다. 작업을 작은 단위로 쪼개어 동시에 실행할 수 있다면 정말 어떤 것이라도 잡으로 선언할 수 있다. [[[Active Job is a framework for declaring jobs and making them run on a variety of queueing backends. These jobs can be everything from regularly scheduled clean-ups, to billing charges, to mailings. Anything that can be chopped up into small units of work and run in parallel, really.]]]


[The Purpose of Active Job] 액티브 잡의 목적
-----------------------------

요점은 레일스 애플리케이션이 어떤 잡 하부구조를 가질 것이라는 것을 확인하는 것이다. 이러한 잡은 지체없이 바로 실행되는 러너의 형태를 가지더라도 상관없다. 이렇게 되면 프레임워크의 특성을 가지게 되어, Delayed Job과 Resque와 같은 다양한 잡 러너들이 각기 다른 API를 가지더라도 걱정할 필요가 없이, 이 위에서 다른 젬을 빌드할 수 있게 된다. 따라서 큐 작업을 처리하는 백엔드의 선택이 더 큰 운영상의 관심꺼리가 된다. 어떤 것을 선택하더라도 더 이상 잡을 다시 작성하지 않고도 잡 러너를 교체할 수 있을 것이다. [[[The main point is to ensure that all Rails apps will have a job infrastructure in place, even if it's in the form of an "immediate runner". We can then have framework features and other gems build on top of that, without having to worry about API differences between various job runners such as Delayed Job and Resque. Picking your queuing backend becomes more of an operational concern, then. And you'll be able to switch between them without having to rewrite your jobs.]]]


[Creating a Job] 잡 생성하기
--------------

이 섹션에서는 잡을 생성하고 큐에 등록하는 과정을 단계별로 가이드해 줄 것이다. [[[This section will provide a step-by-step guide to creating a job and enqueuing it.]]]

### [Create the Job] 잡 생성

액티브 잡은 잡을 생성할 수 있도록 레일스 제너레이터를 제공한다. 아래의 명령은 `app/jobs` 디렉토리에 잡을 생성하고 `test/jobs` 디렉토리에 테스트 케이스를 작성해 줄 것이다. [[[Active Job provides a Rails generator to create jobs. The following will create a job in `app/jobs` (with an attached test case under `test/jobs`):]]]

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

물론, 특정 큐에서만 실행되는 잡을 생성할 수도 있다. [[[You can also create a job that will run on a specific queue:]]]

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

잡 제너레이터를 사용하지 않을 경우에는 `app/jobs` 디렉토리에 직접 파일을 생성하고 해당 잡이 `ActiveJob::Base`로부터 상속받도록 정의하면 된다. [[[If you don't want to use a generator, you could create your own file inside of `app/jobs`, just make sure that it inherits from `ActiveJob::Base`.]]]

잡의 형태는 아래와 같다. [[[Here's what a job looks like:]]]

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # 나중에 수행할 작업을 작성한다.
    # Do something later
  end
end
```

### [Enqueue the Job] 잡의 큐 등록

아래와 같이 잡을 큐에 등록한다. [[[Enqueue a job like so:]]]

```ruby
# 큐 시스템에 등록된 작업이 완료될 때 수행하도록 잡을 큐에 등록한다
# Enqueue a job to be performed as soon the queueing system is
# free.
MyJob.perform_later record
```

```ruby
# 내일 정오에 수행하도록 잡을 큐에 등록한다.
# Enqueue a job to be performed tomorrow at noon.
MyJob.set(wait_until: Date.tomorrow.noon).perform_later(record)
```

```ruby
# 1주일 후에 수행하도록 잡을 큐에 등록한다.
# Enqueue a job to be performed 1 week from now.
MyJob.set(wait: 1.week).perform_later(record)
```

이것으로 등록 작업이 끝났다. [[[That's it!]]]


[Job Execution] 잡 실행
-------------

어댑터를 지정하지 않으면 잡이 즉각 실행된다. [[[If no adapter is set, the job is immediately executed.]]]

### [Backends] 백엔드

액티브 잡은 Sidekiq, Resque, Delayed Job 등과 같은 여러가지 큐 등록 백엔드에 대한 내장 어댑터를 가지고 있다. 이러한 어댑터의 최신 목록을 보기 위해서는 [ActiveJob::QueueAdapters](http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)에 대한 API 문서를 보라. [[[Active Job has built-in adapters for multiple queueing backends (Sidekiq, Resque, Delayed Job and others). To get an up-to-date list of the adapters see the API Documentation for [ActiveJob::QueueAdapters](http://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).]]]

### [Setting the Backend] 백엔드 지정하기

아래와 같이 쉽게 큐 등록 백엔드를 지정할 수 있다. [[[You can easily set your queueing backend:]]]

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Gemfile에 해당 어댑터의 젬이 있는지 확인하고
    # 해당 어댑터의 특별한 설치 및 배포 명령을 따른다.
    # Be sure to have the adapter's gem in your Gemfile
    # and follow the adapter's specific installation
    # and deployment instructions.
    config.active_job.queue_adapter = :sidekiq
  end
end
```


[Queues] 큐
------

대다수의 어댑터는 여러개의 큐를 동시에 지원한다. 액티브 잡을 사용하면 특정 잡이 지정 큐에서 실행되도록 일정을 잡을 수 있다. [[[Most of the adapters support multiple queues. With Active Job you can schedule the job to run on a specific queue:]]]

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :low_priority
  #....
end
```

`application.rb` 파일의 `config.active_job.queue_name_prefix`을 사용하면 모든 잡의 큐 이름 앞에 접두어를 지정할 수 있다. [[[You can prefix the queue name for all your jobs using `config.active_job.queue_name_prefix` in `application.rb`:]]]

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end

# app/jobs/guests_cleanup.rb
class GuestsCleanupJob < ActiveJob::Base
  queue_as :low_priority
  #....
end

# 이와 같이 지정하면 운영 환경에서는 production_low_priority 큐에서,
# 스테이징 환경에서는 staging_low_priority 큐에서 잡을 실행하게 될 것이다.
# Now your job will run on queue production_low_priority on your
# production environment and on staging_low_priority
# on your staging environment
```

큐 이름 접두어 구분자는 디폴트로 '\_'로 지정되어 있다. 이것은 `application.rb`에서 `config.active_job.queue_name_delimiter`를 다른 값으로 지정하여 변경할 수 있다. [[[The default queue name prefix delimiter is '\_'.  This can be changed by setting `config.active_job.queue_name_delimiter` in `application.rb`:]]]

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end

# app/jobs/guests_cleanup.rb
class GuestsCleanupJob < ActiveJob::Base
  queue_as :low_priority
  #....
end

# 이제부터 운영 환경에서는 production.low_priority 큐에서,
# 스테이징 환경에서는 staging.low_priority 큐에서 잡이 실행될 것이다.
# Now your job will run on queue production.low_priority on your
# production environment and on staging.low_priority
# on your staging environment
```

잡을 수행할 큐를 더 잘 제어하기 위해서 `#set` 메소드에 `:queue` 옵션을 넘겨줄 수 있다. [[[If you want more control on what queue a job will be run you can pass a `:queue` option to `#set`:]]]

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

잡 레벨에서 큐를 제어하기 위해서 `#queue_as` 메소드로 블록을 넘겨 줄 수 있다. 이 때 해당 블록은 잡 컨텍스트 상에서 실행되어 `self.arguments`를 접근할 수 있으며 마지막에는 큐 이름을 반환해야 한다. [[[To control the queue from the job level you can pass a block to `#queue_as`. The block will be executed in the job context (so you can access `self.arguments`) and you must return the queue name:]]]

```ruby
class ProcessVideoJob < ActiveJob::Base
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

NOTE: 큐 등록 백엔드가 특정 큐 이름을 "인식"한다는 것을 확인해야 한다. 어떤 백엔드에서는 인식해야할 큐를 명시해야하는 경우도 있다. [[[Make sure your queueing backend "listens" on your queue name. For some backends you need to specify the queues to listen to.]]]


[Callbacks] 콜백
---------

액티브 잡은 잡이 동작하는 동안에 훅을 사용할 수 있게 한다. 콜백은 잡이 동작하는 동안 어떤 동작을 호출할 수 있게 한다. [[[Active Job provides hooks during the life cycle of a job. Callbacks allow you to trigger logic during the life cycle of a job.]]]

### [Available callbacks] 사용가능한 콜백

* `before_enqueue`
* `around_enqueue`
* `after_enqueue`
* `before_perform`
* `around_perform`
* `after_perform`

### [Usage] 사용법

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    # 잡 인스턴스에 대해서 어떤 작업을 수행한다.
    # do something with the job instance
  end

  around_perform do |job, block|
    # perform 메소드를 호출하기 전에 어떤 작업을 작성한다.
    # do something before perform
    block.call
    # perform 메소드를 호출한 후 어떤 작업을 작성한다.
    # do something after perform
  end

  def perform
    # 나중에 수행할 작업을 작성한다.
    # Do something later
  end
end
```


[Action Mailer] 액션 메일러
------------

최근 웹 애플리케이션에서의 가장 흔한 작업 중의 하나는 요청-응답 주기와는 별개로 이메일을 발송하는 것이며, 따라서 사용자는 응답-요청 주기를 끝날 때까지 기다릴 필요가 없게 되었다. 액티브 잡은 액션 메일러와 통합되어 손쉽게 비동기적으로 이메일을 발송할 수 있게 되었다. [[[One of the most common jobs in a modern web application is sending emails outside of the request-response cycle, so the user doesn't have to wait on it. Active Job is integrated with Action Mailer so you can easily send emails asynchronously:]]]

```ruby
# 이메일을 즉시 발송하기를 원할 때는 #deliver_now 메소드를 사용하라.
# If you want to send the email now use #deliver_now
UserMailer.welcome(@user).deliver_now

# 액티브 잡을 이용해서 이메일을 발송할 때는 #deliver_later 메소드를 사용하라.
# If you want to send the email through Active Job use #deliver_later
UserMailer.welcome(@user).deliver_later
```


[GlobalID] GlobalID
--------

액티브 잡은 파라미터에 대해 GlobalID를 사용할 수 있도록 지원한다. 따라서 class/id 쌍 대신에 실제 데이터를 가지는 액티브 레코드 객체를 잡으로 넘겨 줄 수 있게 되는데 class/id 쌍으로 넘겨 줄 경우에는 직접 액티브 레코드 객체를 생성해 주어야 한다. 변경 전의 코든 아래와 같다. [[[Active Job supports GlobalID for parameters. This makes it possible to pass live Active Record objects to your job instead of class/id pairs, which you then have to manually deserialize. Before, jobs would look like this:]]]

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

변경 후는 아래와 같이 간단하게 작성할 수 있다. [[[Now you can simply do:]]]

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

이것은 `GlobalID::Identification` 모듈을 믹신하는 어떤 클래스에서도 동작하는데, 이 모듈은 액티브 레코드 클래스에 디폴트로 믹신되어 있다. [[[This works with any class that mixes in `GlobalID::Identification`, which by default has been mixed into Active Record classes.]]]


[Exceptions] 예외
----------

액티브 잡은 잡 실행 중에 발생하는 예외를 잡아낼수 있는 방법을 제공한다. [[[Active Job provides a way to catch exceptions raised during the execution of the job:]]]

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # 예외 발생시 수행할 작업을 작성한다.
    # do something with the exception
  end

  def perform
    # 나중에 수행할 작업을 작성한다.
    # Do something later
  end
end
```
