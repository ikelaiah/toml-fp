# TOML-FP v1.0.6 release checklist

## Scope

- [x] Use TOML key-specific tokenization without weakening value validation.
- [x] Fix numeric dotted keys and numeric table-name paths.
- [x] Reject multiline keys and missing line boundaries.
- [x] Make decoder float output deterministic across supported platforms.
- [x] Expand focused project regression coverage from 75 to 82 tests.
- [x] Deduplicate and bound CI runs.
- [x] Set the release date to 2026-07-20.
- [x] Synchronize package, README, changelog, coverage, conformance, and release-note metadata.

## Local gate

- [x] Build the Lazarus package from scratch.
- [x] Build and run all 82 Debug tests; confirm zero errors, failures, and heap leaks.
- [x] Build and run all 82 Release tests.
- [x] Run `toml-test` v2.2.0; confirm 199 valid passes, 445 invalid passes, and 35 guarded skips.
- [x] Run `git diff --check` and review the complete `v1.0.5..HEAD` diff.

## GitHub gate

- [ ] Push `release/v1.0.6` and open a pull request.
- [ ] Require the Linux, Windows, and conformance jobs to pass.
- [ ] Merge only after review confirms the patch is backward compatible.

## Publish

- [ ] Confirm `packages/lazarus/toml_fp.lpk` and the README badge both say 1.0.6.
- [ ] Create annotated tag `v1.0.6` from the reviewed merge commit.
- [ ] Publish the GitHub release using `docs/Release-Notes-v1.0.6.md`.
- [ ] Verify the release archive contains source and package files, but no compiled artifacts.
