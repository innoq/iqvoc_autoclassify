# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class CompoundLabelIdentificationTest < ActionController::TestCase

  setup do
    @labels = {}
    # labels with inflectionals
    {
      "Weltraum" => [],
      "Kampf" => ["Kämpfe", "Kampfes"],
      "Fracht" => [],
      "Pilot" => ["Piloten", "Pilotin"]
    }.each { |term, inflectionals|
      @labels[term] = make_label(term, :inflectionals => inflectionals)
    }
    # compound forms
    {
      "Weltraumkampfpilot" => ["Weltraum", "Kampf", "Pilot"],
      "Weltraumfrachtpilot" => ["Weltraum", "Fracht", "Pilot"]
    }.each { |term, components|
      components = components.map { |term| @labels[term] }
      @labels[term] = make_label(term, :components => components)
    }
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
