# initializer for both iqvoc and iqvoc_skosxl

Iqvoc.config.register_settings({
  "title" => "iQvoc AutoClassify",
  "languages.pref_labeling" => ["de", "en"]
})

ActiveSupport.on_load :navigation_services_group_created do
  Iqvoc.navigation_items[-3][:items] << {
    :text       => "AutoClassify",
    :href       => proc { documents_path },
    :controller => "documents"
  }
end

Iqvoc.core_assets += %w(iqvoc_autoclassify/jquery.mintip.css iqvoc_autoclassify/jquery.mintip.js)
