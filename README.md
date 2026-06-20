# Feature Factory — 软件工厂 Skill 包

将 Claude Code 从"一个 AI 做所有事"转变为 **7 个专职 Agent 协作的软件工厂**。一个命令启动完整的功能交付流水线：研究 → 规划 → 构建 → 测试 → 验证。你只在判断力真正重要的两个节点介入。

| 平台 | 状态 |
|------|------|
| Claude Code | ✅ 原生支持 |
| ModelScope / npx skills | ✅ Skill 入口 |

---

## 快速开始

### 1. 安装

**方式 A：一键安装脚本（推荐）**

```bash
# macOS / Linux
bash scripts/install.sh /path/to/your-project

# Windows PowerShell
.\scripts\install.ps1 -TargetPath C:\path\to\your-project
```

脚本会自动完成：复制 `.claude/` 目录、处理 CLAUDE.md 冲突、显示安装摘要。

**方式 B：npx skills add**

```bash
npx skills add https://github.com/anthropics/skills --skill feature-factory
```

**方式 C：手动复制**

```bash
cp -r .claude /your-project/
```

### 2. 创建项目 CLAUDE.md

```bash
cp references/docs/CLAUDE.md.template /your-project/CLAUDE.md
```

保持 150 行以内，填入你项目的技术栈、命令和架构规则。

### 3. 启动工厂

```bash
/software-factory 构建发票催收功能，对超过7天未支付的发票自动发送提醒
```

---

## 三种模式

| 命令 | 模式 | 流程 |
|------|------|------|
| `/software-factory <描述>` | Full 完整 | Researcher → Planner → Builders → Verifier → Validator |
| `/software-factory --debug <Bug>` | Debug 调试 | Debugger → Builder(s) → Verifier → Validator |
| `/software-factory --incremental <变更>` | Incremental 增量 | Researcher (quick) → Builder(s) → Verifier → Validator |
| `/debug <Bug>` | 仅分析 | Debugger → 输出报告 → 询问是否修复 |

---

## 7 个 Agent

| # | Agent | 模型 | 职责 | 权限 |
|---|-------|------|------|------|
| 1 | **Researcher** | Opus | 映射代码库、识别模式、标记风险 | 只读 |
| 2 | **Planner** | Opus | 用户故事 + 技术蓝图 + 领域建模 | 写入 `.claude/context/` |
| 3 | **Debugger** | Opus | 根因分析、可复现步骤、修复建议 | 只读 |
| 4 | **Backend Builder** | Sonnet | API、服务、数据库迁移、后台任务 | 后端文件 |
| 5 | **Frontend Builder** | Sonnet | 组件、页面、状态管理、UI 测试 | 前端文件 |
| 6 | **Test Verifier** | Haiku | 验收测试，逐条验证 Acceptance Criteria | 仅测试文件 |
| 7 | **Implementation Validator** | Sonnet | 10 项质量门禁检查 | 只读 + Minor 修复 |

---

## 核心设计

- **专业化分工** — 每个 Agent 有干净的上下文和严格边界
- **并行执行** — Backend 和 Frontend Builder 同时启动
- **TDD 强制** — Builder 使用 RED→GREEN→REFACTOR 垂直切片开发
- **模式自适应** — 新功能走 Full，Bug 走 Debug，小改动走 Incremental
- **分级问题处理** — Minor 自动修复，Important 报告，Critical 阻塞
- **领域驱动命名** — Planner 定义规范术语，Validator 检查命名漂移
- **5 个反馈闭环** — 蓝图驳回、测试失败、Validator 阻断、不可测标准、研究阻塞

### 人工审批点

只有两个：**蓝图审批**（Planner 输出后）和 **PR 审批**（Validator 输出后）。

---

## 前置依赖

- [Claude Code](https://code.claude.com)
- 推荐安装 [Superpowers](https://github.com/anthropics/superpowers) 插件（Planner 的 brainstorming 功能，不可用时自动降级为内联分析）

---

## 端到端示例

以下是 `/software-factory 构建发票催收功能` 的完整流水线摘要。

```
Step 1: Researcher — 定位 4 个关键文件，找到类似功能，标记 2 个风险点
Step 2: Planner — 产出 Domain Glossary + User Story (4 AC) + Technical Brief
Step 3: ⏸ 蓝图审批 — 用户批准
Step 4: Builders 并行 — Backend 创建 migration/service/job/API，Frontend 创建逾期标记组件
Step 5: Test Verifier — 4/4 acceptance criteria ✅
Step 6: Validator — Verdict: CLEAN
Step 7: ⏸ PR 审批 — 交付

完整流程耗时约 5-8 分钟，你只在两个节点介入。
```

---

## 项目结构

```
feature-factory/
├── SKILL.md                  ★ ModelScope / Skill 入口（根目录仅此 1 个）
├── .claude/                  部署到目标项目的 Skill 包
│   ├── agents/               7 个 Agent 定义（YAML frontmatter + body）
│   ├── skills/domain-modeling/ 领域建模 Skill（Planner 加载）
│   ├── commands/             /software-factory 和 /debug 入口
│   ├── rules/                Builder 规则、Git 工作流、失败恢复
│   ├── tests/smoke.sh        安装后完整性验证（55+ 项检查）
│   ├── FAQ.md                常见问题排查指南
│   └── CLAUDE.md.template    目标项目模板
├── references/               ★ 规范源（捆绑资源）
│   ├── agents/               7 Agent 定义
│   ├── rules/                3 规则文件
│   ├── commands/             2 入口命令
│   ├── domain-modeling/      领域建模 Skill
│   └── docs/                 FAQ、CLAUDE.md 模板
├── scripts/                  可执行资源
│   ├── install.sh            Unix/macOS 安装脚本
│   ├── install.ps1           Windows PowerShell 安装脚本
│   └── smoke.sh              55+ 项 Pipeline 完整性检查
├── assets/                   图标等静态资源
├── CHANGELOG.md
├── VERSION
├── LICENSE
└── README.md
```

- **向魔搭社区上传时**：`SKILL.md` 是唯一入口，`references/`、`scripts/`、`assets/` 为捆绑资源
- **在本仓库中**：`.claude/` 是从 `references/` 镜像的副本，确保本项目自身可运行 `/software-factory`

---

## 验证安装

```bash
bash .claude/tests/smoke.sh
```

应显示 `Verdict: CLEAN — all checks passed`。

---

## Token 消耗参考（中型 TypeScript 项目）

| 模式 | Agent 序列 | 预计输入 | 预计输出 | 参考耗时 |
|------|-----------|:------:|:------:|:------:|
| Full | Opus×2 + Sonnet×3 + Haiku×1 | ~90K | ~45K | 5-8 min |
| Debug | Opus + Sonnet×2 + Haiku×1 | ~55K | ~28K | 3-5 min |
| Incremental | Opus(quick) + Sonnet×2 + Haiku×1 | ~35K | ~18K | 2-4 min |

**省钱技巧**：小改动用 Incremental、写清楚需求、CLAUDE.md 写完整、信任 Validator 的 Minor 自动修复。
