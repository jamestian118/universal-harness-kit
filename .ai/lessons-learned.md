# Global Lessons Learned（跨项目教训汇总）

所有项目的 Lessons Learned 都追加到此文件。
agent 在每次 handoff 时，除了写项目内的 .ai/handoff.md，还必须把 Lessons Learned 同步追加到此文件。

格式：`- YYYY-MM-DD [项目名]: [现象] → [根因] → [是否需要升级规则]`

当同一类问题出现 ≥2 次时，应升级为 golden principle 或机械化检查（参见 docs/quality.md 的规则升级机制）。

---

## 记录

- 2026-02-21 [harness-test]: secrets-check 误报自身脚本中的 pattern 字符串 → macOS grep --exclude 只匹配文件名不匹配路径 → 已修复为 --exclude=secrets-check
- 2026-02-21 [harness-test]: gc 裸 TODO 检查误报模板占位内容和规则描述文本 → gc 脚本需要排除自身和 docs 中的规则描述 → 待后续迭代修复
- 2026-02-21 [universal-harness-kit]: arch-check 未识别 CommonJS require('./tests/...') 导致违规依赖漏检，且默认模板 bare TODO 造成 gc 持续噪声 → regex 仅覆盖 import/from、模板占位未遵循 TODO 规则 → 已修复为 require() 检测 + TODO(#INIT) 规范化，并将脚本文档匹配改为 fixed-string 精确行匹配
- 2026-02-21 [patrol-final-acceptance-kit]: VM“GUI登录页”实际是 getty 控制台登录而非 gdm/lightdm，手工输入阻塞录屏流程 → 系统未安装桌面 display manager，仅启用 getty@tty1/serial-getty@hvc0 → 已落地 systemd override（agetty --autologin lima），建议升级为开机自检：优先判定登录类型（display-manager vs getty）再执行自动登录方案
- 2026-02-21 [patrol-final-acceptance-kit]: Lima Ubuntu server 镜像默认无桌面，VZ 窗口看到的只是 getty 控制台，无法直接做 Gazebo/RViz GUI 演示 → 误把“登录界面”当成桌面登录导致流程卡死 → 已修复为 `lightdm + xfce4 + xorg + autologin` 并验证 `tty7` 图形会话；同类问题已出现 2 次，建议升级为 golden principle：先判定 VM 是 headless 还是 desktop，再决定登录/录屏方案
- 2026-02-21 [patrol-final-acceptance-kit]: 证据文件仅用时间戳编号（如 item1_dynamic_202602...）不利于直接入报告 → 缺少“场景/能力/证据类型”语义字段 → 已统一追加报告友好命名模板：`item<NN>_<scene-or-capability>_<evidence-type>_<key-params>_<YYYY-MM-DD>.<ext>`，并保留原始文件做可追溯映射
- 2026-02-21 [patrol-final-acceptance-kit]: GUI录屏中“cmd_vel/odom 在变但画面机器人不动”被误判为模型太小 → 通过对比 `/world/factory/pose/info` 与 `/odom` 发现是“物理位姿不变、里程计漂移”，并非视觉缩放问题 → 建议升级为机械化检查：录屏前先跑 1 轮 `world_pose_delta vs odom_delta` 一致性探针，再决定用 cmd_vel 还是 set_pose 做演示素材
- 2026-02-21 [patrol-final-acceptance-kit]: 在 `limactl shell ... bash` here-doc 内执行 `ffmpeg x11grab` 后，下一行命令偶发丢首字符（如 `sleep`→`leep`）导致自动化误动作 → 伪终端/命令流边界问题而非业务脚本逻辑 → 建议升级为 golden principle：凡 ffmpeg/x11grab 串行脚本，后续命令统一加前置空格或拆分为独立 shell 调用
- 2026-02-21 [patrol-final-acceptance-kit]: GUI录屏用 `timeout ffmpeg` 直接截断会导致 mp4 `moov atom not found`（不可播放）→ 默认 TERM 信号中断未完成封装 → 建议升级为机械化检查：录屏统一用 `ffmpeg -t <seconds>` 自然收尾，或结束后强制执行 `ffprobe` 可播放校验
- 2026-02-21 [universal-harness-kit]: agent 在截图/视频迭代中产生冗余 artifacts 且缺少统一清理触发点 → 临时产物生命周期未建模（目录、验收闸门、人工确认）→ 已升级为 golden principle 并机械化落地 `scripts/finalize-artifacts` + `scripts/milestone-finalize`（verify + confirm 后清理）
- 2026-02-21 [universal-harness-kit]: artifacts 清理流程虽已脚本化，但里程碑收尾仍依赖人工记忆导致执行不一致 → 缺少 closeout 固定清单入口 → 已接入 `.codex/.claude` 的 `/closeout` 清单并在 KIT_README 增加回归命令；同类问题第 2 次，已完成从规则到机械化流程的升级
- 2026-02-21 [patrol-final-acceptance-kit]: `demo_final_60s.mp4` 为 headless 文字拼片却被错误当作 Item9 最终展示成片 → 验收口径里“脚本可生成视频”与“GUI 实录可展示”未分离，缺少实录真伪闸门 → 建议升级为机械化检查：凡标记“最终展示”的视频必须同时满足 `x11grab 来源证明 + 对照抽帧含 GUI 窗口`，否则自动降级为内部证据片
- 2026-02-22 [bulk-github-publish]: 批量推送时包含 `.github/workflows/*` 的仓库被 GitHub 拒绝（OAuth token 无 `workflow` scope）→ 凭据 scope 与内容类型不匹配 → 建议升级为机械化检查：发布前先探测 token scopes，缺 `workflow` 时自动提示“删除 workflow 文件或切换 PAT scope”
- 2026-02-22 [bulk-github-publish]: 路径脱敏规则对 `$HOME` 未生效（仅替换了 `/Users/...`）→ 使用了不适配斜杠前缀的 `\b` 边界正则 → 建议升级为 golden principle：路径脱敏统一用“平台路径样例回放测试”（/Users、/home、C:\\Users）后再跑全量发布
- 2026-02-22 [multi-repo-readme-standardization]: 多项目发布前容易出现“主文档命名不一致”（如 `KIT_README.md`）导致 GitHub 展示不稳定 → 缺少创建入口的 README 命名硬约束与跨 CLI 默认发布语义一致性 → 建议机械化：在项目生成脚本中强制校验根 `README.md`，并在 Codex/Claude 全局指令同步“提交 GitHub=脱敏+分级+发布”
- 2026-02-22 [github-publish-contract]: 仅靠“记忆偏好”不足以保证长期一致执行，跨 CLI 会出现执行口径漂移 → 缺少可机读、可验收的发布契约定义（输入触发词、分级标准、必交付物）→ 已升级为标准化约束：全局 AGENTS + Claude 规则同步 `sanitize -> classify -> publish` 与结果校验闭环
