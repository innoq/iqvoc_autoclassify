# encoding: UTF-8

require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  setup do
    @document = Document.make!(:content => "lorem ipsum\ndolor sit amet")
  end

  test "list documents at index" do
    get :index

    assert_response :success
    assert_not_nil assigns(:documents)
    assert_select "table" do
      assert_select "tr", 2
    end
    assert_select "tr:nth-of-type(2) a[href=/documents/1]", 1 # FIXME: use content hash as ID
  end

  test "list matching concepts for the respective document" do
    get :show, :id => @document

    assert_response :success
    assert_select "ol" do
      assert_select "li", 0
    end
  end

  test "create document from raw content" do
    assert_difference("Document.count") do
      post :create, :content => "lorem ipsum"
    end

    assert_redirected_to document_path(assigns(:document),
        :lang => @active_language)
  end

  test "create document from URL" do
    # TODO
  end

end
