# TOML-FP v1.0.5 release checklist

## Scope

- [x] Fix clean Release unit search paths.
- [x] Add clean Debug, Release, and package CI on Linux and Windows.
- [x] Add a pinned official TOML 1.0 decoder conformance gate.
- [x] Fix the parser issues selected from the conformance findings.
- [x] Synchronize package version, changelog, README, contribution guide, coverage notes, and release notes.
- [x] Record deferred conformance work without expanding the patch-release scope.

## Local gate

- [x] Build the Lazarus package from scratch.
- [x] Build and run all 75 Debug tests; confirm zero errors, failures, and heap leaks.
- [x] Build and run all 75 Release tests.
- [x] Build the conformance decoder and run `toml-test` v2.2.0; confirm 184 valid passes, 431 invalid passes, and 64 guarded skips.
- [x] Run `git diff --check` and review the complete `v1.0.4..HEAD` diff.

## GitHub gate

- [ ] Push `release/v1.0.5` and open a pull request.
- [ ] Require both OS matrix jobs and the conformance job to pass.
- [ ] Merge only after review confirms the public API additions are backward compatible.

## Publish

- [ ] Confirm `packages/lazarus/toml_fp.lpk` and the README badge both say 1.0.5.
- [ ] Create annotated tag `v1.0.5` from the reviewed merge commit.
- [ ] Publish the GitHub release using `docs/Release-Notes-v1.0.5.md`.
- [ ] Verify the release archive contains source and package files, but no compiled artifacts.
