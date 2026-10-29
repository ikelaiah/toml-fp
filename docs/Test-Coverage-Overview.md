# Test Coverage Overview

TOML-FP v1.1.0 uses two complementary test layers.

## Project suite

The FPCUnit project contains 94 tests covering:

- scalar values, arrays, inline tables, tables, and arrays of tables;
- parsing and serialization, including hierarchical and literal dotted keys;
- Unicode escapes, multiline strings, numeric formats, and all four TOML date/time kinds;
- invalid syntax, duplicate keys, strict lexical rules, and parse-error ownership;
- v1.0.5 regressions for trailing commas, nested dotted key-values, date/time offset preservation, and clean Debug/Release builds;
- v1.0.6 regressions for numeric/date-like bare keys, numeric dotted paths, table-name components, multiline-key rejection, required line boundaries, and key serialization round trips;
- v1.1.0 coverage for `\e` and `\xHH` escapes, optional seconds (including serialization with seconds), multi-line inline tables with comments and trailing commas, table redefinition rules (rejected and valid forms), multiline-string quote runs, bare carriage returns, invalid UTF-8 and byte order marks, `Int64` boundaries, `[[array]]` bracket adjacency, a local date before a comment, and DEL escaping in the serializer.

The Debug build runs with `heaptrc`; the release gate requires 94 tests, zero errors, zero failures, and zero unfreed blocks. CI enforces the leak check on Windows, and on Linux whenever heaptrc prints its report. The v1.1.0 local gate used Lazarus 4.8 and FPC 3.2.2.

## Official conformance suite

CI pins [`toml-test`](https://github.com/toml-lang/toml-test) v2.2.0 to the TOML 1.1 profile through `tests/conformance/TOMLTestDecoder.lpr`.

- Valid decoder cases: 214 of 214 pass.
- Invalid decoder cases: 467 of 467 are rejected.
- Known gaps: none. `tests/conformance/known-failures.txt` is empty and `-skip-must-err` keeps it honest.
- Encoder cases: not yet covered.

See [`tests/conformance/README.md`](../tests/conformance/README.md) for build and run instructions. The figures describe the decoder only; encoder conformance is a separate, still open item.

## Repository checks

`scripts/check-release-metadata.sh` runs in CI. It verifies that the package version, README badge, newest changelog entry, release notes, and documented test counts agree with each other and with the number of tests in `tests/TestCaseTOML.pas`, and that no compiled files are tracked. The example projects under `examples/` are built from scratch on every CI run.
