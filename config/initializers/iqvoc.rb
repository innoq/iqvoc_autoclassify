# initializer for both iqvoc and iqvoc_skosxl

Iqvoc.title = "iQvoc AutoClassify"

Iqvoc.navigation_items.insert(-5, { # in front of search, users, instance configuration and about
  :content => proc { link_to "AutoClassify", documents_path }, # XXX: i18n
  :controller => "documents"
})
