require "test/test_helper.rb"

class HelpersTest < Futile::TestCase
  def test_typing_by_field_name
    @futile.get("/form")
    @futile.fill("p1", "msq")
    assert_equal "msq", @futile.params["p1"]
  end

  def test_raise_error_when_not_found
    @futile.get("/form")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("not_found_param_name", "test")
    end
  end
end
