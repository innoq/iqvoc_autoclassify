# initializer for both iqvoc and iqvoc_skosxl


Iqvoc::Concept.include_module_names << 'DocumentsConceptExtension'

Iqvoc.config.register_settings({
  'title' => 'iQvoc AutoClassify',
  'languages.pref_labeling' => ['de', 'en']
})

Iqvoc::Configuration::Navigation.add_grouped({
  text: proc { t('txt.views.document.auto_classify_title') },
  href: proc { new_document_path },
  controller: 'documents'
}, -3)

# show upcoming link in dev & staging
if Rails.env.development? || Rails.env.staging?
  Iqvoc::Configuration::Navigation.add_grouped({
    text: proc { t('txt.views.autoclassify.tag_wizard_title') },
    href: proc { autoclassify_path },
    controller: 'autoclassify'
  }, -3)
end

Iqvoc.core_assets += %w(iqvoc_autoclassify/jquery.mintip.css iqvoc_autoclassify/jquery.mintip.js)

ActiveSupport.on_load :skos_importer do
  SkosImporter.second_level_object_classes += [
    Label::Iqvoc::Properties::AutoClassify
  ]
end
