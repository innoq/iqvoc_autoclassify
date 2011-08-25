# encoding: UTF-8

require 'test_helper'

class TraceConceptsTest < ActiveSupport::TestCase

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
        value: Pilot
      -
        value: foo

      concepts:
      -
        pref_labels: [Weltraum]
        alt_labels: [All]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
      -
        pref_labels: [foo]
        published_at:
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
    @concept_ids = data[:concepts]
    @concept_ids.each { |term, concept| @concept_ids[term] = concept.id }
  end

  test "trace not created by default" do
    text = "lorem Weltraum ipsum Pilot"
    doc = make_document(:content => text)

    assert_equal nil, doc.classification_trace
  end

  test "tracing exposes discovered concepts by label ID" do
    text = "lorem Weltraum ... Pilot ipsum All"
    trace = make_document(:content => text).trace

    assert_equal 3, trace[:label_index].length
    assert_equal 0, trace[:compound_index].length
    assert_equal 2, trace[:concept_index].length
    assert_equal 1, trace[:concept_index][@concept_ids["Pilot"]].length
    assert trace[:concept_index][@concept_ids["Pilot"]].include? @label_ids["Pilot"]
    assert_equal 2, trace[:concept_index][@concept_ids["Weltraum"]].length
    assert trace[:concept_index][@concept_ids["Weltraum"]].include? @label_ids["Weltraum"]
    assert trace[:concept_index][@concept_ids["Weltraum"]].include? @label_ids["All"]
  end

  test "trace is persisted explicitly (rather than automatically)" do
    text = "lorem Weltraum ... Pilot ipsum All"

    doc = make_document(:content => text)

    assert_equal nil, doc.classification_trace

    _ = doc.trace

    assert_equal nil, doc.classification_trace

    doc.destroy
    doc = make_document(:content => text)
    classification_trace = doc.create_classification_trace

    assert_instance_of ClassificationTrace, doc.classification_trace
    assert_instance_of String, classification_trace.trace

    trace = JSON.parse(classification_trace.trace) # NB: both symbols and integer keys become strings
    assert_equal 3, trace["label_index"].length
    assert_equal 0, trace["compound_index"].length
    assert_equal 2, trace["concept_index"].length
    assert_equal 1, trace["concept_index"][@concept_ids["Pilot"].to_s].length
    assert trace["concept_index"][@concept_ids["Pilot"].to_s].include? @label_ids["Pilot"]
    assert_equal 2, trace["concept_index"][@concept_ids["Weltraum"].to_s].length
    assert trace["concept_index"][@concept_ids["Weltraum"].to_s].include? @label_ids["Weltraum"]
    assert trace["concept_index"][@concept_ids["Weltraum"].to_s].include? @label_ids["All"]
  end

end
