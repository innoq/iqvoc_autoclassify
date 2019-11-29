# initializer for both iqvoc and iqvoc_skosxl


Iqvoc::Concept.include_module_names << 'DocumentsConceptExtension'

Iqvoc.config.register_settings({
  'title' => 'iQvoc AutoClassify',
  'languages.pref_labeling' => ['de', 'en']
})

Iqvoc::Configuration::Navigation.add_grouped({
  text: 'AutoClassify',
  href: proc { autoclassify_path },
  controller: 'autoclassify'
}, -3)

Iqvoc.core_assets += %w(iqvoc_autoclassify/jquery.mintip.css iqvoc_autoclassify/jquery.mintip.js)

ActiveSupport.on_load :skos_importer do
  SkosImporter.second_level_object_classes += [
    Label::Iqvoc::Properties::AutoClassify
  ]
end
