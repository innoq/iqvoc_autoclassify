# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'fake_web'

class AutoclassifyControllerTest < ActionController::TestCase
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
      "service" => "http://example.org/service.pdf",
      "pdf" => "http://example.org/sample.pdf",
      "html" => "http://example.org/sample.html",
      "huge" => "http://example.org/huge.pdf"
    }

    @content = {
      "html" => File.open(File.join(File.expand_path(File.dirname(__FILE__)), '../fixtures/sample.html')).read,
      "text" => File.open(File.join(File.expand_path(File.dirname(__FILE__)), '../fixtures/sample.txt')).read
    }

    FakeWeb.register_uri :get, @urls["service"],
      :body => "test/fixtures/service.pdf",
      :content_type => "application/pdf"

    FakeWeb.register_uri :get, @urls["pdf"],
      :body => "test/fixtures/sample.pdf",
      :content_type => "application/pdf"

    FakeWeb.register_uri :get, @urls["html"],
      :body => "test/fixtures/sample.html",
      :content_type => "text/html"

    FakeWeb.register_uri :get, @urls["huge"],
      :body => "test/fixtures/huge.pdf",
      :content_type => "application/pdf",
      :content_length => 512001
  end

  test "create classification from uri html" do
    get :from_uri, :uri => @urls["html"], :format => 'rdf'
    assert_response 200
  end

  test "create classification from uri pdf" do
    get :from_uri, :uri => @urls["service"], :format => 'rdf'
    assert_response 200
  end

  test "refuse large documents" do
    get :from_uri, :uri => @urls["huge"], :format => 'rdf'
    assert_response 413
  end
end
