module Futile::Helpers
  def fill(where, what)
    element = response.parsed_body.at("//input[@name='%s']" % [where])
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [where]) unless element
    params[element["name"]] = what
  end

  def select(from, what)
  end

  def check(what)
  end

  def uncheck(what)
  end

  def find_link(locator)
    #First try to treat it as a CSS or XPath locator
    element = response.parsed_body.at(locator)
    #If that doesn't work search for a tag matching the specified text
    response.parsed_body.xpath('//a').each do |el|
      return el.to_s if el.to_s.include?(locator)
    end unless element
    element.to_s
  end

  private
  def params_to_string
    params.map { |k, v| "%s=%s" % [k, v] }.join("&")
  end
end
