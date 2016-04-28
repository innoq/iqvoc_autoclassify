# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'word_matcher'

class TraceLabelsTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
        inflectionals: [Kampfes, Kämpfe]
      -
        value: Fracht
      -
        value: Pilot
        inflectionals: [Piloten, Pilotin]
      -
        value: Weltraumkampfpilot
        components: [Weltraum, Kampf, Pilot]
      -
        value: Weltraumfrachtpilot
        components: [Weltraum, Fracht, Pilot]
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }
  end

  test "tracing exposes discovered labels" do
    sentence = %w(lorem Weltraum ipsum Pilot)
    matcher = WordMatcher.new([sentence])
    labels = matcher.labels
    trace_flat = matcher.trace.transform_values { |it| it.values.flatten } # ignore sentence segmentation for now

    assert_equal labels, trace_flat[:result_index]

    assert_equal 2, trace_flat[:label_index].length
    assert_empty trace_flat[:compound_index]
    assert_empty trace_flat[:homograph_index]
    assert_equal 2, trace_flat[:result_index].length

    assert trace_flat[:label_index].include?(@label_ids['Weltraum'])
    assert trace_flat[:label_index].include?(@label_ids['Pilot'])
    assert trace_flat[:result_index].include?(@label_ids['Weltraum'])
    assert trace_flat[:result_index].include?(@label_ids['Pilot'])
  end

  test "tracing exposes discovered compound labels" do
    sentence = %w(lorem Weltraum ipsum Kampf dolor Fracht sit Pilot amet)
    matcher = WordMatcher.new([sentence])
    labels = matcher.labels
    trace_flat = matcher.trace.transform_values { |it| it.values.flatten } # ignore sentence segmentation for now

    assert_equal labels, trace_flat[:result_index]

    assert_equal 4, trace_flat[:label_index].length
    assert_equal 2, trace_flat[:compound_index].length
    assert_empty trace_flat[:homograph_index]
    assert_equal 2, trace_flat[:result_index].length

    assert trace_flat[:compound_index].include?(@label_ids['Weltraumkampfpilot'])
    assert trace_flat[:compound_index].include?(@label_ids['Weltraumfrachtpilot'])
  end

  # test "tracing exposes discovered homograph-qualifier labels" do
  #   skip("@see HomographLabelIdentificationTest")
  # end

end
