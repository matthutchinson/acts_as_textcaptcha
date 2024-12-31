# ChangeLog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][KeepAChangelog] and this project
adheres to [Semantic Versioning][Semver].

## [Unreleased]

- Your contribution here!

## [4.7.1] - 2024-12-31
### Changed
- CI covers Latest Rails version 8
- Push gems with bundler

## [4.7.0] - 2024-10-03
### Changed
- CI covers Latest Rails version 7, 6 and Ruby 3.1 -> 3.4
- Removed Apprasial
- Added GH workflow
- Dropped rubocop, simplecov

## [4.6.0] - 2022-02-14
### Changed
- CI covers Latest Rails version 7 and Ruby 3.1
- Use `YAML.safe_load` and allow aliases

## [4.5.2] - 2021-01-28
### Changed
- CI covers Latest Rails version 6,5,4 and Ruby 3,2.7,2.6,2.5
### Removed
- Support for Ruby < 2.5 (EOL versions not supported)
- No longer testing against Rails 3 in CI

## [4.5.1] - 2020-01-28
### Fixed
- add Rails Railtie to fix rake task loading
### Removed
- Support for Ruby < 2.4 (EOL versions not supported)

## [4.5.0] - 2019-04-22
### Added
- `# frozen_string_literal: true` to all Ruby files

### Removed
- Support for Ruby < 2.3 (earlier versions no longer supported)

## [4.4.1] - 2018-05-20
### Changed
- Fetch from JSON endpoint, rather than XML
- Regular MiniTest used for tests
- Update README, LICENSE, CHANGELOG, gemspec etc.

### Added
- Test against Rails 5.1.5
- API/network errors logged by default
- Allow API/network errors to be raised with `raise_errors` option
- Allow endpoint to be configured with `api_endpoint` option

### Removed
- Coveralls (now Code Climate & SimpleCov)

## [4.3.0] - 2018-02-18
### Changed
- Update README, fixed Code Climate

### Removed
- Support for Ruby 2.0

## [4.2.0] - 2018-01-17
### Changed
- Updated Rubies for Travis CI.
- Update tests to remove MiniTest warnings.
- Latest Rails (~> 5.1.4) now set in gemspec.

## [4.1.3] - 2016-0-28
### Changed
- Updated gem dependencies.
- Switched from FakeWeb to Webmock.
- Cleaned up Rakefile.
- README now in markdown, badges fixed up.

### Added
- bin/console
- MIT license and Code of Conduct.

### Removed
- Pry gem (dev dependency)

## [4.1.2] - 2014-05-11
### Changed
- Updated gem dependencies.

### Added
- `rake console` for helpful debugging.

## [4.1.1] 2014-01-13
### Removed
- gem [signing & cert](http://tinyurl.com/p98owwz).

## [4.1.0] - 2014-01-02
### Added
- CHANGELOG (this file) added.

### Removed
- Support for Rails 2.

## [4.0.0] - 2014-01-01
### Changed
- Using a cache store to persist answers between requests.
- README updated.
- Test coverage improved.

[Unreleased]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.7.0...HEAD
[4.7.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.6.0...v4.7.0
[4.6.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.5.2...v4.6.0
[4.5.2]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.5.1...v4.5.2
[4.5.1]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.5.0...v4.5.1
[4.5.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.4.1...v4.5.0
[4.4.1]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.3.0...v4.4.1
[4.3.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.2.0...v4.3.0
[4.2.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.1.3...v4.2.0
[4.1.3]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.1.2...v4.1.3
[4.1.2]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.1.1...v4.1.2
[4.1.1]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.1.0...v4.1.1
[4.1.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/matthutchinson/acts_as_textcaptcha/compare/v3.0.11...v4.0.0
[KeepAChangelog]: http://keepachangelog.com/en/1.0.0/
[Semver]: http://semver.org/spec/v2.0.0.html
