module ConceptExtension

  # TODO: move to iqvoc core!?
  # returns the (one!) preferred label of a concept for the requested language.
  # lang can either be a (lowercase) string or symbol with the (ISO ....) two letter
  # code of the language (e.g. :en for English, :fr for French, :de for German).
  def pref_label(language = nil)
    if pref_labels.loaded?
      # use select if association is already loaded
      @cached_pref_labels ||= pref_labels.select(&:published?).each_with_object({}) do |label, hash|
        if hash[label.language]
          Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
        end
        hash[label.language] = label
      end
    else
      # use scope otherwise
      @cached_pref_labels ||= pref_labels.published.each_with_object({}) do |label, hash|
        if hash[label.language]
          Rails.logger.warn("Two pref_labels (#{hash[label.language]}, #{label}) for one language (#{label.language}). Taking the second one.")
        end
        hash[label.language] = label
      end
    end

    lang = language.to_s.presence || (I18n.locale.to_s == 'none' ? nil : I18n.locale.to_s)

    if @cached_pref_labels[lang].nil?
      # Fallback to the main language
      @cached_pref_labels[lang] = pref_labels.select{ |l|
        l.language.to_s == Iqvoc::Concept.pref_labeling_languages.first.to_s
      }.first
    end
    @cached_pref_labels[lang]
  end

end

Rails.configuration.to_prepare do
  Concept::SKOS::Base.prepend ConceptExtension
end
