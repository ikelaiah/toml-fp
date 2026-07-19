# TOML-FP v1.0.6

## Release date

2026-07-20

## Highlights

Version 1.0.6 is a parser-correctness patch focused on TOML key grammar, table-name paths, strict line boundaries, and portable conformance measurement. It improves the pinned TOML 1.0 decoder baseline from 62 guarded gaps to 35 without changing the public API or supported toolchain.

## Fixed

- Numeric, date-like, leading-zero, and dash-prefixed bare keys are tokenized as keys instead of being subjected to value-number or datetime validation.
- Dots in numeric bare keys and numeric table-name components create nested table paths rather than literal dotted key names.
- Multiline basic and literal strings are rejected when used as keys or table headers.
- Table headers and top-level key-value pairs must end at a TOML line boundary; additional same-line assignments are rejected.
- The `toml-test` decoder emits deterministic 17-digit `Double` values on both Linux and Windows.

## CI and tests

- The project suite has 82 tests with zero errors, failures, or Debug heap leaks.
- The pinned `toml-test` v2.2.0 TOML 1.0 decoder baseline passes 199/205 valid cases and rejects 445/474 invalid cases.
- All 35 outstanding conformance gaps remain listed in `tests/conformance/known-failures.txt`; `-skip-must-err` makes stale exclusions fail CI.
- Pull-request branches no longer run duplicate push and pull-request workflows.
- CI cancels stale runs and applies explicit timeouts while retaining Lazarus 4.8 and FPC 3.2.2 on Linux and Windows.

## Scope deferred beyond 1.0.6

- The 35 named decoder gaps, primarily table redefinition rules, invalid UTF-8, inline-table conflicts, multiline-string edge cases, arrays of tables, comments, and integer boundaries.
- Official encoder conformance.
- Performance work and public API changes.

## Compatibility

- Minimum supported compiler: Free Pascal 3.2.2.
- Minimum and tested IDE: Lazarus 4.8.
- No public API changes are introduced.
- This is intended as a safe patch-level upgrade from v1.0.5.
