require 'test/unit'
require File.join("lib", "futile")
require File.join("test", "server", "server")

class Futile::TestCase < Test::Unit::TestCase
  TEST_SERVER_URI = "http://localhost:6666"

  def setup
    super
    @futile = Futile::Session.new(TEST_SERVER_URI)
  end

  def teardown
    super
    begin
      @futile.disconnect
    rescue
    end
  end

  def assert_include(what, where)
    assert where.include?(what), "%p doesn't include %p" % [where, what]
  end

  def test_default
    # just to get rid of annoying warning: "No tests were specified."
  end
end
