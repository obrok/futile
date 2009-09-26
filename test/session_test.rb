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

  def test_click_link
    @futile.get('/simple_get')
    @futile.click_link("link q9")
    assert_match(/This is the second page/, @futile.response.body)
  end

  def test_click_nonexistent_link
    @futile.get('/simple_get')
    assert_raise(Futile::SearchIsFutile) do
      @futile.click_link("No such link")
    end
  end
end
