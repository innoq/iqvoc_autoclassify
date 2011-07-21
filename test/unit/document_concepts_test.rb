# encoding: UTF-8

require 'test_helper'

class DocumentConceptsTest < ActionController::TestCase

  setup do
    @concepts = []
    @labels = {}
    [
      ["Weltraum", "All"],
      ["Fracht"],
      ["Kampf"],
      ["Pilot"]
    ].each { |terms|
      labels = terms.map { |term|
        @labels[term] = make_label(term)
      }
      pref_labels = [labels.shift]
      alt_labels = labels
      @concepts.push make_concept(:pref_labels => pref_labels, :alt_labels => alt_labels)
    }
    # add some relations
    broader_concept = make_concept(:pref_labels => ["Auseinandersetzung"])
    @concepts[2].send(Iqvoc::Concept.broader_relation_class.name.to_relation_name).
        create_with_reverse_relation(broader_concept)
    narrower_concept = make_concept(:pref_labels => ["Messerkampf"])
    @concepts[2].send(Iqvoc::Concept.broader_relation_class.narrower_class.name.to_relation_name).
        create_with_reverse_relation(narrower_concept)
  end

  test "concept discovery and redundancy elimination" do
    text = "Der Weltraum (oder das All) ist Schauplatz für den Kampf."
    doc = Document.make!(:content => text)

    labels = doc.labels
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["All"]
    assert labels.include? @labels["Kampf"]

    concepts = doc.determine_concepts
    assert_equal 2, concepts.keys.length
  end

  test "simple concept weighting" do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für den Kampf, sagt der Pilot.
    EOF
    doc = Document.make!(:content => text)

    # simple analysis
    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts[0]]
    assert_equal 1.0, concepts[@concepts[2]]
  end

  test "full concept weighting" do
    text = <<-EOF
      Der Weltraum (oder das All) ist Schauplatz für die Auseinandersetzung;
      der letzte Kampf.
    EOF
    doc = Document.make!(:content => text)

    # full analysis
    concepts = doc.concepts
    assert_equal 3, concepts.keys.length
    assert_equal 2.0, concepts[@concepts[0]]
    assert_equal 2.0, concepts[@concepts[2]]
    assert_equal 1.5, concepts[@concepts[4]]
  end

end
