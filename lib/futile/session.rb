class Futile::Session
  include Futile::Helpers

  attr_reader :response, :params

  def initialize(url, port, opts = {})
    @session = Net::HTTP.start(url, port)
    @max_redirects = opts[:max_redirects] || 10
    reset_state
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

  def click_link(locator)
    link = find_link(locator)
    raise Futile::SearchIsFutile.new("Could not find '%s'" % locator) unless link
    href = link['href']
    if href =~ /^#/
      @uri = @uri.split("#")[0] + href
    else
      get(link['href'])
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

  def fill(where, what)
    # first find the only unique label
    labels = response.parsed_body.search("//label[text()='%s']" % where)
    if labels.size > 1
      raise Futile::SearchIsFutile.new("Multiple labels found for '%s'" % [where])
    end
    label = labels.first
    if label
      # if the label was found locate element it was labeling
      element = response.parsed_body.at("//input[@id='%s']" % [label["for"]])
      element ||= response.parsed_body.at("//textarea[@id='%s']" % [label["for"]])
    else
      # else try to find element by name
      element = response.parsed_body.at("//input[@name='%s']" % [where])
      element ||= response.parsed_body.at("//textarea[@name='%s']" % [where])
    end
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [where]) unless element
    if not (["text", "password"].include?(element["type"] || "text")) and element.name != "textarea"
      # cannot type if the element is not a text field, password field or textarea
      raise Futile::SearchIsFutile.new("Cannot type into '%s'" % [element])
    end
    if element["disabled"] or element["readonly"]
      # cannot type into disabled/readonly field
      raise Futile::SearchIsFutile.new("Element '%s' is disabled/readonly" % [element])
    end
    params[element["name"]] = what
  end

  def select(from, what)
  end

  def check(what)
  end

  def uncheck(what)
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
