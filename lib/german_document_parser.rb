# encoding: UTF-8

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

  def normalize_word(token)
    # strip leading and trailing non-alphanumeric characters (excl. umlauts and ß)
    return token.
        sub(/^[^A-Za-z0-9ÄÖÜäöüß]+/, "").
        sub(/[^A-Za-z0-9ÄÖÜäöüß]+$/, "")
  end
end
