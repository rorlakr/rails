[Development Dependencies Install] 개발 의존성 설치하기
================================

본 가이드는 루비 온 레일스 코어 개발을 위한 환경을 설정하는 방법을 다룹니다. [[[This guide covers how to setup an environment for Ruby on Rails core development.]]]

본 가이드를 읽은 후, 다음을 알게 됩니다.:[[[After reading this guide, you will know:]]]

--------------------------------------------------------------------------------

[The Easy Way] 쉬운 방법
------------

개발 환경을 준비하기 위한 가장 손쉽고 추천되는 방법은 [Rails development box](https://github.com/rails/rails-dev-box)를 사용하는 것입니다. [[[The easiest and recommended way to get a development environment ready to hack is to use the [Rails development box](https://github.com/rails/rails-dev-box).]]]

[The Hard Way] 어려운 방법
------------

위에서 본 것과 같이 레일스 개발 백스를 사용할 수 없디면, 루비 온 레일스 코어 개발을 위한 개발 박스를 수동으로 구축하는 단계가 다음에 있습니다. [[[In case you can't use the Rails development box, see section above, these are the steps to manually build a development box for Ruby on Rails core development.]]]

### [Install Git] Git 설치

루비 온 레일스는 소스코드 제어를 위해 Git을 사용합니다. [Git homepage](http://git-scm.com/)에 설치 지침이 있습니다. Git에 익숙해지는 것을 도울 다양한 리소스들이 네트워크상에 있습니다. [[[Ruby on Rails uses Git for source code control. The [Git homepage](http://git-scm.com/) has installation instructions. There are a variety of resources on the net that will help you get familiar with Git:]]]

* [Try Git course](http://try.github.io/)는 기초를 가르쳐주는 인터렉티브 코스입니다. [[[[Try Git course](http://try.github.io/) is an interactive course that will teach you the basics.]]]

* [official Documentation](http://git-scm.com/documentation)는 매우 포괄적이고 또한 Git의 기초에 대한 약간의 동영상을 포함하고 있습니다. [[[The [official Documentation](http://git-scm.com/documentation) is pretty comprehensive and also contains some videos with the basics of Git]]]

* [Everyday Git](http://schacon.github.io/git/everyday.html)은 Git을 사용할 때 충분한 내용을 가르쳐줄 것입니다. [[[[Everyday Git](http://schacon.github.io/git/everyday.html) will teach you just enough about Git to get by.]]]

* Git의 [PeepCode screencast](https://peepcode.com/products/git) ($12)는 따라하기 쉽습니다. [[[The [PeepCode screencast](https://peepcode.com/products/git) on Git ($12) is easier to follow.]]]

* [GitHub](http://help.github.com)는 Git 리소스의 다양한 링크를 제공합니다. [[[[GitHub](http://help.github.com) offers links to a variety of Git resources.]]]

* [Pro Git](http://git-scm.com/book)은 크리에이티브 커먼스 라이센스로 제공되는 Git에 대한 온전한 책입니다. [[[[Pro Git](http://git-scm.com/book) is an entire book about Git with a Creative Commons license.]]]

### [Clone the Ruby on Rails Repository] 루비 온 레일스 저장소 복제

루비 온 레일스 소스 코드를 위치시키고자 하는 폴더로 이동하여(이 작업은 `rails` 서브디렉터리를 만듭니다) 다음을 실행합니다.: [[[Navigate to the folder where you want the Ruby on Rails source code (it will create its own `rails` subdirectory) and run:]]]

```bash
$ git clone git://github.com/rails/rails.git
$ cd rails
```

### [Set up and Run the Tests] 설정 및 테스트 실행

테스트 스위트는 모든 서브밋된 코드를 통과해야 합니다. 새로운 패치를 작성하였건, 다른 사람의 것을 평가하건 상관없이, 테스트를 수행할 수 있어야 합니다. [[[The test suite must pass with any submitted code. No matter whether you are writing a new patch, or evaluating someone else's, you need to be able to run the tests.]]]

먼저 Nokogiri에 대한 libxml2와 libxslt를 개발용 파일과 함께 설치합니다. 우분투의 경우는 [[[Install first libxml2 and libxslt together with their development files for Nokogiri. In Ubuntu that's]]]

```bash
$ sudo apt-get install libxml2 libxml2-dev libxslt1-dev
```

만약 Fedora나 CentOS를 사용하고 있다면, 다음을 실행할 수 있습니다. [[[If you are on Fedora or CentOS, you can run]]]

```bash
$ sudo yum install libxml2 libxml2-devel libxslt libxslt-devel
```

만약 이 라이브러리들을 설치하는데 문제가 있다면, 소스코드를 수동으로 컴파일하여 이 라이브러리들을 설치해야 합니다. [Red Hat/CentOS section of the Nokogiri tutorials](http://nokogiri.org/tutorials/installing_nokogiri.html#red_hat__centos)에 있는 지침을 따라 하십시오. [[[If you have any problems with these libraries, you should install them manually compiling the source code. Just follow the instructions at the [Red Hat/CentOS section of the Nokogiri tutorials](http://nokogiri.org/tutorials/installing_nokogiri.html#red_hat__centos) .]]]

또한, `sqlite3-ruby` 젬을 위한 SQLite3와 개발용 파일들을, 우분투의 경우 다음과 같이 하면 됩니다. [[[Also, SQLite3 and its development files for the `sqlite3-ruby` gem — in Ubuntu you're done with just]]]

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev
```

만약 Fedora나 CentOS를 사용하고 있다면, 다음과 같이 합니다. [[[And if you are on Fedora or CentOS, you're done with]]]

```bash
$ sudo yum install sqlite3 sqlite3-devel
```

[Bundler](http://gembundler.com/)의 최신 버전을 얻습니다. [[[Get a recent version of [Bundler](http://gembundler.com/)]]]

```bash
$ gem install bundler
$ gem update bundler
```

그리고 다음을 실행합니다. [[[and run:]]]

```bash
$ bundle install --without db
```

이 명령은 MySQL과 PostgreSQL 루비 드라이버를 제외한 모든 의존성을 설치합니다. 이것은 곧 다를 것입니다. 의존성 설치를 마치면, 다음과 같이 테스트 스위트를 실행할 수 있습니다. [[[This command will install all dependencies except the MySQL and PostgreSQL Ruby drivers. We will come back to these soon. With dependencies installed, you can run the test suite with:]]]

```bash
$ bundle exec rake test
```

물론 Action Pack처럼, 특정 컴포넌트를 위한 테스트를 실행할 수도 있습니다. 컴포넌트의 디렉터리로 들어가서 동일한 명령을 수행합니다. [[[You can also run tests for a specific component, like Action Pack, by going into its directory and executing the same command:]]]

```bash
$ cd actionpack
$ bundle exec rake test
```

만약 특정 디렉터리에 위치한 테스트를 실행하고자 한다면 `TEST_DIR` 환경 변수를 사용하십시오. 예를 들어, 다음 명령은 `railties/test/generators`의 테스트만 실행할 것입니다. [[[If you want to run the tests located in a specific directory use the `TEST_DIR` environment variable. For example, this will run the tests of the `railties/test/generators` directory only:]]]

```bash
$ cd railties
$ TEST_DIR=generators bundle exec rake test
```

개별적으로 특정 단일 테스트만 수행할 수도 있습니다. [[[You can run any single test separately too:]]]

```bash
$ cd actionpack
$ bundle exec ruby -Itest test/template/form_helper_test.rb
```

### [Active Record Setup] 액티브 레코드 설정

액티브 레코드의 테스트 스위트는 네번 실행을 시도합니다. 한번은 SQLite3, 한번은 두개의 MySQL 젬들(`mysql`과 `mysql2`), 그리고 한번은 PostgreSQL에 대한 실행입니다. 이제 그들을 위한 환경을 설정하는 방법을 보겠습니다. [[[The test suite of Active Record attempts to run four times: once for SQLite3, once for each of the two MySQL gems (`mysql` and `mysql2`), and once for PostgreSQL. We are going to see now how to set up the environment for them.]]]

WARNING: 만약 액티브 레코드 코드로 작업하려면, 적어도 MySQL, PostgreSQL, 그리고 SQLite3을 위한 테스트를 통과하는지 _반드시_ 확인해야 합니다. MySQL로만 테스트했을 때 문제 없었던 많은 패치를 거부한 배후에는 다양한 어댑터간의 미묘한 차이가 있습니다. [[[WARNING: If you're working with Active Record code, you _must_ ensure that the tests pass for at least MySQL, PostgreSQL, and SQLite3. Subtle differences between the various adapters have been behind the rejection of many patches that looked OK when tested only against MySQL.]]]

#### [Database Configuration] 데이터베이스 구성

액티브 레코드 테스트 스위트는 사용자 정의 구성 파일 `activerecord/test/config.yml`이 필요합니다. 예제는 `activerecord/test/config.example.yml` 내에 제공되는데, 이를 복사하여 자신의 환경에 맞게 사용할 수 있습니다. [[[The Active Record test suite requires a custom config file: `activerecord/test/config.yml`. An example is provided in `activerecord/test/config.example.yml` which can be copied and used as needed for your environment.]]]

#### [MySQL and PostgreSQL] MySQL과 PostgreSQL

MySQL과 PostgreSQL을 위한 스위트를 실행할 수 있게 하려면 이들을 위한 젬이 필요합니다. 먼저 서버를 설치하고, 클라이언트 라이브러리들을 설치하고, 개발용 파일들을 설치합니다. 우분투에서는 다음과 같이 실행합니다. [[[To be able to run the suite for MySQL and PostgreSQL we need their gems. Install first the servers, their client libraries, and their development files. In Ubuntu just run]]]

```bash
$ sudo apt-get install mysql-server libmysqlclient15-dev
$ sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev
```

Fedora나 CentOS에서는 다음을 실행합니다. [[[On Fedora or CentOS, just run:]]]

```bash
$ sudo yum install mysql-server mysql-devel
$ sudo yum install postgresql-server postgresql-devel
```

그 후, 다음을 실행합니다. [[[After that run:]]]

```bash
$ rm .bundle/config
$ bundle install
```

먼저 `.bundle/config`를 삭제할 필요가 있는데, 그 이유는 "db" 그룹(아니면 파일에서 수정할 수 있는)을 설치하고자 하지 않았던 파일들을 번들러가 기억하고 있기 때문입니다. [[[We need first to delete `.bundle/config` because Bundler remembers in that file that we didn't want to install the "db" group (alternatively you can edit the file).]]]

MySQL에 대한 테스트 스위트를 실행할 수 있게 하려면 테스트 데이터베이스에 권한을 가진 `rails`라는 이름의 사용자를 생성할 필요가 있습니다. [[[In order to be able to run the test suite against MySQL you need to create a user named `rails` with privileges on the test databases:]]]

```bash
$ mysql -uroot -p

mysql> CREATE USER 'rails'@'localhost';
mysql> GRANT ALL PRIVILEGES ON activerecord_unittest.*
       to 'rails'@'localhost';
mysql> GRANT ALL PRIVILEGES ON activerecord_unittest2.*
       to 'rails'@'localhost';
```

그리고 테스트 데이터베이스를 생성합니다.: [[[and create the test databases:]]]

```bash
$ cd activerecord
$ bundle exec rake mysql:build_databases
```

PostgreSQL의 인증은 다르게 작동합니다. 예제를 위한 개발 환경을 설정하는 쉬운 방법은 개발 계정으로 실행하는 것입니다. [[[PostgreSQL's authentication works differently. A simple way to set up the development environment for example is to run with your development account]]]

```bash
$ sudo -u postgres createuser --superuser $USER
```

그리고나서 다음과 같이 테스트 데이터베이스를 생성합니다. [[[and then create the test databases with]]]

```bash
$ cd activerecord
$ bundle exec rake postgresql:build_databases
```

PostgreSQL과 MySQL 모두를 위한 데이터베이스를 만들 수도 있습니다. [[[It is possible to build databases for both PostgreSQL and MySQL with]]]

```bash
$ cd activerecord
$ bundle exec rake db:create
```

다음과 같이 데이터베이스를 정리할 수 있습니다. [[[You can cleanup the databases using]]]

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTE: 테스트 데이터베이스를 생성하기 위해 rake 태스크를 사용하는 것은 올바른 캐릭터셋과 정렬(collation)을 보장합니다. [[[NOTE: Using the rake task to create the test databases ensures they have the correct character set and collation.]]]

NOTE: PostgreSQL 9.1.x 혹은 그 이전 버전에서는 HStore 확장을 활성화하는 동안 다음과 같은 경고(혹은 지역화된 경고)를 볼 것입니다: "WARNING: => is deprecated as an operator" [[[NOTE: You'll see the following warning (or localized warning) during activating HStore extension in PostgreSQL 9.1.x or earlier: "WARNING: => is deprecated as an operator".]]]

만약 다른 데이터베이스를 사용한다면, 기본 접속 정보를 위해 `activerecord/test/config.yml` 혹은 `activerecord/test/config.example.yml` 파일을 살펴 보십시오. 만약 머신에 반드시 다른 종류의 자격증명을 제공해야만 한다면, `activerecord/test/config.yml`를 수정할 수 있습니다. 하지만 그러한 변경의 어떠한 부분이라도 Rails로 푸시하지 않아야 합니다. [[[If you’re using another database, check the file `activerecord/test/config.yml` or `activerecord/test/config.example.yml` for default connection information. You can edit `activerecord/test/config.yml` to provide different credentials on your machine if you must, but obviously you should not push any such changes back to Rails.]]]
