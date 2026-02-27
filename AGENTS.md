# AGENTS.md（universal-harness-kit root）

## 1) Scope
- 本文件适用于 kit root（`universal-harness-kit`）及其所有子目录；若子目录存在更深层 `AGENTS.md`，按就近覆盖。

## 2) Mandatory Entry
- 每次任务开始前（主 agent + 子 agent）先执行：
  `./scripts/agent-policy-stack --tool <codex|claude|gemini> --cwd "$PWD" --strict --strict-profile harness`
- 入口结果含 `strict_result=fail` 时禁止跳过；必须先修复 policy 问题。

## 3) Repo Map
- `profiles/*/template/`：新项目骨架来源（python/node/go/generic）
- `scripts/`：workflow 级稳定入口（policy stack、verify、doc parity、publish artifacts）
- `docs/`：双语 usage 与规则文档（system of record）
- `new_project.sh`：模板实例化入口
- `.ai/handoff.md`：会话动态交接记录

## 4) Verification + Docs Sync
- 对可执行脚本（`*.sh`、`scripts/*`）的修改，必须同步更新对应双语 usage 文档（同文件 `## 中文` / `## English`）。
- 里程碑前必须运行 `./scripts/verify`，并以命令与关键输出作为结论证据。

## 5) Handoff Contract
- 会话切换/结束前更新 `.ai/handoff.md`：`当前状态`、`下一步`、`已知问题`。
- 输出结论必须可复现：至少包含 1 条验证命令、pass/fail 结果、关键输出摘要。
