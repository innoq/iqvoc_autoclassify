# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class HomographLabelIdentificationTest < ActiveSupport::TestCase

  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weide
      -
        value: Salix
      -
        value: Grünland
      -
        value: Weide [Salix]
      -
        value: Weide [Grünland]
      -
        value: Luft
      -
        value: Weide [Salix, Grünland]
      -
        value: Luft [Weide [Grünland]]
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }

    # FIXME: (architecture) Can't use RDFAPI here as Homograph/Qualifier aren't part of iqvoc_autoclassify
    Label::Relation::Umt::Homograph.create!(domain_id: @label_ids['Weide [Salix]'], range_id: @label_ids['Weide'])
    Label::Relation::Umt::Qualifier.create!(domain_id: @label_ids['Weide [Salix]'], range_id: @label_ids['Salix'])

    Label::Relation::Umt::Homograph.create!(domain_id: @label_ids['Weide [Grünland]'], range_id: @label_ids['Weide'])
    Label::Relation::Umt::Qualifier.create!(domain_id: @label_ids['Weide [Grünland]'], range_id: @label_ids['Grünland'])

    Label::Relation::Umt::Homograph.create!(domain_id: @label_ids['Weide [Salix, Grünland]'], range_id: @label_ids['Weide'])
    Label::Relation::Umt::Qualifier.create!(domain_id: @label_ids['Weide [Salix, Grünland]'], range_id: @label_ids['Salix'])
    Label::Relation::Umt::Qualifier.create!(domain_id: @label_ids['Weide [Salix, Grünland]'], range_id: @label_ids['Grünland'])

    Label::Relation::Umt::Homograph.create!(domain_id: @label_ids['Luft [Weide [Grünland]]'], range_id: @label_ids['Weide [Grünland]'])
    Label::Relation::Umt::Qualifier.create!(domain_id: @label_ids['Luft [Weide [Grünland]]'], range_id: @label_ids['Luft'])
  end

  test 'simple homograph discovery' do
    sentences = (DocumentParser::German.new('Bäume (zum Beispiel Weide (Salix)) sind empfindlich gegenüber Verschmutzungen der Luft.')).sentences
    matcher = WordMatcher.new(sentences)
    labels = matcher.labels

    assert_equal 3, labels.length
    assert labels.include? @label_ids['Luft'] # common label
    assert labels.include? @label_ids['Weide [Salix]'] # full homograph/qualifier pair found
    assert labels.include? @label_ids['Weide [Salix, Grünland]'] # some homograph/qualifier pair found
    assert labels.exclude? @label_ids['Weide'] # common label but part of homograph/qualifier pair, hence retained
    assert labels.exclude? @label_ids['Salix'] # common label but part of homograph/qualifier pair, hence retained
    assert labels.exclude? @label_ids['Weide [Grünland]'] # qualifier not given

    trace_flat = matcher.trace.transform_values { |it| it.values.flatten } # ignore sentence segmentation for now

    assert_equal labels, trace_flat[:result_index]
    assert_equal 3, trace_flat[:label_index].length
    assert_equal 2, trace_flat[:homograph_index].length
    assert_empty trace_flat[:compound_index]

    assert trace_flat[:homograph_index].include?(@label_ids['Weide [Salix]'])
    assert trace_flat[:homograph_index].include?(@label_ids['Weide [Salix, Grünland]'])
    assert trace_flat[:result_index].include?(@label_ids['Luft'])
    assert trace_flat[:result_index].include?(@label_ids['Weide [Salix]'])
    assert trace_flat[:result_index].include?(@label_ids['Weide [Salix, Grünland]'])
  end

  test 'cascading homograph discovery' do
    sentences = (DocumentParser::German.new('Lorem Weide Ipsum Grünland Amet Luft Dolor')).sentences
    matcher = WordMatcher.new(sentences)
    labels = matcher.labels

    assert_equal 2, labels.length
    assert labels.include? @label_ids['Weide [Salix, Grünland]'] # common homograph/qualifier pair
    assert labels.include? @label_ids['Luft [Weide [Grünland]]'] # cascading homograph/qualifier pair

    trace_flat = matcher.trace.transform_values { |it| it.values.flatten } # ignore sentence segmentation for now

    assert_equal labels, trace_flat[:result_index]
    assert_equal 3, trace_flat[:label_index].length
    assert_equal 2, trace_flat[:homograph_index].length
    assert_empty trace_flat[:compound_index]

    assert trace_flat[:homograph_index].include?(@label_ids['Weide [Salix, Grünland]'])
    assert trace_flat[:homograph_index].include?(@label_ids['Luft [Weide [Grünland]]'])
    assert trace_flat[:result_index].include?(@label_ids['Weide [Salix, Grünland]'])
    assert trace_flat[:result_index].include?(@label_ids['Luft [Weide [Grünland]]'])
  end
end
