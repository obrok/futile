require File.join("test", "test_helper")

class CookiesTest < Futile::TestCase
  def test_cookie_stored_and_sent
    @futile.post("/set_cookie", {:data => {'test' => 'cookie'}})
    assert_match(/test:cookie/, @futile.get("/cookies").body)
  end

  def test_multiple_cookies
    @futile.post("/set_cookie", {:data => {'a' => 'b', 'c' => 'd'}})
    @futile.get("/cookies")
    assert_match(/a:b/, @futile.response.body)
    assert_match(/c:d/, @futile.response.body)
  end

  def test_cookies_per_hostname
    @futile.post("/set_cookie", {:data => {'a' => 'b'}})
    @futile.get("http://127.0.0.1:6666/cookies")
    assert_no_match(/a:b/, @futile.response.body)
  end
end
