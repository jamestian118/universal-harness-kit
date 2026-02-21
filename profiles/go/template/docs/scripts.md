# scripts（脚本说明）

## 中文（ZH）

### prereqs
- go（建议 1.22+）

### setup
```bash
./scripts/setup
```

### exact commands
```bash
./scripts/dev
./scripts/format
./scripts/lint
./scripts/test
./scripts/arch-check
./scripts/verify
```

### examples
```bash
# 本地开发
./scripts/dev

# 最小验证（milestone/stop/切换 CLI 前）
./scripts/verify
```

### I/O
- 输入：通常为命令行参数（dev 脚本会透传参数，若实现）
- 输出：stdout/stderr；失败返回非 0

### flags
- 无统一 flags；若后续为某脚本新增 flags，必须同步更新本文档（中英双语）

### dev
- 启动本地开发环境

### format
- 格式化代码

### lint
- 静态检查代码

### test
- 运行测试套件

### verify
- 最小验证入口，顺序执行格式化、代码检查、测试及自检

### finalize-artifacts
```bash
./scripts/finalize-artifacts dry-run
./scripts/finalize-artifacts confirm --approved-by "$USER"
./scripts/finalize-artifacts apply --token "<confirm-token>"
```
- Artifact 清理闸门（方案 2）：先生成 plan，再基于确认文件执行删除
- `dry-run`：默认扫描 `.artifacts` 与 `test-results`，仅输出候选不删除
- `confirm`：写入 `plan_hash/approved_by/expiry/token`
- `apply`：先跑 verify，再校验 token/expiry/plan hash，仅删除 plan 中且满足 roots + git ignored 的候选
- 审计输出：`.ai/finalize-artifacts.last.json`

### milestone-finalize
```bash
./scripts/milestone-finalize
```
- Milestone 收尾入口：自动执行 verify + finalize-artifacts dry-run
- `CI=true` 或非 TTY：输出“跳过交互清理”，不执行删除
- 交互 TTY：输入 `yes` 后自动执行 confirm + apply；否则保留 artifacts

### docs-check
- 确保系统核心文档存在及 scripts/ 下可执行脚本的文档覆盖率

### secrets-check
- 快速的敏感信息扫描

### setup
- 初始化项目依赖和环境

### arch-check
```bash
./scripts/arch-check
```
- 检查 src/ 中是否存在违规 import/from/require tests/ 的情况
- 违规：输出文件名和行号，exit 1
- 无违规：输出 OK，exit 0
- 已集成到 `./scripts/verify` 流程中（test 之后、docs-check 之前）

### gc
```bash
./scripts/gc
```
- 抗熵检查入口，扫描项目中违反 golden principles 的 drift
- 检查 1：scripts/ 下每个可执行脚本是否在 docs/scripts.md 中有记录
- 检查 2：裸 TODO（不含 issue 编号或截止日期）
- 检查 3：docs/ 中是否混入动态进度（日期模式）
- 非阻断：始终 exit 0，输出 drift report
- CI 定时运行：.github/workflows/gc.yml

### troubleshooting
- verify 失败：先看是哪一步失败（format/lint/test/arch-check/docs-check/secrets-check），修复后重新运行 verify
- secrets-check 误报：优先改为更精确规则或引入专用 secrets 扫描工具（仍通过 scripts/ 与 CI 入口统一调用）

---

## English (EN)

### prereqs
- go (recommended 1.22+)

### setup
```bash
./scripts/setup
```

### exact commands
```bash
./scripts/dev
./scripts/format
./scripts/lint
./scripts/test
./scripts/arch-check
./scripts/verify
```

### examples
```bash
# local dev
./scripts/dev

# minimal verification (before milestone/stop/CLI switch)
./scripts/verify
```

### I/O
- Input: usually CLI args (dev may forward args if implemented)
- Output: stdout/stderr; non-zero exit on failure

### flags
- No unified flags. If any script gains flags, this doc must be updated (bilingual).

### dev
- Starts the local development environment

### format
- Formats the codebase

### lint
- Runs static code analysis

### test
- Runs the test suite

### verify
- Minimal verification entrypoint, sequentially runs format, lint, test, and self-checks

### finalize-artifacts
```bash
./scripts/finalize-artifacts dry-run
./scripts/finalize-artifacts confirm --approved-by "$USER"
./scripts/finalize-artifacts apply --token "<confirm-token>"
```
- Artifact cleanup gate (option 2): generate a plan first, then delete only with explicit confirmation
- `dry-run`: scans `.artifacts` and `test-results` by default, prints candidates only
- `confirm`: writes `plan_hash/approved_by/expiry/token`
- `apply`: runs verify first, validates token/expiry/plan hash, then deletes only planned candidates that are inside roots and git ignored
- Audit output: `.ai/finalize-artifacts.last.json`

### milestone-finalize
```bash
./scripts/milestone-finalize
```
- Milestone closeout entry: runs verify and finalize-artifacts dry-run automatically
- If `CI=true` or non-TTY: prints "跳过交互清理" and skips deletion
- If interactive TTY: type `yes` to run confirm + apply, otherwise keep artifacts

### docs-check
- Ensures core documentation exists and executable scripts under scripts/ are documented

### secrets-check
- Fast heuristic secrets scanning

### arch-check
```bash
./scripts/arch-check
```
- Checks whether src/ contains any forbidden import/from/require usage from tests/
- Violation found: prints file name and line number, exit 1
- No violation: prints OK, exit 0
- Integrated into `./scripts/verify` pipeline (after test, before docs-check)

### gc
```bash
./scripts/gc
```
- Anti-entropy check entry point; scans the project for drift against golden principles
- Check 1: every executable script in scripts/ is documented in docs/scripts.md
- Check 2: bare TODOs (missing issue number or deadline)
- Check 3: dynamic progress dates leaked into docs/
- Non-blocking: always exit 0, outputs drift report
- Scheduled CI: .github/workflows/gc.yml

### troubleshooting
- If verify fails: identify the failed stage (format/lint/test/arch-check/docs-check/secrets-check), fix it, then rerun verify.
- If secrets-check false-positives: tighten patterns or adopt a dedicated secrets scanner (still invoked via scripts/ and CI).
