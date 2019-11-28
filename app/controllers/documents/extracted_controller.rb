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
    GET https://sns.uba.de/umthes/de/autoclassify/extract.json?uri=http://www.spiegel.de

    {
      "url": "https://sns.uba.de/umthes/de/autoclassify/extract.json?uri=http://www.spiegel.de",
      "total_results": 2,
      "results":
        [
          {"link":"http://localhost:3000/de/_00048961", "title":"Internet"},
          {"link":"http://localhost:3000/de/_00100204","title":"Europa"}
        ]
    }

    TURTLE/TTL
    ---------------
    GET https://sns.uba.de/umthes/de/autoclassify/extract.ttl?uri=http://www.spiegel.de

    # omitted namespace definitions
    <https://sns.uba.de/umthes/de/autoclassify/extract?uri=http://www.spiegel.de> a sdc:Query;
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
    @document = Document::Extracted.new(uri: params[:uri])
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
                "link": rdf_url(id: c.concept_origin, lang: nil, only_path: false, format: nil)
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

  def error_response
    {
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
      messages << t('txt.controllers.documents.create.invalid')
    end

    respond_to do |format|
      format.html do
        flash[:error] = messages.join("\n")
        render :new
      end
      format.any(:rdf, :ttl) do
        if extraction_error_code
          render text: messages.join("\n"), status: extraction_error_code
        else
          render text: messages.join("\n"), status: 422
        end
      end
    end
  end
end
