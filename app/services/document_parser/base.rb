# encoding: UTF-8

require 'pragmatic_segmenter'

module DocumentParser
  class Base # XXX bad API (result is instance.sentences)

    attr_reader :sentences

    @@delimiters = {
        word: [' ', "\t", ',', ':', ';', '"', "'", '(', ')']
    }

    def initialize(_text, _lang ='en')
      @sentences = []

      text = preprocess _text
      ps = PragmaticSegmenter::Segmenter.new(text: text, language: _lang, clean: true)

      ps.segment.each { |segment|
        @current_sentence = []
        @current_token = nil
        @previous_char = nil
        @next_char = nil

        sentence = normalize_sentence segment
        current_char = sentence.slice!(0) # skip first iteration (for look-ahead)
        sentence.each_char { |char|
          @next_char = char
          process current_char
          current_char = char
        }
        end_sentence
      }
    end

    private

    def preprocess(text)
      text.gsub! "\r\n", "\n" # Adapt Windows-NL
      text.gsub! /(?<!\n)\n(?!\n)/, ' ' # Remove single NLs (or use PragmaticSegmenter::Segmenter w/ doc_type=pdf)

      text
    end

    def process(char)
      if @@delimiters[:word].include? char
        end_word
      else
        @current_token = @current_token ? "#{@current_token}#{char}" : char
      end
      @previous_char = char
    end

    def end_sentence
      end_word
      @sentences.push(@current_sentence) if @current_sentence.length > 0
      @current_sentence = []
    end

    def end_word
      if @current_token
        word = normalize_word @current_token
        @current_sentence.push(word) if validate(word) # ignore dashes, slashes etc.
      end
      @current_token = nil
    end

    def validate(word) # XXX: rename
      word.length > 1 or word =~ /^[0-9A-Za-z]$/
    end

    def normalize_sentence(text)
      "#{text} "
    end

    def normalize_word(token)
      TokenNormalizer.do_it token
    end

  end
end
