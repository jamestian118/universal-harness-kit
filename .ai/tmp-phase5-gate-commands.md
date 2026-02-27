# Phase5 Gate Command Matrix (UHK Lane)

- 生成时间: 2026-02-27 21:02:11 +0800
- 生成路径: `/Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-gate-commands.md`
- 作用域: `/Users/Zhuanz/Documents/Code/universal-harness-kit`
- 固定 6 项目清单:
  - `/Users/Zhuanz/Documents/Code/claude-code-api-config`
  - `/Users/Zhuanz/Documents/Code/claude-session-manager`
  - `/Users/Zhuanz/Documents/Code/cli-handoff-bundle`
  - `/Users/Zhuanz/Documents/Code/git-privacy-guard`
  - `/Users/Zhuanz/Documents/Code/oh-my-orch`
  - `/Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224`

## 0) Strict 入口记录（UHK root）

- 命令:
  ```bash
  ./scripts/agent-policy-stack --tool codex --cwd "$PWD" --strict --strict-profile harness
  ```
- 关键输出:
  - `strict_result=pass`
  - `copy_project_root_relaxed: warn`
  - `strict_copy_project_root_required=false`

## 1) Gate 5 执行矩阵（verify + tests）

| 项目 | Verify 命令 | Tests 命令（模板） | Verify 输出 | Tests 输出 |
|---|---|---|---|---|
| `/Users/Zhuanz/Documents/Code/claude-code-api-config` | `(cd /Users/Zhuanz/Documents/Code/claude-code-api-config && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-claude-code-api-config-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/claude-code-api-config && echo "NO_STANDARD_TEST_ENTRY" 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-claude-code-api-config-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-claude-code-api-config-verify.out` | `.ai/tmp-phase5-claude-code-api-config-tests.out` |
| `/Users/Zhuanz/Documents/Code/claude-session-manager` | `(cd /Users/Zhuanz/Documents/Code/claude-session-manager && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-claude-session-manager-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/claude-session-manager && echo "NO_STANDARD_TEST_ENTRY" 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-claude-session-manager-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-claude-session-manager-verify.out` | `.ai/tmp-phase5-claude-session-manager-tests.out` |
| `/Users/Zhuanz/Documents/Code/cli-handoff-bundle` | `(cd /Users/Zhuanz/Documents/Code/cli-handoff-bundle && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-cli-handoff-bundle-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/cli-handoff-bundle && echo "NO_STANDARD_TEST_ENTRY" 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-cli-handoff-bundle-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-cli-handoff-bundle-verify.out` | `.ai/tmp-phase5-cli-handoff-bundle-tests.out` |
| `/Users/Zhuanz/Documents/Code/git-privacy-guard` | `(cd /Users/Zhuanz/Documents/Code/git-privacy-guard && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-git-privacy-guard-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/git-privacy-guard && echo "NO_STANDARD_TEST_ENTRY" 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-git-privacy-guard-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-git-privacy-guard-verify.out` | `.ai/tmp-phase5-git-privacy-guard-tests.out` |
| `/Users/Zhuanz/Documents/Code/oh-my-orch` | `(cd /Users/Zhuanz/Documents/Code/oh-my-orch && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-oh-my-orch-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/oh-my-orch && ./scripts/test 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-oh-my-orch-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-oh-my-orch-verify.out` | `.ai/tmp-phase5-oh-my-orch-tests.out` |
| `/Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224` | `(cd /Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224 && ./scripts/verify 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-uhk-audit-20260226-224224-verify.out); echo "verify_exit=$?"` | `(cd /Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224 && ./scripts/test 2>&1 | tee /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase5-uhk-audit-20260226-224224-tests.out); echo "tests_exit=$?"` | `.ai/tmp-phase5-uhk-audit-20260226-224224-verify.out` | `.ai/tmp-phase5-uhk-audit-20260226-224224-tests.out` |

## 2) 汇总模板（verify + tests）

> 复制下表后逐仓填写；`pass` 判定建议按 exit code=`0`，并附关键输出摘要。

| repo | verify_exit | verify_result(pass/fail) | verify_log | tests_exit | tests_result(pass/fail/n-a) | tests_log | key_excerpt |
|---|---:|---|---|---:|---|---|---|
| claude-code-api-config |  |  | `.ai/tmp-phase5-claude-code-api-config-verify.out` |  |  | `.ai/tmp-phase5-claude-code-api-config-tests.out` |  |
| claude-session-manager |  |  | `.ai/tmp-phase5-claude-session-manager-verify.out` |  |  | `.ai/tmp-phase5-claude-session-manager-tests.out` |  |
| cli-handoff-bundle |  |  | `.ai/tmp-phase5-cli-handoff-bundle-verify.out` |  |  | `.ai/tmp-phase5-cli-handoff-bundle-tests.out` |  |
| git-privacy-guard |  |  | `.ai/tmp-phase5-git-privacy-guard-verify.out` |  |  | `.ai/tmp-phase5-git-privacy-guard-tests.out` |  |
| oh-my-orch |  |  | `.ai/tmp-phase5-oh-my-orch-verify.out` |  |  | `.ai/tmp-phase5-oh-my-orch-tests.out` |  |
| uhk-audit-20260226-224224 |  |  | `.ai/tmp-phase5-uhk-audit-20260226-224224-verify.out` |  |  | `.ai/tmp-phase5-uhk-audit-20260226-224224-tests.out` |  |

## 3) 当前基线探测

- `scripts/verify`：6/6 仓存在。
- `scripts/test(s)`：仅 `oh-my-orch` 与 `uhk-audit-20260226-224224` 存在统一入口。
- 其余 4 仓在 Gate 5 统计中建议将 tests 先标记为 `n-a`，或由各仓 owner 指定标准测试命令后替换模板。
