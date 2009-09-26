class Futile::Response
  attr_reader :body, :content_type, :status, :response, :headers

  def initialize(response)
    @body = response.body
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
  # @return [Nokogiri] response body parsed with Nokogiri
  def parsed_body
    @parsed_body ||= Nokogiri.parse(@body)
  end
end
