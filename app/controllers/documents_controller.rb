require 'responders'

class DocumentsController < ApplicationController
  respond_to :html, :rdf, :ttl

  before_action :load_document, only: [:show, :edit, :update, :destroy]

  def index
    @documents = Document::Base.includes(:classifications)
                               .order('updated_at DESC')
                               .page(params[:page])

    respond_with @documents
  end

  def show
    render_compare_show if request.format.html? && @document.is_a?(Document::Compare::Plain)
  end

  def new
    @document = Document::Base.new(language: Iqvoc::Concept.pref_labeling_languages.first.to_s)
  end

  def edit
    authorize! :use, :administration
    # FIXME: use custom cancan ability
  end

  def update
    authorize! :use, :administration
    # FIXME: use custom cancan ability

    @document.update(document_params)

    if @document.save
      @document.reclassify!

      flash[:success] = I18n.t('txt.controllers.documents.update.success')
      redirect_to document_path(id: @document)
    else
      flash[:error] = I18n.t('txt.controllers.documents.update.invalid')
      if @document.is_a?(Document::Compare::Plain)
        render_compare_show(status: 400)
      else
        render :show, status: 400
      end
    end
  end

  def destroy
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

  def render_compare_show(status: nil)
    render 'documents/compare/plain/show', status: status
  end

  def load_document
    @document = Document::Base.includes(:classifications)
                              .find_by!(id: params[:id])

    @classifications = @document.classifications.select { |c| c.concept.present? }
  end

  def document_params
    if params[:document]
      # form request
      params.require(:document).permit(:title, :content, :language, *Document::Base::BOOLEAN_OPTIONS)
    else
      # api request
      params.permit(:title, :content, :language, *Document::Base::BOOLEAN_OPTIONS)
    end
  end
end
