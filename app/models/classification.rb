class Classification < ActiveRecord::Base
  belongs_to :document, class_name: Document::Base
  belongs_to :concept, -> { where 'expired_at >= ? OR expired_at IS NULL', Date.today },
             class_name: Iqvoc::Concept.base_class,
             foreign_key: 'concept_origin',
             primary_key: 'origin'

  paginates_per 100

  def build_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(concept.origin)) if concept
    result.Dct::title(title) if title
    result.Sdc::rank(weighting) # XXX: "rank" invalid; not an integer, not unique(?)
  end

  def to_s
    title || concept.to_s
  end

end
