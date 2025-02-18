# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class HelpersTest < ActiveSupport::TestCase

  test 'labels from YAML' do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Foo
        published_at:
        inflectionals: ["foo", "fu"]
      -
        value: Bar
        language: en
        inflectionals: ["bar", "baz"]
      -
        value: FooBar
        components: ["Foo", "Bar"]
    EOF

    labels = Iqvoc::Xllabel.base_class.all
    assert_equal 3, labels.length

    label = labels[0]
    assert_equal 'Foo', label.value
    assert_equal 'de', label.language
    assert_nil label.published_at

    label = labels[1]
    assert_equal 'Bar', label.value
    assert_equal 'en', label.language
    assert_not_nil label.published_at

    label = labels[2]
    assert_equal 'FooBar', label.value
    assert_equal 2, label.compound_form_contents.length
    assert_equal labels[0], label.compound_form_contents[0].label
    assert_equal labels[1], label.compound_form_contents[1].label

    assert_equal 7, Inflectional::Base.count
  end

  test 'concepts from YAML with label references' do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Foo
        language: en
      -
        value: Bar
        language: de
      -
        value: Baz
        language: en

      concepts:
      -
        pref_labels: [Foo, Bar]
        alt_labels: [Baz]
      -
        pref_labels: [Baz]
        published_at:
    EOF

    concepts = Iqvoc::Concept.base_class.all
    assert_equal 2, concepts.length

    concept = concepts[0]
    alt_labels = concept.send(Iqvoc::Concept.further_labeling_classes.
        first.first.name.to_relation_name).map(&:target)
    assert_equal 2, concept.pref_labels.count
    assert_equal %w(Bar Foo), concept.pref_labels.map(&:value).sort
    assert_equal 1, alt_labels.count
    assert_equal 'Baz', alt_labels[0].value

    concept = concepts[1]
    alt_labels = concept.send(Iqvoc::Concept.further_labeling_classes.
        first.first.name.to_relation_name).map(&:target)
    assert_nil concept.published_at
    assert_equal 1, concept.pref_labels.count
    assert_equal 'Baz', concept.pref_labels[0].value
    assert_equal 0, alt_labels.count
  end

  test 'concepts from YAML with inline labels' do
    # TODO (YAGNI?)
  end

  test 'concepts from YAML with relation references' do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Foo
        language: en
      -
        value: Bar
        language: de
      -
        value: Baz
        language: en

      concepts:
      -
        pref_labels: [Foo]
      -
        pref_labels: [Baz]
      -
        pref_labels: [Bar]
        broader: Foo
        narrower: Baz
    EOF

    concepts = Iqvoc::Concept.base_class.all
    assert_equal 3, concepts.length

    concept = concepts[0]
    assert_equal 0, concept.broader_relations.count
    assert_equal 1, concept.narrower_relations.count

    concept = concepts[1]
    assert_equal 1, concept.broader_relations.count
    assert_equal 0, concept.narrower_relations.count

    concept = concepts[2]
    broader = concept.broader_relations.map(&:target)
    narrower = concept.narrower_relations.map(&:target)
    assert_equal 1, broader.count
    assert_equal 1, narrower.count
    assert_equal concepts[0], broader.first
    assert_equal concepts[1], narrower.first
  end

  test 'concepts from YAML with inline relations' do
    # TODO (YAGNI?)
  end

end
