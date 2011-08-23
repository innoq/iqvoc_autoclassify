# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class CompoundLabelIdentificationTest < ActiveSupport::TestCase

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

  test "compound discovery" do
    sentence = ["der", "Weltraum", "der", "Kampf", "und", "der", "Pilot"]
    labels = WordMatcher.new([sentence]).labels
    assert_equal 4, labels.length
    assert labels.include? @label_ids["Weltraumkampfpilot"]
    assert (not labels.include? @label_ids["Weltraumfrachtpilot"])

    sentence = ["Weltraum", "des", "Kampfes", "und", "der", "Piloten"]
    labels = WordMatcher.new([sentence]).labels
    assert_equal 4, labels.length
    assert labels.include? @label_ids["Weltraumkampfpilot"]
    assert (not labels.include? @label_ids["Weltraumfrachtpilot"])
  end

  test "order of occurrence is significant" do
    sentence = ["der", "Kampf", "der", "Weltraum", "und", "der", "Pilot"]
    labels = WordMatcher.new([sentence]).labels
    assert_equal 3, labels.length
    assert (not labels.include? @label_ids["Weltraumkampfpilot"])
    assert (not labels.include? @label_ids["Weltraumfrachtpilot"])
  end

  test "duplicates are retained" do
    sentence = "Weltraum Pilot Kampf Pilot".split(" ")
    labels = WordMatcher.new([sentence]).labels
    assert_equal 5, labels.length
    assert labels.include? @label_ids["Weltraumkampfpilot"]
    assert (not labels.include? @label_ids["Weltraumfrachtpilot"])
    assert_equal 2, labels.find_all { |id| id == @label_ids["Pilot"] }.length

    sentence = "foo Fracht bar Weltraum baz Pilot ... Kampf ... Pilot".split(" ")
    labels = WordMatcher.new([sentence]).labels
    assert_equal 6, labels.length
    assert labels.include? @label_ids["Weltraumkampfpilot"]
    assert (not labels.include? @label_ids["Weltraumfrachtpilot"])
    assert_equal 2, labels.find_all { |id| id == @label_ids["Pilot"] }.length
  end

end
