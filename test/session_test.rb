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
    @futile.request("/doit", {:method => Futile::Session::POST})
    assert @futile.post?
  end

  def test_scoped_links
    @futile.get("/scoped_links")
    assert_raises(Futile::SearchIsFutile) do
      @futile.click_link("one")
    end
    @futile.within("#scope1") do
      @futile.click_link("one")
      assert @futile.path =~ /simple_get/
    end
    assert_equal(Nokogiri.parse(TestServer.parse_erb("simple_html.erb")).to_s,
      @futile.response.parsed_body.to_s)
  end

  def test_scoped_form
    @futile.get("/scoped_links")
    parsed = @futile.response.parsed_body.dup
    assert_raises(Futile::SearchIsFutile) do
      @futile.click_link("one")
    end
    @futile.within("#scope2") do
      @futile.click_button("Click")
      assert @futile.path =~ /form_without_method/
    end
    assert_equal(Nokogiri.parse(TestServer.parse_erb("form_without_method.erb")).to_s,
      @futile.response.parsed_body.to_s)
  end

  def test_scoped_doesnt_change_body_when_no_request
    @futile.get("/scoped_links")
    parsed = @futile.response.parsed_body.dup
    @futile.within("#scope2") do
      # nothing
    end
    assert_equal parsed.to_s, @futile.response.parsed_body.to_s
  end

  def test_scoped_raises_when_scope_not_found
    @futile.get("/scoped_links")
    parsed = @futile.response.parsed_body.dup
    assert_raises(Futile::SearchIsFutile) do
      @futile.within("#scope_not_existing") do
      end
    end
  end

  def test_double_within
    @futile.get("/scoped_links")
    @futile.within("#scope3") do
      @futile.click_link("destiny")
      @futile.within("//div[@id='scope3']/div[1]") do
        assert_raises(Futile::SearchIsFutile) do
          @futile.click_link("destiny")
        end
        @futile.click_link("pick")
      end
    end
    assert /my_text=msq/, @futile.path
  end

  def test_redirection_sets_correct_uri
    @futile.get("/single_redirect")
    assert_equal "/simple_get", @futile.path
  end

  def test_get_post_consts_are_frozen
    assert_raises(TypeError) { Futile::Session::GET[1, 1] = "u" }
    assert_raises(TypeError) { Futile::Session::POST[1, 1] = "e" }
  end

  def test_process_uri_without_http_scheme
    path = Futile::Session.new("localhost:6666").full_path
    assert_equal "http://localhost:6666/", path
  end

  def test_get_data
    @futile.get("/doit", {:data => {:a => :b}})
    assert_match(/a:b/, @futile.response.body)
  end

  [:get, :post, :request].each do |method|
    define_method "test_usupported_options_#{method}" do
      opts = {:there_is_no_such_option => :some_value}
      assert_raises(Futile::OptionIsFutile){@futile.send(method, "/simple_get", opts)}
    end
  end
end
