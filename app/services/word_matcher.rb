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

    compound_forms(label_seqs)
  end

  def compound_forms(label_seqs)
    label_ids = label_seqs.flatten.uniq

    # determine compound forms _beginning_ with any of the given labels
    candidates = CompoundForm::Content::Base.
        where(label_id: label_ids).
        includes(compound_form: [:compound_form_contents])
        # NB: intentionally not including `domain` (label), based on the
        #     assumption that eager loading would be less efficient due to a
        #     high percentage of rejects
    candidates = candidates.map(&:compound_form).uniq # TODO: might as well query CompoundForm::Base above!?

    # for each sentence, determine compound forms whose components are present in the sentence
    label_ids_found = []
    label_seqs.each do |_label_seq|
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
      label_seq = compound_forms([label_seq]) unless _label_seq == label_seq

      label_ids_found << label_seq
    end

    label_ids_found.flatten
  end

end
