require 'digest/sha1'
require 'document_parser/german_document_parser'
require 'word_matcher'

class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessor :url_info # required for classifications' concept URLs

  has_many :classifications, :order => "weighting DESC", :dependent => :destroy

  validates_presence_of :content
  validates_uniqueness_of :content_hash

  before_validation do |document|
    self.content_hash = Digest::SHA1.hexdigest(content)
  end

  after_save do |document|
    document.classifications.each(&:destroy)
    concepts.each { |concept, weighting|
      uri = concept_url(concept, :host => @url_info[:host],
          :lang => @url_info[:lang])
      document.classifications.create!(:concept_uri => uri,
          :weighting => weighting, :title => concept.to_s)
    }
  end

  # use content_hash as entity identifier
  def to_param
    content_hash
  end

  def concepts
    return @concepts if @concepts
    @concepts = determine_concepts
    analyze_concept_relations
    return @concepts
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
      'Labeling::SKOSXL::PrefLabel'   => 1.0,
      'Labeling::SKOSXL::AltLabel'    => 1.0,
      'Labeling::SKOSXL::HiddenLabel' => 0.3
    }
  end

  def weighting_factors
    @weighting_factors ||= {
      Iqvoc::Concept.broader_relation_class_name => 1.5,
      'Concept::Relation::SKOS::Narrower::Base'  => 2.0,
      'Concept::Relation::SKOS::Related'         => 1.3
    }
  end

  def determine_concepts
    concepts = {}
    self.labels.each do |label|
      label.labelings.each do |labeling|
        concept = labeling.owner
        next if not concept.published?
        weighting = weightings[labeling.type]
        if concepts.has_key?(concept)
          concepts[concept] += weighting
        else
          concepts[concept] = weighting
        end
      end
    end
    return concepts
  end

  def analyze_concept_relations
    @concepts.each do |concept, weighting|
      concept.relations.each do |relation|
        if @concepts.has_key?(relation.target)
          @concepts[relation.target] *= weighting_factors[relation.type]
        end
      end
    end
  end

end
