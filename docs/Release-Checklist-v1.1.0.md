# TOML-FP v1.1.0 release checklist

## Scope

- [x] Support the TOML 1.1.0 additions: `\e`, `\xHH`, optional seconds, multi-line inline tables with trailing commas.
- [x] Close all 35 guarded `toml-test` gaps (table definition rules, UTF-8 validation, multiline quotes, and others).
- [x] Move the conformance gate to the TOML 1.1 profile.
- [x] Expand focused project regression coverage from 82 to 94 tests.
- [x] Add CI checks: Debug leak gate, example builds, release-metadata check, tag-driven release job, Dependabot.
- [x] Set the release date to 2026-10-30.
- [x] Synchronize package, README, changelog, coverage, conformance, and release-note metadata at version 1.1.0.

## Local gate

- [x] Build the Lazarus package from scratch.
- [x] Build and run all 94 Debug tests; confirm zero errors, failures, and heap leaks.
- [x] Build and run all 94 Release tests.
- [x] Build all seven projects under `examples/`.
- [x] Run `toml-test` v2.2.0 with `-toml 1.1`; confirm 214 valid passes, 467 invalid passes, and no skips.
- [x] Run `bash scripts/check-release-metadata.sh`.
- [ ] Run `git diff --check` and review the complete `v1.0.6..HEAD` diff.

## GitHub gate

- [ ] Push `feature/v1.1.0` and open a pull request (ask the maintainer first).
- [ ] Require the Linux, Windows, conformance, and metadata jobs to pass.
- [ ] Merge only after review confirms the changes in the "Compatibility" section of the release notes are acceptable.

## Publish

- [ ] Confirm `packages/lazarus/toml_fp.lpk` and the README badge both say 1.1.0.
- [ ] Create annotated tag `v1.1.0` from the reviewed merge commit. The `release` job in `ci.yml` verifies the tag against the package version and publishes `docs/Release-Notes-v1.1.0.md`.
- [ ] Verify the release archive contains source and package files, but no compiled artifacts.
