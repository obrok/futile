require 'test/unit'
require File.join("lib", "futile")
require File.join("test", "test_server")

class Futile::TestCase < Test::Unit::TestCase
  def setup
    super
    @futile = Futile::Session.new("localhost", 6666)
  end

  def teardown
    super
    begin
      @futile.disconnect
    rescue
    end
  end

  def test_default
    # just to get rid of annoying warning: "No tests were specified."
  end
end
