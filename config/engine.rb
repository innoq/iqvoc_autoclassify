require 'rails'

# An engine doesn't require it's own dependencies automatically.
require 'responders'
require 'pragmatic_segmenter'

module Iqvoc
  module AutoClassify

    class Engine < Rails::Engine
      paths['lib/tasks'] << 'lib/engine_tasks'

      initializer 'iqvoc_autoclassify.load_migrations' do |app|
        app.config.paths['db/migrate'].concat(Iqvoc::AutoClassify::Engine.paths['db/migrate'].existent)
      end
    end

  end
end
