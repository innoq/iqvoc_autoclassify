# encoding: UTF-8

require 'test_helper'

class DocumentConceptsTest < ActiveSupport::TestCase

  setup do
    data = Iqvoc::Maker.from_yaml <<-EOF
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
        value: Auseinandersetzung
      -
        value: Messerkampf
      -
        value: foo
      -
        value: Kyoto
      -
        value: Protokoll
      -
        value: Kyoto-Protokoll
        components: [Kyoto, Protokoll]

      concepts:
      -
        pref_labels: [Weltraum]
        alt_labels: [All]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
      -
        pref_labels: [Auseinandersetzung]
      -
        pref_labels: [Messerkampf]
      -
        pref_labels: [Kampf]
        broader: Auseinandersetzung
        narrower: Messerkampf
      -
        pref_labels: [foo]
        published_at:
      -
        pref_labels: [Kyoto]
      -
        pref_labels: [Protokoll]
      -
        pref_labels: [Kyoto-Protokoll]
    EOF
    @labels = data[:labels]
    @concepts = data[:concepts]
  end

  test "gracefully handle lack of matches" do
    text = "..."
    doc = make_document(:content => text)

    assert_equal 0, doc.determine_labels.length
    assert_equal 0, doc.concepts.keys.length
  end

  test "concept discovery and redundancy elimination" do
    text = "Der Weltraum (oder das All) ist Schauplatz für den Kampf."
    doc = make_document(:content => text)

    labels = doc.determine_labels
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["All"]
    assert labels.include? @labels["Kampf"]

    concepts = doc.determine_concepts
    assert_equal 2, concepts.keys.length
    assert concepts.include? @concepts["Weltraum"]
    assert concepts.include? @concepts["Kampf"]
  end

  test "ignore unpublished concepts" do
    text = "lorem foo ipsum"
    doc = make_document(:content => text)

    assert_equal 0, doc.concepts.keys.length
  end

  test "simple concept weighting" do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für den Kampf, sagt der Pilot.
    EOF
    doc = make_document(:content => text)

    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts["Weltraum"]]
    assert_equal 1.0, concepts[@concepts["Kampf"]]
    assert_equal 1.0, concepts[@concepts["Pilot"]]
  end

  test "full concept weighting" do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für die Auseinandersetzung;
      der letzte Kampf.
    EOF
    doc = make_document(:content => text)

    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts["Weltraum"]]
    assert_equal 2.0, concepts[@concepts["Kampf"]]
    assert_equal 1.5, concepts[@concepts["Auseinandersetzung"]]
  end

  test "multiple occurence increases weighting" do
    text = <<-EOF
      Weltraum Weltraum Kampf Weltraum Kampfes
    EOF
    doc = make_document(:content => text)

    concepts = doc.concepts
    assert_equal 2, concepts.keys.length
    assert_equal 3.0, concepts[@concepts["Weltraum"]]
    assert_equal 2.0, concepts[@concepts["Kampf"]]
  end

  test "decompose hyphenated words without adding compound forms" do
    text = "Kyoto-Protokoll"
    doc = make_document(:content => text)

    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 1.0, concepts[@concepts["Kyoto-Protokoll"]]
    assert_equal 1.0, concepts[@concepts["Kyoto"]]
    assert_equal 1.0, concepts[@concepts["Protokoll"]]
  end

end
