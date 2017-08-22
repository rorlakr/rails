
Asset Pipeline
==================

이 가이드에서는 애셋 파이프라인(asset pipeline)에 대해서 설명합니다.

이 가이드의 내용:

* 애셋 파이프라인의 개요와 기능
* 애셋 파이프라인의 올바른 구성 방법
* 애셋 파이프라인의 장점
* 애셋 파이프라인에 전처리기를 추가하는 방법
* 애셋을 gem으로 만드는 방법

--------------------------------------------------------------------------------

애셋 파이프라인에 대해서
---------------------------

애셋 파이프라인이란 JavaScript나 CSS 애셋을 최소화(minify: 공백이나 개행 등을
제거) 또는 압축하여 연결하는 프레임워크입니다. 애셋 파이프라인에서는
CoffeeScript나 SASS, ERB 등의 다른 언어로 기술된 애셋을 생성하는 기능을 추가할
수도 있습니다.
거기에 다른 젬들로부터 애셋을 자동으로 애플리케이션에 결합해주기도 합니다.
예를 들어, jquery-rails는 jquery.js의 사본을 가지고 있으며 Rails에서 AJAX
기능을 사용할 수 있게 해줍니다.

애셋 파이프라인은 [sprockets-rails](https://github.com/rails/sprockets-rails)
잼으로 구현되어 있으며, 새 앱을 만들때 기본으로 포함됩니다. 이를 비활성화하고
싶은 경우에는 아래와 같이 `--skip-sprockets` 를 넘겨주세요.

```bash
rails new appname --skip-sprockets
```

Rails에서는 `sass-rails`, `coffee-rails`, `uglifier` gem이 자동적으로 Gemfile에
추가됩니다. Sprokets는 애셋을 압축할 때 이 gem들을 사용합니다.

```ruby
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
```

`--skip-sprockets` 옵션을 사용하면 Rails는 이러한 젬들을 Gemfile에 추가하지
않습니다. 그러므로 애셋 파이프라인을 나중에 활성화하고 싶은 경우에는 이 젬들을
Gemfile에 다시 추가해주어야 합니다. 마찬가지로 애플리케이션을 새로 생성할 경우
`--skip-sprockets` 옵션을 사용하면 `config/application.rb` 파일의 내용물이 약간
변경됩니다. 구체적으로는 sproket railtie에서 필요로하는 내용들이
주석처리됩니다. 애셋 파이프라인을 수동으로 활성화하는 경우에는 이러한
주석처리 된 코드들을 찾아서 주석처리를 해제해주어야 합니다.

```ruby
# require "sprockets/railtie"
```

애셋 압축 방식을 지정하려면 `production.rb`에 존재하는 해당하는 설정을
찾습니다. `config.assets.css_compressor`로는 CSS 압축 방식,
`config.assets.js_compressor`로는 JavaScript의 압축 방식을 각각 지정할 수
있습니다.

```ruby
config.assets.css_compressor = :yui
config.assets.js_compressor = :uglifier
```

NOTE: `sass-rails` gem이 Gemfile에 포함되어 있다면 자동적으로 CSS 압축에
사용됩니다. 이러한 경우 `config.assets.css_compressor` 옵션은 지정되지
않습니다.


### 주요한 기능

애셋 파이프라인의 첫번째 기능은 애셋을 연결하는 것입니다. 이를 통해 브라우저가
웹페이지를 랜더링하기 위해서 서버에 보내야하는 HTTP 요청의 숫자를 줄일 수
있습니다. 웹 브라우저가 동시에 처리할 수 있는 요청 수에는 제한이 있으므로,
동시 요청수를 줄일 수 있다면 그만큼 페이지를 로딩하는 속도가 빨라집니다.

Sprockets은 모든 JavaScript 파일을 하나의 마스터 `.js` 파일로 연결하고, 모든
CSS 파일을 하나의 마스터 `.css` 파일로 연결합니다. 이 가이드에서 나중에
설명하겠지만, 애셋 파일을 그룹으로 묶는 방법은 자유롭게 변경할 수 있습니다.
production 환경에서는 애셋 파일명에 MD5 핑거프린트를 삽입하여 애셋 파일이
웹 브라우저에서 캐싱되도록 합니다. 핑거프린트의 변경은 애셋 파일의 내용물이
변경되었을 때에 자동적으로 이루어집니다.

애셋 파이프라인의 또 다른 기능은 애셋의 최소화(압축)입니다. CSS파일의 최소화는
공백과 주석을 제거하는 것으로 이루어집니다. JavaScript의 압축 프로세스는 이보다
더 복잡합니다. 이 때 사용할 방법은 내장된 옵션으로부터 선택하거나 다른 것을
지정할 수 있습니다.

애셋 파이프라인의 3번째 기능은 보다 고도의 언어를 사용한 코딩을 지원하는
것입니다. 이러한 언어로 작성된 코드는 전처리되어 실제 애셋이 됩니다.
기본으로 지원되는 언어는 CSS로 변환되는 SASS, JavaScript로 변환되는
CoffeeScript, CSS/JavaScript로 변환되는 ERB입니다.

### 핑거프린트와 주의점

애셋 파일명으로 사용되는 핑거프린트는 애셋 파일의 내용에 따라 변경됩니다. 애셋 파일의 내용이 조금이라도 변경되면, 애셋 파일의 이름도 반드시 그에 따라 변경됩니다(역주: MD5의 성질에 따라 다른 파일로부터 가끔 같은 핑거프린트가 생성될 가능성의 극히 적습니다). 변경되지 않은 파일이나 변경될 일이 거의 없는 파일이 있는 경우, 핑거프린트도 변경되지 않으므로 파일의 내용이 완전히 동일하다는 것을 쉽게 확인할 수 있습니다. 이것은 서버나 배포하는 서버가 다른 경우에도 마찬가지입니다.

애셋 파일 이름은 내용 변경에 따라서 반드시 변화하므로 CDN, ISP, 네트워크 기기, 웹브라우저 등 모든 곳에서 유효한 캐시를 HTTP 헤더에 지정할 수도 있습니다. 파일의 내용이 변경되면 핑거프린트도 변경됩니다. 이에 따라서 원격 클리아언트(역주: 기존의 캐시를 사용하지 않고)는 새 컨텐츠를 서버에 요청할 수 있습니다. 이 방법을 일반적으로 _캐시 파기(cache busting)_라고 부릅니다.

Sprockets가 핑거프린트를 사용하는 경우에는 파일의 내용을 해싱한뒤 파일명(보통 어미)에 추가합니다. 예를 들자면 `global.css`라는 CSS 파일 이름은 다음과 같이 생성됩니다.

```
global-908e25f4bf641868d8683022a5b62f54.css
```

이것은 Rails의 애셋 파이프라인의 전략으로서 채용되어 있습니다.

이전 Rails에서는 내장된 헬퍼에 링크된 모든 애셋에 날짜 기반의 쿼리 문자열을 추가하는 전략을 사용했었습니다. 당시의 소스로 생성된 코드는 다음과 같습니다.

```
/stylesheets/global.css?1309495796
```

이 쿼리 문자열 기반의 전략에는 많은 문제가 있습니다.

1. **쿼리 파라미터만 다른 컨텐츠는 안정적으로 캐싱이 되지 않는다**

    [Steve Souders의 글](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)에 의하면 '캐싱될 가능성이 있는 리소스를 쿼리 문자열을 사용해서 접근하지 말 것'이라고 권장하고 있습니다. Steve는 5%에서 20%의 요청이 캐시를 사용하지 않는다는 사실을 발견했습니다. 또한 쿼리 문자열은 캐시를 무효화하는 몇몇 CDN에서도 동작하지 않습니다.

2. **멀티 서버 환경에서 파일명이 다를 경우가 있다**

    Rails 2.x의 기본 쿼리 문자열은 파일의 갱신 날짜에 기반하고 있었습니다. 이 애셋을 서버 클러스터에 배포하게되면, 서버간에 파일의 타임스탬프가 동일할 것이라는 보장이 없으므로, 요청을 받는 서버가 바뀔 때마다 쿼리문자열이 다를 수 있습니다.

3. **캐시 무효화가 과도하게 발생한다**

    코드 릴리즈 시에 새 애셋이 배포되면 애셋에 변경이 있었는지 없었는지에 관계 없이, _모든_ 파일의 mtime(마지막으로 갱신된 시각)이 변경됩니다. 이 때문에 웹 브라우저를 포함한 모든 원격 클라이언트에서는 강제적으로 애셋을 다시 요청하게 됩니다.

핑거프린트가 도입되어 위에서 설명한 쿼리 문자열로 인한 문제가 해결되었으며, 애셋의 내용이 같다면 파일명도 언제나 동일하게 되었습니다.

핑거프린트는 production 환경에서는 기본적으로 활성화되어 있으며, 그 이외의 환경에서는 꺼져 있습니다. 설정 파일에서 `config.assets.digest` 옵션을 사용해서 핑거프린트를 활성화/비활성화할 수 있습니다.

자세한 설명은 아래의 링크를 참조해주세요.

* [캐시의 최적화](http://code.google.com/speed/page-speed/docs/caching.html)
* [파일명의 변경에 쿼리 문자열을 사용해서는 안되는 이유](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)


애셋 파이프라인을 사용하는 방법
-----------------------------

이전의 Rails에서는 모든 애셋은 `public` 폴더 밑의 `images`, `javascripts`, `stylesheets` 등의 하위 폴더에 저장했었습니다. 애셋 파이프라인의 도입 이후에는 `app/assets` 폴더가 애셋을 저장하는 위치로 권장되고 있습니다. 이 디렉토리에 저장되어 있는 파일들은 Sprockets 미들웨어에 의해서 제공됩니다.

여전히 애셋은 `public` 폴더에서 제공할 수도 있습니다. `config.serve_static_assets`이 true로 설정되어 있다면 `public` 폴더에 위치한 모든 애셋은 애플리케이션 또는 웹 서버에 의해서 정적인 파일로서 취급됩니다. 전처리가 필요한 파일은 `app/assets` 폴더에 저장해야할 필요가 있습니다.

Rails는 production 환경에서는 기본적으로 `public/assets` 파일을 미리 컴파일합니다. 이 컴파일된 파일이 웹 서버에 의해서 정적인 애셋으로서 취급됩니다. `app/assets`에 위치한 파일들이 있는 그대로 production 환경에서 사용되는 일은 결코 없습니다.

### 컨트롤러 전용 애셋

Rails에서 scaffold나 컨트롤러를 생성하면 JavaScript 파일(`coffee-rails` gem이 `Gemfile`에 포함되어 있는 경우에는 CoffeeScript)과 CSS(`sass-rails` gem이 `Gemfile`에 포함되어 있는 경우에는 SCSS)도 컨트롤러 전용으로 생성됩니다. scaffold를 생성하는 경우에는 scaffolds.css(`sass-rails` gem이 `Gemfile`에 포함되어 있는 경우에는 scaffolds.css.scss)도 생성됩니다.

예를 들어 `ProjectsController`를 생성하면 `app/assets/javascripts/projects.js.coffee`파일과 `app/assets/stylesheets/projects.css.scss` 파일이 새롭게 생성됩니다. `require_tree` 디렉티브를 사용하면 이 파일을 바로 애플리케이션에서 사용할 수 있습니다. require_tree의 자세한 설명은 [매니페스트 파일과 디렉티브](#매니페스트-파일과-디렉티브)를 참고해주세요.

관련된 컨트롤러에서 아래의 코드를 추가하여 컨트롤러 고유의 스타일 시트나 JavaScript 파일을 그 컨트롤러에서만 사용할 수 있습니다.

`<%= javascript_include_tag params[:controller] %>` 또는 `<%= stylesheet_link_tag params[:controller] %>`

이 코드를 사용할 때에는 `require_tree` 디렉티브를 사용하지 않았는지 확인해주세요. `require_tree`를 함께 사용하게되면 애셋을 2번 이상 포함하게 됩니다.

WARNING: 애셋을 미리 컴파일하는 경우, 페이지가 로드될 때마다 컨트롤러의 애셋이 미리 컴파일되도록 해두어야 합니다. 기본으로는 `.coffee` 파일과 `.scss` 파일은 자동으로 컴파일되지 않습니다. 이 동작에 대해서는 [애셋을 미리 컴파일하기](#애셋을-미리-컴파일하기)를 참조해주세요.

NOTE: CoffeeScript를 사용하려면 ExecJS가 런타임으로 지원되어야 합니다. Mac OS X 또는 Windows를 사용하는 경우에는 OS에 JavaScript 런타임을 설치해주세요. 지원되는 모든 JavaScript 런타임에 대한 설명은 [ExecJS](https://github.com/sstephenson/execjs#readme)에서 확인 할 수 있습니다.

`config/application.rb` 설정에 아래를 추가하여 컨트롤러 전용의 애셋 파일을 생성하지 않을 수도 있습니다.

```ruby
config.generators do |g|
  g.assets false
end 
```

### `애셋을 구성하기`

파이프라인의 애셋은 애플리케이션의 `app/assets`, `lib/assets`, `vendor/assets` 중 어딘가에 저장할 수 있습니다.

* `app/assets`에는 커스텀 이미지, JavaScript, 스타일시트 등, 애플리케이션 자신이 관리하는 애셋을 저장합니다.

* `lib/assets`에는 1개의 애플리케이션의 범주에 포함되지 않는 라이브러리의 코드나, 복수의 애플리케이션에서 공유되는 라이브러리 코드를 저장합니다.

* `vendor/assets`는 JavaScript 플러그인이나 CSS 프레임워크 등, 외부의 단체 등이 관리하는 애셋을 저장합니다.

WARNING: Rails 3으로부터 업그레이드를 하는 경우에는 `lib/assets`과 `vendor/assets`에 저장되어 있는 애셋이 Rails에서는 애플리케이션의 매니페스트에 의해서 포함되어 사용가능하다는 점, 단 미리 컴파일될 파일 목록에는 포함되지 않게 되었다는 점을 주의해주세요. 더 자세한 안내는 [애셋을 미리 컴파일하기](#애셋을-미리-컴파일하기)를 참조해주세요.

#### 경로 탐색

파일이 매니페스트나 헬퍼에서 참조되고 있는 경우, Sprockets는 애셋이 저장되어 있는 3개의 폴더로부터 파일을 찾습니다.

3개의 폴더란 `app/assets`에 있는 `images`, `javascripts`, `stylesheets` 폴더입니다. 단 이 하위 폴더들이 특별한 것이 아니라, 실제로는 `assets/*`에 맞는 모든 경로가 검색 대상이 됩니다.

아래는 파일의 목록입니다.

```
app/assets/javascripts/home.js
lib/assets/javascripts/moovinator.js
vendor/assets/javascripts/slider.js
vendor/assets/somepackage/phonebox.js
```

이 파일은 매니페스트에서 다음과 같이 참조가능합니다.

```js
//= require home
//= require moovinator
//= require slider
//= require phonebox
```

하위 폴더에 있는 애셋에도 접근할 수 있습니다.

```
app/assets/javascripts/sub/something.js
```

이 파일은 다음과 같이 참조할 수 있습니다.

```js
//= require sub/something
```

검색 경로를 확인하려면, Rails 콘솔에서 `Rails.application.config.assets.paths`를 확인하세요.

파이프라인에 `assets/*`에 더하여 다른 경로를 검색하고 싶은 경우에는 `config/application.rb`에서 경로를 추가할 수 있습니다. 아래는 예시입니다.

```ruby
config.assets.paths << Rails.root.join("lib", "videoplayer", "flash")
```

경로의 탐색은 탐색 경로 목록의 순서대로 이루어집니다. 기본으로는 `app/assets`의 탐색이 우선되므로 대응하는 경로가 `lib`나 `vendor`에 있는 경우에는 무시됩니다.

여기서 주의해야 할 것은, 참조하고 싶은 파일이 매니페스트의 바깥에 존재하는 경우, 그 것들을 미리 컴파일할 목록에 추가해야한다는 점, 그리고 이들은 production에서는 사용할 수 없다는 점입니다.

#### index 파일을 사용하기

Sprockets에서는 `index`라는 이름의 파일(그리고 관련된 확장자)를 특수한 목적으로 사용하고 있습니다.

예를 들자면 많은 모듈이 있는 jQuery 라이브러리를 사용하고 있고, 그것이 `lib/assets/javascripts/library_name`에 저장되어 있다고 가정합시다. 이 `lib/assets/javascripts/library_name/index.js` 파일은 그 라이브러리 내의 모든 파일에서 이용할 수 있는 매니페스트로서 기능을 합니다. 이 파일에는 필요한 파일을 모두 순서대로 적거나, 또는 단순히 `require_tree`로 작성할 수 있습니다.

일반적으로 이 라이브러리는 애플리케이션 매니페스트에는 다음과 같이 작성하여 사용할 수 있습니다.

```js
//= require library_name
```

이렇게 작성하여 다른 곳에서 사용하기 전에 코드를 그룹으로 묶을 수 있어, 작성이 보다 간결하고 변경이 용이하게 됩니다.

### 애셋을 연결하는 코드를 작성하기

Sprockets은 애셋을 사용하기 위한 메소드를 추가해주지 않습니다. 익숙한 `javascript_include_tag`와 `stylesheet_link_tag`를 계속 사용할 수 있습니다.

```erb
<%= stylesheet_link_tag "application", media: "all" %>
<%= javascript_include_tag "application" %>
```

Rails부터 포함되는 turbolinks gem를 사용하고 있는 경우, 'data-turbolinks-track' 옵션을 사용할 수 있습니다. 이것은 애셋이 갱신되어 페이지에 로딩되었는지 아닌지 turbolinks가 확인합니다.

```erb
<%= stylesheet_link_tag "application", media: "all", "data-turbolinks-track" => "reload" %>
<%= javascript_include_tag "application", "data-turbolinks-track" => "reload" %>
```

일반적인 뷰에서는 아래와 같은 방법으로 `public/assets/images` 폴더의 이미지에 접근할 수 있습니다.

```erb
<%= image_tag "rails.png" %>
```

파이프라인을 사용하고, 현재 환경에서 무효가 아닌 경우, 이 파일은 Sprockets이 처리하게 됩니다. 파일이 `public/assets/rails.png`에 위치하는 경우, 웹 서버에 의해서 처리됩니다.

`public/assets/rails-af27b6a414e6da00003503148be9b409.png` 등, 파일 이름에 MD5 해시를 포함하는 파일 이름에 대한 요청도 동일하게 다루어집니다. 해시의 생성 방법에 대해서는 이 가이드의 [production 환경의 경우](#production-환경의-경우)에서 설명합니다.

Sprockets는 `config.assets.paths`에서 지정한 경로도 탐색합니다. 이 경로에는 일반적인 애플리케이션 경로와 Rails 엔진에 의해서 추가된 모든 경로가 포함됩니다.

필요하다면 이미지 파일을 하위 폴더에서 정리해둘 수도 있습니다. 이 이미지에 접근하려면 폴더명을 포함하여 아래와 같이 태그로 지정하면 됩니다.

```erb
<%= image_tag "icons/rails.png" %>
```

WARNING: 애셋을 미리 컴파일 하는 경우([production 환경의 경우](#production-환경의-경우) 참조), 존재하지 않는 애셋에 대한 링크를 포함한 페이지를 호출하면, 예외가 발생합니다. 빈 문자열로 된 링크도 마찬가지로 예외가 발생합니다. 사용자로부터 제공된 데이터를 사용해서 `image_tag` 등의 헬퍼를 사용하는 경우에는 주의해주세요.

#### CSS와 ERB 

애셋 파이프라인은 자동적으로 ERB를 평가합니다. 예를 들자면 css 애셋 파일에 `erb`라는 확장자를 추가하면 (`application.css.erb` 등), CSS 규칙 내에서 `asset_path` 등의 헬퍼를 사용할 수 있습니다.

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

이것은 지정된 애셋에 대한 경로를 출력합니다. 이 예제에서는 애셋을 읽어와서 경로의 어딘가에 이미지 파일(`app/assets/images/image.png` 등)이 지정된다고 해석할 수 있습니다. 이 이미지가 이미 핑거프린트가 추가되어 있고 `public/assets`에 저장되어 있다면 이 경로에 대한 참조는 유효합니다.

[데이터 URI 스킴](https://en.wikipedia.org/wiki/Data_URI_scheme) (CSS 파일에 데이터를 직접 포함하는 방법)을 사용하고 싶은 경우에는 `asset_data_uri`를 사용하세요.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

이 코드는 CSS 소스에 올바른 형식으로 변경된 data URI를 삽입합니다.

이 경우 `-%>`로 태그를 닫을 수 없으므로 주의해주세요.

#### CSS와 Sass

애셋 파이프라인을 사용하는 경우, 최종적으로 애셋에 대한 경로를 변환할 필요가 있습니다. 이를 위해서
`sass-rails` gem은 이름이 `-url`이나 `-path`로 끝나는 (Sass에서는 하이픈입니다만, Ruby에서는 언더스코어를 사용합니다) 각종 헬퍼를 제공합니다. 헬퍼가 서포트하는 애셋 클래스는 이미지, 폰트, 비디오, 음성, JavaScript, 스타일시트 입니다.

* `image-url("rails.png")`는 `url(/assets/rails.png)`로 변환됩니다.
* `image-path("rails.png")`는 `"/assets/rails.png"`로 변환됩니다.

아래와 같은 좀 더 일반적인 기법을 사용할 수도 있습니다.

* `asset-url("rails.png")`는 `url(/assets/rails.png)`로 변환됩니다.
* `asset-path("rails.png")`는 `"/assets/rails.png"`로 변환됩니다.

#### JavaScript/CoffeeScript와 ERB

JavaScript 애셋에 `erb` 확장자를 추가하면 (`application.js.erb` 등), 아래와 같이 JavaScript 코드 상에서 `asset_path` 헬퍼를 사용할 수 있습니다.

```js
$('#logo').attr({ src: "<%= asset_path('logo.png') %>" });
```

이는 지정된 애셋에 대한 경로를 출력합니다.

CoffeeScript 파일에서도 `application.js.coffee.erb`와 같이 `erb` 확장자를 추가하여 마찬가지로 `asset_path` 헬퍼를 사용할 수 있습니다.

```js
$('#logo').attr src: "<%= asset_path('logo.png') %>"
```

### 매니페스트와 디렉티브

Sprockets에서는 어떤 애셋을 가져와서 지원할지를 지정할 때에 매니페스트 파일을 사용합니다. 매니페스트 파일에는 _디렉티브(directive)_가 포함되어 있습니다. 디렉티브를 사용하여 필요한 파일을 지정하고, 거기에 기반하여 최종적인 단일 CSS나 JavaScript 파일이 생성됩니다. Sprockets는 디렉티브로 지정된 파일을 읽어와, 필요에 따라서 처리를 하고 연결하여 단일 파일을 생성하여 압축해줍니다(`Rails.application.config.assets.compress`가 true인 경우). 파일을 연결하여 하나로 만드는 것으로 브라우저로부터 서버에 대한 요청 횟수를 줄일 수 있으며, 압축을 통해서 파일 사이즈도 줄여서 페이지를 읽어오는데 걸리는 시간을 대폭 단축시킵니다.

새로 생성한 Rails 애플리케이션에서는 기본으로 `app/assets/javascripts/application.js` 파일에 다음과 같은 내용이 포함되어 있습니다.

```js
// ...
//= require jquery
//= require jquery_ujs
//= require_tree .
```

JavaScript의 Sprockets 디렉티브는 `//=`로 시작됩니다. 이 예제에서는 `require`와 `require_tree`라는 디렉티브가 사용되고 있습니다. `require`는 필요한 파일을 Sprockets에 지정할 때에 사용합니다. 여기에서는 `jquery.js`와 `jquery_ujs.js`를 필요한 파일로 지정하고 있습니다. 이러한 파일은 Sprockets의 검색 경로의 어딘가로부터 불러오게 됩니다. 이 디렉티브에서는 확장자를 명시적으로 지정할 필요가 없습니다. 디렉티브가 `.js` 파일에 선언되었다면 Sprockets에 의해서 자동적으로 `.js` 파일이 필요한 파일로 지정됩니다.

`require_tree` 디렉티브는 지정된 폴더 밑에 있는 _모든_ JavaScript 파일을 재귀적으로 출력에 포함합니다. 이 경로는 매니페스트 파일로부터의 상대 경로를 지정해야합니다. `require_directory` 디렉티브를 사용하면 지정된 폴더에 저장되어 있는 모든 JavaScript 파일을 포함합니다. 이 경우, 하위 폴더를 재귀적으로 탐색하지 않습니다.

디렉티브는 적혀있는 순서대로 실행됩니다만, `require_tree`로 포함된 파일들을 불러오는 순서를 지정할 수는 없습니다. 따라서, 코드를 불러오는 순서에 의존하지 않도록 작성할 필요가 있습니다. 만약 어떤 이유가 있어서 특정 JavaScript 파일을 다른 JavaScript 파일보다 먼저 불러오고 싶은 경우에는 그 파일의 require 디렉티브를 매니페스트의 첫번째에 위치시킵니다. `require`, 그리고 비슷한 디렉티브는 출력시에 같은 파일을 2회 이상 포함하지 않도록 한다는 점을 기억해두세요.

Rails는 아래의 내용을 포함하는 `app/assets/stylesheets/application.css` 파일을 생성합니다.

```css
/* ...
*= require_self
*= require_tree .
*/
```

Rails는 `app/assets/javascripts/application.js`와 `app/assets/stylesheets/application.css` 파일을 둘 다 생성합니다. 이것은 Rails 애플리케이션을 새로 생성할 때의 `--skip-sprockets`와는 관계 없이 실행됩니다. 이에 따라 필요에 따라 손쉽게 애셋 파이프라인을 추가할 수도 있습니다.

JavaScript에서 사용할 수 있는 디렉티브는 스타일시트에서도 사용할 수 있습니다(그러나 JavaScript와 다르게 스타일시트는 명시적으로 포함된다는 점이 다릅니다). CSS 매니페스트에서의 `require_tree` 디렉티브의 동작은 JavaScript의 경우와 마찬가지로 지정된 폴더에 있는 모든 스타일시트를 require합니다.

이 예제에서는 `require_self`가 사용되고 있습니다. 이 디렉티브는 `require_self` 호출이 있었던 곳에 css 파일이 있다면 불러옵니다.

NOTE: Sass 파일을 여러개 사용하고 사용하고 있는 경우라면 Sprockets 디렉티브 대신에 [Sass `@import` 규칙](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#import)을 사용할 필요가 있습니다. 이러한 경우에 Sprockets 디렉티브를 사용하게 되면, Sass 파일이 자기 자신을 스코프에 넣게 되므로, 그 내부에서 정의되어 있는 변수나 믹스인을 다른 Sass에서 사용할 수 없게 됩니다.

`@import "*"`나 `@import "**/*"`처럼 와일드카드 매칭으로 트리 전체를 지정할 수도 있습니다. 이거승ㄴ `require_tree`와 동등한 동작을 합니다. 자세한 설명과 주의점에 대해서는 [sass-rails 문서](https://github.com/rails/sass-rails#features)를 참조해주세요.

매니페스트 파일은 필요에 따라서 몇개든 사용할 수 있습니다. 예를 들어 애플리케이션의 admin 섹션에서 사용하는 JS파일과 CSS파일을 `admin.css`와 `admin.js` 매니페스트로 각각 따로 작성할 수도 있습니다.

읽어오는 순서는 위에서 말한 방식이 적용됩니다. 특히, 개별로 지정한 파일들은 그 순서대로 컴파일 됩니다. 예를 들어, 다음과 같이 3개의 CSS파일을 결합할 수 있습니다.

```js
/* ...
*= require reset
*= require layout
*= require chrome
*/
```

### 전처리

적용되는 전처리의 종류는 애셋 파일의 확장자에 의해서 결정됩니다. 컨트롤러나 scaffold를 기본 gem으로 생성한 경우 Javascript 파일이나 CSS파일이 위치한 곳에 CoffeeScript 파일과 SCSS 파일이 각각 생성됩니다. 위에서 보인 예제에서는 컨트롤러의 이름이 "projects"이고, `app/assets/javascripts/projects.js.coffee` 파일과 `app/assets/stylesheets/projects.css.scss` 파일이 생성됩니다.

development 환경의 경우 또는 애셋 파이프라인이 유효하지 않은 경우에는 이 애셋에 대한 요청은 `coffee-script` gem과 `sass` gem이 제공하는 처리기에 의해서 처리되며, 각각 JavaScript와 CSS로 변환되어 브라우저로 전송됩니다. 애셋 파이프라인이 활성화 되어 있는 경우에는 이러한 애셋 파일들은 전처리의 대상이 되며, 처리된 파일이 `public/assets` 폴더에 위치하여 Rails 애플리케이션이나 웹서버에 의해서 처리됩니다.

애셋 파일 이름에 다른 확장자를 추가하여 전처리시에 레이어를 추가하여 요청할 수 있습니다. 애셋 파일 이름의 확장자는 '오른쪽에서 왼쪽'의 순서로 처리됩니다. 따라서 애셋 파일명의 확장자는 이에 따라, 처리를 해야하는 순서대로 구성되어야 합니다. 예를 들어, `app/assets/stylesheets/projects.css.scss.erb`라는 스타일시트에서는 처음에 ERB로 처리되며, 이어서 SCSS, 마지막으로 CSS로 처리됩니다. 마찬가지로 `app/assets/javascripts/projects.js.coffee.erb`라는 JavaScript 파일의 경우에는 ERB → CoffeeScript → JavaScript의 순서대로 처리가 진행됩니다.

이 전처리 순서는 무척 중요하므로, 잘 기억해두세요. 예를 들어, `app/assets/javascripts/projects.js.erb.coffee`라는 파일을 호출하면 처음에 CoffeeScript 인터프리터에 의해서 처리됩니다. 하지만 처리된 코드는 다음의 ERB가 처리할 수 없는 경우가 있으므로 문제가 발생할 수 있습니다.

development 환경의 경우
--------------

development 환경의 경우, 애셋은 각각의 파일로서 매니페스트 파일에 기재되어 있는 순서대로 불러와집니다.

`app/assets/javascripts/application.js`라는 매니페스트의 내용이 아래와 같다고 가정합니다.

```js
//= require core
//= require projects
//= require tickets
```

이에 의해서 다음의 HTML이 생성됩니다.

```html
<script src="/assets/core.js?body=1"></script>
<script src="/assets/projects.js?body=1"></script>
<script src="/assets/tickets.js?body=1"></script>
```

`body` 파라미터는 Sprockets에서 사용됩니다.

### 런타임 에러를 체크하기

애셋 파이프라인은 development 환경에서 런타임 시의 에러를 항시 확인합니다. 이 동작을 비활성화 하려면 아래의 설정을 사용하세요.

```ruby
config.assets.raise_runtime_errors = false
```

이 옵션이 true라면 애플리케이션의 애셋이 `config.assets.precompile`에 기술되어 있는 순서대로 모두 불러오는지를 확인합니다. `config.assets.digest`도 true인 경우, 애셋에 대한 요청에서는 다이제스트를 반드시 포함해야합니다.

### 다이제스트를 비활성화하기

`config/environments/development.rb`를 다음과 같이 고쳐서 다이제스트를 비활성화할 수 있습니다.

```ruby
config.assets.digest = false
```

이 옵션이 true라면 다이제스트가 생성되어 애셋 URL에 포함됩니다.

### 디버그를 비활성화하기

디버그 모드를 비활성화 하려면 `config/environments/development.rb`에 다음을 추가합니다.

```ruby
config.assets.debug = false
```

디버그 모드를 끄면, Sprockets는 모든 파일을 결합하여, 필요한 전처리를 수행합니다. 그리고 위의 매니페스트 파일에 의해서 다음과 같은 결과가 생성됩니다.

```html
<script src="/assets/application.js"></script> 
```

애셋은 서버 기동 후에 첫번째 리퀘스트를 받은 시점에서 컴파일과 캐시가
실행됩니다. Sprockets는 `must-revalidate`라는 Cache-Control HTTP 헤더를
설정하여 이후의 요청에 대한 오버헤드를 줄입니다. 이 경우 브라우저는
304(Not Modified) 응답을 받게 됩니다.

요청과 요청 사이에 매니페스트에 지정되어 있는 파일 중 하나에서 변경이 있었을
경우, Rails 서버는 새로 컴파일 된 파일을 응답으로 돌려줍니다.

Rails의 헬퍼 메소드를 사용하여 디버그 모드를 켤 수도 있습니다.

```erb
<%= stylesheet_link_tag "application", debug: true %>
<%= javascript_include_tag "application", debug: true %>
```

디버그 모드가 이미 켜져있는 경우, `:debug` 옵션은 의미가 없습니다.

development 환경에서 건전성을 확인하기 위한 일환으로 압축을 활성화하거나,
디버그의 필요성에 따라 그때그때 켜고 끌 수 있습니다.

production 환경의 경우
-------------

Sprockets은 production 환경에서는 위에서 말한 핑거프린트에 의한 스킴을
사용합니다. 기본으로 Rails의 애셋은 전처리된 정적인 애셋으로 웹서버에서
제공됩니다.

MD5는 컴파일된 파일의 내용을 기반으로 전처리중에 생성되며, 파일명에 추가되어
저장됩니다. 매니페스트의 이름은 Rails 헬퍼가 핑거프린트를 추가하여 사용합니다.

다음은 예시입니다.

```erb
<%= javascript_include_tag "application" %>
<%= stylesheet_link_tag "application" %>
```

이 코드에 의해서 다음과 같은 결과가 생성됩니다.

```html
<script src="/assets/application-908e25f4bf641868d8683022a5b62f54.js"></script>
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" media="screen" rel="stylesheet" />
```

NOTE: 애셋 파이프라인의 `:cache` 옵션과 `:concat`옵션은 폐기되었습니다.
이러한 옵션은 `javascript_include_tag`와 `stylesheet_link_tag`에서
삭제해주세요.

핑거프린트의 동작에 대해서는 `config.assets.digest` 초기화 옵션에서 제어할 수
있습니다. 기본값은 `true`입니다.

NOTE: `config.assets.digest` 옵션은 가급적 변경하지 말아주세요. 파일명에
다이제스트가 포함되지 않으면 먼 미레에 헤더가 설정되었을 때에 클라이언트가
파일의 내용이 변경된 것을 검출하지 못하게 될 수 있습니다.

### 애셋을 전처리하기

Rails에는 파이프라인에 애셋 매니페스트 파일을 수동으로 컴파일하기 위한
태스크가 포함되어 있습니다.

컴파일 된 애셋은 `config.assets.prefix`에서 지정한 위치에 저장됩니다. 이
위치의 기본값은 `/assets` 폴더 입니다.

배포시에 이 태스크를 서버 상에서 실행하면, 컴파일된 애셋이 서버 상에 직접
생성됩니다. 로컬 환경에서 컴파일 하는 방법에 대해서는 다음 절을 참고해주세요.

다음이 그 태스크입니다.

```bash
$ RAILS_ENV=production bin/rails assets:precompile
```

Capistrano (v2.15.1 이후)에는 배포중에 이 태스크를 사용하는 레시피가 포함되어
있습니다. `Capfile`에 다음을 추가합니다.

```ruby
load 'deploy/assets'
```

이를 통해 `config.assets.prefix`로 지정된 폴더가 `shared/assets`에 링크됩니다.
이미 이 공유 폴더를 사용하고 있다면 별도의 배포용 태스크를 작성해야합니다.

이 폴더는 복수의 배포에 걸쳐 공유된다는 점이 중요합니다. 이는 서버 이외의 다른
장소에서 캐시되어있는 패이지가 오래된 컴파일된 애셋을 참조하고 있는 경우에도,
캐시된 페이지의 수명이 되어 삭제될 때까지는 그 오래된 페이지의 참조가
유효하도록 만들기 때문입니다.

파일을 컴파일 할 때에 기본 매쳐에 의해서 `app/assets` 폴더에 있는
`application.js`, `application.css`, 그리고 모든 비JS/CSS 파일(이를 통해 모든
이미지 파일도 자동적으로 포함됩니다)가 포함됩니다. `app/assets` 폴더에 있는
젬도 포함됩니다.

```ruby
[ Proc.new { |filename, path| path =~ /app\/assets/ && !%w(.js .css).include?(File.extname(filename)) },
/application.(css|js)$/ ]
```

NOTE: 이 매쳐(그리고 뒤에서 설명할 precompile 배열의 다른 멤버)가 적용되는
것은 컴파일 전이나 컴파일 중의 파일명이 아닌, 컴파일 후의 최종적인
파일명이라는 점을 주의해주세요. 이것은 컴파일 되어서 JavaScript나 CSS로
변환되는 중간 과정인 파일은(순수한 JavaScript/CSS와 마찬가지로) 매쳐의
대상에서 모두 제외된다는 의미입니다. 예를 들자면 `.coffee`와 `.scss` 파일은
컴파일 후에는 각각 JavaScript와 CSS로 변환되므로, 이들은 자동적으로 포함되지
않습니다.

다른 매니페스트나, 그 외의 스타일시트/JavaScript 파일을 포함하고 싶은 경우에는
`config/initializers/assets.rb`의 `precompile`라는 배열을 사용하세요.

```ruby
Rails.application.config.assets.precompile += ['admin.js', 'admin.css', 'swfObject.js'
```

NOTE: precompile 배열에 Sass나 CoffeeScript 파일등을 추가할 경우에도 반드시 `.js`, `.css`로 끝나는 파일명(다시 말해 컴파일이 끝난 시점의 파일명)으로 지정해주세요.

이 태스크는 `manifest-md5hash.json` 파일을 생성합니다. 이것은 모든 애셋과 그 핑거프린트 목록입니다. Rails 헬퍼는 이 정보를 사용해서 매핑 요청이 Sprockets에 돌아가는 것을 회피합니다. 일반적인 매니페스트 파일의 내용은 아래와 같습니다.

```ruby
{"files":{"application-723d1be6cc741a3aabb1cec24276d681.js":{"logical_path":"application.js","mtime":"2013-07-26T22:55:03-07:00","size":302506,
"digest":"723d1be6cc741a3aabb1cec24276d681"},"application-12b3c7dd74d2e9df37e7cbb1efa76a6d.css":{"logical_path":"application.css","mtime":"2013-07-26T22:54:54-07:00","size":1560,
"digest":"12b3c7dd74d2e9df37e7cbb1efa76a6d"},"application-1c5752789588ac18d7e1a50b1f0fd4c2.css":{"logical_path":"application.css","mtime":"2013-07-26T22:56:17-07:00","size":1591,
"digest":"1c5752789588ac18d7e1a50b1f0fd4c2"},"favicon-a9c641bf2b81f0476e876f7c5e375969.ico":{"logical_path":"favicon.ico","mtime":"2013-07-26T23:00:10-07:00","size":1406,
"digest":"a9c641bf2b81f0476e876f7c5e375969"},"my_image-231a680f23887d9dd70710ea5efd3c62.png":{"logical_path":"my_image.png","mtime":"2013-07-26T23:00:27-07:00","size":6646,
"digest":"231a680f23887d9dd70710ea5efd3c62"}},"assets":{"application.js":
"application-723d1be6cc741a3aabb1cec24276d681.js","application.css":
"application-1c5752789588ac18d7e1a50b1f0fd4c2.css",
"favicon.ico":"favicona9c641bf2b81f0476e876f7c5e375969.ico","my_image.png":
"my_image-231a680f23887d9dd70710ea5efd3c62.png"}}
```

매니페스트 위치의 기본값은 `config.assets.prefix`로 지정된 장소의 최상위
폴더(기본값은 '/assets')입니다.

NOTE: production 환경에서 발견되지 않는 컴파일 후의 파일이 있다면, 찾을 수 없는
파일명을 에러 메시지에 포함하고 있는 `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`가 발생합니다.

#### 먼 미래에 유효기간이 끝나는 헤더

미리 컴파일한 애셋은 파일 시스템에 저장되어 웹서버로부터 직접 클라이언트에 제공됩니다. 이런 애셋들은 먼 미래에 유효기간이 끝나는 헤더(far-future headers)를 가지고 있지 않습니다. 따라서, 핑거프린트의 장점을 얻기 위해서는 서버의 설정을 변경하여 이러한 헤더를 포함시켜야 합니다.

Apache의 경우: 

```apache
# Expires* 디렉티브를 사용하는 경우는 Apache의
# `mod_expires` 모듈을 사용팔 필요가 있음
<Location /assets/>
  # Last-Modified 필드가 존재하는 경우에는 Etag의 사용을 막음
  Header unset ETag
  FileETag None
  # RFC에 따르면 캐시는 최대 1년까지
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

NGINX의 경우:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### 로컬에서 미리 컴파일하기

애셋을 로컬에서 미리 컴파일하는 이유는 몇가지를 생각해볼 수 있습니다. 예를
들자면 다음과 같은 이유입니다.

* production 환경의 파일 시스템에 쓰기 권한이 없음
* 배포를 여러곳에 해야해서 같은 작업을 반복하고 싶지 않음
* 애셋을 변경하지 않는 배포를 빈번하게 함

로컬에서 컴파일하여 컴파일 후의 애셋 파일을 Git 등에 의해 소스 관리 대상으로
포함하고, 다른 파일과 함께 배포되도록 만들 수 있습니다.

단, 주의할 부분이 있습니다.

* Capistrano의 배포 태스크에서 애셋의 컴파일을 수행하지 않을 것
* development 환경에서 압축기능이나 최소화 기능을 모두 쓸 수 있도록 해둘 것
* 아래의 애플리케이션 설정을 변경해둘 것

`config/environments/development.rb`에서 다음을 변경하세요.

```ruby
config.assets.prefix = "/dev-assets"
```

`prefix`를 변경하면 Sprockets은 development 환경에서 다른 URL을 사용해서 애셋을
제공하며, 모든 요청이 Sprockets에 넘겨지게 됩니다. production환경의 접두어는
`/assets`를 그대로 사용합니다. 이 변경이 이루어지지 않으면 애플리케이션은
development 환경에서도 production 환경과 동일한 애셋을 제공합니다. 이 경우,
애셋을 다시 컴파일하지 않으면 작업 중의 변경사항이 반영되지 않습니다.

실제로는, 이를 통해 로컬에서 컴파일을 할 수 있게 되므로, 필요에 따라 그
파일들을 소스 관리 시스템에 커밋할 수 있게 됩니다. development 환경은 기대한
대로 동작을 하게 됩니다.

### 동적인 컴파일

상황에 따라서는 동적으로 컴파일(live compilation)을 사용하고 싶은 경우도 있을
겁니다. 이 상황에서는 파이프라인의 애셋에 대한 요청이 직접 Sprockets을 통해
처리됩니다.

이 옵션을 활성화하려면 아래와 같이 설정합니다.

```ruby
config.assets.compile = true
```

최초의 요청을 받으면 애셋은 위의 development 환경의 부분에서 설명했듯 컴파일과
캐싱 작업이 이루어 집니다. 헬퍼에서 사용되는 매니페스트 이름은 MD5 해시가
포함됩니다.

또한 Sprockets는 `Cache-Control` HTTP 헤더를 `max-age=31536000`로 변경합니다.
이 헤더는 서버와 클라이언트의 사이에 존재하는 모든 캐시(프록시 등)에 대해서
서버가 제공하는 컨텐츠는 1년간 캐시해도 좋다고 알립니다. 이에 의해서 그 서버의
애셋에 대한 요청 수를 줄일 수 있으며, 애셋을 브라우저에서 직접 캐시하거나,
그 중간에서 캐시로 대체할 수 있는 기회가 주어집니다.

이 기능은 메모리를 추가로 사용하며, 성능에 영향을 줄 수 있므로 권장하지
않습니다.

실제 애플리케이션의 배포시스템에 JavaScript 런타임이 없는 경우에는 다음을
Gemfile에 추가하세요.

```ruby
group :production do
  gem 'therubyracer'
end
```

### CDN

CDN([컨텐츠 전송 네트워크](http://ko.wikipedia.org/wiki/%EC%BD%98%ED%85%90%EC%B8%A0_%EC%A0%84%EC%86%A1_%EB%84%A4%ED%8A%B8%EC%9B%8C%ED%81%AC))는 전세계를
대상으로 애셋을 캐싱하는 것을 주목적으로 설계됩니다. 이를 통해 브라우저에서
애셋을 요청하게 되면, 네트워크 상에서 가장 가까운 캐시의 사본이 사용됩니다.
production 환경의 Rails 서버로부터 (중간 캐시를 사용하지 않고) 직접 애셋을
제공하고 있다면, 애플리케이션과 브라우저의 사이에서 CDN을 사용하는 것이
가장 좋습니다.

CDN의 일반적인 사용법은 production 서버를 "origin" 서버로 설정하는 것입니다.
다시 말해, 브라우저가 CDN 상의 애셋을 요청하여, 캐시가 발견되지 않았을 경우
즉시 원 서버로부터 애셋 파일을 가져와서 캐싱하는 식입니다. 예를 들자면,
Rails 애플리케이션을 `example.com`이라는 도메인으로 운영하고 있고,
`mycdnsubdomain.fictional-cdn.com`라는 CDN이 설정되어 있다고 가정합시다.
`mycdnsubdomain.fictional-cdn.com/assets/smile.png`이 요청되면, CDN은 일단
기존 서버의 `example.com/assets/smile.png`에 접근하여 이 요청을 캐싱합니다.
CDN에 같은 요청이 다시 발생하면 캐시된 사본을 사용하게 됩니다. CDN이 애셋을
직접 제공하는 경우, 브라우저로부터 요청이 직접 Rails 서버에 넘어가는 경우는
없습니다. CDN이 제공하는 애셋은 네트워크 상에서 브라우저와 가까운 위치에
존재하므로 요청이 빠르게 처리됩니다. 또한, 서버는 애셋 전송에 사용할 시간을
절약할 수 있으므로 애플리케이션의 코드를 좀 더 빠르게 제공할 수 있게 됩니다.

#### CDN에서 정적인 애셋을 제공하기

CDN을 설정하려면, Rails 애플리케이션이 인터넷 상에서 production 환경으로
동작하고 있어야하며, `example.com`처럼 누구라도 접근할 수 있는 URL이 존재해야
합니다. 이어서 클라우드 호스팅 제공자가 제공하는 CDN 서비스와 계약할 필요도
있습니다. 이 경우, CDN의 "origin" 설정을 Rails 애플리케이션의 웹사이트
`example.com`로 설정해야압니다. "origin" 서버의 설정 방법에 대해서는 각
제공자에게 문의해주세요.

서비스에서 사용하는 CDN으로부터 애플리케이션에서 사용하기 위한 커스텀 서브
도메인(ex: `mycdnsubdomain.fictional-cdn.com`)도 얻어야 합니다. 여기까지로
CDN 서버의 설정이 완료되므로 이번에는 브라우저에 대해서 Rails 서버에 직접
접근하는 것이 아닌 CDN으로부터 애셋을 가져오도록 알려줄 필요가 있습니다.
이를 위해서는 본래 사용하던 상대경로 대신에 CDN을 애셋의 호스트 서버로
사용하도록 Rails를 변경합니다. Rails의 애셋 호스트를 설정하려면
`config/environments/production.rb`의 `config.action_controller.asset_host`를 다음과 같이
설정하세요.

```ruby
config.action_controller.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

NOTE: 여기에 적는 것은 "호스트명"(서브 도메인과 루트 도메인을 합친
것)뿐입니다. `http://`나 `https://` 같은 프로토콜 스킴을 적을 필요는 없습니다.
애셋에 대한 링크에서 사용되는 프로토콜 스킴은 웹페이지에 대한 요청이 발생했을
때, 그 페이지에 대한 기본 접근 방법에 따라서 적절하게 생성됩니다.

이 값은 [환경변수](http://ko.wikipedia.org/wiki/%ED%99%98%EA%B2%BD_%EB%B3%80%EC%88%98)로 설정할 수도 있습니다. 이를 사용하면 스테이징 서버를 실행하는 작업이 편해집니다.

```
config.action_controller.asset_host = ENV['CDN_HOST']
```

NOTE: 이 설정을 유효하게 만들려면 서버의 `CDN_HOST` 환경 변수에 값(이 경우라면,
`mycdnsubdomain.fictional-cdn.com`)을 설정해두어야 합니다.

서버와 CDN의 설정을 완료한 후, 다음의 애셋을 가지고 있는 웹 페이지에
접근했다고 가정합니다.

```erb
<%= asset_path('smile.png') %>
```

이 예제에서는 `/assets/smile.png`와 같은 경로는 반환되지 않습니다(읽기 쉽게 만들기 위해서 다이제스트 문자열을 생략했습니다). 실제로 생성되는 CDN에 대한 전체 경로는 다음과 같습니다.

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

`smile.png`의 사본이 CDN에 있다면, CDN이 대신 이 파일을 브라우저에 전송합니다. 원래 서버는 요청이 있었는지조차 확인할 수 없습니다. 파일의 사본이 CDN에 없는 경우, CDN은 "origin"(이 경우, `example.com/assets/smile.png`)을 찾아서 나중을 위해 저장해둡니다.

몇몇 애셋만을 CDN을 통해서 다루고 싶을 때, 애셋 헬퍼의 `:host` 옵션을 사용해서 `config.action_controller.asset_host`의 값을 덮어쓸 수도 있습니다.

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```

#### CDN의 캐싱 동작을 커스커마이즈하기

CDN은 컨텐츠를 캐싱함으로서 동작합니다. CDN에 저장되어 있는 컨텐츠가 오래되거나, 문제가 있다면 장점보다 단점이 커지게 됩니다. 여기에서는 다수의 CDN들의 일반적인 캐싱 동작에 대해서 설명합니다. 제공자에 따라서는 이 설명대로 동작하지 않는 경우도 있으므로 주의해주세요.

##### CDN 요청 캐싱

지금까지 CDN이 애셋을 캐싱할 때에 유용하다고 설명해왔습니다만, 실제로 캐싱되는 것은 애셋 뿐만이 아니라, 요청 전체입니다. 요청에는 애셋 자체 이외에도 여러 개의 헤더가 포함되어 있습니다. 헤더 중에서도 가장 중요한 것은 `Cache-Control`입니다. 이것은 CDN(그리고 웹브라우저)에서 어떻게 캐시를 다룰지에 대하여 알려주는 것입니다. 예를 들자면, 누군가가 실제로는 존재하지 않는 애셋 `/assets/i-dont-exist.png`에 요청을 하고, Rails가 404 에러를 반환했다고 합니다. 이 때에 `Cache-Control` 헤더가 유효하게 설정되어 있다면, CDN은 이 404 에러 페이지를 캐싱하게 됩니다.

##### CDN 헤더를 디버깅하기

이 헤더가 올바르게 캐싱되어 있는지를 확인하는 방법중 하나로 [curl](http://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com)을 사용할 수 있습니다. curl을 사용해서 서버와 CDN에 각각의 요청을 전송하고, 헤더가 같은지 아닌지 다음을 통해 확인할 수 있습니다.

```
$ curl -I http://www.example/assets/application-d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

이번에는 CDN의 사본입니다.

```
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy
Last-Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

CDN이 제공하는 `X-Cache` 등의 기능이나, CDN이 추가한 헤더등의 추가 정보에 대해서는 CDN의 문서를 확인해주세요.

##### CDN과 Cache-Control 헤더

[Cache-Control 헤더](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9)는 요청이 캐싱되는 방법을 정의하는 W3C의 사양입니다. CDN을 사용하지 않는 경우, 브라우저는 이 헤더 정보를 사용해서 컨텐츠를 캐싱합니다. 이 헤더 덕분에 애셋에 변경사항이 없는 경우에 브라우저가 CSS나 JavaScript를 요청할 때마다 다시 다운로드하지 않아도 되므로 무척 유용합니다. 애셋의 Cache-Control 헤더는 일반적으로 "public"으로 해두며, Rails 서버는 CDN이나 브라우저에 대해서 이 헤더를 통해서 그 사실을 알립니다. 애셋이 "public"이라는 것은 그 요청을 어떤 캐시든 저장해두라는 의미입니다. 마찬가지로 `max-age`도 이 헤더를 통해서 CDN이나 브라우저에 전송됩니다. 이 기간을 지나면 캐시를 폐기하게 됩니다. `max-age`의 값은 초단위로 지정할 수 있으며, 최댓값은 `31536000`이며, 이것은 1년에 해당합니다. Rails에서는 다음의 설정으로 이 기간을 지정할 수 있습니다.

```
config.static_cache_control = "public, max-age=31536000"
```

production 환경의 애셋은 이 설정에 의해서 애플리케이션으로부터 제공되며, 캐시는 1년간 저장됩니다. 많은 CDN은 요청 캐시도 저장하고 있으므로 이 `Cache-Control` 헤더는 애셋을 요청하는 모든 브라우저(미래에 등장할 브라우저를 포함하여)에 넘겨집니다. 브라우저는 이 헤더를 받으면, 이후에 같은 요청을 보낼 경우에 대비하여 캐시를 저장해둬도 된다는 것을 알 수 있습니다.

##### CDN에서의 URL 기반 캐시 폐기에 대해서

많은 CDN에서는 애셋의 캐싱을 완전히 URL에 기반해서 수행하고 있습니다. 예를 들자면, 아래의 애셋에 대한 요청이 있다고 합시다.

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

이 요청의 캐시는, 아래의 애셋에 대한 요청의 캐시와 완전히 다른 것으로 취급됩니다.

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

`Cache-Control`의 `max-age`를 먼 미래로 설정했지만, 애셋에 변경이 발생한 경우에는 이러한 캐시를 폐기해주세요. 예를 들자면, 어떤 아이콘의 색을 노란색에서 파란색으로 변경했다면, 홈페이지에 방문한 사람에게는 변경 후의 파란색으로 보이길 바랄 것입니다. Rails는 CDN을 함께 사용하는 경우, Rails의 애셋 파이프라인 `config.assets.digest`이 기본적으로 true로 설정되어 있으므로, 애셋의 내용이 조금이라도 바뀐다면 파일명도 바뀝니다. 이 때에 캐시 내역을 수동으로 삭제할 필요가 없다는 점에 주목해주세요. 애셋 이름은 내용에 따라서 변경되므로, 사용자는 언제나 최신 애셋을 사용할 수 있게 됩니다.

파이프라인을 커스터마이즈하기
------------------------

### CSS를 압축하기

YUI는 CSS 압축방법 중 하나입니다. [YUI CSS compressor](http://yui.github.io/yuicompressor/css.html)는 최소화 기능을 제공하고 있습니다(역주: 여기에서는 압축(compress)은 최소화(minify)나 난독화(uglify)와 동일한 의미로 사용되고 있으며, 압축 후의 파일은 zip과 같은 바이너리가 되지 않습니다).

YUI 압축은 아래의 설정으로 활성화할 수 있습니다. 단, `yui-compressor` gem이 필요합니다.

```ruby
config.assets.css_compressor = :yui
```
sass-rails gem을 사용하고 있는 경우에는 YUI 대신 사용할 수도 있습니다.

```ruby
config.assets.css_compressor = :sass
```

### JavaScript를 압축하기

JavaScript를 압축할 때에는 `:closure`, `:uglifier`, `:yui` 중에 하나를 옵션으로 지정할 수 있습니다. 각각 `closure-compiler` gem, `uglifier` gem, `yui-compressor` gem이 필요합니다.

Rails의 Gemfile에는 기본으로 [uglifier](https://github.com/lautis/uglifier)가 포함되어 있습니다. 이 gem은 NodeJS로 작성된 [UglifyJS](https://github.com/mishoo/UglifyJS)를 Ruby로 감싼 것입니다. uglifier에 의한 압축은 다음과 같이 이루어집니다. 공개문자와 주석을 제거하고, 지역 변수명을 짧게 줄인 뒤, 가능하다면 `if`와 `else`를 삼항연산자로 변환하는 등의 최적화를 합니다.

아래의 설정으로 JavaScript 압축시에 `uglifier`가 사용됩니다.

```ruby
config.assets.js_compressor = :uglifier
```

NOTE: `uglifier`를 사용하려면 [ExecJS](https://github.com/sstephenson/execjs#readme)가 지원하는 JavaScript 런타임이 필요합니다. Mac OS X나 Windows를 사용하고 있는 경우에는 OS에 JavaScript 런타임을 설치해주세요.

### GZip으로 압축한 애셋 제공하기

기본으로 gzip으로 압축된 애셋이 압축되지 않은 애셋과 함께 생성됩니다. 압축된
애셋을 사용하면 전송량을 줄일 수 있습니다. 이는 `gzip` 플래그를 통해 변경할
수 있습니다.

```ruby
config.assets.gzip = false # 압축된 애셋 생성하지 않기
```

### 다른 압축 방법을 사용하기

CSS나 JavaScript의 압축 설정에는 다른 객체를 설정할 수도 있습니다. 설정에 넘길
객체에는 `compress` 메소드가 구현되어 있어야 합니다. 이 메소드는 문자열을
인수로 받아서 압축 결과를 문자열의 형태로 반환하면 됩니다.

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

이 코드를 유효하게 만들려면 `application.rb`의 설정 옵션에 새로운 객체를 넘기면 됩니다.

```ruby
config.assets.css_compressor = Transformer.new
```

### _애셋_의 경로를 변경하기

Sprockets가 사용하는 애셋의 경로는 기본값으로 `/assets`입니다.

이 경로는 다음을 통해서 변경할 수 있습니다.

```ruby
config.assets.prefix = "/some_other_path"
```

이 옵션은 애셋 파이프라인을 사용하지 않는 기존의 프로젝트가 있고, 그 프로젝트의 기존의 경로를 그대로 유지하거나, 새로운 리소스용의 경로를 지정할 경우 등에 유용합니다.

### X-Sendfile 헤더

X-Sendfile 헤더는 웹서버에 대한 디렉티브이며 애플리케이션으로부터 응답을 브라우저에 전송하지 않고 파기한 뒤, 대신에 다른 파일을 디스크로부터 읽어와서 브라우저에게 돌려줍니다. 이 옵션은 기본적으로 꺼져있습니다. 서버가 이 헤더를 지원하는 경우에만 사용할 수 있습니다. 이 경우 그 파일의 전송 작업은 웹 서버에게 일임되며, 이에 의해서 속도 향상을 기대할 수 있습니다. 이 기능의 사용법에 대해서는 [send_file](http://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)을 참조해주세요.

Apache와 NGINX에서는 이 옵션이 지원되며, 다음과 같이 `config/environments/production.rb`에서 유효하게 설정할 수 있습니다.

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # Apache용
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # NGINX용
```

WARNING: 기존의 Rails 애플리케이션을 업그레이드할 때에 이 기능을 사용할지 검토하고 있는 경우라면, 이 옵션을 어디에서 활성화할지 잘 확인해주세요. 이 옵션을 사용해도 좋은 곳은 `production.rb`과 production 환경처럼 동작하는 다른 환경 파일 뿐입니다. `application.rb`에서 사용해서는 안됩니다.

TIP: 자세한 설명은 production 환경용의 웹서버 문서를 참고해주세요.
- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](http://wiki.nginx.org/XSendfile)

애셋의 캐시 저장소
------------------

기본으로 Sprockets 캐시는 development 환경과 production 환경에서
`tmp/cache/assets`를 사용합니다. 이 경로는 다음과 같이 변경할 수 있습니다.

config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end

애셋 캐시 스토어를 비활성화 하려면 다음의 코드를 추가합니다.

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Gem에 애셋을 추가하기
--------------------------

애셋은 외부 소스로부터 gem의 형태로 가져올 수도 있습니다.

좋은 예시로 `jquery-rails` gem이 있습니다. 이것은 JavaScript 라이브러리를 gem으로서 Rails에 제공합니다. 이 gem을 사용하면, Rails는 이 gem용의 폴더를 애셋이 저장되어 있을 것이라고 이해하며, 이 gem의 폴더가 `app/assets`, `lib/assets`, `vendor/assets` 폴더와 함께 Sprockets의 검색 경로에 추가됩니다.

라이브러리나 Gem을 전처리기로 만들기
------------------------------------------

Sprockets는 다른 템플릿 엔진에 대한 일반적인 인터페이스로서 [Tilt](https://github.com/rtomayko/tilt)를 사용하고 있으므로, gem에서 Tilt의 템플릿 프로토콜을 구현하기만 하면 됩니다. 보통 Tilt를 `Tilt::Template`처럼 상속하여 `prepare` 메소드와 `evaluate` 메소드를 구현합니다. `prepare` 메소드는 템플릿을 초기화하며, `evaluate` 메소드는 처리가 끝난 소스를 반환합니다. 처리전의 코드는 `data`에 저장됩니다. 더 자세한 설명은 [`Tilt::Template`](https://github.com/rtomayko/tilt/blob/master/lib/tilt/template.rb)의 소스를 참고해주세요.

```ruby
module BangBang
  class Template < ::Tilt::Template
    def prepare
      # 여기에서 모든 초기화 처리를 수행한다
    end

    # 원래 템플릿에 ""!를 추가한다
    def evaluate(scope, locals, &block)
      "#{data}!"
    end
  end
end
```

이것으로 `Template` 클래스가 생성되었으므로, 이어서 템플릿 파일의 확장자와 연결하면 됩니다.

```ruby
Sprockets.register_engine '.bang', BangBang::Template
```

오래된 버전의 Rails를 업그레이드하기
------------------------------------

Rails 3.0나 Rails 2.x로부터 업그레이드를 하는 경우에는 몇몇 작업을 처리할 필요가 있습니다. 우선 `public/` 폴더에 있던 파일들을 다른 위치로 옮깁니다. 파일의 종류에 따른 올바른 위치는 [애셋을 구성하기](#애셋을-구성하기)를 참조해주세요.

이어서 JavaScript 파일의 중복을 제거합니다. jQuery는 Rails 3.1이후로 기본 JavaScript 라이브러리가 되었으므로 `jquery.js`를 `app/assets`에 두지 않더라도 자동적으로 불러와집니다.

세번째로는, 많은 환경설정 파일에 올바른 기본 옵션값을 추가합니다.

`application.rb`의 경우.

```ruby
# 애셋의 버전을 지정합니다. 애셋을 모두 갱신하고 싶은 경우에는 이 값을 변경하세요.
config.assets.version = '1.0'

# config.assets.prefix = "/assets"는 애셋을 어디에 위치시킬지에 대한 경로를 변경할 때에 사용합니다.
```

`development.rb`의 경우.

```ruby
# 애셋을 읽어온 행을 전개합니다.
config.assets.debug = true
```

`production.rb`의 경우.

```ruby
# 사용하고 싶은 전처리기를 선택하세요
config.assets.js_compressor = :uglifier
# config.assets.css_compressor = :yui

# 컴파일된 애셋이 발견되지 않는 경우에 애셋 파이프라인으로 돌아가지 않기
config.assets.compile = false

# 애셋 URL의 다이제스트를 생성하기. 이 옵션은 제거 예정입니다.
config.assets.digest = true

# 추가 애셋을 미리 컴파일하기 (application.js, application.css, 그리고 모든
# 비JS/CSS 파일이 추가되어 있음)
# config.assets.precompile += %w( search.js )
```

Rails는 Sprockets의 기본 설정값을 test 환경을 위한 `test.rb`에서 설정하지
않도록 변경되었습니다. 따라서 `test.rb`에서 Sprockets의 설정을 추가할 필요가
있습니다. test환경에서의 이전 기본값은 `config.assets.compile = true`,
`config.assets.compress = false`, `config.assets.debug = false`,
`config.assets.digest = false`입니다.

다음을 `Gemfile`에 추가해야합니다.

```ruby
gem 'sass-rails',   "~> 3.2.3"
gem 'coffee-rails', "~> 3.2.1"
gem 'uglifier'
```
