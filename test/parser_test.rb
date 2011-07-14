# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_helper')
require 'document_parser'


class ParserTest < Test::Unit::TestCase

  def test_simple_sentence_identification
    text = "lorem ipsum dolor sit amet"
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = "lorem ipsum. dolor sit amet"
    doc = DocumentParser.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length

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
  end

end
