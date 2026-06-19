# Feature Factory 演示录屏脚本

3 分钟终端录屏，展示 Feature Factory 完整的 Full Mode 流水线。

## 录制参数

- **时长**：3 分钟
- **分辨率**：1920×1080（终端窗口原生分辨率）
- **工具**：OBS Studio（免费，跨平台）
- **风格**：真实速度，不做过度后期制作
- **终端**：Windows Terminal 或 Warp（支持颜色和 emoji 显示）

## 时间线

| 时间 | 画面 | 旁白 |
|------|------|------|
| 0:00-0:15 | 终端全屏，显示 `claude` 已启动 | Feature Factory 把 Claude Code 变成 7 个专职 Agent 协作的软件工厂。一个命令，完成从需求到验证的完整流程。 |
| 0:15-0:45 | 用户输入 `/software-factory 在设置页加一个导出数据为 CSV 的功能` | 以一个新功能为例——设置页导出 CSV。输入命令后，Researcher 先扫描代码库，找到相关文件、现有模式和风险点。 |
| 0:45-1:15 | Planner 产出输出——屏幕滚过 Domain Glossary + User Story + Technical Brief | Planner 接收 Researcher 的报告，定义领域术语，写用户故事，设计技术蓝图。输出包含精确的验收标准和实现路径。 |
| 1:15-1:30 | 用户看蓝图，输入 "Approved" | 你检查蓝图——只有这一个审批点。确认后，Builder 开始工作。 |
| 1:30-2:00 | 终端分屏或滚动——Backend 和 Frontend Builder 同时输出，可见 TDD Cycle Log | 两个 Builder 并行构建，每个行为都走 RED→GREEN→REFACTOR 的 TDD 循环。 |
| 2:00-2:20 | Test Verifier 输出 PASS/FAIL 表格 | Verifier 对照验收标准逐条测试，告诉你哪些过、哪些没过。 |
| 2:20-2:40 | Validator 输出 CLEAN | Validator 跑 10 项 checklist——安全、迁移、命名一致性、TDD 可追溯性……全部通过。 |
| 2:40-3:00 | 终端显示 "Ready for PR. Branch: feature/export-csv" | 3 分钟后，功能就绪。你获得了：完整实现、测试覆盖、验收验证和质量门禁检查。 |

## 录制清单

- [ ] 准备一个示例项目（中型 TypeScript 项目，有设置页）
- [ ] 打开终端，确认 claude 命令可用
- [ ] 启动 OBS，截取终端窗口
- [ ] 输入 `/software-factory 在设置页加一个导出数据为 CSV 的功能`
- [ ] 等待流水线完成（5-8 分钟实际耗时）→ 加速播放到 3 分钟
- [ ] 关键画面：Researcher 扫描结果、Planner 蓝图、并行 Builder、Verifier 表格、Validator CLEAN
- [ ] 上传到 YouTube（不公开列出）
- [ ] 把 YouTube 分享链接填入 README.md
