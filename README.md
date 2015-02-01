## 레일스 가이드 한글 번역

가이드 번역 관련된 사항은 `guides-ko` 브랜치에서만 작업합니다. `master` 브랜치는 `rails/rails` 와의 동기화를 위한것으로 이곳에 직접 커밋하거나 풀리퀘스트 하지 않습니다.

## 번역 파일 생성 하기

```
$ cd guides
$ bundle exec rake guides:generate:html:ko ALL=1
```

`ALL=1` 옵션을 붙이지 않으면 변경된 파일만 생성

### 배포하기

```
$ bundle exec rake guides:generate:html:ko:publish ALL=1
```

## 번역 기여하기

누구라도 번역에 참가 할 수 있습니다. guides/source/ko 하위의 파일들을 번역후 `guides-ko` 브랜치에 풀리퀘스트 하면됩니다.

## 빌드 상태

[![Build Status](https://travis-ci.org/rorlakr/rails-guides.svg?branch=guides-ko)](https://travis-ci.org/rorlakr/rails-guides)

## License

Ruby on Rails is released under the [MIT License](http://www.opensource.org/licenses/MIT).
