require 'test_helper'
require 'document_parser/german_document_parser'

class DocumentTest < ActiveSupport::TestCase
  
  setup do
    @concept = Iqvoc::Concept.base_class.make!(:weltraumkampfpilot)
    broader_concept = Iqvoc::Concept.base_class.make(
      :pref_labelings => [Labeling::SKOSXL::PrefLabel.make(:target => Iqvoc::XLLabel.base_class.make(:value => "Weltraumkampf"))]
    )
    narrower_concept = Iqvoc::Concept.base_class.make(
      :pref_labelings => [Labeling::SKOSXL::PrefLabel.make(:target => Iqvoc::XLLabel.base_class.make(:value => "Weltraumkampfspezialpilot"))]
    )
    @concept.send(Iqvoc::Concept.broader_relation_class.name.to_relation_name).create_with_reverse_relation(broader_concept)
    @concept.send(Iqvoc::Concept.broader_relation_class.narrower_class.name.to_relation_name).create_with_reverse_relation(narrower_concept)
    
    @document = Document.make!
  end
  
  test "should determine concepts" do
    assert true
  end
  
end
