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

  ["link q9", '//a', 'html > body > a'].each_with_index do |locator, index|
    define_method "test_find_link(#{locator})".to_sym do
      @futile.get('/simple_get')
      assert_equal("<a href=\"/some_page\">link q9</a>", @futile.find_link(locator))
    end
  end
end
