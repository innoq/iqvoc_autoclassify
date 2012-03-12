# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'document_parser/german_document_parser'

class ParserGermanTest < ActiveSupport::TestCase

  test "implicit sentence termination" do
    text = "lorem ipsum dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum. dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length

    [
      "lorem ipsum\ndolor sit amet.",
      "lorem ipsum\r\ndolor sit amet."
    ].each { |text|
      doc = DocumentParser::German.new text

      assert_equal 1, doc.sentences.length
      assert_equal 5, doc.sentences[0].length
    }

    [
      "lorem ipsum\n\ndolor sit amet.",
      "lorem ipsum\r\n\r\ndolor sit amet."
    ].each { |text|
      doc = DocumentParser::German.new text

      assert_equal 2, doc.sentences.length
      assert_equal 2, doc.sentences[0].length
      assert_equal 3, doc.sentences[1].length
    }
  end

  test "word normalization" do
    text = "Nord- und Südgefälle"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal "Nord", doc.sentences[0][0]
    assert_equal "Südgefälle", doc.sentences[0][1]

    text = "solch überflüssige Äußerlichkeiten - Gruß!"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal "solch", doc.sentences[0][0]
    assert_equal "überflüssige", doc.sentences[0][1]
    assert_equal "Äußerlichkeiten", doc.sentences[0][2]
    assert_equal "Gruß", doc.sentences[0][3]
  end

  test "decompose hyphenated words" do
    text = "deutsch-französisch"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal ["deutsch-französisch", "französisch", "deutsch"], doc.sentences[0]

    text = "saar-lor-lux"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal ["saar-lor-lux", "lux", "lor", "saar"], doc.sentences[0]
  end

  test "abbreviation handling" do
    text = "lorem ipsum z. B. dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum z.B. dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum i. d. R. dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length

    text = "lorem ipsum i.d.R. dolor sit amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length

    text = "lorem d.h. ipsum s.o. dolor Nr. sit etc. amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length

    text = "lorem 1. ipsum 10. dolor 99. sit 13.07.2011 amet"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
  end

  test "stop-word handling" do
    text = "er oder sie"
    doc = DocumentParser::German.new text

    assert_equal ["er", "sie"], doc.sentences[0]

    text = "auf der Oder"
    doc = DocumentParser::German.new text

    assert_equal ["auf", "der", "Oder"], doc.sentences[0]

    text = "moderat Moder oderfoo" # "oderfoo" since there's no actual word starting with lowercase "oder"
    doc = DocumentParser::German.new text

    assert_equal ["moderat", "Moder", "oderfoo"], doc.sentences[0]
  end

  test "do not discard potentially meaningful single-character tokens" do
    text = "lorem Euro 5 ipsum"
    doc = DocumentParser::German.new text

    assert_equal 1, doc.sentences.length
    assert_equal ["lorem", "Euro", "5", "ipsum"], doc.sentences[0]
  end

end
