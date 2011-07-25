# encoding: UTF-8

require 'test_helper'

class DocumentLabelsTest < ActiveSupport::TestCase

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
        inflectionals: [Weltraumkampfpiloten]
        components: [Weltraum, Kampf, Pilot]
      -
        value: Weltraumfrachtpilot
        components: [Weltraum, Fracht, Pilot]
    EOF
    @labels = data[:labels]
  end

  test "label discovery and redundancy elimination" do
    text = <<-EOF
      Im Weltraum fliegt ein Pilot. Es besteht die Gefahr eines Kampfes. Dazu
      gibt es Weltraumkampfpiloten, die ausgebildet sind, in den Weiten des
      Weltraums Kämpfe auszutragen.
    EOF

    labels = Document.make!(:content => text).labels
    assert_equal 4, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["Pilot"]
    assert labels.include? @labels["Kampf"]
    assert labels.include? @labels["Weltraumkampfpilot"]
  end

end
