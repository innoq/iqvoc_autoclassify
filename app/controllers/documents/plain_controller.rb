class Documents::PlainController < DocumentsController
  resource_description { name 'AutoClassify plain text' }

  api :POST, ':lang/autoclassify/plain{.html|.ttl|.rdf|.json}', <<-DOC
    Returns the most significant concepts for a given document body.
  DOC
  param :content, String, required: true, desc: 'Plain text to be classified.'
  example <<-DOC
  JSON
  ---------------
  POST curl -X POST --data "content=Abfallwirtschaft" https://sns.uba.de/umthes/de/autoclassify/plain.json

  {
    "url": "https://sns.uba.de/umthes/de/autoclassify/plain.json",
    "total_results": 1,
    "results":
      [
        {
          "link": "https://sns.uba.de/umthes/de/_00000347",
          "title": "Abfallwirtschaft",
          "rank": 2.0
        }
      ]
  }

  TURTLE/TTL
  ---------------
  POST curl -X POST --data "content=Abfallwirtschaft" https://sns.uba.de/umthes/de/autoclassify/plain.ttl
  200

  # omitted namespace definitions
  <https://sns.uba.de/umthes/de/autoclassify/plain> a sdc:Query;
                                                  sdc:totalResults 1;
                                                  sdc:result search:result1.
  search:result1 a sdc:Result;
                 sdc:link :_00000347;
                 dct:title "Abfallwirtschaft";
                 sdc:rank 1.0.
  DOC

  def create
    @document = Document::Plain.new document_params

    @document.persist = false unless current_user

    render_errors and return if @document.invalid?

    @document.classify!

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
          # TODO: render using jbuilder?
          render json: {
            "url": request.original_url,
            "total_results": @document.classifications.length,
            "results":
              @document.classifications
              .select { |classification| classification.concept }
              .map { |c|
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
    if params[:document]
      # form request
      params.require(:document).permit(:title, :content, :language, :exclude_disabled_concepts)
    else
      # api request
      params.permit(:title, :content, :language, :exclude_disabled_concepts)
    end
  end

  def render_errors
    status = 422

    if @document.content.blank?
      status = 400
    end

    respond_to do |format|
      format.html {
        @document = Document::Base.new unless @document
        flash[:error] = t('txt.controllers.documents.create.invalid')
        render :new
      }
      format.any(:rdf, :ttl, :nt, :json) {
        head status
      }
    end

  end
end
