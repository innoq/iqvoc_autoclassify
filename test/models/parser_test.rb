# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ParserTest < ActiveSupport::TestCase

  test 'simple sentence identification' do
    text = 'Lorem ipsum dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = 'lorem ipsum. dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length

    text = 'lorem ipsum.dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 4, doc.sentences[0].length
    assert_equal 'ipsum.dolor', doc.sentences[0][1]

    text = 'lörem ipsüm dolor ßit ämet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = 'lorem ipsum, dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = 'lorem ipsum - dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 6, doc.sentences[0].length

    text = 'lorem ipsum-37-dolor sit amet.'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 4, doc.sentences[0].length
    assert_equal 'ipsum-37-dolor', doc.sentences[0][1]
  end

  test 'quotations and apostrophes' do
    text = %Q(Gretchen fragt "Nun sag, wie hast du's mit der Religion?" und blickt)
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length # we're currently not parsing quotes as separate sentences
    assert_equal 13, doc.sentences[0].length
    assert_equal 'du', doc.sentences[0][6]
    assert_equal 'mit', doc.sentences[0][8]

    # NB: special chars being used for quotes and apostrophe
    text = %Q(„Nun sag, wie hast du’s mit der Religion? Du bist ein herzlich guter Mann, allein ich glaub, du hältst nicht viel davon.“)
    doc = DocumentParser::Base.new text

    assert_equal 2, doc.sentences.length
    assert_equal 8, doc.sentences[0].length
    assert_equal 14, doc.sentences[1].length

    text = "Was gibt's denn? Äußerlich sieht's gut aus."
    doc = DocumentParser::Base.new text

    assert_equal 2, doc.sentences.length
    assert_equal 4, doc.sentences[0].length
    assert_equal 'Was', doc.sentences[0][0]
    assert_equal 'gibt', doc.sentences[0][1]
    assert_equal 's', doc.sentences[0][2]
    assert_equal 'denn', doc.sentences[0][3]
  end

  test 'implicit sentence termination' do
    text = 'lorem ipsum dolor sit amet'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal 5, doc.sentences[0].length

    text = 'lorem ipsum. dolor sit amet'
    doc = DocumentParser::Base.new text

    assert_equal 2, doc.sentences.length
    assert_equal 2, doc.sentences[0].length
    assert_equal 3, doc.sentences[1].length

    [
      "lorem ipsum\ndolor sit amet.",
      "lorem ipsum\r\ndolor sit amet."
    ].each { |text|
      doc = DocumentParser::Base.new text

      assert_equal 1, doc.sentences.length
      assert_equal 5, doc.sentences[0].length
    }

    [
      "lorem ipsum\n\ndolor sit amet.",
      "lorem ipsum\r\n\r\ndolor sit amet."
    ].each { |text|
      doc = DocumentParser::Base.new text

      assert_equal 2, doc.sentences.length
      assert_equal 2, doc.sentences[0].length
      assert_equal 3, doc.sentences[1].length
    }
  end

  test 'do not discard potentially meaningful single-character tokens' do
    text = 'lorem Euro 5 ipsum'
    doc = DocumentParser::Base.new text

    assert_equal 1, doc.sentences.length
    assert_equal ['lorem', 'Euro', '5', 'ipsum'], doc.sentences[0]
  end

end
