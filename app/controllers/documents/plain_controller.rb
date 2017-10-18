class Documents::PlainController < DocumentsController
  resource_description { name 'AutoClassify plain text' }

  api :POST, ':lang/autoclassify/plain', <<-DOC
    Returns the most significant concepts for a given document body.
  DOC
  formats [:html, :ttl, :rdf]
  param :content, String, required: true, desc: 'Plain text to be classified.'
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

    render_errors and return if content.nil?

    @document = Document::Plain.new do |doc|
      doc.title = title
      doc.content = content
    end
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
        format.any(:rdf, :ttl) { render :show }
      end
    else
      render_errors
    end
  end

  protected

  def render_errors
    @document = Document::Base.new unless @document

    flash[:error] = t('txt.controllers.documents.create.invalid')
    respond_to do |format|
      format.html { render :new }
      format.any(:rdf, :ttl) { render text: flash[:error], status: 422 }
    end
  end
end
