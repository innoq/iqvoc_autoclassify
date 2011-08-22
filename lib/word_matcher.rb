# encoding: UTF-8

# XXX / NB: This currently relies on UMT, as inflectionals and compounds are
#           not yet separate engines.

class WordMatcher # XXX: does this really need to be a class? (makes for a bad API)

  # each sentence is an array words (i.e. simple strings)
  def initialize(sentences)
    @sentences = sentences
  end

  # NB: returns label IDs rather than label instances (for performance reasons),
  #     *not* distinguishing between published and unpublished
  def labels
    # use normalized form for case-insensitivity (and performance)
    hash_seqs = @sentences.map { |sentence|
      sentence.map { |word| Inflectional::Base.normalize(word) }
    }

    # determine inflectionals
    inflectionals = Inflectional::Base.
        select([:normal_hash, :label_id]).
        where(:normal_hash => hash_seqs.flatten.uniq) # NB: does not retain order or duplicates

    # restore order of occurrence
    label_index = inflectionals.each_with_object({}) { |inf, hsh|
      hsh[inf.normal_hash] = inf.label_id # XXX: this risks discarding two inflectionals with identical value
    }
    inflectionals = nil # manual GC
    label_seqs = hash_seqs.map { |seq|
      seq.map { |hash| label_index[hash] }.
          compact # discard unmatched words
    }
    hash_seqs = nil; label_index = nil # manual GC

    label_ids = label_seqs.flatten.uniq
    label_ids += compound_forms(label_seqs, label_ids)
    return label_ids.uniq
  end

  def compound_forms(label_seqs, label_ids)
    # determine compound forms _beginning_ with any of the given labels
    candidates = CompoundForm::Content::Base.
        where(:order => 0, :label_id => label_ids).
        includes(:compound_form => [:compound_form_contents])
        # NB: intentionally not including `domain` (label), based on the
        #     assumption that eager loading would be less efficient due to a
        #     high percentage of rejects
    candidates = candidates.map(&:compound_form) # TODO: might as well query CompoundForm::Base above!?

    # for each sentence, determine compound forms whose components are present
    # in the sentence, in the right order
    results = []
    label_seqs.each { |label_seq|
      candidates.each { |compound_form| # XXX: iterating over all candidates seems inefficient; can't we pre-filter based on what appears in the current sentence?
        component_ids = compound_form.compound_form_contents.map(&:label_id)
        indexes = component_ids.map { |component_id| label_ids.index(component_id) }
        unless indexes.include? nil # all components must be present in the sentence
          # sequence of occurrence within the sentence must match the compound form's
          results.push(compound_form.domain_id) if align(label_seq, component_ids)
        end
      }
    }

    return results.uniq
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
