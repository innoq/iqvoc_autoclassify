# encoding: UTF-8

require 'open-uri'
require 'tempfile'
require 'nokogiri'
require 'readability'
require 'pdf-reader'

module Textractor

  def self.extract(url)
    raise(ArgumentError, "HTTP URL expected") unless url =~ /^https?:\/\/[^\s]+$/
    title = nil
    content = nil

    # NB: Content-Length headers are not necessarily reliable
    validate_size = lambda { |content_length|
      raise ExcessiveSize if (content_length && content_length > 512000) # TODO: configurable
    }

    open(url, :content_length_proc => validate_size) { |data|
      case data.content_type
        when "application/pdf"
          file = Tempfile.new "textractor"
          file.binmode
          file.write data.read
          file.close
          title, content = from_pdf(file.path)
          file.delete
        when "text/plain"
          content = data.read
        else # assume HTML
          title, content = from_html(data.read)
      end
    }

    if RUBY_VERSION >= "1.9"
      title = title.encode("UTF-8") unless title.nil?
    end

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
    pdf = PDF::Reader.file(filepath, rcv)
    return rcv.meta[:Title], rcv.content.join("\n\n")
  end

  class ExcessiveSize < StandardError; end

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
