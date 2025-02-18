require 'iqvoc/environments/test'

if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.configure do
    Iqvoc::Environments::Test.setup(config)
  end
end
