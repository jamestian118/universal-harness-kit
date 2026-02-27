# new_project.sh Usage (中文 + English)

## 中文

### 作用

`new_project.sh` 用于从 `profiles/<lang>/template/` 复制项目骨架，替换 `__PROJECT_NAME__` 占位符，并在新目录执行 `git init` + 初始 commit。

### 前置条件

- `bash`
- `python3`
- `git`
- 在 kit root 执行（推荐）：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### 命令

```bash
./new_project.sh <project-name> --lang <python|node|go|generic> [--dest <path>]
```

### 参数与默认值

- `<project-name>`：项目名（必填）
  - 正则：`^[a-z0-9][a-z0-9._-]{0,62}$`
  - 仅允许小写字母、数字、`.`、`_`、`-`
  - 必须以字母或数字开头，长度 1-63
- `--lang`：模板类型，默认 `python`
- `--dest`：项目目标根目录（可选）
  - 优先级高于环境变量 `HARNESS_DEST_ROOT`
- `HARNESS_DEST_ROOT`：当未传 `--dest` 时生效
- 都未设置时默认目标根目录：`/Users/Zhuanz/Documents/Code`

### 示例

```bash
./new_project.sh demo-api --lang python
./new_project.sh web-tool --lang node
./new_project.sh cli-go --lang go --dest /tmp/uhk-go
HARNESS_DEST_ROOT=/tmp/uhk-env ./new_project.sh misc --lang generic
```

### 输入 / 输出

输入：

- 语言 profile
- 项目名
- 目标根目录（`--dest` / `HARNESS_DEST_ROOT` / 默认值）

输出：

- 目标目录 `<dest-root>/<project-name>`
- 初始 Git 仓库与首个 commit
- 标准下一步提示：`./scripts/setup`、`./scripts/verify`

### 常见错误

1. `project-name 不合法`
- 原因：不满足命名正则（常见是大写、空格、特殊符号）
- 处理：改为小写 kebab/slug 风格

2. `目标目录已存在`
- 原因：目标目录已被占用
- 处理：换项目名或换 `--dest`

3. `模板不存在`
- 原因：`--lang` 不在支持范围或模板目录损坏
- 处理：确认 `profiles/<lang>/template/` 存在

---

## English

### Purpose

`new_project.sh` copies project scaffolding from `profiles/<lang>/template/`, replaces `__PROJECT_NAME__` placeholders, and bootstraps a Git repo with an initial commit.

### Prerequisites

- `bash`
- `python3`
- `git`
- Run from kit root (recommended):

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### Command

```bash
./new_project.sh <project-name> --lang <python|node|go|generic> [--dest <path>]
```

### Arguments and Defaults

- `<project-name>`: required project name
  - Regex: `^[a-z0-9][a-z0-9._-]{0,62}$`
  - Allowed chars: lowercase letters, digits, `.`, `_`, `-`
  - Must start with alnum, length 1-63
- `--lang`: profile type, default `python`
- `--dest`: optional destination root
  - Higher priority than `HARNESS_DEST_ROOT`
- `HARNESS_DEST_ROOT`: used when `--dest` is not provided
- If neither is set, default destination root is `/Users/Zhuanz/Documents/Code`

### Examples

```bash
./new_project.sh demo-api --lang python
./new_project.sh web-tool --lang node
./new_project.sh cli-go --lang go --dest /tmp/uhk-go
HARNESS_DEST_ROOT=/tmp/uhk-env ./new_project.sh misc --lang generic
```

### Inputs / Outputs

Inputs:

- language profile
- project name
- destination root (`--dest` / `HARNESS_DEST_ROOT` / default)

Outputs:

- destination directory `<dest-root>/<project-name>`
- initialized Git repo with initial commit
- next-step hints: `./scripts/setup` and `./scripts/verify`

### Troubleshooting

1. `project-name 不合法`
- Cause: name does not match regex (common: uppercase, spaces, symbols)
- Fix: use lowercase slug-like names

2. `目标目录已存在`
- Cause: destination directory already exists
- Fix: choose a different name or `--dest`

3. `模板不存在`
- Cause: unsupported `--lang` or missing template directory
- Fix: confirm `profiles/<lang>/template/` exists
