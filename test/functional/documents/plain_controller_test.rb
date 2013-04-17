# encoding: UTF-8

require File.join(File.expand_path(File.dirname(__FILE__)), '../../test_helper')
require 'fake_web'

class Documents::PlainControllerTest < ActionController::TestCase
  test "create document from raw content" do
    assert_difference("Document::Plain.count") do
      post :create, :document => { :content => "lorem ipsum" }, :lang => "de"
    end

    assert_redirected_to document_path(assigns(:document), :lang => "de")
  end
end
