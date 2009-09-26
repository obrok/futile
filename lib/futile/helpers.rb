module Futile::Helpers
  private
  def find_form(button_locator)
    button = find_element(button_locator, :button) || find_element(button_locator, :submit)
    find_parent(button, 'form')
  end

  def find_link(locator)
    find_element(locator, :a)
  end

  def find_parent(element, type)
    parent = element.parent
    parent = parent.parent while parent.name != type
    parent
  end

  def find_element(locator, type)
    response.parsed_body.xpath("//#{type}").each do |el|
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

    if element["disabled"] or element["readonly"]
      # cannot type into disabled/readonly field
      raise Futile::SearchIsFutile.new("Element '%s' is disabled/readonly" % [element])
    end
    element
  end
end
