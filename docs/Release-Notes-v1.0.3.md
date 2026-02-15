# TOML-FP v1.0.3

## Release Date

2026-02-15

## Highlights

This patch release fixes a TOML parser issue with array-of-tables path resolution.

## Fixed

- Fixed parsing of dotted table paths when an intermediate key is an array of tables.
- Example now supported:
  - `[[fruits]]`
  - `[fruits.physical]`
  - `[[fruits.varieties]]`
- Improved parser error messaging for invalid intermediate path values:
  - now reports: `table or array of tables`

## Tests

- Added regression test:
  - `Test69_1_ArrayOfTablesWithSubtables`
- Full suite status:
  - `60` tests run
  - `0` errors
  - `0` failures
  - `0` memory leaks reported by `heaptrc`

## Files Updated

- `src/TOML.Parser.pas`
- `tests/TestCaseTOML.pas`
- `CHANGELOG.md`
- `README.md`

## Upgrade Notes

- No API changes.
- Safe patch-level upgrade from `v1.0.2` to `v1.0.3`.
