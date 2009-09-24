class Futile::Session
  attr_reader :response

  def initialize(url, port)
    @session = Net::HTTP.start(url, port)
  end

  def get(uri)
    uri = "/" + uri if uri[0, 1] != "/"
    @no_redirects = 0
    @response = Futile::Response.new(session.get(uri))
    while response.redirect? and not infinite_redirect?
      uri = @response.headers["location"]
      @response = Futile::Response.new(session.get(uri))
      @no_redirects += 1
    end
    if infinite_redirect?
      raise "Infinite redirect"
    else
      @response
    end
  end

  private
  def session
    @session
  end

  def infinite_redirect?
    @no_redirects > 10
  end
end
