# encoding: UTF-8

require 'test_helper'
require 'document_parser/base'

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

  def test_quotations_and_apostrophes
    text = %Q(Gretchen fragt "Nun sag, wie hast du's mit der Religion?" und blickt)
    doc = DocumentParser.new text

    assert_equal 1, doc.sentences.length # we're currently not parsing quotes as separate sentences
    assert_equal 12, doc.sentences[0].length
    assert_equal "du", doc.sentences[0][6]
    assert_equal "mit", doc.sentences[0][7]

    # NB: special chars being used for quotes and apostrophe
    text = %Q(„Nun sag, wie hast du’s mit der Religion? Du bist ein herzlich guter Mann, allein ich glaub, du hältst nicht viel davon.“)
    doc = DocumentParser.new text

    assert_equal 2, doc.sentences.length
    assert_equal 8, doc.sentences[0].length
    assert_equal 14, doc.sentences[1].length

    text = "Was gibt's denn? Äußerlich sieht's gut aus."
    doc = DocumentParser.new text

    assert_equal 2, doc.sentences.length
    assert_equal 3, doc.sentences[0].length
    assert_equal "Was", doc.sentences[0][0]
    assert_equal "gibt", doc.sentences[0][1]
    assert_equal "denn", doc.sentences[0][2]
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
