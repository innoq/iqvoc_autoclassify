# encoding: UTF-8

require 'machinist/active_record'

Document.blueprint do
  url_info { { :host => "localhost", :lang => "de" } }
end

Iqvoc::Concept.base_class.blueprint do
  origin { "_#{sn}" }
  published_at { 3.days.ago }
end

Iqvoc::XLLabel.base_class.blueprint do
  origin { OriginMapping.merge(object.value) }
  language { Iqvoc::Concept.pref_labeling_languages.first }
  published_at { 2.days.ago }
end
