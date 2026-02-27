# Global Lessons Learned（跨项目教训汇总）

所有项目的 Lessons Learned 都追加到此文件。
agent 在每次 handoff 时，除了写项目内的 .ai/handoff.md，还必须把 Lessons Learned 同步追加到此文件。

格式：`- YYYY-MM-DD [项目名]: [现象] → [根因] → [是否需要升级规则]`

当同一类问题出现 ≥2 次时，应升级为 golden principle 或机械化检查（参见 docs/quality.md 的规则升级机制）。

---

## 发布与脱敏（Publish & Sanitize）

- 2026-02-22 [bulk-github-publish]: 批量推送时包含 `.github/workflows/*` 的仓库被 GitHub 拒绝（OAuth token 无 `workflow` scope）→ 凭据 scope 与内容类型不匹配 → 建议升级为机械化检查：发布前先探测 token scopes
- 2026-02-22 [bulk-github-publish]: 路径脱敏规则对 `/home/...` 未生效（仅替换了 `/Users/...`）→ 使用了不适配斜杠前缀的 `\b` 边界正则 → 建议升级为 golden principle：路径脱敏统一用"平台路径样例回放测试"
- 2026-02-22 [incremental-github-publish]: 用"原仓 vs 上次脱敏快照"直接做差会把未脱敏内容全部误判为改动 → 基线形态不一致 → 建议机械化：增量发布先用发布时间窗口或远端内容比对筛项目
- 2026-02-22 [bulk-codex-review-ping]: 仅检查"最新评论"会误判 `@codex review` 未生效 → 验证口径选择错误（latest vs any）→ 建议机械化：PR 评论验收统一改为"评论列表任意一条包含"

## 验证与测试（Verify & Test）

- 2026-02-21 [harness-test]: gc 裸 TODO 检查误报模板占位内容和规则描述文本 → gc 脚本需要排除自身和 docs 中的规则描述 → 待后续迭代修复
- 2026-02-23 [oh-my-orch]: 对 Markdown 文件直接执行 Python `ruff check` 产生大量语法误报 → Python linter 被误用于 `.md` → 建议升级为机械化检查：文档一致性改用专用 Markdown linter
- 2026-02-23 [oh-my-orch]: Team 模式把 synthesis/final_summary 排除在返回结构与 `ok` 判定之外 → 流程证据链只记录三代理主步骤 → 建议升级为机械化检查：多阶段命令 machine-readable 输出必须包含全部关键阶段
- 2026-02-23 [oh-my-orch]: Team live 采集观点时走 interactive 且未捕获 stdout，出现假成功 → stdout 捕获通道与成功判定口径不一致 → ⚠️ 同类 ≥2 次，建议升级
- 2026-02-23 [oh-my-orch]: `verify` 出现"假绿"风险——gate 扫描范围与真实实现目录不一致 → 脚本覆盖面滞后于代码迁移 → ⚠️ 同类 ≥2 次，建议机械化：统一声明 `scan_roots`
- 2026-02-24 [oh-my-orch]: 仅用 `ok` 布尔值做 CLI 退出码会丢失可机读失败类型 → machine-readable 错误分类未透传 → 建议升级为机械化检查
- 2026-02-24 [claude-session-manager+cli-handoff-bundle]: 修"文件写入安全"时只覆盖主路径但漏掉失败分支语义 → 未把失败路径纳入验收用例 → 建议升级为机械化检查：所有 I/O 修复必须补故障注入 smoke

## 文档与契约（Docs & Contracts）

- 2026-02-23 [oh-my-orch]: Pipeline dry-run 初版把 `.ai/review.md` 仅写在 sandbox worktree → worktree 产物路径与根目录契约断言未统一 → 建议增加统一 artifact sync 规则
- 2026-02-23 [oh-my-orch]: Team 产物契约收敛为单文件后未同步更新测试断言与 README → 产物契约缺少单点 schema 约束 → ⚠️ 同类 ≥2 次，建议升级
- 2026-02-23 [oh-my-orch]: Pipeline 仅写根目录且 Stage5 无总结产物 → pipeline/team 产物契约不对称 → 建议升级为机械化检查
- 2026-02-24 [oh-my-orch]: 并行推进中"代码契约与文档契约"容易出现细节漂移 → 接口字段命名缺少统一单点定义 → ⚠️ 同类 ≥2 次，建议升级
- 2026-02-26 [universal-harness-kit]: 全局指令里的 workflow version 标题与实际内容不同步 → spec 升级后只改了局部文件 → 建议机械化：三端 workflow version 一致性纳入 docs parity 自动检查

## 环境与配置（Environment & Config）

- 2026-02-22 [incremental-github-publish]: 在 zsh 中使用 `${VAR^^}` 做大写转换会报 `bad substitution` → Bash 参数扩展与 zsh 兼容差异 → 建议统一使用 `tr '[:lower:]' '[:upper:]'`
- 2026-02-22 [claude-session-manager]: 三个 CLI 配置里都写了 `csm`，但运行时仍出现找不到/断连 → 配置存在不等于可用 → 建议升级为机械化检查：安装后固定跑四联验收
- 2026-02-23 [oh-my-orch]: 调试 `new_project.sh --help` 时误创建了名为 `--help` 的项目目录 → 脚本将第一个位置参数视为 project-name → 建议升级为机械化检查：首参数为 `-h/--help` 时优先打印 usage
- 2026-02-23 [codex-mcp-graphiti]: Codex 启动报 `Unexpected content type: text/html` → MCP URL 命中非 JSON-RPC endpoint → 已采用最小修复 `enabled=false`（未升级为规则）
- 2026-02-23 [oh-my-orch]: live pipeline 的 Stage1 在非交互 shell 中可能卡住或触发 TimeoutExpired → 交互/非交互场景未分流 → ⚠️ 同类 ≥2 次，建议升级
- 2026-02-23 [oh-my-orch]: interactive TTY 下执行 live team 出现长时间阻塞 240s → team 观点阶段未设置 timeout → ⚠️ 同类 ≥2 次，建议升级
- 2026-02-26 [homebrew-codex-config]: `brew update` 出现 tap apply/rebase 冲突 + cask 元数据不一致 → tap 仓库处于未收敛 git 状态 → 最小修复闭环已记录
- 2026-02-26 [homebrew-codex-config]: 同类 Homebrew 残留问题第 2 次：cask 已登记但 App artifact 丢失 → 用户手动删除 `.app` 后 cask 元数据未同步 → ⚠️ 同类 ≥2 次，建议升级为 cask artifact 存在性扫描
- 2026-02-27 [claude-code-auth]: Claude Code 出现持续 401 且重试 10 次超时 → `~/.zshrc` 把 `ANTHROPIC_API_KEY` 覆盖为空值 → 建议机械化检查：新增 `claude-auth-smoke`

## Artifact 生命周期

- 2026-02-22 [multi-repo-readme-standardization]: 多项目发布前容易出现"主文档命名不一致" → 缺少创建入口的 README 命名硬约束 → 建议机械化

## 并发与调度（Concurrency & Scheduling）

- 2026-02-24 [oh-my-orch]: 多 worker 并行改造若不做文件 ownership 切分 + 主线程统一 verify 容易产生局部自测通过但组合回归失败 → 并行分支只验证局部目标 → 建议升级为机械化检查：并行任务完成后强制主线程执行一次 `./scripts/verify`

## 领域特定（Domain-Specific）

- 2026-02-21 [patrol-final-acceptance-kit]: VM"GUI登录页"实际是 getty 控制台登录而非 gdm/lightdm → 系统未安装桌面 display manager → 建议升级为开机自检：优先判定登录类型
- 2026-02-21 [patrol-final-acceptance-kit]: GUI录屏中 cmd_vel/odom 在变但画面机器人不动被误判为模型太小 → 物理位姿不变、里程计漂移 → 建议升级为机械化检查：录屏前先跑一致性探针
- 2026-02-21 [patrol-final-acceptance-kit]: 在 limactl shell bash here-doc 内执行 ffmpeg x11grab 后下一行命令偶发丢首字符 → 伪终端/命令流边界问题 → 建议升级为 golden principle：后续命令统一加前置空格或拆分独立 shell
- 2026-02-21 [patrol-final-acceptance-kit]: GUI录屏用 timeout ffmpeg 直接截断会导致 mp4 moov atom not found → TERM 信号中断未完成封装 → 建议升级为机械化检查：统一用 `ffmpeg -t` 自然收尾
- 2026-02-21 [patrol-final-acceptance-kit]: demo_final_60s.mp4 为 headless 文字拼片却被错误当作最终展示成片 → 验收口径未分离 → 建议升级为机械化检查
- 2026-02-22 [claude-session-manager]: TUI 二次确认菜单闪现后立刻返回主界面 → curses 轮询超时未在二次输入场景切阻塞 → 建议升级为机械化检查

---

## 已毕业（Graduated）

以下条目已升级为 golden principle 或机械化检查，保留摘要供追溯。

| 原始条目 | 升级去向 |
|----------|----------|
| secrets-check 误报自身脚本 | `--exclude=secrets-check` 修复 |
| arch-check 未识别 CommonJS require | require() 检测 + TODO(#INIT) 规范化 |
| VM GUI 登录页实际是 getty | systemd override 落地 |
| Lima 无桌面 | lightdm + xfce4 + autologin 落地 |
| 证据文件仅用时间戳编号 | 报告友好命名模板 |
| agent 截图/视频冗余 artifacts | `scripts/finalize-artifacts` 机械化 |
| artifacts 清理依赖人工记忆 | `/closeout` 清单接入 |
| 发布仅靠记忆偏好 | `sanitize→classify→publish` 标准化 |
| 发布动作遗漏阶段 | `scripts/publish` 机械化 |
| 发布中间目录散落 | `/_sanitized_publish_artifacts/` 统一 |
| 手动 cleanup 依赖人记忆 | `scripts/sanitized-publish-artifacts-scheduler` |
| 中间验证脚本散落 | `finalize-artifacts` 默认 roots 扩展 |
| 三层 policy 文本约束漂移 | `scripts/agent-policy-stack` 机械化 |
| 三层规则多文件重复展开 | 最小全局 + repo-local 最小收敛 |
| 多 agent strict 绕过 | `--strict-profile` + publish 阻断 |
| 四套模板未同步 | 四模板补齐修复 |
| 仅做文件存在性检查 | 语义级 contract checks |
| 单工具上下文检查遗漏 | `global_minimal_section_order_symmetric` |
| graphiti disabled 掩盖可用性 | 三步 docker+探针+config |
| 明文凭据写入 dotfiles | 凭据必须 env var / keychain |
| README commands 与实际不一致 | `scripts/check-doc-file-parity` |
