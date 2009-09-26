##
# This class is the base class which is used to perform requests and check
# results.
class Futile::Session
  include Futile::Helpers

  attr_reader :response

  ##
  # Initialize with url/port of the tested page.
  #
  #  app = Futile::Session.new("localhost:3000")
  # would test your Rails application
  #
  #  app = Futile::Session.new("www.google.com", {:max_redirects => 100})
  # Set the number of redirects considered to be an infinite redirect.
  #
  # @param [String, URI] path the web page address to test / uri object
  # @param [Hash] opts override default options
  def initialize(path, opts = {})
    if path.is_a?(URI)
      url, port = path.host, path.port
    else
      url, port = path.split(":")
      port ||= 80
    end
    @session = Net::HTTP.start(url, port)
    @max_redirects = opts[:max_redirects] || 10
    reset_state
  end

  ##
  # Performs a simple get on base url.
  # Please mind that the uri *must* begin with a slash ('/'), otherwise the
  # request will be invalid.
  #
  #  app.get("/site")
  #
  # @param [String] uri relative path to request
  # @param [Hash] opts additional options:
  # :method - 'post' or 'get' - request method
  # @return [Futile::Response] response from the server to the request
  # @raise [Futile::RedirectIsFutile] when infinite redirection is encountered
  def get(uri, opts = {})
    reset_state
    @uri = uri
    result = opts[:method] == 'post' ? session.post(@uri, {}) : session.get(@uri)
    @response = Futile::Response.new(result)
    while response.redirect? and not infinite_redirect?
      follow_redirect
    end
    if infinite_redirect?
      raise Futile::RedirectIsFutile.new("Infinite redirect for %p" % @uri)
    else
      response
    end
  end

  ##
  # Clicks link (HTML tag <a>) specified by _locator_. This means that a request
  # to path found in _href_ attribute is performed.
  #
  # @param [String] locator locator to specify a link. This can be either the
  #        inner html of link or xpath/css locator
  # @return [Futile::Response] response to the request
  # @raise [Futile::SearchIsFutile] raised when the link specified by _locator_
  #        could not be found
  def click_link(locator)
    link = find_link(locator)
    raise Futile::SearchIsFutile.new("Could not find '%s'" % locator) unless link
    href = link['href']
    if href =~ /^#/
      @uri = @uri.split("#")[0] + href
      response
    else
      get(href)
    end
  end

  ##
  # Clicks button (HTML tag <submit> or <button>) specified by _locator_. This means
  # that a request to path found in the containing form's _href_ attribute is
  # performed with the appropriate method
  #
  # @param [String] locator locator to specify a button. This can be either the
  #        inner html of link or xpath/css locator
  # @return [Futile::Response] response to the request
  # @raise [Futile::SearchIsFutile] raised when the button specified by _locator_
  #        could not be found
  def click_button(locator)
    form = find_form(locator)
    get(form['action'], :method => form['method'] || 'post')
  end

  ##
  # Current path (i.e. the path which was yielded by last request)
  #
  # @return [String] current path (relative)
  def path
    @uri
  end

  ##
  # Returns true if last request ended with redirect (3xx status code)
  #
  # @return [Boolean] true if redirection happened
  def redirected?
    @no_redirects > 0
  end

  def disconnect
    @session.finish
  end

  ##
  # Finds input element (HTML tags <input> and <textarea>) by its label or name
  # and fills it with _what_.
  #
  #  fill("value", "Michal") # => <input name="param" value="Michal"/>
  #
  # @param [String] locator label's inner html or xpath/css locator
  # @param [String] what the text to type into field
  # @raise [Futile::SearchIsFutile] raised when no element found, two or more
  #         elements found or element is not suitable for typing
  # @return [String] the text filled
  def fill(locator, what)
    element = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless element
    if not (["text", "password"].include?(element["type"] || "text")) and element.name != "textarea"
      # cannot type if the element is not a text field, password field or textarea
      raise Futile::SearchIsFutile.new("Cannot type into '%s'" % [element])
    end
    if element.name == "input"
      element["value"] = what
    else
      element.inner_html = what
    end
  end

  def select(locator, what)
  end

  ##
  # Use this method to check a checkbox input specified by _locator_.
  #
  #  # => <input type="checkbox" name="foo" value="on">
  #  session.check("foo") # => <input type="checkbox" name="foo" value="on" checked>
  #
  # @param [String] locator label/name of checkbox
  # @raise [Futile::SearchIsFutile] raised when element not found
  # @raise [Futile::CheckIsFutile] raised when checkbox is already checked
  def check(locator)
    checkbox = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless checkbox
    if checkbox.name != "input" or checkbox["type"] != "checkbox"
      raise Futile::SearchIsFutile.new("Element '%s' is not a checkbox" % [element])
    end
    if checkbox["checked"]
      raise Futile::CheckIsFutile.new("Element '%s' already checked" % [checkbox])
    end
    checkbox["checked"] = "checked"
  end

  ##
  # Use this method to uncheck a checkbox input specified by _locator_.
  #
  #  # => <input type="checkbox" name="foo" value="on" checked>
  #  session.uncheck("foo") # => <input type="checkbox" name="foo" value="on">
  #
  # @param [String] locator label/name of checkbox
  # @raise [Futile::SearchIsFutile] raised when element not found
  # @raise [Futile::CheckIsFutile] raised when checkbox is not checked
  def uncheck(locator)
    checkbox = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless checkbox
    if checkbox.name != "input" or checkbox["type"] != "checkbox"
      raise Futile::SearchIsFutile.new("Element '%s' is not a checkbox" % [element])
    end
    unless checkbox["checked"]
      raise Futile::CheckIsFutile.new("Element '%s' already unchecked" % [checkbox])
    end
    checkbox.remove_attribute("checked")
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
  end
end
