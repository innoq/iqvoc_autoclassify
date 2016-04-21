# encoding: UTF-8

class WordMatcher

  # @trace[:label_index]: list of label IDs by inflectionals' normal_hash
  # @trace[:compound_index]: list of label IDs by first component's label ID
  attr_reader :trace

  # each sentence is an array words (i.e. simple strings)
  def initialize(sentences)
    @sentences = sentences
    @trace = {}
  end

  # NB: returns label IDs rather than label instances (for performance reasons),
  #     *not* distinguishing between published and unpublished
  def labels
    # use normalized form for case-insensitivity (and performance)
    hash_seqs = @sentences.map do |sentence|
      seq = []
      sentence.each do |word1|
        word2 = word1.gsub /\./, '' # dots are allowed now, see TokenNormalizer.do_it
        seq << Inflectional::Base.normalize(TokenNormalizer.do_it word2) if (word1 != word2)
        seq << Inflectional::Base.normalize(TokenNormalizer.do_it word1)
      end
      seq
    end

    # determine inflectionals
    inflectionals = Inflectional::Base.select([:normal_hash, :label_id])
    # Trying to avoid ORA-01795 by limiting
    # the number of values per IN clause to 1000
    #
    # NB: does not retain order or duplicates
    hash_seqs.flatten.compact.uniq.in_groups_of(1000, false).each do |group|
      inflectionals = inflectionals.where(normal_hash: group)
    end

    # restore order of occurrence
    label_index = inflectionals.each_with_object({}) do |inf, hsh|
      hsh[inf.normal_hash] = inf.label_id # FIXME: this risks discarding two inflectionals with identical value
    end

    # list of label IDs by inflectionals' normal_hash
    @trace[:label_index] = label_index
    @trace[:compound_index] = {}

    label_seqs = hash_seqs.map do |seq|
      seq.map { |hash| label_index[hash] }.
          compact # discard unmatched words
    end

    label_seqs.reject!(&:empty?) # discard empty []

    label_seqs = homographs(label_seqs)
    label_seqs = compound_forms(label_seqs)

    label_seqs.flatten
  end

  # FIXME: (architecture) this gem doesn't know about Label::Relation::UMT::Homograph/::Qualifier
  def homographs(_label_seqs)
    type_homograph = 'Label::Relation::UMT::Homograph'
    type_qualifier = 'Label::Relation::UMT::Qualifier'

    return _label_seqs unless Object.const_get(type_homograph).is_a?(Class) || Object.const_get(type_qualifier).is_a?(Class)

    relations = Label::Relation::Base.
        where(range_id: (_label_seqs.flatten.uniq),
              type: [type_homograph, type_qualifier])

    domain_ranges = {}
    relations.each do |c|
      domain_ranges[c.domain_id] ||= {type_homograph.to_sym => [], type_qualifier.to_sym => []}
      domain_ranges[c.domain_id][c.class.to_s.to_sym] << c.range_id
    end

    domain_ranges.select! { |_, range_ids|
      range_ids[type_homograph.to_sym].any? && range_ids[type_qualifier.to_sym].any?
    }

    label_seqs = []
    _label_seqs.each do |_label_seq|
      label_seq = _label_seq

      domain_ranges.each do |domain_id, range_ids|

        match_homograph = _label_seq & range_ids[type_homograph.to_sym]
        match_qualifier = _label_seq & range_ids[type_qualifier.to_sym]

        if match_homograph.any? && match_qualifier.any?
          label_seq << domain_id
          label_seq -= match_homograph
          label_seq -= match_qualifier
        end
      end

      # check for cascading homographs
      label_seq = homographs([label_seq]).flatten unless _label_seq == label_seq

      label_seqs << label_seq
    end

    label_seqs
  end

  # Gets all labels per sentence, retaining those which are part of a compound form
  def compound_forms(_label_seqs)
    label_seqs = []

    # determine compound forms containing any of the given labels
    candidates = CompoundForm::Content::Base.
        where(label_id: (_label_seqs.flatten.uniq)).
        includes(compound_form: [:compound_form_contents])
    # NB: intentionally not including `domain` (label), based on the
    #     assumption that eager loading would be less efficient due to a
    #     high percentage of rejects
    candidates = candidates.map(&:compound_form).uniq.compact # FIXME uniq+compact # TODO: might as well query CompoundForm::Base above!?

    # for each sentence, determine compound forms whose components are present in the sentence
    _label_seqs.each do |_label_seq|
      label_seq = _label_seq

      candidates.each do |compound_form| # XXX: iterating over all candidates seems inefficient; can't we pre-filter based on what appears in the current sentence?
        component_ids = compound_form.compound_form_contents.map(&:label_id)
        if component_ids.size <= _label_seq.size &&
            (component_ids - _label_seq).empty? &&
            !_label_seq.include?(compound_form.domain_id)

          label_seq << compound_form.domain_id
          label_seq -= component_ids

          # list of label IDs by first component's label ID
          (@trace[:compound_index][component_ids.first] ||= []) << compound_form.domain_id
        end
      end

      # check for cascading components
      label_seq = compound_forms([label_seq]).flatten unless _label_seq == label_seq

      label_seqs << label_seq
    end

    label_seqs
  end

end
