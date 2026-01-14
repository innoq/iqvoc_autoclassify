# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')

class DocumentsTest < ActionDispatch::IntegrationTest
  setup do
    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Foo
      -
        value: Bar
      -
        value: Baz

      concepts:
      -
        origin: foo
        pref_labels: [Foo]
      -
        origin: bar
        pref_labels: [Bar]
      -
        origin: baz
        pref_labels: [Baz]
    EOF

    @concepts = data[:concepts]

    @documents = [
      "lorem ipsum\ndolor sit amet",
      "lorem Foo ipsum\ndolor Bar sit Baz amet"
    ].map do |text|
      make_document(content: text)
    end
  end

  test 'list documents at index' do
    visit documents_path(lang: 'de')

    assert page.has_css? '.documents-table .documents-table-item', count: 2
    assert page.has_css? '.documents-table-item-link', count: 2

    classifications = all('.documents-table-item-classifications')
    assert_equal '3', classifications.first.text
    assert_equal '0', classifications.last.text
  end

  test 'list matching concepts for the respective document' do
    visit document_path(id: @documents[1], lang: 'de')

    assert page.has_css? 'ul.auto-classify-result-list li', count: 3
    assert page.has_no_selector?('pre.trace'), 'trace area should not be shown'
  end

  test 'list matching concepts for the respective document in trace mode' do
    login 'administrator'
    visit document_path(id: @documents[1], lang: 'de', trace: 1)

    assert page.has_selector?('pre.trace'), 'could not find trace area'
    assert page.has_css? 'ul.auto-classify-result-list li', count: 3
  end

  test 'reclassify document' do
    login 'administrator'

    visit document_path(id: @documents[0].id, format: 'html', lang: 'de')
    assert page.has_css?('ol li', count: 0)

    Maker.concept pref_labels: [Maker.label('lorem')]
    Maker.concept pref_labels: [Maker.label('dolor')]

    click_button I18n.t('txt.views.document.reclassify')
    assert page.has_content?('Dokument wurde erfolgreich aktualisiert.')
    visit document_path(id: @documents[0].id, format: 'html', lang: 'de')
    assert page.has_css?('ul.auto-classify-result-list li', count: 2)
  end

  test 'turtle rdf representation' do
    id = @documents[1].id

    visit document_path(id: id, lang: 'de', format: 'ttl')

    ttl = page.body.gsub(/^ +/, "\t") # simplifies testing

    assert ttl.include? '@prefix sdc: <http://sindice.com/vocab/search#>.'
    assert ttl.include? "<http://www.example.com/de/documents/#{id}> a sdc:Query;"
    refute ttl.include? 'sdc:result search:result0;'

    assert ttl.include? 'sdc:result search:result1;'
    expected = <<-EOS
      search:result1 a sdc:Result;
      \tsdc:link :foo;
      \tdct:title "Foo";
      \tsdc:rank 1.0.
    EOS
    assert ttl.include? expected.gsub(/^ +/, '')

    assert ttl.include? 'sdc:result search:result2;'
    expected = <<-EOS
      search:result2 a sdc:Result;
      \tsdc:link :bar;
      \tdct:title "Bar";
      \tsdc:rank 1.0.
    EOS
    assert ttl.include? expected.gsub(/^ +/, '')
    assert ttl.include? 'sdc:result search:result3.'
    expected = <<-EOS
      search:result3 a sdc:Result;
      \tsdc:link :baz;
      \tdct:title "Baz";
      \tsdc:rank 1.0.
    EOS
    assert ttl.include? expected.gsub(/^ +/, '')
  end

  test 'XML/RDF representation' do
    id = @documents[1].id
    visit document_path(id: id, lang: 'de', format: 'rdf')

    assert page.body.include? %{<rdf:Description rdf:about="http://www.example.com/de/documents/#{id}">}
    assert page.body.include? %{<rdf:type rdf:resource="http://sindice.com/vocab/search#Query"/>}
    refute page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result0"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result1"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result2"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result3"/>}
  end

  test 'persist documents when logged in' do
    documents_count = Document::Base.count

    login 'administrator'
    visit new_document_path(lang: 'de')
    fill_in 'Text', with: 'Foo Bar Baz'
    click_button 'Text verschlagworten'

    assert_equal Document::Base.count, documents_count+1 # one document than before
    assert page.current_path.include? '/de/documents/'
  end

  test 'not persist documents when logged out' do
    documents_count = Document::Base.count

    visit new_document_path(lang: 'de')
    fill_in 'Text', with: 'Foo Bar Baz'
    click_button 'Text verschlagworten'

    assert_equal Document::Base.count, documents_count # same count as before
    assert_equal page.current_path, '/de/autoclassify/plain.html'
  end

  test 'missing or empty plain content parameters' do
    visit new_document_path(lang: 'de')
    click_button 'Text verschlagworten'

    assert page.has_content?('Entweder URL oder Volltext müssen übermittelt werden'), 'Fehlermeldung nicht gefunden'

    visit new_document_path(lang: 'de')
    fill_in 'Text', with: ''
    click_button 'Text verschlagworten'

    assert page.has_content?('Entweder URL oder Volltext müssen übermittelt werden'), 'Fehlermeldung nicht gefunden'

    visit new_document_path(lang: 'de')
    fill_in 'Text', with: 'Lorem'
    click_button 'Text verschlagworten'

    assert page.has_no_content?('Entweder URL oder Volltext müssen übermittelt werden')
  end

  test 'missing or empty extracted uri parameter' do
    visit new_document_path(lang: 'de')
    click_button 'Text verschlagworten'

    assert page.has_content?('Entweder URL oder Volltext müssen übermittelt werden'), 'Fehlermeldung nicht gefunden'

    visit new_document_path(lang: 'de')
    fill_in 'URL zu HTML-Seite oder PDF-Dokument', with: ''
    click_button 'Text verschlagworten'

    assert page.has_content?('Entweder URL oder Volltext müssen übermittelt werden'), 'Fehlermeldung nicht gefunden'
  end

end
