# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class CompoundLabelIdentificationTest < ActiveSupport::TestCase

  setup do
    data = make_from_yaml <<-EOF
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
    @labels = data[:labels]
  end

  test "compound discovery" do
    sentence = ["der", "Weltraum", "der", "Kampf", "und", "der", "Pilot"]
    labels = WordMatcher.new(sentence).labels
    assert_equal 4, labels.length
    assert labels.include? @labels["Weltraumkampfpilot"]
    assert (not labels.include? @labels["Weltraumfrachtpilot"])

    sentence = ["Weltraum", "des", "Kampfes", "und", "der", "Piloten"]
    labels = WordMatcher.new(sentence).labels
    assert_equal 4, labels.length
    assert labels.include? @labels["Weltraumkampfpilot"]
    assert (not labels.include? @labels["Weltraumfrachtpilot"])
  end

  test "order of occurrence is significant" do
    sentence = ["der", "Kampf", "der", "Weltraum", "und", "der", "Pilot"]
    labels = WordMatcher.new(sentence).labels
    assert_equal 3, labels.length
    assert (not labels.include? @labels["Weltraumkampfpilot"])
    assert (not labels.include? @labels["Weltraumfrachtpilot"])
  end

end
