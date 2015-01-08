# initializer for both iqvoc and iqvoc_skosxl

Iqvoc.config.register_settings({
  'title' => 'iQvoc AutoClassify',
  'languages.pref_labeling' => ['de', 'en']
})

Navigation.add_grouped({
  text: 'AutoClassify',
  href: proc { documents_path },
  controller: 'documents'
}, -3)

Iqvoc.core_assets += %w(iqvoc_autoclassify/jquery.mintip.css iqvoc_autoclassify/jquery.mintip.js)
