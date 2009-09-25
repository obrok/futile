module Futile::Helpers
  def fill(where, what)
    element = response.parsed_body.at("//input[@name='%s']" % [where])
    raise Futile::SearchIsFutile.new("Cannot find '%s'" % [where]) if not element
    params[element["name"]] = what
  end

  def select(from, what)
  end

  def check(what)
  end

  def uncheck(what)
  end

  private
  def params_to_string
    params.map { |k, v| "%s=%s" % [k, v] }.join("&")
  end
end
