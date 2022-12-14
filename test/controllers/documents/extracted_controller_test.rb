# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'fake_web'

class Documents::ExtractedControllerTest < ActionController::TestCase
  require 'authlogic/test_case'

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
      make_document(content: text)
    end

    @urls = {
      service: 'http://example.org/service.pdf',
      html: 'http://example.org/sample.html',
      big: 'http://example.org/sample.pdf',
      not_found: 'http://example.org/not_found',
      unsupported_content_type: 'http://example.org/unsupported.zip',
      redirected: 'http://example.org/redirected',
    }

    FakeWeb.register_uri :get, @urls[:service],
      body: 'test/fixtures/service.pdf',
      content_type: 'application/pdf'

    FakeWeb.register_uri :get, @urls[:html],
      body: 'test/fixtures/sample.html',
      content_type: 'text/html'

    FakeWeb.register_uri :get, @urls[:big],
      body: 'test/fixtures/sample.pdf',
      content_type: 'application/pdf',
      content_length: 751945

    FakeWeb.register_uri :get, @urls[:not_found],
      body: 'Nothing here',
      status: ['404', 'Not Found']

    FakeWeb.register_uri :get, @urls[:unsupported_content_type],
      body: 'test/fixtures/unsupported.pdf',
      content_type: 'application/zip'

    FakeWeb.register_uri :get, @urls[:redirected],
                         status:   ['301', 'Moved Permanently'],
                         location: @urls[:html]

    activate_authlogic

    @admin = User.create! do |u|
      u.forename = 'Test'
      u.surname = 'User'
      u.email = 'admin@iqvoc'
      u.password = 'omgomgomg'
      u.password_confirmation = 'omgomgomg'
      u.role = 'administrator'
      u.active = true
    end
  end

  test 'classify html via uri' do
    assert_no_difference 'Document::Extracted.count' do
      post :create, params: {
        uri: @urls[:html],
        format: 'rdf',
        lang: 'de'
      }
    end
    assert_not_nil assigns(:document)
    assert_response 200
    assert_equal 'application/rdf+xml; charset=utf-8', response.content_type
  end

  test 'classify pdf via uri' do
    assert_no_difference 'Document::Extracted.count' do
      post :create, params: {
        uri: @urls[:service],
        format: 'rdf',
        lang: 'de'
      }
    end
    assert_not_nil assigns(:document)
    assert_response 200
    assert_equal 'application/rdf+xml; charset=utf-8', response.content_type
  end

  test 'classify and persist via uri' do
    session = UserSession.create(@admin)

    assert_difference 'Document::Extracted.count' do
      post :create, params: {
        uri: @urls[:html],
        format: 'rdf',
        lang: 'de'
      }
    end

    session.destroy
  end

  # XXX: disabled due to inability to provoke timeouts
  #test "timeout handling" do
  #  post :create, :uri => @urls[:big], :format => 'rdf', :lang => "de"
  #  assert_response 504
  #  assert_equal 'application/rdf+xml; charset=utf-8', response.content_type
  #end

  test 'extraction errors' do
    post :create, params: {
      uri: @urls[:not_found],
      format: 'rdf',
      lang: 'de'
    }
    assert_response 422

    post :create, params: {
      uri: @urls[:unsupported_content_type],
      format: 'rdf',
      lang: 'de'
    }
    assert_response 422
  end

  test 'follow redirects, classify html and persist via uri' do
    session = UserSession.create(@admin)

    assert_difference 'Document::Extracted.count' do
      post :create, params: {
        uri: @urls[:redirected],
        format: 'rdf',
        commit: '1',
        lang: 'de'
      }
    end
    assert_not_nil assigns(:document)
    assert_response :success
    assert_equal 'application/rdf+xml; charset=utf-8', response.content_type

    session.destroy
  end

  test 'ttl, ntriples, rdfxml and json support' do
    mimes = [
      {accept: 'ttl', content_type: 'text/turtle; charset=utf-8'},
      {accept: 'nt', content_type: 'application/n-triples; charset=utf-8'},
      {accept: 'rdf', content_type: 'application/rdf+xml; charset=utf-8'},
      {accept: 'json', content_type: 'application/json; charset=utf-8'},
    ]

    mimes.each do |mime|
      post :create, params: {
        lang: 'de',
        format: mime[:accept],
        uri: @urls[:html]
      }

      assert_response :success
      assert_equal mime[:content_type], response.content_type
    end
  end

  test 'flat and nested documents params' do
    %w[ttl nt rdf json].each do |format|
      post :create, params: {
        lang: 'de',
        format: format,
        uri: @urls[:html]
      }
      assert_response :success

      post :create, params: {
        lang: 'de',
        format: format,
        document_base: {
          uri: @urls[:html]
        }
      }
      assert_response :success

      post :create, params: {
        lang: 'de',
        format: format,
        document_extracted: {
          uri: @urls[:html]
        }
      }
      assert_response :success
    end
  end

  test 'respond with bad request on missing uri parameter' do
    %w[ttl nt rdf json].each do |format|
      post :create, params: {
        lang: 'de',
        format: format,
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document_base: {
          xuri: 'my text'
        }
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document_extracted: {
          xuri: 'my text'
        }
      }
      assert_response :bad_request
    end
  end

  test 'respond with bad request on empty uri parameter' do
    %w[ttl nt rdf json].each do |format|
      post :create, params: {
        lang: 'de',
        format: format,
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document_base: {
          xuri: 'my text'
        }
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document_extracted: {
          xuri: 'my text'
        }
      }
      assert_response :bad_request
    end
  end
end
