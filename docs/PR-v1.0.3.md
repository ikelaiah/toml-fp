# PR: Fix array-of-tables dotted table path parsing (`v1.0.3`)

## Summary

This PR fixes parsing for TOML array-of-tables paths where an intermediate key resolves to an array, such as:

```toml
[[fruits]]
name = "apple"
[fruits.physical]
color = "red"
```

Previously, the parser raised:
`Key fruits is not a table`

## Root Cause

During dotted table path traversal, intermediate keys were required to be `TTOMLTable`.  
For array-of-tables, the intermediate key is `TTOMLArray`, and the parser must resolve to the last table item in that array.

## Changes

- Updated parser traversal logic in `src/TOML.Parser.pas`:
  - When an intermediate path value is `TTOMLArray`, resolve to the last array element.
  - Raise a clear error if the array is empty.
  - Keep strict type validation for non-table values.
- Improved error wording for invalid intermediate path types:
  - `Key %s is not a table or array of tables ...`
- Added regression test in `tests/TestCaseTOML.pas`:
  - `Test69_1_ArrayOfTablesWithSubtables`
  - Covers:
    - `[[fruits]]`
    - `[fruits.physical]`
    - `[[fruits.varieties]]`
    - multiple fruits with nested varieties
- Documentation/version updates:
  - `README.md` version badge bumped to `1.0.3`
  - test counts updated to `60`
  - sample test output refreshed
  - `CHANGELOG.md` updated with `v1.0.3` entry

## Validation

Executed:

```bash
./TestRunner.exe -a --format=plain
```

Result:

- Number of run tests: `60`
- Errors: `0`
- Failures: `0`
- Unfreed memory blocks: `0`

## Compatibility / Risk

- Scope is limited to parser table-path traversal.
- Existing table/array behavior is preserved.
- Risk is low and covered by regression + full test suite.

## Checklist

- [x] Bug reproduced from user report
- [x] Parser fix implemented
- [x] Regression test added
- [x] Full test suite passed
- [x] Changelog updated
- [x] README updated
