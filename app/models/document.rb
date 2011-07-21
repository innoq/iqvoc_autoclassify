require 'digest/sha1'

class Document < ActiveRecord::Base
  has_many :classifications, :dependent => :destroy

  before_save do |document|
    self.content_hash = Digest::SHA1.hexdigest(content)
  end

  def self.after_initialize
    @concepts = nil
  end

  def concepts
    return @concepts if @concepts
    determine_concepts
    analyze_concept_relations
  end

  def labels
    # XXX: it might be more efficient to adopt a streaming approach, processing
    #      each sentence as they're identified instead of separating the
    #      processing steps
    GermanDocumentParser.new(self.content).sentences.map { |sentence| # XXX: simply assuming German for now
      WordMatcher.new(sentence).labels
    }.flatten.uniq # XXX: this could be made more efficient
  end

  def weightings
    @weightings ||= {
      'Labeling::SKOS::PrefLabel'   => 1.0,
      'Labeling::SKOS::AltLabel'    => 1.0,
      'Labeling::SKOS::HiddenLabel' => 0.3
    }
  end

  def weighting_factors
    @weighting_factors ||= {
      Iqvoc::Concept.broader_relation_class_name => 1.5,
      'Concept::Relation::SKOS::Narrower'        => 2.0,
      'Concept::Relation::SKOS::Related'         => 1.3
    }
  end

  def determine_concepts
    labels.each do |label|
      label.labelings.each do |labeling|
        concept = labeling.owner
        weighting = weightings[labeling.type]
        if @concepts.has_key?(concept)
          @concepts[concept] += weighting
        else
          @concepts[concept] = weighting
        end
      end
    end
  end

  def analyze_concept_relations
    @concepts.each do |concept|
      concept.relations.each do |relation|
        if @concepts.has_key?(relation.target)
          @concepts[concept] *= weighting_factors[relation.type]
        end
      end
    end
  end

end
