class DocumentsController < ApplicationController
  respond_to :html, :rdf, :ttl

  def index
    @documents = Document::Base.order("updated_at DESC").page(params[:page])
    respond_with @documents
  end

  def show
    get_document

    if params[:trace]
      @trace = true
      @classifications = @classifications.per(100)
    end
  end

  def new
    @document = Document::Base.new
  end

  def update
    if params[:reclassify]
      get_document

      @document.reclassify!

      flash[:notice] = I18n.t("txt.controllers.documents.update.success")
      redirect_to document_path(:id => @document)
    else
      flash[:error] = I18n.t("txt.controllers.documents.update.invalid")
      render :show, :status => 400
    end
  end

  protected

  def get_document
    @document = Document::Base.find(params[:id], :include => :classifications)
    @document.url_info = { # required for classifications' concept URLs
      :host => request.host_with_port,
      :lang => I18n.locale
    }
    @classifications = @document.classifications.order("weighting DESC").page(params[:page])
  end
end
