require "test/test_helper.rb"

class HeadersTest < Futile::TestCase
  {
    "host"            => "localhost:6666",
    "accept"          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "accept-language" => "en-us,en;q=0.5",
    "accept-encoding" => "gzip,deflate",
    "accept-charset"  => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
    "keep-alive"      => "300",
    "connection"      => "keep-alive",
  }.each do |header, value|
    define_method "test_header_#{header.gsub("-", "_")}".to_sym do
      @futile.get("/request_headers")
      headers = parse_response_headers(@futile.response.body)
      assert_header(headers, header, value)
    end
  end

  def test_raises_when_browser_not_found
    assert_raises(Futile::ResistanceIsFutile) do
      @futile.headers.browser = :naughty_boy
    end
  end

  def test_frozen_sample_headers
    assert_raises(TypeError) do
      Futile::Headers::REQUEST.delete(:any_key_will_do)
    end
  end

  def test_default_browser
    @futile = Futile::Session.new("localhost:6666", {:default_browser => :just_to_check})
    exception = assert_raises(Futile::ResistanceIsFutile) do
      @futile.headers
    end
    assert_include "just_to_check", exception.message
  end

  private
  def parse_response_headers(body)
    headers_params = body.split("\n")[1..-2]
    headers = {}
    headers_params.each do |header|
      name, value = header.split(" => ")
      headers[name] = value
    end
    headers
  end
end
