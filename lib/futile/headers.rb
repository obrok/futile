##
# This class handles request headers set at next request. You can set predefined
# headers with {#browser=}. You can always set specific headers using simple
# Hash interface
#
# @example Setting headers for Firefox 3.
#   headers.browser = :firefox3
# @example Setting specific header
#   headers[Futile::Headers::ACCEPT] = "*.*" # accept everything
class Futile::Headers < Hash
  ACCEPT          = "accept".freeze
  ACCEPT_CHARSET  = "accept-charset".freeze
  ACCEPT_ENCODING = "accept-encoding".freeze
  ACCEPT_LANGUAGE = "accept-language".freeze
  CONNECTION      = "connection".freeze
  KEEP_ALIVE      = "keep-alive".freeze
  REFERER         = "referer".freeze
  USER_AGENT      = "user-agent".freeze

  REQUEST = {
    :firefox3 =>
    {
      ACCEPT          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8".freeze,
      ACCEPT_CHARSET  => "ISO-8859-1,utf-8;q=0.7,*;q=0.7".freeze,
      ACCEPT_ENCODING => "gzip,deflate".freeze,
      ACCEPT_LANGUAGE => "en-us,en;q=0.5".freeze,
      CONNECTION      => "keep-alive".freeze,
      KEEP_ALIVE      => "300".freeze,
      USER_AGENT      => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3".freeze,
    },
    :safari3 =>
    {
      ACCEPT          => "application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5".freeze,
      ACCEPT_ENCODING => "gzip, deflate".freeze,
      ACCEPT_LANGUAGE => "en-us".freeze,
      CONNECTION      => "keep-alive".freeze,
      USER_AGENT      => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_1; en-us) AppleWebKit/531.9 (KHTML, like Gecko) Version/4.0.3 Safari/531.9".freeze,
    },
  }.freeze

  ##
  # Creates headers object with browser set to _default_browser_.
  def initialize(default_browser)
    super()
    self.browser = default_browser
  end

  ##
  # Returns the current browser (most recent set with {#browser=})
  #
  # @example
  #   headers.current_browser #=> :firefox3
  # @return [Symbol] recent browser
  def current_browser
    @_current_browser
  end

  ##
  # Reset request headers to the most recent browser.
  #
  # @example
  #   headers.browser = :firefox3
  #   headers["keep-alive"] #=> 300
  #   headers["keep-alive"] = 150
  #   headers.reset
  #   headers["keep-alive"] #=> 300
  # @return [Symbol] browser which was reset
  def reset
    self.browser = current_browser
  end

  ##
  # Clears headers (removes them completely). You will probably need to set them
  # again with {#browser=}.
  #
  # @example Clears the request headers
  #   headers["accept"] #=> "*.*"
  #   headers.clear
  #   headers["accept"] #=> nil
  def clear
    super
  end

  ##
  # Sets request headers for specific _browser_. Available browsers can be
  # obtained with Futile::Headers::REQUEST.keys.
  # @example Set headers for Safari 3
  #   headers.browser = :safari3
  # @return [Symbol] browser which was set
  # @raise [Futile::ResistanceIsFutile] raised when browser is not found
  def browser=(browser)
    clear
    @_current_browser = browser
    headers = REQUEST[current_browser]
    unless headers
      msg = "Browser '%s' not found. Available browsers: %s" % [current_browser, REQUEST.keys.join(", ")]
      raise Futile::ResistanceIsFutile.new(msg)
    end
    merge!(headers.dup)
    current_browser
  end
end
