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
      assert_match(/#{pair[1].to_s.upcase}/, @futile.response.body)
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

  [/p1:init value/, /p5:Initial value/, /button:submit post/, /p8:on/, 
   /p10:radio value 2/, /p12:on/, /p13:selected/, /p14:selected1/,
   /p14:selected2/].each do |regex|
    define_method("test_submit_#{regex.to_s.gsub(' ', '_')}") do
      @futile.get("/form")
      @futile.click_button("submit post")
      assert_match(regex, @futile.response.body)
    end
  end

  def test_submit_button_value
    @futile.get("/form")
    @futile.click_button("button post")
    assert_match(/button:button post/, @futile.response.body)
  end

  [/p7:disabled/, /button:submit post/, /p4:/, /p10:radio value1/,
   /p11/, /p13:not selected/, /p14:not selected/].each do |regex|
    define_method("test_submit_not_sent_#{regex.to_s.gsub(' ', '_')}") do
      @futile.get("/form")
      @futile.click_button("button post")
      assert_no_match(regex, @futile.response.body)
    end
  end

  def test_click_button_with_no_form
    @futile.get("/form")
    assert_raises(Futile::ButtonIsFutile){@futile.click_button("random button")}
  end

  def test_click_nonexistent_button
    @futile.get("/form")
    assert_raises(Futile::SearchIsFutile){@futile.click_button("no such button")}
  end

  def test_process_uri_builds_simple_uri
    uri = @futile.send(:process_uri, "/msq#test")
    assert_include "msq#test", uri.to_s
  end

  def test_process_uri_merges_relative_uri
    uri = @futile.send(:process_uri, "http://0.0.0.0:6666/doit")
    assert_include "0.0.0.0:6666", uri.to_s
  end

  def test_process_uri_handles_params
    path = "/?test=params&and_one=more"
    uri = @futile.send(:process_uri, path)
    assert_include path, uri.to_s
  end

  def test_session_changed
    session = @futile.send(:session)
    @futile.get("http://0.0.0.0:6666/form")
    assert session != @futile.send(:session)
  end

  def test_select_singleselect
    @futile.get("/form")
    @futile.select("p13", "here")
    @futile.click_button("button post")
    assert_match(/p13:not selected/, @futile.response.body)
    assert_no_match(/p13:selected/, @futile.response.body)
  end

  def test_select_multiselect
    @futile.get("/form")
    @futile.select("p14", "here")
    @futile.click_button("submit post")
    assert_match(/p14:selected/, @futile.response.body)
    assert_match(/p14:not selected/, @futile.response.body)
  end

  def test_select_from_nonexistent
    @futile.get("/form")
    assert_raise(Futile::SearchIsFutile){@futile.select("there is no such select", "#this")}
  end

  def test_select_nonexistent_option
    @futile.get("/form")
    assert_raise(Futile::SearchIsFutile){@futile.select("p13", "there is no such option")}
  end

  def test_select_disabled_option
    @futile.get("/form")
    assert_raise(Futile::SelectIsFutile){@futile.select("p13", "#disabled")}
  end

  def test_unselect
    @futile.get("/form")
    @futile.unselect("p14", "selected1")
    @futile.click_button("button post")
    assert_no_match(/p14:selected1/, @futile.response.body)
    assert_match(/p14:selected2/, @futile.response.body)
  end

  def test_unselect_from_singleselect
    @futile.get("/form")
    assert_raise(Futile::SelectIsFutile){@futile.unselect("p13", "selected")}
  end

  def test_unselect_not_selected
    @futile.get("/form")
    assert_raise(Futile::SelectIsFutile){@futile.unselect("p14", "not selected")}
  end

  def test_unselect_last_option
    @futile.get("/form")
    @futile.unselect("p14", "selected1")
    @futile.unselect("p14", "selected2")
    @futile.click_button("button post")
    assert_no_match(/p14/, @futile.response.body)
  end

  def test_reset_happy_path
    @futile.get("/form")
    @futile.fill("p1", "u1")
    @futile.uncheck("p8")
    @futile.fill("p5", "textarea mod")
    @futile.click_button("reset1")
    assert_equal "init value", @futile.response.parsed_body.at("#id0")["value"]
    assert @futile.response.parsed_body.at("#id6").has_attribute?("checked")
    assert_equal "Initial value", @futile.response.parsed_body.at("#id4").inner_html
  end

  def test_doesnt_reset_other_form
    @futile.get("/form")
    @futile.fill("kraps", "other")
    @futile.click_button("reset1")
    assert_equal "other", @futile.response.parsed_body.at("#kraps")["value"]
  end

  def test_uncheck_not_checkbox
    assert_raises(Futile::SearchIsFutile) do
      @futile.get("/form")
      @futile.uncheck("p9")
    end
  end
end
