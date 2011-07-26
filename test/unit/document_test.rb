# encoding: UTF-8

require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  test "ensures content is supplied" do
    doc = Document.new
    doc.save

    assert_equal 0, Document.count
    assert_equal 1, doc.errors.length
  end

end
