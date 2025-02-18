require 'iqvoc/environments/development'

if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.configure do
    Iqvoc::Environments::Development.setup(config)
  end
end
