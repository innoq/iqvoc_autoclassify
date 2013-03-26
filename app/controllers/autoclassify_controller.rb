class AutoclassifyController < ApplicationController # TODO: auth restrictions?
  skip_before_filter :require_user

  def from_uri
    uri = params[:uri]
    has_uri =  uri && uri.strip.length > 0
    url_info = { :host => request.host_with_port, :lang => I18n.locale }
    return head 422 unless has_uri

    @document = Document.from_uri(uri, url_info)

    if @document.errors[:extraction].any?
      render :text => @document.errors[:extraction].join(" "), :status => 422
      return
    end

    @document.autoclassify

    if @document.valid?
      @results = @document.classifications
      respond_to do |format|
        format.rdf { render "index", :formats => [:rdf] }
        format.ttl { render "index", :formats => [:rdf] }
      end
    elsif @document.errors[:too_large].any?
      head 413
    else
      head 422
    end
  end

end
