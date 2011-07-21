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
  end

  test "concept discovery and redundancy elimination" do
    text = "Der Weltraum (oder das All) ist Schauplatz für den Kampf."

    doc = Document.make!(:content => text)
    labels = doc.labels
    concepts = doc.determine_concepts
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["All"]
    assert labels.include? @labels["Kampf"]
    assert_equal 2, concepts.keys.length
    assert_equal 2.0, concepts[@concepts[0]]
    assert_equal 1.0, concepts[@concepts[2]]
  end

end
