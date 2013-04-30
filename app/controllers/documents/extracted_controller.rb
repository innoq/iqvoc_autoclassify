class Documents::ExtractedController < DocumentsController
  def create
    @document = Document::Extracted.new(:uri => params[:uri])
    @document.persist = true if params[:commit]
    @document.url_info = {
      :host => request.host_with_port,
      :lang => I18n.locale
    }

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
      :unsupported_content_type => 422
    }
  end

  def render_errors
    messages = []

    if @document.halted? && @document.current_state < :extracted
      extraction_error_code = error_response[@document.halted_because]
      messages << t("txt.textractor.#{@document.halted_because}")
    end

    if @document.errors.any?
      messages << t("txt.controllers.documents.create.invalid")
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
