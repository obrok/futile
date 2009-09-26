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

  def find_input(locator)
    # first find the only unique label
    labels = response.parsed_body.search("//label[text()='%s']" % [locator])
    if labels.size > 1
      raise Futile::SearchIsFutile.new("Multiple labels found for '%s'" % [locator])
    end
    label = labels.first
    if label
      # if the label was found locate element it was labeling
      element = response.parsed_body.at("//input[@id='%s']" % [label["for"]])
      element ||= response.parsed_body.at("//textarea[@id='%s']" % [label["for"]])
    else
      # else try to find element by name
      element = response.parsed_body.at("//input[@name='%s']" % [locator])
      element ||= response.parsed_body.at("//textarea[@name='%s']" % [locator])
    end

    # don't bother, the element is no more
    return nil unless element

    if not (["text", "password"].include?(element["type"] || "text")) and element.name != "textarea"
      # cannot type if the element is not a text field, password field or textarea
      raise Futile::SearchIsFutile.new("Cannot type into '%s'" % [element])
    end
    if element["disabled"] or element["readonly"]
      # cannot type into disabled/readonly field
      raise Futile::SearchIsFutile.new("Element '%s' is disabled/readonly" % [element])
    end
    element
  end

  def params_to_string
    params.map { |k, v| "%s=%s" % [k, v] }.sort.join("&")
  end
end
