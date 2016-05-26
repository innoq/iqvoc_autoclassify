# encoding: UTF-8

class WordMatcher

  attr_reader :trace

  PHRASES_DELIM = ' '

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
    @phrases = {} # Labels containing spaces. Could have compound forms aswell.
  end

  # NB: returns label IDs rather than label instances (for performance reasons),
  #     *not* distinguishing between published and unpublished
  def labels
    @trace[:token_index] = {}
    @trace[:label_index] = {}
    @trace[:homograph_index] = {}
    @trace[:phrase_index] = {}
    @trace[:compound_index] = {}
    @trace[:result_index] = {}

    return [] if @sentences.empty?

    # use normalized form for case-insensitivity (and performance)
    hash_seqs = {}
    @sentences.each_with_index { |_sentence, _ix|
      sentence = _sentence.map { |word| word.mb_chars.downcase.strip.normalize }
      key = sentence.join(' ').to_sym

      @trace[:token_index][key] = {}
      @trace[:label_index][key] = []
      @trace[:homograph_index][key] = []
      @trace[:phrase_index][key] = []
      @trace[:compound_index][key] = []
      @trace[:result_index][key] = []

      sentence += word_combinations(sentence, 5) # find phrases that are not compound-forms
      # pp "SENTENCE: #{sentence.join(' | ')}"

      # store phrases for later removal if a corresponding label exists
      @phrases[key] = {}
      sentence.each do |word1|
        if (word1.include?(PHRASES_DELIM))
          @phrases[key][WordMatcher.normalize_word(word1).last()] = word1.split(PHRASES_DELIM).map { |word2| WordMatcher.normalize_word(word2).last() }
        else
          @trace[:token_index][key][TokenNormalizer.do_it(word1).to_s.mb_chars.downcase.to_s] = WordMatcher.normalize_word(word1)
        end
      end

      hash_seqs[key] = sentence.map { |word| WordMatcher.normalize_word(word) }.flatten
    }

    # determine inflectionals
    inflectionals = []
    inflectionals_sql = Inflectional::Base.select([:normal_hash, :label_id])

    # Trying to avoid ORA-01795 by limiting
    # the number of values per IN clause to 1000
    #
    # NB: does not retain order or duplicates
    hash_seqs.values.flatten.compact.uniq.in_groups_of(1000, false).each do |group|
      inflectionals += inflectionals_sql.where(normal_hash: group)
    end

    label_index = inflectionals.each_with_object({}) do |inf, hsh|
      (hsh[inf.normal_hash] ||= []) << inf.label_id
    end

    label_seqs = {}
    hash_seqs.each do |key, seq|
      label_hsh_idx_1 = {}
      seq.each do |hash|
        (label_hsh_idx_1[hash] ||= []) << label_index[hash]
      end
      label_hsh_idx_2 = label_hsh_idx_1.deep_dup

      # If a phrase-token exists as label, remove single tokens and don't look up their labels
      label_hsh_idx_1.each do |hsh, _|
        if @phrases[key] && @phrases[key][hsh]
          Array.new(@phrases[key][hsh]).each do |hsh_to_remove|
            label_hsh_idx_2[hsh_to_remove] = [] if label_index[hsh]
          end
        end
      end

      @trace[:token_index][key].reject! { |_, tokens| !(tokens & label_index.keys).empty? }
      @trace[:token_index][key] = @trace[:token_index][key].keys

      label_seqs[key] = label_hsh_idx_2.values.flatten.compact
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

    return _label_seqs unless Object.const_defined?(type_homograph) || Object.const_defined?(type_qualifier)

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
      label_seq = homographs({"#{ix}".to_sym => label_seq}).values.flatten unless _label_seq == label_seq

      label_seqs[ix] = label_seq
    end

    label_seqs
  end

  # Gets all labels per sentence, retaining those which are part of a compound form
  def compound_forms(_label_seqs, level=0)
    label_seqs = {}

    # for each sentence, determine compound forms whose components are present in the sentence
    _label_seqs.each do |ix, _label_seq|
      label_seq_new = _label_seq
      label_seq_dup = _label_seq

      # determine compound forms containing any of the given labels
      candidates = CompoundForm::Content::Base.
          where(label_id: (_label_seq.uniq)).
          includes(compound_form: [:compound_form_contents])
      # NB: intentionally not including `domain` (label), based on the
      #     assumption that eager loading would be less efficient due to a
      #     high percentage of rejects
      candidates = candidates.map(&:compound_form).uniq.compact # FIXME uniq+compact # TODO: might as well query CompoundForm::Base above!?

      #pp "---CANDIDATES=#{candidates.size} LEVEL=#{level}"
      #pp "---LABELS: " + Iqvoc::XLLabel.base_class.where(id: label_seq_dup).map(&:value).join(', ')

      # phrases-extraction
      # FIXME: there might have been non-label tokens between a phrases-tupel which blurry the results
      # example: "*Stand* foo bar *Technik*" == "*Stand* der *Technik*"
      candidates.each do |compound_form|
        component_ids = compound_form.compound_form_contents.sort_by(&:order).map(&:label_id)

        if component_ids.size <= label_seq_dup.size
          if label_seq_dup.join('@@@').include?(component_ids.join('@@@'))
            #pp "---PHRASE: #{compound_form.domain}"

            unless label_seq_new.include?(compound_form.domain_id)
              label_seq_new << compound_form.domain_id
              @trace[:phrase_index][ix] << compound_form.domain_id
            end

            label_seq_new -= component_ids
            label_seq_dup -= component_ids # don't use them for multi-label-extraction
            @trace[:phrase_index][ix] -= component_ids
          end

          if (component_ids - label_seq_dup).empty?
            #pp "---MEHRWORT: #{compound_form.domain}"

            unless label_seq_new.include?(compound_form.domain_id)
              label_seq_new << compound_form.domain_id
              @trace[:compound_index][ix] << compound_form.domain_id
            end

            label_seq_new -= component_ids
            @trace[:compound_index][ix] -= component_ids
          end
        end
      end

      # check for cascading components
      label_seq_new = compound_forms({"#{ix}".to_sym => label_seq_new}, level+1).values.flatten unless _label_seq == label_seq_new

      label_seqs[ix] = label_seq_new
    end

    label_seqs
  end


  private

  def word_combinations(words, max_tupel_size=3)
    res = []
    return res if max_tupel_size < 2
    (2..max_tupel_size).each do |max|
      ix = 0
      while ix+1 < words.size
        tmp = words[ix, max]
        res << tmp.join(PHRASES_DELIM) if tmp.size == max
        ix+= 1
      end
    end

    res
  end

end