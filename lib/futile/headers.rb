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
  KEEP_ALIVE      = "keep-alive".freeze
  CONNECTION      = "connection".freeze
  USER_AGENT      = "user-agent".freeze

  REQUEST = {
    :firefox3 =>
    {
      ACCEPT          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      ACCEPT_CHARSET  => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
      ACCEPT_ENCODING => "gzip,deflate",
      ACCEPT_LANGUAGE => "en-us,en;q=0.5",
      CONNECTION      => "keep-alive",
      KEEP_ALIVE      => "300",
      USER_AGENT      => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3",
    },
    :safari3 =>
    {
      ACCEPT          => "application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5",
      ACCEPT_ENCODING => "gzip, deflate",
      ACCEPT_LANGUAGE => "en-us",
      CONNECTION      => "keep-alive",
      USER_AGENT      => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_1; en-us) AppleWebKit/531.9 (KHTML, like Gecko) Version/4.0.3 Safari/531.9",
    }
  }.freeze

  ##
  # Sets request headers for specific _browser_. Available browsers can be
  # obtained with Futile::Headers::REQUEST.keys.
  # @example Set headers for Safari 3
  #   headers.browser = :safari3
  # @raise [Futile::ResistanceIsFutile] raised when browser is not found
  def browser=(browser)
    headers = REQUEST[browser]
    unless headers
      msg = "Browser '%s' not found. Available browsers: %s" % [browser, REQUEST.keys.join(", ")]
      raise Futile::ResistanceIsFutile.new(msg)
    end
    merge!(headers.dup)
  end
end
