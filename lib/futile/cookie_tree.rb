module Futile
  class CookieTree
    def initialize
      @children = {}
      @cookies = []
    end

    def insert(cookie, path=cookie.path)
      path = path.sub(/^\//,"").sub(/\/$/, "").split("/")
      if path.empty?
        @cookies << cookie
      else
        element = path.shift
        @children[element] ||= CookieTree.new
        @children[element].insert(cookie, path.join("/"))
      end
    end

    def cookies(path="/")
      @cookies = @cookies.select{|x| !x.expired?}
      path = path.sub(/^\//,"").sub(/\/$/, "").split("/")
      return @cookies if path.empty?
      node = path.shift
      children = @children[node] ? @children[node].cookies(path.join("/")) : []
      @cookies + children
    end
  end
end
