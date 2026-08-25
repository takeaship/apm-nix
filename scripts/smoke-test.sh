#!/usr/bin/env bash

set -euo pipefail

readonly system="${1:?usage: smoke-test.sh SYSTEM [VERSION]}"
readonly expected_version="${2:-$(nix eval --raw --file version.nix version)}"

nix flake check --no-build
result_path="$(nix build --no-link --print-out-paths ".#packages.$system.apm")"
reported="$("$result_path/bin/apm" --version)"
[[ "$reported" == *"$expected_version"* ]] || {
  printf 'Unexpected version: %s\n' "$reported" >&2
  exit 1
}
