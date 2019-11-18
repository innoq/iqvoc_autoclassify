Rails.application.routes.draw do
  scope ':lang', constraints: Iqvoc.routing_constraint do
    resources :documents do
      resources :comments
    end

    get 'autoclassify' => 'autoclassify#index'

    get  'autoclassify/extract' => 'documents/extracted#create'
    post 'autoclassify/extract' => 'documents/extracted#create',
        :as => 'extracted_documents',
        :commit => /.+/

    get  'autoclassify/plain' => 'documents/plain#create'
    post 'autoclassify/plain' => 'documents/plain#create',
        :as => 'plain_documents',
        :commit => /.+/

    scope 'documents/:id' do
      get 'classifications/new' => 'classifications#new', as: :new_document_classification
      post 'classifications' => 'classifications#create', as: :document_classifications
      delete 'classifications/:classification_id/destroy' => 'classifications#destroy', as: :document_classification

      put 'classifications/:classification_id/promote' => 'classifications#promote', as: :promote_document_classification
      put 'classifications/:classification_id/demote' => 'classifications#demote', as: :demote_document_classification
    end
  end
end
