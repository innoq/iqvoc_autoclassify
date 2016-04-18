# encoding: UTF-8

module DocumentParser
  class German < DocumentParser::Base

    @@stop_words = ['und', 'oder']

    @@irrelevant_abbreviations = [
      'ca.', 'etc.', 'usw.', 'bzw.', 'vgl.', 'evtl.',
      'P.S.', 'z. B.', 'd. h.', 's. o.', 'u.a.', 'z. T.', 'z. Zt.', 'i. A.', 'i. V.',
      'i. d. R.',
      'Min.', 'min.', 'Mio.', 'Mrd.', 'Nr.',
      'Dr.', 'Prof.', 'Fa.', 'ff.',
    ]
    # add common variants
    @@irrelevant_abbreviations += @@irrelevant_abbreviations.
        map { |abbr| abbr.gsub('. ', '.') }

    def initialize(text)
      super(text, 'de')
    end

    def end_word # NB: closely tied to behavior of super's method
      word = normalize_word(@current_token) if @current_token
      super
      # extract hyphenated components -- FIXME: this risks skewing weightings by adding duplicate terms
      if word and word.length > 1 and word.include? '-'
        word.split('-').reverse.each { |word| # NB: reverse avoids additional compound forms
          @current_sentence.push(word) if validate(word) # ignore dashes, slashes etc.
        }
      end
    end

    def normalize_sentence(_text)
      text = super _text

      # discard stop words
      @@stop_words.each { |word| text = text.gsub(/\b#{Regexp.quote word}\b/, '') } # XXX: might be more efficient to construct one big RegEx instead

      # discard semantically irrelevant abbreviations (to avoid erroneous sentence termination)
      @@irrelevant_abbreviations.each { |abbr| text = text.gsub(abbr, '') }

      text
    end

  end
end
