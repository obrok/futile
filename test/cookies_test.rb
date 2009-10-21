require File.join("test", "test_helper")

class CookiesTest < Futile::TestCase
  def test_cookie_stored_and_sent
    @futile.post("/set_cookie", {:data => {'test' => 'cookie'}})
    assert_match(/test:cookie/, @futile.get("/cookies.html").body)
  end

  def test_multiple_cookies
    @futile.post("/set_cookie", {:data => {'a' => 'b', 'c' => 'd'}})
    @futile.get("/cookies.html")
    assert_match(/a:b/, @futile.response.body)
    assert_match(/c:d/, @futile.response.body)
  end

  def test_cookies_per_hostname
    @futile.post("/set_cookie", {:data => {'a' => 'b'}})
    @futile.get("http://127.0.0.1:6666/cookies.html")
    assert_no_match(/a:b/, @futile.response.body)
  end

  def test_cookies_sent_before_expiry
    @futile.post("/set_cookie", {:data => {"cookie" => "value; expires=Wed, 17-Oct-12 16:28:56 GMT"}})
    Time.stubs(:now).returns(Time.parse("Wed, 17-Oct-12 16:28:55 GMT"))
    assert_match(/cookie:value/, @futile.get("/cookies.html").body)
  end

  def test_cookies_not_sent_after_expiry
    @futile.post("/set_cookie", {:data => {"cookie" => "value; expires=Wed, 17-Oct-12 16:28:56 GMT"}})
    Time.stubs(:now).returns(Time.parse("Wed, 17-Oct-12 16:28:57 GMT"))
    assert_no_match(/cookie:value/, @futile.get("/cookies.html").body)
  end
end
