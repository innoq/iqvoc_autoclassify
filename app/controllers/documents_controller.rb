require 'textractor'

class DocumentsController < ApplicationController # TODO: auth restrictions?
  skip_before_filter :require_user

  respond_to :html # TODO: JSON, RDF

  def index
    @documents = Document.order("updated_at DESC").page(params[:page])
    respond_with @documents
  end

  def show
    @document = Document.find_by_content_hash(params[:id],
        :include => :classifications)
    raise ActiveRecord::RecordNotFound if not @document
    @classifications = @document.classifications.
        order("weighting DESC"). # XXX: redundant (cf. model)!?
        page(params[:page])

    respond_to do |format|
      format.html
      format.ttl { render("show.iqrdf") }
      format.rdf { render("show.iqrdf") }
    end
  end

  def new
    @document = Document.new
  end

  def create # TODO: restrict the amount of requests from the same IP?
    content = params[:document] ? params[:document][:content] : nil
    url = params[:url]
    if content && content.strip.length > 0
      title = nil # TODO: optional form field?
      text = content
      url = nil # disallow simultaneous occurrence of both content and URL
    elsif url
      begin
        title, text = Textractor.extract(url)
      rescue Textractor::ExcessiveSize => exception
        flash[:error] = I18n.t("txt.views.document.too_large")
        render "errors/blank", :status => 413
        return
      end
    else
      flash[:error] = I18n.t("txt.controllers.documents.create.invalid")
      render "errors/blank", :status => 400
      return
    end

    @document = Document.new(:title => title, :content => text, :uri => url)
    @document.url_info = { # required for classifications' concept URLs
      :host => request.host_with_port,
      :lang => I18n.locale
    }

    if @document.save
      respond_with @document, :location => document_path(:id => @document.content_hash)
    elsif @document.errors.has_key?(:content_hash) && @document.errors.keys.length == 1
      redirect_to document_path(:id => @document.content_hash)
    else
      respond_with @document.errors.full_messages, :status => 400
    end
  end

  def edit
    @document = Document.find_by_content_hash(params[:id],
        :include => :classifications)
    @classifications = @document.classifications.
        order("weighting DESC"). # XXX: redundant (cf. model)!?
        page(params[:page])
  end

  def update
    if params[:reclassify]
      @document = Document.find_by_content_hash(params[:id])
      @document.url_info = { # required for classifications' concept URLs
        :host => request.host_with_port,
        :lang => I18n.locale
      }
      @document.save!

      flash[:notice] = I18n.t("txt.controllers.documents.update.success")
      redirect_to document_path(:id => @document.content_hash)
    else
      flash[:error] = I18n.t("txt.controllers.documents.update.invalid")
      render "errors/blank", :status => 400
      return
    end
  end

end
