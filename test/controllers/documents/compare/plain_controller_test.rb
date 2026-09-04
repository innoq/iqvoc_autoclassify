# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../../test_helper')
require 'authlogic/test_case'

class Documents::Compare::PlainControllerTest < ActionController::TestCase
  include Authlogic::TestCase

  setup do
    @original_service_uri = ENV['AUTOCLASSIFY_SERVICE_URI']
    ENV['AUTOCLASSIFY_SERVICE_URI'] = 'http://sns-autoclassify.test'
    Rails.application.reload_routes!

    @original_base_url = AutoclassifyApiService::BASE_URL
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, 'http://sns-autoclassify.test')

    data = Maker.from_yaml <<-EOF
      labels:
      -
        value: Weltraum

      concepts:
      -
        pref_labels: [Weltraum]
    EOF
    @concept = data[:concepts]['Weltraum']

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

  teardown do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, @original_base_url)

    ENV['AUTOCLASSIFY_SERVICE_URI'] = @original_service_uri
    Rails.application.reload_routes!
  end

  test 'admin gets both engines results when sns-autoclassify responds' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { results: [{ uri: "http://sns.uba.de/umthes/de/#{@concept.origin}", score: 0.9, pref_label: 'Weltraum' }] }.to_json
    )

    session = UserSession.create(@admin)

    post :create, params: {
      document: { content: 'der Weltraum' },
      lang: 'de'
    }

    document = assigns(:document)
    assert document.is_a?(Document::Compare::Plain)
    refute document.comparison_unavailable?
    assert_equal 1, document.classifications.count
    assert_equal 1, document.comparison_results.length

    session.destroy
  end

  test 'admin still gets classic results with a notice when sns-autoclassify fails' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(status: 500)

    session = UserSession.create(@admin)

    post :create, params: {
      document: { content: 'der Weltraum' },
      lang: 'de'
    }

    document = assigns(:document)
    assert_redirected_to document_path(document, lang: 'de')
    assert document.comparison_unavailable?
    assert_equal 1, document.classifications.count

    session.destroy
  end

  test 'admin can still classify classically when sns-autoclassify is not configured' do
    AutoclassifyApiService.send(:remove_const, :BASE_URL)
    AutoclassifyApiService.const_set(:BASE_URL, nil)

    session = UserSession.create(@admin)

    post :create, params: {
      document: { content: 'der Weltraum' },
      lang: 'de'
    }

    document = assigns(:document)
    assert_redirected_to document_path(document, lang: 'de')
    assert document.comparison_unavailable?
    assert_equal 1, document.classifications.count
    assert_not_requested :post, 'http://sns-autoclassify.test/autoclassify/content'

    session.destroy
  end

  test 'rejects submission without administration rights' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(status: 200, body: { results: [] }.to_json)

    post :create, params: {
      document: { content: 'der Weltraum' },
      lang: 'de'
    }

    assert_response 401
    assert_not_requested :post, 'http://sns-autoclassify.test/autoclassify/content'
  end

  test 'rejects submission for a non-administrator user' do
    stub_request(:post, 'http://sns-autoclassify.test/autoclassify/content').to_return(status: 200, body: { results: [] }.to_json)

    reader = User.create! do |u|
      u.forename = 'Reader'
      u.surname = 'User'
      u.email = 'reader@iqvoc'
      u.password = 'omgomgomg'
      u.password_confirmation = 'omgomgomg'
      u.role = 'reader'
      u.active = true
    end
    session = UserSession.create(reader)

    post :create, params: {
      document: { content: 'der Weltraum' },
      lang: 'de'
    }

    assert_response 403
    assert_not_requested :post, 'http://sns-autoclassify.test/autoclassify/content'

    session.destroy
  end

end
