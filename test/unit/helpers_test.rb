# encoding: UTF-8

require 'test_helper'

class HelpersTest < ActiveSupport::TestCase

  test "labels from YAML" do
    make_from_yaml <<-EOF
      labels:
      -
        value: Foo
        published_at: nil
        inflectionals: ["foo", "fu"]
      -
        value: Bar
        language: en
        inflectionals: ["bar", "baz"]
      -
        value: FooBar
        components: ["Foo", "Bar"]
    EOF

    labels = Label::Base.all
    assert_equal 3, labels.length

    label = labels[0]
    assert_equal "Foo", label.value
    assert_equal "de", label.language
    assert_nil label.published_at

    label = labels[1]
    assert_equal "Bar", label.value
    assert_equal "en", label.language
    assert_not_nil label.published_at

    label = labels[2]
    assert_equal "FooBar", label.value
    assert_equal 2, label.compound_form_contents.length
    assert_equal labels[0], label.compound_form_contents[0].label
    assert_equal labels[1], label.compound_form_contents[1].label

    assert_equal 7, Inflectional::Base.count
  end

end
