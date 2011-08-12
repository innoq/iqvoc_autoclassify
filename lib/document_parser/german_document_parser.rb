# encoding: UTF-8

require 'document_parser/base'

class GermanDocumentParser < DocumentParser::Base # XXX: should also be in DocumentParser module

  Irrelevant_abbreviations = [
    "ca.", "etc.", "usw.", "bzw.", "vgl.", "evtl.",
    "P.S.", "z. B.", "d. h.", "s. o.", "u.a.", "z. T.", "z. Zt.", "i. A.", "i. V.",
    "i. d. R.",
    "Min.", "min.", "Mio.", "Mrd.", "Nr.",
    "Dr.", "Prof.", "Fa.", "ff."
  ]
  # add common variants
  Irrelevant_abbreviations += Irrelevant_abbreviations.map { |abbr| abbr.gsub(". ", ".") }

  def preprocess(text)
    # discard semantically irrelevant abbreviations (to avoid erroneous sentence termination)
    Irrelevant_abbreviations.each { |abbr| text = text.gsub(abbr, "") }
    return text
  end

  def end_word # NB: closely tied to behavior of super's method
    word = normalize_word(@current_token) if @current_token
    super
    # extract hyphenated components
    if word and word.length > 1 and word.include? "-"
      word.split("-").each { |word|
        @current_sentence.push(word) if word.length > 1 # ignore dashes, slashes etc.
      }
    end
  end

  def normalize_word(token)
    # strip leading and trailing non-alphanumeric characters (excl. umlauts and ß)
    return token.
        sub(/^[^A-Za-z0-9ÄÖÜäöüß]+/, "").
        sub(/[^A-Za-z0-9ÄÖÜäöüß]+$/, "")
  end

end
