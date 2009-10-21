module Futile
  class Cookie
    attr_accessor :name, :value, :expires, :path, :domain

    ##
    # Test if this Cookie has expired.
    def expired?
      !!(expires && expires < Time.now)
    end

    ##
    # Parses a cookie from a string.
    #
    # @param [String] cookie_string The textual representation of the cookie.
    # @param [String] domain The cookie's domain will be set to this if the
    #   cookie_string doesn't contain a domain field.
    def self.parse(cookie_string, domain)
      cookie = Cookie.new(domain)
      fields = cookie_string.split(";")

      name, value = fields.shift.split("=")
      cookie.name = name
      cookie.value = value

      fields.each do |field|
        name, value = field.split("=")
        case name.strip
        when "expires"
          cookie.expires = Time.parse(value)
        when "domain"
          cookie.domain = value.split(":").first.split("//").last
        when "path"
          cookie.path = value
        end
      end
      cookie
    end

    protected
    def initialize(domain)
      self.path = "/"
      self.domain = domain
    end
  end
end
