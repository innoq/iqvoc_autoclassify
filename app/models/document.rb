require 'digest/sha1'
require 'document_parser/german_document_parser'
require 'word_matcher'
require 'textractor'

class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessor :url_info # required for classifications' concept URLs

  has_many :classifications, :order => "weighting DESC", :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_one :classification_trace, :dependent => :destroy

  after_initialize do
    @parser = DocumentParser::German
  end

  validates_presence_of :content
  validates_uniqueness_of :content_hash
  validate :document_is_too_large

  before_validation do |document|
    self.content_hash = Digest::SHA1.hexdigest(content) if content
  end

  after_save do |document|
    document.classifications.destroy_all
    document.concepts.each do |concept, weighting|
      uri = concept_url(concept, :host => @url_info[:host],
          :lang => @url_info[:lang])
      document.classifications.create!(:concept_id => concept.id,
          :concept_uri => uri, :weighting => weighting,
          :title => concept.to_s) # XXX: `to_s` is expensive (label loaded lazily)
    end

    # NB: trace only stores references (IDs)
    document.create_classification_trace(:trace => @trace.to_json)
  end

  def document_is_too_large
    if too_large?
      errors.add(:too_large, "Document is too large.")
    end
  end

  def self.from_uri(uri, url_info)
    document = Document.new(:uri => uri, :url_info => url_info)
    document.extract_from_uri(uri)
    return document
  end

  def self.from_html(html, url_info)
    document = Document.new(:url_info => url_info)
    document.extract_from_html(html)
    return document
  end

  def self.from_text(text, url_info)
    document = Document.new(:content => text, :url_info => url_info)
    return document
  end

  def too_large?
    return false if too_large.nil?
    return too_large
  end

  def extract_from_uri(uri)
    begin
      self.title, self.content = Textractor.extract(uri)
    rescue Textractor::ExcessiveSize => exception
      self.too_large = true
    end
  end

  def extract_from_html(html)
    begin
      self.title, self.content = Textractor.from_html(html)
    rescue Textractor::ExcessiveSize => exception
      self.too_large = true
    end
  end

  def autoclassify
    if self.valid?
      self.classifications.destroy_all
      self.concepts.each do |concept, weighting|
        uri = concept_url(concept, :host => @url_info[:host], :lang => @url_info[:lang])
        self.classifications.new(:concept_id => concept.id,
        :concept_uri => uri, :weighting => weighting,
        :title => concept.to_s) # XXX: `to_s` is expensive (label loaded lazily)
      end
      self.classifications.sort_by!{ |c| -c.weighting }
    end
    return self
  end

  # use content_hash as entity identifier
  def to_param
    content_hash
  end

  def concepts
    return @concepts if (@concepts && @trace)
    @concepts = determine_concepts
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

  def determine_concepts
    concepts = {}
    labels = determine_labels
    @trace[:concept_index] = {}

    labels.each do |label, occurrences|
      label.labelings.each do |labeling|
        concept = labeling.owner
        next if not concept.published?
        # list of concept IDs by label ID
        @trace[:concept_index][label.id] ||= []
        @trace[:concept_index][label.id] << concept.id
        # weighting
        concepts[concept] ||= 0
        concepts[concept] += occurrences * weightings[labeling.type]
      end
    end

    # increase weighting for concepts derived from the title
    determine_title_concepts(concepts.keys).each { |concept|
      concepts[concept] *= 1.5 # NB: regular analysis already includes the title
    }

    return concepts
  end

  # concepts is a list of known Concept instances, merely used for efficiency
  def determine_title_concepts(concepts)
    return {} unless self.title
    sentences = @parser.new(self.title).sentences
    matcher = WordMatcher.new(sentences)
    concept_ids = matcher.labels.map { |id| @trace[:concept_index][id] }.
        flatten.compact.uniq # `uniq` avoids multiple bonuses for the same concept
    concepts = concepts.index_by(&:id)
    return concept_ids.map { |id| concepts[id] }
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
  def determine_labels
    text = self.title ? self.title + ".\n\n" + self.content : self.content
    sentences = @parser.new(text).sentences

    matcher = WordMatcher.new(sentences)
    label_ids = matcher.labels
    @trace = matcher.trace

    labels = Iqvoc::XLLabel.base_class.
        published.
        where(:id => label_ids.uniq, :language => I18n.locale).
        select(:id).
        includes(:labelings => { :owner => { :relations => :target } }) # required for subsequent concept analysis
    labels = labels.index_by(&:id)

    # count number of occurrences
    return label_ids.inject({}) do |hsh, id|
      label = labels[id]
      if label
        hsh[label] = hsh[label] ? hsh[label] + 1 : 1
      end
      hsh
    end
  end

  private
  attr_accessor :too_large

end
