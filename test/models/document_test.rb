# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')

class DocumentTest < ActiveSupport::TestCase

  setup do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
      -
        value: Fracht
      -
        value: Pilot
        inflectionals: [Piloten]

      concepts:
      -
        pref_labels: [Weltraum]
      -
        pref_labels: [Kampf]
      -
        pref_labels: [Fracht]
      -
        pref_labels: [Pilot]
    EOF
  end

  test 'classification creation' do
    text = 'der Weltraum - Piloten im Kampf'

    doc = Document::Plain.create(content: text)

    assert_equal 0, doc.classifications.count

    doc.classify!
    assert doc.classified?

    assert_equal 3, doc.classifications.count

    doc.classifications.each do |classification|
      assert_equal 1.0, classification.weighting
    end
  end

  test 'truncates an overlong title without breaking a character' do
    limit = Document::Base::MAX_TITLE_CHARS
    suffix = Document::Base::MAX_CONTENT_SUFFIX

    doc = Document::Plain.new(title: 'ä' * limit)

    assert doc.title.end_with?(suffix)
    assert_equal Encoding::UTF_8, doc.title.encoding
    assert doc.title.valid_encoding?, 'must not cut a multibyte character in half'
    truncated = doc.title.delete_suffix(suffix)
    assert_operator truncated.bytesize, :<=, limit - suffix.length
    # cut as late as possible, i.e. only the trailing character did not fit
    assert_operator truncated.bytesize, :>, limit - suffix.length - 'ä'.bytesize
  end

  test 'truncates an overlong content without breaking a character' do
    limit = Document::Base::MAX_CONTENT_CHARS
    suffix = Document::Base::MAX_CONTENT_SUFFIX

    doc = Document::Plain.new(content: 'ä' * limit)

    assert doc.content.end_with?(suffix)
    assert doc.content.valid_encoding?, 'must not cut a multibyte character in half'
    truncated = doc.content.delete_suffix(suffix)
    assert_operator truncated.bytesize, :<=, limit - suffix.length
    # cut as late as possible, i.e. only the trailing character did not fit
    assert_operator truncated.bytesize, :>, limit - suffix.length - 'ä'.bytesize
  end

  # Textractor hands back a binary body for text/plain responses; truncation
  # used to repair that via ActiveSupport::Multibyte::Chars
  test 'truncates non-UTF-8 input without blowing up on the suffix' do
    binary = ('Öl Straße ' * 1500).dup.force_encoding(Encoding::ASCII_8BIT)

    doc = Document::Plain.new(content: binary, title: binary)

    assert_equal Encoding::UTF_8, doc.content.encoding
    assert doc.content.valid_encoding?
    assert doc.content.end_with?(Document::Base::MAX_CONTENT_SUFFIX)
    assert_equal Encoding::UTF_8, doc.title.encoding
    assert doc.title.valid_encoding?
  end

  test 'leaves a title within the limit untouched' do
    title = 'Weltraum'

    assert_equal title, Document::Plain.new(title: title).title
  end

end
