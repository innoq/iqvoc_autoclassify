class Documents::PlainController < DocumentsController
  def create
    @document = Document::Plain.new(params[:document])
    @document.url_info = {
      :host => request.host_with_port,
      :lang => I18n.locale
    }

    @document.classify!

    if @document.classified? && @document.errors.none?
      redirect_to document_path(:id => @document)
    else
      flash[:error] = t("txt.controllers.documents.create.invalid")
      render :new
    end
  end
end
