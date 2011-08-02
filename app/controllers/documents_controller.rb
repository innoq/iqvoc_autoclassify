require 'textractor'

class DocumentsController < ActionController::Base # TODO: auth restrictions?
  respond_to :html # TODO: JSON, RDF

  def index
    @documents = Document.all
    respond_with @documents
  end

  def show
    @document = Document.find_by_content_hash(params[:id],
        :include => :classifications)

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
    if content && content.strip.length > 0
      text = content
    elsif params[:url]
      text = Textractor.extract(params[:url])
    else
      render :text => "missing content or URI reference", :status => 400 # TODO: phrasing, i18n
    end

    @document = Document.new(:content => text)
    @document.url_info = { # required for classifications' concept URLs
      :host => request.host_with_port,
      :lang => I18n.locale
    }

    if @document.save
      respond_with @document, :location => document_path(:id => @document,
          :lang => I18n.locale)
    else
      respond_with @document.errors.full_messages, :status => 400
    end
  end

  def edit
    @document = Document.find_by_content_hash(params[:id],
        :include => :classifications)
  end

  def update
    if params[:reclassify]
      @document = Document.find_by_content_hash(params[:id])
      @document.url_info = { # required for classifications' concept URLs
        :host => request.host_with_port,
        :lang => I18n.locale
      }
      @document.save!

      flash[:notice] = "Document was successfully reclassified." # TODO: phrasing, i18n
      redirect_to document_path(:id => @document, :lang => I18n.locale)
    else
      render :text => "missing reclassify flag", :status => 400 # TODO: phrasing, i18n
    end
  end

end
