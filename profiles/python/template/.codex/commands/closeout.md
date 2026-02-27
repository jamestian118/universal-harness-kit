# /closeout

目标：milestone / stop / CLI 切换前的统一收尾。

## Checklist
1. 运行 milestone-finalize（含 verify + artifact 清理闸门）：
   ```bash
   ./scripts/milestone-finalize
   ```

2. 运行 gc（抗熵检查）：
   ```bash
   ./scripts/gc
   ```

3. 更新 `.ai/handoff.md`（必须包含）：
   - Goal/DoD
   - branch/commit + git status 摘要
   - 验证命令与关键输出
   - Done + Next Steps（3-8 条）

4. Lessons Learned 同步：
   - 追加到 `/Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/lessons-learned.md`
   - 同类问题 ≥2 次，提议升级为 golden principle 或机械化检查

## Pass/Fail
- Pass：milestone-finalize 通过 + handoff 证据链完整
- Fail：milestone-finalize 失败 或 handoff 缺失
