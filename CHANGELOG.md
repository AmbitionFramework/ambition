# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased] 0.2.0
### Added
- New Routing
  - Renamed Actions to Routes
  - Removed actions.conf and the parsing of actions.conf
  - Restructured Application subclasses to now call create_routes, and the
    content of that method will now add application routes via code instead of
    config
  - Support marshalling of requests and responses in a route
  - Allow routes to call multiple targets with multiple marshallers
  - Deprecate ServiceThing, as the functionality is now merged with Ambition
  - Remove IActionFilter
  - Alter scaffold to support new Routes
  - Controller methods are now static methods, and can be one of four method
    signatures depending on input/output

### Changed
- Incremented library version from 0.1 to 0.2
- Now requires Vala >= 0.54
- Now requires log4vala 0.2
- Migrated from CMake to Meson

### Fixed

### Removed/Deprecated
- Deprecate assert_* methods in Testing library, as using those makes it more
  difficult to determine which test failed. Methods exist without the assert_
  prefix, and recommendation is now to call assert( content_is(foo) ) instead of
  assert_content_is(foo)

[Unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...HEAD
