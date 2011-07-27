class DocumentsController < ActionController::Base
  respond_to :html # TODO: JSON, RDF

  def index
    @documents = Document.all
    respond_with @documents
  end

  def show
    @document = Document.find_by_content_hash(params[:id],
        :include => :classifications)
    respond_with @document
  end

  def new
    @document = Document.new
  end

  def create # TODO: restrict the amount of requests from the same IP?
    doc = params[:document]
    if doc[:content]
      text = doc[:content]
    elsif doc[:uri]
      # TODO: extract content body from target resource
    else
      respond_with "missing content or URI reference", :status => 400 # TODO: phrasing, i18n
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

end
