# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class CompoundLabelIdentificationTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
        inflectionals: [Kämpfe, Kampfes]
      -
        value: Fracht
      -
        value: Pilot
        inflectionals: [Piloten, Pilotin]
      -
        value: Weltraumkampfpilot
        components: [Weltraum, Kampf, Pilot]
      -
        value: Weltraumfrachtpilot
        components: [Weltraum, Fracht, Pilot]
      -
        value: Euro
      -
        value: "5"
      -
        value: Euro 5
        components: [Euro, "5"]
      -
        value: Verkehr
      -
        value: Polizist
      -
        value: Verkehrspolizist
        components: [Verkehr, Polizist]
      -
        value: Weltraumfrachtverkehrspolizistenpilot
        components: [Verkehrspolizist, Weltraumfrachtpilot]
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
  end

  test 'compound discovery' do
    sentence = %w(der Weltraum der Kampf und der Pilot)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 1, labels.length
    assert labels.include? @label_ids['Weltraumkampfpilot']
    assert labels.exclude? @label_ids['Weltraumfrachtpilot']

    sentence = %w(Weltraum des Kampfes und der Piloten)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 1, labels.length
    assert labels.include? @label_ids['Weltraumkampfpilot']
    assert labels.exclude? @label_ids['Weltraumfrachtpilot']
  end

  test 'order of occurrence is NOT significant anymore' do
    sentence = %w(der Kampf der Weltraum und der Pilot)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 1, labels.length
    assert labels.include? @label_ids['Weltraumkampfpilot']
    assert labels.exclude? @label_ids['Weltraumfrachtpilot']

    sentence = %w(Foo Weltraum Kampf Pilot Fracht)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 2, labels.length
    assert labels.include? @label_ids['Weltraumkampfpilot']
    assert labels.exclude? @label_ids['Fracht']
    assert labels.include? @label_ids['Weltraumfrachtpilot']
  end

  test 'compound parts are retained' do
    sentence = %w(Weltraum Euro Pilot Kampf Pilot)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 2, labels.length
    assert labels.include? @label_ids['Euro']
    assert labels.include? @label_ids['Weltraumkampfpilot']
    assert labels.exclude? @label_ids['Weltraumfrachtpilot']
    assert labels.exclude? @label_ids['Weltraum']

    sentence = %w(foo Fracht foo Euro foo Kampf Weltraum foo Pilot foo Pilot)
    labels = WordMatcher.new([sentence]).labels
    #pp labels, @label_ids.invert.slice(*labels)

    assert_equal 3, labels.length
    assert labels.include? @label_ids['Euro']
    assert labels.include? @label_ids['Weltraumfrachtpilot']
    assert labels.include? @label_ids['Weltraumkampfpilot']
  end

  test 'special cases' do
    sentence = %w(die Euro 5 Norm)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 1, labels.length
    assert_equal [@label_ids['Euro 5']], labels

    sentence = %w(Hier sind 5 Euro für Dich!)
    labels = WordMatcher.new([sentence]).labels
    #pp @label_ids.invert.slice(*labels)

    assert_equal 1, labels.length
    assert_equal [@label_ids['Euro 5']], labels

    # sentence = 'zum Euro gibt es 5 Alternativen'.split(' ')
    # labels = WordMatcher.new([sentence]).labels

    # # XXX: the following is not actually desirable, but inevitable due to the way
    # #      compound forms are handled (allowing arbitrary tokens between components)
    # assert_equal 3, labels.length
    # assert_equal [@label_ids['Euro'], @label_ids['5'], @label_ids['Euro 5']], labels
  end

  # --Example--
  # Sentence: [Die verkehrsbedingte Verunreinigung der Luft]
  # Labels:   [Verkehrsbedingte Luftverunreinigung] -> [Verkehr, Luftverunreinigung -> [Luft, Verunreinigung]]
  test 'cascading compound forms' do
    sentence = %w(Polizist Euro Weltraum Verkehr Fracht Pilot)
    labels = WordMatcher.new([sentence]).labels

    assert_equal 2, labels.length
    assert_equal [@label_ids['Euro'], @label_ids['Weltraumfrachtverkehrspolizistenpilot']], labels
  end

  # Should find only exact matches without components and other concept/label matches
  test 'exact labels matches' do
    sentence = %w(Weltraumfrachtverkehrspolizistenpilot)
    labels = WordMatcher.new([sentence]).labels
    assert_equal 1, labels.length
    assert_equal [@label_ids['Weltraumfrachtverkehrspolizistenpilot']], labels
  end
end
