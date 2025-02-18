Rails.application.config.to_prepare do
  silence_warnings do
    # common German abbreviations like i.d.R. are missing hence it'll be split and re-compound wrongly
    PragmaticSegmenter::Languages::Deutsch::Abbreviation::ABBREVIATIONS += (DocumentParser::German.class_eval('@@irrelevant_abbreviations').map { |abbr| abbr.gsub(/\s+/, '') }).uniq
  end
end
