# Iqvoc::AutoClassify

This is the iQvoc AutoClassify extension. Use this in your Gemfile to add AutoClassify features to iQvoc.

Iqvoc::AutoClassify may run in two different modes: Standalone as Application and embedded into another Application as Engine.

## Standalone Application

Operate Iqvoc::AutoClassify like a common iQvoc-based Application.

1. Run database migrations:
    `rake iqvoc:db:migrate_all`
2. Populate iQvoc seeds:
    `rake iqvoc:db:seed_all`

## Engine

Operate Iqvoc::AutoClassify and Iqvoc as Engines running in a custom App.

1. Add iqvoc_autoclassify to your Gemfile (beneath iqvoc)
2. Run database migrations:
    `rake iqvoc:db:migrate_all`
3. Populate iQvoc seeds:
    `rake iqvoc:db:seed_all`
