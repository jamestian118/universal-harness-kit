# Phase3 Gate Commands (UHK Lane)

- 生成时间: 2026-02-27 20:37:10 +0800
- 生成路径: `/Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/tmp-phase3-gate-commands.md`
- 作用域: `/Users/Zhuanz/Documents/Code/universal-harness-kit`

## 0) 当前可执行路径探测

- `command -v omo` -> `/opt/anaconda3/bin/omo`
- `command -v csm` -> `NOT_FOUND`
- 说明：Gate 3 仍使用统一模板命令（`omo` / `csm`）。若 `csm` 未在 `PATH`，执行结果应判定为 fail（非误报）。

## 1) Gate 3 命令模板

1. OMO
   ```bash
   OMO_LOG_LEVEL=DEBUG omo --help 2>&1 | tee .ai/tmp-phase3-omo.out
   ```
2. CSM
   ```bash
   CSM_LOG_LEVEL=DEBUG csm list 2>&1 | tee .ai/tmp-phase3-csm.out
   ```

## 2) 判定规则（必须出现 debug 字段/行）

- R1（必选）：命令 exit code 必须为 `0`。
- R2（必选）：输出（`stdout + stderr`）中必须至少出现 1 条 debug 相关字段/行。
- 推荐匹配规则（case-insensitive）：
  - `debug`
  - `log_level=debug`
  - `level=debug`
  - `"level":"debug"`
  - `[debug]`
- Gate 3 通过条件：`R1 && R2`。任一规则不满足即判定为 fail。

## 3) 结果核验命令（模板）

```bash
rg -n -i 'debug|log_level=debug|level=debug|"level":"debug"|\\[debug\\]' .ai/tmp-phase3-omo.out
rg -n -i 'debug|log_level=debug|level=debug|"level":"debug"|\\[debug\\]' .ai/tmp-phase3-csm.out
```

## 4) 当前基线（2026-02-27）

- OMO 基线：`OMO_LOG_LEVEL=DEBUG omo --help` exit `0`，但输出未命中 debug 字段/行，判定 fail（R2 不满足）。
- CSM 基线：`CSM_LOG_LEVEL=DEBUG csm list` 返回 `command not found`（exit `127`），判定 fail（R1/R2 均不满足）。
