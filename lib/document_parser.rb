# encoding: UTF-8

class DocumentParser # XXX bad API (result is instance.sentences)
  attr_reader :sentences

  @@delimiters = {
    "sentence" => [".", "?", "!"],
    "word" => [" ", ",", ":", ";", '"', "'", "(", ")"]
  }

  def initialize(text)
    @sentences = []
    @current_sentence = []
    @current_token = nil

    @previous_char = nil
    @next_char = nil

    text = preprocess(text)

    text += "." # ensure final sentence is completed -- XXX: hacky?
    text += " " # ensure a final iteration -- XXX: hacky?
    current_char = text.slice!(0) # skip first iteration (for look-ahead)
    text.each_char { |char|
      @next_char = char
      process current_char
      current_char = char
    }
  end

  private

  def process(char)
    if char == "\n"
      if @previous_char == "\n" # XXX: what about >2 occurrences?
        end_sentence
      else
        end_word
      end
    elsif (@@delimiters["sentence"].include? char) and
        (@next_char =~ /\s/) != nil # XXX: too simplistic?
      end_sentence
    elsif @@delimiters["word"].include? char
      end_word
    else
      @current_token = @current_token ? "#{@current_token}#{char}" : char
    end
    @previous_char = char
  end

  def preprocess(text)
    text
  end

  def end_sentence
    end_word
    @sentences.push(@current_sentence) if @current_sentence.length > 0
    @current_sentence = []
    @current_token = nil
  end

  def end_word
    if @current_token and @current_token.length > 1 # ignore dashes, slashes etc.
      @current_sentence.push(@current_token)
    end
    @current_token = nil
  end
end

class GermanDocumentParser < DocumentParser
  @@abbreviations = {
    "z. B." => "" # XXX: simply dropping this is cheating and breaks encapsulation
  }

  def preprocess(text)
    # "disguise" known abbreviations
    @@abbreviations.each { |old, new|
      text = text.gsub(old, new)
    }
    return text
  end
end
