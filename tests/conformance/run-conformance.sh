#!/usr/bin/env bash
set -euo pipefail

toml_test=${1:?"usage: run-conformance.sh /path/to/toml-test [decoder] [encoder]"}
decoder=${2:-"$(dirname "$0")/TOMLTestDecoder"}
encoder=${3:-"$(dirname "$0")/TOMLTestEncoder"}
known_failures="$(dirname "$0")/known-failures.txt"
skip_arguments=()

while IFS= read -r test_name; do
  test_name=${test_name%$'\r'}
  [[ -z "$test_name" || "$test_name" == \#* ]] && continue
  skip_arguments+=("-skip=$test_name")
done < "$known_failures"

"$toml_test" test -toml 1.1 -skip-must-err \
  ${skip_arguments[@]+"${skip_arguments[@]}"} \
  -decoder "$decoder" -encoder "$encoder" -color never
