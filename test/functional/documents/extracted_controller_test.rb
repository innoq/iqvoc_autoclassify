# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'fake_web'

class Documents::ExtractedControllerTest < ActionController::TestCase
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
    ].map do |text|
      make_document(:content => text)
    end

    @urls = {
      :service => "http://example.org/service.pdf",
      :html => "http://example.org/sample.html",
      :huge => "http://example.org/huge.pdf",
      :not_found => "http://example.org/not_found",
      :unsupported_content_type => "http://example.org/unsupported.zip"
    }

    FakeWeb.register_uri :get, @urls[:service],
      :body => "test/fixtures/service.pdf",
      :content_type => "application/pdf"

    FakeWeb.register_uri :get, @urls[:html],
      :body => "test/fixtures/sample.html",
      :content_type => "text/html"

    FakeWeb.register_uri :get, @urls[:huge],
      :body => "test/fixtures/huge.pdf",
      :content_type => "application/pdf",
      :content_length => 751945

    FakeWeb.register_uri :get, @urls[:not_found],
      :body => "Nothing here",
      :status => ["404", "Not Found"]

    FakeWeb.register_uri :get, @urls[:unsupported_content_type],
      :body => "test/fixtures/unsupported.pdf",
      :content_type => "application/zip"
  end

  test "classify html via uri" do
    assert_no_difference "Document::Extracted.count" do
      post :create, :uri => @urls[:html], :format => 'rdf'
    end
    assert_not_nil assigns(:document)
    assert_response 200
    assert_equal 'application/xml+rdf', response.content_type
  end

  test "classify pdf via uri" do
    assert_no_difference "Document::Extracted.count" do
      post :create, :uri => @urls[:service], :format => 'rdf'
    end
    assert_not_nil assigns(:document)
    assert_response 200
    assert_equal 'application/xml+rdf', response.content_type
  end

  test "classify and persist via uri" do
    assert_difference "Document::Extracted.count" do
      post :create, :uri => @urls[:html], :format => 'rdf', :commit => "1"
    end
  end

  test "refuse large documents" do
    post :create, :uri => @urls[:huge], :format => 'rdf'
    assert_response 413
    assert_equal 'application/xml+rdf', response.content_type
  end

  test "extraction errors" do
    post :create, :uri => @urls[:not_found], :format => 'rdf'
    assert_response 422

    post :create, :uri => @urls[:unsupported_content_type], :format => 'rdf'
    assert_response 422
  end
end
