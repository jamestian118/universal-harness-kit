# Phase6 Gate Command Matrix (UHK Lane)

- 生成时间: 2026-02-27
- 生成路径: `/Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase6-gate-commands.md`
- 作用域: `/Users/Zhuanz/Documents/Code/universal-harness-kit`
- 目标: 为 Gate 6 提供可直接执行的 `omo/csm --help` 基线采集与判定模板（主线程可复用）。

## 0) Strict 入口记录（UHK root）

- 命令:
  ```bash
  /Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/universal-harness-kit --strict --strict-profile harness
  ```
- Gate 条件:
  - 必须出现 `strict_result=pass`。
  - `copy_project_root_relaxed: warn` 在 workflow root 场景允许，不视为失败。

## 1) Gate 6 命令矩阵（help 可读性 + 信息完整性）

| 检查对象 | 命令模板 | 输出落盘 | 通过检查点（Gate 6） | 常见失败信号 |
|---|---|---|---|---|
| OMO help | `(cd /Users/Zhuanz/Documents/Code/universal-harness-kit && omo --help 2>&1 | tee .ai/tmp-phase6-omo-help.out); echo "omo_exit=$?"` | `.ai/tmp-phase6-omo-help.out` | `exit=0`；包含 `usage:`；包含子命令区块（至少命中 `pipeline`、`team`、`resume`） | `command not found`；`exit!=0`；仅报错无 usage |
| CSM help | `(cd /Users/Zhuanz/Documents/Code/universal-harness-kit && csm --help 2>&1 | tee .ai/tmp-phase6-csm-help.out); echo "csm_exit=$?"` | `.ai/tmp-phase6-csm-help.out` | `exit=0`；包含 `usage:`；包含关键能力词（至少命中 `handoff`、`mcp`、`memory-sync`） | `command not found`；`exit!=0`；仅报错无 usage |

## 2) Gate 6 判定规则（Readability + Completeness）

### A. 可读性检查点（Readability）

1. 帮助文本有明确标题行（`usage:`）。
2. 至少出现一个结构化分组标题（如 `positional arguments`、`options`）。
3. 子命令或选项说明行不是空描述（避免只有命令名无释义）。

### B. 信息完整性检查点（Information Completeness）

1. `omo --help` 至少覆盖 orchestration 核心面：`pipeline`、`team`、`resume`。
2. `csm --help` 至少覆盖 session + bridge + memory 三类能力：`handoff`、`mcp`、`memory-sync`。
3. 两个命令都必须可执行（exit code 为 0），且输出文件可追溯（`.ai/tmp-phase6-*.out` 存在）。

### C. Gate 决策

- `PASS`: A/B 全部满足，且 `omo_exit=0 && csm_exit=0`。
- `FAIL`: 任一命令不可执行、关键关键词缺失、或输出不具可读结构。
- `NEEDS_OWNER_INPUT`: 命令可运行但帮助文本关键能力缺失（疑似版本漂移），需 owner 明确是否放宽关键字门槛。

## 3) 主线程一键执行模板（可直接复制）

```bash
set -euo pipefail

ROOT="/Users/Zhuanz/Documents/Code/universal-harness-kit"
cd "$ROOT"

# 1) strict gate
/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd "$ROOT" --strict --strict-profile harness | tee .ai/tmp-phase6-policy.out

# 2) help baseline capture
(omo --help 2>&1 | tee .ai/tmp-phase6-omo-help.out); echo "omo_exit=$?" | tee .ai/tmp-phase6-omo-exit.out
(csm --help 2>&1 | tee .ai/tmp-phase6-csm-help.out); echo "csm_exit=$?" | tee .ai/tmp-phase6-csm-exit.out

# 3) lightweight gate checks
rg -n "^usage:" .ai/tmp-phase6-omo-help.out .ai/tmp-phase6-csm-help.out
rg -n "pipeline|team|resume" .ai/tmp-phase6-omo-help.out
rg -n "handoff|mcp|memory-sync" .ai/tmp-phase6-csm-help.out

# 4) quick summary for Gate 6
printf "\n[gate6] policy=%s omo_usage=%s csm_usage=%s\n" \
  "$(rg -n 'strict_result=pass' .ai/tmp-phase6-policy.out >/dev/null && echo pass || echo fail)" \
  "$(rg -n '^usage:' .ai/tmp-phase6-omo-help.out >/dev/null && echo pass || echo fail)" \
  "$(rg -n '^usage:' .ai/tmp-phase6-csm-help.out >/dev/null && echo pass || echo fail)"
```

## 4) 建议回填模板（Gate 6 结果）

| check | result(pass/fail/needs_owner_input) | evidence |
|---|---|---|
| strict_result |  | `.ai/tmp-phase6-policy.out` |
| omo_help_readability |  | `.ai/tmp-phase6-omo-help.out` |
| omo_help_completeness |  | `.ai/tmp-phase6-omo-help.out` |
| csm_help_readability |  | `.ai/tmp-phase6-csm-help.out` |
| csm_help_completeness |  | `.ai/tmp-phase6-csm-help.out` |
| final_gate6 |  | `summary + exit files` |
