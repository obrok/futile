require "test/test_helper.rb"

class LocatorsTest < Futile::TestCase
  def test_find_parent_returns_nil_when_no_such_parent
    @futile.get("/simple_get")
    element = @futile.response.parsed_body.at("//a[1]")
    assert_nil @futile.send(:find_parent, element, "oooops")
  end
end
