Rails.application.routes.draw do
  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do
    resources :documents do
      resources :comments
    end

    post 'documents/extracted' => 'documents/extracted#create', :as => 'extracted_documents'
    post 'documents/plain' => 'documents/plain#create', :as => 'plain_documents'

    # post 'autoclassify' => 'documents/extracted#create'
  end
end
