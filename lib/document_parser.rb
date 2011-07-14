# encoding: UTF-8

class DocumentParser
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

    text.each_char { |char|
      process char
    }
    process "." # XXX: hacky?
  end

  private

  def process(char)
    if char == "\n"
      if @previous_char == "\n" # XXX: what about >2 occurrences?
        end_sentence
      else
        end_word
      end
    elsif @@delimiters["sentence"].include? char
      end_sentence
    elsif @@delimiters["word"].include? char
      end_word
    else
      @current_token = @current_token ? "#{@current_token}#{char}" : char
    end
    @previous_char = char
  end

  def end_sentence
    @current_sentence.push(@current_token) if @current_token
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
