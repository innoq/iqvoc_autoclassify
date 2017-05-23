# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class ClassificationWeightingTest < ActiveSupport::TestCase

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
        inflectionals: [Piloten]
      -
        value: Weltraumkampfpilot
        components: [Weltraum, Kampf, Pilot]
      -
        value: Weltraumfrachtpilot
        components: [Weltraum, Fracht, Pilot]
      -
        value: Auseinandersetzung
      -
        value: Messerkampf

      concepts:
      -
        pref_labels: [Weltraum]
        alt_labels: [All]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
      -
        pref_labels: [Weltraumkampfpilot]
      -
        pref_labels: [Weltraumfrachtpilot]
      -
        pref_labels: [Auseinandersetzung]
      -
        pref_labels: [Messerkampf]
      -
        pref_labels: [Kampf]
        broader: Auseinandersetzung
        narrower: Messerkampf
    EOF
    @concepts = data[:concepts]
  end

  test 'simple concept weighting' do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für den Kampf, sagt der Pilot.
    EOF
    doc = make_document(content: text)

    concepts = doc.concepts
    assert_equal 2, concepts.keys.length
    assert_equal 1.0, concepts[@concepts['Weltraum']] # via 'All' # FIXME: ?
    assert_nil concepts[@concepts['Kampf']]
    assert_nil concepts[@concepts['Pilot']]
    assert_equal 1.0, concepts[@concepts['Weltraumkampfpilot']]
  end

  test 'full concept weighting' do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für die Auseinandersetzung;
      der letzte Kampf.
    EOF
    doc = make_document(content: text)

    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts['Weltraum']]
    assert_equal 2.0, concepts[@concepts['Kampf']]
    assert_equal 1.5, concepts[@concepts['Auseinandersetzung']]
  end

  test 'occurence in document title increases weighting' do
    title = 'Fracht'
    text = 'Weltraum'
    doc = make_document(title: title, content: text)

    concepts = doc.concepts
    assert_equal 2, concepts.keys.length
    assert_equal 1.0, concepts[@concepts['Weltraum']]
    assert_equal 1.5, concepts[@concepts['Fracht']]

    title = 'der Weltraum, ein Kampf der Pilot'
    text = 'ein Weltraumkampfpilot im All'
    doc = make_document(title: title, content: text)

    concepts = doc.concepts
    assert_equal 2, concepts.keys.length
    assert_equal 1.0, concepts[@concepts['Weltraum']] # via 'All' FIXME: ?
    assert_nil concepts[@concepts['Kampf']]
    assert_nil concepts[@concepts['Pilot']]
    assert_equal 3.0, concepts[@concepts['Weltraumkampfpilot']]
  end

  test 'multiple occurence of the same label increases weighting' do
    text = <<-EOF
      Weltraum Weltraum Kampf Weltraum Kampfes
    EOF
    doc = make_document(content: text)

    concepts = doc.concepts
    assert_equal 2, concepts.keys.length
    assert_equal 3.0, concepts[@concepts['Weltraum']]
    assert_equal 2.0, concepts[@concepts['Kampf']]

    # same concept, different labels - does not increase weighting -- FIXME: desired?
    text = 'Weltraum und All'
    doc = make_document(content: text)

    concepts = doc.concepts
    assert_equal 1, concepts.keys.length
    assert_equal 2.0, concepts[@concepts['Weltraum']]
  end

end
