# encoding: UTF-8

module DocumentParser
  class German < DocumentParser::Base

    @@stop_words = ['oder'] # e.g und/oder

    @@irrelevant_abbreviations = [
        'ca.', 'etc.', 'usw.', 'bzw.', 'vgl.', 'evtl.',
        'P.S.', 'z. B.', 'd. h.', 's. o.', 'u.a.', 'z. T.', 'z. Zt.', 'i. A.', 'i. V.',
        'i. d. R.',
        'Min.', 'min.', 'Mio.', 'Mrd.', 'Nr.',
        'Dr.', 'Prof.', 'Fa.', 'ff.',
    ]

    def initialize(text)
      super(text, 'de')
    end

    def end_word # NB: closely tied to behavior of super's method
      word = normalize_word(@current_token) if @current_token
      super
      # extract hyphenated components -- FIXME: this risks skewing weightings by adding duplicate terms
      # ppn: commented out because it blows up the results and also destroys label findings
      # if word and word.length > 1 and word.include? '-'
      #   word.split('-').reverse.each { |word| # NB: reverse avoids additional compound forms
      #     @current_sentence.push(word) if validate(word) # ignore dashes, slashes etc.
      #   }
      # end
    end

    def normalize_sentence(_text)
      text = super _text

      # discard stop words and semantically irrelevant abbreviations
      rx = Regexp.union (@@irrelevant_abbreviations+@@stop_words)
                            .map { |w| /\s#{ (w.strip.gsub '.', '\.').gsub(' ', '.?') }\s/ }
      text.gsub!(rx, ' ')

      text
    end

  end
end
