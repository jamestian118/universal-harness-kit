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
  echo "[test_new_project] FAIL: $*" >&2
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
    echo "[test_new_project] expected output to contain: $needle" >&2
    cat "$output_file" >&2
    fail "output mismatch"
  fi
}

TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/uhk-test-new-project.XXXXXX")"
OUTPUT_FILE="$TEST_TMP/output.log"
DEST_ROOT="$TEST_TMP/workspace"
PROJECT_NAME="phase4-new-project"
PROJECT_DIR="$DEST_ROOT/$PROJECT_NAME"

exit_code="$(run_capture "$OUTPUT_FILE" ./new_project.sh --help)"
[[ "$exit_code" -eq 0 ]] || fail "--help should exit 0, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "用法："

exit_code="$(run_capture "$OUTPUT_FILE" ./new_project.sh "BadName" --lang python --dest "$DEST_ROOT")"
[[ "$exit_code" -eq 2 ]] || fail "invalid project name should exit 2, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "project-name 不合法"

exit_code="$(run_capture "$OUTPUT_FILE" ./new_project.sh "valid-name" --lang rust --dest "$DEST_ROOT")"
[[ "$exit_code" -eq 2 ]] || fail "unsupported lang should exit 2, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "不支持的 lang：rust"

exit_code="$(run_capture "$OUTPUT_FILE" env \
  GIT_AUTHOR_NAME="UHK Test" \
  GIT_AUTHOR_EMAIL="uhk-test@example.com" \
  GIT_COMMITTER_NAME="UHK Test" \
  GIT_COMMITTER_EMAIL="uhk-test@example.com" \
  ./new_project.sh "$PROJECT_NAME" --lang generic --dest "$DEST_ROOT")"
[[ "$exit_code" -eq 0 ]] || fail "new project creation should exit 0, got $exit_code"

[[ -d "$PROJECT_DIR" ]] || fail "project directory missing: $PROJECT_DIR"
[[ -f "$PROJECT_DIR/README.md" ]] || fail "README.md missing in project root"
[[ -d "$PROJECT_DIR/.git" ]] || fail "git repository not initialized"
[[ -x "$PROJECT_DIR/.githooks/pre-commit" ]] || fail "pre-commit hook is not executable"

if grep -R -I -n --exclude-dir=.git "__PROJECT_NAME__" "$PROJECT_DIR" >/dev/null 2>&1; then
  fail "placeholder __PROJECT_NAME__ still exists after scaffold"
fi

if ! git -C "$PROJECT_DIR" log --oneline -1 | grep -Fq "init: scaffold from universal-harness-kit (generic profile)"; then
  fail "initial scaffold commit message mismatch"
fi

exit_code="$(run_capture "$OUTPUT_FILE" ./new_project.sh "$PROJECT_NAME" --lang generic --dest "$DEST_ROOT")"
[[ "$exit_code" -eq 2 ]] || fail "re-creating existing project should exit 2, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "目标目录已存在"

echo "[test_new_project] PASS"
