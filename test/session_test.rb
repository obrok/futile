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

  def test_typing_by_field_name
    @futile.get("/form")
    @futile.fill("p1", "msq")
    assert_equal "msq", @futile.response.parsed_body.at("#id0")["value"]
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
    assert_equal "will happen", @futile.response.parsed_body.at("#id2")["value"]
  end

  def test_can_type_by_label
    @futile.get("/form")
    @futile.fill("The label", "value5")
    assert_equal "value5", @futile.response.parsed_body.at("#id1")["value"]
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
    assert_equal "textarea text", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_typing_password_field
    @futile.get("/form")
    @futile.fill("p6", "secret")
    assert_equal "secret", @futile.response.parsed_body.at("#id5")["value"]
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
    assert_equal "new textarea body", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_click_anchored_link_should_only_change_path
    @futile.get("/simple_get")
    @futile.click_link("anchor!!!1")
    assert_equal "/simple_get#only_anchor", @futile.path
  end

  def test_anchored_link_returns_response
    @futile.get("/simple_get")
    response = @futile.click_link("anchor!!!1")
    assert response.is_a?(Futile::Response)
  end

  def test_anchored_link_elswhere
    @futile.get("/simple_get")
    @futile.click_link("anchor elsewhere")
    assert_match("This is the second page", @futile.response.body)
  end

  [[:submit, :post], [:submit, :get], [:button, :post], [:button, :get]].each do |pair|
    define_method "test_form_submission_#{pair[0]}_#{pair[1]}" do
      @futile.get("/form")
      @futile.click_button("#{pair[0]} #{pair[1]}")
      assert_equal(pair[1].to_s.upcase, @futile.response.body)
    end
  end

  def test_checking_checkbox
    @futile.get("/form")
    @futile.check("p4")
    assert @futile.response.parsed_body.at("#id3")["checked"]
  end

  def test_raise_on_checking_already_checked
    @futile.get("/form")
    assert_raises(Futile::CheckIsFutile) do
      @futile.check("p8")
    end
  end

  def test_unchecking_checkbox
    @futile.get("/form")
    @futile.uncheck("p8")
    assert_nil @futile.response.parsed_body.at("#id6")["checked"]
  end
end
