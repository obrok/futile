class Futile::Session
  attr_reader :response

  def initialize(url, port, opts = {})
    @session = Net::HTTP.start(url, port)
    @max_redirects = opts[:max_redirects] || 10
    @no_redirects = 0
  end

  def get(uri)
    @uri = uri
    @uri = "/%s" % @uri if @uri[0, 1] != "/"
    @no_redirects = 0
    @response = Futile::Response.new(session.get(@uri))
    while response.redirect? and not infinite_redirect?
      follow_redirect
    end
    if infinite_redirect?
      raise RedirectIsFutile.new("Infinite redirect for %p" % @uri)
    else
      response
    end
  end

  def path
    @uri
  end

  def redirected?
    @no_redirects > 0
  end

  private
  def session
    @session
  end

  def infinite_redirect?
    @no_redirects > @max_redirects
  end

  def follow_redirect
    @uri = response.headers["location"]
    @response = Futile::Response.new(session.get(@uri))
    @no_redirects += 1
  end
end
