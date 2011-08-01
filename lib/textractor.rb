# encoding: UTF-8

require 'open-uri'
require 'nokogiri'
require 'readability'

module Textractor

  def self.extract(html)
    puts "DEBUG #{html}"
    if html =~ /^https?:\/\/[^\s]+$/ # URL
      html = open(html).read # TODO: error handling
      return extract(html)
    end

    content = Readability::Document.new(html).content
    return Nokogiri::HTML(content).text # this seems a bit redundant, but is
                                        # necessary because Readability's
                                        # sanitize method converts the DOM tree
                                        # to a string
  end

end
