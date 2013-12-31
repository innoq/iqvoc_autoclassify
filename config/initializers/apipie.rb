Apipie.configure do |config|
  config.api_controllers_matcher += [
    "#{IqvocAutoclassify.root}/app/controllers/*.rb",
    "#{IqvocAutoclassify.root}/app/controllers/documents/*.rb"
  ]
end
