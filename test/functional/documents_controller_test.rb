# encoding: UTF-8

require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  setup do
    make_from_yaml <<-EOF
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

    @documents = [
      "lorem ipsum\ndolor sit amet",
      "lorem Foo ipsum\ndolor Bar sit Baz amet"
    ].map { |text|
      doc = Document.make!(:content => text)
    }
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
    # TODO
  end

end
