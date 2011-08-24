# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class TraceLabelsTest < ActiveSupport::TestCase

  setup do
    data = Iqvoc::Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
        inflectionals: [Kämpfe, Kampfes]
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

  test "tracing deactivated by default" do
    sentence = "lorem Weltraum ipsum Pilot".split(" ")
    matcher = WordMatcher.new([sentence])
    _ = matcher.labels

    assert_equal nil, matcher.trace
  end

  test "tracing exposes discovered labels by inflectionals' normal_hash" do
    sentence = "lorem Weltraum ipsum Pilot".split(" ")
    matcher = WordMatcher.new([sentence], true)
    _ = matcher.labels
    trace = matcher.trace

    assert_equal 2, trace[:label_index].length
    assert_equal @label_ids["Weltraum"], trace[:label_index][Inflectional::Base.normalize("Weltraum")]
    assert_equal @label_ids["Pilot"], trace[:label_index][Inflectional::Base.normalize("Pilot")]
    assert_equal({}, trace[:compound_index])
  end

  test "tracing exposes discovered compound labels by first component's label ID" do
    sentence = "foo Weltraum bar Kampf baz Pilot".split(" ")
    matcher = WordMatcher.new([sentence], true)
    _ = matcher.labels
    trace = matcher.trace

    assert_equal 3, trace[:label_index].length
    assert_equal 1, trace[:compound_index].length
    assert_equal @label_ids["Weltraumkampfpilot"], trace[:compound_index][@label_ids["Weltraum"]]
  end

end
