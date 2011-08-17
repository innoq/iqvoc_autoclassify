# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class LabelIdentificationTest < ActiveSupport::TestCase

  setup do
    Iqvoc::Maker.from_yaml <<-EOF
      labels:
      -
        value: Baum
        inflectionals: [Bäume, Baumes]
      -
        value: Kind
        inflectionals: [Kinder, Kinde, Kindes]
      -
        value: Fenster
      -
        value: foo
        published_at:
      -
        value: bar
        published_at:
    EOF
  end

  test "identifying matching inflectionals" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    sentence = ["Kinder", "Fenster", "Bäume", "Kinder", "Baum"]
    assert_equal 5, WordMatcher.new(sentence).inflectionals.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length
  end

  test "case-insensitive identification of inflectionals" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    sentence = ["kinder", "fenster", "bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    sentence = ["kinder", "fenSter", "bÄume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length
  end

  test "identifying matching labels" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).labels.length

    sentence = ["Kinder", "Fenster", "Bäume", "Kinder", "Baum"]
    assert_equal 3, WordMatcher.new(sentence).labels.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new(sentence).labels.length
  end

  test "ignore unpublished labels" do
    sentence = ["lorem", "foo", "ipsum", "bar", "dolor", "sit", "amet"]
    assert_equal 0, WordMatcher.new(sentence).labels.length
  end

end
