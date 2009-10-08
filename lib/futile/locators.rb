module Futile::Locators
  private
  def find_link(locator)
    find_element(locator, :a)
  end

  def find_parent(element, name)
    parent = element.parent
    parent = parent.parent while parent.name != name
    parent
  end

  def find_element(locator, name, opts={})
    find_element_in(locator, name, response.parsed_body, opts)
  end

  def find_element_in(locator, name, node, opts={})
    node.xpath(xpath_expression(name, opts)).each do |el|
      return el if el.to_s.include?(locator)
    end
    element = node.at(locator) rescue nil
    element
  end

  def find_select_and_option(locator, what)
    select = find_element(locator, 'select')
    raise Futile::SearchIsFutile.new("Cannot find '#{locator}'") unless select
    option = find_element_in(what, 'option', select)
    raise Futile::SearchIsFutile.new("Cannot find '#{what}' in #{select}") unless option
    raise Futile::SelectIsFutile.new("The option denoted by '#{what}' in #{select} is disabled") if option['disabled']
    [select, option]
  end

  def xpath_expression(name, opts)
    conditions = []
    opts.each do |k,v|
      conditions << "@#{k} = '#{v}'"
    end
    conditions.empty? ? ".//#{name}" : ".//#{name}[#{conditions.join(' and ')}]"
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
      # try to find element by name
      element = response.parsed_body.at("//input[@name='%s']" % [locator])
      element ||= response.parsed_body.at("//textarea[@name='%s']" % [locator])

      # try to find element by value
      element ||= response.parsed_body.at("//input[@value='%s']" % [locator])
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
