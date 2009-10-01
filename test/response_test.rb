require "test/test_helper.rb"

class ResponseTest < Futile::TestCase
  def test_get
    @futile.get("/simple_get")
    assert @futile.response.body.include?("unique response 445d")
    assert_equal 200, @futile.response.status
  end

  def test_lazy_nokogiri_parsing
    @futile.get("/simple_get")
    @futile.response.instance_variables.each do |var|
      assert @futile.response.instance_variable_get(var).class.name !~ /nokogiri/i
    end
  end

  def test_lazy_nokogiri_parsing_after_body_get
    @futile.get("/simple_get")
    @futile.response.body
    @futile.response.instance_variables.each do |var|
      assert @futile.response.instance_variable_get(var).class.name !~ /nokogiri/i
    end
  end
end
