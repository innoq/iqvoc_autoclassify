class AutoclassifyController < ApplicationController # TODO: auth restrictions?
  skip_before_filter :require_user

  def from_uri
    uri = params[:uri]
    has_uri =  uri && uri.strip.length > 0
    url_info = { :host => request.host_with_port, :lang => I18n.locale }
    return head :bad_request unless has_uri
    @document = Document.from_uri(uri, url_info)
    @document.autoclassify!

    if @document.valid?
      respond_to do |format|
        format.rdf { render("index.rdf") }
        format.ttl { render("index.rdf") }
      end
    elsif @document.errors.include? :too_large
      return head :request_entity_too_large
    else
      return head :bad_request
    end
  end

  def from_content
    content = request.body ? request.body.read : nil
    content_type = Mime::Type.lookup request.content_type
    has_content = content && content.strip.length > 0
    has_content_type = !content_type.nil?
    url_info = { :host => request.host_with_port, :lang => I18n.locale }
    return head :bad_request unless has_content and has_content_type
    return head :bad_request unless content_type.text? or content_type.html?

    if content_type.text?
      @document = Document.from_text(content, url_info)
    elsif content_type.html?
      @document = Document.from_html(content, url_info)
    else
      @document = Document.new
    end

    @document.autoclassify!

    if @document.valid?
      respond_to do |format|
        format.rdf { render("index.rdf") }
        format.ttl { render("index.rdf") }
      end
    elsif @document.errors.include? :too_large
      return head :request_entity_too_large
    else
      return head :bad_request
    end
  end
end
