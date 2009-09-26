module Futile::Helpers
  def fill(where, what)
    # first find the only unique label
    labels = response.parsed_body.search("//label[text()='%s']" % where)
    if labels.size > 1
      raise Futile::SearchIsFutile.new("Multiple labels found for '%s'" % [where])
    end
    label = labels.first
    if label
      # if the label was found locate element it was labeling
      element = response.parsed_body.at("//input[@id='%s']" % [label["for"]])
      element ||= response.parsed_body.at("//textarea[@id='%s']" % [label["for"]])
    else
      # else try to find element by name
      element = response.parsed_body.at("//input[@name='%s']" % [where])
      element ||= response.parsed_body.at("//textarea[@name='%s']" % [where])
    end
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [where]) unless element
    if not (["text", "password"].include?(element["type"] || "text")) and element.name != "textarea"
      # cannot type if the element is not a text field, password field or textarea
      raise Futile::SearchIsFutile.new("Cannot type into '%s'" % [element])
    end
    if element["disabled"] or element["readonly"]
      # cannot type into disabled/readonly field
      raise Futile::SearchIsFutile.new("Element '%s' is disabled/readonly" % [element])
    end
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
