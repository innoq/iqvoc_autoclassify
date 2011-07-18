# encoding: UTF-8

require 'document_parser/base'

class GermanDocumentParser < DocumentParser

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

  def normalize_word(token)
    # strip leading and trailing non-alphanumeric characters (excl. umlauts and ß)
    return token.
        sub(/^[^A-Za-z0-9ÄÖÜäöüß]+/, "").
        sub(/[^A-Za-z0-9ÄÖÜäöüß]+$/, "")
  end
end
