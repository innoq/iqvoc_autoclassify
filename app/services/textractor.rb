# encoding: UTF-8

require 'tempfile'
require 'readability'
require 'pdf-reader'
require 'net/http'

class Textractor

  def self.from_uri(uri, timeout = 1.0)
    raise InvalidUri, 'HTTP URL expected' unless uri =~ /^https?:\/\/[^\s]+$/
    title = nil
    content = nil

    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = timeout
    http.use_ssl = true if uri.scheme == 'https'
    req = Net::HTTP::Get.new(uri)
    begin
      http.request(req) do |response|
        return from_uri(response['location'], timeout) if response['location'] && response.kind_of?(Net::HTTPRedirection)
        raise HTTPError.new(502, response.message) unless response.code == '200'

        case response.content_type
          when 'text/plain'
            content = response.body
          when 'text/html'
            title, content = from_html(response.body)
          when 'application/pdf'
            file = Tempfile.new 'textractor'
            file.binmode
            response.read_body { |chunk| file.write chunk }
            file.close
            begin
              title, content = from_pdf(file.path)
            rescue ArgumentError
              raise UnprocessablePDF, 'PDF encoding error'
            rescue PDF::Reader::MalformedPDFError
              raise UnprocessablePDF, 'malformed PDF document'
            rescue PDF::Reader::UnsupportedFeatureError
              raise UnprocessablePDF, 'encrypted PDF not supported'
            end
            file.delete
          else
            raise UnsupportedContentType.new(response.content_type)
        end
      end
    rescue Timeout::Error
      raise ResponseLimitExceeded
    rescue SocketError, Errno::ECONNREFUSED
      raise ConnectionError, 'could not retrieve document'
    end

    # TODO: do we still need this?
    title = title.try(:encode, 'UTF-8')

    return title, content
  end

  def self.from_html(html)
    doc = Readability::Document.new(html)
    title = doc.html.at_css('title').try(:text)
    content = Nokogiri::HTML(doc.content).text # invoking Nokogiri seems a bit
                                               # redundant, but is necessary
                                               # because Readability's sanitize
                                               # method converts the DOM tree to
                                               # a string
    return title, content
  end

  def self.from_pdf(filepath)
    reader = PDF::Reader.new(filepath)

    title = reader.info.values_at(:Title, :Author).join(' / ')
    content = reader.pages.map(&:text).join("\nn") # should this be marked somewhat?

    # Regardless of the internal encoding used in the PDF all text will be converted to UTF-8 before it is passed back
    # from PDF::Reader. https://github.com/yob/pdf-reader#text-encoding
    title.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '_')
    content.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '_')

    return title, content
  end

  class InvalidUri < ArgumentError; end
  class ConnectionError < StandardError; end
  class ResponseLimitExceeded < StandardError; end
  class UnprocessablePDF < StandardError; end
  class UnsupportedContentType < StandardError
    attr_accessor :message
    def initialize(content_type)
      @message = "Unsupported content type: #{content_type}"
    end
  end
  class HTTPError < StandardError
    attr_accessor :code, :message
    def initialize(code, message)
      @code, @message = code, "#{code} #{message}"
    end
  end
end
