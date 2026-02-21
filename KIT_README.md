# Universal Harness Kit（通用 Harness 模板包）

## 中文（ZH）

这是一套“项目骨架 + Harness 规则”模板包，用来快速创建新项目目录，并在项目内落地：

- `<repo>/AGENTS.md`：repo map（目录/入口命令/指向 docs）
- `scripts/`：稳定入口（setup/dev/format/lint/test/verify 等）
- `docs/`：system of record（架构/安全/质量/文档规范）
- `.ai/handoff.md`：唯一动态进度与交接载体
- `.github/workflows/`：CI gate（PR 跑 verify / docs-check / secrets-check；以及可选 gc）

模板支持多语言 profile（python/node/go/generic）。创建项目时选择语言即可。

### 前置条件（prereqs）
- macOS（默认目标环境）
- bash
- python3（用于创建项目时做占位符替换；不要求项目本身是 Python）

### 创建新项目（exact commands）
在本目录下执行：

```bash
chmod +x ./new_project.sh
./new_project.sh <project-name> --lang <python|node|go|generic>
```

示例：

```bash
./new_project.sh demo-api --lang python
./new_project.sh web-tool --lang node
./new_project.sh cli-go --lang go
./new_project.sh misc --lang generic
```

创建完成后，新项目位于：

`$HOME/Documents/Code/<project-name>/`

进入项目并初始化（根据 profile 不同略有差异，但都应以 scripts 为准）：

```bash
cd $HOME/Documents/Code/<project-name>
chmod +x ./scripts/*
./scripts/setup
./scripts/verify
```

### 回归命令（milestone 清理流程）
用于一键回归 `verify -> dry-run -> confirm -> apply` 的收尾链路：

```bash
cd $HOME/Documents/Code/<project-name>
./scripts/milestone-finalize
```

预期行为：
- 本地交互 TTY：先跑 `verify`，再生成清理计划，并询问是否清理；输入 `yes` 才执行删除
- CI 或非 TTY：只跑 `verify` + `dry-run`，自动跳过删除

### 新增能力

- `scripts/arch-check`：架构不变式检查（检测 `src/` 中违规 `import/from/require tests/` 的情况）
- `scripts/gc` 检查逻辑：脚本文档覆盖、裸 TODO、动态进度泄漏、重复函数检测
- `scripts/finalize-artifacts` + `scripts/milestone-finalize`：artifacts 生命周期闸门（`dry-run -> confirm -> apply`），仅在 verify 成功且人工确认后清理临时产物
- `docs/quality.md`：golden principles（5 条质量规则，新增 artifacts 生命周期约束）
- `docs/architecture.md`：invariants（3 条架构不变式）
- `.githooks/pre-commit`：commit 前自动跑 verify
- `.harness`：标记文件，证明项目由模板创建
- `.claude/CLAUDE.md`：项目级 Claude Code 指令
- verify 可观测性：输出 JSON 日志到 `.ai/verify-log.json`
- `.ai/handoff.md` 新增 `Lessons Learned` 字段（反馈循环）
- 失败可复现机制（`conftest.py` / `test-reporter` / `-v` flag）
- `new_project.sh` 现在自动 `git init` + 配置 hook + 首次 commit；若 `.githooks/pre-commit` 缺失或不可执行会 fail-fast 退出

### 说明
- 该模板包只负责”把正确的文件放到正确的位置 + 给出稳定入口”。具体业务与工具链可后续由 agent 按你的指令在项目内调整。
- 禁止把 secrets 写入 repo；使用 `.env.example` 指引环境变量。

---

## English (EN)

A project skeleton + harness kit to bootstrap new projects with:

- `<repo>/AGENTS.md`: repo map (commands + pointers to docs)
- `scripts/`: stable entrypoints (setup/dev/format/lint/test/verify, etc.)
- `docs/`: system of record (architecture/security/quality/docs policy)
- `.ai/handoff.md`: the only place for dynamic progress & handoff notes
- `.github/workflows/`: CI gates (verify/docs-check/secrets-check; optional gc)

Profiles supported: python/node/go/generic.

### Prereqs
- macOS (default target)
- bash
- python3 (used by the generator for placeholder replacement; project language can be anything)

### Create a new project (exact commands)

```bash
chmod +x ./new_project.sh
./new_project.sh <project-name> --lang <python|node|go|generic>
```

After creation:

```bash
cd $HOME/Documents/Code/<project-name>
chmod +x ./scripts/*
./scripts/setup
./scripts/verify
```

### Regression Command (Milestone Cleanup Flow)
Use this one-liner to regress the closeout chain `verify -> dry-run -> confirm -> apply`:

```bash
cd $HOME/Documents/Code/<project-name>
./scripts/milestone-finalize
```

Expected behavior:
- Local interactive TTY: runs `verify`, generates cleanup plan, then asks whether to clean; deletion only happens after `yes`
- CI or non-TTY: runs `verify` + `dry-run` only and skips deletion automatically

### New Capabilities

- `scripts/arch-check`: architecture invariant checker (detects illegal `import/from/require tests/` in `src/`)
- `scripts/gc` check logic: script doc coverage, bare TODOs, dynamic progress leaks, duplicate function detection
- `scripts/finalize-artifacts` + `scripts/milestone-finalize`: artifact lifecycle gate (`dry-run -> confirm -> apply`), cleanup only after verify success and explicit human confirmation
- `docs/quality.md`: golden principles (5 quality rules, including artifact lifecycle constraints)
- `docs/architecture.md`: invariants (3 architecture rules)
- `.githooks/pre-commit`: auto-runs verify before each commit
- `.harness`: marker file proving the project was created from the template
- `.claude/CLAUDE.md`: project-level Claude Code instructions
- verify observability: outputs JSON log to `.ai/verify-log.json`
- `.ai/handoff.md` now includes a `Lessons Learned` field (feedback loop)
- Failure reproducibility (`conftest.py` / `test-reporter` / `-v` flag)
- `new_project.sh` now auto-runs `git init` + configures hooks + initial commit; it fails fast if `.githooks/pre-commit` is missing or not executable
