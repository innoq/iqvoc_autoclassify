# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../../test_helper')

class Document::Compare::PlainTest < ActiveSupport::TestCase

  setup do
    @original_base_url = AutoclassifyApiService::BASE_URL
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, 'http://sns-autoclassify.test')

    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum

      concepts:
      -
        pref_labels: [Weltraum]
    EOF
    @concept = data[:concepts]['Weltraum']
  end

  teardown do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, @original_base_url)
  end

  test 'combines classic classifications with sns-autoclassify results' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        results: [
          { uri: "http://sns.uba.de/umthes/de/#{@concept.origin}", score: 0.9, pref_label: 'Weltraum' },
          { uri: 'http://sns.uba.de/umthes/de/_09999999', score: 0.3, pref_label: 'Sonstiges' }
        ]
      }.to_json
    )

    doc = Document::Compare::Plain.create(content: 'der Weltraum')
    doc.classify!

    assert doc.classified?
    assert_equal 1, doc.classifications.count
    assert_equal @concept.origin, doc.classifications.first.concept_origin

    refute doc.comparison_unavailable?
    assert_equal 2, doc.comparison_results.length
    assert_equal [@concept.origin], doc.shared_concept_origins
  end

  test 'gracefully degrades when the sns-autoclassify request fails' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(status: 500)

    doc = Document::Compare::Plain.create(content: 'der Weltraum')
    doc.classify!

    assert doc.classified?
    assert_equal 1, doc.classifications.count

    assert doc.comparison_unavailable?
    assert_equal [], doc.comparison_results
    assert_equal [], doc.shared_concept_origins
    assert_nil doc.api_response_body
  end

  test 'skips the sns-autoclassify call entirely when not configured' do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, nil)

    doc = Document::Compare::Plain.create(content: 'der Weltraum')
    doc.classify!

    assert doc.classified?
    assert_equal 1, doc.classifications.count
    assert doc.comparison_unavailable?
    assert_nil doc.api_response_body
    assert_not_requested :post, /sns-autoclassify/
  end

  test 'shared_concept_origins is empty without overlap' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        results: [
          { uri: 'http://sns.uba.de/umthes/de/_09999999', score: 0.3, pref_label: 'Sonstiges' }
        ]
      }.to_json
    )

    doc = Document::Compare::Plain.create(content: 'der Weltraum')
    doc.classify!

    refute doc.comparison_unavailable?
    assert_equal 1, doc.comparison_results.length
    assert_equal [], doc.shared_concept_origins
  end

end
