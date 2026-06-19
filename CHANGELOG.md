# Changelog

本文件记录 Feature Factory Agent Teams Skill 包的所有值得关注的变更。

格式遵循 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)，版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## 版本策略

- **MAJOR**（X.0.0）：增加新 Agent、删除 Agent、或不向后兼容的流水线架构变更
- **MINOR**（0.X.0）：增强 Skill 逻辑、新增编排规则、模板改进
- **PATCH**（0.0.X）：Prompt 措辞修正、Bug 修复、文档勘误

## Deprecation 策略

以下规则定义了 Feature Factory 各组件向后兼容的承诺。当某个组件需要以不兼容的方式变更时，
这些规则告诉维护者如何处理过渡期，告诉用户如何判断自己的 `.claude/` 副本是否需要更新。

### 受影响的组件及策略

| 组件 | 策略 | 说明 |
|------|------|------|
| **Agent 定义** (`.claude/agents/*.md`) | 旧格式保留 1 个 MAJOR 版本 | 新增 frontmatter 字段向后兼容（缺少新字段不影响已有行为）。重命名或删除字段时，旧名称在 `deprecated` 注释下保留 1 个 MAJOR 版本后移除。 |
| **编排 Skill** (`.claude/skills/feature-factory/`) | 旧结构和模板保留 1 个 MINOR 版本 | SKILL.md 和 prompt 模板文件的路径变更时，原位置保留一个 `[MOVED to <new-path>]` 桩文件，1 个 MINOR 版本后移除。 |
| **规则文件** (`.claude/rules/*.md`) | 立即生效 | 规则文件是纯文本，没有解析依赖。内容变更就是内容变更——CHANGELOG 里写清楚即可。 |
| **Smoke test** (`smoke.sh`) | 检查项只增不减 | 如果某项检查不再适用，标记为 `# LEGACY: <reason>` 并跳过一次检查，下一个 MAJOR 版本移除。绝不静默删除检查项。 |
| **命令定义** (`.claude/commands/*.md`) | 参数兼容 1 个 MINOR 版本 | 新增 flag 向后兼容。删除 flag 时保留接受（忽略）1 个 MINOR 版本，然后移除。 |
| **Domain modeling 制品** (`.claude/context/`) | 不适用 | CONTEXT.md 和 ADR 是项目数据，不是 Feature Factory 的 API。格式变更在 ADR-FORMAT.md 和 CONTEXT-FORMAT.md 中声明。 |

### 版本号触发规则

| 变更类型 | 版本号 bump | 示例 |
|----------|------------|------|
| 新增 Agent | MAJOR | v1.x → v2.0 |
| 删除 Agent | MAJOR | v1.x → v2.0 |
| 不兼容的流水线架构变更（如模式重排、Agent 职责重定义） | MAJOR | v1.x → v2.0 |
| 新增编排规则、prompt 模板改进、smoke test 扩展 | MINOR | v1.4 → v1.5 |
| Prompt 措辞修正、文档勘误、注释修正 | PATCH | v1.4.0 → v1.4.1 |

### 废弃时间线模板

当宣布某个组件废弃时，CHANGELOG 条目必须包含：

```
### Deprecated
- **[组件名]**: [废弃内容]。将在 [版本号] 中移除。迁移方式：[一句话说明如何迁移]。
```

### 用户如何检查兼容性

在目标项目中运行 Feature Factory 的 smoke test 可以检测大部分不兼容问题：

```bash
bash .claude/tests/smoke.sh
```

如果 smoke test 通过，你的 `.claude/` 副本与当前版本的 Feature Factory 兼容。
如果出现 FAIL，查看失败项对应的 Agent 或文件，对照上方表格确定是否需要更新。

---

## [1.5.0] — 2026-06-19

### Added
- **ModelScope / Skill 标准化**: 新增根目录 `SKILL.md` 作为 ModelScope 标准 Skill 入口（根目录仅此 1 个），YAML frontmatter 包含 license、tags、compatibility
- **npx skills add 安装**: 新增安装方式 B —— 通过 `npx skills add` 直接安装
- **references/ 目录**: 绑定资源重组到 `references/` 下（agents/、rules/、prompts/、commands/、domain-modeling/、docs/）
- **scripts/ 目录**: 安装脚本和 smoke test 移至 `scripts/`
- **assets/ 目录**: 预留给图标等静态资源

### Changed
- **编排 Skill 移至根目录**: `.claude/skills/feature-factory/SKILL.md` + `rules.md` → 根 `SKILL.md`（ModelScope 规范）
- **Agent/Command/Rule 镜像**: `.claude/` 目录保留 `references/` 的拷贝副本，确保本仓库自身可用 `/software-factory`
- **安装脚本路径**: `install.sh`/`install.ps1` 移至 `scripts/`，源路径从 script-dir 改为 project-root
- **Smoke test 双模式**: 支持从 `scripts/`（源仓库）和 `.claude/tests/`（已安装）两种路径运行
- **Skill 入口命令**: 文件路径从 `.claude/skills/feature-factory/SKILL.md` → 根 `SKILL.md`

### Removed
- **`.agents/skills/skill-creator/`**: 开发工具，非发布包的一部分
- **`.claude/skills/feature-factory/`**: 已合并到根 `SKILL.md`
- **根 `install.sh`/`install.ps1`**: 移至 `scripts/`

### Deprecated
- **`.claude/skills/feature-factory/SKILL.md`**: 旧编排 Skill 位置。将在 v2.0.0 中移除。迁移方式：使用根 `SKILL.md`。

### Added
- **domain-modeling skill** (`/domain-modeling`): extract and define canonical domain terms, maintain CONTEXT.md glossary, create ADRs for hard-to-reverse decisions. Loaded by Planner during Phase 0.
- **TDD workflow for Builders**: Backend Builder and Frontend Builder now use RED→GREEN→REFACTOR vertical slices (one behavior at a time). Step 2 becomes "Plan Test Seams", Step 3 becomes "TDD Loop". Horizontal slicing (all tests first) is explicitly banned.
- **Feedback loop discipline for Debugger**: Phase 1 now requires constructing a tight, red-capable pass/fail signal before code analysis. Nine methods to try, with soft-guidance exit clause if the environment prevents loop construction.
- **Domain Glossary chapter in Planner blueprint**: new chapter between User Story and Technical Brief — canonical terms table, new ADRs, CONTEXT.md update log.
- **Validator checklist expanded 8→10**: new check #8 Domain Glossary Consistency (naming matches glossary), new check #9 TDD Traceability (every criterion has a public-interface test).
- **TDD Cycle Log** in Builder output format: behavior tested, test file, seam, RED→GREEN result, refactor notes.
- **Glossary Terms Used** in Builder output format: terms from CONTEXT.md, plus NEW terms flagged for Planner review.
- **Smoke test expanded 43→50**: 7 new checks covering domain-modeling skill integrity, planner skill loading, validator checklist count, and SKILL.md references.

### Changed
- **Planner maxTurns**: 12 → 15 (accommodates domain-modeling phase)
- **Planner skills**: now loads both `brainstorming` and `domain-modeling`
- **Builder Step 2**: renamed from "Plan Your Implementation" to "Plan Test Seams" — output is a prioritized behavior list with test seams, not a file list
- **Builder Step 3**: replaced "Implement" with "TDD Loop — RED → GREEN → REFACTOR" with per-slice checklist
- **Builder input**: now reads `.claude/context/CONTEXT.md` for domain terminology when available
- **Debugger Phase 1**: renamed from "Reproduce the Failure in Your Mind" to "Build a Feedback Loop + Reproduce" — now requires a concrete command + output before code analysis
- **Orchestrator SKILL.md**: Planner and Builder Agent() call templates updated with domain-modeling and TDD instructions

## [1.3.1] — 2026-06-14

### Changed
- **Agent 模型分级**：深度推理型 Agent（researcher、planner、debugger）→ `opus`；Builder（backend、frontend）保持 `sonnet`；验证型 Agent（test-verifier、implementation-validator）→ `haiku`。按认知负载匹配模型能力，在质量和成本间平衡
- **SKILL.md 拆分**：将 Git Workflow Integration（~150 行）和 Failure Recovery & Feedback Loops（~80 行）提取为独立规则文件 `.claude/rules/git-workflow.md` 和 `.claude/rules/failure-recovery.md`。SKILL.md 保留简要概述和交叉引用链接，从 ~830 行缩减至 ~600 行
- **test-verifier maxTurns**：从 15 提升至 20，匹配其实际工作量（需读取两份 Builder 输出 + 编写验收测试 + 运行测试）

### Fixed
- **CLAUDE.md 路径**：FAQ.md 引用从根目录修正为 `.claude/FAQ.md`（与文件实际位置一致）
- **.gitignore 评估规则**：`*evaluation*` 全局通配变为更精确的 `evaluation/`、`evaluation.*`、`eval.*`，避免在目标项目中意外忽略含 "evaluation" 子串的文件

### Added
- CLAUDE.md 关键文件列表新增 `git-workflow.md` 和 `failure-recovery.md` 引用
- **Pipeline smoke test**（`.claude/tests/smoke.sh`）：43 项自动化检查，覆盖 Agent frontmatter 验证、工具权限审计、命令路由检查、SKILL.md subagent 引用完整性、跨文件链接校验、模型分级确认。运行：`bash .claude/tests/smoke.sh`
- **Frontend Builder 集成 frontend-design Skill**：Agent frontmatter 新增 `skills: [frontend-design]`，启动时自动加载排版、色彩、动效、空间构成和氛围设计原则

---

## [1.3.0] — 2026-06-13

### Added
- **FAQ.md**：8 个常见问题的排查指南，覆盖 Agent 行为、参数调整、执行流程和跨项目复制四类场景。附带快速诊断框架
- **Frontend Builder a11y 检查清单**：从 1 条通用规则扩展为 6 条可执行检查项（Keyboard、Focus、Semantics、Color、Announcements、Forms）

### Changed
- CLAUDE.md 关键文件列表新增 FAQ.md 引用

---

## [1.2.0] — 2026-06-13

### Changed
- **Git 工作流全面重写**：子 Agent 不再自行 commit，改为编排者统一提交；提交前完整的安全检查流程
- **Incremental 模式完全重写**：所有 5 个步骤不再使用跨模式引用（"Same as Full Mode Step N"），每一步均为自包含的完整描述，附带完整的 Agent prompt 模板

### Added
- **共享文件冲突预防**：并行 Builder 启动前的文件所有者分配、冲突检测（`git diff` 去重）、按风险等级分级的冲突解决策略
- **Pipeline 废弃时的工作保护**：`git stash` + backup tag 两步保护，三种清理选项（保留全部 / 保留分支 / 完全清理），绝不静默丢弃代码
- **Git 安全检查**：分支创建前必须 `git status --porcelain` 检查 dirty tree，`git branch --list` 检查重复
- **Incremental 模式升级边界**：5 个明确的触发信号（8+ 文件、范围蔓延、需求模糊、架构级 Critical、涉及 migration），出现任意一个即建议升级到 Full 模式

### Fixed
- Pipeline 废弃时直接建议 `git branch -D` 导致未提交变更丢失的安全隐患

---

## [1.1.0] — 2026-06-13

### Added
- **异步故障恢复机制**：Agent 超时、maxTurns 耗尽、输出不完整时的降级策略
- **并行 Builder 部分成败处理**：一个成功一个失败时的保留与恢复流程
- **5 个反馈闭环流程**：蓝图驳回、测试失败、Validator 阻断、不可测标准、研究阻塞
- **Git 工作流集成**：分支命名、提交策略、PR 准备指引
- **端到端示例**：README 中完整的"发票催收"流水线演示
- **CHANGELOG.md**：本文件，记录所有版本变更

### Changed
- **CLAUDE.md.template 改为技术栈无关**：从纯 TypeScript/Next.js 改为支持 Python、Go、Rust 的多语言模板
- **CLAUDE.md.template "禁止做的事"**：改为面向数据安全的通用规则，不再是特定于 BullMQ/Payments 的注意事项

### Fixed
- Incremental 模式架构图：与详细步骤不一致，已统一为 5 步流程
- VERSION 文件孤立：现在 CHANGELOG.md 提供完整上下文

---

## [1.0.0] — 2026-06-13

### Added
- 7 个 Agent：Researcher、Debugger、Planner、Backend Builder、Frontend Builder、Test Verifier、Implementation Validator
- Feature Factory 编排 Skill：Full、Debug、Incremental 三种模式
- `/feature-factory` → `/software-factory` 入口命令
- `/debug` 入口命令
- builder-rules.md：Builder 共享的 13 条质量准则
- CLAUDE.md.template：目标项目配置模板
- 人审关卡：蓝图审批、PR 审批
- 并行 Builder 执行：Backend 和 Frontend Builder 同时启动
- Planner 的 brainstorming 集成（依赖 Superpowers 插件）
