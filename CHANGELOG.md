# Change Log

## [0.6.1] - 2017-05-17

### Added

- Add separated methods to clear state [#30](https://github.com/yuya-takeyama/flagship/pull/30)

## [0.6.0] - 2017-05-15

### Added

- Add `Flagship.with_context` method to apply temporal changes to context variables [#26](https://github.com/yuya-takeyama/flagship/pull/26)
- Now `Flagship.clear_state` clears context variables as well [#27](https://github.com/yuya-takeyama/flagship/pull/27)

### Changed

- Allow `Flagship.set_context` to set multiple variables at once using `Hash` [#25](https://github.com/yuya-takeyama/flagship/pull/25)

## [0.5.0] - 2017-01-07

- Documented about helper methods [#21](https://github.com/yuya-takeyama/flagship/pull/21)
- Helper methods can be specified as a `Symbol` [#21](https://github.com/yuya-takeyama/flagship/pull/21)
- Helper methods are extended [#22](https://github.com/yuya-takeyama/flagship/pull/22)

## [0.4.0] - 2016-12-23

### Added

- Added methods to filter `Flagship.features` [#16](https://github.com/yuya-takeyama/flagship/pull/16) [#19](https://github.com/yuya-takeyama/flagship/pull/19)
- `enabled?` method in DSL [#17](https://github.com/yuya-takeyama/flagship/pull/17)
- `Flagship.disabled?` method [#18](https://github.com/yuya-takeyama/flagship/pull/18)

## [0.3.0] - 2016-11-24

### Added

- `with_tags` method to DSL

### Fixed

- Tags are extended from the feature with same key in base flagset

### Removed

- `Flagship.set_flagset` method. Use `Flagship.set_flagset` instead

## [0.2.0] - 2016-11-14

### Added

- `Flagship.features` method to fetch all `Flagship::Feature`
- Tagging
- `Flagship.select_flagset` instead of `Flagship.set_flagset`

### Deprecated

- `Flagship.set_flagset` method

## [0.1.0] - 2016-10-30

### Added

- Initial release
