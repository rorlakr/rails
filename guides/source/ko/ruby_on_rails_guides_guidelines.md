**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON http://guides.rubyonrails.org.**

Ruby on Rails 가이드를 위한 가이드라인
===============================

이 가이드는 Ruby on Rails 가이드를 작성하기 위한 가이드라인 입니다. 이 가이드 자체가 이 가이드에 따라서 작성되었으며, 바람직한 가이드라인의 예가 됨과 동시에 우아한 루프를 형성하고 있습니다.

이 가이드의 내용:

* Rails 문서의 기술
* 가이드를 로컬에서 생성하기

--------------------------------------------------------------------------------

마크다운
-------

가이드는 [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown)으로 작성되어 있습니다. 이 가이드는 [마크다운 문서](http://daringfireball.net/projects/markdown/syntax) 뿐만 아니라, [치트시트](http://daringfireball.net/projects/markdown/basics)의 내용도 포함하고 있습니다.

프롤로그
--------

가이드의 시작 부분에는 독자들의 동기부여를 위한 내용을 기술해주세요. 가이드의 파란색 부분이 이에 해당합니다. 프롤로그에서는 그 가이드의 개요와 가이드에서 배울 수 있는 것들에 대해서 설명해주세요. 예제로서 [라우팅 가이드](routing.html)을 참고해주세요.

제목
------

가이드의 제목에는 `h1`, 가이드의 절에는 `h2`, 작은 절에는 `h3`를 각각 사용해주세요. 그리고 실제로 생성된 HTML에서는 `<h2>`부터 시작됩니다.

```
가이드의 제목
===========

절
-------

### 작은 절
```

제목을 작성할 때 관사, 전치사, 접속사, be동사 이외의 단어는 모두 대문자로 시작해주세요.

```
#### Middleware Stack is an Array
#### When are Objects Saved?
```

일반 텍스트와 같은 스타일을 사용해주세요.

```
##### `:content_type` 옵션
```

API에 링크
------------------

가이드 제너레이터로 API(`api.rubyonrails.org`) 링크는 다음과 같은 방법으로 처리됩니다.

릴리즈 태그를 포함하지 않은 링크들은 그대로 유지됩니다. 예를 들면

```
http://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

는 수정되지 않습니다.

생성된 문서에 상관없이 동일한 버전을 가리켜야 하기 때문에, 릴리즈 노트에 있는 링크들을 사용해주세요.

릴리즈 태그와 edge 가이드를 포함하고 있지 않은 링크가 만약 생성 된다면, 도메인은 `edgeapi.rubyonrails.org`로 수정됩니다. 예를 들면

```
http://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

위 링크가 아래와 같이 됩니다.

```
http://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

릴리즈 태그와 릴리즈 가이드를 포함하고 있지 않는 링크가 생성되면 레일즈 버젼이 추가됩니다. 예를 들어 v5.1.0 버젼 가이드를 생성하면

```
http://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

위 링크가 아래와 같이 됩니다.

```
http://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

`edgeapi.rubyonrails.org`를 직접 링크하지 마세요.


API 문서 가이드라인
----------------------------

가이드와 API는 적절한 일관성이 있어야 합니다. [API 문서 가이드라인](api_documentation_guidelines.html)의 다음 절을 참고해주세요. 이 절은 가이드에서도 적용됩니다.

* [Wording](api_documentation_guidelines.html#wording)
* [English](api_documentation_guidelines.html#english)
* [Example Code](api_documentation_guidelines.html#example-code)
* [Filenames](api_documentation_guidelines.html#file-names)
* [Fonts](api_documentation_guidelines.html#fonts)

HTML 가이드
-----------

가이드를 생성하기 전에 시스템에 최신 Bundler가 설치되었는지 확인하세요.
 현시점에서는 1.3.5 이상이 설치되어있어야 
합니다.

최신 Bundler를 설치하려면 `gem install bundler`를 실행해주세요.

### 생성

모든 가이드를 생성하려면 `cd` 명령으로 `guides` 디렉토리에 이동하여 `bundle install`를 실행한 뒤에 다음 중 하나를 실행합니다.

```
bundle exec rake guides:generate
```

또는

```
bundle exec rake guides:generate:html
```

HTML파일의 결과는 `./output`디렉토리에서 찾을 수 있습니다.

`my_guide.md` 파일만을 생성하고 싶은 경우에는 환경변수 `ONLY`를 사용합니다.

```
touch my_guide.md
bundle exec rake guides:generate ONLY=my_guide
```

기본적으로는 변경이 없는 가이드의 생성은 생략되므로 `ONLY`를 사용할 기회는 많지 않을 것입니다.

모든 가이드를 강제적으로 생성하려면 `ALL=1`를 추가하면 됩니다

영어 이외의 언어에서 생성하고 싶은 경우에는 `source` 폴더 밑의 `source/es`와 같이 해당 언어의 폴더를 생성하고 `GUIDES_LANGUAGE` 환경변수를 설정해주세요.

```
bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

생성 스크립트의 설정에 사용할 수 있는 환경변수를 모두 알고 싶은 경우에는 다음을 실행하면 됩니다.

```
rake
```

### 검증

생성된 HTML을 검증하기 위해 다음을 실행하세요.

```
bundle exec rake guides:validate
```

콘텐츠에서 생성된 아이디로 얻은 제목은 종종 중복이 발생합니다. 중복을 찾기 위해서는 가이드를 생성할 때에 `WARNINGS=1`를 지정해주세요. 경고와 함께 해결할 방법을 제안합니다.

Kindle 가이드
-------------

### 생성

Kindle 용 가이드를 생성하기 위해서 다음의 rake 태스크를 실행해주세요.

```
bundle exec rake guides:generate:kindle
```
