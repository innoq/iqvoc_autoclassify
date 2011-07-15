# XXX: should this be moved to config/engine.rb? (cf. iqvoc_skosxl)

require 'rails'

module Iqvoc
  module AutoClassify

    class Engine < Rails::Engine

      paths.lib.tasks  << "lib/engine_tasks"

      def self.load_seed
        seed_file = Iqvoc::AutoClassify::Engine.find_root_with_flag("db").join('db/seeds.rb')
        load(seed_file) if File.exist?(seed_file)
      end

    end

  end
end
