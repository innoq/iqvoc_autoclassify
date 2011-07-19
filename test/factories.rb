Factory.define :document do |document|
  document.content <<-END
    Ein Weltraumkampfpilot ist ein Pilot, der im Weltraum fliegt und kämpft.
    Es geht dabei um nichts geringeres als den Kampf um die Weltherrschaft und
    die Herrschaft über den Weltraum. Diese kann nur kämpfend erreicht werden.
    Dafür braucht es nun mal einen Piloten, der den Kampf um den Weltraum kämpft.
  END
end

Factory.define :concept, :class => Iqvoc::Concept.base_class do |c|
  c.sequence(:origin) { |n| "_000000#{n}" }
  c.published_at 3.days.ago
  c.pref_labelings { |pref_labelings| [pref_labelings.association(:pref_labeling)] }
  c.alt_labelings { |alt_labelings| [alt_labelings.association(:alt_labeling)] }
  c.broader_relations { |broader_relations| [broader_relations.association(:broader_relation)] }
  c.narrower_relations { |narrower_relations| [narrower_relations.association(:narrower_relation)] }
end

Factory.define :stupid_broader_relation, :class => Iqvoc::Concept.broader_relation_class do |rel|
end

Factory.define :stupid_narrower_relation, :class => Iqvoc::Concept.broader_relation_class.narrower_class do |rel|
end

Factory.define :broader_relation, :class => Iqvoc::Concept.broader_relation_class.narrower_class do |rel|
  rel.target {|target|
    target.association(:concept, :broader_relations => [], :narrower_relations => [], :pref_labelings => [
        Factory.create(:pref_labeling, :target => Factory.create(:pref_label, :value => 'Weltraumkampf'))
      ])
  }
  rel.after_create { |new_relation| Factory(:stupid_narrower_relation, :owner => new_relation.target, :target => new_relation.owner) }
end

Factory.define :narrower_relation, :class => Iqvoc::Concept.broader_relation_class.narrower_class do |rel|
  rel.target {|target|
    target.association(:concept, :broader_relations => [], :narrower_relations => [], :pref_labelings => [
        Factory.create(:pref_labeling, :target => Factory.create(:pref_label, :value => 'Weltraumkampfspezialpilot'))
      ])
  }
  rel.after_create { |new_relation| Factory(:stupid_broader_relation, :owner => new_relation.target, :target => new_relation.owner) }
end

Factory.define :pref_labeling, :class => Iqvoc::Concept.pref_labeling_class do |lab|
  lab.target { |target| target.association(:pref_label) }
end

Factory.define :alt_labeling, :class => Iqvoc::Concept.further_labeling_classes.first.first do |lab|
  lab.target { |target| target.association(:alt_label) }
end

Factory.define :label, :class => Label::Base do |l|
  l.language Iqvoc::Concept.pref_labeling_languages.first
  l.published_at 2.days.ago
  l.value "Weltraumkampfpilot"
end

Factory.define :pref_label, :parent => :label, :class => Iqvoc::Concept.pref_labeling_class.label_class do |l|
end

Factory.define :alt_label, :parent => :label, :class => Labeling::SKOS::AltLabel.label_class do |l|
end
