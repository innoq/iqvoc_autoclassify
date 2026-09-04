# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class DocumentsCompareTest < ActionDispatch::IntegrationTest
  setup do
    @original_service_uri = ENV['AUTOCLASSIFY_SERVICE_URI']
    ENV['AUTOCLASSIFY_SERVICE_URI'] = 'http://sns-autoclassify.test'
    Rails.application.reload_routes!

    @original_base_url = AutoclassifyApiService::BASE_URL
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, 'http://sns-autoclassify.test')

    Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum
      -
        value: Kampf

      concepts:
      -
        origin: weltraum
        pref_labels: [Weltraum]
      -
        origin: kampf
        pref_labels: [Kampf]
    EOF
  end

  teardown do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, @original_base_url)

    ENV['AUTOCLASSIFY_SERVICE_URI'] = @original_service_uri
    Rails.application.reload_routes!
  end

  teardown { logout }

  test 'compare page lists every result per engine and highlights the engine-only hits' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        results: [
          { uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' },
          { uri: 'http://sns.uba.de/umthes/de/_09999999', score: 0.3, pref_label: 'Sonstiges' }
        ]
      }.to_json
    )

    login 'administrator'
    visit compare_documents_path(lang: 'de')

    fill_in 'Text', with: 'der Weltraum im Kampf'
    click_button 'Text verschlagworten'

    assert page.current_path.include?('/de/documents/'), 'expected redirect to the persisted document'
    assert page.has_no_css?('#auto-classify-results'), 'the classic single-column results box should not render for compare documents'

    assert page.has_no_css?('.compare-column-shared'), 'the shared column should be dissolved into the two engine columns'

    # classic finds Weltraum (shared) + Kampf (classic only), sns finds Weltraum (shared) + Sonstiges (sns only)
    within('.compare-column-classic') do
      assert page.has_css?('.auto-classify-result', count: 2)
      assert page.has_css?('.auto-classify-result-autoclassify', count: 1, text: 'Kampf')
      assert page.has_css?('.auto-classify-result-shared', count: 1, text: 'Weltraum')
    end

    within('.compare-column-sns') do
      assert page.has_css?('.auto-classify-result', count: 2)
      assert page.has_css?('.auto-classify-result-autoclassify2', count: 1, text: 'Sonstiges')
      assert page.has_css?('.auto-classify-result-shared', count: 1, text: 'Weltraum')
    end
  end

  test 'each engine column lists its results ordered by descending score' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        results: [
          { uri: 'http://sns.uba.de/umthes/de/_09999999', score: 0.3, pref_label: 'Sonstiges' },
          { uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' }
        ]
      }.to_json
    )

    login 'administrator'
    visit compare_documents_path(lang: 'de')

    fill_in 'Text', with: 'der Weltraum, der Weltraum im Kampf'
    click_button 'Text verschlagworten'

    within('.compare-column-sns') do
      assert_equal ['Weltraum', 'Sonstiges'], page.all('.auto-classify-result .result-item').map { |item| item.text.strip }
    end

    within('.compare-column-classic') do
      scores = page.all('.auto-classify-result').map { |result| result.text[/\[([\d.,]+)\]/, 1].tr(',', '.').to_f }
      assert_equal 2, scores.size
      assert_equal scores.sort.reverse, scores, 'classic results should be listed by descending weighting'
    end
  end

  test 'venn diagram shows the classic-only, shared and sns-only counts as three distinct numbers' do
    Maker.from_yaml <<-EOF
      labels:
      -
        value: Fracht

      concepts:
      -
        origin: fracht
        pref_labels: [Fracht]
    EOF

    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        results: [
          { uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' },
          { uri: 'http://sns.uba.de/umthes/de/_09999999', score: 0.3, pref_label: 'Sonstiges' }
        ]
      }.to_json
    )

    login 'administrator'
    visit compare_documents_path(lang: 'de')
    fill_in 'Text', with: 'der Weltraum im Kampf mit Fracht'
    click_button 'Text verschlagworten'

    # classic engine finds Weltraum, Kampf, Fracht (3); sns-autoclassify finds Weltraum (shared) and Sonstiges (sns-only)
    # -> classic-only: Kampf + Fracht = 2, shared: Weltraum = 1, sns-only: Sonstiges = 1
    assert page.has_css?('svg circle', count: 2), 'expected two overlapping circles'
    within('svg') do
      assert page.has_css?('text', exact_text: '2', count: 1)
      assert page.has_css?('text', exact_text: '1', count: 2)
    end
  end

  test 'compare page is reachable as its own page, not a tab, and only linked for admins' do
    login 'administrator'
    visit new_document_path(lang: 'de')

    assert page.has_no_css?('#compare-tab'), 'compare should not be a tab on the main new-document page'
    assert page.has_link?(I18n.t('txt.controllers.documents.new.compare'), href: compare_documents_path(lang: 'de', format: 'html'))

    click_link I18n.t('txt.controllers.documents.new.compare')
    assert_equal compare_documents_path(lang: 'de', format: 'html'), page.current_path
    assert page.has_css?('form.document-form')
  end

  test 'compare stays possible with classic-only results when sns-autoclassify is configured but unreachable (e.g. not started)' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_raise(Faraday::ConnectionFailed.new('Connection refused'))

    login 'administrator'
    visit compare_documents_path(lang: 'de')

    fill_in 'Text', with: 'der Weltraum im Kampf'
    click_button 'Text verschlagworten'

    assert page.current_path.include?('/de/documents/'), 'expected redirect to the persisted document'
    within('.compare-column-classic') { assert page.has_css?('.auto-classify-result-autoclassify', count: 2) }
    within('.compare-column-sns') { assert page.has_css?('.auto-classify-result', count: 0) }
    assert page.has_content?(I18n.t('txt.views.document.show.compare_unavailable'))
  end

  test 'previously created comparisons remain viewable after sns-autoclassify is no longer configured, new submissions are disabled' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { results: [{ uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' }] }.to_json
    )

    document = Document::Compare::Plain.create!(content: 'der Weltraum im Kampf')
    document.classify!
    document_url = document_path(document, lang: 'de')

    ENV['AUTOCLASSIFY_SERVICE_URI'] = nil
    Rails.application.reload_routes!

    login 'administrator'

    visit new_document_path(lang: 'de')
    assert page.has_no_link?(I18n.t('txt.controllers.documents.new.compare')), 'no link to submit a new comparison once sns-autoclassify is unconfigured'

    visit document_url
    assert_equal 200, page.status_code
    within('.compare-column-classic') { assert page.has_css?('.auto-classify-result', count: 2) }
    within('.compare-column-sns') { assert page.has_css?('.auto-classify-result-shared', count: 1) }
  end

  test 'reclassifying a compare document via the toolbar stays on the compare view' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { results: [{ uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' }] }.to_json
    )

    login 'administrator'
    visit compare_documents_path(lang: 'de')
    fill_in 'Text', with: 'der Weltraum'
    click_button 'Text verschlagworten'

    click_button 'Neu verschlagworten'

    assert_equal 200, page.status_code
    assert page.has_css?('.compare-column-classic'), 'reclassify should stay on the dedicated compare view, not fall back to the classic single-column view'
    within('.compare-column-sns') { assert page.has_css?('.auto-classify-result-shared', count: 1) }
  end

  test 'a failed update on a compare document still renders the dedicated compare view, not the shared one' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { results: [{ uri: 'http://sns.uba.de/umthes/de/weltraum', score: 0.9, pref_label: 'Weltraum' }] }.to_json
    )

    document = Document::Compare::Plain.create!(content: 'der Weltraum')
    document.classify!

    login 'administrator'
    visit edit_document_path(document, lang: 'de')
    fill_in 'Texteingabe', with: ''
    click_button 'Text verschlagworten'

    assert_equal 400, page.status_code
    assert page.has_no_css?('#auto-classify-results'), 'should not fall back to the shared single-column view on a validation failure'
    assert page.has_css?('.compare-column-classic')
  end

  test 'compare page is not linked or reachable without administration rights' do
    visit new_document_path(lang: 'de')

    assert page.has_no_css?('#compare-tab')
    assert page.has_no_link?(I18n.t('txt.controllers.documents.new.compare'))

    visit compare_documents_path(lang: 'de')
    assert_equal 401, page.status_code
  end

end
