# encoding: UTF-8

require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  setup do
    make_from_yaml <<-EOF
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

  test "ensures content is supplied" do
    doc = Document.new
    doc.save

    assert_equal 0, Document.count
    assert_equal 1, doc.errors.length
  end

  test "ensures content is unique" do
    Document.make!(:content => "lipsum")

    doc = Document.new(:content => "lipsum")
    doc.save
    assert_equal 1, doc.errors.length
  end

  test "classification creation" do
    text = "der Weltraum - Piloten im Kampf"

    doc = Document.new(:content => text)
    doc.url_info = { :host => "localhost", :lang => "de" }

    assert_equal 0, Classification.count

    doc.save!

    assert_equal 3, Classification.count
    assert_equal 3, doc.classifications.length
    uri_pattern = Regexp.new("^http://localhost/de/concepts/_\\d+")
    doc.classifications.each { |classification|
      assert_equal 1.0, classification.weighting
      assert_equal 0, classification.concept_uri =~ uri_pattern
    }
  end

end
