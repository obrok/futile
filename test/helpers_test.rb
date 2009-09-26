require "test/test_helper.rb"

class HelpersTest < Futile::TestCase
  ["link q9", '//a', 'html > body > a'].each_with_index do |locator, index|
    define_method "test_find_link(#{locator})".to_sym do
      @futile.get('/simple_get')
      assert_equal("<a href=\"/second_page\">link q9</a>", @futile.send(:find_link, locator).to_s)
    end
  end
end
