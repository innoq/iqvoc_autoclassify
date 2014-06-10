class Documents::ExtractedController < DocumentsController
  resource_description { name 'AutoClassify URI' }

  api :GET, ':lang/autoclassify/extract', <<-DOC
    Returns the most significant concepts for a given document URL.
  DOC
  formats [:html, :ttl, :rdf]
  param :uri, String, :required => true, :desc => <<-DOC
    HTTP URI reference of the document to be processed, needs to be escaped.
    Content type may be HTML or PDF.
  DOC
  example <<-DOC
    GET /de/autoclassify/extract.ttl?uri=http%3A%2F%2Fwww.spiegel.de
    200

    # omitted namespace definitions
    <http://umthes.innoq.com/de/autoclassify/extract?uri=http%3A%2F%2Fwww.spiegel.de> a sdc:Query;
                                                                                sdc:totalResults 2;
                                                                                sdc:result search:result1;
                                                                                sdc:result search:result2.
    search:result1 a sdc:Result;
                   sdc:link :_00048961;
                   dct:title "Internet";
                   sdc:rank 1.0.
    search:result2 a sdc:Result;
                   sdc:link :_00100204;
                   dct:title "Europa";
                   sdc:rank 1.0.
  DOC

  def create
    @document = Document::Extracted.new(:uri => params[:uri])
    @document.persist = true if params[:commit]

    render_errors and return if @document.invalid?
    @document.save if @document.persist?

    @document.extract!
    render_errors and return if @document.halted?

    @document.classify!
    render_errors and return if @document.halted?

    respond_to do |format|
      format.html { redirect_to document_path(:id => @document) }
      format.any(:rdf, :ttl) { render :show }
    end
  end

  protected

  def error_response
    {
      :response_limit_exceeded => 413, # XXX: s/response/request/ ?
      :http_error => 422,
      :unsupported_content_type => 422,
      :unprocessable_pdf => 422
    }
  end

  def render_errors
    messages = []

    if @document.halted? && @document.current_state < :extracted
      extraction_error_code = error_response[@document.halted_because]
      messages << t("txt.textractor.#{@document.halted_because}")
    end

    if @document.errors.any?
      messages << t('txt.controllers.documents.create.invalid')
    end

    respond_to do |format|
      format.html do
        flash[:error] = messages.join("\n")
        render :new
      end
      format.any(:rdf, :ttl) do
        if extraction_error_code
          render :text => messages.join("\n"), :status => extraction_error_code
        else
          render :text => messages.join("\n"), :status => 422
        end
      end
    end
  end
end
