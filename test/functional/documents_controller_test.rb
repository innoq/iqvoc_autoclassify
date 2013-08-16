# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'fake_web'

class DocumentsControllerTest < ActionController::TestCase

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
    ].map { |text|
      make_document(:content => text)
    }

    @urls = {
      "pdf" => "http://example.org/sample.pdf",
      "html" => "http://example.org/sample.html"
    }
    FakeWeb.register_uri(:get, @urls["pdf"], :body => "test/fixtures/sample.pdf",
        :content_type => "application/pdf")
    FakeWeb.register_uri(:get, @urls["html"], :body => "test/fixtures/sample.html")
  end

  test "list documents at index" do
    get :index, :format => :html, :lang => "de"

    assert_response 200
    assert_not_nil assigns(:documents)
    assert_select "table tbody" do
      assert_select "tr", 2
    end
    # FIXME: the following assertions are currently unconfirmed
    assert_select "tbody tr:nth-of-type(1) td:nth-of-type(3)", "3"
    assert_select "tbody tr:nth-of-type(1) a", 1
    assert_select "tbody tr:nth-of-type(2) td:nth-of-type(3)", "0"
  end

  test "list matching concepts for the respective document" do
    get :show, :id => @documents[1].id, :format => :html, :lang => "de"

    assert_response 200
    assert_select "ol li", 3
  end

  test "reclassify document" do
    get :show, :id => @documents[0].id, :format => :html, :lang => "de"
    assert_response 200
    assert_select "ol li", 0

    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("lorem")]
    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("dolor")]

    post :update, :id => @documents[0].id, :reclassify => "1", :lang => "de"
    assert_redirected_to document_path(assigns(:document), :lang => "de")
    assert_equal "Dokument wurde erfolgreich aktualisiert.", flash[:notice]

    get :show, :id => @documents[0].id, :format => :html, :lang => "de"
    assert_select "ol li", 2
  end

  test "turtle rdf representation" do
    id = @documents[1].id

    get :show, :id => id, :format => :ttl, :lang => "de"

    ttl = response.body.gsub(/^ +/, "\t") # simplifies testing
    assert_response 200
    assert ttl.include? "@prefix sdc: <http://sindice.com/vocab/search#>."
    assert ttl.include? "<http://#{request.host}/de/documents/#{id}> a sdc:Query;"
    assert (not ttl.include? "sdc:result search:result0;")

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

    get :show, :id => id, :format => :rdf, :lang => "de"

    host = "http://#{request.host}"
    assert_response 200
    assert response.body.include? %{<rdf:Description rdf:about="#{host}/de/documents/#{id}">}
    assert response.body.include? %{<rdf:type rdf:resource="http://sindice.com/vocab/search#Query"/>}
    assert (not response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result0"/>})
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result1"/>}
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result2"/>}
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result3"/>}
  end

end
