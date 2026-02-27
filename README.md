# Universal Harness Kit（通用 Harness 模板包）

> 本目录是模板生成器（kit root），不是生成后的项目实例。  
> 生成后项目的完整 skeleton 位于 `profiles/*/template/`。  
> 对 kit root 跑 `agent-policy-stack --strict` 会走 workflow-root relaxed 路径。

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
./new_project.sh <project-name> --lang <python|node|go|generic> [--dest <path>]
```

示例：

```bash
./new_project.sh demo-api --lang python
./new_project.sh web-tool --lang node
./new_project.sh cli-go --lang go
./new_project.sh misc --lang generic
./new_project.sh demo-local --lang python --dest /tmp/uhk-demo
HARNESS_DEST_ROOT=/tmp/uhk-env ./new_project.sh demo-env --lang generic
```

创建完成后，新项目位于：

`/Users/Zhuanz/Documents/Code/<project-name>/`

命名约束：`project-name` 必须匹配 `^[a-z0-9][a-z0-9._-]{0,62}$`（仅小写、数字、`.`、`_`、`-`）。

新项目根文档会被强制标准化为 `README.md`（大写），确保 GitHub 默认可识别展示。

进入项目并初始化（根据 profile 不同略有差异，但都应以 scripts 为准）：

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
chmod +x ./scripts/*
./scripts/setup
./scripts/verify
```

### 回归命令（milestone 清理流程）
用于一键回归 `verify -> dry-run -> confirm -> apply` 的收尾链路：

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
./scripts/milestone-finalize
```

预期行为：
- 本地交互 TTY：先跑 `verify`，再生成清理计划，并询问是否清理；输入 `yes` 才执行删除
- CI 或非 TTY：只跑 `verify` + `dry-run`，自动跳过删除

### 标准发布命令（自动 commit + push + PR 评论）
用于一键执行发布工作流（默认包含垃圾清理阶段）：

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
./scripts/publish
```

预期行为：
- 第 1 阶段：执行 `milestone-finalize`（垃圾清理就在这里：`verify -> dry-run -> confirm -> apply`）
- 第 2 阶段：若工作区有改动，自动本地 `git commit`
- 第 3 阶段：推送当前分支到 GitHub
- 第 4 阶段：自动定位/创建对应 PR，并自动发表评论 `@codex review`

### 新增能力

- `scripts/arch-check`：架构不变式检查（检测 `src/` 中违规 `import/from/require tests/` 的情况）
- `scripts/gc` 检查逻辑：脚本文档覆盖、裸 TODO、动态进度泄漏、重复函数检测
- `scripts/finalize-artifacts` + `scripts/milestone-finalize`：artifacts 生命周期闸门（`dry-run -> confirm -> apply`），仅在 verify 成功且人工确认后清理临时产物
- 临时验证/测试自动化脚本规范：仅保留最终成功脚本；中间脚本统一放 `scripts/.tmp/` 或 `.ai/tmp-scripts/`，并由 `finalize-artifacts` 默认根清理
- `scripts/publish`：标准发布入口（`milestone-finalize -> auto commit -> push -> PR -> @codex review`）
- `scripts/agent-policy-stack`：统一入口检查 `Global -> Workflow -> Copy-to-project` 调用链；完整参数与示例见 `docs/agent-policy-stack.usage.zh-en.md`
- `scripts/verify`（kit root）：脚本级最小验收入口（`bash -n` + `shellcheck` + smoke）；完整说明见 `docs/verify.usage.zh-en.md`
- `docs/quality.md`：golden principles（5 条质量规则，新增 artifacts 生命周期约束）
- `docs/architecture.md`：invariants（3 条架构不变式）
- `.githooks/pre-commit`：commit 前自动跑 verify
- `.harness`：标记文件，证明项目由模板创建
- `.claude/CLAUDE.md`：项目级 Claude Code 指令
- verify 可观测性：输出 JSON 日志到 `.ai/verify-log.json`
- `.ai/handoff.md` 新增 `Lessons Learned` 字段（反馈循环）
- 失败可复现机制（`conftest.py` / `test-reporter` / `-v` flag）
- `new_project.sh` 现在自动 `git init` + 配置 hook + 首次 commit；若 `.githooks/pre-commit` 缺失或不可执行会 fail-fast 退出
- `new_project.sh` 现在会强制校验项目根 `README.md`（若模板存在 `readme.*` 变体会自动标准化）
- `new_project.sh` 现在支持 `--dest` 与 `$HARNESS_DEST_ROOT` 参数化目标目录；完整说明见 `docs/new_project.usage.zh-en.md`

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
./new_project.sh <project-name> --lang <python|node|go|generic> [--dest <path>]
```

After creation:

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
chmod +x ./scripts/*
./scripts/setup
./scripts/verify
```

The project root documentation is enforced as `README.md` (uppercase) so GitHub can recognize and render it directly.

Project name constraint: `project-name` must match `^[a-z0-9][a-z0-9._-]{0,62}$` (lowercase letters, digits, `.`, `_`, `-` only).

### Regression Command (Milestone Cleanup Flow)
Use this one-liner to regress the closeout chain `verify -> dry-run -> confirm -> apply`:

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
./scripts/milestone-finalize
```

Expected behavior:
- Local interactive TTY: runs `verify`, generates cleanup plan, then asks whether to clean; deletion only happens after `yes`
- CI or non-TTY: runs `verify` + `dry-run` only and skips deletion automatically

### Standard Publish Command (Auto Commit + Push + PR Comment)
Use this one-liner to execute the full publish workflow (cleanup stage included by default):

```bash
cd /Users/Zhuanz/Documents/Code/<project-name>
./scripts/publish
```

Expected behavior:
- Stage 1: runs `milestone-finalize` (cleanup is here: `verify -> dry-run -> confirm -> apply`)
- Stage 2: auto-creates a local `git commit` when there are changes
- Stage 3: pushes current branch to GitHub
- Stage 4: auto-detects/creates the PR and posts `@codex review`

### New Capabilities

- `scripts/arch-check`: architecture invariant checker (detects illegal `import/from/require tests/` in `src/`)
- `scripts/gc` check logic: script doc coverage, bare TODOs, dynamic progress leaks, duplicate function detection
- `scripts/finalize-artifacts` + `scripts/milestone-finalize`: artifact lifecycle gate (`dry-run -> confirm -> apply`), cleanup only after verify success and explicit human confirmation
- Temporary validation/test automation script policy: keep only final successful scripts; place intermediate scripts in `scripts/.tmp/` or `.ai/tmp-scripts/`, and let `finalize-artifacts` clean them by default
- `scripts/publish`: standardized publish entrypoint (`milestone-finalize -> auto commit -> push -> PR -> @codex review`)
- `scripts/agent-policy-stack`: unified entrypoint to verify the `Global -> Workflow -> Copy-to-project` call chain; for full arguments and examples, see `docs/agent-policy-stack.usage.zh-en.md`
- `scripts/verify` (kit root): minimal script-level acceptance entrypoint (`bash -n` + `shellcheck` + smoke); see `docs/verify.usage.zh-en.md`
- `docs/quality.md`: golden principles (5 quality rules, including artifact lifecycle constraints)
- `docs/architecture.md`: invariants (3 architecture rules)
- `.githooks/pre-commit`: auto-runs verify before each commit
- `.harness`: marker file proving the project was created from the template
- `.claude/CLAUDE.md`: project-level Claude Code instructions
- verify observability: outputs JSON log to `.ai/verify-log.json`
- `.ai/handoff.md` now includes a `Lessons Learned` field (feedback loop)
- Failure reproducibility (`conftest.py` / `test-reporter` / `-v` flag)
- `new_project.sh` now auto-runs `git init` + configures hooks + initial commit; it fails fast if `.githooks/pre-commit` is missing or not executable
- `new_project.sh` now enforces a root `README.md` (and auto-normalizes `readme.*` variants when found)
- `new_project.sh` now supports destination-root parameterization via `--dest` and `$HARNESS_DEST_ROOT`; see `docs/new_project.usage.zh-en.md`
