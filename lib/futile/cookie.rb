module Futile
  class Cookie
    attr_accessor :name, :value, :expires, :path, :domain

    def initialize(domain)
      self.path = "/"
      self.domain = domain
    end

    def expired?
      expires && expires < Time.now
    end

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
  end
end
