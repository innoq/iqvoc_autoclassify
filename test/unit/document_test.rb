require 'test_helper'
require 'document_parser/german_document_parser'

class DocumentTest < ActiveSupport::TestCase

  setup do
    @concept = make_concept(:pref_labels => ["Weltraumkampfpilot"],
        :alt_labels => ["Weltraumkampfflieger"])
    broader_concept = make_concept(:pref_labels => ["Weltraumkampf"])
    narrower_concept = make_concept(:pref_labels => ["Weltraumkampfspezialpilot"])
    @concept.send(Iqvoc::Concept.broader_relation_class.name.to_relation_name).
        create_with_reverse_relation(broader_concept)
    @concept.send(Iqvoc::Concept.broader_relation_class.narrower_class.name.to_relation_name).
        create_with_reverse_relation(narrower_concept)
  end

  test "should gracefully handle lack of matches" do
    text = ""

    doc = Document.make!(:content => text)
    assert_equal 0, doc.labels.length
    assert_equal 0, doc.concepts.length
  end

  test "should determine matching concepts" do
    text = "Der Weltraumkampfpilot"

    doc = Document.make!(:content => text)
    assert_equal 1, doc.labels.length
    assert_equal 1, doc.concepts.length
  end

end
