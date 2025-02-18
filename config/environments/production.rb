require 'iqvoc/environments/production'

if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.configure do
    Iqvoc::Environments::Production.setup(config)
  end
end
