require 'iqvoc/environments/development'

if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.configure do
    Iqvoc::Environments.setup_development(config)
  end
end
