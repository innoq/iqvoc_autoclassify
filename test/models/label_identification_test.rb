# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'word_matcher'

class LabelIdentificationTest < ActiveSupport::TestCase

  setup do
    data = Iqvoc::Maker.from_yaml <<-EOF
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
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
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
    labels = WordMatcher.new([sentence]).labels
    assert_equal 5, labels.length
    assert_equal 2, labels.find_all { |id| id == @label_ids["Baum"] }.length

    sentence = ["Das", "Kind", "am", "Fenster", "sieht", "Bäume", "und", "Gras"]
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end

end
