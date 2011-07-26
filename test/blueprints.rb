# encoding: UTF-8

require 'machinist/active_record'

Iqvoc::Concept.base_class.blueprint do
  origin { "_#{sn}" }
  published_at { 3.days.ago }
end

Iqvoc::Concept.base_class.blueprint(:weltraumkampfpilot) do
  origin { "_#{sn}" }
  published_at { 3.days.ago }
  labeling_skosxl_pref_labels(1)
  labeling_skosxl_alt_labels(1)
end

Iqvoc::XLLabel.base_class.blueprint do
  origin { OriginMapping.merge(object.value) }
  language { Iqvoc::Concept.pref_labeling_languages.first }
  published_at { 2.days.ago }
end
