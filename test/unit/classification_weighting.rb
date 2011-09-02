# encoding: UTF-8

require 'test_helper'

class ClassificationWeightingTest < ActiveSupport::TestCase

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
    @concepts = data[:concepts]
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

end
