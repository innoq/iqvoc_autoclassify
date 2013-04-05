class CommentsController < ApplicationController

  def create
    document = Document::Base.find(params[:document_id])
    document.comments.create(:body => params[:comment][:body],
        :user => current_user)
    redirect_to document_path(:id => document),
        :success => I18n.t("txt.controllers.comments.save.success")
  end

end
