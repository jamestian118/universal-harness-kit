# Handoff - GitHub Publish Workflow Standardization

## Goal / DoD
- 目标：把“推送 GitHub”标准化为单一入口，默认包含：
  1) 本地自动 commit（有改动时）
  2) push 后在对应 PR 自动评论 `@codex review`
  3) 将垃圾清理步骤整合进发布流程并明确位置
- DoD：四个模板（python/node/go/generic）都具备同构 `scripts/publish`，并有中英双语文档与 docs-check 通过证据。

## Repo State
- Branch: `ai/20260221-artifact-finalize`
- HEAD: `1db86c2`
- `git status -sb`：工作区原本存在历史改动（如 `new_project.sh`、`KIT_README.md`、`.DS_Store` 等），本次新增/更新集中在：
  - `profiles/*/template/scripts/publish`
  - `profiles/*/template/docs/scripts.md`
  - `profiles/*/template/docs/publish.usage.zh-en.md`
  - `profiles/*/template/docs/index.md`
  - `README.md`
  - `.ai/lessons-learned.md`

## Evidence (Commands + Key Output)
1. 语法检查（四模板 publish 脚本）
- Command:
  - `bash -n profiles/python/template/scripts/publish`
  - `bash -n profiles/node/template/scripts/publish`
  - `bash -n profiles/go/template/scripts/publish`
  - `bash -n profiles/generic/template/scripts/publish`
- Key output: 无输出且 exit 0（语法通过）

2. 文档覆盖检查（四模板 docs-check）
- Command:
  - `./scripts/docs-check`（分别在四个 `profiles/<lang>/template` 下执行）
- Key output:
  - `[docs-check] OK`（四次）

3. 发布脚本帮助信息检查
- Command: `./scripts/publish --help`（python 模板）
- Key output:
  - 显示完整参数：`--base`、`--commit-message`、`--skip-finalize`、`--skip-codex-review`、`--review-comment`
  - 显示默认 workflow：`milestone-finalize -> auto-commit -> push -> ensure PR -> comment`

4. gh 子命令行为核验（本地 help）
- Commands:
  - `gh pr view --help`
  - `gh pr comment --help`
- Key output:
  - `gh pr view`：无参数时默认当前 branch 对应 PR
  - `gh pr comment`：支持 `--body`，目标可传 `<branch>/<number>/<url>`

## Done
- 新增四套模板脚本：`scripts/publish`
  - 默认先执行 `./scripts/milestone-finalize`（垃圾清理步骤在此阶段）
  - 自动检测工作区，必要时执行 `git add -A && git commit`
  - 自动 push 当前分支
  - 自动查找或创建 PR
  - 自动评论 `@codex review`
- 文档更新：
  - `docs/scripts.md` 增加 `publish` 条目（中英双语）
  - 新增 `docs/publish.usage.zh-en.md`（中英完整用法）
  - `docs/index.md` 增加 publish usage 索引
  - 根 `README.md` 增加标准发布命令说明，并明确垃圾清理阶段位置
- Lessons Learned 已同步追加到全局：`.ai/lessons-learned.md`

## Next Steps
1. 在一个真实项目里执行一次 `./scripts/publish` 全流程 smoke（验证 commit/push/PR/comment 全链路）。
2. 若团队希望更严谨发布闸门，可在 `scripts/publish` 前加 `secrets + PII` 专项扫描子阶段。 
3. 视需要把 `--base main` 改为“自动探测默认分支”（`origin/HEAD`）并补测试。
4. 如需完全无人值守发布，可补 `--yes-finalize`（仅在已确认风险场景启用）。

---

## Milestone Update (2026-02-22): Temporary Validation/Test Automation Script Cleanup

## Goal / DoD
- 目标：当前项目与未来由 `new_project.sh` 生成的项目都默认把“中间验证/测试自动化脚本”纳入统一目录与统一清理流程。
- DoD：四模板 `finalize-artifacts` 默认 roots 扩展到 `scripts/.tmp` 与 `.ai/tmp-scripts`，并同步 `.gitignore` 与中英文档；补充全局约束与 lessons learned 证据。

## Repo State
- Branch: `ai/20260221-artifact-finalize`
- HEAD: `1db86c2`
- 相关改动集中在：
- `profiles/*/template/scripts/finalize-artifacts`
- `profiles/*/template/.gitignore`
- `profiles/*/template/docs/finalize-artifacts.usage.zh-en.md`
- `profiles/*/template/docs/scripts.md`
- `profiles/*/template/docs/quality.md`（generic/python）
- `README.md`
- `/Users/Zhuanz/AGENTS.md`
- `/Users/Zhuanz/.claude/CLAUDE.md`
- `.ai/lessons-learned.md`

## Evidence (Commands + Key Output)
1. 默认 roots 已机械化到四模板
- Command:
- `rg -n 'DEFAULT_ROOTS=\("\.artifacts" "test-results" "scripts/\.tmp" "\.ai/tmp-scripts"\)' profiles/*/template/scripts/finalize-artifacts`
- Key output:
- 四模板均命中 `DEFAULT_ROOTS=(".artifacts" "test-results" "scripts/.tmp" ".ai/tmp-scripts")`

2. 脚本语法检查
- Command:
- `bash -n profiles/{generic,go,node,python}/template/scripts/finalize-artifacts`
- Key output:
- `finalize-artifacts: bash -n OK (all profiles)`

3. ignore 约束检查
- Command:
- `rg -n 'scripts/\.tmp/|\.ai/tmp-scripts/' profiles/*/template/.gitignore`
- Key output:
- 四模板 `.gitignore` 均包含 `scripts/.tmp/` 与 `.ai/tmp-scripts/`

4. 文档一致性检查
- Command:
- `rg -n '\.artifacts.+test-results.+scripts/\.tmp.+\.ai/tmp-scripts|scripts/\.tmp.+\.ai/tmp-scripts.+\.artifacts' profiles/*/template/docs/{scripts.md,finalize-artifacts.usage.zh-en.md,quality.md}`
- Key output:
- 四模板 `scripts.md` 与 `finalize-artifacts.usage.zh-en.md` 均命中，`quality.md`（generic/python）同步命中。

5. 最小验收链路（模板级）
- Commands:
- `./scripts/verify`（四模板）
- `./scripts/gc`（四模板）
- Key output:
- verify 失败（环境/模板初始化未完成）：
- generic: `TODO(#INIT): configure format/lint/test`
- go: `gofmt/go: command not found`
- node: `prettier/eslint: command not found`
- python: `.venv/bin/activate: No such file or directory`
- gc 均返回同类 drift：`docs/scripts.md` 中 `./scripts/query-logs --since 2026-01-01` 被标记为动态进度。

## Done
- 已将“临时验证/测试自动化脚本清理”升级为默认机械化规则（当前 + 未来模板）。
- 已把目录规范固化为 `scripts/.tmp` 与 `.ai/tmp-scripts`，并纳入 `finalize-artifacts` 默认清理根。
- 已同步全局规则：`/Users/Zhuanz/AGENTS.md`、`/Users/Zhuanz/.claude/CLAUDE.md`。
- 已同步记录到 `.ai/lessons-learned.md`（同类问题第 3 次，升级为机械化检查）。

## Next Steps
1. 在任意新建项目中验证一次：生成临时脚本到 `scripts/.tmp`，执行 `./scripts/finalize-artifacts --yes`，确认自动清理。
2. 修复 `scripts/gc` 对 `docs/scripts.md` 示例命令的动态进度误报（把示例路径加入 allowlist）。
3. 若要进一步收紧发布闸门，可在 `scripts/publish` 前增加“临时脚本目录非空阻断”检查（需要时开启）。

---

## Milestone Update (2026-02-26): Final Sync P2-3 + P3 Governance

## Goal / DoD
- Goal: 完成执行文档中的 P2-3 与 P3（README 澄清、policy 安全 gate、doc-file parity 脚本、lessons 同步）。
- DoD:
  - `README.md` 顶部明确 kit root vs generated project。
  - `scripts/agent-policy-stack` 新增 `global_no_plaintext_secrets` 并纳入 strict 合约。
  - 新增 `scripts/check-doc-file-parity` + 双语 usage 文档。
  - `.ai/lessons-learned.md` 追加三条本次教训。

## Repo State
- Branch: `ai/20260221-artifact-finalize`
- HEAD: `1db86c2`
- 备注: 工作区存在大量历史改动；本次改动聚焦 `README.md`、`scripts/`、`docs/`、`.ai/lessons-learned.md`。

## Evidence (Commands + Key Output)
1. strict gate（含新检查）
- Command:
  - `./scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz --strict --strict-profile harness`
- Key output:
  - `global_no_plaintext_secrets: pass (checked 3 file(s): ~/.claude/settings.json, ~/.claude/scripts/*, ~/.codex/config.toml)`
  - `strict_result=pass`

2. 脚本语法
- Command:
  - `bash -n scripts/agent-policy-stack scripts/check-doc-file-parity`
- Key output:
  - `bash_syntax_ok`

3. parity 脚本 smoke
- Command:
  - `./scripts/check-doc-file-parity /Users/Zhuanz/Documents/Code/cli-handoff-bundle`
- Key output:
  - `check1_readme_commands=pass`
  - `check2_workflow_version=fail`
  - `overall=fail`
  - 说明：该结果表明脚本正常发现版本标识缺失问题。

## Done
- `README.md` 顶部新增 kit root 声明（3 行）。
- `scripts/agent-policy-stack` 新增 `global_no_plaintext_secrets` 检查并接入 strict 阻断。
- 新增 `scripts/check-doc-file-parity`。
- 新增 `docs/check-doc-file-parity.usage.zh-en.md`。
- 更新 `docs/agent-policy-stack.usage.zh-en.md`（补充新检查说明）。
- 追加 `.ai/lessons-learned.md` 三条同步条目。

## Next Steps
1. 将 `scripts/check-doc-file-parity` 纳入发布前检查链（如 `scripts/verify` 或 CI docs-check）。
2. 若要通过“全量 grep 安全扫描=空输出”，需单独规划历史缓存/备份清理策略。
3. 持续在 global policy 升级时同步三端文档版本标识，避免再次漂移。

---

## 当前状态：[已完成 UHK Gate lane Phase1 输入盘点；新增 .ai/tmp-phase1-gate-input.md；strict 已执行并 pass（含 copy_project_root_relaxed: warn）；关键文件：.ai/tmp-phase1-gate-input.md]
## 下一步：[1) 由 owner 确认固定 6 项目清单是否需要替换 2) 对缺少 scripts/secrets-check 的仓补齐最小脚本骨架 3) 逐仓执行 Gate1 命令模板并收集 strict 输出]
## 已知问题：[当前固定 6 项目清单基于现状仓库约定（claude-code-api-config / claude-session-manager / cli-handoff-bundle / git-privacy-guard / oh-my-orch / uhk-audit-20260226-224224）；若治理口径变更需更新清单后重跑盘点]

---

## 当前状态：[已完成 UHK Phase 3 gate lane；新增 .ai/tmp-phase3-gate-commands.md；strict 已执行并 pass（strict_result=pass，copy_project_root_relaxed: warn）；关键文件：.ai/tmp-phase3-gate-commands.md]
## 下一步：[1) 让 csm 可执行路径进入 PATH（当前 command -v csm = NOT_FOUND）2) 按模板执行 OMO/CSM 命令并落盘 .ai/tmp-phase3-*.out 3) 按 debug 规则（R1 && R2）判定 gate]
## 已知问题：[当前 OMO 基线仅输出 help 文本，未出现 debug 字段/行；CSM 基线为 command not found（exit 127），两者均未达到 Gate 3 通过条件]

---

## 当前状态：[已完成 Phase 4 UHK lane 4.7/4.8；新增 tests/test_new_project.sh 与 tests/test_policy_stack.sh；scripts/verify 已纳入 shell_tests；修复 new_project.sh 在 unsupported --lang 分支的 unbound variable；同步 docs/verify.usage.zh-en.md 与 docs/new_project.usage.zh-en.md]
## 下一步：[1) 若 CI 需强制 shellcheck，可在 runner 安装 shellcheck 后复跑 scripts/verify 2) 若要扩展回归维度，可继续补充 tests/ 下更多 strict-profile 场景（如 contract drift/fail reason 细粒度断言）]
## 已知问题：[当前环境未安装 shellcheck，scripts/verify 输出 WARN 后跳过；其余步骤与 shell_tests 均通过]

---

## Milestone Update (2026-02-27): Phase 5 Gate Lane Matrix (UHK support lane)

## Goal / DoD
- 目标：产出 Gate 5 执行矩阵（固定 6 仓 `verify + tests`）并提供可填写汇总模板。
- DoD：
  - 新增 `.ai/tmp-phase5-gate-commands.md`，包含逐仓命令、输出落盘路径、汇总表。
  - 在 UHK root 执行 strict 并记录 `strict_result`。

## Evidence (Commands + Key Output)
1. strict gate
- Command:
  - `./scripts/agent-policy-stack --tool codex --cwd "$PWD" --strict --strict-profile harness`
- Key output:
  - `strict_result=pass`
  - `copy_project_root_relaxed: warn`

2. 固定 6 仓脚本入口探测
- Command:
  - `for repo in <6 repos>; do [ -f scripts/verify ] ...; [ -f scripts/test ]/[ -f scripts/tests ] ...; done`
- Key output:
  - `scripts/verify`: 6/6 present
  - `scripts/test(s)`: 2/6 present (`oh-my-orch`, `uhk-audit-20260226-224224`)

## Done
- 新增文件：`.ai/tmp-phase5-gate-commands.md`
  - 包含 6 仓 Gate 5 `verify + tests` 命令矩阵
  - 包含 `.ai/tmp-phase5-*.out` 输出命名约定
  - 包含 verify/tests 汇总模板表格

## 当前状态：[已完成 UHK Phase 5 gate lane 文档产物；strict 已执行并 pass（strict_result=pass，copy_project_root_relaxed: warn）；关键文件：.ai/tmp-phase5-gate-commands.md]
## 下一步：[1) 按矩阵逐仓执行 verify/tests 并填汇总表 2) 对缺失 `scripts/test(s)` 的 4 仓确认 tests 口径（n-a 或补统一入口）3) 将汇总结果写回 handoff]
## 已知问题：[`claude-code-api-config`/`claude-session-manager`/`cli-handoff-bundle`/`git-privacy-guard` 暂无统一 `scripts/test(s)`；当前模板默认 `NO_STANDARD_TEST_ENTRY`]

---

## Milestone Update (2026-02-27): Phase 6 Gate Command Matrix (UHK support lane)

## Goal / DoD
- 目标：产出 Gate 6 命令矩阵，覆盖 `omo --help`、`csm --help`、Gate 判定规则（可读性 + 信息完整性）与主线程可直接执行模板。
- DoD：
  - 新增 `.ai/tmp-phase6-gate-commands.md`，结构简洁可复用（复用 phase5 文档骨架）。
  - 在 UHK root 记录 strict 通过证据。
  - 本仓验证链通过：`./scripts/verify`；`./scripts/secrets-check` 若存在则通过（当前不存在，按规则 skip）。

## Evidence (Commands + Key Output)
1. strict gate
- Command:
  - `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/universal-harness-kit --strict --strict-profile harness`
- Key output:
  - `strict_result=pass`
  - `copy_project_root_relaxed: warn`

2. help baseline 探测
- Commands:
  - `omo --help`
  - `csm --help`
- Key output:
  - `omo_exit=0`，且输出包含 `usage:`、`pipeline`、`team`、`resume`
  - `csm_exit=0`，且输出包含 `usage:`、`handoff`、`mcp`、`memory-sync`

3. verify
- Command:
  - `./scripts/verify`
- Key output:
  - `[verify] OK`
  - `shellcheck` 为 WARN/skip（环境未安装），其余检查与 shell_tests 通过。

4. secrets-check（条件执行）
- Command:
  - `if [ -x ./scripts/secrets-check ]; then ./scripts/secrets-check; else echo "[secrets-check] SKIP"; fi`
- Key output:
  - `[secrets-check] SKIP: ./scripts/secrets-check not found or not executable`

## Done
- 新增文件：`.ai/tmp-phase6-gate-commands.md`
  - 包含 Gate 6 命令矩阵（OMO/CSM help）
  - 包含 Readability/Completeness 判定规则与 PASS/FAIL/NEEDS_OWNER_INPUT 决策
  - 包含主线程一键执行模板与回填表

## 当前状态：[已完成 UHK Phase 6 support lane 文档产物；strict 与 verify 均通过；关键文件：.ai/tmp-phase6-gate-commands.md]
## 下一步：[1) 主线程按模板执行并回填 Gate 6 结果 2) 如 OMO/CSM help 关键词漂移，由 owner 决定是否放宽关键字门槛]
## 已知问题：[`./scripts/secrets-check` 当前不存在（按“若存在则执行”规则已记录 skip）]

---

## Milestone Update (2026-02-27): Phase 7 UHK Lane (7.1 / 7.8 / 7.9 / 7.10)

## Goal / DoD
- 目标：在 UHK root 完成 Phase 7 lane 交付：
  - 7.1 新增 root CI workflow（shellcheck + smoke，复用现有 `scripts/verify`）
  - 7.8 新增 `scripts/bootstrap-stack`（拓扑序安装，支持 `--dry-run` / `--root`）
  - 7.9 `scripts/agent-policy-stack` 新增 `--self-test`
  - 7.10 在 UHK 范围做最小路径硬编码参数化（不破坏现有行为）
- DoD：strict pass、`./scripts/verify` pass、（若存在）`scripts/secrets-check` pass、handoff 记录完整证据。

## Repo State
- Branch: `ai/20260227-phase0-upgrade`
- 关键改动文件：
  - `.github/workflows/verify.yml`
  - `scripts/bootstrap-stack`
  - `scripts/agent-policy-stack`
  - `scripts/verify`
  - `tests/test_bootstrap_stack.sh`
  - `tests/test_policy_stack.sh`
  - `new_project.sh`
  - `docs/bootstrap-stack.usage.zh-en.md`
  - `docs/agent-policy-stack.usage.zh-en.md`
  - `docs/new_project.usage.zh-en.md`
  - `docs/verify.usage.zh-en.md`
  - `README.md`

## Evidence (Commands + Key Output)
1. strict policy（必须项）
- Command:
  - `./scripts/agent-policy-stack --tool codex --cwd "$PWD" --strict --strict-profile harness`
- Key output:
  - `strict_result=pass`
  - `copy_project_root_relaxed: warn`（workflow root 场景）

2. verify（必须项）
- Command:
  - `./scripts/verify`
- Key output:
  - `[verify] PASS: bash_syntax`
  - `[verify] PASS: smoke_policy_json_schema`
  - `[verify] PASS: shell_tests`
  - `[test_bootstrap_stack] PASS`
  - `[test_new_project] PASS`
  - `[test_policy_stack] PASS`
  - `[verify] OK`

3. self-test（7.9）
- Command:
  - `./scripts/agent-policy-stack --self-test`
- Key output:
  - `[agent-policy-stack][self-test] RUN: tests/test_policy_stack.sh`
  - `[test_policy_stack] PASS`
  - `[agent-policy-stack][self-test] PASS`

4. bootstrap-stack dry-run（7.8）
- Command:
  - `./scripts/bootstrap-stack --dry-run`
- Key output:
  - `STEP 1/4: render-global-policy`
  - `STEP 2/4: agent-policy-stack strict`
  - `STEP 3/4: agent-policy-stack self-test`
  - `STEP 4/4: verify`
  - `DONE`

5. secrets-check（条件项）
- Command:
  - `if [ -x scripts/secrets-check ]; then ./scripts/secrets-check; else echo "[secrets-check] SKIP: scripts/secrets-check not found"; fi`
- Key output:
  - `[secrets-check] SKIP: scripts/secrets-check not found`

## Risks / Boundaries
- 本地环境未安装 `shellcheck`，`scripts/verify` 按设计输出 WARN 并继续；CI workflow 已显式 `apt-get install shellcheck`，可在 CI 强制覆盖该检查。
- `scripts/bootstrap-stack` 默认会执行 `render-global-policy`（非 dry-run），会写入 `~/.codex/AGENTS.md` / `~/.claude/CLAUDE.md` / `~/.gemini/GEMINI.md`；如需仅预览请使用 `--dry-run`。
- `scripts/secrets-check` 在 kit root 当前不存在，本次无法给出 pass 证据，仅能给出 skip 证据。

## 当前状态：[已完成 Phase 7 UHK lane 7.1/7.8/7.9/7.10；已补 CI + bootstrap + self-test + 路径参数化 + 双语文档；strict/verify 已通过]
## 下一步：[1) 审核并提交本次改动 2) 如需可补一次 GitHub Actions 实跑验证 shellcheck gate 3) 若 owner 要求，可将 root verify workflow 同步到 profile template 的 workflow contract]
## 已知问题：[本地 shellcheck 缺失仅输出 WARN；CI 已安装 shellcheck 并可强制执行]
