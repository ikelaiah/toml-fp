# TOML-FP v1.2.0

## Release date

2026-11-17

## Highlights

The serializer now writes what you parsed or built: same key order, exact floats, no lost values. Its output is checked by the official `toml-test` encoder suite (214/214), alongside the decoder suite (214/214 valid, 467/467 invalid). Reading configuration also takes less code:

```pascal
Port := Config.GetInteger(['server', 'port'], 8080);
```

## Added

- `TTOMLTable`: `GetString`, `GetInteger`, `GetFloat`, `GetBoolean` (path plus default), `GetTable`, `GetArray`, `FindPath`, `Find`, `Contains`, `Remove`, `Count`, `Keys[]`, `Values[]`, and `for Pair in Table` in document order.
- `TTOMLArray`: `for Item in Arr`.
- `TTOMLKeyValuePair` in `TOML.Types`, re-exported by `TOML`.
- Encoder conformance adapter `tests/conformance/TOMLTestEncoder.lpr`, run in CI.

## Fixed

- Tables kept no key order; output order was effectively random.
- Arrays mixing tables with other values (`[{ x = 1 }, 2]`) and arrays of arrays of tables were dropped or written as invalid TOML.
- `1.0` serialized as `1`, which reads back as an integer.
- `inf` and `nan` serialized as `+Inf` and `Nan`, which are invalid TOML.
- Floats used the locale decimal separator and only 15 significant digits.
- `TOMLDateTime(Now)` was written with a `Z` (UTC) offset although `TDateTime` has no time zone.
- Duplicate-key errors had no line number.

## Changed

- Output layout: no leading blank line, no header for a table that only holds sub-tables, inline tables written as `{ k = v }`, long arrays wrapped one item per line, `\f` escape for form feed.
- `TTOMLDateTime.Create(TDateTime)` produces `Kind = tdtLocalDateTime`, written as `2026-11-17T09:30:00`; milliseconds appear only when non-zero.
- `SerializeTOMLToFile` writes the serialized bytes directly.

## CI and tests

- The project suite has 108 tests (94 before) with zero errors, failures or Debug heap leaks.
- `toml-test` v2.2.0, TOML 1.1 profile: 214/214 valid, 467/467 invalid, 214/214 encoder.

## Compatibility

- Minimum compiler: Free Pascal 3.2.2. Tested IDE: Lazarus 4.8.
- Source compatible with v1.1.0. Private serializer members were removed.
- Serialized text differs from v1.1.0. Code that compares output text, or relies on `TTOMLDateTime.Create(TDateTime)` having an offset kind, needs updating.
- `Table.Items` is still the underlying dictionary. Add and remove keys through the table so the order stays correct.
