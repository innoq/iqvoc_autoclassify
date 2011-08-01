# encoding: UTF-8

require 'test_helper'
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

    @url = "http://example.org"
    FakeWeb.register_uri(:get, @url, :body => "test/fixtures/sample.html")
  end

  test "list documents at index" do
    get :index

    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select "table" do
      assert_select "tr", 3
    end
    assert_select "tr:nth-of-type(2) a[href=/de/documents/d0d2efdf0c05081e2c3ae386215483329a653cfd]", 1
    assert_select "tr:nth-of-type(3) td:nth-of-type(3)", "3"
  end

  test "list matching concepts for the respective document" do
    get :show, :id => @documents[1].content_hash

    assert_response :success
    assert_select "ol li", 3
  end

  test "create document from raw content" do
    assert_difference("Document.count") do
      post :create, :document => { :content => "lorem ipsum" }
    end

    assert_redirected_to document_path(assigns(:document),
        :lang => I18n.locale)
  end

  test "create document from URL" do
    assert_difference("Document.count") do
      post :create, :document => { :url => @url }
    end

    assert_redirected_to document_path(assigns(:document),
        :lang => I18n.locale)

    get :show, :id => response.headers["Location"].split("/").last

    assert_select "ol li", 3
  end

  test "reclassify document" do
    get :show, :id => @documents[0].content_hash
    assert_response :success
    assert_select "ol li", 0

    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("lorem")]
    Iqvoc::Maker.concept :pref_labels => [Iqvoc::Maker.label("dolor")]

    post :update, :id => @documents[0].content_hash, :reclassify => "1"
    assert_redirected_to document_path(assigns(:document),
        :lang => I18n.locale)
    assert_equal "Document was successfully reclassified.", flash[:notice]

    get :show, :id => @documents[0].content_hash
    assert_select "ol li", 2
  end

  test "Turtle RDF representation" do
    id = @documents[1].content_hash

    get :show, :id => id, :format => :ttl

    assert_response :success
    assert response.body.include? "@prefix sdc: <http://sindice.com/vocab/search#>."
    assert response.body.include? "<http://#{request.host}/documents/#{id}> a sdc:Query;"
    @concepts.each { |identifier, concept|
      assert response.body.include? "sdc:result rdf:http://localhost/de/concepts/#{concept.origin}"
    }
  end

  test "XML/RDF representation" do
    id = @documents[1].content_hash

    get :show, :id => id, :format => :rdf

    host = "http://#{request.host}"
    assert_response :success
    assert response.body.include? %{<rdf:Description rdf:about="#{host}/documents/#{id}">}
    assert response.body.include? %{<rdf:type rdf:resource="http://sindice.com/vocab/search#Query"/>}
    @concepts.each { |identifier, concept|
      assert response.body.include? %{<sdc:result rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#http://localhost/de/concepts/#{concept.origin}"/>}
    }
  end

end
