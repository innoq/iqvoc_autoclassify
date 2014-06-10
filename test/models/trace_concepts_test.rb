# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

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
        pref_labels: [All]
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

  test 'tracing exposes discovered concepts by label ID' do
    text = 'lorem Weltraum ... Pilot ipsum All'
    doc = make_document(content: text)

    assert_instance_of ClassificationTrace, doc.classification_trace

    trace = JSON.parse(doc.classification_trace.trace) # NB: both symbols and integer keys become strings

    assert_equal 3, trace['label_index'].length
    assert_equal 0, trace['compound_index'].length
    assert_equal 3, trace['concept_index'].length
    assert_equal 1, trace['concept_index'][@label_ids['Pilot'].to_s].length
    assert trace['concept_index'][@label_ids['Pilot'].to_s].include? @concept_ids['Pilot']
    assert_equal 1, trace['concept_index'][@label_ids['Weltraum'].to_s].length
    assert trace['concept_index'][@label_ids['Weltraum'].to_s].include? @concept_ids['Weltraum']
    assert_equal 2, trace['concept_index'][@label_ids['All'].to_s].length
    assert trace['concept_index'][@label_ids['All'].to_s].include? @concept_ids['All']
    assert trace['concept_index'][@label_ids['All'].to_s].include? @concept_ids['Weltraum']
  end

end
