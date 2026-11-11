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

1. Bump the version in `lib/iqvoc/auto_classify/version.rb` and `package.json`
2. Commit and tag the release:
    `git tag -a vX.Y.Z -m "Version X.Y.Z"`
3. Push the commit and the tag:
    `git push origin main vX.Y.Z`
4. Build and publish the gem:
    `gem build iqvoc_autoclassify.gemspec && gem push iqvoc_autoclassify-X.Y.Z.gem`

## Maintainer & Contributors

iQvoc was originally created and is being maintained by [innoQ Deutschland GmbH](http://innoq.com).

* Robert Glaser ([mrreynolds](http://github.com/mrreynolds))
* Till Schulte-Coerne ([tillsc](http://github.com/tillsc))
* Frederik Dohr ([FND](http://github.com/FND))
* Marc Jansing ([mjansing](http://github.com/mjansing))

## License

Copyright 2025 [innoQ Deutschland GmbH](https://www.innoq.com).

Licensed under the Apache License, Version 2.0.
