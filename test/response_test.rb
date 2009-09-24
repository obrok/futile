require "test/test_helper.rb"

class ResponseTeset < Futile::TestCase
  def test_get
    @futile.get("/simple_get")
    assert_equal "get response", @futile.response.body
    assert_equal 200, @futile.response.status
  end
end
