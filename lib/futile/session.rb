class Futile::Session
  attr_reader :session

  def initialize(url, port)
    @session = Net::HTTP.open(url, port)
  end
end
