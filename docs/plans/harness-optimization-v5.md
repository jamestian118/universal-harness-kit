# Harness Kit 优化方案 V5（ExecPlan）

> 基于 OpenAI Harness Engineering 五大原则 + Boris Cherny Claude Code 工作流对标评估
> 生成时间：2026-02-27
> 状态：Draft → 待特西确认

## 元信息

| 字段 | 值 |
|------|-----|
| 目标仓库 | `/Users/Zhuanz/Documents/Code/universal-harness-kit` |
| 当前分支 | `ai/20260221-artifact-finalize` |
| 预估变更文件数 | ~25 |
| 预估子任务数 | 10 |
| 回滚锚点 | 执行前打 tag `pre-optimization-v5` |

## DoD（Definition of Done）

1. 全局 CLAUDE.md 从 ~200 行工作流瘦身到 ~30 行 map + 指针
2. `scripts/verify` 捕获 stdout/stderr 到 JSON，agent 可直接读取定位问题
3. Policy stack 入口有 hook 强制执行方案（文档 + 示例配置）
4. Lessons Learned 按主题分类 + 已毕业条目归档
5. 四套 profile 同步有机械化检查脚本
6. Agent 面向文件去除冗余双语
7. Closeout 精简为 4 步
8. gc/arch-check 输出包含修复指令
9. Living ExecPlan 机制落地（`.ai/current-plan.md` 模板）
10. 全量 `./scripts/verify` 通过

## Progress

- [x] Task 1: 全局 CLAUDE.md 瘦身（97行→25行）
- [x] Task 2: verify 升级为 observability（output 字段 + tmpdir 捕获）
- [x] Task 3: gc/arch-check 输出增加修复指令（四套 profile 已同步）
- [x] Task 4: Policy stack hook 方案（方案 A + sentinel 缓存）
- [x] Task 5: Lessons Learned 重构（7 分类 + 21 条毕业归档）
- [x] Task 6: Profile sync check 脚本（首次运行即抓到 3 处 drift）
- [x] Task 7: Agent 面向文件去冗余双语（已确认无需改动）
- [x] Task 8: Closeout 精简（7步→4步，8 个文件已同步）
- [x] Task 9: Living ExecPlan 模板（OpenAI 格式，四套 profile 已同步）
- [ ] Task 10: 全量验证 + 文档同步
- [ ] Task 7: Agent 面向文件去冗余双语
- [ ] Task 8: Closeout 精简
- [ ] Task 9: Living ExecPlan 模板
- [x] Task 10: 全量验证 + 文档同步（profile-sync-check OK + 临时项目 verify JSON 验证通过）

## Surprises & Discoveries

- verify 的 `|||` IFS 分隔符在 bash 中按字符拆分而非字符串，导致 output 混合。改用 tmpdir 文件读取方案彻底解决。
- `datetime.utcnow()` 在 Python 3.12+ 已 deprecated，改为 `datetime.now(datetime.timezone.utc)`。
- profile-sync-check 首次运行即发现 3 处历史遗留的 verify.yml drift，验证了机械化检查的价值。
- Lessons Learned 实际 53 条（非 67），毕业率 39.6%，oh-my-orch 占 15 条活跃条目。

## Decision Log

- Task 4 选方案 A（hook 每次触发）+ sentinel 缓存（1 小时有效期），兼顾零遗漏和性能。
- Lessons Learned 分类为 7 个主题维度，基于条目聚类分析而非预设。
- verify observability 改用 tmpdir 文件读取而非 IFS 分隔，避免 bash 字符串处理的不可靠性。

---

## Task 1: 全局 CLAUDE.md 瘦身（P0）

### 原理

OpenAI 原则 5："Give a map, not a 1,000-page manual"。当前全局 `~/.claude/CLAUDE.md` 包含完整六阶段工作流 V4.3（~200 行），每次对话都加载，90% 的任务用不到。context 是稀缺资源，长篇指令在 context 压缩后细节丢失，直接降低 agent 遵守度。

### 目标

- 全局 CLAUDE.md 只保留 map 级内容（称呼、语言、项目规范、policy stack 入口、关键指针）
- 六阶段工作流完整定义下沉到独立文件
- 需要时按需读取，读取时 context 新鲜，遵守度更高

### 变更清单

**文件 1：`~/.claude/CLAUDE.md`**

瘦身后结构（~30 行）：

```markdown
每次回复之前，必须使用"特西"进行称呼。始终使用中文回复，技术术语保留 English。

## 工作流
- 简单单文件修改：直接执行
- 复杂任务（≥3 文件或 ≥2 子任务）：ultrathink，读取并遵循 `/Users/Zhuanz/docs/plans/codex-workflow-default.md`
- 模板目录：`/Users/Zhuanz/docs/plans/templates/`

## Policy Stack（每次任务开始前必须执行）
`/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool claude --cwd "$PWD" --strict --strict-profile harness`
- 执行顺序：Global → Workflow → Copy-to-project
- 入口校验 fail 时不得跳过，先修复再继续
- `copy_project_root_relaxed: warn` 场景可继续 Global/Workflow 维护，进入项目后必须重跑

## 项目规范
- 新建项目：`/Users/Zhuanz/Documents/Code/universal-harness-kit/new_project.sh <name> --lang <python|node|go|generic>`
- 设计偏好：Apple Design Language
- 进入已有项目后先读取 `AGENTS.md` 并严格遵守
- Lessons Learned 同步追加到 `/Users/Zhuanz/Documents/Code/universal-harness-kit/.ai/lessons-learned.md`
- 提交 GitHub 默认闭环：脱敏 → public/private 分级 → 发布
- README 统一大写 `README.md`
- 临时脚本放 `scripts/.tmp/` 或 `.ai/tmp-scripts/`，closeout 前清理

## 联网搜索（强制启用）
遇到时效性信息、用户要求搜索、答案不确定时，必须使用 WebSearch / WebFetch。
每次回复末尾附：搜索来源（URL）或未搜索原因或 Memory used（引用来源）。
```

**关键删除项**：整个"标准工作流 V4.3（六阶段）"段落（Phase 1-6 全部），包括 CSV 14 字段定义、retry_class 分类、DAG 调度算法、Event Log 结构等。这些内容已存在于 `codex-workflow-default.md`，无需重复。

### 验收

```bash
# CLAUDE.md 行数应 ≤ 40
wc -l ~/.claude/CLAUDE.md
# 确认工作流文件仍存在且完整
grep -c "Phase" /Users/Zhuanz/docs/plans/codex-workflow-default.md
```

---

## Task 2: verify 升级为 observability（P1）

### 原理

OpenAI 原则 4："Give agents eyes and observability"。Boris Cherny："验证反馈循环让输出质量提升 2-3 倍"。当前 verify 只输出 pass/fail，agent 失败后需要重跑命令才能定位问题。捕获 stdout/stderr 到 JSON 后，agent 可直接读取 `.ai/verify-log.json` 定位问题。

### 变更清单

**文件：四套 profile 的 `scripts/verify`**（generic/python/node/go）

修改 `run_step()` 函数，捕获每步的 stdout+stderr：

```bash
run_step() {
  local name="$1" cmd="$2"
  echo "[verify] $name..."
  local s_start s_end status output_file
  s_start=$(now_ms)
  output_file="$tmpdir/${name}.out"
  if eval "$cmd" > "$output_file" 2>&1; then
    status="pass"
    # 仍然输出到终端供人类查看
    cat "$output_file"
  else
    status="fail"
    overall="fail"
    cat "$output_file"
  fi
  s_end=$(now_ms)
  span_steps+=("$name")
  span_statuses+=("$status")
  span_durations+=("$(( s_end - s_start ))")
  span_outputs+=("$(cat "$output_file")")
}
```

修改 `write_log()` 函数，将 output 写入 JSON 的每个 span：

```python
# 在 spans.append 中增加 'output' 字段
outputs = '''$(IFS='|||'; echo "${span_outputs[*]:-}")'''.split('|||')
for s, st, d, o in zip(steps, statuses, durations, outputs):
    spans.append({
        'step': s, 'status': st,
        'duration_ms': int(d),
        'output': o.strip()[-2000:]  # 截断到最后 2000 字符，防止 JSON 过大
    })
```

在 `run_step` 前创建 tmpdir：

```bash
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/verify.XXXXXX")
trap 'write_log; rm -rf "$tmpdir"' EXIT
declare -a span_outputs=()
```

### 验收

```bash
cd <any-harness-project>
./scripts/verify
# 检查 JSON 中包含 output 字段
python3 -c "import json; d=json.load(open('.ai/verify-log.json')); assert 'output' in d['spans'][0], 'missing output field'"
```

---

## Task 3: gc/arch-check 输出增加修复指令（P1）

### 原理

OpenAI 原则 3："linter 错误信息同时充当修复指令——agent 在工作中被工具教导"。当前 gc 输出 `[DRIFT] 脚本 'xxx' 未在 docs/scripts.md 中记录`，但不告诉 agent 怎么修。agent 需要额外推理才能修复。

### 变更清单

**文件：四套 profile 的 `scripts/gc`**

检查 1 的输出从：
```
[DRIFT] 脚本 'xxx' 未在 docs/scripts.md 中记录
```
改为：
```
[DRIFT] 脚本 'xxx' 未在 docs/scripts.md 中记录
  修复: 在 docs/scripts.md 中添加 '### xxx' 段落（含中英双语说明）
```

检查 2 的输出增加：
```
  修复: 将 TODO 改为 TODO(#<issue>) 或 TODO(YYYY-MM-DD) 格式
```

检查 3 的输出增加：
```
  修复: 将日期内容移到 .ai/handoff.md，docs/ 只保留静态规范
```

检查 4 的输出增加：
```
  修复: 合并重复函数或重命名为不同名称
```

**文件：四套 profile 的 `scripts/arch-check`**

违规输出从：
```
[arch-check] FAIL: src/ 中发现违规依赖 tests/：
```
改为：
```
[arch-check] FAIL: src/ 中发现违规依赖 tests/
  修复: 移除 src/ 中对 tests/ 的 import，改用 dependency injection 或将共享代码提取到 src/
```

层级违规输出增加：
```
[${layer} -> ${target}] 违规:
  修复: ${layer}/ 不可依赖 ${target}/（同层或高层），将共享逻辑下沉到更低层级
```

### 验收

```bash
# gc 输出应包含"修复"关键词
./scripts/gc 2>&1 | grep -c "修复" || echo "无 drift（正常）"
# arch-check 输出应包含"修复"关键词（需要先制造违规）
```

---

## Task 4: Policy Stack Hook 方案（P0）

### 原理

Boris Cherny："同一个错误不应该被指出两次"。当前 policy stack 是软约束——写在 CLAUDE.md 里"每次任务开始前必须执行"，但 agent 可能跳过。Claude Code 支持 `PreToolUse` hook，可以在第一次文件写入前自动触发检查。

### 方案

提供两种落地路径，由特西选择：

**方案 A：Claude Code settings.json hook（推荐）**

在 `~/.claude/settings.json` 中配置：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack --tool claude --cwd \"$PWD\" --strict --strict-profile harness --json 2>/dev/null || true"
      }
    ]
  }
}
```

优点：每次写文件前自动检查，零遗漏
缺点：每次 Edit/Write 都触发，可能影响速度

**方案 B：轻量 sentinel 文件方案（平衡）**

创建 `scripts/policy-gate`（~30 行）：
- 检查 `.ai/.policy-checked` 文件是否存在且时间戳在 1 小时内
- 不存在或过期 → 跑 `agent-policy-stack --strict`，通过后写 sentinel
- 存在且未过期 → 直接 pass（0ms 开销）

hook 配置改为调用 `policy-gate`，避免每次都跑完整 700 行检查。

```bash
#!/usr/bin/env bash
set -euo pipefail
# scripts/policy-gate — 轻量 policy stack 缓存闸门
SENTINEL=".ai/.policy-checked"
MAX_AGE=3600  # 1 小时

if [ -f "$SENTINEL" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$SENTINEL" 2>/dev/null || stat -c %Y "$SENTINEL" 2>/dev/null || echo 0) ))
  if [ "$age" -lt "$MAX_AGE" ]; then
    exit 0
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KIT_ROOT="$(dirname "$SCRIPT_DIR")"
POLICY_STACK="${KIT_ROOT}/scripts/agent-policy-stack"

if [ ! -x "$POLICY_STACK" ]; then
  # 不在 harness 项目内，尝试全局路径
  POLICY_STACK="/Users/Zhuanz/Documents/Code/universal-harness-kit/scripts/agent-policy-stack"
fi

if "$POLICY_STACK" --tool claude --cwd "$PWD" --strict --strict-profile harness; then
  mkdir -p .ai
  touch "$SENTINEL"
else
  echo "[policy-gate] FAIL: policy stack 检查未通过，请先修复"
  exit 1
fi
```

### 变更清单

- 新建 `scripts/policy-gate`（方案 B 选择时）
- 提供 `~/.claude/settings.json` hook 配置示例文档
- 四套 profile 的 `.gitignore` 增加 `.ai/.policy-checked`

### 验收

```bash
# 方案 B 验收
./scripts/policy-gate && echo "PASS" || echo "FAIL"
ls -la .ai/.policy-checked
# 第二次应该秒过
time ./scripts/policy-gate
```

---

## Task 5: Lessons Learned 重构（P1）

### 原理

67 条纯文本列表，agent 无法高效检索。已升级为 golden principle 或机械化检查的条目仍留在列表中，造成噪音。OpenAI 的 "doc-gardening" 理念：知识库需要定期修剪。

### 变更清单

**文件：`.ai/lessons-learned.md`**

1. 按主题分类，增加二级标题：
   - `## 发布与脱敏（Publish & Sanitize）`
   - `## 验证与测试（Verify & Test）`
   - `## 并发与调度（Concurrency & Scheduling）`
   - `## 文档与契约（Docs & Contracts）`
   - `## 环境与配置（Environment & Config）`
   - `## Artifact 生命周期`
   - `## 领域特定（Domain-Specific）`

2. 已升级的条目移到归档段落：
   - 在文件末尾增加 `## 已毕业（Graduated）` 段落
   - 将明确标注"已升级为 golden principle"或"已机械化"的条目移入
   - 每条保留一行摘要 + 指向升级后位置的指针

3. 活跃条目保留在对应主题分类下

### 验收

```bash
# 确认分类标题存在
grep -c "^## " .ai/lessons-learned.md
# 确认已毕业段落存在
grep -q "已毕业" .ai/lessons-learned.md && echo "PASS"
```

---

## Task 6: Profile Sync Check 脚本（P2）

### 原理

Lessons Learned 第 42 条已记录：`generic 的 verify/gc 修复未同步到 python/node/go 造成策略漂移`。四套 profile 中有大量应该一致的文件（verify、gc、AGENTS.md、closeout.md 等），当前靠人工同步，容易遗漏。OpenAI 原则 3：一致性来自机械化约束。

### 变更清单

**新建文件：`scripts/profile-sync-check`**（~80 行 bash）

核心逻辑：
- 定义"必须一致"的文件列表（相对于 `profiles/*/template/`）
- 以 generic 为基准，逐个 diff 其他三套 profile
- 输出差异报告，`--strict` 模式下有差异则 exit 1

```bash
#!/usr/bin/env bash
set -euo pipefail

# scripts/profile-sync-check
# 检查四套 profile 中应该一致的文件是否同步

STRICT=0
for arg in "$@"; do [ "$arg" = "--strict" ] && STRICT=1; done

cd "$(dirname "$0")/.." || exit 1

BASELINE="profiles/generic/template"
PROFILES=("python" "node" "go")

# 必须一致的文件（相对于 template/）
SYNC_FILES=(
  "AGENTS.md"
  "scripts/verify"
  "scripts/gc"
  "scripts/arch-check"
  "scripts/secrets-check"
  "scripts/docs-check"
  "scripts/finalize-artifacts"
  "scripts/milestone-finalize"
  ".claude/commands/closeout.md"
  ".codex/commands/closeout.md"
  ".gemini/GEMINI.md"
  ".claude/CLAUDE.md"
  ".github/workflows/verify.yml"
  ".github/workflows/secrets.yml"
  ".github/workflows/docs.yml"
)

drift=0
echo "=== [profile-sync-check] ==="
echo "基准: $BASELINE"
echo ""

for profile in "${PROFILES[@]}"; do
  target="profiles/${profile}/template"
  [ -d "$target" ] || continue
  for file in "${SYNC_FILES[@]}"; do
    base_file="${BASELINE}/${file}"
    target_file="${target}/${file}"
    if [ ! -f "$base_file" ]; then
      continue  # 基准不存在则跳过
    fi
    if [ ! -f "$target_file" ]; then
      echo "[DRIFT] ${profile}: 缺少 ${file}"
      echo "  修复: cp '${base_file}' '${target_file}'"
      drift=1
    elif ! diff -q "$base_file" "$target_file" >/dev/null 2>&1; then
      echo "[DRIFT] ${profile}: ${file} 与 generic 不一致"
      echo "  修复: cp '${base_file}' '${target_file}'"
      drift=1
    fi
  done
done

echo ""
if [ "$drift" -eq 0 ]; then
  echo "[profile-sync-check] OK"
else
  echo "[profile-sync-check] 发现 drift"
fi

[ "$STRICT" -eq 1 ] && [ "$drift" -gt 0 ] && exit 1
exit 0
```

**同步更新**：
- `docs/scripts.md`（四套 profile）增加 `### profile-sync-check` 段落
- kit 级 README 的"新增能力"增加一行说明

### 验收

```bash
./scripts/profile-sync-check --strict && echo "PASS" || echo "DRIFT detected"
```

---

## Task 7: Agent 面向文件去冗余双语（P2）

### 原理

Agent 不需要双语——它们都能理解中文。面向 agent 的文件（AGENTS.md、.claude/CLAUDE.md、.gemini/GEMINI.md）双语意味着 context 消耗翻倍，且维护时中英容易不同步。面向人类的 docs/ 保留双语。

### 变更清单

**四套 profile 的 `AGENTS.md`**：删除 English 段落（当前只有中文，已经是最简，无需改动）

**四套 profile 的 `.claude/CLAUDE.md`**：当前只有 2 行中文，无需改动

**四套 profile 的 `.gemini/GEMINI.md`**：检查是否有冗余双语，有则精简为中文

**不改动的文件**：`docs/` 下所有文件保留双语（面向人类）

### 验收

```bash
# AGENTS.md 不应包含 English 段落标题
for p in profiles/*/template/AGENTS.md; do
  grep -q "^## English" "$p" && echo "FAIL: $p has English section" || echo "OK: $p"
done
```

---

## Task 8: Closeout 精简（P2）

### 原理

当前 `/closeout` 有 7 步，其中 `milestone-finalize` 已封装了 verify + dry-run + confirm + apply。closeout 又把这些步骤拆开重复列出，造成认知冗余。Boris Cherny 的理念：slash command 应该是高效的工作流编码，不是冗长的 checklist。

### 变更清单

**四套 profile 的 `.claude/commands/closeout.md` 和 `.codex/commands/closeout.md`**

精简为 4 步：

```markdown
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
```

### 验收

```bash
# closeout 文件行数应 ≤ 30
wc -l profiles/generic/template/.claude/commands/closeout.md
```

---

## Task 9: Living ExecPlan 模板（P1）

### 原理

OpenAI 的 ExecPlan 是 living document，包含 Progress、Surprises & Discoveries、Decision Log。让 agent 能基于单个计划进行 6+ 小时自主工作。当前 `.ai/handoff.md` 面向交接，不面向执行中的自我追踪。context 被压缩后，agent 可通过读取 living plan 恢复完整上下文。

### 变更清单

**新建文件：四套 profile 的 `docs/exec-plans/_template.md`**（已存在，需更新）

更新模板为 OpenAI ExecPlan 格式：

```markdown
# [任务标题]

> 创建时间：YYYY-MM-DD
> 状态：Planning | Executing | Blocked | Done

## 目标与约束
- 目标：
- 边界：
- DoD：

## 实施步骤
- [ ] Step 1: ...
- [ ] Step 2: ...

## Progress（执行中持续更新）
<!-- agent 每完成一步在此追加 -->

## Surprises & Discoveries
<!-- 执行中遇到的意外发现 -->

## Decision Log
<!-- 关键决策及其理由 -->

## Outcomes & Retrospectives
<!-- 完成后填写 -->
```

**更新：四套 profile 的 `AGENTS.md`**

在"最小执行与交接闭环"段落增加一行：
```
- 复杂任务执行中持续更新：`.ai/current-plan.md`（基于 docs/exec-plans/_template.md）
```

**更新：四套 profile 的 `.gitignore`**

确认 `.ai/current-plan.md` 不在 ignore 列表中（它应该被 commit）。

### 验收

```bash
# 模板存在且包含关键段落
grep -q "Surprises" profiles/generic/template/docs/exec-plans/_template.md && echo "PASS"
grep -q "current-plan" profiles/generic/template/AGENTS.md && echo "PASS"
```

---

## Task 10: 全量验证 + 文档同步（P1）

### 原理

Boris Cherny："验证是输出质量的最关键因素"。所有改动完成后，必须跑全量验证确认无回归，并同步所有受影响的文档。

### 变更清单

1. Kit 级 README.md 的"新增能力"段落增加：
   - `scripts/profile-sync-check`
   - `scripts/policy-gate`（若选方案 B）
   - verify observability 升级说明

2. 四套 profile 的 `docs/scripts.md` 同步新增脚本的文档段落

3. Kit 级 `docs/` 下新增 `profile-sync-check.usage.zh-en.md`（如有必要）

4. 全量验证链：

```bash
# 1. kit 级 profile 同步检查
./scripts/profile-sync-check --strict

# 2. 用 generic 模板创建临时项目验证
./new_project.sh _verify-test --lang generic
cd /Users/Zhuanz/Documents/Code/_verify-test
./scripts/verify
cd -

# 3. 清理临时项目
rm -rf /Users/Zhuanz/Documents/Code/_verify-test
```

### 验收

```bash
# profile-sync-check 通过
./scripts/profile-sync-check --strict && echo "PASS"
# 临时项目 verify 通过
# （上述命令链全部 exit 0）
```

---

## 执行依赖图（DAG）

```
Wave 0（无依赖，可并行）:
  Task 1: 全局 CLAUDE.md 瘦身
  Task 5: Lessons Learned 重构
  Task 9: Living ExecPlan 模板

Wave 1（依赖 Wave 0 中的模板稳定）:
  Task 3: gc/arch-check 修复指令  （无硬依赖，但改动同文件）
  Task 7: Agent 面向文件去冗余双语
  Task 8: Closeout 精简

Wave 2（依赖 Wave 1 的脚本改动）:
  Task 2: verify 升级 observability  （改 verify 脚本）
  Task 4: Policy stack hook 方案     （依赖 Task 1 确认最终 CLAUDE.md）

Wave 3（依赖所有脚本改动完成）:
  Task 6: Profile sync check 脚本   （需要所有 profile 文件稳定后再校验）

Wave 4（收口）:
  Task 10: 全量验证 + 文档同步      （依赖 Task 1-9 全部完成）
```
