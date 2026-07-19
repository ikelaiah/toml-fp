#!/usr/bin/env bash
set -euo pipefail

toml_test=${1:?"usage: run-conformance.sh /path/to/toml-test [decoder]"}
decoder=${2:-"$(dirname "$0")/TOMLTestDecoder"}
known_failures="$(dirname "$0")/known-failures.txt"
skip_arguments=()

while IFS= read -r test_name; do
  [[ -z "$test_name" || "$test_name" == \#* ]] && continue
  skip_arguments+=("-skip=$test_name")
done < "$known_failures"

"$toml_test" test -toml 1.0 -skip-must-err \
  "${skip_arguments[@]}" -decoder "$decoder" -color never
