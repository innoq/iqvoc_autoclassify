# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'authlogic/test_case'

class Documents::PlainControllerTest < ActionController::TestCase
  include Authlogic::TestCase

  setup do
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

  test 'create and persist document from raw content' do
    session = UserSession.create(@admin)

    assert_difference('Document::Plain.count') do
      post :create, params: {
        document: {
          content: 'lorem ipsum'
        },
        lang: 'de'
      }
    end

    assert_redirected_to document_path(assigns(:document), lang: 'de')

    session.destroy
  end

  test 'create document from raw content' do
    assert_no_difference('Document::Plain.count') do
      post :create, params: {
        document: {
          content: 'lorem ipsum'
        },
        lang: 'de'
      }
    end

    assert_response 200
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
        content: 'my text'
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
        content: 'my text'
      }
      assert_response :success

      post :create, params: {
        lang: 'de',
        format: format,
        document: {
          content: 'my text'
        }
      }
      assert_response :success
    end
  end

  test 'respond with bad request on missing content parameter' do
    %w[ttl nt rdf json].each do |format|
      post :create, params: {
        lang: 'de',
        format: format
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document: {
          xcontent: 'my text'
        }
      }
      assert_response :bad_request
    end
  end

  test 'respond with bad request on empty content parameter' do
    %w[ttl nt rdf json].each do |format|
      post :create, params: {
        lang: 'de',
        format: format,
        content: '',
      }
      assert_response :bad_request

      post :create, params: {
        lang: 'de',
        format: format,
        document: {
          content: ''
        }
      }
      assert_response :bad_request
    end
  end
end
