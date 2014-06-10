Rails.application.routes.draw do
  scope ':lang', constraints: Iqvoc.routing_constraint do
    resources :documents do
      resources :comments
    end

    get  'autoclassify/extract' => 'documents/extracted#create'
    post 'autoclassify/extract' => 'documents/extracted#create',
        :as => 'extracted_documents',
        :commit => /.+/

    get  'autoclassify/plain' => 'documents/plain#create'
    post 'autoclassify/plain' => 'documents/plain#create',
        :as => 'plain_documents',
        :commit => /.+/
  end
end
