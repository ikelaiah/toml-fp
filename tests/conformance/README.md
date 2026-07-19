# TOML conformance tests

`TOMLTestDecoder.lpr` adapts TOML-FP to the tagged JSON protocol used by the
language-agnostic [`toml-test`](https://github.com/toml-lang/toml-test) suite.
CI pins `toml-test` v2.2.0 and tests the TOML 1.0 profile.

The known-failure list is intentional and enforced with `-skip-must-err`.
That means all currently supported official cases are required to keep passing,
and CI also fails when a listed case starts passing until its stale exclusion is
removed. The v1.0.5 baseline is:

- 186 of 205 valid decoder cases pass.
- 431 of 474 invalid decoder cases are rejected.
- Encoder conformance is not yet covered.

Build the decoder from this directory with FPC 3.2.2 or later:

```text
fpc -MObjFPC -Sh -Fu../../src -FUlib -FE. TOMLTestDecoder.lpr
```

Run the pinned suite on Windows:

```powershell
./run-conformance.ps1 -TomlTest C:\path\to\toml-test.exe
```

On Linux or macOS:

```bash
./run-conformance.sh /path/to/toml-test
```
