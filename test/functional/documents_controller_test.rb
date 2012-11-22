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
        pref_labels: [Foo]
      -
        pref_labels: [Bar]
      -
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
      "html" => "http://example.org/sample.html",
      "huge" => "http://example.org/huge.pdf"
    }
    FakeWeb.register_uri(:get, @urls["pdf"], :body => "test/fixtures/sample.pdf",
        :content_type => "application/pdf")
    FakeWeb.register_uri(:get, @urls["html"], :body => "test/fixtures/sample.html")
    FakeWeb.register_uri(:get, @urls["huge"], :body => "test/fixtures/huge.pdf",
        :content_type => "application/pdf", :content_length => 512001)
  end

  test "list documents at index" do
    get :index, :format => :html

    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select "table tbody" do
      assert_select "tr", 2
    end
    assert_select "tbody tr:nth-of-type(1) td:nth-of-type(3)", "3"
    assert_select "tbody tr:nth-of-type(2) a[href=/de/documents/d0d2efdf0c05081e2c3ae386215483329a653cfd.html]", 1
    assert_select "tbody tr:nth-of-type(2) td:nth-of-type(3)", "0"
  end

  test "list matching concepts for the respective document" do
    get :show, :id => @documents[1].content_hash, :format => :html

    assert_response :success
    assert_select "ol li", 3
  end

  test "create document from raw content" do
    assert_difference("Document.count") do
      post :create, :document => { :content => "lorem ipsum" }
    end

    assert_redirected_to document_path(assigns(:document), :lang => "de")
  end

  test "create document from URL (HTML)" do
    assert_difference("Document.count") do
      post :create, :url => @urls["html"], :document => { :content => "" }
    end

    assert_redirected_to document_path(assigns(:document), :lang => "de")

    id = response.headers["Location"].split("/").last.sub(/.html$/, "")
    get :show, :id => id, :lang => "de", :format => :html

    assert_select "a[href=#{@urls["html"]}]", 1
    assert_select "h1", /Lipsum/
    assert_select "ol li", 3
  end

  test "create document from URL (PDF)" do
    assert_difference("Document.count") do
      post :create, :url => @urls["pdf"], :document => { :content => "" }
    end

    assert_redirected_to document_path(assigns(:document), :lang => "de")

    id = response.headers["Location"].split("/").last.sub(/.html$/, "")
    get :show, :id => id, :lang => "de", :format => :html

    assert_select "a[href=#{@urls["pdf"]}]", 1
    assert_select "h1", /\(Unsaved Publication\)/
    assert_select "blockquote", {
        :text => "This is a sample PDF file.If you can read this,you already " +
            "have Adobe AcrobatReader installed on your computer." }
  end

  test "refuse excessively large documents" do
    post :create, :url => @urls["huge"]

    assert_response 413
  end

  test "reclassify document" do
    get :show, :id => @documents[0].content_hash, :format => :html
    assert_response :success
    assert_select "ol li", 0

    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("lorem")]
    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("dolor")]

    post :update, :id => @documents[0].content_hash, :reclassify => "1"
    assert_redirected_to document_path(assigns(:document), :lang => "de")
    assert_equal "Dokument wurde erfolgreich aktualisiert.", flash[:notice]

    get :show, :id => @documents[0].content_hash, :format => :html
    assert_select "ol li", 2
  end

  test "Turtle RDF representation" do
    id = @documents[1].content_hash

    get :show, :id => id, :format => :ttl

    ttl = response.body.gsub(/^ +/, "\t") # simplifies testing
    assert_response :success
    assert ttl.include? "@prefix sdc: <http://sindice.com/vocab/search#>."
    assert ttl.include? "<http://#{request.host}/de/documents/#{id}> a sdc:Query;"
    assert (not ttl.include? "sdc:result search:result0;")

    assert ttl.include? "sdc:result search:result1;"
    expected = <<-EOS
      search:result1 a sdc:Result;
      \tsdc:link :http://localhost/de/concepts/_00000001;
      \tdct:title "Foo";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected

    assert ttl.include? "sdc:result search:result2;"
    expected = <<-EOS
      search:result2 a sdc:Result;
      \tsdc:link :http://localhost/de/concepts/_00000002;
      \tdct:title "Bar";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected

    assert ttl.include? "sdc:result search:result3."
    expected = <<-EOS
      search:result3 a sdc:Result;
      \tsdc:link :http://localhost/de/concepts/_00000003;
      \tdct:title "Baz";
      \tsdc:rank 1.0.
    EOS
    expected.gsub!(/^ +/, "")
    assert ttl.include? expected
  end

  test "XML/RDF representation" do
    id = @documents[1].content_hash

    get :show, :id => id, :format => :rdf

    host = "http://#{request.host}"
    assert_response :success
    assert response.body.include? %{<rdf:Description rdf:about="#{host}/de/documents/#{id}">}
    assert response.body.include? %{<rdf:type rdf:resource="http://sindice.com/vocab/search#Query"/>}
    assert (not response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result0"/>})
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result1"/>}
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result2"/>}
    assert response.body.include? %{<sdc:result rdf:resource="#{host}/de/documents/#{id}#result3"/>}
  end

end
