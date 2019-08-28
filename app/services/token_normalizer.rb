class TokenNormalizer

  # strip leading and trailing non-alphanumeric characters (excl. umlauts, ß and dots)
  def self.do_it(_token)
    token = _token.to_s
    return token.
        sub(/^[^A-Za-z0-9ÄÖÜäöüß\.\-]+/, '').
        sub(/[^A-Za-z0-9ÄÖÜäöüß\.\-]+$/, '')
  end

end
