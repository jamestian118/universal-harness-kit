# sanitized-publish-artifacts-scheduler Usage (中文 + English)

## 中文

### 作用

`scripts/sanitized-publish-artifacts-scheduler` 用于把发布产物清理任务注册为 `launchd` 定时任务，实现自动化定期清理。

默认会定时执行：

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply --root ~/.local/share/sanitized_publish_artifacts
```

安装时会自动维护一个 alias：

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts -> ~/.local/share/sanitized_publish_artifacts`

### 前置条件

- macOS（支持 `launchd`）
- `bash`、`launchctl` 可用
- 已存在清理脚本：`scripts/sanitized-publish-artifacts`

建议先进入目录：

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### 快速开始

1) 安装定时任务（默认每周日 03:15）

```bash
./scripts/sanitized-publish-artifacts-scheduler install
```

2) 查看状态

```bash
./scripts/sanitized-publish-artifacts-scheduler status
```

3) 立即触发一次（用于验收）

```bash
./scripts/sanitized-publish-artifacts-scheduler run-now
```

### 命令说明

#### install

```bash
./scripts/sanitized-publish-artifacts-scheduler install [options]
```

可选参数：

- `--days <N>`：清理年龄阈值（默认 `14`）
- `--keep <N>`：始终保留最新 N 个 run（默认 `3`）
- `--weekday <1-7>`：周几执行（1=Sunday，默认 `1`）
- `--hour <0-23>`：小时（默认 `3`）
- `--minute <0-59>`：分钟（默认 `15`）
- `--root <dir>`：artifact 根目录（默认 `~/.local/share/sanitized_publish_artifacts`）

输出：

- 安装后的 `plist` 路径
- 定时计划摘要
- runtime 脚本路径（位于 `<root>/runtime/`，用于规避 macOS 对 `Documents` 的后台访问限制）

#### status

```bash
./scripts/sanitized-publish-artifacts-scheduler status
```

输出：

- label、plist 路径、domain
- 是否已加载
- `launchctl print` 的前几行状态

#### run-now

```bash
./scripts/sanitized-publish-artifacts-scheduler run-now
```

输出：

- 触发成功提示；若失败会返回错误信息

#### uninstall

```bash
./scripts/sanitized-publish-artifacts-scheduler uninstall
```

输出：

- 卸载与 plist 删除结果

#### print-plist

```bash
./scripts/sanitized-publish-artifacts-scheduler print-plist [options]
```

输出：

- 生成后的 plist 内容（不写盘，便于审计）

### IO / 日志路径

- LaunchAgent plist：
  - `~/Library/LaunchAgents/com.zhuanz.sanitized_publish_artifacts_cleanup.plist`
- Code alias（人类入口路径）：
  - `/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts -> ~/.local/share/sanitized_publish_artifacts`
- stdout log：
  - `<root>/logs/cleanup.stdout.log`
- stderr log：
  - `<root>/logs/cleanup.stderr.log`

### Troubleshooting

1) `launchd 安装失败`

- 先检查当前用户会话是否可用：

```bash
launchctl print gui/$(id -u)
```

- 再执行：

```bash
./scripts/sanitized-publish-artifacts-scheduler status
```

2) `run-now` 触发失败

- 确认已安装且 loaded：

```bash
./scripts/sanitized-publish-artifacts-scheduler install
./scripts/sanitized-publish-artifacts-scheduler status
```

如果看到 `Operation not permitted` 且路径在 `Documents` 下，请改用默认 root（`~/.local/share/...`）重新安装，避免 TCC 拦截后台访问。

3) 没有清理任何目录

- 这是正常情况（仍在保留窗口）。可先手动 dry-run 验证：

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3
```

---

## English

### Purpose

`scripts/sanitized-publish-artifacts-scheduler` registers an automated `launchd` cleanup job for publish artifacts.

By default, it schedules:

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3 --apply --root ~/.local/share/sanitized_publish_artifacts
```

During install, the script also maintains a Code-facing alias:

`/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts -> ~/.local/share/sanitized_publish_artifacts`

### Prerequisites

- macOS with `launchd`
- `bash` and `launchctl`
- Existing cleanup script: `scripts/sanitized-publish-artifacts`

Recommended working directory:

```bash
cd /Users/Zhuanz/Documents/Code/universal-harness-kit
```

### Quick Start

1) Install scheduler (default: Sunday 03:15)

```bash
./scripts/sanitized-publish-artifacts-scheduler install
```

2) Check status

```bash
./scripts/sanitized-publish-artifacts-scheduler status
```

3) Trigger once now

```bash
./scripts/sanitized-publish-artifacts-scheduler run-now
```

### Commands

#### install

```bash
./scripts/sanitized-publish-artifacts-scheduler install [options]
```

Options:

- `--days <N>`: age threshold for deletion (default `14`)
- `--keep <N>`: always keep newest N runs (default `3`)
- `--weekday <1-7>`: weekday (1=Sunday, default `1`)
- `--hour <0-23>`: hour (default `3`)
- `--minute <0-59>`: minute (default `15`)
- `--root <dir>`: artifact root (default `~/.local/share/sanitized_publish_artifacts`)

Output:

- installed plist path
- schedule summary
- runtime script path (`<root>/runtime/`, avoids macOS background access limits on `Documents`)

#### status

```bash
./scripts/sanitized-publish-artifacts-scheduler status
```

Output:

- label, plist path, domain
- loaded or not
- first lines from `launchctl print`

#### run-now

```bash
./scripts/sanitized-publish-artifacts-scheduler run-now
```

Output:

- success message (or failure details)

#### uninstall

```bash
./scripts/sanitized-publish-artifacts-scheduler uninstall
```

Output:

- unload/delete result

#### print-plist

```bash
./scripts/sanitized-publish-artifacts-scheduler print-plist [options]
```

Output:

- rendered plist content (stdout only)

### IO / Log Paths

- LaunchAgent plist:
  - `~/Library/LaunchAgents/com.zhuanz.sanitized_publish_artifacts_cleanup.plist`
- Code alias (human-facing path):
  - `/Users/Zhuanz/Documents/Code/_sanitized_publish_artifacts -> ~/.local/share/sanitized_publish_artifacts`
- stdout log:
  - `<root>/logs/cleanup.stdout.log`
- stderr log:
  - `<root>/logs/cleanup.stderr.log`

### Troubleshooting

1) `launchd install failed`

```bash
launchctl print gui/$(id -u)
./scripts/sanitized-publish-artifacts-scheduler status
```

2) `run-now` failed

```bash
./scripts/sanitized-publish-artifacts-scheduler install
./scripts/sanitized-publish-artifacts-scheduler status
```

If you see `Operation not permitted` on paths under `Documents`, reinstall with a non-Documents root (the default `~/.local/share/...` is recommended) to avoid TCC blocking background jobs.

3) Nothing gets deleted

- This can be expected if runs are still inside retention windows.

```bash
./scripts/sanitized-publish-artifacts cleanup --days 14 --keep 3
```
