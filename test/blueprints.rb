# encoding: UTF-8

require 'machinist/active_record'

Document.blueprint do
  content { <<-END
    Ein Weltraumkampfpilot ist ein Pilot, der im Weltraum fliegt und kämpft.
    Es geht dabei um nichts geringeres als den Kampf um die Weltherrschaft und
    die Herrschaft über den Weltraum. Diese kann nur kämpfend erreicht werden.
    Dafür braucht es nun mal einen Piloten, der den Kampf um den Weltraum kämpft.
  END
  }
end

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

Labeling::SKOSXL::PrefLabel.blueprint do
  target { Label::Base.make(:value => "Weltraumkampfpilot") }
end

Labeling::SKOSXL::AltLabel.blueprint do
  target { Label::Base.make(:value => "Weltraumkampfflieger") }
end

Label::Base.blueprint do
  language { Iqvoc::Concept.pref_labeling_languages.first }
  published_at { 2.days.ago }
  origin { object.value }
end
