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
      sentence.map { |word| Inflectional::Base.normalize(word) }
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
    inflectionals = nil # manual GC
    label_seqs = hash_seqs.map do |seq|
      seq.map { |hash| label_index[hash] }.
          compact # discard unmatched words
    end
    hash_seqs = nil; label_index = nil # manual GC

    label_ids = label_seqs.flatten
    return label_ids + compound_forms(label_seqs, label_ids.uniq)
  end

  def compound_forms(label_seqs, label_ids)
    # determine compound forms _beginning_ with any of the given labels
    candidates = CompoundForm::Content::Base.
        where(order: 0, label_id: label_ids).
        includes(compound_form: [:compound_form_contents])
        # NB: intentionally not including `domain` (label), based on the
        #     assumption that eager loading would be less efficient due to a
        #     high percentage of rejects
    candidates = candidates.map(&:compound_form) # TODO: might as well query CompoundForm::Base above!?

    # for each sentence, determine compound forms whose components are present
    # in the sentence, in the right order
    results = []
    @trace[:compound_index] = {}
    label_seqs.each { |label_seq|
      candidates.each { |compound_form| # XXX: iterating over all candidates seems inefficient; can't we pre-filter based on what appears in the current sentence?
        component_ids = compound_form.compound_form_contents.map(&:label_id)
        indexes = component_ids.map { |component_id| label_ids.index(component_id) }
        unless indexes.include? nil # all components must be present in the sentence
          # sequence of occurrence within the sentence must match the compound form's
          if align(label_seq, component_ids)
            results.push(compound_form.domain_id)
            # list of label IDs by first component's label ID
            @trace[:compound_index][component_ids.first] ||= []
            @trace[:compound_index][component_ids.first].push(compound_form.domain_id)
          end
        end
      }
    }

    return results
  end

  private

  # compares two sequences, checking whether tokens contains all items of
  # template, in that same order
  def align(tokens, template)
    if pos = tokens.index(template.first)
      template.size == 1 || align(tokens.slice(pos..-1), template.drop(1))
    end
  end

end
