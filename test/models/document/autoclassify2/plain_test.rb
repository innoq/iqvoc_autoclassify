# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../../test_helper')

class Document::Autoclassify2::PlainTest < ActiveSupport::TestCase

  setup do
    @original_base_url = AutoclassifyApiService::BASE_URL
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, 'http://sns-autoclassify.test')

    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf
      -
        value: Sonne
      -
        value: Mond

      concepts:
      -
        pref_labels: [Weltraum]
      -
        expired_at: '2020-01-01'
        pref_labels: [Kampf]
      -
        published_at:
        pref_labels: [Sonne]
      -
        auto_classify: false
        pref_labels: [Mond]
    EOF
    @concept = data[:concepts]['Weltraum']
    @expired_concept = data[:concepts]['Kampf']
    @unpublished_concept = data[:concepts]['Sonne']
    @non_classifiable_concept = data[:concepts]['Mond']
  end

  teardown do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, @original_base_url)
  end

  test 'classifies a document from the sns-autoclassify results' do
    stub_results([[@concept.origin, 0.9]])

    doc = classify_document

    assert doc.classified?
    assert_equal [@concept.origin], doc.classifications.map(&:concept_origin)
    assert_equal [0.9], doc.classifications.map { |c| c.weighting.to_f.round(4) }
  end

  # the service index is a snapshot of the thesaurus and is not filtered by
  # publication state, so it reports concepts we must not classify against --
  # a single one of those used to invalidate the whole document
  test 'skips expired concepts instead of failing the classification' do
    stub_results([[@concept.origin, 0.9], [@expired_concept.origin, 0.5]])

    doc = classify_document

    assert doc.classified?
    assert_equal [@concept.origin], doc.classifications.map(&:concept_origin)
  end

  test 'skips unpublished concepts' do
    stub_results([[@concept.origin, 0.9], [@unpublished_concept.origin, 0.5]])

    doc = classify_document

    assert doc.classified?
    assert_equal [@concept.origin], doc.classifications.map(&:concept_origin)
  end

  test 'skips concepts excluded from auto classification' do
    stub_results([[@concept.origin, 0.9], [@non_classifiable_concept.origin, 0.5]])

    doc = classify_document

    assert doc.classified?
    assert_equal [@concept.origin], doc.classifications.map(&:concept_origin)
  end

  test 'skips results without a matching concept' do
    stub_results([[@concept.origin, 0.9], ['_09999999', 0.5]])

    doc = classify_document

    assert doc.classified?
    assert_equal [@concept.origin], doc.classifications.map(&:concept_origin)
  end

  test 'classifies without results' do
    stub_results([])

    doc = classify_document

    assert doc.classified?
    assert_equal [], doc.classifications.to_a
  end

  private

  def stub_results(origins_with_scores)
    results = origins_with_scores.map { |origin, score|
      { uri: "http://sns.uba.de/umthes/de/#{origin}", score: score, pref_label: origin }
    }

    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { results: results }.to_json
    )
  end

  def classify_document
    doc = Document::Autoclassify2::Plain.create(content: 'der Weltraum')
    doc.classify!
    doc
  end

end
