require 'stringio'
require 'zlib'

class Futile::Response
  attr_reader :status # Returns Fixnum representing status of the response.
  attr_reader :headers # Returns Hash of headers sent with this response.

  def initialize(response)
    @status = response.code.to_i
    @headers = response.each_header { |_, _| }
    @body = extract_body(response.body, *headers[Futile::Headers::CONTENT_ENCODING])
    @status = response.code.to_i
  end

  ##
  # @return [Boolean] true if redirected
  def redirect?
    status / 100 == 3
  end

  ##
  # @return [Boolean] true if response code was 5xx
  def error?
    status / 100 == 5
  end

  ##
  # This method returns actual body of the page. Note that this might be
  # afftected by methods which type/select/check elements.
  #
  # @return [String] body of response
  def body
    if @parsed_body
      parsed_body.to_s
    else
      @body
    end
  end

  ##
  # Parsed body by Nokogiri.
  #
  # @return [Nokogiri] Nokogiri--parsed body.
  def parsed_body
    @parsed_body ||= Nokogiri.parse(@body)
  end

  def original_parsed_body
    @original_parsed_body ||= Nokogiri.parse(@body)
  end

  private
  def extract_body(body, encoding)
    if encoding.nil?
      body
    elsif encoding == "gzip"
      gunzip(body)
    else
      raise Futile::ResistanceIsFutile.new("Unknown encoding '%s'" % [encoding])
    end
  end

  def gunzip(body)
    Zlib::GzipReader.new(StringIO.new(body)).read
  end
end
