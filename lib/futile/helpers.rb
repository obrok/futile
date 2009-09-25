module Futile::Helpers
  def select(from, what)
    p params_to_string
  end

  def type(where, what)
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
