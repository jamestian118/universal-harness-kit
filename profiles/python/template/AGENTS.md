# AGENTS.md（Repo-Local Minimal）

## 1) Policy Stack 调用
- 每次进入项目（主 agent + 子 agent）前，先设置 `UHK_ROOT`（指向 universal-harness-kit 根目录）并运行：
  `"${UHK_ROOT}/scripts/agent-policy-stack" --tool <codex|claude|gemini> --cwd "$PWD" --strict --strict-profile harness`
- 若环境中未设置 `UHK_ROOT`，先执行：`export UHK_ROOT="$HOME/Documents/Code/universal-harness-kit"`

## 2) Repo 结构（Map）
- `src/`：业务代码
- `tests/`：测试
- `scripts/`：稳定入口脚本
- `docs/`：长期规范与说明
- `.ai/handoff.md`：动态进度与交接（唯一动态记录）

## 3) 最小执行与交接闭环
- Milestone / Stop / CLI 切换前必须运行：`./scripts/verify`
- 复杂任务执行中持续更新：`.ai/current-plan.md`（基于 `docs/exec-plans/_template.md`）
- 其余命令统一查阅：`docs/scripts.md`
- 完成 verify 后追加写入：`.ai/handoff.md`（`branch`、`commit`、`git status` 摘要、验证命令与关键输出、`Done`、`Next Steps`）
