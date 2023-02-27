module LabelsHelperExtension
  def human_label_for(labeling, language = nil)
    label = labeling.target
    concept = labeling.owner

    if label == concept.pref_label(language)
      # concepts pref label
      concept.pref_label(language).value
    else
      # not a pref label, render with pref_label reference
      "#{label.value} &rarr; #{concept.pref_label(language).value}"
    end.html_safe
  end
end

Rails.configuration.to_prepare do
  LabelsHelper.prepend LabelsHelperExtension
end
