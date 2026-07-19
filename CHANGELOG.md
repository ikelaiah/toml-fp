# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


### v1.0.6 - Key Grammar and Parser Hardening (2026-07-21)

- Added context-aware key tokenization so numeric, date-like, leading-zero, and dash-prefixed bare keys no longer inherit value-number validation rules.
- Fixed numeric dotted keys and numeric table-name components so each dot creates the required nested table path.
- Rejected multiline basic and literal strings in keys and table headers.
- Rejected table headers and key-value pairs followed by additional same-line content without a TOML line boundary.
- Made conformance-adapter float output deterministic across Linux and Windows at full `Double` precision.
- Expanded the project suite from 75 to 82 tests with key grammar, rejection, and serialization round-trip coverage.
- Improved the pinned TOML 1.0 decoder baseline to 199/205 valid cases and 445/474 invalid cases, leaving 35 guarded gaps.
- Avoided duplicate branch push and pull-request CI runs, added stale-run cancellation, and added explicit job timeouts.
- Synchronized package, README, coverage, conformance, checklist, and release-note metadata at version 1.0.6.


### v1.0.5 - Conformance and Release Reliability (2026-07-19)

- Fixed clean Release builds by adding the source directory to the Release and global Lazarus project search paths.
- Added Linux and Windows CI for clean package, Debug-test, and Release-test builds with Lazarus 4.8 and FPC 3.2.2.
- Added a pinned `toml-test` v2.2.0 decoder adapter and regression gate. The v1.0.5 baseline passes 186/205 valid cases and rejects 431/474 invalid cases; the 62 remaining gaps are tracked explicitly.
- Fixed dotted key-value parsing so syntactic dotted keys create nested tables while quoted dotted components stay literal.
- Added array trailing-comma support.
- Preserved TOML date/time kinds and original offset syntax for correct serialization, including lowercase `t` and `z` input.
- Tightened lexical validation for unterminated and single-line strings, unescaped control characters, bare carriage returns, case-sensitive booleans, and base-prefixed integers.
- Fixed value ownership when tokenization fails after a parsed scalar, eliminating a parse-error memory leak.
- Expanded the project test suite from 70 to 75 tests and retained zero-error, zero-failure, zero-leak Debug results.
- Synchronized package, README, contribution, coverage, and release-note metadata at version 1.0.5.

### v1.0.4 - Bug Fixes (2026-03-09)

- Implemented TOML 1.0 Unicode escape parsing for basic strings (`\uXXXX` and `\UXXXXXXXX`).
- Added missing basic-string escape support for backspace (`\b`) and form feed (`\f`).
- Fixed multiline string handling to trim the first newline in multiline literal strings and to honor line-ending backslash whitespace trimming in multiline basic strings.
- Fixed local time tokenization and parsing for bare TOML time values such as `07:32:00`.
- Fixed parsing of local datetimes that use a space separator (for example `1979-05-27 07:32:00`) so the time component is preserved.
- Tightened numeric validation to reject invalid underscore placement, decimal leading zeros, and hexadecimal floating-point syntax.
- Fixed basic-string escape validation to reject invalid TOML escapes such as `\'`.
- Fixed serializer output for quoted dotted keys so table headers and arrays of tables preserve literal dotted keys instead of splitting them into paths.
- Added regression coverage for Unicode escapes, multiline string trimming, local-time parsing, space-separated local datetimes, numeric validation, invalid basic-string escapes, inline quoted dotted keys, and quoted array-of-table serialization.

### v1.0.3 - Bug Fixes (2026-02-15)

- Fixed parser navigation for dotted table paths when an intermediate key is an array of tables (e.g., `[fruits.physical]` after `[[fruits]]`).
- Added support for resolving intermediate `TTOMLArray` values to the last table element during table path traversal.
- Improved parser error message to clarify invalid intermediate values as "table or array of tables".
- Added regression test `Test69_1_ArrayOfTablesWithSubtables` for array-of-tables with subtables and nested array-of-tables.

### v1.0.2 - Bug Fixes (2025-05-18)

- Fixed `NeedsQuoting` function to properly conform to TOML specification for bare keys
- Fixed serialization of nested tables to use correct dotted key notation (e.g., `[parent.child]`) instead of separate table declarations
- Fixed proper distinction between hierarchical nested tables and literal dotted keys
- Added dedicated tests for hierarchical nested tables (Test71) and literal dotted keys (Test72)
- Updated documentation to clarify the difference between hierarchical paths and literal dotted keys
- Added best practice recommendations from TOML spec about using bare keys when possible

### v1.0.1 - Bug Fixes (2025-03-24)

- Fixed serialization of arrays of tables to use the proper TOML format (`[[table]]`).
- Fixed parsing of arrays containing inline tables with newlines.
- Added additional test cases to verify these fixes.


## [1.0.0] - 2025-01-01

### Added
- Initial release
- Broad TOML v1.0.0 support across essential data types and structures
- Parsing and serialization functionality
- Comprehensive test suite (53 items)
- Documentation and examples
- Lazarus package
- Updated license and README metadata
