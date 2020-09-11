require 'responders'

class DocumentsController < ApplicationController
  respond_to :html, :rdf, :ttl

  def index
    @documents = Document::Base.includes(:classifications)
                               .order('updated_at DESC')
                               .page(params[:page])

    respond_with @documents
  end

  def show
    get_document
  end

  def new
    @document = Document::Base.new
  end

  def update
    if params[:reclassify]
      get_document

      @document.reclassify!

      flash[:success] = I18n.t('txt.controllers.documents.update.success')
      redirect_to document_path(id: @document)
    else
      flash[:error] = I18n.t('txt.controllers.documents.update.invalid')
      render :show, status: 400
    end
  end

  def destroy
    get_document

    # FIXME: use custom cancan ability
    authorize! :use, :administration

    if @document.destroy
      flash[:success] = I18n.t('txt.controllers.documents.index.delete_success')
    else
      flash[:error] = I18n.t('txt.controllers.documents.index.delete_error')
    end

    redirect_to documents_path
  end

  protected
  def get_document
    @document = Document::Base.includes(:classifications)
                              .find_by!(id: params[:id])

    @classifications = @document.classifications.select { |c| c.concept.present? }
  end
end
