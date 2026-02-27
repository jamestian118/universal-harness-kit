# check-doc-file-parity Usage (中文 + English)

## 中文

### 作用

`scripts/check-doc-file-parity` 用于做文档与文件的一致性检查，避免出现“README 写了但仓库里不存在”或“三端 workflow version 漂移”。

脚本默认检查两项：

1. README 声明的 commands 目录/文件是否存在
2. `AGENTS.md` / `.claude/CLAUDE.md` / `.gemini/GEMINI.md` 的 workflow version string 是否一致

### 前置条件

- macOS / Linux shell（`bash`）
- 推荐在仓库根目录执行
- 脚本可执行：

```bash
chmod +x ./scripts/check-doc-file-parity
```

### 命令

```bash
./scripts/check-doc-file-parity [project_root]
```

- `project_root` 省略时默认当前目录
- 也可传绝对路径或相对路径

### 检查细节

#### 检查1：README commands parity

- 读取 `README.md`
- 提取 backtick 中的 commands 声明路径（如 `.codex/commands/`、`.claude/commands/closeout.md`）
- 提取 README 中 bullet 形式声明的 slash command（如 `` `/takeover` ``）
- 校验逻辑：
  - README 声明的 command 文件必须存在
  - README 声明的 command 目录必须存在
  - 当 README 同时声明了 command 目录和 slash command 时，要求 `<dir>/<command>.md` 存在

#### 检查2：workflow version consistency

- 检查文件：
  - `AGENTS.md`
  - `.claude/CLAUDE.md`
  - `.gemini/GEMINI.md`
- 从文件中提取 workflow version（例如 `V4.3` / `v4.3` / `workflow ... 4.3`）
- 三个文件必须都存在且版本一致，否则失败并输出差异

### 输出格式

固定输出：

- `root=<abs_path>`
- `check1_readme_commands=pass|fail`
- `check2_workflow_version=pass|fail`
- `overall=pass|fail`
- `diffs:`（差异清单）

示例输出（失败）：

```text
root=/path/to/repo
check1_readme_commands=fail
check2_workflow_version=fail
overall=fail
diffs:
- check1: declared command directory missing: .codex/commands
- check1: slash command declared but file missing: /closeout -> .codex/commands/closeout.md
- check2: workflow version mismatch: AGENTS.md=v4.3; .claude/CLAUDE.md=v4.2; .gemini/GEMINI.md=v4.3
```

### 退出码

- `0`：全部通过
- `1`：存在至少一项失败
- `2`：参数错误（如路径不存在、参数过多）

### 常见问题

1) 报 `missing README.md`

- 原因：目标目录没有根 `README.md`
- 处理：补齐根文档或传入正确项目根目录

2) 报 slash command 文件缺失

- 原因：README 声明了 `/xxx`，但未提供对应的 `.codex/.claude/.gemini` command markdown
- 处理：新增对应 `commands/<name>.md`，或同步修改 README 声明

3) 报 workflow version string not found

- 原因：文件中没有可识别版本标识
- 处理：在三份文件统一补齐相同 workflow version（如 `V4.3`）

---

## English

### Purpose

`scripts/check-doc-file-parity` validates doc-to-file consistency so the repo does not drift into:
- “README claims it exists, but file is missing”
- “workflow version differs across AGENTS / CLAUDE / GEMINI docs”

It runs two checks by default:

1. README-declared commands paths exist
2. Workflow version strings are consistent across:
   `AGENTS.md` / `.claude/CLAUDE.md` / `.gemini/GEMINI.md`

### Prerequisites

- macOS / Linux shell (`bash`)
- Run from repository root (recommended)
- Ensure executable bit:

```bash
chmod +x ./scripts/check-doc-file-parity
```

### Command

```bash
./scripts/check-doc-file-parity [project_root]
```

- If `project_root` is omitted, current directory is used
- Absolute and relative paths are both supported

### Check Details

#### Check 1: README commands parity

- Reads `README.md`
- Extracts backticked commands declarations (for example `.codex/commands/`, `.claude/commands/closeout.md`)
- Extracts bullet-style slash command declarations (for example `` `/takeover` ``)
- Validation logic:
  - Declared command files must exist
  - Declared command directories must exist
  - If command directories and slash commands are both declared, `<dir>/<command>.md` must exist

#### Check 2: Workflow version consistency

- Files checked:
  - `AGENTS.md`
  - `.claude/CLAUDE.md`
  - `.gemini/GEMINI.md`
- Extracts workflow version tokens (for example `V4.3`, `v4.3`, or `workflow ... 4.3`)
- All three files must exist and resolve to the same version, otherwise fail with diffs

### Output Format

Always prints:

- `root=<abs_path>`
- `check1_readme_commands=pass|fail`
- `check2_workflow_version=pass|fail`
- `overall=pass|fail`
- `diffs:` (difference list)

Example (fail):

```text
root=/path/to/repo
check1_readme_commands=fail
check2_workflow_version=fail
overall=fail
diffs:
- check1: declared command directory missing: .codex/commands
- check1: slash command declared but file missing: /closeout -> .codex/commands/closeout.md
- check2: workflow version mismatch: AGENTS.md=v4.3; .claude/CLAUDE.md=v4.2; .gemini/GEMINI.md=v4.3
```

### Exit Codes

- `0`: all checks passed
- `1`: one or more checks failed
- `2`: invalid arguments (for example missing path, too many args)

### Troubleshooting

1) `missing README.md`

- Cause: target root has no top-level `README.md`
- Fix: add root README or pass the correct project root

2) Slash command file missing

- Cause: README declares `/xxx`, but corresponding command markdown is absent
- Fix: add `commands/<name>.md` under declared command dirs, or update README declarations

3) `workflow version string not found`

- Cause: no recognizable workflow version marker in one of the required files
- Fix: add a consistent workflow version marker (for example `V4.3`) to all three files
