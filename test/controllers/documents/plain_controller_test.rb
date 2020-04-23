# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'fake_web'

class Documents::PlainControllerTest < ActionController::TestCase
  require 'authlogic/test_case'

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
end
