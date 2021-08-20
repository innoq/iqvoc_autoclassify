Rails.application.routes.draw do
  scope ':lang', constraints: Iqvoc.routing_constraint do
    resources :documents do
      resources :comments
    end

    get 'classification' => 'classification#index'
    get 'freeclassify' => 'free_classification#index'
    get 'autoclassify' => 'documents#new'

    get  'autoclassify/extract' => 'documents/extracted#create'
    post 'autoclassify/extract' => 'documents/extracted#create',
         as: 'extracted_documents',
         commit: /.+/

    get  'autoclassify/plain' => 'documents/plain#create'
    post 'autoclassify/plain' => 'documents/plain#create',
         as: 'plain_documents',
         commit: /.+/
  end
end
