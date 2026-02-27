# scripts/verify Usage (中文 + English)

## 中文

### 作用

`scripts/verify` 是 kit root 的最小验证入口，聚焦脚本质量与核心 smoke：

1. `bash -n` 语法检查
2. `shellcheck`（若环境未安装则给出 WARN 并跳过）
3. `new_project.sh --help` smoke
4. `new_project.sh` 项目名正则校验 smoke
5. `agent-policy-stack --json` 输出结构校验（基于 schema）

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

---

## English

### Purpose

`scripts/verify` is the minimal kit-root verification entrypoint focused on script quality and core smoke checks:

1. `bash -n` syntax checks
2. `shellcheck` (warn-and-skip if not installed)
3. `new_project.sh --help` smoke
4. project-name regex validation smoke for `new_project.sh`
5. schema-based structure validation for `agent-policy-stack --json`

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
