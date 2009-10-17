##
# This class is the base class which is used to perform requests.
class Futile::Session
  include Futile::Locators
  include Futile::Interaction

  GET  = "GET".freeze
  POST = "POST".freeze

  attr_reader :response

  ##
  # Initialize with url/port of the tested page.
  #
  # @example Testing Rails application
  #   session = Futile::Session.new("http://localhost:3000")
  # @example Overriding default :max_redirects option
  #   session = Futile::Session.new("http://www.google.com", {:max_redirects => 100})
  # @param [String, URI] path the web page address to test / uri object
  # @param [Hash] opts override default options
  # @option opts [Fixnum] :max_redirects (10) Number of redirects considered to be
  #   infinite
  # @option opts [Symbol] :default_browser (:firefox3) Browser-specific request
  #   headers
  def initialize(path, opts = {})
    @uri = process_uri(path)
    @session = Net::HTTP.start(@uri.host, @uri.port)
    @max_redirects = opts[:max_redirects] || 10
    @default_browser = opts[:default_browser] || :firefox3
    reset_state
  end

  ##
  # Perform GET request on _uri_.
  #
  # @param [String] uri uri to request
  # @param [Hash] opts Same as opts for {Session#request}
  # @return [Futile::Response] response from the server to the request
  def get(uri, opts={})
    request(uri, opts.merge({:method => GET}))
  end

  def post(uri, opts={})
    request(uri, opts.merge({:method => POST}))
  end

  # Performs a request on _uri_
  #
  # You can pass an absolute uri.
  #
  # @example make a get request to path '/site'
  #   session.get("/site")
  # @param [String] uri relative path to request
  # @param [Hash] opts Miscellanous options
  # @option opts [#to_s] :method The request method. You cas use Futile::Session::GET and Futile::Session::POST
  # @option opts [Hash] :data The data to be sent. Method to_s will be called on both keys
  #   and values to create the request data.
  # @option opts [Hash] :headers Any custom headers that should be added to the request.
  #   Method to_s will be called on both keys and values to produce the actual headers.
  # @return [Futile::Response] response from the server to the request
  # @raise [Futile::RedirectIsFutile] when infinite redirection is encountered
  # @raise [Futile::RequestIsFutile] when response status code is 5xx
  def request(uri, opts={})
    unsupported = opts.keys - [:method, :headers, :data]
    raise Futile::OptionIsFutile.new("The following options are unsupported: #{unsupported.join(" ")}") unless unsupported.empty?

    @uri = process_uri(uri)
    if session_changed?
      disconnect
      @session = Net::HTTP.start(@uri.host, @uri.port)
    end
    method = opts[:method].to_s.upcase
    data = hash_to_params(opts[:data] || {})
    result = case method
             when GET
               session.get("#{path}?#{data}", headers.merge(opts[:headers] || {}))
             when POST
               session.post(path, data)
             else
               raise Futile::ResistanceIsFutile.new("Unknown request method '%s'" % [method])
             end
    @request_method = method
    @response = Futile::Response.new(result)

    if response.redirect?
      follow_redirect
    else
      reset_state
    end
    if response.error?
      raise Futile::RequestIsFutile.new("Response was invalid (%d)" % [response.status])
    end
    response
  end


  ##
  # Current path (i.e. the path which was yielded by last request) together with
  # anchor if there is one.
  #
  # @example Sample path of current page (including anchor)
  #  session.path #=> "/my_page#new"
  # @return [String] current path (relative)
  def path
    [@uri.path, @uri.fragment].compact.join("#")
  end

  ##
  # Absolute path of current page.
  #
  # @example Full path of current page (with params and anchor)
  #   session.full_path #=> "http://google.pl/?q=goatse#no"
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

  ##
  # @return [Boolean] true if last request was GET
  def get?
    @request_method == GET
  end

  ##
  # @return [Boolean] true if last request was POST
  def post?
    @request_method == POST
  end

  ##
  # Use this method to perform any action within scope of filtered HTML.
  #
  # @example Clicking link inside css/xpath selectors
  #   app.within("#menu") do
  #     app.within("//div[1]") do
  #       app.click_link("Item")
  #     end
  #   end
  # @raise [Futile::SearchIsFutile] when scope is not found or multiple scopes
  #   match the _locator_
  def within(locator, &block)
    old_body = response.parsed_body.dup
    elements = response.parsed_body.search(locator)
    if elements.size > 1
      raise Futile::SearchIsFutile.new("Multiple elements found for scope '%s'" % [locator])
    end
    element = elements.first
    raise Futile::SearchIsFutile.new("Scope '%s' not found" % [locator]) unless element
    old_response = response
    response.parsed_body.root.replace(element)
    block.call
  ensure
    if response == old_response # we didn't make any request, back to original body
      response.parsed_body.root.replace(old_body.root)
    end
  end

  ##
  # Hash of headers sent with next request.
  #
  # @return [Futile::Headers] request headers
  def headers
    @_headers ||= Futile::Headers.new(@default_browser)
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
    raise Futile::RedirectIsFutile.new("Infinite redirect for %p" % @uri) if infinite_redirect?
    @no_redirects += 1
    get(response.headers["location"].first)
  end

  def reset_state
    @no_redirects = 0
  end

  def process_uri(path)
    uri = URI.parse(path.to_s)
    unless uri.is_a?(URI::HTTP) # relative path
      # here we handle the case when user inits the session without http scheme
      uri = URI.parse("http://%s" % [path.to_s]) unless @uri
      if uri.to_s[0, 1] != "/" # relative to last folder
        base = File.dirname(@uri.path) rescue ""
        uri.path = File.join(base, uri.path).squeeze("/")
      end
    end
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
