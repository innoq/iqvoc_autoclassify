# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class DocumentTest < ActiveSupport::TestCase

  setup do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
      -
        value: Fracht
      -
        value: Pilot
        inflectionals: [Piloten]

      concepts:
      -
        pref_labels: [Weltraum]
      -
        pref_labels: [Kampf]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
    EOF
  end

  test 'classification creation' do
    text = 'der Weltraum - Piloten im Kampf'

    doc = Document::Plain.create(content: text)

    assert_equal 0, doc.classifications.count

    doc.classify!
    assert doc.classified?

    assert_equal 3, doc.classifications.count

    doc.classifications.each do |classification|
      assert_equal 1.0, classification.weighting
    end
  end

end
