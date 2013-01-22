Rails.application.routes.draw do
  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do
    resources :documents do
      resources :comments
    end

    post 'autoclassify' => 'autoclassify#from_content',  :defaults => { :format => 'rdf' }
    get 'autoclassify' => 'autoclassify#from_uri',  :defaults => { :format => 'rdf' }
  end
end
