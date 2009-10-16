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
  ACCEPT = "accept".freeze
  ACCEPT_LANGUAGE = "accept-language".freeze
  ACCEPT_ENCODING = "accept-encoding".freeze
  ACCEPT_CHARSET = "accept-charset".freeze
  KEEP_ALIVE = "keep-alive".freeze
  CONNECTION = "connection".freeze

  REQUEST = {
    :firefox3 =>
    {
      ACCEPT          => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      ACCEPT_LANGUAGE => "en-us,en;q=0.5",
      ACCEPT_ENCODING => "gzip,deflate",
      ACCEPT_CHARSET  => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
      KEEP_ALIVE      => "300",
      CONNECTION      => "keep-alive",
    },
  }.freeze

  ##
  # Sets request headers for specific _browser_. Available browsers can be
  # obtained with Futile::Headers::REQUEST.keys.
  #
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
