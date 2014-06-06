# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require File.join(File.expand_path(File.dirname(__FILE__)), '../integration_test_helper')
require 'fake_web'

class DocumentsTest < ActionDispatch::IntegrationTest
  setup do
    data = Iqvoc::Maker.from_yaml <<-EOF
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

    @urls = {
      'pdf' => 'http://example.org/sample.pdf',
      'html' => 'http://example.org/sample.html'
    }
    FakeWeb.register_uri(:get, @urls['pdf'], :body => 'test/fixtures/sample.pdf',
        :content_type => 'application/pdf')
    FakeWeb.register_uri(:get, @urls['html'], :body => 'test/fixtures/sample.html')
  end

  test "list documents at index" do
    visit documents_path(lang: 'de')

    assert page.has_css?('.documents-table .documents-table-item', count: 2)
    assert page.has_css?('.documents-table-item-link', count: 2)

    classifications = all('.documents-table-item-classifications')
    assert_equal '0', classifications.first.text
    assert_equal '3', classifications.last.text
  end

  test "list matching concepts for the respective document" do
    visit document_path(id: @documents[1], lang: 'de')

    assert page.has_css? 'ol li', 3
  end

  test "reclassify document" do
    login 'administrator'

    visit document_path(id: @documents[0].id, format: 'html', lang: 'de')
    assert page.has_css?('ol li', count: 0)

    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("lorem")]
    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("dolor")]

    click_button 'Klassifizierung neu berechnen'
    assert page.has_content?("Dokument wurde erfolgreich aktualisiert.")
    visit document_path(id: @documents[0].id, format: 'html', lang: 'de')
    assert page.has_css?('ol li', count: 2)
  end

  test "turtle rdf representation" do
    id = @documents[1].id

    visit document_path(id: id, lang: 'de', format: 'ttl')

    ttl = page.body.gsub(/^ +/, "\t") # simplifies testing

    assert ttl.include? "@prefix sdc: <http://sindice.com/vocab/search#>."
    assert ttl.include? "<http://www.example.com/de/documents/#{id}> a sdc:Query;"
    refute ttl.include? "sdc:result search:result0;"

    assert ttl.include? "sdc:result search:result1;"
    expected = <<-EOS
      search:result1 a sdc:Result;
      \tsdc:link :foo;
      \tdct:title "Foo";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected

    assert ttl.include? "sdc:result search:result2;"
    expected = <<-EOS
      search:result2 a sdc:Result;
      \tsdc:link :bar;
      \tdct:title "Bar";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected

    assert ttl.include? "sdc:result search:result3."
    expected = <<-EOS
      search:result3 a sdc:Result;
      \tsdc:link :baz;
      \tdct:title "Baz";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected
  end

  test "XML/RDF representation" do
    id = @documents[1].id
    visit document_path(id: id, lang: 'de', format: 'rdf')

    assert page.body.include? %{<rdf:Description rdf:about="http://www.example.com/de/documents/#{id}">}
    assert page.body.include? %{<rdf:type rdf:resource="http://sindice.com/vocab/search#Query"/>}
    refute page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result0"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result1"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result2"/>}
    assert page.body.include? %{<sdc:result rdf:resource="http://www.example.com/de/documents/#{id}#result3"/>}
  end

end
