# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'word_matcher'

class PhraseRecognitionTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Fuß- und Radverkehr
      -
        value: Monetäre Bewertung
      -
        value: Bewertung
      -
        value: Monetäre Bewertung von Umweltschäden
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
  end

  test 'exact labels matches' do
    # respects hyphens and keep stopword "und"
    sentence = %w(Fuß- und Radverkehr)
    labels = WordMatcher.new([sentence]).labels
    assert labels.include? @label_ids['Fuß- und Radverkehr']
  end

 test 'prefer longer labels matches' do
    sentence = %w(Die Monetäre Bewertung der Umweltschäden ist mein Hobby.)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Monetäre Bewertung']

     # should only find "Monetäre Bewertung von Umweltschäden" and not shorter "Monetäre Bewertung"
    sentence = %w(In diesem Satz geht es um Monetäre Bewertung von Umweltschäden und nicht anderem.)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Monetäre Bewertung von Umweltschäden']
  end
end
