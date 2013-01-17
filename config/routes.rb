Rails.application.routes.draw do
  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do
    resources :documents do
      resources :comments
    end

		match 'autoclassify' => 'autoclassify#from_content',  :via => [:post],  :defaults => { :format => 'rdf' }
		match 'autoclassify' => 'autoclassify#from_uri',  :via => [:get],  :defaults => { :format => 'rdf' }
  end
end
