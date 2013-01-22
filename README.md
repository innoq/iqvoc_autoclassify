# Iqvoc::AutoClassify

This is the iQvoc AutoClassify extension. Use this in your Gemfile to add AutoClassify features to iQvoc.

Iqvoc::AutoClassify may run in two different modes: Standalone as Application and embedded into another Application as Engine.

## Standalone Application

Operate Iqvoc::AutoClassify like a common iQvoc-based Application.

1. Run database migrations:
    `rake db:migrate`
2. Populate iQvoc seeds:
    `rake iqvoc:db:seed_all`

## Engine

Operate Iqvoc::AutoClassify and Iqvoc as Engines running in a custom App.

1. Add iqvoc_autoclassify to your Gemfile (beneath iqvoc)
2. Run database migrations:
    `rake db:migrate`
3. Populate iQvoc seeds:
    `rake iqvoc:db:seed_all`
    
## Release

### Prerequisites

As iqvoc_autoclassify is closed source it cannot be pushed to Rubygems. Therefore
you have to use [iq_gem](https://github.com/innoq/iq_gem) in order to push it to 
gems.innoq.com.

1. Make your changes, commit them
2. Increment `lib/iqvoc/autoclassify/version.rb` and commit
3. Create a tag referencing the last commit:<br />`$ git tag v1.2.7 -am "v1.2.7"
4. Push changes and tags: `$ git push origin master --tags`
5. Build the .gem file and push it to gems.innoq.com:<br />
`$ iq_gem --gemspec iqvoc_autoclassify.gemspec --tag v1.2.7 --gem-repo iqvoc`
