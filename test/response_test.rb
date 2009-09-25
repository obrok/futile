require "test/test_helper.rb"

class ResponseTest < Futile::TestCase
  def test_get
    @futile.get("/simple_get")
    assert @futile.response.body.include?("unique response 445d")
    assert_equal 200, @futile.response.status
  end
end
