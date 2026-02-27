# agent-policy-stack Usage (中文 + English)

## 中文

### 作用

`scripts/agent-policy-stack` 是统一入口检查脚本，用于在 agent 开始执行前先完成三段链路核验：

1. `Global`：tool 对应全局策略文件（`~/.codex/AGENTS.md` / `~/.claude/CLAUDE.md` / `~/.gemini/GEMINI.md`）
2. `Workflow`：`universal-harness-kit` 根与其 `scripts/` 目录
3. `Copy-to-project`：从 `--cwd` 向上回溯找到项目根（通过 `AGENTS.md`，且不使用 `$HOME` 作为项目根），并检查关键文件

该脚本支持 text/JSON 两种输出，便于终端阅读和自动化集成。

### 前置条件

- macOS / Linux shell（`bash`）
- 推荐在仓库根目录执行：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

- 确保脚本可执行：

```bash
chmod +x ./scripts/agent-policy-stack
```

### 命令总览

```bash
./scripts/agent-policy-stack [--tool <codex|claude|gemini>] [--cwd <path>] [--json] [--strict] [--strict-profile <compat|harness>]
```

### 参数说明

- `--tool <codex|claude|gemini>`：指定 tool 上下文，影响 `.codex/.claude/.gemini` 的检查路径
- `--cwd <path>`：用于回溯 `copy_project_root` 的起始目录，默认当前 `PWD`
- `--json`：输出 JSON 格式
- `--strict`：启用严格模式
  - `compat`（默认）：当找到 `copy_project_root` 时，如果缺少 `AGENTS.md`、`.ai/handoff.md`、`scripts/verify` 任一项，脚本非 0 退出
  - `harness`：`copy_project_root` 未找到即失败；且 required 文件扩展为
    `AGENTS.md`、`.ai/handoff.md`、`scripts/verify`、`.claude/CLAUDE.md`、`.codex/commands/closeout.md`、`.gemini/GEMINI.md`
  - 例外：当 `--cwd` 为 `$HOME` 或 workflow 根目录时，脚本会输出 `WARN` 并放宽 `copy_project_root` 必需约束（用于 Global/Workflow 维护场景）
- `--strict-profile <compat|harness>`：指定 strict 行为档位，默认 `compat`
- `-h, --help`：显示帮助

### 输出字段

固定输出字段：

- `global_file`
- `workflow_root`
- `copy_project_root`
- `copy_agents_file`
- `strict_profile`
- `required_checks`（每项包含 `name/status/detail`）
- `strict`（包含 `enabled/profile/copy_project_root_required/required_items/result/reason`）

`required_checks` 典型项：

- `global_file_exists`
- `workflow_root_exists`
- `workflow_scripts_exists`
- `workflow_usage_doc_exists`
- `workflow_usage_mentions_gemini_required`
- `workflow_usage_mentions_relax_warn`
- `global_policy_stack_command_matches`
- `global_policy_order_clause_exists`
- `global_policy_fail_clause_exists`
- `global_minimal_section_order_symmetric`
- `gemini_global_no_heavy_tool_rules`
- `global_no_plaintext_secrets`
- `copy_project_root_found`
- `copy_agents_exists`
- `copy_handoff_exists`
- `copy_verify_exists`
- `copy_claude_exists`
- `copy_codex_closeout_exists`
- `copy_gemini_exists`
- `copy_project_root_relaxed`（仅在 HOME/workflow 根场景出现，状态为 `warn`）

JSON contract schema：

- `docs/agent-policy-stack.output.schema.json`

状态说明：

- `pass`：检查通过
- `fail`：检查失败
- `skip`：当前上下文不适用（例如未找到 `copy_project_root`）

### 示例

1) 默认 text 输出：

```bash
./scripts/agent-policy-stack --tool codex
```

2) 指定项目目录并启用严格模式：

```bash
./scripts/agent-policy-stack --tool claude --cwd /Users/Zhuanz/Documents/Code/demo-api --strict --strict-profile compat
```

3) JSON 输出（适合 CI 或外层脚本解析）：

```bash
./scripts/agent-policy-stack --tool gemini --cwd /Users/Zhuanz/Documents/Code/demo-api --json
```

4) 常见组合（JSON + strict）：

```bash
./scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/demo-api --json --strict --strict-profile harness
```

5) 用 schema 校验 `--json` 输出：

```bash
./scripts/agent-policy-stack --tool codex --cwd "$PWD" --json --strict --strict-profile harness \
  | python3 -m jsonschema -i /dev/stdin ./docs/agent-policy-stack.output.schema.json
```

### 输入 / 输出与退出码

输入：

- CLI flags（`--tool/--cwd/--json/--strict/--strict-profile`）
- 文件系统状态（全局策略、workflow 根、copy 项目关键文件）

输出：

- text 或 JSON 检查报告

退出码：

- `0`：成功（严格模式未触发失败）
- `2`：参数错误（例如无效 `--tool`、`--cwd` 不存在）
- `3`：严格模式失败（例如：`harness` 下未找到 `copy_project_root`；或已找到但 required 文件缺失）

### Troubleshooting

1) `copy_project_root` 为空

- 说明：从 `--cwd` 向上没有找到项目级 `AGENTS.md`（或只命中 `$HOME/AGENTS.md`）；当 `--cwd` 等于 workflow root 时也会强制保持为空（按维护上下文处理）
- 处理：确认你传入的是由 harness 模板复制出的项目目录，或切换到正确目录后重试

2) strict 模式失败

- 说明：`strict_profile=compat` 时，已找到 `copy_project_root`，但 required 文件缺失；
  `strict_profile=harness` 时，`copy_project_root` 未找到也会失败（若 `--cwd` 为 HOME/workflow 根则会放宽并给出 `WARN`）；
  严格模式还会校验 policy contract（global 命令契约、顺序条款、fail/warn 条款、workflow usage 关键字段、global-minimal 对称顺序、Gemini 无重型 tool 规则、global dotfiles 明文凭据检查）
- 处理：补齐缺失文件或修复 policy 文档/全局条款后重跑

3) 命中 `global_no_plaintext_secrets`

- 说明：在以下目标中检测到高置信明文凭据：
  - `~/.claude/settings.json`
  - `~/.claude/scripts/*`
  - `~/.codex/config.toml`
- 检测范围聚焦：
  - 明文前缀：`sk-ant-`、`sk-proj-`
  - 明显明文赋值：`password/token/secret/api_key` 等键名直接赋 literal
- 已做误报抑制：环境变量引用（`$VAR`/`${VAR}`/`process.env`/`getenv`）、常见占位值（`example/changeme/placeholder/redacted`）会被忽略
- 处理：改为环境变量或 keychain 注入后重跑

4) 本地缺少 `python3 -m jsonschema`

- 说明：schema 校验工具未安装
- 处理：可先运行 `./scripts/verify`（内置 fallback 结构校验），或安装 `jsonschema`

---

## English

### Purpose

`scripts/agent-policy-stack` is a unified entrypoint checker that validates the policy chain before an agent run:

1. `Global`: tool-specific global policy file (`~/.codex/AGENTS.md` / `~/.claude/CLAUDE.md` / `~/.gemini/GEMINI.md`)
2. `Workflow`: `universal-harness-kit` root and its `scripts/` directory
3. `Copy-to-project`: walks up from `--cwd` to locate project root (via `AGENTS.md`, excluding `$HOME`) and checks required files

It supports both human-readable text output and machine-readable JSON output.

### Prerequisites

- macOS / Linux shell (`bash`)
- Recommended working directory:

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

- Ensure executable bit:

```bash
chmod +x ./scripts/agent-policy-stack
```

### Command Summary

```bash
./scripts/agent-policy-stack [--tool <codex|claude|gemini>] [--cwd <path>] [--json] [--strict] [--strict-profile <compat|harness>]
```

### Options

- `--tool <codex|claude|gemini>`: select tool context; affects `.codex/.claude/.gemini` checks
- `--cwd <path>`: starting directory for `copy_project_root` lookup (default: current `PWD`)
- `--json`: emit JSON output
- `--strict`: enable strict mode
  - `compat` (default): if `copy_project_root` is found and any of
    `AGENTS.md`, `.ai/handoff.md`, `scripts/verify` is missing, exits non-zero
  - `harness`: `copy_project_root` is mandatory; required files are
    `AGENTS.md`, `.ai/handoff.md`, `scripts/verify`, `.claude/CLAUDE.md`, `.codex/commands/closeout.md`, `.gemini/GEMINI.md`
  - Exception: when `--cwd` is `$HOME` or workflow root, the script emits `WARN` and relaxes the `copy_project_root` requirement (for Global/Workflow maintenance contexts)
- `--strict-profile <compat|harness>`: strict behavior profile (default: `compat`)
- `-h, --help`: show help

### Output Fields

Always included:

- `global_file`
- `workflow_root`
- `copy_project_root`
- `copy_agents_file`
- `strict_profile`
- `required_checks` (each item has `name/status/detail`)
- `strict` (`enabled/profile/copy_project_root_required/required_items/result/reason`)

Typical `required_checks` entries:

- `global_file_exists`
- `workflow_root_exists`
- `workflow_scripts_exists`
- `workflow_usage_doc_exists`
- `workflow_usage_mentions_gemini_required`
- `workflow_usage_mentions_relax_warn`
- `global_policy_stack_command_matches`
- `global_policy_order_clause_exists`
- `global_policy_fail_clause_exists`
- `global_minimal_section_order_symmetric`
- `gemini_global_no_heavy_tool_rules`
- `global_no_plaintext_secrets`
- `copy_project_root_found`
- `copy_agents_exists`
- `copy_handoff_exists`
- `copy_verify_exists`
- `copy_claude_exists`
- `copy_codex_closeout_exists`
- `copy_gemini_exists`
- `copy_project_root_relaxed` (HOME/workflow-root only, status `warn`)

JSON contract schema:

- `docs/agent-policy-stack.output.schema.json`

Status semantics:

- `pass`: check passed
- `fail`: check failed
- `skip`: not applicable in current context (for example, no `copy_project_root` found)

### Examples

1) Default text output:

```bash
./scripts/agent-policy-stack --tool codex
```

2) Point to a copied project and enable strict mode:

```bash
./scripts/agent-policy-stack --tool claude --cwd /Users/Zhuanz/Documents/Code/demo-api --strict --strict-profile compat
```

3) JSON output (for CI/automation):

```bash
./scripts/agent-policy-stack --tool gemini --cwd /Users/Zhuanz/Documents/Code/demo-api --json
```

4) Typical automation combo (JSON + strict):

```bash
./scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/demo-api --json --strict --strict-profile harness
```

5) Validate `--json` output against schema:

```bash
./scripts/agent-policy-stack --tool codex --cwd "$PWD" --json --strict --strict-profile harness \
  | python3 -m jsonschema -i /dev/stdin ./docs/agent-policy-stack.output.schema.json
```

### Inputs / Outputs / Exit Codes

Inputs:

- CLI flags (`--tool/--cwd/--json/--strict/--strict-profile`)
- Filesystem state (global policy file, workflow root, copy project required files)

Outputs:

- Text or JSON report

Exit codes:

- `0`: success (strict mode not failed)
- `2`: argument error (for example invalid `--tool`, missing `--cwd` path)
- `3`: strict-mode failure (for example `harness` with no `copy_project_root`, or missing required files)

### Troubleshooting

1) `copy_project_root` is empty

- Meaning: no project-level `AGENTS.md` found while walking up from `--cwd` (or only `$HOME/AGENTS.md` is found); it is also forced empty when `--cwd` equals workflow root (maintenance context)
- Fix: pass the correct harness-generated project directory

2) strict mode fails

- Meaning: with `strict_profile=compat`, `copy_project_root` exists but required files are incomplete;
  with `strict_profile=harness`, missing `copy_project_root` also fails (except HOME/workflow-root contexts, where requirement is relaxed with `WARN`);
  strict mode also checks policy contract consistency (global command contract/order/fail-warn clauses, workflow usage key fields, global-minimal section-order symmetry, Gemini no-heavy-tool-rules guard, and global dotfiles plaintext-credential checks)
- Fix: restore missing files or fix policy/global documentation contract, then rerun

3) `global_no_plaintext_secrets` fails

- Meaning: high-confidence plaintext credentials were detected in:
  - `~/.claude/settings.json`
  - `~/.claude/scripts/*`
  - `~/.codex/config.toml`
- Detection focus:
  - Explicit token prefixes: `sk-ant-`, `sk-proj-`
  - Literal assignments for keys like `password/token/secret/api_key`
- False-positive guards:
  - Environment references (`$VAR`, `${VAR}`, `process.env`, `getenv`) are ignored
  - Common placeholders (`example/changeme/placeholder/redacted`) are ignored
- Fix: switch to environment-variable or keychain injection, then rerun

4) Missing `python3 -m jsonschema`

- Meaning: the JSON Schema validator module is not installed
- Fix: run `./scripts/verify` first (it has a fallback structural validation), or install `jsonschema`
