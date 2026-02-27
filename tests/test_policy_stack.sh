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
  echo "[test_policy_stack] FAIL: $*" >&2
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

run_json_capture() {
  local json_file="$1"
  local err_file="$2"
  shift 2

  set +e
  "$@" >"$json_file" 2>"$err_file"
  local exit_code=$?
  set -e

  printf '%s' "$exit_code"
}

assert_output_contains() {
  local output_file="$1"
  local needle="$2"

  if ! grep -Fq -- "$needle" "$output_file"; then
    echo "[test_policy_stack] expected output to contain: $needle" >&2
    cat "$output_file" >&2
    fail "output mismatch"
  fi
}

write_global_policy_file() {
  local file_path="$1"
  local tool_name="$2"

  mkdir -p "$(dirname "$file_path")"
  cat >"$file_path" <<EOF
# 项目规范
$ROOT_DIR/scripts/agent-policy-stack --tool $tool_name --cwd "\$PWD" --strict --strict-profile harness
Global -> Workflow -> Copy-to-project
入口校验结果为 \`fail\` 时不得跳过
copy_project_root_relaxed: warn
# Policy Stack（Global -> Workflow -> Copy-to-project）
copy_project_root_relaxed: warn
# 联网搜索（强制启用）
local test fixture
EOF
}

setup_fake_home() {
  local fake_home="$1"

  write_global_policy_file "$fake_home/.codex/AGENTS.md" "codex"
  write_global_policy_file "$fake_home/.claude/CLAUDE.md" "claude"
  write_global_policy_file "$fake_home/.gemini/GEMINI.md" "gemini"
}

create_copy_project() {
  local root_dir="$1"
  local mode="$2"

  mkdir -p "$root_dir/subdir"
  cat >"$root_dir/AGENTS.md" <<'EOF'
# copy project fixture
EOF

  if [[ "$mode" == "complete" ]]; then
    mkdir -p "$root_dir/.ai" "$root_dir/scripts" "$root_dir/.claude" "$root_dir/.codex/commands" "$root_dir/.gemini"
    cat >"$root_dir/.ai/handoff.md" <<'EOF'
## 当前状态：fixture
## 下一步：fixture
## 已知问题：none
EOF
    cat >"$root_dir/scripts/verify" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$root_dir/scripts/verify"
    echo "fixture" >"$root_dir/.claude/CLAUDE.md"
    echo "fixture" >"$root_dir/.codex/commands/closeout.md"
    echo "fixture" >"$root_dir/.gemini/GEMINI.md"
  fi
}

assert_json_policy_pass() {
  local json_file="$1"

  python3 - "$json_file" <<'PY'
import json
import sys

path = sys.argv[1]
obj = json.loads(open(path, encoding="utf-8").read())

if obj.get("strict", {}).get("result") != "pass":
    raise SystemExit(f"strict.result should be pass: {obj.get('strict')}")

checks = {item["name"]: item["status"] for item in obj.get("required_checks", [])}
required = [
    "copy_project_root_found",
    "copy_agents_exists",
    "copy_handoff_exists",
    "copy_verify_exists",
    "copy_claude_exists",
    "copy_codex_closeout_exists",
    "copy_gemini_exists",
]
for key in required:
    if checks.get(key) != "pass":
        raise SystemExit(f"{key} should be pass, got {checks.get(key)!r}")
PY
}

assert_json_policy_fail_missing_files() {
  local json_file="$1"

  python3 - "$json_file" <<'PY'
import json
import sys

path = sys.argv[1]
obj = json.loads(open(path, encoding="utf-8").read())

strict = obj.get("strict", {})
if strict.get("result") != "fail":
    raise SystemExit(f"strict.result should be fail: {strict}")

reason = strict.get("reason") or ""
if "missing required files" not in reason:
    raise SystemExit(f"strict.reason should mention missing required files: {reason!r}")
PY
}

assert_json_relaxed_warn() {
  local json_file="$1"

  python3 - "$json_file" <<'PY'
import json
import sys

path = sys.argv[1]
obj = json.loads(open(path, encoding="utf-8").read())

strict = obj.get("strict", {})
if strict.get("result") != "pass":
    raise SystemExit(f"strict.result should be pass in relaxed mode: {strict}")

if strict.get("copy_project_root_required") is not False:
    raise SystemExit(f"copy_project_root_required should be false: {strict}")

checks = {item["name"]: item["status"] for item in obj.get("required_checks", [])}
if checks.get("copy_project_root_relaxed") != "warn":
    raise SystemExit(f"copy_project_root_relaxed should be warn: {checks.get('copy_project_root_relaxed')!r}")
PY
}

TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/uhk-test-policy-stack.XXXXXX")"
OUTPUT_FILE="$TEST_TMP/output.log"
JSON_FILE="$TEST_TMP/output.json"
ERR_FILE="$TEST_TMP/output.err"
FAKE_HOME="$TEST_TMP/home"
COPY_OK="$TEST_TMP/copy-ok"
COPY_FAIL="$TEST_TMP/copy-fail"

setup_fake_home "$FAKE_HOME"
create_copy_project "$COPY_OK" "complete"
create_copy_project "$COPY_FAIL" "minimal"

exit_code="$(run_capture "$OUTPUT_FILE" ./scripts/agent-policy-stack --tool unknown)"
[[ "$exit_code" -eq 2 ]] || fail "invalid --tool should exit 2, got $exit_code"
assert_output_contains "$OUTPUT_FILE" "--tool only supports codex|claude|gemini"

exit_code="$(run_json_capture "$JSON_FILE" "$ERR_FILE" env HOME="$FAKE_HOME" \
  ./scripts/agent-policy-stack --tool codex --cwd "$COPY_OK/subdir" --json --strict --strict-profile harness)"
[[ "$exit_code" -eq 0 ]] || fail "strict harness should pass for complete copy project, got $exit_code"
assert_json_policy_pass "$JSON_FILE"

exit_code="$(run_json_capture "$JSON_FILE" "$ERR_FILE" env HOME="$FAKE_HOME" \
  ./scripts/agent-policy-stack --tool codex --cwd "$COPY_FAIL/subdir" --json --strict --strict-profile harness)"
[[ "$exit_code" -eq 3 ]] || fail "strict harness should fail for incomplete copy project, got $exit_code"
assert_json_policy_fail_missing_files "$JSON_FILE"

exit_code="$(run_json_capture "$JSON_FILE" "$ERR_FILE" env HOME="$FAKE_HOME" \
  ./scripts/agent-policy-stack --tool codex --cwd "$ROOT_DIR" --json --strict --strict-profile harness)"
[[ "$exit_code" -eq 0 ]] || fail "strict harness should relax copy_project_root at workflow root, got $exit_code"
assert_json_relaxed_warn "$JSON_FILE"

if [[ "${AGENT_POLICY_STACK_IN_SELF_TEST:-0}" != "1" ]]; then
  exit_code="$(run_capture "$OUTPUT_FILE" ./scripts/agent-policy-stack --self-test)"
  [[ "$exit_code" -eq 0 ]] || fail "--self-test should exit 0, got $exit_code"
  assert_output_contains "$OUTPUT_FILE" "[agent-policy-stack][self-test] PASS"
fi

echo "[test_policy_stack] PASS"
