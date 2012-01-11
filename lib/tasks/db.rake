# encoding: UTF-8

if Iqvoc::AutoClassify.const_defined?(:Application)
  namespace :db do

    task :migrate_all => :environment do
      Iqvoc.invoke_engine_tasks "db:migrate", %w(iqvoc iqvoc_skosxl iqvoc_umt)
    end

    task :seed_all => :environment do
      Iqvoc.invoke_engine_tasks "db:seed", %w(iqvoc iqvoc_skosxl iqvoc_umt)
    end

  end
end
