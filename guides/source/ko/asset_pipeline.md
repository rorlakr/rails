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

Fingerprinting이라는 것은 파일이름을 파일의 내용에 의존해서 만드는 기술을 말합니다. 따라서 파일 내용이 변경될 때 파일이름 또한 변경됩니다. 그러나, 내용이 정해져 있거나 거의 변화지 않는 경우에는, 다른 서버에 위치하거나 배포 날짜가 다른 경우에도 해당 파일의 두가지 버전이 일치하는지를 쉽게 알려 주게 됩니다. [[[Fingerprinting is a technique that makes the name of a file dependent on the contents of the file. When the file contents change, the filename is also changed. For content that is static or infrequently changed, this provides an easy way to tell whether two versions of a file are identical, even across different servers or deployment dates.]]]

특정 파일명이 유일하고 파일내용에 근거하여 만들어질 때, HTTP 헤더를 설정하여 캐시가 어느 곳에 위치하더라도 자신만의 파일 복사본을 유지하도록 할 수 있습니다. 해당 파일의 내용이 업데이트될 때 fingerprint는 변경될 것입니다. 이것은 원격상의 클라이언트가 해당 파일의 새로운 복사본을 요청하도록 할 것입니다. 이러한 것을 일반적으로 _cache busting_ 이라고 합니다. [[[When a filename is unique and based on its content, HTTP headers can be set to encourage caches everywhere (whether at CDNs, at ISPs, in networking equipment, or in web browsers) to keep their own copy of the content. When the content is updated, the fingerprint will change. This will cause the remote clients to request a new copy of the content. This is generally known as _cache busting_.]]]

fingerprinting에 대해서 레일스가 사용하는 기술은 파일내용의 해시값을 대개 파일명의 끝에 삽입하는 것입니다. 예를 들어, `global.css`라는 CSS 파일은 해당 파일내용의 MD5 digest값이 삽입되어 파일명이 변경될 것입니다. [[[The technique that Rails uses for fingerprinting is to insert a hash of the content into the name, usually at the end. For example a CSS file `global.css` could be renamed with an MD5 digest of its contents:]]]

```
global-908e25f4bf641868d8683022a5b62f54.css
```

이러한 것이 바로 레일스 asset pipeline이 채택한 전략입니다. [[[This is the strategy adopted by the Rails asset pipeline.]]]

레일스의 예전 전략은 날짜를 근거로 한 쿼리문자열을 내장 헬퍼에 연결되는 모든 자원에 추가하는 것이었습니다. [[[Rails' old strategy was to append a date-based query string to every asset linked with a built-in helper. In the source the generated code looked like this:]]]

```
/stylesheets/global.css?1309495796
```

쿼리문자열 전략은 몇가지 단점이 있습니다. [[[The query string strategy has several disadvantages:]]]

1. **Not all caches will reliably cache content where the filename only differs by query parameters**<br />
    [Steve Souders recommends](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/), "...avoiding a querystring for cacheable resources". He found that in this case 5-20% of requests will not be cached. Query strings in particular do not work at all with some CDNs for cache invalidation.

2. **The file name can change between nodes in multi-server environments.**<br />
    The default query string in Rails 2.x is based on the modification time of the files. When assets are deployed to a cluster, there is no guarantee that the timestamps will be the same, resulting in different values being used depending on which server handles the request.
3. **Too much cache invalidation**<br />
    When static assets are deployed with each new release of code, the mtime(time of last modification) of _all_ these files changes, forcing all remote clients to fetch them again, even when the content of those assets has not changed.

Fingerprinting fixes these problems by avoiding query strings, and by ensuring that filenames are consistent based on their content.

Fingerprinting is enabled by default for production and disabled for all other environments. You can enable or disable it in your configuration through the `config.assets.digest` option.

More reading:

* [Optimize caching](http://code.google.com/speed/page-speed/docs/caching.html)
* [Revving Filenames: don’t use querystring](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)


[How to Use the Asset Pipeline] Asset Pipeline 사용법
-----------------------------

레일스 이전 버전에서는, 모든 자원이 `public` 디렉토리의 하위 디렉토리인 `images`, `javascripts`, `stylesheets`에 위치했었습니다. Asset pipeline을 사용하게 되면, `app/assets` 디렉토리에 자원들이 위치하게 됩니다. 이 디렉토리 상의 파일들은 sprockets 젬을 설치할 경우 Sprockets 미들웨어에 의해서 처리됩니다. [[[In previous versions of Rails, all assets were located in subdirectories of `public` such as `images`, `javascripts` and `stylesheets`. With the asset pipeline, the preferred location for these assets is now the `app/assets` directory. Files in this directory are served by the Sprockets middleware included in the sprockets gem.]]]

Asset pipeline을 사용할 때도 자원들을 `public` 디렉토리에 둘 수 있습니다. `public` 디렉토리사의 모든 자원들은 어플리케이션이나 웹서버에 의해서 static 파일로서 사용될 것입니다. 따라서 사용하기 전에 어떤 전처리과정이 필요한 파일들은 `app/assets` 디렉토리에 두어야 합니다. [[[Assets can still be placed in the `public` hierarchy. Any assets under `public` will be served as static files by the application or web server. You should use `app/assets` for files that must undergo some pre-processing before they are served.]]]

운영환경에서는, 레일스가 디폴트로 이러한 자원 파일들을 사전 컴파일해서 `public/assets` 디렉토리에 둡니다. 이 사전 컴파일된 파일들은 웹서버가 static 자원으로 사용하게 됩니다. `app/assets` 디렉토리에 있는 파일들은 운영환경에서 절대로 직접 사용되지 않습니다. [[[In production, Rails precompiles these files to `public/assets` by default. The precompiled copies are then served as static assets by the web server. The files in `app/assets` are never served directly in production.]]]

### [Controller Specific Assets] 컨트롤러 전용 자원

임의의 scaffold 또는 컨트롤러를 생성할 때 레일스는 해당 컨트롤러 전용 자바스크립 파일(또는 `Gemfile`에 `coffeescript-rails` 젬이 있다면 CoffeeScript 파일)과 CSS 파일(`Gemfile` 내에 `sass-rails`젬이 있다면 SCSS 파일)도 동시에 생성해 줍니다. [[[When you generate a scaffold or a controller, Rails also generates a JavaScript file (or CoffeeScript file if the `coffee-rails` gem is in the `Gemfile`) and a Cascading Style Sheet file (or SCSS file if `sass-rails` is in the `Gemfile`) for that controller.]]]

예를 들어, `ProjectsController`를 생성한다면, 레일스는 동시에 `app/assets/javascripts/projects.js.coffee`와 `app/assets/stylesheets/projects.css.scss` 파일을 생성해 줍니다. 디폴트 상태에서, 이러한 파일들은 `require_tree` 명령어를 사용한 후에 어플리케이션에서 사용할 수 있게 됩니다. require_tree에 대한 자세한 내용은 [Manifest Files and Directives](#manifest-files-and-directives)를 보기 바랍니다. [[[For example, if you generate a `ProjectsController`, Rails will also add a new file at `app/assets/javascripts/projects.js.coffee` and another at `app/assets/stylesheets/projects.css.scss`. By default these files will be ready to use by your application immediately using the `require_tree` directive. See [Manifest Files and Directives](#manifest-files-and-directives) for more details on require_tree.]]]

또한 `<%= javascript_include_tag params[:controller] %>` 또는 `<%= stylesheet_link_tag params[:controller] %>`를 사용하게 되면 전용 CSS와 자바스크립트를 각각의 컨트롤러에서만 사용할 수 있습니다. 주의할 것은 `require_tree` 명령을 사용하지 않았는지를 확인해야 합니다. 왜냐하면 결과적으로 자원이 한번이상 포함될 것이기 때문입니다. [[[You can also opt to include controller specific stylesheets and JavaScript files only in their respective controllers using the following: `<%= javascript_include_tag params[:controller] %>` or `<%= stylesheet_link_tag params[:controller] %>`. Ensure that you are not using the `require_tree` directive though, as this will result in your assets being included more than once.]]]

WARNING: (운영환경의 디폴트 상태에서는) 자원을 사전 컴파일할 때는, 컨트롤러 전용 자원이 해당 페이지가 로딩될 때마다 사전 컴파일되는 것을 확인할 필요가 있습니다. 디폴트로, .coffee 와 .scss 파일은 사전 컴파일되지 않습니다. 개발환경에서는 이러한 파일들이 임시로 컴파일되기 때문에 사전 컴파일될 듯한 효과를 보이게 되어 제대로 동작할 것입니다. 그러나 운영환경에서 실행할 때는, 디폴트로 실시간 컴파일작업이 꺼진 상태이므로 500 에러가 발생하게 될 것입니다. 사전 컴파일 작업이 어떻게 동작하는지에 대한 자셍한 내용은 [Precompiling Assets](#precompiling-assets)를 보기 바랍니다. [[[When using asset precompilation (the production default), you will need to ensure that your controller assets will be precompiled when loading them on a per page basis. By default .coffee and .scss files will not be precompiled on their own. This will result in false positives during development as these files will work just fine since assets will be compiled on the fly. When running in production however, you will see 500 errors since live compilation is turned off by default. See [Precompiling Assets](#precompiling-assets) for more information on how precompiling works.]]]

NOTE: CoffeeScript를 사용하기 위해서는 ExecJS를 지원하는 런타임 라이브러리가 설치되어 있어야 합니다. Mac OS X 또는 윈도우즈를 사용하는 경우라면, 해당 운영 시스템에 자바스크립트 런타임 라이브러리를 설치해 주어야 합니다. 지원 가능한 모든 자바스크립트 런타임 라이브러리를 알기를 원하면 [ExecJS](https://github.com/sstephenson/execjs#readme) 문서를 참고하기 바랍니다. [[[You must have an ExecJS supported runtime in order to use CoffeeScript. If you are using Mac OS X or Windows you have a JavaScript runtime installed in your operating system. Check [ExecJS](https://github.com/sstephenson/execjs#readme) documentation to know all supported JavaScript runtimes.]]]

물론, `config/application.rb` 설정 파일에 아래의 코드라인을 추가해서 컨트롤러가 생성될 때 자원 파일들의 생성을 방지할 수 있습니다. [[[You can also disable the generation of asset files when generating a controller by adding the following to your `config/application.rb` configuration:]]]

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

[[[It is important to note that files you want to reference outside a manifest must be added to the precompile array or they will not be available in the production environment.]]]

#### Using Index Files

Sprockets uses files named `index` (with the relevant extensions) for a special purpose.

For example, if you have a jQuery library with many modules, which is stored in `lib/assets/library_name`, the file `lib/assets/library_name/index.js` serves as the manifest for all files in this library. This file could include a list of all the required files in order, or a simple `require_tree` directive.

The library as a whole can be accessed in the site's application manifest like so:

```js
//= require library_name
```

This simplifies maintenance and keeps things clean by allowing related code to be grouped before inclusion elsewhere.

### Coding Links to Assets

Sprockets does not add any new methods to access your assets - you still use the familiar `javascript_include_tag` and `stylesheet_link_tag`.

```erb
<%= stylesheet_link_tag "application" %>
<%= javascript_include_tag "application" %>
```

In regular views you can access images in the `assets/images` directory like this:

```erb
<%= image_tag "rails.png" %>
```

Provided that the pipeline is enabled within your application (and not disabled in the current environment context), this file is served by Sprockets. If a file exists at `public/assets/rails.png` it is served by the web server.

Alternatively, a request for a file with an MD5 hash such as `public/assets/rails-af27b6a414e6da00003503148be9b409.png` is treated the same way. How these hashes are generated is covered in the [In Production](#in-production) section later on in this guide.

Sprockets will also look through the paths specified in `config.assets.paths` which includes the standard application paths and any path added by Rails engines.

Images can also be organized into subdirectories if required, and they can be accessed by specifying the directory's name in the tag:

```erb
<%= image_tag "icons/rails.png" %>
```

WARNING: If you're precompiling your assets (see [In Production](#in-production) below), linking to an asset that does not exist will raise an exception in the calling page. This includes linking to a blank string. As such, be careful using `image_tag` and the other helpers with user-supplied data.

#### CSS and ERB

The asset pipeline automatically evaluates ERB. This means that if you add an `erb` extension to a CSS asset (for example, `application.css.erb`), then helpers like `asset_path` are available in your CSS rules:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

This writes the path to the particular asset being referenced. In this example, it would make sense to have an image in one of the asset load paths, such as `app/assets/images/image.png`, which would be referenced here. If this image is already available in `public/assets` as a fingerprinted file, then that path is referenced.

If you want to use a [data URI](http://en.wikipedia.org/wiki/Data_URI_scheme) — a method of embedding the image data directly into the CSS file — you can use the `asset_data_uri` helper.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

This inserts a correctly-formatted data URI into the CSS source.

Note that the closing tag cannot be of the style `-%>`.

#### CSS and Sass

When using the asset pipeline, paths to assets must be re-written and `sass-rails` provides `-url` and `-path` helpers (hyphenated in Sass, underscored in Ruby) for the following asset classes: image, font, video, audio, JavaScript and stylesheet.

* `image-url("rails.png")` becomes `url(/assets/rails.png)`
* `image-path("rails.png")` becomes `"/assets/rails.png"`.

The more generic form can also be used but the asset path and class must both be specified:

* `asset-url("rails.png", image)` becomes `url(/assets/rails.png)`
* `asset-path("rails.png", image)` becomes `"/assets/rails.png"`

#### JavaScript/CoffeeScript and ERB

If you add an `erb` extension to a JavaScript asset, making it something such as `application.js.erb`, then you can use the `asset_path` helper in your JavaScript code:

```js
$('#logo').attr({
  src: "<%= asset_path('logo.png') %>"
});
```

This writes the path to the particular asset being referenced.

Similarly, you can use the `asset_path` helper in CoffeeScript files with `erb` extension (e.g., `application.js.coffee.erb`):

```js
$('#logo').attr src: "<%= asset_path('logo.png') %>"
```

### Manifest Files and Directives

Sprockets uses manifest files to determine which assets to include and serve. These manifest files contain _directives_ — instructions that tell Sprockets which files to require in order to build a single CSS or JavaScript file. With these directives, Sprockets loads the files specified, processes them if necessary, concatenates them into one single file and then compresses them (if `Rails.application.config.assets.compress` is true). By serving one file rather than many, the load time of pages can be greatly reduced because the browser makes fewer requests. Compression also reduces the file size enabling the browser to download it faster.


For example, a new Rails application includes a default `app/assets/javascripts/application.js` file which contains the following lines:

```js
// ...
//= require jquery
//= require jquery_ujs
//= require_tree .
```

In JavaScript files, the directives begin with `//=`. In this case, the file is using the `require` and the `require_tree` directives. The `require` directive is used to tell Sprockets the files that you wish to require. Here, you are requiring the files `jquery.js` and `jquery_ujs.js` that are available somewhere in the search path for Sprockets. You need not supply the extensions explicitly. Sprockets assumes you are requiring a `.js` file when done from within a `.js` file.

The `require_tree` directive tells Sprockets to recursively include _all_ JavaScript files in the specified directory into the output. These paths must be specified relative to the manifest file. You can also use the `require_directory` directive which includes all JavaScript files only in the directory specified, without recursion.

Directives are processed top to bottom, but the order in which files are included by `require_tree` is unspecified. You should not rely on any particular order among those. If you need to ensure some particular JavaScript ends up above some other in the concatenated file, require the prerequisite file first in the manifest. Note that the family of `require` directives prevents files from being included twice in the output.

Rails also creates a default `app/assets/stylesheets/application.css` file which contains these lines:

```js
/* ...
*= require_self
*= require_tree .
*/
```

The directives that work in the JavaScript files also work in stylesheets (though obviously including stylesheets rather than JavaScript files). The `require_tree` directive in a CSS manifest works the same way as the JavaScript one, requiring all stylesheets from the current directory.

In this example `require_self` is used. This puts the CSS contained within the file (if any) at the precise location of the `require_self` call. If `require_self` is called more than once, only the last call is respected.

NOTE. If you want to use multiple Sass files, you should generally use the [Sass `@import` rule](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#import) instead of these Sprockets directives. Using Sprockets directives all Sass files exist within their own scope, making variables or mixins only available within the document they were defined in.

You can have as many manifest files as you need. For example the `admin.css` and `admin.js` manifest could contain the JS and CSS files that are used for the admin section of an application.

The same remarks about ordering made above apply. In particular, you can specify individual files and they are compiled in the order specified. For example, you might concatenate three CSS files together this way:

```js
/* ...
*= require reset
*= require layout
*= require chrome
*/
```


### Preprocessing

The file extensions used on an asset determine what preprocessing is applied. When a controller or a scaffold is generated with the default Rails gemset, a CoffeeScript file and a SCSS file are generated in place of a regular JavaScript and CSS file. The example used before was a controller called "projects", which generated an `app/assets/javascripts/projects.js.coffee` and an `app/assets/stylesheets/projects.css.scss` file.

When these files are requested, they are processed by the processors provided by the `coffee-script` and `sass` gems and then sent back to the browser as JavaScript and CSS respectively.

Additional layers of preprocessing can be requested by adding other extensions, where each extension is processed in a right-to-left manner. These should be used in the order the processing should be applied. For example, a stylesheet called `app/assets/stylesheets/projects.css.scss.erb` is first processed as ERB, then SCSS, and finally served as CSS. The same applies to a JavaScript file — `app/assets/javascripts/projects.js.coffee.erb` is processed as ERB, then CoffeeScript, and served as JavaScript.

Keep in mind that the order of these preprocessors is important. For example, if you called your JavaScript file `app/assets/javascripts/projects.js.erb.coffee` then it would be processed with the CoffeeScript interpreter first, which wouldn't understand ERB and therefore you would run into problems.

In Development
--------------

In development mode, assets are served as separate files in the order they are specified in the manifest file.

This manifest `app/assets/javascripts/application.js`:

```js
//= require core
//= require projects
//= require tickets
```

would generate this HTML:

```html
<script src="/assets/core.js?body=1"></script>
<script src="/assets/projects.js?body=1"></script>
<script src="/assets/tickets.js?body=1"></script>
```

The `body` param is required by Sprockets.

### Turning Debugging Off

You can turn off debug mode by updating `config/environments/development.rb` to include:

```ruby
config.assets.debug = false
```

When debug mode is off, Sprockets concatenates and runs the necessary preprocessors on all files. With debug mode turned off the manifest above would generate instead:

```html
<script src="/assets/application.js"></script>
```

Assets are compiled and cached on the first request after the server is started. Sprockets sets a `must-revalidate` Cache-Control HTTP header to reduce request overhead on subsequent requests — on these the browser gets a 304 (Not Modified) response.

If any of the files in the manifest have changed between requests, the server responds with a new compiled file.

Debug mode can also be enabled in the Rails helper methods:

```erb
<%= stylesheet_link_tag "application", debug: true %>
<%= javascript_include_tag "application", debug: true %>
```

The `:debug` option is redundant if debug mode is on.

You could potentially also enable compression in development mode as a sanity check, and disable it on-demand as required for debugging.

In Production
-------------

In the production environment Rails uses the fingerprinting scheme outlined above. By default Rails assumes that assets have been precompiled and will be served as static assets by your web server.

During the precompilation phase an MD5 is generated from the contents of the compiled files, and inserted into the filenames as they are written to disc. These fingerprinted names are used by the Rails helpers in place of the manifest name.

For example this:

```erb
<%= javascript_include_tag "application" %>
<%= stylesheet_link_tag "application" %>
```

generates something like this:

```html
<script src="/assets/application-908e25f4bf641868d8683022a5b62f54.js"></script>
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" media="screen" rel="stylesheet" />
```

Note: with the Asset Pipeline the :cache and :concat options aren't used anymore, delete these options from the `javascript_include_tag` and `stylesheet_link_tag`.


The fingerprinting behavior is controlled by the setting of `config.assets.digest` setting in Rails (which defaults to `true` for production and `false` for everything else).

NOTE: Under normal circumstances the default option should not be changed. If there are no digests in the filenames, and far-future headers are set, remote clients will never know to refetch the files when their content changes.

### Precompiling Assets

Rails comes bundled with a rake task to compile the asset manifests and other files in the pipeline to the disk.

Compiled assets are written to the location specified in `config.assets.prefix`. By default, this is the `public/assets` directory.

You can call this task on the server during deployment to create compiled versions of your assets directly on the server. See the next section for information on compiling locally.

The rake task is:

```bash
$ RAILS_ENV=production bundle exec rake assets:precompile
```

For faster asset precompiles, you can partially load your application by setting
`config.assets.initialize_on_precompile` to false in `config/application.rb`, though in that case templates
cannot see application objects or methods. **Heroku requires this to be false.**

WARNING: If you set `config.assets.initialize_on_precompile` to false, be sure to
test `rake assets:precompile` locally before deploying. It may expose bugs where
your assets reference application objects or methods, since those are still
in scope in development mode regardless of the value of this flag. Changing this flag also affects
engines. Engines can define assets for precompilation as well. Since the complete environment is not loaded,
engines (or other gems) will not be loaded, which can cause missing assets.

Capistrano (v2.15.1 and above) includes a recipe to handle this in deployment. Add the following line to `Capfile`:

```ruby
load 'deploy/assets'
```

This links the folder specified in `config.assets.prefix` to `shared/assets`. If you already use this shared folder you'll need to write your own deployment task.

It is important that this folder is shared between deployments so that remotely cached pages that reference the old compiled assets still work for the life of the cached page.

NOTE. If you are precompiling your assets locally, you can use `bundle install --without assets` on the server to avoid installing the assets gems (the gems in the assets group in the Gemfile).

The default matcher for compiling files includes `application.js`, `application.css` and all non-JS/CSS files (this will include all image assets automatically):

```ruby
[ Proc.new { |path| !%w(.js .css).include?(File.extname(path)) }, /application.(css|js)$/ ]
```

NOTE. The matcher (and other members of the precompile array; see below) is applied to final compiled file names. This means that anything that compiles to JS/CSS is excluded, as well as raw JS/CSS files; for example, `.coffee` and `.scss` files are **not** automatically included as they compile to JS/CSS.

If you have other manifests or individual stylesheets and JavaScript files to include, you can add them to the `precompile` array in `config/application.rb`:

```ruby
config.assets.precompile += ['admin.js', 'admin.css', 'swfObject.js']
```

Or you can opt to precompile all assets with something like this:

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

NOTE. Always specify an expected compiled filename that ends with js or css, even if you want to add Sass or CoffeeScript files to the precompile array.

The rake task also generates a `manifest.yml` that contains a list with all your assets and their respective fingerprints. This is used by the Rails helper methods to avoid handing the mapping requests back to Sprockets. A typical manifest file looks like:

```yaml
---
rails.png: rails-bd9ad5a560b5a3a7be0808c5cd76a798.png
jquery-ui.min.js: jquery-ui-7e33882a28fc84ad0e0e47e46cbf901c.min.js
jquery.min.js: jquery-8a50feed8d29566738ad005e19fe1c2d.min.js
application.js: application-3fdab497b8fb70d20cfc5495239dfc29.js
application.css: application-8af74128f904600e41a6e39241464e03.css
```

The default location for the manifest is the root of the location specified in `config.assets.prefix` ('/assets' by default).

NOTE: If there are missing precompiled files in production you will get an `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` exception indicating the name of the missing file(s).

#### Far-future Expires Header

Precompiled assets exist on the filesystem and are served directly by your web server. They do not have far-future headers by default, so to get the benefit of fingerprinting you'll have to update your server configuration to add them.

For Apache:

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

For nginx:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
  break;
}
```

#### GZip Compression

When files are precompiled, Sprockets also creates a [gzipped](http://en.wikipedia.org/wiki/Gzip) (.gz) version of your assets. Web servers are typically configured to use a moderate compression ratio as a compromise, but since precompilation happens once, Sprockets uses the maximum compression ratio, thus reducing the size of the data transfer to the minimum. On the other hand, web servers can be configured to serve compressed content directly from disk, rather than deflating non-compressed files themselves.

Nginx is able to do this automatically enabling `gzip_static`:

```nginx
location ~ ^/(assets)/  {
  root /path/to/public;
  gzip_static on; # to serve pre-gzipped version
  expires max;
  add_header Cache-Control public;
}
```

This directive is available if the core module that provides this feature was compiled with the web server. Ubuntu packages, even `nginx-light` have the module compiled. Otherwise, you may need to perform a manual compilation:

```bash
./configure --with-http_gzip_static_module
```

If you're compiling nginx with Phusion Passenger you'll need to pass that option when prompted.

A robust configuration for Apache is possible but tricky; please Google around. (Or help update this Guide if you have a good example configuration for Apache.)

### Local Precompilation

There are several reasons why you might want to precompile your assets locally. Among them are:

* You may not have write access to your production file system.
* You may be deploying to more than one server, and want to avoid the duplication of work.
* You may be doing frequent deploys that do not include asset changes.

Local compilation allows you to commit the compiled files into source control, and deploy as normal.

There are two caveats:

* You must not run the Capistrano deployment task that precompiles assets.
* You must change the following two application configuration settings.

In `config/environments/development.rb`, place the following line:

```ruby
config.assets.prefix = "/dev-assets"
```

You will also need this in application.rb:

```ruby
config.assets.initialize_on_precompile = false
```

The `prefix` change makes Rails use a different URL for serving assets in development mode, and pass all requests to Sprockets. The prefix is still set to `/assets` in the production environment. Without this change, the application would serve the precompiled assets from `public/assets` in development, and you would not see any local changes until you compile assets again.

The `initialize_on_precompile` change tells the precompile task to run without invoking Rails. This is because the precompile task runs in production mode by default, and will attempt to connect to your specified production database. Please note that you cannot have code in pipeline files that relies on Rails resources (such as the database) when compiling locally with this option.

You will also need to ensure that any compressors or minifiers are available on your development system.

In practice, this will allow you to precompile locally, have those files in your working tree, and commit those files to source control when needed. Development mode will work as expected.

### Live Compilation

In some circumstances you may wish to use live compilation. In this mode all requests for assets in the pipeline are handled by Sprockets directly.

To enable this option set:

```ruby
config.assets.compile = true
```

On the first request the assets are compiled and cached as outlined in development above, and the manifest names used in the helpers are altered to include the MD5 hash.

Sprockets also sets the `Cache-Control` HTTP header to `max-age=31536000`. This signals all caches between your server and the client browser that this content (the file served) can be cached for 1 year. The effect of this is to reduce the number of requests for this asset from your server; the asset has a good chance of being in the local browser cache or some intermediate cache.

This mode uses more memory, performs more poorly than the default and is not recommended.

If you are deploying a production application to a system without any pre-existing JavaScript runtimes, you may want to add one to your Gemfile:

```ruby
group :production do
  gem 'therubyracer'
end
```

### CDNs

If your assets are being served by a CDN, ensure they don't stick around in
your cache forever. This can cause problems. If you use
`config.action_controller.perform_caching = true`, Rack::Cache will use
`Rails.cache` to store assets. This can cause your cache to fill up quickly.

Every cache is different, so evaluate how your CDN handles caching and make
sure that it plays nicely with the pipeline. You may find quirks related to
your specific set up, you may not. The defaults nginx uses, for example,
should give you no problems when used as an HTTP cache.

Customizing the Pipeline
------------------------

### CSS Compression

There is currently one option for compressing CSS, YUI. The [YUI CSS compressor](http://developer.yahoo.com/yui/compressor/css.html) provides minification.

The following line enables YUI compression, and requires the `yui-compressor` gem.

```ruby
config.assets.css_compressor = :yui
```

The `config.assets.compress` must be set to `true` to enable CSS compression.

### JavaScript Compression

Possible options for JavaScript compression are `:closure`, `:uglifier` and `:yui`. These require the use of the `closure-compiler`, `uglifier` or `yui-compressor` gems, respectively.

The default Gemfile includes [uglifier](https://github.com/lautis/uglifier). This gem wraps [UglifierJS](https://github.com/mishoo/UglifyJS) (written for NodeJS) in Ruby. It compresses your code by removing white space. It also includes other optimizations such as changing your `if` and `else` statements to ternary operators where possible.

The following line invokes `uglifier` for JavaScript compression.

```ruby
config.assets.js_compressor = :uglifier
```

Note that `config.assets.compress` must be set to `true` to enable JavaScript compression

NOTE: You will need an [ExecJS](https://github.com/sstephenson/execjs#readme) supported runtime in order to use `uglifier`. If you are using Mac OS X or Windows you have a JavaScript runtime installed in your operating system. Check the [ExecJS](https://github.com/sstephenson/execjs#readme) documentation for information on all of the supported JavaScript runtimes.

### Using Your Own Compressor

The compressor config settings for CSS and JavaScript also take any object. This object must have a `compress` method that takes a string as the sole argument and it must return a string.

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

To enable this, pass a new object to the config option in `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```


### Changing the _assets_ Path

The public path that Sprockets uses by default is `/assets`.

This can be changed to something else:

```ruby
config.assets.prefix = "/some_other_path"
```

This is a handy option if you are updating an older project that didn't use the asset pipeline and that already uses this path or you wish to use this path for a new resource.

### X-Sendfile Headers

The X-Sendfile header is a directive to the web server to ignore the response from the application, and instead serve a specified file from disk. This option is off by default, but can be enabled if your server supports it. When enabled, this passes responsibility for serving the file to the web server, which is faster.

Apache and nginx support this option, which can be enabled in `config/environments/production.rb`.

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
```

WARNING: If you are upgrading an existing application and intend to use this option, take care to paste this configuration option only into `production.rb` and any other environments you define with production behavior (not `application.rb`).

Assets Cache Store
------------------

The default Rails cache store will be used by Sprockets to cache assets in development and production. This can be changed by setting `config.assets.cache_store`.

```ruby
config.assets.cache_store = :memory_store
```

The options accepted by the assets cache store are the same as the application's cache store.

```ruby
config.assets.cache_store = :memory_store, { size: 32.megabytes }
```

Adding Assets to Your Gems
--------------------------

Assets can also come from external sources in the form of gems.

A good example of this is the `jquery-rails` gem which comes with Rails as the standard JavaScript library gem. This gem contains an engine class which inherits from `Rails::Engine`. By doing this, Rails is informed that the directory for this gem may contain assets and the `app/assets`, `lib/assets` and `vendor/assets` directories of this engine are added to the search path of Sprockets.

Making Your Library or Gem a Pre-Processor
------------------------------------------

As Sprockets uses [Tilt](https://github.com/rtomayko/tilt) as a generic
interface to different templating engines, your gem should just
implement the Tilt template protocol. Normally, you would subclass
`Tilt::Template` and reimplement `evaluate` method to return final
output. Template source is stored at `@code`. Have a look at
[`Tilt::Template`](https://github.com/rtomayko/tilt/blob/master/lib/tilt/template.rb)
sources to learn more.

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

Now that you have a `Template` class, it's time to associate it with an
extension for template files:

```ruby
Sprockets.register_engine '.bang', BangBang::Template
```

Upgrading from Old Versions of Rails
------------------------------------

There are a few issues when upgrading. The first is moving the files from `public/` to the new locations. See [Asset Organization](#asset-organization) above for guidance on the correct locations for different file types.

Next will be avoiding duplicate JavaScript files. Since jQuery is the default JavaScript library from Rails 3.1 onwards, you don't need to copy `jquery.js` into `app/assets` and it will be included automatically.

The third is updating the various environment files with the correct default options. The following changes reflect the defaults in version 3.1.0.

In `application.rb`:

```ruby
# Enable the asset pipeline
config.assets.enabled = true

# Version of your assets, change this if you want to expire all your assets
config.assets.version = '1.0'

# Change the path that assets are served from
# config.assets.prefix = "/assets"
```

In `development.rb`:

```ruby
# Do not compress assets
config.assets.compress = false

# Expands the lines which load the assets
config.assets.debug = true
```

And in `production.rb`:

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

You should not need to change `test.rb`. The defaults in the test environment are: `config.assets.compile` is true and `config.assets.compress`, `config.assets.debug` and `config.assets.digest` are false.

The following should also be added to `Gemfile`:

```ruby
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier'
end
```

If you use the `assets` group with Bundler, please make sure that your `config/application.rb` has the following Bundler require statement:

```ruby
# If you precompile assets before deploying to production, use this line
Bundler.require *Rails.groups(:assets => %w(development test))
# If you want your assets lazily compiled in production, use this line
# Bundler.require(:default, :assets, Rails.env)
```

Instead of the generated version:

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
```
