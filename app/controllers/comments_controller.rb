class CommentsController < ApplicationController

  def create
    document = Document.find_by_content_hash(params[:document_id])
    document.comments.create(:body => params[:comment][:body],
        :user => current_user)
    redirect_to document_path(:id => document),
        :notice => 'Comment was successfully created.' # TODO: i18n
  end

end
