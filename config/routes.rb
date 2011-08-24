Rails.application.routes.draw do
  scope '(:lang)', :lang => /#{Iqvoc::Concept.pref_labeling_languages.join("|").presence || " "}/ do
    resources :documents do
      member do
        post "", :action => "trace"
      end
      resources :comments
    end
  end
end
