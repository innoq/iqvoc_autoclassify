class Classification < ActiveRecord::Base
  belongs_to :document, :class_name => Document::Base
  belongs_to :concept

  def build_rdf(document, result)
    result.Sdc::link(IqRdf.build_uri(concept_uri))
    result.Dct::title(title) if title
    result.Sdc::rank(weighting) # XXX: "rank" invalid; not an integer, not unique(?)
  end

  def to_s
    title || "-"
  end

end
