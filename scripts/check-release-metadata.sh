#!/usr/bin/env bash
# Verifies that version, test-count and release metadata agree across the repo.
#
# Usage: scripts/check-release-metadata.sh [tag]
#
# The package version in packages/lazarus/toml_fp.lpk is the source of truth.
# When a tag (for example v1.1.0 or v1.1.0-rc1) is given, or GITHUB_REF_NAME
# holds one, it must match that version as well.
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

lpk=packages/lazarus/toml_fp.lpk
version_line=$(tr -d '\r' < "$lpk" | grep -E '^\s*<Version Major=' | head -n 1 || true)
if [[ -z "$version_line" ]]; then
  echo "FAIL: no <Version Major=...> element found in $lpk" >&2
  exit 1
fi

attribute() {
  local value
  value=$(sed -n "s/.*${1}=\"\([0-9]*\)\".*/\1/p" <<< "$version_line")
  echo "${value:-0}"
}
version="$(attribute Major).$(attribute Minor).$(attribute Release)"
echo "Package version: $version"

require_text() {
  local file=$1 pattern=$2 description=$3
  if [[ ! -f "$file" ]]; then
    fail "$file is missing ($description)"
  elif ! grep -q -E -- "$pattern" "$file"; then
    fail "$file does not mention $description"
  fi
}

escaped_version=${version//./\\.}
require_text README.md "Version-${escaped_version}-" "version badge ${version}"
require_text CHANGELOG.md "^### v${escaped_version} " "a v${version} entry"
require_text docs/Test-Coverage-Overview.md "v${escaped_version}" "v${version}"
require_text tests/conformance/README.md "v${escaped_version}" "the v${version} baseline"
require_text "docs/Release-Notes-v${version}.md" "v${escaped_version}" "v${version}"

# The newest changelog entry must be the packaged version.
latest=$(tr -d '\r' < CHANGELOG.md | sed -n 's/^### v\([0-9][0-9.]*\) .*/\1/p' | head -n 1)
if [[ "$latest" != "$version" ]]; then
  fail "newest CHANGELOG entry is v${latest}, expected v${version}"
fi

# Published test count must match the test methods declared in the suite.
test_count=$(tr -d '\r' < tests/TestCaseTOML.pas | grep -c -E '^    procedure Test[0-9]')
echo "Project tests: $test_count"

# Reports every test count that a text mentions ("94 tests", "94 Debug tests",
# "N:94", "Number of run tests: 94") and fails when it differs from the suite.
check_counts() {
  local label=$1 count
  while read -r count; do
    if [[ -n "$count" && "$count" != "$test_count" ]]; then
      fail "$label mentions $count tests but the suite declares $test_count"
    fi
  done < <(grep -o -E '[0-9]+ ([A-Za-z]+ )?tests|N:[0-9]+|run tests: [0-9]+' \
    | grep -o -E '[0-9]+' | sort -u)
}

for file in README.md docs/Test-Coverage-Overview.md \
    "docs/Release-Notes-v${version}.md" "docs/Release-Checklist-v${version}.md"; do
  [[ -f "$file" ]] && check_counts "$file" < "$file"
done
# Older changelog entries legitimately cite older counts; check only the newest.
tr -d '\r' < CHANGELOG.md | awk '/^### v/{n++} n==1' | check_counts "newest CHANGELOG entry"

# Compiled output must never be tracked.
tracked_artifacts=$(git ls-files | grep -E '\.(exe|o|ppu|a|dll|so|dylib|dbg|compiled|lps)$' || true)
if [[ -n "$tracked_artifacts" ]]; then
  fail "compiled or IDE-generated files are tracked:"
  echo "$tracked_artifacts" >&2
fi

tag=${1:-}
if [[ -z "$tag" && "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
  tag=${GITHUB_REF_NAME:-}
fi
if [[ -n "$tag" ]]; then
  echo "Release tag: $tag"
  if [[ "$tag" != "v${version}" && "$tag" != v${version}-* ]]; then
    fail "tag $tag does not match package version v${version}"
  fi
fi

if (( failures > 0 )); then
  echo "$failures metadata check(s) failed" >&2
  exit 1
fi
echo "Release metadata is consistent."
