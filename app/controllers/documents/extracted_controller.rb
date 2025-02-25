class Documents::ExtractedController < DocumentsController
  resource_description { name 'AutoClassify URI' }

  api :GET, ':lang/autoclassify/extract{.html|.ttl|.rdf|.json}?uri=http://www.uri.de', <<-DOC
    Analyzes the content found at the given uri and returns its most significant matching concepts of the thesaurus.
  DOC
  param :uri, String, required: true, desc: <<-DOC
    HTTP URI reference of the document to be processed.
    Content type may be HTML or PDF.
  DOC
  example <<-DOC
    JSON
    ---------------
    curl https://sns.uba.de/umthes/de/autoclassify/extract.json?uri=https://www.umweltbundesamt.de

    {
      "url": "http://localhost:3000/de/autoclassify/extract.json?uri=https://www.umweltbundesamt.de",
      "total_results": 2,
      "results": [
        {
          "title": "Stickoxidemission",
          "link": "https://sns.uba.de/umthes/_e4ab78e3",
          "rank": 1.69
        },
        {
          "title": "Umwelt",
          "link": "https://sns.uba.de/umthes/_00025105",
          "rank": 1.5
        }
      ]
    }

    TURTLE/TTL
    ---------------
    curl https://sns.uba.de/umthes/de/autoclassify/extract.ttl?uri=https://www.umweltbundesamt.de

    # omitted namespace definitions
    <https://sns.uba.de/umthes/de/autoclassify/extract?uri=https://www.umweltbundesamt.de> a sdc:Query;
                                                                                            sdc:totalResults 2;
                                                                                            sdc:result search:result1;
                                                                                            sdc:result search:result2.

    search:result1 a sdc:Result;
                   sdc:link :_e4ab78e3;
                   dct:title "Stickoxidemission";
                   sdc:rank 1.69.
    search:result2 a sdc:Result;
                   sdc:link :_00025105;
                   dct:title "Umwelt";
                   sdc:rank 1.5.

    DOC

  def create
    @document = Document::Extracted.new document_params

    @document.persist = false unless current_user

    render_errors and return if @document.invalid?
    @document.save if @document.persist?

    @document.extract!
    render_errors and return if @document.halted?

    @document.classify!
    render_errors and return if @document.halted?

    if @document.classified? && @document.errors.none?
      respond_to do |format|
        format.html {
          if @document.persisted?
            flash[:success] = I18n.t('txt.controllers.documents.save.success')
            redirect_to document_path(id: @document)
          else
            render :show
          end
        }
        format.any(:rdf, :ttl, :nt) { render :show }
        format.json {
          render json: {
            "url": request.original_url,
            "total_results": @document.classifications.length,
            "results":
              @document.classifications
              .select { |classification| classification.concept }
              .map {|c|
                {
                "title": c.title,
                "link": rdf_url(id: c.concept_origin, lang: nil, only_path: false, format: nil),
                "rank": c.weighting
                }
              }
          }.to_json
        }
      end
    else
      render_errors
    end
  end

  protected

  def document_params
    if params[:document_base]
      # form request
      params.require(:document_base).permit(:uri, :language, :exclude_disabled_concepts)
    elsif params[:document_extracted]
      # FIXME: necessary?
      params.require(:document_extracted).permit(:uri, :language, :exclude_disabled_concepts)
    else
      # api request
      params.permit(:uri, :language, :exclude_disabled_concepts)
    end
  end

  def error_response
    {
      bad_request: 400,
      response_limit_exceeded: 413, # XXX: s/response/request/ ?
      http_error: 422,
      unsupported_content_type: 422,
      unprocessable_pdf: 422
    }
  end

  def render_errors
    messages = []

    if @document.halted? && @document.current_state < :extracted
      extraction_error_code = error_response[@document.halted_because]
      messages << t("txt.textractor.#{@document.halted_because}")
    end

    if @document.errors.any?
      extraction_error_code = error_response[:bad_request]
      messages << t('txt.controllers.documents.create.invalid')
    end

    respond_to do |format|
      format.html do
        flash[:error] = messages.join("\n")
        render :new
      end
      format.any(:rdf, :ttl, :nt, :json) do
        if extraction_error_code
          head extraction_error_code
        else
          head 422
        end
      end
    end
  end
end
