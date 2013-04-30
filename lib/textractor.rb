# encoding: UTF-8

require 'net/http'
require 'tempfile'
require 'nokogiri'
require 'readability'
require 'pdf-reader'

module Textractor

  def self.from_uri(uri, timeout = 0.5)
    raise InvalidUri, "HTTP URL expected" unless uri =~ /^https?:\/\/[^\s]+$/
    title = nil
    content = nil

    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = timeout if timeout
    req = Net::HTTP::Get.new(uri)
    begin
      http.request(req) do |response|
        raise HTTPError.new(502, response.message) unless response.code == "200"

        case response.content_type
          when "text/plain"
            content = response.body
          when "text/html"
            title, content = from_html(response.body)
          when "application/pdf"
            file = Tempfile.new "textractor"
            file.binmode
            response.read_body { |chunk| file.write chunk }
            file.close
            begin
              title, content = from_pdf(file.path)
            rescue ArgumentError
              raise UnsupportedContentType, "PDF encoding error" # XXX: hacky; inappropriate
            end
            file.delete
          else
            raise UnsupportedContentType.new(response.content_type)
        end
      end
    rescue Net::ReadTimeout
      raise ResponseLimitExceeded
    rescue PDF::Reader::UnsupportedFeatureError
      raise UnsupportedContentType, "encrypted PDF" # XXX: hacky; inappropriate
    rescue SocketError, Errno::ECONNREFUSED
      raise ConnectionError, "could not retrieve document"
    end

    title = title.encode("UTF-8") unless title.nil?

    return title, content
  end

  def self.from_html(html)
    doc = Readability::Document.new(html, :encoding => "UTF-8")
    title = doc.html.css("title").first
    title = title ? title.text : nil
    content = Nokogiri::HTML(doc.content).text # invoking Nokogiri seems a bit
                                               # redundant, but is necessary
                                               # because Readability's sanitize
                                               # method converts the DOM tree to
                                               # a string
    return title, content
  end

  def self.from_pdf(filepath)
    rcv = PDFReceiver.new
    PDF::Reader.file(filepath, rcv)
    return rcv.meta[:Title], rcv.content.join("\n\n")
  end

  class InvalidUri < ArgumentError; end
  class ConnectionError < StandardError; end
  class ResponseLimitExceeded < StandardError; end
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

  # required due to pdf-reader v0.10's awkward API
  # largely cargo-culted from pdf-reader examples
  class PDFReceiver
    attr_reader :meta, :content

    def initialize
      @content = []
    end

    def metadata(data)
      @meta = data
    end

    def begin_page(arg = nil)
      @content << ""
    end

    def show_text(string, *params)
      @content.last << string.strip
    end

    alias :super_show_text :show_text
    alias :move_to_next_line_and_show_text :show_text
    alias :set_spacing_next_line_show_text :show_text

    def show_text_with_positioning(*params)
      params = params.first
      params.each { |str| show_text(str) if str.is_a?(String) }
    end
  end

end
