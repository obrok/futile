class Futile::Response
  attr_reader :content_type, :status, :response, :headers

  def initialize(response)
    @_body = response.body
    @content_type = response.content_type
    @status = response.code.to_i
    @headers = response.each_header { |_, _| }
  end

  ##
  # @return [Boolean] true if redirected
  def redirect?
    status / 100 == 3
  end

  ##
  # This method returns actual body of the page. Note that this might be
  # afftected by methods which type/select/check elements.
  #
  # @return [String] body of response
  def body
    @_body || parsed_body.to_s
  end

  ##
  # Parsed body by Nokogiri.
  #
  # @return [Nokogiri] Nokogiri--parsed body.
  def parsed_body
    unless @parsed_body
      @parsed_body = Nokogiri.parse(@_body)
      @_body = nil
    end
    @parsed_body
  end
end
