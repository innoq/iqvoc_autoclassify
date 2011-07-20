# encoding: UTF-8

require 'test_helper'
require 'word_matcher'

class CompoundLabelIdentificationTest < ActionController::TestCase

  setup do # TODO: use factories/blueprints
    @labels = {}
    {
      "Weltraum" => [],
      "Kampf" => ["Kämpfe", "Kampfes"],
      "Fracht" => [],
      "Pilot" => ["Piloten", "Pilotin"]
    }.each { |term, inflectionals|
      @labels[term] = Iqvoc::XLLabel.base_class.create :value => term,
          :origin => OriginMapping.merge(term)
      inflectionals.unshift term # the label itself is also an inflectional
      inflectionals.each { |inf|
        Inflectional::Base.create :value => inf, :label => @labels[term]
      }
    }

    compound = "Weltraumkampfpilot"
    @labels[compound] = Iqvoc::XLLabel.base_class.create :value => compound,
        :origin => OriginMapping.merge(compound)
    compound_form_contents = ["Weltraum", "Kampf", "Pilot"].map { |term|
      CompoundForm::Content::Base.new(:label => @labels[term])
    }
    @labels[compound].compound_forms.create!(:compound_form_contents => compound_form_contents)

    compound = "Weltraumfrachtpilot"
    @labels[compound] = Iqvoc::XLLabel.base_class.create :value => compound,
        :origin => OriginMapping.merge(compound)
    compound_form_contents = ["Weltraum", "Fracht", "Pilot"].map { |term|
      CompoundForm::Content::Base.new(:label => @labels[term])
    }
    @labels[compound].compound_forms.create!(:compound_form_contents => compound_form_contents)
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
