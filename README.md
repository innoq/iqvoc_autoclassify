[![CI](https://github.com/innoq/iqvoc_autoclassify/actions/workflows/ci.yml/badge.svg)](https://github.com/innoq/iqvoc_autoclassify/actions/workflows/ci.yml)

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

Operate Iqvoc::AutoClassify and iQvoc as Engines running in a custom App.

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

### Push

You can bump, tag and push a new gem release with

    $ bundle exec rake release:push[X.X.X]
