# bootstrap-stack Usage (中文 + English)

## 中文

### 作用

`scripts/bootstrap-stack` 用于按拓扑序安装并验证 UHK 栈，默认顺序固定为：

1. 渲染 Global policy（`scripts/render-global-policy`）
2. 执行 strict policy gate（`scripts/agent-policy-stack --strict --strict-profile harness`）
3. 执行 policy 自检（`scripts/agent-policy-stack --self-test`）
4. 执行仓库级最小验收（`scripts/verify`）

### 前置条件

- `bash`
- 建议在 kit root 执行：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### 命令

```bash
./scripts/bootstrap-stack [--root <path>] [--tool <codex|claude|gemini>] [--dry-run]
```

### 参数说明

- `--root <path>`：指定 UHK 根目录
  - 默认优先 `UHK_ROOT`，否则使用脚本上级目录
- `--tool <codex|claude|gemini>`：strict gate 的 tool 上下文，默认 `codex`
- `--dry-run`：仅打印执行计划，不真正执行命令
- `-h, --help`：显示帮助

### 示例

```bash
# 使用当前仓默认根目录执行全链路
./scripts/bootstrap-stack

# 显式指定根目录
./scripts/bootstrap-stack --root /Users/Zhuanz/Documents/Code/universal-harness-kit

# 仅预览拓扑执行顺序
./scripts/bootstrap-stack --dry-run
```

### 输出与退出码

- 成功：输出 `DONE`，退出码 `0`
- 参数/环境问题：输出 `FAIL: ...`，退出码 `2`

### Troubleshooting（中文）

1. `UHK root 不存在`
- 原因：`--root` 指向路径不存在
- 处理：修正 `--root` 或设置正确的 `UHK_ROOT`

2. `缺少可执行脚本`
- 原因：`scripts/render-global-policy` / `scripts/agent-policy-stack` / `scripts/verify` 不存在或无执行权限
- 处理：检查路径并执行 `chmod +x ./scripts/*`

---

## English

### Purpose

`scripts/bootstrap-stack` installs and validates the UHK stack in a fixed topological order:

1. Render Global policy (`scripts/render-global-policy`)
2. Run strict policy gate (`scripts/agent-policy-stack --strict --strict-profile harness`)
3. Run policy self-test (`scripts/agent-policy-stack --self-test`)
4. Run repo-level minimal acceptance (`scripts/verify`)

### Prerequisites

- `bash`
- Recommended to run from kit root:

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### Command

```bash
./scripts/bootstrap-stack [--root <path>] [--tool <codex|claude|gemini>] [--dry-run]
```

### Options

- `--root <path>`: UHK root path
  - Defaults to `UHK_ROOT` when set, otherwise script parent directory
- `--tool <codex|claude|gemini>`: tool context for strict gate (default `codex`)
- `--dry-run`: print execution plan only, without running commands
- `-h, --help`: show help

### Examples

```bash
# full install/verification chain with default root
./scripts/bootstrap-stack

# explicit root path
./scripts/bootstrap-stack --root /Users/Zhuanz/Documents/Code/universal-harness-kit

# preview only
./scripts/bootstrap-stack --dry-run
```

### Output and Exit Codes

- Success: prints `DONE`, exits with `0`
- Argument/environment issues: prints `FAIL: ...`, exits with `2`

### Troubleshooting

1. `UHK root 不存在`
- Cause: `--root` path does not exist
- Fix: correct `--root` or set `UHK_ROOT`

2. `缺少可执行脚本`
- Cause: one of `scripts/render-global-policy`, `scripts/agent-policy-stack`, `scripts/verify` is missing or not executable
- Fix: verify files and run `chmod +x ./scripts/*`
