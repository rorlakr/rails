[The Asset Pipeline] Asset Pipeline
==================

본 가이드에서는 asset pipeline에 대해서 다룹니다. [[[This guide covers the asset pipeline.]]]

본 가이드를 읽은 후, 아래의 내용을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* asset pipeline의 개념과 하는 일을 이해하는 방법 [[[How to understand what the asset pipeline is and what it does.]]]

* 어플리케이션 자원을 적절하게 구성하는 방법 [[[How to properly organize your application assets.]]]

* appet pipeline의 잇점을 이해하는 방법 [[[How to understand the benefits of the asset pipeline.]]]

* pipeline에 전처리기를 추가하는 방법 [[[How to add a pre-processor to the pipeline.]]]

* 웹 자원을 하나의 젬으로 포장하는 방법 [[[How to package assets with a gem.]]]

--------------------------------------------------------------------------------

[What is the Asset Pipeline?] Asset Pipeline이란 무엇인가?
---------------------------

asset pipeline은 자바스크립트와 CSS 자원을 합치고 최소화 또는 압축하기 위한 프레임워크를 제공해 줍니다. 또한 Coffeescript, Sass, ERB와 같은 언어로 이러한 자원을 작성할 수 있도록 해 줍니다. [[[The asset pipeline provides a framework to concatenate and minify or compress JavaScript and CSS assets. It also adds the ability to write these assets in other languages such as CoffeeScript, Sass and ERB.]]]

asset piepline을 레일스의 핵심 기능으로 만든 것은 모든 개발자들이 Sprockets라는 라이브러리를 이용하여 자원을 전처리하고 압축하고 최소화할 수 있는 잇점을 가질 수 있게 해 줍니다. 이것은 RailsConf 2011에서 DHH가 자신의 키노드에서 소개한 "fast by default" 전략의 일부분입니다. [[[Making the asset pipeline a core feature of Rails means that all developers can benefit from the power of having their assets pre-processed, compressed and minified by one central library, Sprockets. This is part of Rails' "fast by default" strategy as outlined by DHH in his keynote at RailsConf 2011.]]]

asset pipeline은 디폴트 상태에서 별다른 조치없이 바로 사용할 수 있습니다. 그러나 `config/application.rb` 파일에서 application 클래스 정의내에 아래의 코드라인을 추가하여 asset pipeline을 사용하지 않도록 설정할 수 있습니다. [[[The asset pipeline is enabled by default. It can be disabled in `config/application.rb` by putting this line inside the application class definition:]]]

```ruby
config.assets.enabled = false
```

또한 레일스 프로젝트를 새로 만들 때 아래와 같이 `--skip-sprockets` 옵션을 추가하여 asset pipeline을 사용하지 않도록 할 수 있습니다. [[[You can also disable the asset pipeline while creating a new application by passing the `--skip-sprockets` option.]]]

```bash
rails new appname --skip-sprockets
```

의도적으로 asset pipeline을 사용하지 않을 것이 아니라면 새로 생성하는 모든 어플리케이션에 대해서 디폴트 상태를 사용해야만 합니다. [[[You should use the defaults for all new applications unless you have a specific reason to avoid the asset pipeline.]]]


### [Main Features] 주요 특징

첫번째 특징은 자원을 합치는 것입니다. 이것은, 브라우저가 웹페이지를 보여주기 위해 서버에 요청하는 수를 줄일 수 있기 때문에, 운영환경에서 중요한 기능입니다. 웹브라우저는 동시에 요청할 수 있는 수가 제한되어 있어서 요청을 적게한다는 것은 어플리케이션의 로딩 속도를 보다 빠르게 할 수 있다는 것을 의미합니다. [[[The first feature of the pipeline is to concatenate assets. This is important in a production environment, because it can reduce the number of requests that a browser makes to render a web page. Web browsers are limited in the number of requests that they can make in parallel, so fewer requests can mean faster loading for your application.]]]

레일스 2.x 에서는 `javascript_include_tag`와 `stylesheet_link_tag` 메소드에 `cache: true` 옵션을 추가하여 자바스크립트와 CSS 자원을 합칠 수 있도록 했습니다. 그러나 이러한 방법은 몇가지 제한점이 있습니다. 예를 들어, 캐시를 미리 만들 수 없고 다른 라이브러리에서 제공하는 자원들을 분명하게 포함할 수 없다는 것입니다. [[[Rails 2.x introduced the ability to concatenate JavaScript and CSS assets by placing `cache: true` at the end of the `javascript_include_tag` and `stylesheet_link_tag` methods. But this technique has some limitations. For example, it cannot generate the caches in advance, and it is not able to transparently include assets provided by third-party libraries.]]]

3.1 버전부터는, 모든 자바스크립트를 하나의 총괄 `.js` 파일로, 모든 CSS 파일을 하나의 총괄 `.css` 파일로 합치는 것을 디폴트로 지원합니다. 나중에 알게 되겠지만, 이러한 전략을 변경해서 선호하는 방식으로 파일들을 그룹화할 수 있습니다. 운영환경에서, 레일스는 각 파일명에 MD5 fingerprint를 삽입하여 해당 파일이 웹브라우저에서 캐시상태로 만들어 지도록 합니다. 이 fingerprint를 변경하여 해당 캐시 파일을 무효화할 수 있는데, 이것은 파일 컨텐츠를 변경할 때마다 자동으로 발생하게 됩니다. [[[Starting with version 3.1, Rails defaults to concatenating all JavaScript files into one master `.js` file and all CSS files into one master `.css` file. As you'll learn later in this guide, you can customize this strategy to group files any way you like. In production, Rails inserts an MD5 fingerprint into each filename so that the file is cached by the web browser. You can invalidate the cache by altering this fingerprint, which happens automatically whenever you change the file contents.]]]

asset pipeline의 두번째 특징은, 자원을 최소화 또는 압축하는 것입니다. CSS 파일에 대해서는, 코멘트 내용과 whitespace를 제거하므로써 CSS 파일의 크기를 줄이게 됩니다. 자바스크리브에서는, 좀 더 복잡한 과정이 필요할 데, 다양한 내장 옵션을 지정하거나 자신의 것으로 지정할 수 있습니다. 
[[[The second feature of the asset pipeline is asset minification or compression. For CSS files, this is done by removing whitespace and comments. For JavaScript, more complex processes can be applied. You can choose from a set of built in options or specify your own.]]]

asset pipeline의 세번째 특징은, 보다 높은 차원의 언어를 사용하여 자원을 코딩할 수 있도록 해 주는데, 이것은 사전 컴파일 과정을 거쳐서 실제 사용가능한 자원으로 만들어지게 됩니다. 지원되는 언어로는 CSS에 대해서는 Sass, 자바스크립트에 대해서는 Coffeescript, 그리고 CSS와 자바스크립트 모두에 대해서 ERB가 있습니다. [[[The third feature of the asset pipeline is that it allows coding assets via a higher-level language, with precompilation down to the actual assets. Supported languages include Sass for CSS, CoffeeScript for JavaScript, and ERB for both by default.]]]

### [What is Fingerprinting and Why Should I Care?] Fingerprinting의 정의와  유념해야할 이유

Fingerprinting이라는 것은 파일이름을 파일의 내용에 의존해서 만드는 기술을 말합니다. 따라서 파일 내용이 변경될 때 파일이름 또한 변경됩니다. 파일내용이 static하거나 거의 변하지 않는 경우에는, 다른 서버에 위치하거나 배포 날짜가 다른 경우에도 해당 파일의 두가지 버전이 일치하는지를 쉽게 알려 주게 됩니다. [[[Fingerprinting is a technique that makes the name of a file dependent on the contents of the file. When the file contents change, the filename is also changed. For content that is static or infrequently changed, this provides an easy way to tell whether two versions of a file are identical, even across different servers or deployment dates.]]]

특정 파일명이 유일하고 파일내용에 근거하여 만들어질 때, HTTP 헤더를 설정하여 캐시가 어느 곳(CDN, ISP, 네트워크 장비, 또는 웹브라우저)에 위치하더라도 자신만의 파일 복사본을 유지하도록 할 수 있습니다. 해당 파일의 내용이 업데이트될 때 fingerprint는 변경될 것입니다. 이것은 원격상의 클라이언트가 해당 파일의 새로운 복사본을 요청하도록 할 것입니다. 이러한 것을 일반적으로 _cache busting_ 이라고 합니다. [[[When a filename is unique and based on its content, HTTP headers can be set to encourage caches everywhere (whether at CDNs, at ISPs, in networking equipment, or in web browsers) to keep their own copy of the content. When the content is updated, the fingerprint will change. This will cause the remote clients to request a new copy of the content. This is generally known as _cache busting_.]]]

fingerprinting에 대해서 레일스가 사용하는 기술은 _파일내용의 해시값_ 을 대개 파일명의 끝에 삽입하는 것입니다. 예를 들어, `global.css`라는 CSS 파일은 해당 파일내용의 MD5 digest값이 파일명의 끝에 삽입될 것입니다. [[[The technique that Rails uses for fingerprinting is to insert a hash of the content into the name, usually at the end. For example a CSS file `global.css` could be renamed with an MD5 digest of its contents:]]]

```
global-908e25f4bf641868d8683022a5b62f54.css
```

이러한 것이 바로 레일스 asset pipeline이 채택한 전략입니다. [[[This is the strategy adopted by the Rails asset pipeline.]]]

레일스의 예전 전략은 날짜를 근거로 한 쿼리문자열을 내장 헬퍼에 연결되는 모든 자원에 추가하는 것이었습니다. [[[Rails' old strategy was to append a date-based query string to every asset linked with a built-in helper. In the source the generated code looked like this:]]]

```
/stylesheets/global.css?1309495796
```

쿼리문자열 전략은 몇가지 단점이 있습니다. [[[The query string strategy has several disadvantages:]]]

1. **파일명이 단지 쿼리파라메터만 다르다하여 모두 캐시되지는 않는다 것입니다.**<br />
    [Steve Souders](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)이 추천하는 것은 캐시하려는 리소스에 대해서 쿼리문자열을 사용하지 말라는 것입니다. 또한 그는 이러한 경우 요청 중 5-20%는 캐시되지 않을 것이라는 것을 알게 되었습니다. 특히 쿼리문자열은 캐시 유효성여부를 알기 위해서 몇몇 CDN에 접속할 때 전혀 작동하지 않게 됩니다. [[[**Not all caches will reliably cache content where the filename only differs by query parameters**<br />
    [Steve Souders recommends](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/), "...avoiding a querystring for cacheable resources". He found that in this case 5-20% of requests will not be cached. Query strings in particular do not work at all with some CDNs for cache invalidation.]]]

2. **다중 서버 환경에서 파일명은 노드에 따라 변경될 수 있다.**<br />
    레일스 2.x 에서 디폴트 쿼리문자열은 파일의 변경시간에 근거해서 작성됩니다. 따라서 자원들이 특정 클러스트로 배포될 때 타임스탬프가 동일하다는 것을 보장할 수 없게 되는데, 결과적으로 요청을 처리하는 서버에 따라 다른 값을 가지게 되기 때문입니다. [[[**The file name can change between nodes in multi-server environments.**<br />
    The default query string in Rails 2.x is based on the modification time of the files. When assets are deployed to a cluster, there is no guarantee that the timestamps will be the same, resulting in different values being used depending on which server handles the request.]]]

3. **과도한 캐시무효화**<br />
    새로운 버전의 코드와 함께 정적 자원을 배포할 때 이러한 모든 파일들의 최종변경일자인 mtime값도 변경되기 때문에, 모든 원격 클라이언트들로 하여금, 자원의 내용이 변경되지 않는 경우에도 강제로 이들 정적 자원들을 재차 다운로드하도록 할 것입니다. [[[**Too much cache invalidation**<br />
    When static assets are deployed with each new release of code, the mtime(time of last modification) of _all_ these files changes, forcing all remote clients to fetch them again, even when the content of those assets has not changed.]]]

Fingerprinting은 쿼리문자열을 사용하지 않음으로써 이러한 문제점들을 해결하고 파일명들이 내용에 근거해서 일관성을 가지도록 해 줍니다. [[[Fingerprinting fixes these problems by avoiding query strings, and by ensuring that filenames are consistent based on their content.]]]

운영환경에서는 Fingerprinting이 디폴트로 작동하지만 다른 환경에서는 사용할 수 없습니다. 설정파일에서 `config.assets.digest` 옵션을 이용하여 이 기능의 사용여부를 지정할 수 있습니다. [[[Fingerprinting is enabled by default for production and disabled for all other environments. You can enable or disable it in your configuration through the `config.assets.digest` option.]]]

더 자세한 내용을 읽고자 한다면 아래의 링크를 참고하시기 바랍니다. [[[More reading:]]]

* [Optimize caching](http://code.google.com/speed/page-speed/docs/caching.html)
* [Revving Filenames: don’t use querystring](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)


[How to Use the Asset Pipeline] Asset Pipeline 사용법
-----------------------------

레일스 이전 버전에서는, 모든 자원이 `public` 디렉토리의 하위 디렉토리인 `images`, `javascripts`, `stylesheets`에 위치했었습니다. Asset pipeline을 사용하게 되면, `app/assets` 디렉토리에 자원들이 위치하게 됩니다. 이 디렉토리 상의 파일들은 sprockets 젬을 설치할 경우 Sprockets 미들웨어에 의해서 처리됩니다. [[[In previous versions of Rails, all assets were located in subdirectories of `public` such as `images`, `javascripts` and `stylesheets`. With the asset pipeline, the preferred location for these assets is now the `app/assets` directory. Files in this directory are served by the Sprockets middleware included in the sprockets gem.]]]

Asset pipeline을 사용할 때도 자원들을 `public` 디렉토리에 둘 수 있습니다. `public` 디렉토리상의 모든 자원들은 어플리케이션이나 웹서버에 의해서 static 파일로서 사용될 것입니다. 따라서 사용하기 전에 어떤 전처리과정이 필요한 파일들은 `app/assets` 디렉토리에 두어야 합니다. [[[Assets can still be placed in the `public` hierarchy. Any assets under `public` will be served as static files by the application or web server. You should use `app/assets` for files that must undergo some pre-processing before they are served.]]]

운영환경에서는, 레일스가 디폴트로 이러한 자원 파일들을 사전 컴파일해서 `public/assets` 디렉토리에 둡니다. 이 사전 컴파일된 파일들은 웹서버가 static 자원으로 사용하게 됩니다. `app/assets` 디렉토리에 있는 파일들은 운영환경에서 절대로 직접 사용되지 않습니다. [[[In production, Rails precompiles these files to `public/assets` by default. The precompiled copies are then served as static assets by the web server. The files in `app/assets` are never served directly in production.]]]

### [Controller Specific Assets] 컨트롤러 전용 자원

임의의 scaffold 또는 컨트롤러를 생성할 때 레일스는 해당 컨트롤러 전용 자바스크립 파일(또는 `Gemfile`에 `coffeescript-rails` 젬이 있다면 CoffeeScript 파일)과 CSS 파일(`Gemfile` 내에 `sass-rails`젬이 있다면 SCSS 파일)도 동시에 생성해 줍니다. [[[When you generate a scaffold or a controller, Rails also generates a JavaScript file (or CoffeeScript file if the `coffee-rails` gem is in the `Gemfile`) and a Cascading Style Sheet file (or SCSS file if `sass-rails` is in the `Gemfile`) for that controller.]]]

예를 들어, `ProjectsController`를 생성한다면, 레일스는 동시에 `app/assets/javascripts/projects.js.coffee`와 `app/assets/stylesheets/projects.css.scss` 파일을 생성해 줍니다. 디폴트 상태에서, 이러한 파일들은 `require_tree` 명령어를 사용한 후에 어플리케이션에서 사용할 수 있게 됩니다. require_tree에 대한 자세한 내용은 [Manifest Files and Directives](#manifest-files-and-directives)를 보기 바랍니다. [[[For example, if you generate a `ProjectsController`, Rails will also add a new file at `app/assets/javascripts/projects.js.coffee` and another at `app/assets/stylesheets/projects.css.scss`. By default these files will be ready to use by your application immediately using the `require_tree` directive. See [Manifest Files and Directives](#manifest-files-and-directives) for more details on require_tree.]]]

또한 `<%= javascript_include_tag params[:controller] %>` 또는 `<%= stylesheet_link_tag params[:controller] %>`를 사용하게 되면 전용 CSS와 자바스크립트를 각각의 컨트롤러에서만 사용할 수 있습니다. 주의할 것은 `require_tree` 명령을 사용하지 않았는지를 확인해야 합니다. 왜냐하면 결과적으로 자원이 한번이상 포함될 것이기 때문입니다. [[[You can also opt to include controller specific stylesheets and JavaScript files only in their respective controllers using the following: `<%= javascript_include_tag params[:controller] %>` or `<%= stylesheet_link_tag params[:controller] %>`. Ensure that you are not using the `require_tree` directive though, as this will result in your assets being included more than once.]]]

WARNING: (운영환경에서는 디폴트 상태로) 자원을 사전 컴파일하게 되는데, 컨트롤러 전용 자원이 해당 페이지가 로딩될 때마다 사전 컴파일되는 것을 확인할 필요가 있습니다. 디폴트로, .coffee 와 .scss 파일은 사전 컴파일되지 않습니다. 개발환경에서는 이러한 파일들이 임시로 컴파일되기 때문에 사전 컴파일된 듯한 효과를 보이게 되어 제대로 동작할 것입니다. 그러나 운영환경에서 실행할 때는, 디폴트로 실시간 컴파일작업이 꺼진 상태이므로 500 에러가 발생하게 될 것입니다. 사전 컴파일 작업이 어떻게 동작하는지에 대한 자세한 내용은 [Precompiling Assets](#precompiling-assets)를 보기 바랍니다. [[[When using asset precompilation (the production default), you will need to ensure that your controller assets will be precompiled when loading them on a per page basis. By default .coffee and .scss files will not be precompiled on their own. This will result in false positives during development as these files will work just fine since assets will be compiled on the fly. When running in production however, you will see 500 errors since live compilation is turned off by default. See [Precompiling Assets](#precompiling-assets) for more information on how precompiling works.]]]

NOTE: CoffeeScript를 사용하기 위해서는 ExecJS를 지원하는 런타임 라이브러리가 설치되어 있어야 합니다. Mac OS X 또는 윈도우즈를 사용하는 경우라면, 해당 운영 시스템에 자바스크립트 런타임 라이브러리를 설치해 주어야 합니다. 지원 가능한 모든 자바스크립트 런타임 라이브러리를 알기를 원하면 [ExecJS](https://github.com/sstephenson/execjs#readme) 문서를 참고하기 바랍니다. [[[You must have an ExecJS supported runtime in order to use CoffeeScript. If you are using Mac OS X or Windows you have a JavaScript runtime installed in your operating system. Check [ExecJS](https://github.com/sstephenson/execjs#readme) documentation to know all supported JavaScript runtimes.]]]

물론, `config/application.rb` 설정 파일에 아래의 코드라인을 추가해서 컨트롤러가 생성될 때 자원 파일들이 자동으로 생성되지 않도록 방지할 수 있습니다. [[[You can also disable the generation of asset files when generating a controller by adding the following to your `config/application.rb` configuration:]]]

```ruby
config.generators do |g|
  g.assets false
end
```

### [Asset Organization] 자원의 구성

Pipeline 자원들은 어플리케이션내의 `app/assets`, `lib/assets`, `vendor/assets` 디렉토리 중의 하나에 위치할 수 있습니다. [[[Pipeline assets can be placed inside an application in one of three locations: `app/assets`, `lib/assets` or `vendor/assets`.]]]

* `app/assets` 디렉토리에는, 예를 들어, 개발자가 어플리케이션에서 사용하기 위해서는 추가하는 이미지 파일, 자바스크립트 파일 또는 스타일시트 파일들을 둘 수 있습니다. [[[`app/assets` is for assets that are owned by the application, such as custom images, JavaScript files or stylesheets.]]]

* `lib/assets` 디렉토리에는, 어플리케이션의 영역을 벗어나는 라이브러리나, 어플케이션 간에 공유할 수 있는 라이브러리를 위한 자원들을 둘 수 있습니다. [[[`lib/assets` is for your own libraries' code that doesn't really fit into the scope of the application or those libraries which are shared across applications.]]]

* `vendor/assets` 디렉토리에는, 자바스크립트 프러그인과 CSS 프레임워크와 같은 외부에서 사용하는 자원들을 둘 수 있습니다. [[[`vendor/assets` is for assets that are owned by outside entities, such as code for JavaScript plugins and CSS frameworks.]]]

#### [Search Paths] 검색 경로

임의의 manifest 파일이나 헬퍼 파일이 특정 파일을 참조할 때 Sprockets는 3개의 디폴트 위치를 검색하게 됩니다. [[[When a file is referenced from a manifest or a helper, Sprockets searches the three default asset locations for it.]]]

디폴트 위치는 `app/assets/images`와 3개의 모든 위치에서 `javascripts`, `stylesheets` 라는 하위디렉토리입니다. 그러나 이러한 하위디렉토리는 특별한 의미가 있는 것은 아닙니다. `assets/*` 아래의 모든 경로를 찾게 될 것입니다. [[[The default locations are: `app/assets/images` and the subdirectories `javascripts` and `stylesheets` in all three asset locations, but these subdirectories are not special. Any path under `assets/*` will be searched.]]]

예를 들어, 아래의 파일들은 [[[For example, these files:]]]

```
app/assets/javascripts/home.js
lib/assets/javascripts/moovinator.js
vendor/assets/javascripts/slider.js
vendor/assets/somepackage/phonebox.js
```

아래의 manifest 파일에서 각각 참조될 것입니다. [[[would be referenced in a manifest like this:]]]

```js
//= require home
//= require moovinator
//= require slider
//= require phonebox
```

하위디렉토리에 위치하는 자원들도 검색할 수 있습니다. [[[Assets inside subdirectories can also be accessed.]]]

```
app/assets/javascripts/sub/something.js
```

위의 파일은 아래와 같이 참조할 수 있습니다. [[[is referenced as:]]]

```js
//= require sub/something
```

레일스 콘솔에서 `Rails.application.config.assets.paths`로 Sprockets의 검색경로를 확인할 수 있습니다. [[[You can view the search path by inspecting `Rails.application.config.assets.paths` in the Rails console.]]]

레일스 디폴트 경로인 `assets/*` 뿐만아니라, `config/application.rb` 파일에 아래와 같이 코드라인을 추가하여, 특정 경로(절대경로)를 pipleline에 추가할 수도 있습니다. 예를 들면, [[[Besides the standard `assets/*` paths, additional (fully qualified) paths can be added to the pipeline in `config/application.rb`. For example:]]]

```ruby
config.assets.paths << Rails.root.join("lib", "videoplayer", "flash")
```

검색경로상에 나타나는 순서대로 경로 탐색이 실행됩니다. 디폴트 상태에서는 `app/assets` 경로가 우선적으로 검색되고 동일한 파일이 `lib`과 `vendor` 디렉토리상에 있을 때는 검색되지 않게 됩니다. [[[Paths are traversed in the order that they occur in the search path. By default, this means the files in `app/assets` take precedence, and will mask corresponding paths in `lib` and `vendor`.]]]

주목할 것은, 하나의 manifest 파일에 등록되지 않은 파일들을 참조하고자 할 때는 사전컴파일 경로에 해당 파일들을 등록해 주어야 한다는 것입니다. 그렇지 않으면 운영환경에서 해당 파일들을 사용하지 못할 것입니다. [[[It is important to note that files you want to reference outside a manifest must be added to the precompile array or they will not be available in the production environment.]]]

#### [Using Index Files] 인덱스 파일 이용하기

Spockets는 특수한 목적으로 연관확장자를 가지는 `index`라는 이름을 가지는 파일들을 이용합니다. [[[Sprockets uses files named `index` (with the relevant extensions) for a special purpose.]]]

예를 들면, 많은 모듈을 포함하고 있는 jQuery 라이브러리가 `lib/assets/library_name` 디렉토리에 저장되어 있을 경우, `lib/assets/library_name/index.js` 파일은 이 라이브러리에 있는 모든 파일에 대한 manifest 파일로서 기능을 하게 됩니다. 이 파일은 필요로하는 모든 파일들에 대한 목록을 순차적으로 포함하거나 아니면 간단하게 `require_tree` 명령어를 포함할 수 있습니다. [[[For example, if you have a jQuery library with many modules, which is stored in `lib/assets/library_name`, the file `lib/assets/library_name/index.js` serves as the manifest for all files in this library. This file could include a list of all the required files in order, or a simple `require_tree` directive.]]]

이 라이브러리 전체는 다음과 같이 어플리케이션 manifest 파일에서 접근할 수 있습니다. [[[The library as a whole can be accessed in the site's application manifest like so:]]]

```js
//= require library_name
```

이렇게 하면 관리가 쉬워지고 관련된 코드들 다른 곳에 포함하기 전에 그룹화하여 명확하게 유지할 수 있게 해 줍니다. [[[This simplifies maintenance and keeps things clean by allowing related code to be grouped before inclusion elsewhere.]]]

### [Coding Links to Assets] 자원에 대한 링크 작성하기

Sprockets 자체는 자원에 접근하기 위한 메소드를 새로 추가하지 않지만, `javascript_include_tag`와 `stylesheet_link_tag` 메소드를 사용할 수 있습니다. [[[Sprockets does not add any new methods to access your assets - you still use the familiar `javascript_include_tag` and `stylesheet_link_tag`.]]]

```erb
<%= stylesheet_link_tag "application" %>
<%= javascript_include_tag "application" %>
```

일반적인 뷰파일에서, 다음과 같이 `assets/images` 디렉토리에 있는 이미지에 접근할 수 있습니다. [[[In regular views you can access images in the `assets/images` directory like this:]]]

```erb
<%= image_tag "rails.png" %>
```

어플리케이션에서 pipeline이 설정되어 있고 현재의 실행환경에서 작동하도록 되어 있다면, 이 이미지 파일은 Sprockets가 소스를 가공하여 제공하게 됩니다. 만약 특정 파일이 `public/assets/rails.png`에 위치한다면 이 때는 웹서버가 소스를 제공하게 됩니다. [[[Provided that the pipeline is enabled within your application (and not disabled in the current environment context), this file is served by Sprockets. If a file exists at `public/assets/rails.png` it is served by the web server.]]]

또 다른 방법으로, `public/assets/rails-af27b6a414e6da00003503148be9b409.png`와 같이 MD5 해시값을 가지는 파일에 대한 요청이 들어올 때도 동일하게 처리됩니다. 이러한 해시값이 어떻게 생성되는지는 본 가이드의 후반부에 있는 [In Production](#in-production)에서 다루게 됩니다. [[[Alternatively, a request for a file with an MD5 hash such as `public/assets/rails-af27b6a414e6da00003503148be9b409.png` is treated the same way. How these hashes are generated is covered in the [In Production](#in-production) section later on in this guide.]]]

또한 Sprockets는 표준 어플리케이션 경로와 레일스 엔진에서 추가하는 모든 경로를 포함하는 것으로 `config.assets.paths`에 명시된 경로를 검색할 것입니다. [[[Sprockets will also look through the paths specified in `config.assets.paths` which includes the standard application paths and any path added by Rails engines.]]]

이미지들은 필요할 경우 하위디렉토리로 위치시킬 수 있는데, 이 때는 태크에 디렉토리명을 명시하여 접근할 수 있습니다. [[[Images can also be organized into subdirectories if required, and they can be accessed by specifying the directory's name in the tag:]]]

```erb
<%= image_tag "icons/rails.png" %>
```

WARNING: 자원을 미리 컴파일해 두고자 할 경우(아래에서 [In Production](#in-production)을 보기 바랍니다), 존재하지 않는 특정 자원으로의 연결시도는 호출페이지에서 예외를 발생시킬 것입니다. 여기에는 빈 문자열로의 연결시도도 포함됩니다. 따라서, 데이터를 넘겨주는 `image_tag`와 기타 다른 헬퍼메소드를 사용할 때는 주의해야 합니다. [[[If you're precompiling your assets (see [In Production](#in-production) below), linking to an asset that does not exist will raise an exception in the calling page. This includes linking to a blank string. As such, be careful using `image_tag` and the other helpers with user-supplied data.]]]

#### [CSS and ERB] CSS 와 ERB

asset pipeline은 자동으로 자원내에 포함된 ERB 코드를 실행해 줍니다. 즉, 특정 CSS 자원에 `erb` 확장자를 붙일 경우(예, `application.css.erb`), `asset_path`와 같은 헬퍼메소드들을 CSS 문법내에서 사용할 수 있게 됩니다. [[[The asset pipeline automatically evaluates ERB. This means that if you add an `erb` extension to a CSS asset (for example, `application.css.erb`), then helpers like `asset_path` are available in your CSS rules:]]]

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

이것은 참조되는 특정 자원에 대한 경로를 작성해 줍니다. 이 예에서는, 참조하게 되는 `app/assets/images/image.png`와 같은 자원 로드 경로 중에 하나에 해당 이미지가 존재하는 것으로 이해하게 될 것입니다. 그러나 이 이미지 파일이 이미 fingerprinting되어 `public/assets` 디렉토리에 존재하게 될 경우에는 이 경로를 참조하게 됩니다. [[[This writes the path to the particular asset being referenced. In this example, it would make sense to have an image in one of the asset load paths, such as `app/assets/images/image.png`, which would be referenced here. If this image is already available in `public/assets` as a fingerprinted file, then that path is referenced.]]]

이미지 데이터를 직접 CSS 파일에 삽입하는 방법인 [data URI](http://en.wikipedia.org/wiki/Data_URI_scheme)를 이용하고자 할 경우, `asset_data_uri` 헬퍼메소드를 이용할 수 있습니다. [[[If you want to use a [data URI](http://en.wikipedia.org/wiki/Data_URI_scheme) — a method of embedding the image data directly into the CSS file — you can use the `asset_data_uri` helper.]]]

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

위 코드라인은 정해진 포맷형태로 작성된 데이터 URI를 CSS 소스파일로 삽입해 줍니다. [[[This inserts a correctly-formatted data URI into the CSS source.]]]

주의할 것은 닫는 태크로 `-%>` 와 같이 `-`를 추가한 형태를 사용해서는 안된다는 것입니다(에러발생함). 반드시 `%>`로 닫아 줘야 한다는 것입니다. [[[Note that the closing tag cannot be of the style `-%>`.]]]

#### [CSS and Sass] CSS 와 Sass

asset pipeline을 사용할 때는, 자원에 대한 경로를 다시 작성해야 하며, 이미지, 폰트, 비디오, 오디오, 자바스크립트, 스타일시트 파일에서 `sass-rails` 젬이 제공해 주는 `-url`과 `-path` 헬퍼메소드(sass로 작성시에는 하이픈으로 연결, 루비로 작성시에는 밑줄로 연결)를 사용하면 됩니다. [[[When using the asset pipeline, paths to assets must be re-written and `sass-rails` provides `-url` and `-path` helpers (hyphenated in Sass, underscored in Ruby) for the following asset classes: image, font, video, audio, JavaScript and stylesheet.]]]

* `image-url("rails.png")` becomes `url(/assets/rails.png)`
* `image-path("rails.png")` becomes `"/assets/rails.png"`.

더 일반적인 형태를 사용할 수 있지만 이 때는 자원경로와 자원의 종류를 모두 명시해 주어야 합니다. [[[The more generic form can also be used but the asset path and class must both be specified:]]]

* `asset-url("rails.png", image)` becomes `url(/assets/rails.png)`
* `asset-path("rails.png", image)` becomes `"/assets/rails.png"`

#### [JavaScript/CoffeeScript and ERB] JavaScript/CoffeeScript 와 ERB

자바스크립트 자원에 `erb` 확장자를 붙여 `application.js.erb`와 같이 만들어 주면, 자바스크립트 코드내에서 `asset_path` 헬퍼메소드를 사용할 수 있습니다. [[[If you add an `erb` extension to a JavaScript asset, making it something such as `application.js.erb`, then you can use the `asset_path` helper in your JavaScript code:]]]

```js
$('#logo').attr({
  src: "<%= asset_path('logo.png') %>"
});
```

위의 코드는 참조하게 될 특정 자원에 대한 경로를 작성해 줍니다. [[[This writes the path to the particular asset being referenced.]]]

같은 원리로, CoffeeScript 파일에 `erb` 확장자를 붙이면(예, `application.js.coffee.erb`), `asset_path` 헬퍼메소드를 사용할 수 있게 됩니다. [[[Similarly, you can use the `asset_path` helper in CoffeeScript files with `erb` extension (e.g., `application.js.coffee.erb`):]]]

```js
$('#logo').attr src: "<%= asset_path('logo.png') %>"
```

### [Manifest Files and Directives] Manifest 파일과 지시어들

Sprockets는 manifest 파일을 이용해서 어떤 자원들을 포함해서 웹서버로 제공할 것인지를 결정하게 됩니다. 이러한 manifest 파일들은 _전용지시어_ 를 포함하는데, 이 지시어는 Sprockets에게 단일 CSS 또는 자바스크립트 파일을 만드는데 어떤 파일들을 필요로하는지 알려주게 됩니다. 이 지시어를 통해서 Sprockets는 명시된 파일들을 로드해서 필요한 경우 일련의 처리과정을 거쳐서 하나의 단일 파일로 합치고, `Rails.application.config.assets.compress`이 true로 설정되어 있을 경우, 압축도 하게 됩니다. 이와 같이 여러개의 파일보다 단일 파일을 제공하게 되면, 브라우저가 자원에 대한 요청수를 줄일 수 있어 페이지 로드 시간을 크게 줄일 수 있게 됩니다. 또한, 압축과정을 거치게 되면 파일크기도 줄일 수 있어 브라우저가 보다 빠르게 파일을 다운로드할 수 있게 해 줍니다. [[[Sprockets uses manifest files to determine which assets to include and serve. These manifest files contain _directives_ — instructions that tell Sprockets which files to require in order to build a single CSS or JavaScript file. With these directives, Sprockets loads the files specified, processes them if necessary, concatenates them into one single file and then compresses them (if `Rails.application.config.assets.compress` is true). By serving one file rather than many, the load time of pages can be greatly reduced because the browser makes fewer requests. Compression also reduces the file size enabling the browser to download it faster.]]]

예를 들어, 새로 생성한 레일스 어플리케이션은 아래와 같은 코드라인을 포함하는, 디폴트로 작성되는, `app/assets/javascripts/application.js` 파일을 가지게 됩니다. [[[For example, a new Rails application includes a default `app/assets/javascripts/application.js` file which contains the following lines:]]]

```js
// ...
//= require jquery
//= require jquery_ujs
//= require_tree .
```

자바스크립트 파일에서는 지시어가 `//=`로 시작합니다. 위의 예에서는, `require`와 `require_tree` 지시어를 사용하고 있습니다. `require` 지시어를 사용하면 Sprockets에게 필요로 하는 파일들을 알려주게 됩니다. 여기서는 Sprockets가 검색하게되는 경로상에 존재하는 `jquery.js`와 `jquery_ujs.js` 파일을 필요로 하게 됩니다. 이때 명시적으로 파일의 확장자까지 지정할 필요는 없습니다. Sprockets가 하나의 `.js` 파일내에서 require되는 파일들이 `.js` 확장자를 가지는 것으로 가정합니다. [[[In JavaScript files, the directives begin with `//=`. In this case, the file is using the `require` and the `require_tree` directives. The `require` directive is used to tell Sprockets the files that you wish to require. Here, you are requiring the files `jquery.js` and `jquery_ujs.js` that are available somewhere in the search path for Sprockets. You need not supply the extensions explicitly. Sprockets assumes you are requiring a `.js` file when done from within a `.js` file.]]]

`require_tree` 지시어는 Sprockets에게, 특정 디렉토리에 있는 _모든_ 자바스크립트 파일들을 반복적으로 포함한 후 결과물로 만들어지도록 해 줍니다. 경로명을 지정할 때는 해당 manifest 파일에 대한 상대경로로 지정해야만 합니다. 하부디렉토리에 대한 반복동작을 하지 않고 지정한 디렉토리에 있는 모든 자바스크립트 파일만 포함하고자 할 때는 `require_directory` 지시어를 사용할 수 있습니다. [[[The `require_tree` directive tells Sprockets to recursively include _all_ JavaScript files in the specified directory into the output. These paths must be specified relative to the manifest file. You can also use the `require_directory` directive which includes all JavaScript files only in the directory specified, without recursion.]]]

지시어는 위에서 아래로 처리되지만, `requre_tree` 지시어가 포함하는 파일들의 순서는 명시되지 않게 됩니다. 따라서 이들사이에 특정 순서에 의존해서는 안된다는 것입니다. 만약 최종적으로 합쳐진 파일내에서 어떤 특정 자바스크립트들이 다른 것들보다 위에 위치해야 할 필요가 있을 경우에는, manifest 파일에서 이 파일들을 먼저 require해야 합니다. 주목할 것은 `require` 지시어군은 결과물에서 동일한 파일들이 두번 포함되지 않게 합니다. [[[Directives are processed top to bottom, but the order in which files are included by `require_tree` is unspecified. You should not rely on any particular order among those. If you need to ensure some particular JavaScript ends up above some other in the concatenated file, require the prerequisite file first in the manifest. Note that the family of `require` directives prevents files from being included twice in the output.]]]

또한 레일스는 디폴트로 아래의 코드라인을 포함하는 `app/assets/stylesheets/application.css` 파일을 만들어 줍니다. [[[Rails also creates a default `app/assets/stylesheets/application.css` file which contains these lines:]]]

```js
/* ...
*= require_self
*= require_tree .
*/
```

자바스크립트 파일에서 작동하는 지시어들은 스타일시트 파일에서도 작동합니다. 이때는 자바스크립트 파일이 아니라 스타일시트 파일이 포함하게 됩니다. CSS manifest 파일에서 `require_tree` 지시어는 자바스크립트 파일에서와 동일하게 작동하여 현재의 디렉토리에 있는 모든 스타일시트 파일들을 require하게 됩니다. [[[The directives that work in the JavaScript files also work in stylesheets (though obviously including stylesheets rather than JavaScript files). The `require_tree` directive in a CSS manifest works the same way as the JavaScript one, requiring all stylesheets from the current directory.]]]

위의 예에서, `require_self` 지시어가 사용되었습니다. 이 지시어는 `require_self`가 호출되는 정확한 위치에, 있을 경우, 현재의 파일내에 포함된 CSS를 두게 됩니다. `require_self` 지시어가 한번 이상 호출된다면 마지막에 호출된 곳에 (현재 파일에 포함된) CSS가 위치하게 됩니다. [[[In this example `require_self` is used. This puts the CSS contained within the file (if any) at the precise location of the `require_self` call. If `require_self` is called more than once, only the last call is respected.]]]

NOTE. 다수의 Sass 파일을 사용하고자 할 경우에는, Sprockets 지시어를 사용하는 대신, [Sass `@import` rule](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#import)를 일반적으로 사용해야 합니다. Sprockets  지시어를 사용할 경우 모든 Sass 파일들은 각각 자신의 영역내에 존재하게 됩니다. 따라서 변수나 믹신들은 자신들이 정의된 문서내에서만 사용할 수 있게 되는 것입니다. [[[If you want to use multiple Sass files, you should generally use the [Sass `@import` rule](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#import) instead of these Sprockets directives. Using Sprockets directives all Sass files exist within their own scope, making variables or mixins only available within the document they were defined in.]]]

하나 이상의 manifest 파일을 가질 수 있습니다. 예를 들어, `admin.css`와 `admin.js` manifest 파일은 어플리케이션의 관리자 부분에서만 사용하기 위한 JS 와 CSS 파일들을 포함하도록 할 수 있을 것입니다. [[[You can have as many manifest files as you need. For example the `admin.css` and `admin.js` manifest could contain the JS and CSS files that are used for the admin section of an application.]]]

위에서 언급한 파일들의 require 순서에 대해서도 동일하게 적용됩니다. 특히, 파일들을 하나씩 명시하면 그 순서에 따라 컴파일됩니다. 예를 들어, 아래와 같이 3개의 CSS 파일을 함께 합칠 수 있습니다. [[[The same remarks about ordering made above apply. In particular, you can specify individual files and they are compiled in the order specified. For example, you might concatenate three CSS files together this way:]]]

```js
/* ...
*= require reset
*= require layout
*= require chrome
*/
```


### [Preprocessing] 사전처리하기

자원에서 사용하는 파일확장자는 어떤 사전처리기를 사용할지를 결정해 줍니다. 디폴트 레일스 젬셋으로 컨트롤러나 scaffold를 생성할 때 일반적인 자바스크립트와 CSS 파일 대신에 CoffeeScript 파일과 SCSS 파일이 생성됩니다. 이전의 예에서는 `projects`라는 컨트롤러가 있는데, 이것은 `app/assets/javascripts/projects.js.coffee`와 `app/assets/stylesheets/projects.css.scss` 파일을 생성했습니다. [[[The file extensions used on an asset determine what preprocessing is applied. When a controller or a scaffold is generated with the default Rails gemset, a CoffeeScript file and a SCSS file are generated in place of a regular JavaScript and CSS file. The example used before was a controller called "projects", which generated an `app/assets/javascripts/projects.js.coffee` and an `app/assets/stylesheets/projects.css.scss` file.]]]

이들 파일들이 요청될 때, `coffee-script`와 `sass` 젬이 제공하는 처리기에 의해서 처리된 후 각각 자바스크립트와 CSS파일로서 브라우져로 보내지게 됩니다. [[[When these files are requested, they are processed by the processors provided by the `coffee-script` and `sass` gems and then sent back to the browser as JavaScript and CSS respectively.]]]

이러한 사전처리과정은 다른 파일 확장자를 추가하므로써 추가될 수 있는데, 각각 확장자는의 처리순서는 오른쪽에서 왼쪽 방향입니다. 이러한 확장자는 전처리기를 적용하는 순서대로 사용해야 합니다. 예를 들어, `app/assets/stylesheets/projects.css.scss.erb` 파일은 제일먼저 ERB로, 이후에 SCSS로 전처리되고, 마지막에 CSS 파일로 제공됩니다. 자바스크립트 파일에 동일하게 적용되어서, `app/assets/javascripts/projects.js.coffee.erb` 파일은 먼저 ERB로 처리되고 나서 CoffeeScript로 처리된 후 최종적으로는 자바스크립트로 제공됩니다. [[[Additional layers of preprocessing can be requested by adding other extensions, where each extension is processed in a right-to-left manner. These should be used in the order the processing should be applied. For example, a stylesheet called `app/assets/stylesheets/projects.css.scss.erb` is first processed as ERB, then SCSS, and finally served as CSS. The same applies to a JavaScript file — `app/assets/javascripts/projects.js.coffee.erb` is processed as ERB, then CoffeeScript, and served as JavaScript.]]]

기억해 둘 것은, 이러한 사전처리기들의 적용순서라는 것입니다. 예를 들어, `app/assets/javascripts/projects.js.erb.coffee` 파일을 처리할 때 먼저 CoffeeScript로 처리되어야 하는데, CoffeeScript는 ERB 코드를 알지 못하기 때문에 실행시 문제가 발생하게 됩니다. [[[Keep in mind that the order of these preprocessors is important. For example, if you called your JavaScript file `app/assets/javascripts/projects.js.erb.coffee` then it would be processed with the CoffeeScript interpreter first, which wouldn't understand ERB and therefore you would run into problems.]]]

[In Development] 개발환경에서
--------------

개발모드에서는 자원들이 manifest 파일에 명시된 순서대로 별도의 파일로서 제공됩니다. [[[In development mode, assets are served as separate files in the order they are specified in the manifest file.]]]

아래의 `app/assets/javascripts/application.js` manifest 파일은 [[[This manifest `app/assets/javascripts/application.js`:]]]

```js
//= require core
//= require projects
//= require tickets
```

아래의 HTML을 생성해 줄 것입니다. [[[would generate this HTML:]]]

```html
<script src="/assets/core.js?body=1"></script>
<script src="/assets/projects.js?body=1"></script>
<script src="/assets/tickets.js?body=1"></script>
```

`body` 파라메터는 Sprockets에서 필요로하는 것입니다. [[[The `body` param is required by Sprockets.]]]

### [Turning Debugging Off] 디버깅 해제하기

`config/environments/development.rb` 파일에 아래와 같은 코드라인을 추가해서 업데이트해 주면 디버그 모드를 해제할 수 있습니다. [[[You can turn off debug mode by updating `config/environments/development.rb` to include:]]]

```ruby
config.assets.debug = false
```

이와 같이 디버그 모드가 해제된 상태에서, Sprockets는 모든 파일을 합친 후에 필요한 사전처리기를 실행하게 됩니다. 디버그 모드가 해제되면, 위의 manifest 파일은 대신에 아래와 같이 코드를 생성해 줄 것입니다. [[[When debug mode is off, Sprockets concatenates and runs the necessary preprocessors on all files. With debug mode turned off the manifest above would generate instead:]]]

```html
<script src="/assets/application.js"></script>
```

자원들은 서버가 시작된 후 최초의 요청이 들어올 때 컴파일되고 캐시됩니다. Sprockets는 이어서 들어오는 요청에 대해서 요청 오버헤드를 줄이기 위해서 `must-revaludate` Cache-Control HTTP 헤더를 설정하게 되는데 이로 인해 브라우저에서는 304 (Not Modified) 응답을 받게 됩니다. [[[Assets are compiled and cached on the first request after the server is started. Sprockets sets a `must-revalidate` Cache-Control HTTP header to reduce request overhead on subsequent requests — on these the browser gets a 304 (Not Modified) response.]]]

요청 중간에 manifest 파일내에 포함되는 파일 중에 하나가 변경될 경우에, 서버는 새로 컴파일된 파일을 제공하게 됩니다. [[[If any of the files in the manifest have changed between requests, the server responds with a new compiled file.]]]

디버그 모드는 레일스 헬퍼메소드를 이용하여 설정할 수도 있습니다. [[[Debug mode can also be enabled in the Rails helper methods:]]]

```erb
<%= stylesheet_link_tag "application", debug: true %>
<%= javascript_include_tag "application", debug: true %>
```

`:debug` 옵션은 디버그 모드가 설정된 상태에서는 불필요하게 됩니다. [[[The `:debug` option is redundant if debug mode is on.]]]

의도한 바대로 작동하는지를 확인하기 위해 개발모드에서도 자원을 압축해 볼 수 있고 디버그 목적으로 필요시에 압축을 해제할 수도 있을 것입니다. [[[You could potentially also enable compression in development mode as a sanity check, and disable it on-demand as required for debugging.]]]

[In Production] 운영환경에서
-------------

운영환경에서 레일스는 위에서 설명한 바와 같이 fingerprinting 기법을 사용합니다. 디폴트로, 레일스는 자원들이 사전 컴파일되었고 웹서버가 static 자원으로 제공할 것이라고 가정합니다. [[[In the production environment Rails uses the fingerprinting scheme outlined above. By default Rails assumes that assets have been precompiled and will be served as static assets by your web server.]]]

사전컴파일 단계에서 컴파일된 파일의 내용에 근거해서 MD5 해시값이 생성되고 디스크에 기록될 때 파일명에 삽입됩니다. 레일스는 이와 같이 fingerprinting된 파일명을 manifest 이름 대신 사용하게 됩니다. [[[During the precompilation phase an MD5 is generated from the contents of the compiled files, and inserted into the filenames as they are written to disc. These fingerprinted names are used by the Rails helpers in place of the manifest name.]]]

예를 들어 아래의 코드라인은, [[[For example this:]]]

```erb
<%= javascript_include_tag "application" %>
<%= stylesheet_link_tag "application" %>
```

다음과 같은 HTML 태크를 생성합니다. [[[generates something like this:]]]

```html
<script src="/assets/application-908e25f4bf641868d8683022a5b62f54.js"></script>
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" media="screen" rel="stylesheet" />
```

Note: asset pipeline을 사용하면, 더 이상 :cache와 :concat 옵션을 사용할 필요가 없기 때문에, `javascript_include_tag`와 `stylesheet_link_tag`에서 이들 옵션을 제거해야 합니다. [[[with the Asset Pipeline the :cache and :concat options aren't used anymore, delete these options from the `javascript_include_tag` and `stylesheet_link_tag`.]]]


fingerprinting 기능은 `config.assets.digest` 설정으로 제어할 수 있습니다. 이 설정 항목은 운영환경에서 디폴트로 `true` 값을, 기타 다른 환경에서는 `false` 값을 가집니다. [[[The fingerprinting behavior is controlled by the setting of `config.assets.digest` setting in Rails (which defaults to `true` for production and `false` for everything else).]]]

NOTE: 일반적인 환경에서는 디폴트 옵션을 변경해서는 안됩니다. 파일명에 해시값이 없고 far-future 헤더가 설정되면, 원격 클라이언트가 파일내용이 변경되었음에도 불구하고 해당 파일을 다시 불러오지 못하게 될 것입니다. [[[Under normal circumstances the default option should not be changed. If there are no digests in the filenames, and far-future headers are set, remote clients will never know to refetch the files when their content changes.]]]

### [Precompiling Assets] 자원 사전컴파일하기

pipeline상에 있는 자원 manifest 파일가 기타 다른 파일들을 컴파일해서 디스크로 저장하도록 해 주는 rake 작업이 레일스에 번들로 내장되어 배포됩니다. [[[Rails comes bundled with a rake task to compile the asset manifests and other files in the pipeline to the disk.]]]

컴파일된 자원들은 `config.assets.prefix`에 명시된 위치로 저장되는데, 디폴트로 `public/assets` 디렉토리가 해당됩니다. [[[Compiled assets are written to the location specified in `config.assets.prefix`. By default, this is the `public/assets` directory.]]]

배포 중에 서버상에서 이 작업을 수행하여 컴파일 버전의 자원들을 서버상에 직접 생성할 수 있습니다. 로컬머신에서 컴파일하는 것에 대한 정보는 다음 섹션을 보기 바랍니다. [[[You can call this task on the server during deployment to create compiled versions of your assets directly on the server. See the next section for information on compiling locally.]]]

rake 작업은 다음과 같습니다. [[[The rake task is:]]]

```bash
$ RAILS_ENV=production bundle exec rake assets:precompile
```

보다 신속하게 자원을 사전컴파일하기 위해서, `config/application.rb` 파일에 있는 `config.assets.initialize_on_precompile`을 false 값으로 설정할 경우, 어플리케이션을 일부분만 로드할 수 있습니다. 그러나 이런 경우에는 템플릿 파일들이 어플리케이션내 객체나 메소드를 인식할 수 없게 됩니다. **Heroku 경우 이 값을 false로 지정해야 합니다. [[[For faster asset precompiles, you can partially load your application by setting `config.assets.initialize_on_precompile` to false in `config/application.rb`, though in that case templates cannot see application objects or methods. **Heroku requires this to be false.**]]]

WARNING: `config.assets.initialize_on_precompile` 값을 false 로 설정할 경우, 배포전에 로컬머신에서 `rake assets:precompile` 명령으로 확인해 둘 필요가 있습니다. 이 값을 설정하더라도 자원들을 여전히 개발환경의 영역에 있기 때문에, 자원이 어플리케이션 객체나 메소드를 참조할 때 버그가 나타날 수 있습니다. 이 값을 변경할 때 엔진에도 영향을 미치게 됩니다. 엔진은 또한 사전컴파일을 위해서 자원을 정의하기도 합니다. 전체 어플리케이션 환경이 로드되기 않으므로 인해, 엔진이나 다른 젬들도 로드되지 않을 수 있습니다. 따라서 이러한 이유로 자원이 누락되게 됩니다. [[[If you set `config.assets.initialize_on_precompile` to false, be sure to test `rake assets:precompile` locally before deploying. It may expose bugs where your assets reference application objects or methods, since those are still in scope in development mode regardless of the value of this flag. Changing this flag also affects engines. Engines can define assets for precompilation as well. Since the complete environment is not loaded, engines (or other gems) will not be loaded, which can cause missing assets.]]]

Capistrano(v2.15.1 부터)에는 배포시 이러한 문제점을 처리하기 위한 레시피를 제공해 줍니다. 아래와 같은 코드라인을 `Capfile` 추가해 줍니다. [[[Capistrano (v2.15.1 and above) includes a recipe to handle this in deployment. Add the following line to `Capfile`:]]]

```ruby
load 'deploy/assets'
```

이것은 `config.assets.prefix`에 평시된 폴더를 서버상의 `shared/assets` 디렉토리로 연결해 줍니다. 이미 이 공유 폴더를 사용하고 있다면 별도의 배포 작업을 작성할 필요가 있을 것입니다. [[[This links the folder specified in `config.assets.prefix` to `shared/assets`. If you already use this shared folder you'll need to write your own deployment task.]]]

중요한 것은, 이 폴더는 배포 버전마다 공유되기 때문에 이전 컴파일 버전의 자원을 참조하는 원격상의 캐시된 페이지들이 수명기간 동안 이전 자원을 참조할 수 있게 된다는 것입니다. [[[It is important that this folder is shared between deployments so that remotely cached pages that reference the old compiled assets still work for the life of the cached page.]]]

NOTE. 로컬머신에서 자원을 사전컴파일할 경우, Gemfile상의 assets 그룹에 명시된 젬들이 설치되는 것을 피하기 위해 서버 상에서 `bundle install --without assets` 명령을 사용할 수 있습니다. [[[If you are precompiling your assets locally, you can use `bundle install --without assets` on the server to avoid installing the assets gems (the gems in the assets group in the Gemfile).]]]

컴파일하는 파일들에 대한 디폴트 매치 정규식은 `application.js`, `application.css`, 그리고 모든 non-JS/CSS 파일들을 포함하고 모든 이미지 자원들도 자동으로 포함하게 될 것입니다. [[[The default matcher for compiling files includes `application.js`, `application.css` and all non-JS/CSS files (this will include all image assets automatically):]]]

```ruby
[ Proc.new { |path| !%w(.js .css).include?(File.extname(path)) }, /application.(css|js)$/ ]
```

NOTE. 매치 정규식에 포함되는 파일들(과 아래에 있는 precompile 배열의 다른 멤버들)이 최종 컴파일 파일 이름에 적용됩니다. 즉, static JS/CSS 파일뿐만 아니라 JS/CSS로 컴파일되는 모든 파일은 제외된다는 것입니다. 예를 들면, `.coffee`와 `.scss` 파일들은 JS/CSS 파일로 컴파일될 때 자동으로 포함되지 **않는다** 는 것입니다. [[[The matcher (and other members of the precompile array; see below) is applied to final compiled file names. This means that anything that compiles to JS/CSS is excluded, as well as raw JS/CSS files; for example, `.coffee` and `.scss` files are **not** automatically included as they compile to JS/CSS.]]]

다른 manifest 파일들이나 개별 스타일시트와 자바스크립트 파일들을 포함고자할 경우에는, `config/application.rb` 파일내의 `precompile` 배열에 이들을 추가해 줄 수 있습니다. [[[If you have other manifests or individual stylesheets and JavaScript files to include, you can add them to the `precompile` array in `config/application.rb`:]]]

```ruby
config.assets.precompile += ['admin.js', 'admin.css', 'swfObject.js']
```

또는 다음과 같이 모든 자원을 사전컴파일하도록 할 수 있습니다. [[[Or you can opt to precompile all assets with something like this:]]]

```ruby
# config/application.rb
config.assets.precompile << Proc.new do |path|
  if path =~ /\.(css|js)\z/
    full_path = Rails.application.assets.resolve(path).to_path
    app_assets_path = Rails.root.join('app', 'assets').to_path
    if full_path.starts_with? app_assets_path
      puts "including asset: " + full_path
      true
    else
      puts "excluding asset: " + full_path
      false
    end
  else
    false
  end
end
```

NOTE. precompile 배열에 Sass 또는 CoffeeScript 파일을 추가할 경우에도, 컴파일하여 만들어지는 파일명이 js 또는 css로 끝나도록 반드시 명시해 주어야 합니다. [[[Always specify an expected compiled filename that ends with js or css, even if you want to add Sass or CoffeeScript files to the precompile array.]]]

또한 rake 작업은 모든 자원과 각각의 fingerprint 버전에 대한 목록을 포함하는 `manifest.yml` 파일을 생성하게 됩니다. 레일스 헬퍼메소드는 이 파일을 이용하여 외부로 들어오는 매칭 요청을 Sprockets로 넘기지 못하게 합니다. 전형적인 manifest 파일은 다음과 같은 모습을 하게 가지게 됩니다. [[[The rake task also generates a `manifest.yml` that contains a list with all your assets and their respective fingerprints. This is used by the Rails helper methods to avoid handing the mapping requests back to Sprockets. A typical manifest file looks like:]]]

```yaml
---
rails.png: rails-bd9ad5a560b5a3a7be0808c5cd76a798.png
jquery-ui.min.js: jquery-ui-7e33882a28fc84ad0e0e47e46cbf901c.min.js
jquery.min.js: jquery-8a50feed8d29566738ad005e19fe1c2d.min.js
application.js: application-3fdab497b8fb70d20cfc5495239dfc29.js
application.css: application-8af74128f904600e41a6e39241464e03.css
```

이 manifest 파일의 디폴트 위치는 `config.assets.prefix`에 명시된 위치의 루트입니다. 디폴트로 이 값은 `/assets` 입니다. [[[The default location for the manifest is the root of the location specified in `config.assets.prefix` ('/assets' by default).]]]

NOTE: 운영환경에서 사전컴파일된 파일이 없는 경우에, 해당 파일명을 알려주는 `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` 예외가 발생하게 될 것입니다. [[[If there are missing precompiled files in production you will get an `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` exception indicating the name of the missing file(s).]]]

#### Far-future Expires Header

사전컴파일된 자원들은 파일시스템에 존재하게 되며, 웹서버가 직접 제공하게 됩니다. 이 파일들은 디폴트로 far-future 헤더를 가지지 않으며, 따라서 fingerprinting 기능을 시작하기 위해서는 서버 설정을 업데이트해서 추가해 주어야 할 것입니다. [[[Precompiled assets exist on the filesystem and are served directly by your web server. They do not have far-future headers by default, so to get the benefit of fingerprinting you'll have to update your server configuration to add them.]]]

아파치 서버용 [[[For Apache:]]]

```apache
# The Expires* directives requires the Apache module `mod_expires` to be enabled.
<Location /assets/>
  # Use of ETag is discouraged when Last-Modified is present
  Header unset ETag
  FileETag None
  # RFC says only cache for 1 year
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

Nginx 서버용 [[[For nginx:]]]

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
  break;
}
```

#### [GZip Compression] GZip 압축

자원 파일들이 사전컴파일될 때, Sprockets는 자원에 대한 [gzipped](http://en.wikipedia.org/wiki/Gzip)(.gz) 버전도 생성합니다. 웹서버는 대개 절충안으로 중등도 정도의 압축율을 사용하도록 설정되어 있지만, 일단 사전컴파일이 일어나면, Sprockets는 최대의 압축율을 사용해서 데이터 전송크기를 최소한으로 줄이게 됩니다. 한편, 웹서버가 압축되지 않은 파일들을 압축하여 사용하기 보다는 디스크에 저장된 상태에서 직접 압축된 내용을 제공할 수 있도록 할 수 있습니다. [[[When files are precompiled, Sprockets also creates a [gzipped](http://en.wikipedia.org/wiki/Gzip) (.gz) version of your assets. Web servers are typically configured to use a moderate compression ratio as a compromise, but since precompilation happens once, Sprockets uses the maximum compression ratio, thus reducing the size of the data transfer to the minimum. On the other hand, web servers can be configured to serve compressed content directly from disk, rather than deflating non-compressed files themselves.]]]

Nginx 서버의 경우는 `gzip_static` 옵션을 설정하여 자동으로 이러한 일을 할 수 있도록 합니다. [[[Nginx is able to do this automatically enabling `gzip_static`:]]]

```nginx
location ~ ^/(assets)/  {
  root /path/to/public;
  gzip_static on; # to serve pre-gzipped version
  expires max;
  add_header Cache-Control public;
}
```

이 지시어는 이러한 기능을 제공하는 코어 모듈이 Nginx 웹서버에 컴파일되어 있을 때 사용할 수 있습니다. 우분투 패키지들, 심지어 `nginx-light`의 경우도 이 모듈이 컴파일되어 있습니다. 다른 방법으로는 직접 수작업으로 컴파일 작업을 해야할 필요가 있을 것입니다. [[[This directive is available if the core module that provides this feature was compiled with the web server. Ubuntu packages, even `nginx-light` have the module compiled. Otherwise, you may need to perform a manual compilation:]]]

```bash
./configure --with-http_gzip_static_module
```

Phusion Passenger와 함께 nginx 서버를 컴파일할 경우에는 이 옵션에 대한 프롬프트가 나타날 때 그냥 넘어가야할 필요가 있을 것입니다. [[[If you're compiling nginx with Phusion Passenger you'll need to pass that option when prompted.]]]

아파치 서버에 대한 확실한 설정도 가능하지만 약간의 트릭이 필요하기 때문에 구글검색을 해 보기 바랍니다. (또는 이에 대한 좋은 설정 예가 있다면 이 가이드를 업데이트하는데 도움을 주기 바랍니다. [[[A robust configuration for Apache is possible but tricky; please Google around. (Or help update this Guide if you have a good example configuration for Apache.)]]]

### [Local Precompilation] 로컬머신에서 사전컴파일 작업

로컬머신에서 사전컴파일 작업을 해야하는 몇가지 이유가 있습니다. [[[There are several reasons why you might want to precompile your assets locally. Among them are:]]]

* 운영서버 파일시스템에 대한 쓰기권한이 없을 경우 [[[You may not have write access to your production file system.]]]

* 한대 이상의 서버에 배포를 해야할 경우, 중복된 작업을 피하기 위해서 [[[You may be deploying to more than one server, and want to avoid the duplication of work.]]]

* 자원에 대한 변경작업이 없는 배포작업을 자주해야할 경우 [[[You may be doing frequent deploys that do not include asset changes.]]]

로컬머신에서의 컴파일작업으로 컴파일된 파일들을 소스 컨트롤에 추가해서 정상적인 방법으로 배포할 수 있게 됩니다. [[[Local compilation allows you to commit the compiled files into source control, and deploy as normal.]]]

그러나 주의해야 할 사항이 두가지 있습니다. [[[There are two caveats:]]]

* 자원을 사전컴파일하는 Capistrano 배포작업을 실행해서는 안됩니다. [[[You must not run the Capistrano deployment task that precompiles assets.]]]

* 아래의 두가지 어플리케이션 설정내용을 변경해야 합니다. [[[You must change the following two application configuration settings.]]]

`config/environments/development.rb` 파일에 아래의 코드라인을 추가합니다. [[[In `config/environments/development.rb`, place the following line:]]]

```ruby
config.assets.prefix = "/dev-assets"
```

또한, `application.rb` 파일에서는 아래의 코드라인을 추가해 줄 필요가 있습니다. [[[You will also need this in application.rb:]]]

```ruby
config.assets.initialize_on_precompile = false
```

`prefix`를 변경하면 개발모드에서 자원을 해당 주소로 연결하여, 모든 요청을 Sprockets로 보내 줍니다. 그러나 운영환경에서는 `prefix`가 여전히 `/assets`로 설정됩니다. 이와 같이 `prefix`를 변경하지 않으면, 어플리케이션은 개발모드에서 `public/assets`로부터 사전컴파일된 자원들을 제공하게 되고 재차 자원을 컴파일해야만 로컬에서 변경한 내용들이 반영될 것입니다. [[[The `prefix` change makes Rails use a different URL for serving assets in development mode, and pass all requests to Sprockets. The prefix is still set to `/assets` in the production environment. Without this change, the application would serve the precompiled assets from `public/assets` in development, and you would not see any local changes until you compile assets again.]]]

`initialize_on_precompile` 설정을 변경하게 되면 레일스를 호출하지 않은 상태에서 사전컴파일 작업을 수행하도록 해 줍니다. 이것은 사전컴파일 작업이 운영모드에서는 디폴트로 수행되기 때문이며, 명시된 운영서버의 데이터베이스에 연결을 시도할 것입니다. 이 옵션을 설정한 상태에서 로컬머신에서 컴파일작업을 수행할 때 pipeline 파일에서 데이터베이스와 같은 레일스 리소스에 의존하는 코드를 작성할 수 없다는 것에 주의하기 바랍니다. [[[The `initialize_on_precompile` change tells the precompile task to run without invoking Rails. This is because the precompile task runs in production mode by default, and will attempt to connect to your specified production database. Please note that you cannot have code in pipeline files that relies on Rails resources (such as the database) when compiling locally with this option.]]]

또한 모든 압축엔진과 최소화엔진들이 개발시스템에서 사용할 수 있는지를 확인해 둘 필요가 있습니다. [[[You will also need to ensure that any compressors or minifiers are available on your development system.]]]

실제 작업시에, 이렇게 함으로써 로컬머신에서 사전컴파일 작업을 수행하여 작업 중인 디렉토리 구조에 파일을 저장하고 필요시에 소스관리 툴에 커밋을 할 수 있게 됩니다. 이와 같은 상황에서도 개발모드는 제대로 동작할 것입니다. [[[In practice, this will allow you to precompile locally, have those files in your working tree, and commit those files to source control when needed. Development mode will work as expected.]]]

### [Live Compilation] 실시간 컴파일 작업

어떤 상황에서는, 실시간 컴파일작업을 하기를 원할 때가 있습니다. 이런 모드에서는 pipeline상의 자원에 대한 모든 요청을 Sprockets가 직접 처리하게 됩니다. [[[In some circumstances you may wish to use live compilation. In this mode all requests for assets in the pipeline are handled by Sprockets directly.]]]

이 옵션을 사용하기 위해서는 아래와 같이 설정해 줍니다. [[[To enable this option set:]]]

```ruby
config.assets.compile = true
```

최초의 요청시에, 위에서 개발모드에서 언급한 바와 같이 자원들이 컴파일되고 캐시되며, 헬퍼메소드에서 사용되는 manifest 이름들은 MD5 해시값이 포함되도록 변경됩니다. [[[On the first request the assets are compiled and cached as outlined in development above, and the manifest names used in the helpers are altered to include the MD5 hash.]]]

또한 Sprockets는 `Cache-Control` HTTP 헤더를 `max-age=31536000`으로 설정합니다. 이것은 서버와 클라이언트 브라우저사이에 있는 모든 캐시에 대해서 제공되는 자원파일이 1년동안 캐시될 수 있다고 알려주게 됩니다. 이것은 서버로부터 이 자원에 대한 요청수를 줄이는 효과를 가져옵니다. 즉, 해당 자원이 로컬 브라운져상의 캐시나 어떤 중간 레이어의 캐시 상에 존재할 수 있도록 해 줍니다. [[[Sprockets also sets the `Cache-Control` HTTP header to `max-age=31536000`. This signals all caches between your server and the client browser that this content (the file served) can be cached for 1 year. The effect of this is to reduce the number of requests for this asset from your server; the asset has a good chance of being in the local browser cache or some intermediate cache.]]]

이러한 모드는 더 많은 메모리를 사용하게 되고 디폴트 상태보다 퍼포먼스가 좋지 않기 때문에 추천되지는 않습니다. [[[This mode uses more memory, performs more poorly than the default and is not recommended.]]]

기존의 자바스크립트 런타임이 없는 서버 시스템에 운영용 어플리케이션을 배포할 경우에는, 아래와 같이 Gemfile에 젬을 하나 추가해 주어야 합니다. [[[If you are deploying a production application to a system without any pre-existing JavaScript runtimes, you may want to add one to your Gemfile:]]]

```ruby
group :production do
  gem 'therubyracer'
end
```

### CDNs

자원이 CDN으로부터 제공될 때는, 영구적으로 캐시에 의존하지 않다는 것을 확인해야 합니다. 의존할 경우 문제를 야기할 수 있습니다. `config.action_controller.perform_caching = true`로 설정할 경우, Rack::Cache는 `Rails.cache`를 이용해서 자원들을 저장할 것입니다. 이것은 캐시가 빠른 속도로 가득차게 만들 수 있습니다. [[[If your assets are being served by a CDN, ensure they don't stick around in your cache forever. This can cause problems. If you use 
`config.action_controller.perform_caching = true`, Rack::Cache will use
`Rails.cache` to store assets. This can cause your cache to fill up quickly.]]]

모든 캐시는 상이하기 때문에, CDN이 캐싱작업을 다루는 방법을 알아야 하며 pipeline과 함께 제대로 동작하는 것을 확인해 두어야 합니다. 특별한 설정을 할 경우 이와 관련된 이상한 현상을 발견할 수도 있습니다. 예를 들어, HTTP 캐시로 디폴트 상태의 nginx를 사용할 경우는 특별한 문제가 발생하지 않게 됩니다. [[[Every cache is different, so evaluate how your CDN handles caching and make sure that it plays nicely with the pipeline. You may find quirks related to your specific set up, you may not. The defaults nginx uses, for example, should give you no problems when used as an HTTP cache.]]]

[Customizing the Pipeline] Pipeline 옵션변경하기
------------------------

### [CSS Compression] CSS 압축

현재로써 CSS를 압축하기 위한 옵션으로 한가지가 있는데 YUI 라는 것입니다. [YUI CSS compressor](http://developer.yahoo.com/yui/compressor/css.html)는 최소화 작업을 제공해 줍니다. [[[There is currently one option for compressing CSS, YUI. The [YUI CSS compressor](http://developer.yahoo.com/yui/compressor/css.html) provides minification.]]]

아래의 코드라인은 YUI 압축을 사용할 수 있게 해 주며 `yui-compression` 젬을 설치해 주어야 합니다. [[[The following line enables YUI compression, and requires the `yui-compressor` gem.]]]

```ruby
config.assets.css_compressor = :yui
```

이 때 `config.assets.compress`를 `true`로 설정해 주어야 CSS 압축을 사용할 수 있습니다. [[[The `config.assets.compress` must be set to `true` to enable CSS compression.]]]

### [JavaScript Compression] 자바스크립트 압축

자바스크립트 압축시 가능한 옵션으로는 `:closure`, `:uglifier`, `:yui` 가 있습니다. 사용하기 위해서는 각각에 대한 `closure-compiler`, `uglifier`, yui-compressor` 젬을 설치해야 합니다. [[[Possible options for JavaScript compression are `:closure`, `:uglifier` and `:yui`. These require the use of the `closure-compiler`, `uglifier` or `yui-compressor` gems, respectively.]]]

디폴트 Gemfile은 [uglifier](https://github.com/lautis/uglifier)을 포함하고 있습니다. 이 젬은 [UglifierJS](https://github.com/mishoo/UglifyJS)(NodeJS용으로 작성됨)를 루비에서 사용할 수 있도록 한 것입니다. 이 젬은 공백을 제거하여 압축합니다. 또한 `if`와 `else` 문을 가능한한 ternary 연산자(` ? : `)로 변경하는 등과 같은 최적화 작업도 수행하게 됩니다. [[[The default Gemfile includes [uglifier](https://github.com/lautis/uglifier). This gem wraps [UglifierJS](https://github.com/mishoo/UglifyJS) (written for NodeJS) in Ruby. It compresses your code by removing white space. It also includes other optimizations such as changing your `if` and `else` statements to ternary operators where possible.]]]

아래의 코드라인은 자바스크립트 압축을 위해 `uglifier`를 호출하게 됩니다. [[[The following line invokes `uglifier` for JavaScript compression.]]]

```ruby
config.assets.js_compressor = :uglifier
```

주의할 것은 자바스크립트 압축을 위해서는 `config.assets.compress`를 `true`값으로 지정해 주어야 한다는 것입니다. [[[Note that `config.assets.compress` must be set to `true` to enable JavaScript compression]]]

NOTE: `uglifier`를 사용하기 위해서 [ExecJS](https://github.com/sstephenson/execjs#readme)를 지원하는 런타임 모듈이 필요할 것입니다. Mac OS X 또는 윈도우 운영체제를 사용할 경우에는 이미 자바스크립트 런타임이 설치되어 있기 때문에 추가 작업이 필요없습니다. 모든 지원가능한 자바스크립트 런타임에 대한 정보를 원할 경우 [ExecJS](https://github.com/sstephenson/execjs#readme) 문서를 확인해 보기 바랍니다.  [[[You will need an [ExecJS](https://github.com/sstephenson/execjs#readme) supported runtime in order to use `uglifier`. If you are using Mac OS X or Windows you have a JavaScript runtime installed in your operating system. Check the [ExecJS](https://github.com/sstephenson/execjs#readme) documentation for information on all of the supported JavaScript runtimes.]]]

### [Using Your Own Compressor] 자신이 제작한 압축기 사용하기

CSS와 자바스크립트에 대한 압축기 config 셋팅에는 모든 객체를 지정할 수 있습니다. 단, 이 객체는 반드시 하나의 문자열 인수를 취해서 결과로 문자열을 반환하는 `compress` 메소드를 가지고 있어야 합니다.[[[The compressor config settings for CSS and JavaScript also take any object. This object must have a `compress` method that takes a string as the sole argument and it must return a string.]]]

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

이를 위해서, `application.rb` 파일에서 config 옵션에 새로운 객체를 넘겨 주어야 합니다.[[[To enable this, pass a new object to the config option in `application.rb`:]]]

```ruby
config.assets.css_compressor = Transformer.new
```


### [Changing the _assets_ Path] 자원 경로 변경하기

Sprockets가 디폴트로 사용하는 공개 경로는 `/assets` 입니다. [[[The public path that Sprockets uses by default is `/assets`.]]]

아래와 같이 이 값을 다른 것으로 변경할 수 있습니다. [[[This can be changed to something else:]]]

```ruby
config.assets.prefix = "/some_other_path"
```

이것은 asset pipeline을 사용하지 않았던 이전 버전의 프로젝트를 업데이트할 때와 이미 이 경로를 사용하고 있는 경우 또는, 새로운 리소스에 대해 이 경로를 사용하고자 할 때 편리하게 사용할 수 있는 옵션입니다. [[[This is a handy option if you are updating an older project that didn't use the asset pipeline and that already uses this path or you wish to use this path for a new resource.]]]

### [X-Sendfile Headers] X-Sendfile 헤더

X-Sendfile 헤더는 하나의 지시어로써 웹서버가 어플리케이션으로부터 오는 응답을 무시하고 대신에 디스크에 저장되어 있는 특정 파일을 제공할 수 있도록 해 줍니다. 이 옵션은 디폴트로 off 상태이지만, 서버가 해당 기능을 지원하는 경우 사용가능할 수 있습니다. 이와 같이 사용가능한 상태로 한 경우에는, 해당 파일을 제공하는 책임을 웹서버로 넘길 수 있어 보다 빠른 방법이 될 수 있습니다. [[[The X-Sendfile header is a directive to the web server to ignore the response from the application, and instead serve a specified file from disk. This option is off by default, but can be enabled if your server supports it. When enabled, this passes responsibility for serving the file to the web server, which is faster.]]]

아파치와 nginx 웹서버는 이 옵션을 지원합니다. 아래와 같이 `config/environments/production.rb` 파일에서 설정해 주면 됩니다. [[[Apache and nginx support this option, which can be enabled in `config/environments/production.rb`.]]]

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
```

WARNING: 기존의 어플리케이션을 업데이트하여 이 옵션을 사용하고자 한다면, `production.rb` 파일과 `application.rb`가 아닌 운영 속성을 가지는 다른 환경에만 이 설정 옵션을 조심스럽게 붙여넣기 해야 합니다. [[[If you are upgrading an existing application and intend to use this option, take care to paste this configuration option only into `production.rb` and any other environments you define with production behavior (not `application.rb`).]]]

[Assets Cache Store] 자원 캐시 저장소
------------------

디폴트 레일스 캐시 저장소는 개발과 운영환경에서 Sprockets가 자원을 캐시하기 위해서 사용하는 곳입니다. 이 장소는 `config.assets.cache_store` 설정을 변경하여 다른 것으로 바꿀 수 있습니다. [[[The default Rails cache store will be used by Sprockets to cache assets in development and production. This can be changed by setting `config.assets.cache_store`.]]]

```ruby
config.assets.cache_store = :memory_store
```

자원 캐시 저장소에 지정할 수 있는 옵션은 어플리케이션의 캐시 저장소와 동일합니다. [[[The options accepted by the assets cache store are the same as the application's cache store.]]]

```ruby
config.assets.cache_store = :memory_store, { size: 32.megabytes }
```

[Adding Assets to Your Gems] 자원을 젬에 추가하기
--------------------------

자원들을 젬의 형태로 외부 리소스로부터 가져 올 수도 있습니다. [[[Assets can also come from external sources in the form of gems.]]]

이에 대한 좋은 예가 바로 `jquery-rails` 젬인데 이것은 표준 자바스크립트 라이브러리 젬로써 레일스와 함께 내장되어 배포됩니다. 이 젬은 엔진 클래스를 포함하는데, 이것은 `Rails::Engine`으로부터 상속을 받게 됩니다. 따라서 이 젬에서 사용하는 디렉토리가 자원을 포함할 수 있고 이 엔진의 `app/assets`, `lib/assets`, `vendor/assets` 디렉토리가 Sprockets의 검색경로에 추가된다고 레일스에게 알려주게 됩니다. [[[A good example of this is the `jquery-rails` gem which comes with Rails as the standard JavaScript library gem. This gem contains an engine class which inherits from `Rails::Engine`. By doing this, Rails is informed that the directory for this gem may contain assets and the `app/assets`, `lib/assets` and `vendor/assets` directories of this engine are added to the search path of Sprockets.]]]

[Making Your Library or Gem a Pre-Processor] 라이브러리 또는 젬을 사전 처리기로 만들기
------------------------------------------

Sprockets는 다른 템플릿 작성 엔진에 대한 통상적인 인터페이스로 [Tilt](https://github.com/rtomayko/tilt)를 사용합니다. 보통, `Tilt::Template`을 상속한 후 `evaluate` 메소드를 재정의하여 최종 결과물을 반환하게 될 것입니다. 템플릿 소스는 `@code`에 저장됩니다. 더 많은 것을 알기 위해서 [`Tilt::Template`](https://github.com/rtomayko/tilt/blob/master/lib/tilt/template.rb) 소스들을 살펴보기 바랍니다. [[[As Sprockets uses [Tilt](https://github.com/rtomayko/tilt) as a generic interface to different templating engines, your gem should just implement the Tilt template protocol. Normally, you would subclass `Tilt::Template` and reimplement `evaluate` method to return final output. Template source is stored at `@code`. Have a look at [`Tilt::Template`](https://github.com/rtomayko/tilt/blob/master/lib/tilt/template.rb) sources to learn more.]]]

```ruby
module BangBang
  class Template < ::Tilt::Template
    # Adds a "!" to original template.
    def evaluate(scope, locals, &block)
      "#{@code}!"
    end
  end
end
```

이제 이 `Template` 클래스를 템플릿 파일에 대한 확장자와 연결을 시켜줍니다. [[[Now that you have a `Template` class, it's time to associate it with an extension for template files:]]]

```ruby
Sprockets.register_engine '.bang', BangBang::Template
```

[Upgrading from Old Versions of Rails] 이전 버전의 레일스로부터 업그레이드하기
------------------------------------

업그레이드할 때 약간의 문제가 발생합니다. 우선 `public/` 디렉토리에 있는 파일들을 새로운 위치로 이동시킵니다. 파일 종류에 따른 정확한 위치에 대한 설명은 이미 설명한 [자원의 구성](#asset-organization)을 보기 바랍니다. [[[There are a few issues when upgrading. The first is moving the files from `public/` to the new locations. See [Asset Organization](#asset-organization) above for guidance on the correct locations for different file types.]]]

다음으로, 자바스크립트 파일들이 중복되지 않도록 하는 것입니다. jQuery는 레일스 3.1버전부터 디폴트 자바스트립트 라이브러리로 포함되기 때문에 `jquery.js` 파일을 `app/assets` 디렉토리로 복사하는 별도의 작업이 필요치 않으며 레일스가 자동으로 포함시켜 줄 것입니다. [[[Next will be avoiding duplicate JavaScript files. Since jQuery is the default JavaScript library from Rails 3.1 onwards, you don't need to copy `jquery.js` into `app/assets` and it will be included automatically.]]]

세번째는, 환경 파일들을 올바른 디폴트 옵션으로 업데이트 해 주어야 합니다. 아래의 변경내용은 3.1.0 버전에서의 디폴트 내용을 보여 줍니다. [[[The third is updating the various environment files with the correct default options. The following changes reflect the defaults in version 3.1.0.]]]

`application.rb` 파일에서는 아래와 같이 업데이트 하고 [[[In `application.rb`:]]]

```ruby
# Enable the asset pipeline
config.assets.enabled = true

# Version of your assets, change this if you want to expire all your assets
config.assets.version = '1.0'

# Change the path that assets are served from
# config.assets.prefix = "/assets"
```

`development.rb` 파일에서는 다음과 같이 업데이트해 줍니다. [[[In `development.rb`:]]]

```ruby
# Do not compress assets
config.assets.compress = false

# Expands the lines which load the assets
config.assets.debug = true
```

그리고 `production.rb` 파일에서는 아래와 같이 변경해 줍니다. [[[And in `production.rb`:]]]

```ruby
# Compress JavaScripts and CSS
config.assets.compress = true

# Choose the compressors to use
# config.assets.js_compressor  = :uglifier
# config.assets.css_compressor = :yui

# Don't fallback to assets pipeline if a precompiled asset is missed
config.assets.compile = false

# Generate digests for assets URLs.
config.assets.digest = true

# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
# config.assets.precompile += %w( search.js )
```

`test.rb` 파일을 변경해서는 안됩니다. 테스트 환경에서의 디폴트 설정은, `config.assets.compile` 설정은 true 값, 그리고 `config.assets.compress`, `config.assets.debug`, `config.assets.digest` 설정은 모드 false 값으로 설정되어 있스빈다. [[[You should not need to change `test.rb`. The defaults in the test environment are: `config.assets.compile` is true and `config.assets.compress`, `config.assets.debug` and `config.assets.digest` are false.]]]

또한 아래의 내용을 `Gemfile`에 추가해 주어야 합니다. [[[The following should also be added to `Gemfile`:]]]

```ruby
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier'
end
```

Bundler와 함께 `assets` 그룹을 사용할 경우에는 `config/application.rb` 파일에 아래의 Bundler require 문이 있는지를 확인해야 합니다. [[[If you use the `assets` group with Bundler, please make sure that your `config/application.rb` has the following Bundler require statement:]]]

운영서버로 배포전에 자원을 사전컴파일할 경우에는 아래의 코드라인을 사용해야 합니다. [[[ If you precompile assets before deploying to production, use this line]]] 

```ruby
# If you precompile assets before deploying to production, use this line
Bundler.require *Rails.groups(:assets => %w(development test))
```

그러나 자원들을 운영서버에서 필요시 컴파일되도록 할 경우에는 아래의 코드라인을 사용해야 합니다. [[[If you want your assets lazily compiled in production, use this line]]]

```ruby
# If you want your assets lazily compiled in production, use this line
Bundler.require(:default, :assets, Rails.env)
```

또한, 환경별로 자원에 대한 처리를 별도로 할 경우에는 아래와 같은 코드라인을 사용해야 합니다. [[[Instead of the generated version:]]]

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
```
