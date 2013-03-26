Rails.application.routes.draw do
  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do
    resources :documents do
      resources :comments
    end

    get 'autoclassify' => 'autoclassify#from_uri',  :defaults => { :format => 'rdf' }
  end
end
