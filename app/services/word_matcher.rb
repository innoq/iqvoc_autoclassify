# encoding: UTF-8

class WordMatcher

  # @trace[:label_index]: list of label IDs by inflectionals' normal_hash
  # @trace[:compound_index]: list of label IDs by first component's label ID
  attr_reader :trace

  def self.normalize_word(word1)
    ret = []
    word2 = word1.gsub /\./, '' # dots are allowed now, see TokenNormalizer.do_it
    ret << Inflectional::Base.normalize(TokenNormalizer.do_it word2) if (word1 != word2)
    ret << Inflectional::Base.normalize(TokenNormalizer.do_it word1)
    ret
  end

  # each sentence is an array words (i.e. simple strings)
  def initialize(sentences)
    @sentences = sentences
    @trace = {}
  end

  # NB: returns label IDs rather than label instances (for performance reasons),
  #     *not* distinguishing between published and unpublished
  def labels
    return [] if @sentences.empty? # FIXME .labels() is called on GET walking through all(!) inflectionals then

    @trace[:label_index] = {}
    @trace[:homograph_index] = {}
    @trace[:compound_index] = {}
    @trace[:result_index] = {}

    # use normalized form for case-insensitivity (and performance)
    hash_seqs = {}
    @sentences.each_with_index { |sentence, ix|
      key = sentence.join(' ').to_sym
      hash_seqs[key] = sentence.map { |word1| WordMatcher.normalize_word(word1) }.flatten

      @trace[:label_index][key] = []
      @trace[:homograph_index][key] = []
      @trace[:compound_index][key] = []
      @trace[:result_index][key] = []
    }

    # determine inflectionals
    inflectionals = Inflectional::Base.select([:normal_hash, :label_id])

    # Trying to avoid ORA-01795 by limiting
    # the number of values per IN clause to 1000
    #
    # NB: does not retain order or duplicates
    hash_seqs.values.flatten.compact.uniq.in_groups_of(1000, false).each do |group|
      inflectionals = inflectionals.where(normal_hash: group)
    end

    label_index = inflectionals.each_with_object({}) do |inf, hsh|
      # collect _all_ label_ids per hash (Planet vs. planet issue), this risks to have remaining labels when cleaning up
      # a sentence-seq from labels which are part of found compound_forms or homograph-qualifier pairs FIXME !?
      (hsh[inf.normal_hash] ||= []) << inf.label_id
    end

    label_seqs = {}
    hash_seqs.each do |key, seq|
      label_seqs[key] = seq.map { |hash| label_index[hash] }.
          flatten.
          compact # discard unmatched words
    end

    @trace[:label_index] = label_seqs.deep_dup
    label_seqs = homographs(label_seqs)
    label_seqs = compound_forms(label_seqs)
    @trace[:result_index] = label_seqs

    label_seqs.values.flatten
  end

  # FIXME: (architecture) this gem doesn't know about Label::Relation::UMT::Homograph/::Qualifier
  def homographs(_label_seqs)
    type_homograph = 'Label::Relation::UMT::Homograph'
    type_qualifier = 'Label::Relation::UMT::Qualifier'

    return _label_seqs unless Object.const_get(type_homograph).is_a?(Class) && Object.const_get(type_qualifier).is_a?(Class)

    label_seqs = {}

    relations = Label::Relation::Base.
        where(range_id: (_label_seqs.values.flatten.uniq),
              type: [type_homograph, type_qualifier])

    domain_ranges = {}
    relations.each do |c|
      domain_ranges[c.domain_id] ||= {type_homograph.to_sym => [], type_qualifier.to_sym => []}
      domain_ranges[c.domain_id][c.class.to_s.to_sym] << c.range_id
    end

    domain_ranges.select! { |_, range_ids|
      range_ids[type_homograph.to_sym].any? && range_ids[type_qualifier.to_sym].any?
    }

    _label_seqs.each do |ix, _label_seq|
      label_seq = _label_seq

      domain_ranges.each do |domain_id, range_ids|
        match_homograph = _label_seq & range_ids[type_homograph.to_sym]
        match_qualifier = _label_seq & range_ids[type_qualifier.to_sym]
        if match_homograph.any? && match_qualifier.any?
          label_seq << domain_id
          label_seq -= match_homograph
          label_seq -= match_qualifier

          @trace[:homograph_index][ix] << domain_id
          @trace[:homograph_index][ix] -= match_homograph
          @trace[:homograph_index][ix] -= match_qualifier
        end
      end

      # check for cascading homographs
      label_seq = homographs({"#{ix}": label_seq}).values.flatten unless _label_seq == label_seq

      label_seqs[ix] = label_seq
    end

    label_seqs
  end

  # Gets all labels per sentence, retaining those which are part of a compound form
  def compound_forms(_label_seqs)
    label_seqs = {}

    # determine compound forms containing any of the given labels
    candidates = CompoundForm::Content::Base.
        where(label_id: (_label_seqs.values.flatten.uniq)).
        includes(compound_form: [:compound_form_contents])
    # NB: intentionally not including `domain` (label), based on the
    #     assumption that eager loading would be less efficient due to a
    #     high percentage of rejects
    candidates = candidates.map(&:compound_form).uniq.compact # FIXME uniq+compact # TODO: might as well query CompoundForm::Base above!?

    # for each sentence, determine compound forms whose components are present in the sentence
    _label_seqs.each do |ix, _label_seq|
      label_seq = _label_seq

      candidates.each do |compound_form| # XXX: iterating over all candidates seems inefficient; can't we pre-filter based on what appears in the current sentence?
        component_ids = compound_form.compound_form_contents.map(&:label_id)
        if component_ids.size <= _label_seq.size &&
            (component_ids - _label_seq).empty? &&
            !_label_seq.include?(compound_form.domain_id)

          label_seq << compound_form.domain_id
          label_seq -= component_ids

          @trace[:compound_index][ix] << compound_form.domain_id
          @trace[:compound_index][ix] -= component_ids
        end
      end

      # check for cascading components
      label_seq = compound_forms({"#{ix}": label_seq}).values.flatten unless _label_seq == label_seq

      label_seqs[ix] = label_seq
    end

    label_seqs
  end

end
