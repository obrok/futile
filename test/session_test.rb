require "test/test_helper.rb"

class SessionTest < Test::Unit::TestCase
  def setup
    @futile = Futile::Session.new("localhost", 6666)
  end

  def test_basic_get
    @futile.get("/simple_get")
    assert ! @futile.redirected?
    assert_equal "/simple_get", @futile.path
    assert_equal "get response", @futile.response.body
  end

  def test_infinite_redirect
    assert_raises(Futile::RedirectIsFutile) do
      @futile.get("/infinite_redirect")
    end
    assert @futile.redirected?
  end
end
