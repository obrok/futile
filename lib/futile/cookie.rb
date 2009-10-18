module Futile
  class Cookie
    attr_accessor :name, :value, :expires

    def expired?
      expires && expires < Time.now
    end

    def self.parse(cookie_string)
      cookie = Cookie.new
      fields = cookie_string.split(";")

      name, value = fields.shift.split("=")
      cookie.name = name
      cookie.value = value

      fields.each do |field|
        name, value = field.split("=")
        case name.strip
        when "expires"
          cookie.expires = Time.parse(value)
        end
      end
      cookie
    end
  end
end
