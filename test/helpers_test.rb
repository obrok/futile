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

  def test_raise_error_when_filling_not_text_input
    @futile.get("/form")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("p4", "wont happen")
    end
  end

  def test_can_type_into_field_with_no_type
    @futile.get("/form")
    @futile.fill("p3", "will happen")
    assert_equal "will happen", @futile.params["p3"]
  end

  def test_can_type_by_label
    @futile.get("/form")
    @futile.fill("The label", "value5")
    assert_equal "value5", @futile.params["p2"]
  end

  def test_raise_error_when_same_labels
    @futile.get("/form")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("Not unique", "value665")
    end
  end

  def test_typing_textarea
    @futile.get("/form")
    @futile.fill("p5", "textarea text")
    assert_equal "textarea text", @futile.params["p5"]
  end

  def test_typing_password_field
    @futile.get("/form")
    @futile.fill("p6", "secret")
    assert_equal "secret", @futile.params["p6"]
  end

  def test_cannot_type_into_disabled_element
    @futile.get("/form")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("p7", "uhoh")
    end
  end

  def test_type_into_textarea_by_label
    @futile.get("/form")
    @futile.fill("Body", "new textarea body")
    assert_equal "new textarea body", @futile.params["p5"]
  end

  ["link q9", '//a', 'html > body > a'].each_with_index do |locator, index|
    define_method "test_find_link(#{locator})".to_sym do
      @futile.get('/simple_get')
      assert_equal("<a href=\"/second_page\">link q9</a>", @futile.find_link(locator).to_s)
    end
  end

  def test_click_anchored_link_should_only_change_path
    @futile.get("/simple_get")
    @futile.click_link("anchor!!!1")
    assert_equal "/simple_get#only_anchor", @futile.path
  end
end
