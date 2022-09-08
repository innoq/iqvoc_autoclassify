require 'digest/sha1'
require 'workflow'

class Document::Base < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Workflow

  self.table_name = 'documents'

  MAX_TITLE_CHARS = 255
  MAX_CONTENT_CHARS = 10_000
  MAX_CONTENT_SUFFIX = '…'

  store_accessor :options, :language

  attr_writer :persist
  attr_reader :weightings

  has_many :classifications, -> { order 'weighting DESC' },
           foreign_key: 'document_id',
           dependent: :destroy,
           inverse_of: :document

  has_many :comments,
           foreign_key: 'document_id',
           dependent: :destroy,
           inverse_of: :document

  has_one :classification_trace,
          foreign_key: 'document_id',
          dependent: :destroy,
          inverse_of: :document

  validates :title, length: { maximum: MAX_TITLE_CHARS }
  validates :content, length: { maximum: MAX_CONTENT_CHARS }
  validates :language, inclusion: { in: Iqvoc::Concept.pref_labeling_languages }, allow_blank: true

  class_attribute :weightings
  self.weightings = {
    'Labeling::SKOSXL::PrefLabel'   => 1.0,
    'Labeling::SKOSXL::AltLabel'    => 0.8,
    'Labeling::SKOSXL::HiddenLabel' => 0.3
  }

  class_attribute :weighting_factors
  self.weighting_factors = {
    Iqvoc::Concept.broader_relation_class_name => 1.5,
    'Concept::Relation::SKOS::Narrower::Base'  => 2.0,
    'Concept::Relation::SKOS::Related'         => 1.3
  }

  after_initialize do
    @parser = DocumentParser::German
    @persist = true
  end

  before_validation do |document|
    self.content_hash = Digest::SHA1.hexdigest(content) if content
  end

  def self.register_weighting(klass_str, value)
    Mutex.new.synchronize do
      self.weightings[klass_str] = value
    end
  end

  def self.register_weighting_factor(klass_str, value)
    Mutex.new.synchronize do
      self.weighting_factors[klass_str] = value
    end
  end

  def title
    read_attribute(:title).presence
  end

  def title=(_title)
    title = _title&.squish

    if title && title.bytesize >= MAX_TITLE_CHARS
      super(title.mb_chars.limit(MAX_TITLE_CHARS - MAX_CONTENT_SUFFIX.length).to_s + MAX_CONTENT_SUFFIX)
    else
      super(title)
    end
  end

  def content=(_content)
    content = _content&.squish

    if content && content.bytesize >= MAX_CONTENT_CHARS
      super(content.mb_chars.limit(MAX_CONTENT_CHARS - MAX_CONTENT_SUFFIX.length).to_s  + MAX_CONTENT_SUFFIX)
    else
      super(content)
    end
  end

  def classify
    save! if persist?

    classifications.destroy_all
    method = persist? ? :create : :build
    concepts.sort_by {|_k, v| -v[0]}.each.with_index(1) do |concept_with_weighting, index|
      concept = concept_with_weighting.first
      weighting = concept_with_weighting.last
      result_pref_label = concept.pref_labels.find { |pf| pf.language == self.language }&.value

      classifications.send(method,
        concept_origin: concept.origin,
        findings: weighting.drop(1).join(", "),
        weighting: weighting.first,
        title: result_pref_label || concept.to_s)
    end
    create_classification_trace(trace: @trace.to_json) if persist?
    halt if invalid?
  end

  def concepts
    return @concepts if (@concepts && @trace)
    @concepts = determine_concepts
    analyze_concept_relations
    @concepts
  end

  def determine_concepts
    concepts = {}
    labels = determine_labels
    @trace[:concept_index] = {}

    labels.each do |label, occurrences|
      label.labelings
           .reject { |l| l.owner.is_a?(Iqvoc::Collection.base_class) || l.owner.is_a?(Concept::SKOS::Scheme) }
           .each do |labeling|
        concept = labeling.owner
        next if !concept.published? || concept.expired?

        # list of concept IDs by label ID
        @trace[:concept_index][label.id] ||= []
        @trace[:concept_index][label.id] << concept.id
        # weighting
        concepts[concept] ||= [0]
        unless self.class.weightings[labeling.type]
          raise "#{labeling.type} has no registered weighting. Please configure one using Document::Base.register_weighting('MyLabelingClass', 1.0)"
        end
        concepts[concept] << label.value
        concepts[concept][0] += occurrences * self.class.weightings[labeling.type]
      end
    end

    # increase weighting for concepts derived from the title
    determine_title_concepts(concepts.keys).each do |concept|
      concepts[concept][0] *= 5.0 # NB: regular analysis already includes the title
    end
    concepts
  end

  # concepts is a list of known Concept instances, merely used for efficiency
  def determine_title_concepts(concepts)
    return {} unless self.title
    sentences = @parser.new(self.title).sentences
    matcher = WordMatcher.new(sentences)
    concept_ids = matcher.labels.map { |id| @trace[:concept_index][id] }.
        flatten.compact.uniq # `uniq` avoids multiple bonuses for the same concept
    concepts = concepts.index_by(&:id)
    concept_ids.map { |id| concepts[id] }
  end

  def analyze_concept_relations
    @concepts.each do |concept, weighting|
      concept.relations.each do |relation|
        if @concepts.has_key?(relation.target)
          unless self.class.weighting_factors[relation.type]
            raise "#{relation.type} has no registered weighting factor. Please configure one using Document::Base.register_weighting_factor('MyRelationClass', 1.0)"
          end
          @concepts[relation.target][0] *= self.class.weighting_factors[relation.type]
        end
      end
    end
  end

  # returns a hash pairing labels with the respective number of occurrences
  def determine_labels
    text = [self.title, self.content]
             .select(&:present?)
             .join("\n\n")

    sentences = @parser.new(text).sentences

    matcher = WordMatcher.new(sentences)
    label_ids = matcher.labels
    @trace = matcher.trace

    label_params = { id: label_ids.uniq }
    label_params[:language] = self.language if self.language.present?

    labels = Iqvoc::XLLabel.base_class.
        published.
        where(label_params).
        includes(labelings: { owner: { relations: :target } }) # required for subsequent concept analysis
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

  def persist?
    @persist || !new_record?
  end

  def persist_workflow_state(new_value)
    if persist?
      super
    else
      @workflow_state = new_value
    end
  end

  def load_workflow_state
    if persist?
      super
    else
      @workflow_state
    end
  end

  def save(*)
    raise PersistenceNotAllowed, 'Allow persisting of records with record.persist = true' unless persist?
    super
  end

  class PersistenceNotAllowed < StandardError; end
end
