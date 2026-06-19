# Feature Factory — Agent Teams 软件工厂

将 Claude Code 从"一个 AI 做所有事"转变为**7 个专职 Agent 协作的软件工厂**。

一个命令启动完整的功能交付流水线：研究 → 规划 → 构建 → 测试 → 验证。你只在你判断力真正重要的两个节点介入。

## 快速开始

> 🎬 **3 分钟演示**：[观看 Feature Factory 完整流水线](https://youtu.be/XXXXX)

### 1. 安装

**方式 A：一键安装脚本（推荐）**

```bash
# macOS / Linux
./install.sh /path/to/your-project

# Windows PowerShell
.\install.ps1 -TargetPath C:\path\to\your-project
```

脚本会自动完成：复制 `.claude/` 目录、处理 CLAUDE.md 冲突、显示安装摘要。

**方式 B：手动复制**

```bash
cp -r .claude /your-project/
```

### 2. 创建项目 CLAUDE.md

如果使用安装脚本，CLAUDE.md 已自动处理。手动安装的话：

```bash
cp .claude/CLAUDE.md.template /your-project/CLAUDE.md
```

保持 150 行以内，填入你项目的技术栈、命令和架构规则。

### 3. 启动工厂

```bash
/feature-factory 构建发票催收功能，对超过7天未支付的发票自动发送提醒
```

## 三种模式

| 命令 | 模式 | 流程 |
|------|------|------|
| `/feature-factory <描述>` | Full 完整 | Researcher → Planner → Builders → Verifier → Validator |
| `/feature-factory --debug <Bug>` | Debug 调试 | Debugger → Builder(s) → Verifier → Validator |
| `/feature-factory --incremental <变更>` | Incremental 增量 | Researcher (quick) → Builder(s) → Verifier → Validator |
| `/debug <Bug>` | 仅分析 | Debugger → 输出报告 → 询问是否修复 |

## 7 个 Agent

| # | Agent | 职责 | 权限 |
|---|-------|------|------|
| 1 | **Researcher** | 映射代码库、识别模式、标记风险 | 只读 |
| 2 | **Debugger** | 从现象反向追踪到根本原因 | 只读 |
| 3 | **Planner** | 用户故事 + 技术蓝图（集成 brainstorming） | 只读 |
| 4 | **Backend Builder** | API、服务、数据库迁移、后台任务 | 后端只写 |
| 5 | **Frontend Builder** | 组件、页面、状态、UI 测试 | 前端只写 |
| 6 | **Test Verifier** | 根据用户故事编写验收测试 | 仅测试文件 |
| 7 | **Validator** | 对比实现与蓝图，质量门禁 | 只读+Minor修复 |

## 人工审批点

只有两个：

1. **蓝图审批** — Planner 输出后，任何代码修改前
2. **PR 审批** — Validator 输出后

## 设计理念

- **专业化分工** — 每个 Agent 有干净的上下文和严格边界
- **并行执行** — Backend 和 Frontend Builder 同时启动
- **模式自适应** — 新功能走 Full，Bug 走 Debug，小改动走 Incremental
- **分级问题处理** — Minor 自动修复，Important 报告，Critical 阻塞

## 前置依赖

- [Claude Code](https://code.claude.com)
- 推荐安装 [Superpowers](https://github.com/anthropics/superpowers) 插件（Planner 的 brainstorming 功能依赖它）

## Token 消耗参考

以下估算基于**中型 TypeScript 项目**（~150 文件、~20 个 API 端点）。实际消耗取决于项目规模、功能复杂度和 Agent 是否需要重试。数量级参考，不是精确报价。

### 按模式

| 模式 | Agent 序列 | 预计输入 tokens | 预计输出 tokens | 参考耗时 |
|------|-----------|:---------------:|:---------------:|:--------:|
| **Full** | Researcher(Opus) → Planner(Opus) → 2×Builder(Sonnet) → Verifier(Haiku) → Validator(Haiku) | ~80K | ~40K | 5-8 min |
| **Debug** | Debugger(Opus) → Builder(Sonnet) → Verifier(Haiku) → Validator(Haiku) | ~50K | ~25K | 3-5 min |
| **Incremental** | Researcher(Opus, quick) → Builder(Sonnet) → Verifier(Haiku) → Validator(Haiku) | ~30K | ~15K | 2-4 min |

### 影响消耗的因素

| 因素 | 影响 |
|------|------|
| **项目规模** | 大型项目（500+ 文件）输入消耗可能翻倍——Researcher 需要扫描更多文件，Builder 需要理解更多上下文 |
| **功能复杂度** | 多模型关联、跨模块修改 → Planner 输出更长、Builder TDD 循环更多 |
| **Agent 重试** | Planner 蓝图被驳回或 Builder 测试失败时，重试消耗与首次相近 |
| **Superpowers 可用性** | Superpowers 可用时 Planner 的 brainstorming 更高效（更少探索轮次）；不可用时内联流程约增加 10-20% Planner 输出 |

### 省钱技巧

- **小改动用 Incremental，不要用 Full**——省掉 Planner 的深度分析和完整的并行 Builder
- **写清楚需求**——模糊的需求导致 Planner 反复澄清，每次澄清都消耗 tokens
- **CLAUDE.md 写完整**——Researcher 如果找不到项目结构，会花更多轮次在搜索上
- **信任 Validator 的 Minor 自动修复**——不要为了命名风格问题重新跑整个流水线

## 端到端示例

以下是 `/feature-factory 构建发票催收功能，对超过7天未支付的发票自动发送提醒` 的完整流水线输出摘要。

### Step 1: Researcher 报告（节选）

```
## Researcher Report: 发票催收功能

### Files Involved
- `src/services/invoice.service.ts` — 发票核心业务逻辑
- `src/jobs/send-reminder.ts` — 现有单次提醒 Job（参考模式）
- `src/models/Invoice.ts` — 发票模型，已有 dueDate、status 字段
- `src/lib/email.ts` — 邮件发送工具类

### Similar Features
- `src/jobs/send-reminder.ts` — 单次发票提醒。新功能类似但需要定时扫描。

### Risks
- ⚠️ 定时任务可能重复发送 — 需要幂等机制
- ⚠️ 时区处理 — dueDate 存储为 UTC，需确认比较逻辑
```

### Step 2: Planner 蓝图（节选）

```
## User Story
As a 财务人员, I want 系统自动对超过7天未支付的发票发送催收提醒,
so that 我不需要手动追踪逾期发票。

### Acceptance Criteria
1. 每天 8:00 自动扫描所有逾期超过 7 天的未支付发票
2. 每张逾期发票向客户发送一封催收邮件
3. 同一发票 7 天内不重复发送催收
4. 已支付或已取消的发票不发送催收
...
```

### Step 3: ⏸ 蓝图审批 → 用户批准

### Step 4: Builder 并行构建

**Backend Builder** 创建 migration、service、job 和 API，**Frontend Builder** 创建发票列表页的逾期标记组件。

### Step 5: Test Verifier 报告

| # | Criterion | Result |
|---|-----------|--------|
| 1 | 每天 8:00 扫描逾期发票 | ✅ |
| 2 | 发送催收邮件 | ✅ |
| 3 | 7 天内不重复发送 | ✅ |
| 4 | 不催收已支付/已取消 | ✅ |

### Step 6: Validator 报告

```
## Validation Report: 发票催收功能

### Overall Verdict: CLEAN
- 8/8 acceptance criteria covered
- All failure paths tested
- No security issues
- Migration reversible
```

### Step 7: ⏸ PR 审批 → 交付

完整流程耗时约 5-8 分钟（取决于 Agent 执行时间），你只在两个节点介入。

## 文件结构

```
feature-factory/
├── .claude/
│   ├── agents/
│   │   ├── researcher.md
│   │   ├── debugger.md
│   │   ├── planner.md
│   │   ├── backend-builder.md
│   │   ├── frontend-builder.md
│   │   ├── test-verifier.md
│   │   └── implementation-validator.md
│   ├── skills/
│   │   └── feature-factory/
│   │       └── SKILL.md
│   ├── commands/
│   │   ├── feature-factory.md
│   │   └── debug.md
│   ├── rules/
│   │   └── builder-rules.md
│   ├── FAQ.md
│   └── CLAUDE.md.template
├── README.md
├── CLAUDE.md           ← 本项目的 CLAUDE.md（安装时不覆盖目标项目的）
├── install.sh          ← Unix/macOS 安装脚本
├── install.ps1         ← Windows PowerShell 安装脚本
├── CHANGELOG.md
├── VERSION
├── LICENSE
└── .gitignore
```
