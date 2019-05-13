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

    if params[:trace] && current_user
      @trace = true
      @classifications = @classifications.per(100)
    end
  end

  def new
    @document = Document::Base.new
  end

  def new_classification
  end

  def create_classification
  end

  def delete_classification
    deleting_classification = Classification.find(params[:classification_id])
    classifications = Classification.where("document_id = ? AND `rank` > ?", params[:id], deleting_classification.rank)
    Classification.transaction do
      deleting_classification.destroy
      classifications.each do |c|
        c.update rank: c.rank - 1
      end
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.delete_success')
    redirect_to document_path(deleting_classification.document_id)
  end

  def promote_classification
    promoting_classification = Classification.find(params[:classification_id])
    demoting_classification = Classification.find_by(document_id: params[:id], rank: promoting_classification.rank - 1)
    Classification.transaction do
      promoting_classification.update rank: demoting_classification.rank
      demoting_classification.update rank: demoting_classification.rank + 1
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.promote_success')
    redirect_to document_path(promoting_classification.document_id)
  end

  def demote_classification
    demoting_classification = Classification.find(params[:classification_id])
    promoting_classification = Classification.find_by(document_id: params[:id], rank: demoting_classification.rank + 1)
    Classification.transaction do
      promoting_classification.update rank: demoting_classification.rank
      demoting_classification.update rank: demoting_classification.rank + 1
    end
    flash[:success] = I18n.t('txt.controllers.documents.classifications.demote_success')
    redirect_to document_path(promoting_classification.document_id)
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

    @classifications = @document.classifications
                                .reorder(:rank)
                                .page(params[:page])
  end
end
