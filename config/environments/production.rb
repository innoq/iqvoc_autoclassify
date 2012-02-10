require 'iqvoc/environments/production'

if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.configure do
    Iqvoc::Environments.setup_production(config)
  end
end
