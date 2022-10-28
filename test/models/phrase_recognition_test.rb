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
        value: monetär
      -
        value: Bewertung
      -
        value: Monetäre Bewertung von Umweltschäden
        components: [Bewertung, monetär]
      -
        value: Abbau von natürlichen Ressourcen
      -
        value: natürlichen Ressourcen
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
  end

  test 'exact labels matches' do
    # respects hyphens and keep stopword "und"
    sentence = %w(Da ist der Fuß- und Radverkehr von heute)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Fuß- und Radverkehr']
  end

  test 'reject components on exact label matches' do
    sentence = %w(Hier ist die Monetäre Bewertung von Umweltschäden)
    labels = WordMatcher.new([sentence]).labels

    # should find only exact matches and reject components ("Bewetung" and "monetär")
    assert labels.include? @label_ids['Monetäre Bewertung von Umweltschäden']
    assert labels.exclude? @label_ids['Bewertung']
    assert labels.exclude? @label_ids['monetär']

  end

  test 'prefer longer exact labels matches' do
    sentence = %w(Die Monetäre Bewertung der Umweltschäden ist mein Hobby.)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Monetäre Bewertung']

    # should only find "Monetäre Bewertung von Umweltschäden" and not shorter "Monetäre Bewertung"
    sentence = %w(In diesem Satz geht es um Monetäre Bewertung von Umweltschäden und nicht anderem.)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Monetäre Bewertung von Umweltschäden']
    assert labels.exclude? @label_ids['Monetäre Bewertung']

    sentence = %w(Der Abbau von natürlichen Ressourcen ist nicht gut)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Abbau von natürlichen Ressourcen']
    assert labels.exclude? @label_ids['natürlichen Ressourcen']
  end

  test 'phrase recognition size parameter' do
    # should only find "Monetäre Bewertung von Umweltschäden" and not shorter "Monetäre Bewertung"
    sentence = %w(In diesem Satz geht es um Monetäre Bewertung von Umweltschäden und nicht anderem.)

    # phrase_recognition_size: 0, disabled
    # only finds "Bewetung"
    labels = WordMatcher.new([sentence], phrase_recognition_size: 0).labels
    assert_equal 1, labels.length
    assert labels.include? @label_ids['Bewertung']
    assert labels.exclude? @label_ids['Monetäre Bewertung']
    assert labels.exclude? @label_ids['Monetäre Bewertung von Umweltschäden']

    # phrase_recognition_size: 2
    # Finds "Bewertung" and "Monetäre Bewertung" and prefer longer "Monetäre Bewertung"
    labels = WordMatcher.new([sentence], phrase_recognition_size: 2).labels
    assert_equal 1, labels.length
    assert labels.exclude? @label_ids['Bewertung']
    assert labels.include? @label_ids['Monetäre Bewertung']
    assert labels.exclude? @label_ids['Monetäre Bewertung von Umweltschäden']

    # phrase_recognition_size: 4
    # Finds "Bewertung", "Monetäre Bewertung", "Monetäre Bewertung von Umweltschäden" and prefer longest
    labels = WordMatcher.new([sentence], phrase_recognition_size: 4).labels
    assert_equal 1, labels.length
    assert labels.exclude? @label_ids['Bewertung']
    assert labels.exclude? @label_ids['Monetäre Bewertung']
    assert labels.include? @label_ids['Monetäre Bewertung von Umweltschäden']
  end

end
