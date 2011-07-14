# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_helper')
require 'document_parser'


class ParserTest < Test::Unit::TestCase

  def test_simple_sentence_identification
    text = "Lorem ipsum dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum. dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length

    text = "lorem ipsum.dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 4, doc.sentences[0].length
    assert_equal "ipsum.dolor", doc.sentences[0][1]

    text = "lörem ipsüm dolor ßit ämet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum, dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum - dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum-37-dolor sit amet."
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 4, doc.sentences[0].length
    assert_equal "ipsum-37-dolor", doc.sentences[0][1]
  end

  def test_implicit_sentence_termination
    text = "lorem ipsum dolor sit amet"
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum. dolor sit amet"
    doc = DocumentParser.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length
  end

end
