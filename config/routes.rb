Iqvoc.localized_routes << lambda do |routing|
  routing.resources :documents do
    routing.resources :comments
  end

  routing.get  'autoclassify/extract' => 'documents/extracted#create'
  routing.post 'autoclassify/extract' => 'documents/extracted#create', :as => 'extracted_documents', :commit => /.+/

  routing.get  'autoclassify/plain' => 'documents/plain#create'
  routing.post 'autoclassify/plain' => 'documents/plain#create', :as => 'plain_documents', :commit => /.+/
end

Rails.application.routes.draw do
  # see above
end
