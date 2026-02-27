# scripts/verify Usage (中文 + English)

## 中文

### 作用

`scripts/verify` 是 kit root 的最小验证入口，聚焦脚本质量与核心 smoke：

1. `bash -n` 语法检查
2. `shellcheck`（若环境未安装则给出 WARN 并跳过）
3. `new_project.sh --help` smoke
4. `new_project.sh` 项目名正则校验 smoke
5. `agent-policy-stack --json` 输出结构校验（基于 schema）
6. shell test suites：`tests/test_new_project.sh` + `tests/test_policy_stack.sh`

### 前置条件

- `bash`
- `python3`
- 建议安装 `shellcheck`（macOS: `brew install shellcheck`）

### 命令

```bash
./scripts/verify
```

### 通过标准

- 所有强制步骤通过，且最终输出 `[verify] OK`
- 如果缺少 `shellcheck`，会输出 WARN 并继续（不阻塞其余步骤）

### 输出示例

```text
[verify] RUN: bash_syntax
[verify] PASS: bash_syntax
[verify] RUN: shellcheck
[verify][shellcheck] WARN: shellcheck 未安装，跳过（建议：brew install shellcheck）
[verify] PASS: shellcheck
[verify] RUN: shell_tests
[verify] PASS: shell_tests
...
[verify] OK
```

### 常见问题

1. `smoke_new_project_name_validation` 失败
- 说明：非法名称没有被正确拦截
- 处理：检查 `new_project.sh` 的项目名正则和错误消息

2. `smoke_policy_json_schema` 失败
- 说明：`agent-policy-stack --json` 输出与 schema 不一致
- 处理：先跑 `./scripts/agent-policy-stack --tool codex --cwd "$PWD" --json` 查看实际输出字段

3. `shell_tests` 失败（`test_new_project.sh`）
- 说明：`new_project.sh` 的行为与契约不一致（如 project-name 校验、scaffold 结果、git 初始化）
- 处理：先单独运行 `./tests/test_new_project.sh`，根据失败断言修复脚本逻辑

4. `shell_tests` 失败（`test_policy_stack.sh`）
- 说明：`agent-policy-stack` 的 strict/harness 行为、JSON 字段或退出码漂移
- 处理：先单独运行 `./tests/test_policy_stack.sh`，再对照 `docs/agent-policy-stack.output.schema.json` 校验输出结构

---

## English

### Purpose

`scripts/verify` is the minimal kit-root verification entrypoint focused on script quality and core smoke checks:

1. `bash -n` syntax checks
2. `shellcheck` (warn-and-skip if not installed)
3. `new_project.sh --help` smoke
4. project-name regex validation smoke for `new_project.sh`
5. schema-based structure validation for `agent-policy-stack --json`
6. shell test suites: `tests/test_new_project.sh` + `tests/test_policy_stack.sh`

### Prerequisites

- `bash`
- `python3`
- `shellcheck` recommended (`brew install shellcheck` on macOS)

### Command

```bash
./scripts/verify
```

### Pass Criteria

- All required steps pass and final line is `[verify] OK`
- Missing `shellcheck` produces WARN and does not block the rest

### Example Output

```text
[verify] RUN: bash_syntax
[verify] PASS: bash_syntax
[verify] RUN: shellcheck
[verify][shellcheck] WARN: shellcheck 未安装，跳过（建议：brew install shellcheck）
[verify] PASS: shellcheck
[verify] RUN: shell_tests
[verify] PASS: shell_tests
...
[verify] OK
```

### Troubleshooting

1. `smoke_new_project_name_validation` fails
- Meaning: invalid names are not rejected as expected
- Fix: inspect project-name regex and error message in `new_project.sh`

2. `smoke_policy_json_schema` fails
- Meaning: `agent-policy-stack --json` output drifts from the schema
- Fix: run `./scripts/agent-policy-stack --tool codex --cwd "$PWD" --json` and compare fields against schema

3. `shell_tests` fails (`test_new_project.sh`)
- Meaning: `new_project.sh` behavior drift (for example: project-name validation, scaffold contract, git init)
- Fix: run `./tests/test_new_project.sh` directly and fix logic based on failing assertions

4. `shell_tests` fails (`test_policy_stack.sh`)
- Meaning: `agent-policy-stack` strict/harness behavior, JSON fields, or exit codes drifted
- Fix: run `./tests/test_policy_stack.sh` directly, then cross-check with `docs/agent-policy-stack.output.schema.json`
