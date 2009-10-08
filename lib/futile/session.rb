##
# This class is the base class which is used to perform requests.
class Futile::Session
  include Futile::Locators
  include Futile::Interaction

  GET  = "GET"
  POST = "POST"

  attr_reader :response

  ##
  # Initialize with url/port of the tested page.
  #
  #  app = Futile::Session.new("http://localhost:3000")
  # would test your Rails application
  #
  #  app = Futile::Session.new("http://www.google.com", {:max_redirects => 100})
  # Set the number of redirects considered to be an infinite redirect.
  #
  # @param [String, URI] path the web page address to test / uri object
  # @param [Hash] opts override default options
  def initialize(path, opts = {})
    @uri = process_uri(path)
    @session = Net::HTTP.start(@uri.host, @uri.port)
    @max_redirects = opts[:max_redirects] || 10
    reset_state
  end

  ##
  # Perform GET request on _uri_.
  #
  # @param [String] uri uri to request
  # @return [Futile::Response] response from the server to the request
  def get(uri, headers={})
    request(uri, GET, {}, headers)
  end

  # Performs a request on _uri_
  # Please keep in mind that the relative uri *must* begin with a slash ('/'), otherwise
  # the request will be invalid.
  #
  #  app.get("/site")
  #
  # You can pass an absolute uri.
  #
  # @param [String] uri relative path to request
  # @param [String] method request method
  # @return [Futile::Response] response from the server to the request
  # @raise [Futile::RedirectIsFutile] when infinite redirection is encountered
  def request(uri, method, data = {}, headers={})
    reset_state
    @uri = process_uri(uri)
    if session_changed?
      disconnect
      @session = Net::HTTP.start(@uri.host, @uri.port)
    end
    method = method.upcase
    result = case method
             when GET
               session.get(path, headers)
             when POST
               session.post(path, hash_to_params(data))
             else
               raise Futile::ResistanceIsFutile.new("Unknown request method '%s'" % [method])
             end
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
  # Current path (i.e. the path which was yielded by last request) together with
  # anchor if there is one.
  #
  #  session.path # => "/my_page#new"
  #
  # @return [String] current path (relative)
  def path
    [@uri.path, @uri.fragment].compact.join("#")
  end

  ##
  # Absolute path of current page.
  #
  #  session.full_path # => "http://google.pl/?q=goatse#no"
  #
  # @return [String] absolute path
  def full_path
    @uri.to_s
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

  private
  def session
    @session
  end

  def session_changed?
    (@session.address != @uri.host) or (@session.port != @uri.port)
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
  end

  def process_uri(uri)
    uri = URI.parse(uri.to_s)
    uri.port = uri.port || @uri.port || 80
    unless uri.is_a?(URI::HTTP)
      uri.host = @uri.host
      uri.scheme = @uri.scheme
      # to be sure that we have an instance of URI::HTTP
      uri = URI.parse(uri.to_s)
    end
    uri
  end

  def build_params(form, button)
    data = {}
    form.xpath('.//input|.//textarea|.//select').each do |input|
      if input.name == 'input' && input[:type] == 'checkbox'
        data[input[:name]] = 'on' if input[:checked]
      elsif input.name == 'input' && input[:type] == 'radio'
        data[input[:name]] = input[:value] || 'on' if input[:checked]
      elsif input.name == 'input'
        data[input[:name]] = input[:value] || ''
      elsif input.name == 'textarea'
        data[input[:name]] = input.inner_html
      elsif input.name == 'select'
        data[input[:name]] = input.xpath('.//option[@selected]').map{|x| x[:value] || ""}
      end unless input[:disabled] || input[:type] == 'submit'
    end
    data.merge(button[:name] => button[:value])
  end

  def hash_to_params(data)
    params = []
    data.each do |k,v|
      [*v].each {|element| params << "#{CGI.escape(k.to_s)}=#{CGI.escape(element.to_s)}"}
    end
    params.join('&')
  end
end
