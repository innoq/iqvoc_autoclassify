# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'word_matcher'

class HomographLabelIdentificationTest < ActiveSupport::TestCase

  module Label::Relation::UMT
    class Homograph < Label::Relation::SKOSXL::Base
      self.rdf_predicate = 'homograph'
      self.rdf_namespace = 'sns'
    end

    class Qualifier < Label::Relation::SKOSXL::Base
      self.rdf_predicate = 'qualifier'
      self.rdf_namespace = 'sns'
    end
  end

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
    EOF
    @label_ids = data[:labels]
    @label_ids.each { |term, label| @label_ids[term] = label.id }

    Label::Relation::UMT::Homograph.create!(domain_id: @label_ids['Weide [Salix]'], range_id: @label_ids['Weide'])
    Label::Relation::UMT::Qualifier.create!(domain_id: @label_ids['Weide [Salix]'], range_id: @label_ids['Salix'])

    Label::Relation::UMT::Homograph.create!(domain_id: @label_ids['Weide [Grünland]'], range_id: @label_ids['Weide'])
    Label::Relation::UMT::Qualifier.create!(domain_id: @label_ids['Weide [Grünland]'], range_id: @label_ids['Grünland'])
  end

  test 'homograph discovery' do
    sentences = (DocumentParser::German.new('Bäume (zum Beispiel Weide (Salix)) sind empfindlich gegenüber Verschmutzungen der Luft.')).sentences
    labels = WordMatcher.new(sentences).labels

    assert_equal 2, labels.length
    assert labels.include? @label_ids['Luft']
    assert labels.include? @label_ids['Weide [Salix]']
    assert labels.exclude? @label_ids['Weide']
    assert labels.exclude? @label_ids['Salix']
  end

end
