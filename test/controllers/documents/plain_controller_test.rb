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

    UserSession.create(@admin)
  end

  test 'create document from raw content' do
    assert_difference('Document::Plain.count') do
      post :create, document: { content: 'lorem ipsum' }, lang: 'de', commit: '1'
    end

    assert_redirected_to document_path(assigns(:document), lang: 'de')
  end
end
