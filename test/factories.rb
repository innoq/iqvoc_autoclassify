Factory.define :document do |document|
  document.content <<-END
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  END
end

Factory.define :concept, :class => Iqvoc::Concept.base_class do |c|
  c.sequence(:origin) { |n| "_000000#{n}" }
  c.published_at 3.days.ago
  c.pref_labelings { |pref_labelings| [pref_labelings.association(:pref_labeling)] }
  c.alt_labelings { |alt_labelings| [alt_labelings.association(:alt_labeling)] }
  c.narrower_relations { |narrower_relations| [narrower_relations.association(:narrower_relation)] }
end

Factory.define :collection, :class => Iqvoc::Collection.base_class do |c|
  c.sequence(:origin) { |n| "_100000#{n}" }
  c.published_at 3.days.ago
  c.labelings { |labelings| [labelings.association(:pref_labeling)] }
end

Factory.define :stupid_broader_relation, :class => Iqvoc::Concept.broader_relation_class do |rel|
end

Factory.define :narrower_relation, :class => Iqvoc::Concept.broader_relation_class.narrower_class do |rel|
  rel.target {|target|
    target.association(:concept, :broader_relations => [], :narrower_relations => [], :pref_labelings => [
        Factory.create(:pref_labeling, :target => Factory.create(:pref_label, :value => 'Some narrower relation'))
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

Factory.sequence(:label_number) { |n| n + 1 }

Factory.define :label, :class => Label::Base do |l|
  l.language Iqvoc::Concept.pref_labeling_languages.first
  l.published_at 2.days.ago
  l.value "Tree #{Factory.next(:label_number)}"
end

Factory.define :pref_label, :parent => :label, :class => Iqvoc::Concept.pref_labeling_class.label_class do |l|
end

Factory.define :alt_label, :parent => :label, :class => Labeling::SKOS::AltLabel.label_class do |l|
end
