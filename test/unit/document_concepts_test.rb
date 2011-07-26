# encoding: UTF-8

require 'test_helper'

class DocumentConceptsTest < ActiveSupport::TestCase

  setup do
    data = make_from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: All
      -
        value: Fracht
      -
        value: Kampf
      -
        value: Pilot
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
        pref_labels: [Auseinandersetzung]
      -
        pref_labels: [Messerkampf]
      -
        pref_labels: [Kampf]
        broader: Auseinandersetzung
        narrower: Messerkampf
    EOF
    @labels = data[:labels]
    @concepts = data[:concepts]
  end

  test "gracefully handle lack of matches" do
    text = "..."

    doc = Document.create!(:content => text)
    assert_equal 0, doc.labels.length
    assert_equal 0, doc.concepts.keys.length
  end

  test "concept discovery and redundancy elimination" do
    text = "Der Weltraum (oder das All) ist Schauplatz für den Kampf."
    doc = Document.create!(:content => text)

    labels = doc.labels
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["All"]
    assert labels.include? @labels["Kampf"]

    concepts = doc.determine_concepts
    assert_equal 2, concepts.keys.length
    assert concepts.include? @concepts["Weltraum"]
    assert concepts.include? @concepts["Kampf"]
  end

  test "simple concept weighting" do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für den Kampf, sagt der Pilot.
    EOF
    doc = Document.create!(:content => text)

    # simple analysis
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
    doc = Document.create!(:content => text)

    # full analysis
    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts["Weltraum"]]
    assert_equal 2.0, concepts[@concepts["Kampf"]]
    assert_equal 1.5, concepts[@concepts["Auseinandersetzung"]]
  end

end
