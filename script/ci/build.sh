#!/bin/bash -e
source "/usr/local/rvm/scripts/rvm"

# rubies=( "ruby-1.8.7" "ruby-1.9.2" "ruby-1.9.3" "jruby-1.6.5" )

# for ruby in ${rubies[@]}
# do
#   rvm use $ruby
# done

export DISPLAY=:0

rvm use jruby-1.6.7

cp config/database.ci.yml config/database.yml
bundle install
bundle exec rake iqvoc:db:migrate_all RAILS_ENV=test
bundle exec rake test
