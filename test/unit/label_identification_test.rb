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
    EOF
  end

  test "case-insensitive matching" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = ["kinder", "fenster", "bäume"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = ["kinder", "fenSter", "bÄume"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end

  test "identifying matching labels" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = ["Kinder", "Fenster", "Bäume", "Kinder", "Baum"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end

end
