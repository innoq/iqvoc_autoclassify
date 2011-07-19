# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class LabelIdentificationTest < ActionController::TestCase

  setup do
    {
      "Baum" => ["Bäume", "Baumes"],
      "Kind" => ["Kinder", "Kinde", "Kindes"],
      "Fenster" => []
    }.each { |term, inflectionals|
      label = Iqvoc::XLLabel.base_class.create :value => term,
          :origin => OriginMapping.merge(term)
      inflectionals.unshift term # the label itself is also an inflectional
      inflectionals.each { |inf|
        Inflectional::Base.create :value => inf, :label => label
      }
    }
  end

  test "identifying matching inflectionals" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    sentence = ["Kinder", "Fenster", "Bäume", "Kinder", "Baum"]
    assert_equal 4, WordMatcher.new(sentence).inflectionals.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length
  end

  test "case-insensitive identification of inflectionals" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    sentence = ["kinder", "fenster", "bäume"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length

    # FIXME: this currently fails for umlauts
    #sentence = ["kinder", "fenSter", "bÄume"]
    #assert_equal 3, WordMatcher.new(sentence).inflectionals.length
  end

  test "identifying matching labels" do
    sentence = ["Kinder", "Fenster", "Bäume"]
    assert_equal 3, WordMatcher.new(sentence).labels.length

    sentence = ["Kinder", "Fenster", "Bäume", "Kinder", "Baum"]
    assert_equal 3, WordMatcher.new(sentence).labels.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new(sentence).inflectionals.length
  end

end
