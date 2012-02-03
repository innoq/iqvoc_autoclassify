# initializer for both iqvoc and iqvoc_skosxl

Iqvoc.title = "iQvoc AutoClassify"

Iqvoc.navigation_items.insert(-2, {
  :content => proc { link_to "AutoClassify", documents_path }, # XXX: i18n
  :controller => "documents"
})
