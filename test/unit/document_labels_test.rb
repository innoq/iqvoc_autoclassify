# encoding: UTF-8

require 'test_helper'

class DocumentLabelsTest < ActiveSupport::TestCase

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
    # compound forms with inflectionals
    {
      "Weltraumkampfpilot" => [
        ["Weltraumkampfpiloten"],
        ["Weltraum", "Kampf", "Pilot"]
      ],
      "Weltraumfrachtpilot" => [ [], ["Weltraum", "Fracht", "Pilot"] ]
    }.each { |term, options|
      @labels[term] = make_label(term, :inflectionals => options[0],
          :components => options[1].map { |term| @labels[term] })
    }
  end

  test "label discovery and redundancy elimination" do
    text = <<-EOF
      Im Weltraum fliegt ein Pilot. Es besteht die Gefahr eines Kampfes. Dazu
      gibt es Weltraumkampfpiloten, die ausgebildet sind, in den Weiten des
      Weltraums Kämpfe auszutragen.
    EOF

    labels = Document.create!(:content => text).labels
    assert_equal 4, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["Pilot"]
    assert labels.include? @labels["Kampf"]
    assert labels.include? @labels["Weltraumkampfpilot"]
  end

end
