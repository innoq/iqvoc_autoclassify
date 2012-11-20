namespace :iqvoc_autoclassify do
  namespace :db do

    desc "Load seeds (task is idempotent)"
    task :seed => :environment do
      Iqvoc::AutoClassify::Engine.load_seed
    end

  end
end

