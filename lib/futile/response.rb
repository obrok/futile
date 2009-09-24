class Futile::Response
  attr_reader :body, :content_type, :status, :response, :headers

  def initialize(response)
    @body = response.body
    @content_type = response.content_type
    @status = response.code.to_i
    @headers = response.each_header { |_, _| }
  end

  def redirect?
    status / 100 == 3
  end
end
