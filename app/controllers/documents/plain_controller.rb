class Documents::PlainController < DocumentsController
  resource_description { name 'AutoClassify plain text' }

  api :POST, ':lang/autoclassify/plain', <<-DOC
    Returns the most significant concepts for a given document body.
  DOC
  formats [:html, :ttl, :rdf]
  param :content, String, :required => true, :desc => 'Plain text to be classified.'
  example <<-DOC
    curl -X POST --data "content=Abfallwirtschaft" http://umthes.innoq.com/de/autoclassify/plain.ttl
    200

    # omitted namespace definitions
    <http://umthes.innoq.com/de/autoclassify/plain> a sdc:Query;
                                                    sdc:totalResults 1;
                                                    sdc:result search:result1.
    search:result1 a sdc:Result;
                   sdc:link :_00000347;
                   dct:title "Abfallwirtschaft";
                   sdc:rank 1.0.
  DOC

  def create
    if params[:document]
      title = params[:document][:title]
      content = params[:document][:content]
    else
      title = params[:title]
      content = params[:content]
    end

    @document = Document::Plain.new do |doc|
      doc.title = title
      doc.content = content
    end

    @document.persist = false if params[:commit].blank?

    render_errors and return if @document.invalid?

    @document.classify!

    if @document.classified? && @document.errors.none?
      respond_to do |format|
        format.html { redirect_to document_path(:id => @document) }
        format.any(:rdf, :ttl) { render :show }
      end
    else
      render_errors
    end
  end

  protected
  def render_errors
    flash[:error] = t('txt.controllers.plain_documents.create.invalid')
    respond_to do |format|
      format.html { render :new }
      format.any(:rdf, :ttl) { render :text => flash[:error], :status => 422 }
    end
  end
end
