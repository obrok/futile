module Futile::Helpers
  private
  def find_link(locator)
    #First try to treat it as a CSS or XPath locator
    #If that doesn't work search for a tag matching the specified text
    response.parsed_body.xpath('//a').each do |el|
      return el if el.to_s.include?(locator)
    end
    element = response.parsed_body.at(locator) rescue nil
    element
  end

  def params_to_string
    params.map { |k, v| "%s=%s" % [k, v] }.sort.join("&")
  end
end
