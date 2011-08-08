# encoding: UTF-8

require 'open-uri'
require 'nokogiri'
require 'readability'

module Textractor

  def self.extract(html)
    if html =~ /^https?:\/\/[^\s]+$/ # URL
      html = open(html).read # TODO: error handling
      return extract(html)
    end

    doc = Readability::Document.new(html)
    title = doc.html.css("title").first
    title = title ? title.text : nil
    content = Nokogiri::HTML(doc.content).text # invoking Nokogiri seems a bit
                                               # redundant, but is necessary
                                               # because Readability's sanitize
                                               # method converts the DOM tree to
                                               # a string
    return title, content
  end

end
