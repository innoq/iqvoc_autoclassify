# encoding: UTF-8

require 'test_helper'

class DocumentLabelsTest < ActiveSupport::TestCase

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
        inflectionals: [Weltraumkampfpiloten]
        components: [Weltraum, Kampf, Pilot]
      -
        value: Weltraumfrachtpilot
        components: [Weltraum, Fracht, Pilot]
      -
        value: foo
        published_at:
      -
        value: bar
        published_at:
      -
        value: Oder
      -
        value: Moder
      -
        value: moderat
      -
        value: oderfoo
    EOF
    @labels = data[:labels]
  end

  test "title inclusion during classification" do
    title = "Weltraumkampfpiloten"
    text = "Im Weltraum fliegt ein Pilot."

    labels = make_document(:title => title, :content => text).determine_labels
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["Pilot"]
    assert labels.include? @labels["Weltraumkampfpilot"]
  end

  test "label discovery and redundancy elimination" do
    text = <<-EOF
      Im Weltraum fliegt ein Pilot. Es besteht die Gefahr eines Kampfes. Dazu
      gibt es Weltraumkampfpiloten, die ausgebildet sind, in den Weiten des
      Weltraums Kämpfe auszutragen.
    EOF

    labels = make_document(:content => text).determine_labels
    assert_equal 4, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["Pilot"]
    assert labels.include? @labels["Kampf"]
    assert labels.include? @labels["Weltraumkampfpilot"]
  end

  test "avoiding sentence conflation" do
    text = "Im Weltraum tobt ein Kampf. Darin verwickelt ist unser Pilot."

    labels = make_document(:content => text).determine_labels
    assert_equal 3, labels.length
    assert labels.include? @labels["Weltraum"]
    assert labels.include? @labels["Pilot"]
    assert labels.include? @labels["Kampf"]
    assert (not labels.include? @labels["Weltraumkampfpilot"])
  end

  test "ignore unpublished labels" do
    text = "lorem foo ipsum bar"

    labels = make_document(:content => text).determine_labels
    assert_equal 0, labels.length
  end

  test "handling of Oder river vs. 'oder' conjunction" do
    text = "er oder sie"

    labels = make_document(:content => text).determine_labels
    assert_equal 0, labels.length

    text = "auf der Oder"

    labels = make_document(:content => text).determine_labels
    assert_equal 1, labels.length

    text = "moderat Moder oderfoo" # "oderfoo" since there's no actual word starting with lowercase "oder"

    labels = make_document(:content => text).determine_labels
    assert_equal 3, labels.length
  end

end
