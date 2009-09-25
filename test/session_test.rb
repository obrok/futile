# -*- coding: utf-8 -*-
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

  ["Jakiś tekst", '//a', 'html > body > a'].each_with_index do |locator, index|
    define_method "test_find_link(#{locator})".to_sym do
      TestServer.content = <<-HTML
      <html>
        <body>
          <a href="wp.pl">Jakiś tekst</a>
        </body>
      </html>
      HTML
      @futile.get('/')
      assert_equal("<a href=\"wp.pl\">Jakiś tekst</a>", @futile.find_link(locator))
    end
  end
end
