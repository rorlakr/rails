## 레일스 가이드 한글 번역

가이드 번역은 `guides-ko` 브랜치에서만 작업합니다. 편의를 위해 이 저장소의 디폴트 브랜치를 `guides-ko`로 지정해 놓았습니다. 

> **주의** : `master` 브랜치는 `rails/rails` 와의 동기화를 위한것으로 이곳에 직접 커밋하거나 풀리퀘스트 하지 않습니다.

## 준비 작업

1. 현재 저장소를 `fork`한다.
2. 방금 `fork`한 본인 계정의 저장소 **SSH clone URL**을 복사한다.
3. 터미널을 열고 원하는 디렉토리 상에서 아래와 같이 `git clone` 명령을 실행한 후 `rails-guides` 디렉토리로 이동한다.

  ```bash
  $ git clone https://github.com/{user_account}/rails-guides.git
  $ cd rails-guides
  ```

4. Gemfile이 존재하는지 확인한 후 번들 설치한다.

  ```bash
  $ bundle install
  ```
  
5.  `guides` 디렉토리로 이동한 후 `rake` 태스크 목록을 확인한다. 

  ```bash
  $ cd guides
  $ rake -T
  rake guides:generate                  # Generate guides (for authors), use ONLY=foo to process just "foo.md"
  rake guides:generate:html             # Generate HTML guides
  rake guides:generate:html:ko          # Generate HTML guides from source/ko (for RORLAB)
  rake guides:generate:html:ko:publish  # Publish the guides to shared/rg (for ROR Lab.)
  rake guides:generate:kindle           # Generate .mobi file
  rake guides:generate:kindle:ko        # Generate .mobi file
  rake guides:help                      # Show help
  rake guides:validate                  # Validate guides, use ONLY=foo to process just "foo.html"
  ```

## 번역 작업

1. 이제 번역할 마크다운 파일이 있는 디렉토리로 이동한다. 

  ```bash
  $ cd sources/ko
  ```

<<<<<<< HEAD
2. 본인이 번역하기를 원하는 파일이나 수정이 필요한 파일을 찾아 에디터로 열고 작업을 한다. 
3. 번역 작업 중간 중간에 html 파일로 확인하여 작성한 번역이 제대로 포맷되었는지 확인한다. 이 과정은 반드시 필요하다. 아래와 같이 명령을 실행하면 `rails-guides/guides/output/ko` 디렉토리로 `html` 파일이 생성/업데이트되는데, 본인이 작업한 파일명의 `.html` 확장자를 가진 파일을 브라우져로 열어 본다. 
=======
Active Record, Active Model, Action Pack, and Action View can each be used independently outside Rails.
In addition to that, Rails also comes with Action Mailer ([README](actionmailer/README.rdoc)), a library
to generate and send emails; Active Job ([README](activejob/README.md)), a
framework for declaring jobs and making them run on a variety of queueing
backends; Action Cable ([README](actioncable/README.md)), a framework to
integrate WebSockets with a Rails application;
and Active Support ([README](activesupport/README.rdoc)), a collection
of utility classes and standard library extensions that are useful for Rails,
and may also be used independently outside Rails.
>>>>>>> master

  ```bash
  $ cd rails-guides/guides
  $ bundle exec rake guides:generate:html:ko [ALL=1]
  $ cd rails-guides/guides/output/ko
  $ open xxxx.html
  ```


  > **노트** : `ALL=1` 옵션을 붙이지 않으면 변경된 파일만 생성

4. 작업이 완료되면 적절한 메시지와 함께 커밋한다.

  ```bash
  $ cd rails-guides
  $ git add .
  $ git commit -m "xxxxxxxxxx.md 번역 시작함."
  $ git push origin rails-guides
  ```
 
5. 이제 브라우저 상에서 github 본인계정 상의 rails-guides 저장소로 이동한 후 `pull request"을 작성한다. 


## 번역 작업시 자동으로 html 파일 빌드하기

파일 수정시마다 커맨드라인에서 html 파일을 빌드하는 것은 매우 번거롭습니다. `guard-shell` 젬을 이용하면 파일 변경시마다 자동으로 빌드과정을 수행할 수 있습니다. 

1. `rails-guides` 디렉토리의 `Gemfile`을 열고 하단에 `guard-shell` 젬을 추가한다. 
  
  ```bash
  $ cd rails-guides
  $ vi Gemfile
  gem 'guard-shell'
  ```

<<<<<<< HEAD
2. 이어서 번들 설치한다.
=======
4. Using a browser, go to `http://localhost:3000` and you'll see:
"Yay! You’re on Rails!"
>>>>>>> master

  ```bash
  $ bundle install
  ```
  
3. `Guardfile`을 생성하기 위해 아래와 같이 명령을 실행한다. 

  ```bash
  $ cd guides
  $ guard init shell
  ```
 
4.  생성된 `Guardfile`을 에디터로 열고 아래와 같이 추가해 준다. 

  ```ruby
   guard :shell do
      watch(/(.*).md/) { system("rake guides:generate:html:ko")}
  end
  ```
  
5. `rails-guides/guides` 디렉토리에서 아래와 같이 실행한다.

  ```bash
  $ cd rails-guides/guides
  $ bundle exec guard
  ```
  
6. 이제 번역 작업 중인 마크다운 파일을 변경하게 되면 자동으로 html 빌드를 위한 `rake` 태스크가 자동으로 실행된다. 

  ```bash
  $ bundle exec guard
  10:12:50 - INFO - Guard is now watching at '/Users/{user-account}/.../rails-guides/guides'
  /Users/{user-account}/.rbenv/versions/2.2.0/bin/ruby rails_guides.rb
  Generating 4_2_release_notes.md as 4_2_release_notes.html
  [1] guard(main)>_
  ```


## 기여하기

누구라도 번역에 참가 할 수 있습니다. guides/source/ko 하위의 파일들을 번역후 `guides-ko` 브랜치에 풀리퀘스트 하면됩니다.

## 빌드 상태

[![Build Status](https://travis-ci.org/rorlakr/rails-guides.svg?branch=guides-ko)](https://travis-ci.org/rorlakr/rails-guides)

## License

레일스 가이드는 [Creative Commons Attribution-ShareAlike 4.0 International](update license as same as origin repository) License로 배포되고 있습니다.