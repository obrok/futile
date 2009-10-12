require File.join("test", "test_helper")

class SessionTest < Futile::TestCase
  def test_basic_get
    @futile.get("/simple_get")
    assert ! @futile.redirected?
    assert_equal "/simple_get", @futile.path
  end

  def test_infinite_redirect
    assert_raises(Futile::RedirectIsFutile) do
      @futile.get("/infinite_redirect")
    end
    assert @futile.redirected?
  end

  def test_process_uri_builds_simple_uri
    uri = @futile.send(:process_uri, "/msq#test")
    assert_include "msq#test", uri.to_s
  end

  def test_process_uri_merges_relative_uri
    uri = @futile.send(:process_uri, "http://0.0.0.0:6666/doit")
    assert_include "0.0.0.0:6666", uri.to_s
  end

  def test_process_uri_handles_params
    path = "/?test=params&and_one=more"
    uri = @futile.send(:process_uri, path)
    assert_include path, uri.to_s
  end

  def test_session_changed
    session = @futile.send(:session)
    @futile.get("http://0.0.0.0:6666/form")
    assert session != @futile.send(:session)
  end

  def test_referer_sent
    @futile.get("/simple_get")
    @futile.click_link("referer")
    assert_match(/simple_get/, @futile.response.body)
  end

  def test_following_redirect_parses_uri_as_usual
    @futile.get("/single_redirect")
    assert @futile.instance_variable_get(:@uri).is_a?(URI::HTTP)
  end

  def test_post_method
    @futile.request("/doit", Futile::Session::POST)
    assert @futile.post?
  end
end
