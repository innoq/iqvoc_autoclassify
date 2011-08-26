require 'digest/sha1'
require 'document_parser/german_document_parser'
require 'word_matcher'

class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessor :url_info # required for classifications' concept URLs

  has_many :classifications, :order => "weighting DESC", :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_one :classification_trace, :dependent => :destroy

  validates_presence_of :content
  validates_uniqueness_of :content_hash

  before_validation do |document|
    self.content_hash = Digest::SHA1.hexdigest(content)
  end

  after_save do |document|
    document.classifications.destroy_all
    document.concepts(true).each { |concept, weighting|
      uri = concept_url(concept, :host => @url_info[:host],
          :lang => @url_info[:lang])
      document.classifications.create!(:concept_uri => uri,
          :weighting => weighting, :title => concept.to_s) # XXX: `to_s` is slow (label loaded lazily)
    }

    # NB: trace only stores references (IDs)
    document.create_classification_trace(:trace => @trace.to_json)
  end

  # use content_hash as entity identifier
  def to_param
    content_hash
  end

  def concepts(trace=false)
    return @concepts if (trace ? @concepts && @trace : @concept)
    @concepts = determine_concepts(trace)
    analyze_concept_relations
    return @concepts
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

  def determine_concepts(trace=false)
    concepts = {}
    labels = determine_labels(trace)
    @trace[:concept_index] = {} if trace

    labels.each do |label, occurrences|
      label.labelings.each do |labeling|
        concept = labeling.owner
        next if not concept.published?
        if trace
          # list of concept IDs by label ID
          @trace[:concept_index][label.id] ||= []
          @trace[:concept_index][label.id].push(concept.id)
        end
        concepts[concept] ||= 0
        concepts[concept] += occurrences * weightings[labeling.type]
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

  # returns a hash pairing labels with the respective number of occurrences
  def determine_labels(trace=false)
    text = self.title ? self.title + ".\n\n" + self.content : self.content
    sentences = DocumentParser::German.new(text).sentences # simply assuming DE, for now

    matcher = WordMatcher.new(sentences, trace)
    label_ids = matcher.labels
    @trace = matcher.trace

    labels = Iqvoc::XLLabel.base_class.
        published.
        where(:id => label_ids.uniq).
        select(:id).
        includes(:labelings => { :owner => { :relations => :target } }) # required for subsequent concept analysis
    labels = labels.index_by(&:id)

    return label_ids.inject({}) { |hsh, id|
      label = labels[id]
      if label
        hsh[label] = hsh[label] ? hsh[label] + 1 : 1
      end
      hsh
    }
  end

end
