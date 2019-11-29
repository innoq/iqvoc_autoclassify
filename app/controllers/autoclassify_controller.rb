class AutoclassifyController < ApplicationController
  respond_to :html, :rdf, :ttl

  def index
    @classifications = analyze_classifications || {}
    @classification_origins = @classifications.map { |c| c.concept_origin }

    @documents =
      if params[:search_text]
        documents = Document::Base.all
          .where("uri LIKE ?", '%umweltbundesamt.de%')
          .joins(:classifications)
          .where("classifications.concept_origin IN (?)", @classification_origins)
          .group(:id)
          #.page(params[:page])

        documents = documents.map { |d| DocumentView.new(d.id, d.title, d.uri, d.classifications, (d.classifications.select { |c| @classification_origins.include?(c.concept_origin) } ) ) }.sort_by { |d| -d.overlapping.length }
      else
        []
      end

    respond_with @documents
  end

  protected

  def analyze_classifications
    return {} unless params[:search_text]
    content = params[:search_text]

    document = Document::Plain.new do |doc|
      doc.content = content
    end
    document.persist = false

    return {} if document.invalid?

    document.classify!
    document.classifications
  end

  # FIXME: this feels wrong
  class DocumentView
    attr_accessor :id, :title, :uri, :classifications, :overlapping

    def initialize(id, title, uri, classifications, overlapping)
      @id = id
      @title = title
      @uri = uri
      @classifications = classifications
      @overlapping = overlapping
    end
  end

end
