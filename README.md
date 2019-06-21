# Coditsu Offending Sources

[![CircleCI](https://circleci.com/gh/coditsu/offending-sources/tree/master.svg?style=svg)](https://circleci.com/gh/coditsu/offending-sources/tree/master)

Live sources for the Offending Engine for RubyGems details data.

In order to run, Coditsu engine, for some of the validators requires an always up to date stream of information.

This repository provides this data in form of files or API endpoints, so while running build we can query this data.

Note: it does not store any informations, nor it requires any authentication.

## Usage

```ruby
bundle exec rails s
```

## Note on contributions

First, thank you for considering contributing to Coditsu ecosystem! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs and meet our quality requirements.

To check if everything is as it should be, we use [Coditsu](https://coditsu.io) that combines multiple linters and code analyzers for both code and documentation. Once you're done with your changes, submit a pull request.

Coditsu will automatically check your work against our quality standards. You can find your commit check results on the [builds page](https://app.coditsu.io/coditsu/commit_builds) of Coditsu organization.

[![coditsu](https://coditsu.io/assets/quality_bar.svg)](https://app.coditsu.io/coditsu/commit_builds)
