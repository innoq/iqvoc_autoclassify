# initializer for both iqvoc and iqvoc_skosxl

Iqvoc.config.register_settings({
  "title" => "iQvoc AutoClassify",
  "languages.pref_labeling" => ["de", "en"]
})

Iqvoc.navigation_items.insert(-5, { # in front of search, users, instance configuration and about
  :content => proc { link_to "AutoClassify", documents_path }, # XXX: i18n
  :controller => "documents"
})

Iqvoc.core_assets += %w(iqvoc_autoclassify/jquery.mintip.css iqvoc_autoclassify/jquery.mintip.js)
