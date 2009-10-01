class Futile::Response
  attr_reader :parsed_body, :content_type, :status, :response, :headers

  def initialize(response)
    @parsed_body = Nokogiri.parse(response.body)
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
    parsed_body.to_s
  end
end
