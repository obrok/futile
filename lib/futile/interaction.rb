##
# Module gets mixed in Futile::Session providing user interaction like filling
# forms or clicking links/buttons.
module Futile::Interaction
  ##
  # Clicks link (HTML tag <a>) specified by _locator_. This means that a request
  # to path found in _href_ attribute is performed.
  #
  # @param [String] locator locator to specify a link. This can be either the
  #        inner html of link or xpath/css locator
  # @return [Futile::Response] response to the request
  # @raise [Futile::SearchIsFutile] raised when the link specified by _locator_
  #        could not be found
  def click_link(locator)
    link = find_link(locator)
    raise Futile::SearchIsFutile.new("Could not find '%s' link" % locator) unless link
    href = link['href']
    if href =~ /^#/
      @uri.fragment = href[1 .. -1]
      response
    else
      get(href, 'Referer' => @uri.to_s)
    end
  end

  ##
  # Clicks button (HTML tag <submit> or <button>) specified by _locator_. This means
  # that either a request to path found in the containing form's _action_ attribute is
  # performed with the appropriate method or a reset button is clicked and
  # current form is reset.
  #
  # @param [String] locator locator to specify a button. This can be either the
  #        inner html of link or xpath/css locator
  # @return [Futile::Response] response to the request
  # @raise [Futile::SearchIsFutile] raised when the button specified by _locator_
  #        could not be found
  # @raise [Futile::ButtonIsFutile] raised when the button specified by
  #        _locator_ is not inside a <form>
  def click_button(locator)
    button = find_element(locator, :button) ||
             find_element(locator, :input, :type => 'submit') ||
             find_element(locator, :input, :type => 'reset')
    raise Futile::SearchIsFutile.new("Could not find \"#{locator}\" button") unless button
    form = find_parent(button, 'form')
    if button["type"] == "reset"
      reset_form(form)
    else
      data = build_params(form, button)
      request(form['action'], form['method'] || Futile::Session::POST, data)
    end
  rescue NoMethodError
    raise Futile::ButtonIsFutile.new("The button \"#{locator}\" does not belong to a form")
  end

  ##
  # Finds input element (HTML tags <input> and <textarea>) by its label or name
  # and fills it with _what_.
  #
  # @example Filling field named _param_ with value _Michal_
  #   session.fill("param", "Michal") #=> <input name="param" value="Michal"/>
  # @param [String] locator label's inner html or xpath/css locator
  # @param [String] what the text to type into field
  # @raise [Futile::SearchIsFutile] raised when no element found, two or more
  #         elements found or element is not suitable for typing
  # @return [String] the text filled
  def fill(locator, what)
    element = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless element
    if not (["text", "password"].include?(element["type"] || "text")) and element.name != "textarea"
      # cannot type if the element is not a text field, password field or textarea
      raise Futile::SearchIsFutile.new("Cannot type into '%s'" % [element])
    end
    if element.name == "input"
      element["value"] = what
    else
      element.inner_html = what
    end
  end

  ##
  # Selects an option from a select form element
  #
  # @example Selecting option with id='that' in select with id='this'.
  #   select("#this", "#that") #=> <option id="that" selected>Text</option>
  # @param [String] locator select's inner html or xpath/css locator
  # @param [String] the desired option's inner html or xpath/css locator
  # @raise [Futile::SearchIsFutile] raised when no element found, two or more
  #        elements found or the elemnt is not a select or an option
  # @raise [Futile::SelectIsFutile] raised when trying to select a
  #        disabled option
  # @return [Nokogiri::XML::Node] the element selected
  def select(locator, what)
    select, option = find_select_and_option(locator, what)
    select.xpath('.//option[@selected]').each do |opt|
      opt.delete('selected')
    end unless select['multiple']
    option['selected'] = 'true'
    option
  end

  ##
  # Unselects an option from a multiselect
  #
  # @example Unselecting (within multiselect fields)
  #   select("#this", "#that") #=> <option id="that">Text</option>
  # @param [String] locator select's inner html or xpath/css locator
  # @param [String] the option's to unselect inner html or xpath/css locator
  # @raise [Futile::SearchIsFutile] raised when no element found, two or more
  #        elements found or the elemnt is not a select or an option
  # @raise [Futile::SelectIsFutile] raised when trying to unselect an
  #        unselected option or when trying to unselecte from a singleselect
  # @return [Nokogiri::XML::Node] the element unselected
  def unselect(locator, what)
    select, option = find_select_and_option(locator, what)
    raise Futile::SelectIsFutile.new("\"#{select}\" does not allow multiple selections") unless select['multiple']
    raise Futile::SelectIsFutile.new("Option \"#{what}\" in \"#{select}\" is not selected") unless option['selected']
    option.delete('selected')
    option
  end

  ##
  # Use this method to check a checkbox/radiobutton input specified by _locator_.
  #
  # @example Checking a checkbox named "foo"
  #   #=> <input type="checkbox" name="foo" value="on">
  #   session.check("foo") #=> <input type="checkbox" name="foo" value="on" checked>
  # @param [String] locator label/name of checkbox
  # @raise [Futile::SearchIsFutile] raised when element not found
  # @raise [Futile::CheckIsFutile] raised when checkbox is already checked
  def check(locator)
    checkbox = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless checkbox
    if checkbox.name != "input" and (checkbox["type"] != "checkbox" or checkbox["type"] != "radio")
      raise Futile::SearchIsFutile.new("Element '%s' is not a checkbox/radio" % [checkbox])
    end
    if checkbox["checked"]
      raise Futile::CheckIsFutile.new("Element '%s' already checked" % [checkbox])
    end
    if checkbox["type"] == "checkbox"
      checkbox["checked"] = "checked"
    elsif checkbox["type"] == "radio"
      radios = response.parsed_body.search("//input[@type='radio' and @name='%s']" % [checkbox["name"]])
      radios.each { |radio| radio.remove_attribute("checked") }
      checkbox["checked"] = "checked"
    end
  end

  ##
  # Use this method to uncheck a checkbox input specified by _locator_.
  #
  # @example Unchecking checkbox named "foo"
  #   #=> <input type="checkbox" name="foo" value="on" checked>
  #   session.uncheck("foo") #=> <input type="checkbox" name="foo" value="on">
  # @param [String] locator label/name of checkbox
  # @raise [Futile::SearchIsFutile] raised when element not found
  # @raise [Futile::CheckIsFutile] raised when checkbox is not checked
  def uncheck(locator)
    checkbox = find_input(locator)
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [locator]) unless checkbox
    if checkbox.name != "input" or checkbox["type"] != "checkbox"
      raise Futile::SearchIsFutile.new("Element '%s' is not a checkbox" % [checkbox])
    end
    unless checkbox["checked"]
      raise Futile::CheckIsFutile.new("Element '%s' already unchecked" % [checkbox])
    end
    checkbox.remove_attribute("checked")
  end

  private
  def reset_form(form)
    original_form = response.original_parsed_body.at(form.path)
    form.replace(original_form)
  end
end
