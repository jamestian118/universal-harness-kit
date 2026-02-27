#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"

TEST_TMP=""

cleanup() {
  if [[ -n "$TEST_TMP" && -d "$TEST_TMP" ]]; then
    rm -rf "$TEST_TMP"
  fi
}
trap cleanup EXIT

fail() {
  echo "[test_bootstrap_stack] FAIL: $*" >&2
  exit 1
}

run_capture() {
  local output_file="$1"
  shift

  set +e
  "$@" >"$output_file" 2>&1
  local exit_code=$?
  set -e

  printf '%s' "$exit_code"
}

assert_output_contains() {
  local output_file="$1"
  local needle="$2"

  if ! grep -Fq -- "$needle" "$output_file"; then
    echo "[test_bootstrap_stack] expected output to contain: $needle" >&2
    cat "$output_file" >&2
    fail "output mismatch"
  fi
}

TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/uhk-test-bootstrap-stack.XXXXXX")"
OUTPUT_FILE="$TEST_TMP/output.log"

exit_code="$(run_capture "$OUTPUT_FILE" ./scripts/bootstrap-stack --help)"
[[ "$exit_code" -eq 0 ]] || fail "--help should exit 0, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "Usage:"

exit_code="$(run_capture "$OUTPUT_FILE" ./scripts/bootstrap-stack --root "$TEST_TMP/missing-root" --dry-run)"
[[ "$exit_code" -eq 2 ]] || fail "missing root should exit 2, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "UHK root 不存在"

exit_code="$(run_capture "$OUTPUT_FILE" ./scripts/bootstrap-stack --root "$ROOT_DIR" --dry-run)"
[[ "$exit_code" -eq 0 ]] || fail "dry-run should exit 0, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "STEP 1/4: render-global-policy"
assert_output_contains "$OUTPUT_FILE" "STEP 2/4: agent-policy-stack strict"
assert_output_contains "$OUTPUT_FILE" "STEP 3/4: agent-policy-stack self-test"
assert_output_contains "$OUTPUT_FILE" "STEP 4/4: verify"
assert_output_contains "$OUTPUT_FILE" "DRY-RUN:"

echo "[test_bootstrap_stack] PASS"
