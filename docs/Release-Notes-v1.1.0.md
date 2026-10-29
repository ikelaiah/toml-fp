# TOML-FP v1.1.0

## Release date

2026-10-30

## Highlights

Version 1.1.0 moves TOML-FP from TOML 1.0 to [TOML 1.1.0](https://toml.io/en/v1.1.0), released in December 2025. It also closes every gap that the pinned `toml-test` suite reported in 1.0.6: the decoder now passes all 214 valid cases and rejects all 467 invalid cases of the TOML 1.1 profile.

## Added

- `\e` (U+001B) and `\xHH` (U+0000 to U+00FF) escapes in basic and multiline basic strings.
- Optional seconds in local times, local date-times and offset date-times, such as `07:32` or `1979-05-27 07:32Z`.
- Newlines, comments and trailing commas inside inline tables.

## Fixed

- Table redefinition, dotted-key extension of tables owned by another section, extension of inline tables and extension of static arrays are rejected with `ETOMLParserException`.
- `[[array]]` headers require adjacent opening and closing brackets.
- Input that is not valid UTF-8 is rejected, and a leading byte order mark is skipped.
- Bare carriage returns in strings are rejected.
- Multiline strings accept three to five closing quotes, so `""""quoted""""` parses.
- A local date followed by a space and a comment (`d = 1979-05-27 # note`) no longer loses its date.
- `-9223372036854775808` is accepted as an `Int64`.
- The serializer escapes DEL in strings and keys.

## Changed

- The serializer always writes seconds in date/time values (`07:32` becomes `07:32:00`), so output stays readable by TOML 1.0 parsers.
- The conformance gate runs against the TOML 1.1 profile. `tests/conformance/known-failures.txt` is empty.

## CI and tests

- The project suite has 94 tests (82 before) with zero errors, failures or Debug heap leaks.
- `toml-test` v2.2.0, TOML 1.1 profile: 214/214 valid and 467/467 invalid cases.
- CI now fails on Debug heap leaks, builds every project under `examples/`, verifies release metadata with `scripts/check-release-metadata.sh`, and publishes a GitHub release from these notes when a `v*` tag passes all jobs.
- Dependabot keeps the SHA-pinned GitHub Actions current.

## Scope deferred beyond 1.1.0

- Official encoder conformance.
- A TOML 1.0-only strict mode.
- Performance work and public API changes.

## Compatibility

- Minimum supported compiler: Free Pascal 3.2.2.
- Minimum and tested IDE: Lazarus 4.8.
- Two small additions, no breaking API changes: `TTOMLDateTime.CanonicalText` returns the normalized RFC 3339 text used by the serializer, and `TToken` in `TOML.Parser` gained a `SpaceBefore` field, which only matters to code that drives the lexer directly.
- Documents that earlier versions accepted by silently merging redefined tables, or that contain bytes that are not valid UTF-8, now raise `ETOMLParserException`. Both were invalid TOML.
