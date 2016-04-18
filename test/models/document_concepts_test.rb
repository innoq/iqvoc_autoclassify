# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class DocumentConceptsTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: All
      -
        value: Fracht
      -
        value: Kampf
        inflectionals: [Kampfes, Kämpfe]
      -
        value: Pilot
      -
        value: foo
      -
        value: bar
      -
        value: baz
      -
        value: Kyoto
      -
        value: Protokoll
      -
        value: Kyoto-Protokoll
        components: [Kyoto, Protokoll]
      -
        value: Erste
        inflectionals: ['1.']
      -
        value: Sahne
      -
        value: ErsteSahne
        components: [Erste, Sahne]
      -
        value: Zweite
      -
        value: '2.'
      -
        value: ZweiteSahnePref
        components: [Zweite, Sahne]
      -
        value: ZweiteSahneAlt
        components: ['2.', Sahne]

      concepts:
      -
        pref_labels: [Weltraum]
        alt_labels: [All]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
      -
        pref_labels: [Kampf]
      -
        pref_labels: [foo]
        published_at:
      -
        pref_labels: [Kyoto]
      -
        pref_labels: [Protokoll]
      -
        pref_labels: [Kyoto-Protokoll]
      -
        pref_labels: [ErsteSahne]
      -
        pref_labels: [ZweiteSahnePref]
        alt_labels: [ZweiteSahneAlt]
    EOF
    @labels = data[:labels]
    @concepts = data[:concepts]
  end

  test 'gracefully handle lack of matches' do
    text = '...'
    doc = make_document(content: text)

    assert_equal 0, doc.determine_labels.length
    assert_equal 0, doc.concepts.keys.length
  end

  test 'concept discovery and redundancy elimination' do
    text = 'Der Weltraum (oder das All) ist Schauplatz für den Kampf.'
    doc = make_document(content: text)

    labels = doc.determine_labels
    assert_equal 3, labels.length
    assert labels.include? @labels['Weltraum']
    assert labels.include? @labels['All']
    assert labels.include? @labels['Kampf']

    concepts = doc.determine_concepts
    assert_equal 2, concepts.keys.length
    assert concepts.include? @concepts['Weltraum']
    assert concepts.include? @concepts['Kampf']
  end

  test 'ignore unpublished concepts' do
    text = 'lorem foo ipsum'
    doc = make_document(content: text)

    assert_equal 0, doc.concepts.keys.length
  end

  test 'ignore labels without matching concepts' do
    title = 'bar'
    text = 'baz'
    doc = make_document(title: title, content: text)

    concepts = doc.concepts
    assert_equal 0, concepts.keys.length
  end

  test 'decompose hyphenated words without adding compound forms' do
    text = 'Kyoto-Protokoll'
    doc = make_document(content: text)

    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 1.0, concepts[@concepts['Kyoto-Protokoll']]
    assert_equal 1.0, concepts[@concepts['Kyoto']]
    assert_equal 1.0, concepts[@concepts['Protokoll']]
  end

  test 'compounded ordinals as Inflectional for concept' do
    text = 'Erste Sahne! 1. Sahne.'
    doc = make_document(content: text)
    concepts = doc.concepts

    assert_equal 1, concepts.keys.length
    assert_equal 2.0, concepts[@concepts['ErsteSahne']]
  end

  test 'compounded ordinals as AltLabel for concept' do
    text = 'Zweite Sahne! 2. Sahne.'
    doc = make_document(content: text)
    concepts = doc.concepts

    assert_equal 1, concepts.keys.length
    assert_equal 2.0, concepts[@concepts['ZweiteSahnePref']]
  end
end
