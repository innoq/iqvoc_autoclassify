# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'word_matcher'

class LabelIdentificationTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
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
        value: Planet
        language: de
      -
        value: planet
        language: en
     -
        value: Kuchen
        auto_classify: false

    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
  end

  test 'case-insensitive matching' do
    sentence = %w(Kinder Fenster Bäume)
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = %w(kinder fenster bäume)
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = %w(kinder fenSter bÄume)
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end

  test 'identifying matching labels' do
    sentence = %w(Kinder Fenster Bäume)
    assert_equal 3, WordMatcher.new([sentence]).labels.length

    sentence = %w(Kinder Fenster Bäume Kinder Baum)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 5, labels.length
    assert_equal 2, labels.find_all { |id| id == @label_ids['Baum'] }.length

    sentence = %w(Das Kind am Fenster sieht Bäume und Gras)
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end

  test 'equally written labels' do
    sentence = %w(PLANET)
    assert_equal 2, WordMatcher.new([sentence]).labels.length
  end

  test 'unwanted labels' do
    sentence = %w(Kinder Fenster Bäume Kuchen)
    assert_equal 3, WordMatcher.new([sentence]).labels.length
  end
end
