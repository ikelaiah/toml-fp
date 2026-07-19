# TOML-FP v1.0.5

## Release date

2026-07-18

## Highlights

Version 1.0.5 is a release-reliability and TOML 1.0 conformance patch. It fixes clean Release builds, introduces cross-platform CI, measures official decoder conformance, and resolves several parser correctness issues found by that suite.

## Fixed

- Clean Release builds now resolve the units in `src` without relying on stale compiler output.
- Dotted key-value expressions create nested tables; quoted key components containing dots remain literal.
- Arrays accept TOML trailing commas.
- Offset datetime serialization preserves numeric offsets, and date/time values retain their TOML kind and original representation.
- Lowercase datetime separators (`t` and `z`) are accepted and serialized canonically.
- Unterminated strings, newlines in single-line strings, disallowed control characters, bare carriage returns, uppercase booleans, signed base integers, and uppercase base prefixes are rejected.
- Scalar values are freed if scanning the following token fails.

## CI and tests

- GitHub Actions builds the package and runs clean Debug and Release tests on Linux and Windows with Lazarus 4.8 / FPC 3.2.2, matching the locally validated toolchain.
- The project suite has 75 tests with zero errors, failures, or Debug heap leaks.
- The pinned `toml-test` v2.2.0 TOML 1.0 decoder baseline passes 186/205 valid cases and rejects 431/474 invalid cases.
- All 62 outstanding conformance gaps are listed in `tests/conformance/known-failures.txt`; `-skip-must-err` makes stale exclusions fail CI.

## Scope deferred beyond 1.0.5

- The 62 named decoder conformance gaps, primarily table redefinition rules, UTF-8 validation, multiline edge cases, bare-key forms, and date/integer boundaries.
- Official encoder conformance.
- Performance work and larger API changes.

## Compatibility

- Minimum supported compiler: Free Pascal 3.2.2.
- Minimum and tested IDE: Lazarus 4.8.
- Existing date/time construction remains source-compatible; `TTOMLDateTime.Kind` and `RawValue` are additive read-only metadata.
- This is intended as a safe patch-level upgrade from v1.0.4.
