# Test Coverage Overview

TOML-FP v1.0.6 uses two complementary test layers.

## Project suite

The FPCUnit project contains 82 tests covering:

- scalar values, arrays, inline tables, tables, and arrays of tables;
- parsing and serialization, including hierarchical and literal dotted keys;
- Unicode escapes, multiline strings, numeric formats, and all four TOML date/time kinds;
- invalid syntax, duplicate keys, strict lexical rules, and parse-error ownership;
- v1.0.5 regressions for trailing commas, nested dotted key-values, date/time offset preservation, and clean Debug/Release builds;
- v1.0.6 regressions for numeric/date-like bare keys, numeric dotted paths, table-name components, multiline-key rejection, required line boundaries, and key serialization round trips.

The Debug build runs with `heaptrc`; the release gate requires 82 tests, zero errors, zero failures, and zero unfreed blocks. The v1.0.6 local gate used Lazarus 4.8 and FPC 3.2.2.

## Official conformance suite

CI pins [`toml-test`](https://github.com/toml-lang/toml-test) v2.2.0 to the TOML 1.0 profile through `tests/conformance/TOMLTestDecoder.lpr`.

- Valid decoder cases: 199 of 205 pass.
- Invalid decoder cases: 445 of 474 are rejected.
- Known gaps: 35 named exclusions guarded by `-skip-must-err`.
- Encoder cases: not yet covered.

See [`tests/conformance/README.md`](../tests/conformance/README.md) for build and run instructions. The measured figures are deliberately more precise than a blanket “fully compliant” claim.
