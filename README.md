# Iqvoc::AutoClassify

This is the iQvoc AutoClassify extension. Use this in your Gemfile to add AutoClassify features to iQvoc.

Iqvoc::AutoClassify may run in two different modes: Standalone as Application and embedded into another Application as Engine.

## Standalone Application

Operate Iqvoc::AutoClassify like a common iQvoc-based Application.

1. Run Iqvoc database migrations:
    `rake iqvoc:db:migrate`
2. Run Iqvoc:SKOSXL migrations:
    `rake iqvoc_skosxl:db:migrate`
3. Run Iqvoc:UMT migrations:
    `rake iqvoc_umt:db:migrate`
4. Run Iqvoc::AutoClassify migrations:
    `rake db:migrate`
5. Populate Iqvoc seeds:
    `rake iqvoc:db:seed`
6. Populate Iqvoc:AutoClassify seeds:
    `rake db:seed`

## Engine

Operate Iqvoc::AutoClassify and Iqvoc as Engines running in a custom App.

1. Add iqvoc_autoclassify to your Gemfile (beneath iqvoc)
2. Run Iqvoc migrations:
    `rake iqvoc:db:migrate`
3. Run Iqvoc:SKOSXL migrations:
    `rake iqvoc_skosxl:db:migrate`
4. Run Iqvoc:UMT migrations:
    `rake iqvoc_umt:db:migrate`
5. Run Iqvoc:AutoClassify migrations:
    `rake iqvoc_autoclassify:db:migrate`
6. Run your own migrations:
    `rake db:migrate`
7. Populate Iqvoc seeds:
    `rake iqvoc:db:seed`
8. Populate Iqvoc:AutoClassify seeds:
    `rake iqvoc_autoclassify:db:seed`
9. Populate your applications seeds:
    `rake db:seed`
