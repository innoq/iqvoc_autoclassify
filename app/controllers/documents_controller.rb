class DocumentsController < ActionController::Base  
  respond_to :json
  
  def show
    document = Document.find(params[:id])
    respond_with document
  end
  
  def create
    # TBD
    # A production API should restrict the amount of requests coming from the same IP
    
    text = if params[:uri]
      # TBD
      # Parse URI and extract main content
    else
      params[:content]
    end
    
    parsed_document = DocumentParser::Base.new(text)
    document = Document.new(:content => text)
    # TBD
    # Handle creation of classification association records
    # Waiting for FND to expose an API method
    
    if document.save
      respond_with @document, :location => document_path(:id => document)
    else
      respond_with @document.errors.full_messages, :status => 400
    end
  end
  
end
