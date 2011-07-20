# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class LabelIdentificationTest < ActionController::TestCase

  setup do
    # published
    {
      "Baum" => ["Bäume", "Baumes"],
      "Kind" => ["Kinder", "Kinde", "Kindes"],
      "Fenster" => []
    }.each { |term, inflectionals|
      label = Iqvoc::XLLabel.base_class.make! :value => term
      inflectionals.unshift term # the label itself is also an inflectional
      inflectionals.each { |inf|
        Inflectional::Base.create :value => inf, :label => label
      }
    }
    # unpublished
    {
      "foo" => [],
      "bar" => []
    }.each { |term, inflectionals|
      label = Iqvoc::XLLabel.base_class.make! :value => term,
          :published_at => nil
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
    assert_equal 3, WordMatcher.new(sentence).labels.length
  end

  test "ignore unpublished labels" do
    sentence = ["lorem", "foo", "ipsum", "bar", "dolor", "sit", "amet"]
    assert_equal 0, WordMatcher.new(sentence).labels.length
  end

end
