# sanitized-publish-artifacts Usage (中文 + English)

## 中文

### 作用

`scripts/sanitized-publish-artifacts` 用于统一管理 GitHub 发布流程的中间产物（sanitize/classify/publish 阶段）。

默认把所有 run 放到固定目录：

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts/runs/<mode>_<timestamp>`

这样不会再在 `Code/` 根目录散落多个 `_sanitized_publish_*` 目录。

### 前置条件

- macOS / Linux shell（`bash`）
- 可用命令：`find`、`stat`、`du`
- 建议在仓库根目录执行：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### 命令总览

```bash
./scripts/sanitized-publish-artifacts <command> [options]
```

支持命令：

- `new`：创建一个新的 run 目录并输出绝对路径
- `list`：按时间倒序列出 run
- `cleanup`：保留最新 N 个 run，并清理超过 N 天的旧 run
- `root`：输出 artifact 根目录

### 常用流程

1) 创建本次发布 run 目录（例如 incremental）：

```bash
RUN_DIR="$(./scripts/sanitized-publish-artifacts new --mode incremental)"
echo "$RUN_DIR"
```

2) 在发布脚本里使用该路径：

```bash
# 示例：将 stage/reports/work 都放到 RUN_DIR 下
STAGE_DIR="$RUN_DIR/stage"
mkdir -p "$STAGE_DIR" "$RUN_DIR/reports" "$RUN_DIR/work"
```

3) 查看历史 run：

```bash
./scripts/sanitized-publish-artifacts list
```

4) 定期清理（先 dry-run，再执行）：

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply
```

### 参数说明

#### `new`

- `--mode <full|incremental|debug>`：run 类型，默认 `incremental`
- `--root <dir>`：自定义根目录，默认 `/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts`
- `--run-id <id>`：自定义 run id（默认时间戳）

输出：

- 标准输出返回 run 绝对路径，例如：

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts/runs/incremental_20260222_101530`

#### `list`

- `--root <dir>`：自定义根目录

输出：

- 每行 `创建时间<TAB>目录路径`

#### `cleanup`

- `--days <N>`：超过 N 天才允许删除，默认 `14`
- `--keep <N>`：无论天数，始终保留最新 N 个 run，默认 `3`
- `--apply`：真正删除；不加时为 dry-run
- `--root <dir>`：自定义根目录

输出：

- 每个 run 的决策（`[keep]` / `[delete]`）和原因
- 最后输出可释放或已释放空间

### 定期执行（建议）

建议每周执行一次：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply
```

如需系统级定时，可放到 `launchd` 或 `cron`。

自动化推荐（launchd）：

```bash
./scripts/sanitized-publish-artifacts-scheduler install
./scripts/sanitized-publish-artifacts-scheduler status
```

说明：在 macOS 上，scheduler 会使用 `~/.local/share/sanitized_publish_artifacts` 作为后台运行根，并维护 `Code/_sanitized_publish_artifacts` 的 alias，避免 `Documents` 路径被后台 TCC 拦截。

### Troubleshooting

1) 提示 `Permission denied`

- 检查脚本可执行位：

```bash
chmod +x ./scripts/sanitized-publish-artifacts
```

2) `cleanup` 没删任何目录

- 先用 dry-run 看决策；通常是因为目录仍在保留窗口（最新 N 个或未超过 N 天）。

3) 想迁移到其他根目录

- 所有命令都支持 `--root <dir>`，可先 `list --root` 验证再切换。

---

## English

### Purpose

`scripts/sanitized-publish-artifacts` standardizes where publish artifacts are stored for sanitize/classify/publish workflows.

Default root:

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts/runs/<mode>_<timestamp>`

This prevents scattered `_sanitized_publish_*` directories under `Code/`.

### Prerequisites

- macOS/Linux shell (`bash`)
- Available commands: `find`, `stat`, `du`
- Recommended working directory:

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### Command Summary

```bash
./scripts/sanitized-publish-artifacts <command> [options]
```

Commands:

- `new`: create a new run directory and print its absolute path
- `list`: list runs in reverse chronological order
- `cleanup`: keep newest N runs, delete runs older than N days
- `root`: print artifact root path

### Common Workflow

1) Create a run directory (for example, incremental):

```bash
RUN_DIR="$(./scripts/sanitized-publish-artifacts new --mode incremental)"
echo "$RUN_DIR"
```

2) Use the path in your publish pipeline:

```bash
STAGE_DIR="$RUN_DIR/stage"
mkdir -p "$STAGE_DIR" "$RUN_DIR/reports" "$RUN_DIR/work"
```

3) List existing runs:

```bash
./scripts/sanitized-publish-artifacts list
```

4) Periodic cleanup (dry-run first, then apply):

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply
```

### Options

#### `new`

- `--mode <full|incremental|debug>`: run type, default `incremental`
- `--root <dir>`: custom root (default `/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts`)
- `--run-id <id>`: custom run id (default timestamp)

Output:

- Absolute run path, e.g.

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts/runs/incremental_20260222_101530`

#### `list`

- `--root <dir>`: custom root

Output:

- One line per run: `created_time<TAB>path`

#### `cleanup`

- `--days <N>`: delete only if older than N days (default `14`)
- `--keep <N>`: always keep newest N runs (default `3`)
- `--apply`: perform deletion; without this, it's dry-run
- `--root <dir>`: custom root

Output:

- Per-run decision (`[keep]` / `[delete]`) and reason
- Final reclaimable/reclaimed size summary

### Periodic Execution (Recommended)

Run once per week:

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply
```

Use `launchd` or `cron` if you want scheduler-based cleanup.

Recommended automation via launchd:

```bash
./scripts/sanitized-publish-artifacts-scheduler install
./scripts/sanitized-publish-artifacts-scheduler status
```

Note: on macOS, the scheduler uses `~/.local/share/sanitized_publish_artifacts` as its background root and maintains a `Code/_sanitized_publish_artifacts` alias to avoid TCC blocking on background access to `Documents`.

### Troubleshooting

1) `Permission denied`

```bash
chmod +x ./scripts/sanitized-publish-artifacts
```

2) `cleanup` deleted nothing

- Check dry-run output first; runs may still be protected by `--keep` or age threshold.

3) Need another artifact root

- All commands support `--root <dir>`. Validate with `list --root` before switching.
