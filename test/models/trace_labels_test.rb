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

  test "tracing exposes discovered labels by inflectionals' normal_hash" do
    sentence = %w(lorem Weltraum ipsum Pilot)
    matcher = WordMatcher.new([sentence])
    _ = matcher.labels
    trace = matcher.trace

    assert_equal 2, trace[:label_index].length
    assert_equal @label_ids['Weltraum'], trace[:label_index][Inflectional::Base.normalize('Weltraum')]
    assert_equal @label_ids['Pilot'], trace[:label_index][Inflectional::Base.normalize('Pilot')]
    assert_equal({}, trace[:compound_index])
  end

  test "tracing exposes discovered compound labels by first component's label ID" do
    sentence = %w(lorem Weltraum ipsum Kampf dolor Fracht sit Pilot amet)
    matcher = WordMatcher.new([sentence])
    _ = matcher.labels
    trace = matcher.trace

    assert_equal 4, trace[:label_index].length
    assert_equal 1, trace[:compound_index].length
    label_ids = trace[:compound_index][@label_ids['Weltraum']]
    assert_equal 2, label_ids.length
    assert label_ids.include?(@label_ids['Weltraumkampfpilot'])
    assert label_ids.include?(@label_ids['Weltraumfrachtpilot'])
  end

end
