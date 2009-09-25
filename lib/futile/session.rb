class Futile::Session
  include Futile::Helpers

  attr_reader :response, :params

  def initialize(url, port, opts = {})
    @session = Net::HTTP.start(url, port)
    @max_redirects = opts[:max_redirects] || 10
  end

  def get(uri)
    reset_state
    @uri = uri
    @response = Futile::Response.new(session.get(@uri))
    while response.redirect? and not infinite_redirect?
      follow_redirect
    end
    if infinite_redirect?
      raise Futile::RedirectIsFutile.new("Infinite redirect for %p" % @uri)
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

  def disconnect
    @session.finish
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

  def reset_state
    @no_redirects = 0
    @uri = nil
    @params = {}
  end
end
