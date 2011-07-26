class DocumentsController < ActionController::Base
  respond_to :html

  def index
    @documents = Document.all
    respond_with @documents
  end

  def show
    @document = Document.find_by_content_hash(params[:id])
    respond_with @document
  end

  def create # TODO: restrict the amount of requests from the same IP?
    if params[:content]
      text = params[:content]
    elsif params[:uri]
      # TODO: extract content body from target resource
    else
      # TODO: error
    end

    @document = Document.new(:content => text)
    # TODO: calculate and store classification results

    if @document.save
      respond_with @document, :location => document_path(:id => @document,
          :lang => @active_language)
    else
      respond_with @document.errors.full_messages, :status => 400
    end
  end

end
