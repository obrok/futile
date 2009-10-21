require "test/test_helper.rb"

class HelpersTest < Futile::TestCase
  ["link q9", '//a[1]', 'html > body > a[1]'].each_with_index do |locator, index|
    define_method "test_find_link(#{locator})".to_sym do
      @futile.get('/simple_html.html')
      assert_equal("<a href=\"/second_page.html\">link q9</a>", @futile.send(:find_link, locator).to_s)
    end
  end

  def test_raise_error_when_not_found
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("not_found_param_name", "test")
    end
  end

  def test_raise_error_when_filling_not_text_input
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("p4", "wont happen")
    end
  end

  def test_click_link
    @futile.get('/simple_html.html')
    @futile.click_link("link q9")
    assert_match(/This is the second page/, @futile.response.body)
  end

  def test_click_nonexistent_link
    @futile.get('/simple_html.html')
    assert_raise(Futile::SearchIsFutile) do
      @futile.click_link("No such link")
    end
  end

  def test_typing_by_field_name
    @futile.get("/form.html")
    @futile.fill("p1", "msq")
    assert_equal "msq", @futile.response.parsed_body.at("#id0")["value"]
  end

  def test_can_type_into_field_with_no_type
    @futile.get("/form.html")
    @futile.fill("p3", "will happen")
    assert_equal "will happen", @futile.response.parsed_body.at("#id2")["value"]
  end

  def test_can_type_by_label
    @futile.get("/form.html")
    @futile.fill("The label", "value5")
    assert_equal "value5", @futile.response.parsed_body.at("#id1")["value"]
  end

  def test_raise_error_when_same_labels
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("Not unique", "value665")
    end
  end

  def test_typing_textarea
    @futile.get("/form.html")
    @futile.fill("p5", "textarea text")
    assert_equal "textarea text", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_typing_password_field
    @futile.get("/form.html")
    @futile.fill("p6", "secret")
    assert_equal "secret", @futile.response.parsed_body.at("#id5")["value"]
  end

  def test_cannot_type_into_disabled_element
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile) do
      @futile.fill("p7", "uhoh")
    end
  end

  def test_type_into_textarea_by_label
    @futile.get("/form.html")
    @futile.fill("Body", "new textarea body")
    assert_equal "new textarea body", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_click_anchored_link_should_only_change_path
    @futile.get("/simple_html.html")
    @futile.click_link("anchor!!!1")
    assert_equal "/simple_html.html#only_anchor", @futile.path
  end

  def test_anchored_link_returns_response
    @futile.get("/simple_html.html")
    response = @futile.click_link("anchor!!!1")
    assert response.is_a?(Futile::Response)
  end

  def test_anchored_link_elswhere
    @futile.get("/simple_html.html")
    @futile.click_link("anchor elsewhere")
    assert_match("This is the second page", @futile.response.body)
  end

  [[:submit, :post], [:submit, :get], [:button, :post], [:button, :get]].each do |pair|
    define_method "test_form_submission_#{pair[0]}_#{pair[1]}" do
      @futile.get("/form.html")
      @futile.click_button("#{pair[0]} #{pair[1]}")
      assert_match(/#{pair[1].to_s.upcase}/, @futile.response.body)
    end
  end

  def test_checking_checkbox
    @futile.get("/form.html")
    @futile.check("p4")
    assert @futile.response.parsed_body.at("#id3")["checked"]
  end

  def test_raise_on_checking_already_checked
    @futile.get("/form.html")
    assert_raises(Futile::CheckIsFutile) do
      @futile.check("p8")
    end
  end

  def test_unchecking_checkbox
    @futile.get("/form.html")
    @futile.uncheck("p8")
    assert_nil @futile.response.parsed_body.at("#id6")["checked"]
  end

  [/p1:init value/, /p5:Initial value/, /button:submit post/, /p8:on/,
     /p10:radio value 2/, /p12:on/, /p13:selected/, /p14:selected1/,
     /p14:selected2/].each do |regex|
    define_method("test_submit_#{regex.to_s.gsub(' ', '_')}") do
      @futile.get("/form.html")
      @futile.click_button("submit post")
      assert_match(regex, @futile.response.body)
    end
  end

  def test_submit_button_value
    @futile.get("/form.html")
    @futile.click_button("button post")
    assert_match(/button:button post/, @futile.response.body)
  end

  [/p7:disabled/, /button:submit post/, /p4:/, /p10:radio value1/,
   /p11/, /p13:not selected/, /p14:not selected/].each do |regex|
    define_method("test_submit_not_sent_#{regex.to_s.gsub(' ', '_')}") do
      @futile.get("/form.html")
      @futile.click_button("button post")
      assert_no_match(regex, @futile.response.body)
    end
  end

  def test_click_button_with_no_form
    @futile.get("/form.html")
    assert_raises(Futile::ButtonIsFutile){@futile.click_button("random button")}
  end

  def test_click_nonexistent_button
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile){@futile.click_button("no such button")}
  end

  def test_select_singleselect
    @futile.get("/form.html")
    @futile.select("p13", "here")
    @futile.click_button("button post")
    assert_match(/p13:not selected/, @futile.response.body)
    assert_no_match(/p13:selected/, @futile.response.body)
  end

  def test_select_multiselect
    @futile.get("/form.html")
    @futile.select("p14", "here")
    @futile.click_button("submit post")
    assert_match(/p14:selected/, @futile.response.body)
    assert_match(/p14:not selected/, @futile.response.body)
  end

  def test_select_from_nonexistent
    @futile.get("/form.html")
    assert_raise(Futile::SearchIsFutile){@futile.select("there is no such select", "#this")}
  end

  def test_select_nonexistent_option
    @futile.get("/form.html")
    assert_raise(Futile::SearchIsFutile){@futile.select("p13", "there is no such option")}
  end

  def test_select_disabled_option
    @futile.get("/form.html")
    assert_raise(Futile::SelectIsFutile){@futile.select("p13", "#disabled")}
  end

  def test_unselect
    @futile.get("/form.html")
    @futile.unselect("p14", "selected1")
    @futile.click_button("button post")
    assert_no_match(/p14:selected1/, @futile.response.body)
    assert_match(/p14:selected2/, @futile.response.body)
  end

  def test_unselect_from_singleselect
    @futile.get("/form.html")
    assert_raise(Futile::SelectIsFutile){@futile.unselect("p13", "selected @02")}
  end

  def test_unselect_not_selected
    @futile.get("/form.html")
    assert_raise(Futile::SelectIsFutile){@futile.unselect("p14", "not selected")}
  end

  def test_unselect_last_option
    @futile.get("/form.html")
    @futile.unselect("p14", "selected1")
    @futile.unselect("p14", "selected2")
    @futile.click_button("button post")
    assert_no_match(/p14/, @futile.response.body)
  end

  def test_reset_happy_path
    @futile.get("/form.html")
    @futile.fill("p1", "u1")
    @futile.uncheck("p8")
    @futile.fill("p5", "textarea mod")
    @futile.click_button("reset1")
    assert_equal "init value", @futile.response.parsed_body.at("#id0")["value"]
    assert @futile.response.parsed_body.at("#id6").has_attribute?("checked")
    assert_equal "Initial value", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_doesnt_reset_other_form
    @futile.get("/form.html")
    @futile.fill("kraps", "other")
    @futile.click_button("reset1")
    assert_equal "other", @futile.response.parsed_body.at("#kraps")["value"]
  end

  def test_uncheck_not_checkbox
    assert_raises(Futile::SearchIsFutile) do
      @futile.get("/form.html")
      @futile.uncheck("p9")
    end
  end

  def test_select_radio_button_unselects_other_from_group
    @futile.get("/form.html")
    @futile.check("radio value 1")
    assert @futile.response.parsed_body.at("#id8")["checked"]
    assert_nil @futile.response.parsed_body.at("#id9")["checked"]
    assert_nil @futile.response.parsed_body.at("#id10")["checked"]
    @futile.check("radio value 3")
    assert_nil @futile.response.parsed_body.at("#id8")["checked"]
    assert_nil @futile.response.parsed_body.at("#id9")["checked"]
    assert @futile.response.parsed_body.at("#id10")["checked"]
  end

  def test_check_invalid_element_raises_futile_check_error
    @futile.get("/form.html")
    assert_raises(Futile::SearchIsFutile) do
      @futile.check("#dontexistlolo123")
    end
  end

  def test_click_link_without_leading_slash
    @futile.get("/simple_html.html")
    @futile.click_link("link without leading slash")
    assert_equal 200, @futile.response.status
  end

  def test_nested_html_relative_url
    @futile.get("/nested_path/index.html")
    @futile.click_link("nested in")
    assert_equal 200, @futile.response.status
  end

  def test_sending_form_without_method_uses_get
    @futile.get("/form_without_method.html")
    @futile.fill("q", "michal bugno")
    @futile.click_button("Search is Futile")
    assert_equal 200, @futile.response.status
    assert @futile.get?
  end
end
