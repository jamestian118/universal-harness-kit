# AGENTS.md（Repo Map）

## 0) Chat 输出（仅 chat）
- 每次 chat 回复必须以 “xiaozi，” 开头
- 始终使用中文；技术术语保留 English（git/commit/branch/PR/CI/Docker/dependency/lint/test 等）
- 仅 chat 使用称呼；不要把称呼写进代码、commit message、PR title、README/docs

## 1) 工作流（Workflow）
- 复杂任务：先输出 plan（文件清单 + 风险点 + 验收标准），与 xiaozi 对齐后再改代码
- 不写兼容性代码，除非 xiaozi 明确要求
- 严禁 secrets；详见 docs/security.md
- 动态进度只写到：.ai/handoff.md（不要写进 docs/）

## 2) Repo 结构（Map）
- src/：业务代码
- tests/：测试
- scripts/：稳定入口（setup/dev/format/lint/test/verify）
- docs/：system of record（架构/安全/质量/文档规范）
- .ai/handoff.md：动态进度与交接（唯一允许的动态记录）

## 3) 必跑命令（Exact commands）
- Setup：./scripts/setup
- Dev：./scripts/dev
- Format：./scripts/format
- Lint：./scripts/lint
- Test：./scripts/test
- 最小验证命令（milestone/stop/切换 CLI 前必须跑）：./scripts/verify
- Arch-check：./scripts/arch-check
- GC（抗熵检查）：./scripts/gc

## 4) 文档入口（Docs pointers）
- docs/index.md：文档总目录
- docs/architecture.md：架构与依赖边界（invariants）
- docs/quality.md：DoD + golden principles
- docs/security.md：安全红线与 secrets 规则
- docs/docs-policy.md：README 与脚本文档（中英双语）要求
- docs/scripts.md：scripts 使用说明（中英双语）

## 5) Milestone / Stop / CLI 切换前（Handoff）
- 先运行：./scripts/verify
- 运行：./scripts/gc，将 drift 报告写入 .ai/handoff.md
- 将信息追加写入：.ai/handoff.md（branch、commit、git status 摘要、命令与关键输出、Done、Next Steps）
- 做安全点：优先小 commit；若不适合 commit，则 stash，并在 .ai/handoff.md 写明恢复方式
- 自动填写 Lessons Learned：回顾 .ai/verify-log.json 和 gc 输出，总结写入 .ai/handoff.md
- 自动生成 verify 摘要：附上 verify-log.json 的关键信息（每步 pass/fail + 耗时）
- 同步 Lessons Learned 到全局：追加到 $HOME/Documents/Code/universal-harness-kit/.ai/lessons-learned.md
- 检查规则升级：读取全局 lessons-learned.md，同类问题 ≥2 次则提议升级为 golden principle 或机械化检查
