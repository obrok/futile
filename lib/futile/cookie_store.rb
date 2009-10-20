module Futile
  class CookieStore
    def initialize
      @children = {}
      @cookies = []
    end

    ##
    # Insert a Futile::Cookie into this CookieStore
    #
    # @param [Futile::Cookie] cookie The cookie to insert.
    def insert(cookie)
      _insert(cookie, path_to_array(cookie.path))
    end

    ##
    # Gets all cookies on the specified path and above from this CookieStore. The CookieStore
    # manages cookie expiry dates implicitly.
    #
    # @param [String] path The path for which to get cookies. Defaults to "/" (all cookies).
    # @return [Array] An array of Futile::Cookies
    def cookies(path="/")
      _cookies(path_to_array(path))
    end

    protected
    def path_to_array(path)
      path.sub(/^\//,"").sub(/\/$/, "").split("/")
    end

    def _insert(cookie, path)
      if path.empty?
        @cookies << cookie
      else
        element = path.shift
        @children[element] ||= CookieStore.new
        @children[element]._insert(cookie, path)
      end
    end

    def _cookies(path)
      @cookies = @cookies.select{|x| !x.expired?}
      return @cookies if path.empty?
      node = path.shift
      children = @children[node] ? @children[node]._cookies(path) : []
      @cookies + children
    end
  end
end
