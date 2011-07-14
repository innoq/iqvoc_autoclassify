# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_helper')
require 'document_parser'
require 'german_document_parser'

class ParserGermanTest < Test::Unit::TestCase

  def test_word_normalization
    text = "Nord- und Südgefälle"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal "Nord", doc.sentences[0][0]
    assert_equal "und", doc.sentences[0][1]
    assert_equal "Südgefälle", doc.sentences[0][2]

    text = "solch überflüssige Äußerlichkeiten - Gruß!"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal "solch", doc.sentences[0][0]
    assert_equal "überflüssige", doc.sentences[0][1]
    assert_equal "Äußerlichkeiten", doc.sentences[0][2]
    assert_equal "Gruß", doc.sentences[0][3]
  end

  def test_abbreviation_handling
    text = "lorem ipsum z. B. dolor sit amet"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum z.B. dolor sit amet"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum i. d. R. dolor sit amet"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum i.d.R. dolor sit amet"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length

    text = "lorem d.h. ipsum s.o. dolor Nr. sit etc. amet"
    doc = GermanDocumentParser.new text

    assert_equal 1, doc.sentences.length
  end

end
