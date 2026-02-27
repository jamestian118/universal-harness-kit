# Phase1 Gate Input (UHK Lane)

- 生成时间: 2026-02-27 20:09:44 +0800
- 生成位置: /Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase1-gate-input.md
- 严格检查入口: `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd <PROJECT_ROOT> --strict --strict-profile harness`
- 固定 6 项目清单:
  - /Users/Zhuanz/Documents/Code/claude-code-api-config
  - /Users/Zhuanz/Documents/Code/claude-session-manager
  - /Users/Zhuanz/Documents/Code/cli-handoff-bundle
  - /Users/Zhuanz/Documents/Code/git-privacy-guard
  - /Users/Zhuanz/Documents/Code/oh-my-orch
  - /Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224

## Gate1 命令模板与缺失项

| 项目 | Gate1 命令模板 | scripts/verify | scripts/secrets-check | 缺失项 |
|---|---|---|---|---|
| /Users/Zhuanz/Documents/Code/claude-code-api-config | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/claude-code-api-config --strict --strict-profile harness` | Y | N | scripts/secrets-check |
| /Users/Zhuanz/Documents/Code/claude-session-manager | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/claude-session-manager --strict --strict-profile harness` | Y | N | scripts/secrets-check |
| /Users/Zhuanz/Documents/Code/cli-handoff-bundle | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/cli-handoff-bundle --strict --strict-profile harness` | Y | N | scripts/secrets-check |
| /Users/Zhuanz/Documents/Code/git-privacy-guard | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/git-privacy-guard --strict --strict-profile harness` | Y | Y | - |
| /Users/Zhuanz/Documents/Code/oh-my-orch | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/oh-my-orch --strict --strict-profile harness` | Y | Y | - |
| /Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224 | `/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool codex --cwd /Users/Zhuanz/Documents/Code/uhk-audit-20260226-224224 --strict --strict-profile harness` | Y | Y | - |

## 执行备注

- 本文件仅做 Gate1 输入盘点，不修改业务代码。
- 存在性检查口径为文件存在（`-f`），未校验可执行权限。
