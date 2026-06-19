# Feature Factory v1.5.0–v1.5.2 结构升级设计

## 背景

对 Feature Factory Agent Teams Skill 包的全面审计产出了 87/100 的综合评分和 8 项改进建议。本文档描述这 8 项改进的技术实现方案，按三层 Sprint 组织。

### 分类原则

改进项按生命周期分为两类，采用差异化可移植性要求：

| 类别 | 生命周期 | 示例 | 要求 |
|------|---------|------|------|
| **维护者工具** | 只在源 repo 里运行 | CI workflow | 本 repo 可用即可 |
| **分发内容** | 随 `.claude/` 复制到目标项目 | SKILL.md、Agent 定义、FAQ、规则文件、smoke.sh 脚本 | 跨项目可移植 |

### 排除出范围

- 不做 Agent 数量或职责变更（那是 MAJOR 级别的事情）
- 不做编排 Skill 的核心逻辑改动（只拆分文件结构）
- 不引入新外部依赖

---

## Sprint 1（v1.5.0）：结构层

**目标**：SKILL.md 拆分为索引体系 + Prompt 模板独立管理 + Superpowers 耦合降级

### 1.1 SKILL.md 拆分

#### 当前状态

```
.claude/skills/feature-factory/
└── SKILL.md    # ~580 行：编排逻辑 + 三种模式 Agent prompt 模板 + 8 条规则
```

#### 目标结构

```
.claude/skills/feature-factory/
├── SKILL.md              # ~120 行，纯编排逻辑 + 索引
├── rules.md              # ~40 行，8 条编排者规则
└── prompts/
    ├── full-mode/
    │   ├── step-1-researcher.md
    │   ├── step-2-planner.md
    │   ├── step-4-backend-builder.md
    │   ├── step-4-frontend-builder.md
    │   ├── step-5-test-verifier.md
    │   └── step-6-validator.md
    ├── debug-mode/
    │   ├── step-1-debugger.md
    │   ├── step-3-backend-builder.md
    │   ├── step-3-frontend-builder.md
    │   ├── step-4-test-verifier.md
    │   └── step-5-validator.md
    ├── incremental-mode/
    │   ├── step-1-researcher.md
    │   ├── step-2-backend-builder.md
    │   ├── step-2-frontend-builder.md
    │   ├── step-3-test-verifier.md
    │   └── step-4-validator.md
    └── shared/
        ├── planner-revision.md          # 蓝图驳回重试
        ├── builder-test-fix.md           # 测试失败重试
        ├── validator-critical-fix.md     # Critical 修复重试
        └── debugger-reanalysis.md        # 诊断驳回重分析
```

共 20 个新文件 + 1 个精简的 SKILL.md。

#### SKILL.md 新结构

```
---
name: feature-factory
description: ...
argument-hint: ...
user-invocable: true
model: sonnet
---

# Feature Factory — Software Factory Orchestrator

## Architecture
[ASCII 图保持不变]

## Three Modes
[模式决策表保持不变]

## Full Mode Workflow
[7 步，每步一行摘要 + 指向对应 prompt 文件的链接]

## Debug Mode Workflow
[同结构]

## Incremental Mode Workflow
[同结构]

## Rules for the Orchestrator
→ See [rules.md](rules.md)

## Git Workflow Integration
→ See [../../rules/git-workflow.md](../../rules/git-workflow.md)

## Failure Recovery & Feedback Loops
→ See [../../rules/failure-recovery.md](../../rules/failure-recovery.md)
```

#### Prompt 文件格式

纯 Markdown，无 frontmatter。内容即当前 SKILL.md 里 `Agent(...)` 调用的 `prompt="..."` 原文。

示范 `prompts/full-mode/step-1-researcher.md`：

```markdown
# Full Mode — Step 1: Researcher Prompt

Copy this into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="researcher",
  description="Research codebase for feature",
  prompt="Research the codebase for the following feature request. Map relevant files, identify existing patterns, find similar features, flag risks, and list tests that will need updates.

Feature: [USER'S FEATURE DESCRIPTION]"
)
```

#### 可移植性保证

- 所有链接用相对路径
- 零 frontmatter 依赖——文件内容即纯 Markdown
- 整个 `skills/feature-factory/` 目录自包含，随 `.claude/` 一起复制
- smoke.sh 的 `subagent_type` 引用检查不受影响——grep 关键字不变

#### smoke.sh 调整

新增 2 项检查：
1. prompts/ 下所有文件存在性校验（3 模式 × 各自步骤 + 4 shared = 20 个文件）
2. SKILL.md 内链接指向真实文件

### 1.2 Superpowers 解耦

#### 问题

Planner 的 Phase 0 依赖 Superpowers 插件的 brainstorming skill。降级路径"内部分析"未提供结构化指引。

#### 目标

Planner 在任何环境下都有结构化 brainstorming，Superpowers 降级为加速器。

#### 改动：planner.md Phase 0 重写

三处改动：

**改动 1** — 标题和条件分支：

```markdown
### Phase 0: Brainstorming (MANDATORY — never skip)

**If the Superpowers plugin is available**, invoke it for the full interactive process:
`Skill(skill="brainstorming")`

**If Superpowers is NOT available**, do NOT skip brainstorming. Run it inline using the process below. The output must be the same quality — the only difference is the medium, not the rigor.
```

**改动 2** — 内联 brainstorming 流程：

```markdown
#### Inline Brainstorming Process (when Superpowers is unavailable)

Follow this exact sequence. Do not skip steps. Do not batch questions.

**1. Explore project context** (before asking the user anything)
- Read CLAUDE.md — note the tech stack, commands, and rules
- Read the Researcher's findings — note similar features, patterns, and risks
- Read at least one similar feature's implementation for reference
- Summarize what you found in 2-3 sentences before proceeding

**2. Ask clarifying questions** (one at a time, up to 3)
- First question: understand the user's real goal
- Second question (if needed): identify constraints
- Third question (if needed): clarify scope
- After each answer, confirm you understood before asking the next question

**3. Propose 1-2 approaches** (not 3 — keep it focused)
- Each approach: one paragraph on what it is, one paragraph on trade-offs
- Recommend one with clear reasoning
- Ask: "Does this approach make sense?"

**4. Present design in sections** (get approval after each)
- Section 1: Domain Glossary
- Section 2: User Story + Acceptance Criteria
- Section 3: Technical Brief
- Present each, ask if it looks right, adjust if needed

**Hard gate**: Do NOT write the final User Story or Technical Brief until this inline process is complete.
```

**改动 3** — install 脚本加 Superpowers 引导

`install.sh` 末尾：

```bash
echo ""
echo "Recommended: Superpowers Plugin"
echo "  claude plugins install anthropics/superpowers"
read -p "Install Superpowers now? [Y/n] " answer
if [[ "$answer" != "n" && "$answer" != "N" ]]; then
  claude plugins install anthropics/superpowers 2>/dev/null || echo "  → Skipped"
fi
```

`install.ps1` 同理。

#### 可移植性

- 内联流程是纯 Markdown，写在 Planner Agent 定义里——复制到任何项目即生效
- 不引入新文件依赖
- install 脚本引导是可选交互，不阻塞无人值守安装

---

## Sprint 2（v1.5.1）：质量层

**目标**：CI 自动化 + 依赖声明 + 版本兼容性策略

### 2.1 GitHub Actions CI

**文件**：`.github/workflows/smoke.yml`

```yaml
name: Pipeline Smoke Test

on:
  push:
    paths:
      - '.claude/agents/**'
      - '.claude/commands/**'
      - '.claude/context/**'
      - '.claude/rules/**'
      - '.claude/skills/**'
      - '.claude/tests/**'
  pull_request:
    paths:
      - '.claude/agents/**'
      - '.claude/commands/**'
      - '.claude/context/**'
      - '.claude/rules/**'
      - '.claude/skills/**'
      - '.claude/tests/**'

jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Ensure smoke test is executable
        run: test -x .claude/tests/smoke.sh || chmod +x .claude/tests/smoke.sh

      - name: Run pipeline smoke test
        run: bash .claude/tests/smoke.sh --ci
```

**设计决策**：
- 路径触发：只改 `.claude/` 内部文件时跑，改 README/CHANGELOG 不触发
- `ubuntu-latest`：bash ≥5.0，GNU sed/grep，满足所有依赖
- `test -x || chmod +x`：防止 Windows push 后执行权限丢失
- `--ci` flag：warning 不阻塞 CI，只阻塞真正的 error

**分类**：维护者工具——不随 `.claude/` 分发。

### 2.2 smoke.sh 依赖声明

在 `set -euo pipefail` 之后插入：

```bash
# Dependency check
REQUIRED_CMDS=("bash" "sed" "grep")
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: Required command not found: $cmd" >&2
    exit 3
  fi
done

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  echo "ERROR: bash >= 4.0 required, found $BASH_VERSION" >&2
  exit 3
fi
```

`--ci` flag 支持：

```bash
CI_MODE=false
if [ "${1:-}" = "--ci" ]; then
  CI_MODE=true
fi
```

Verdict 逻辑调整——CI 模式下 warning 不退出 1：

```bash
if [ "$FAIL" -gt 0 ]; then
  exit 2
elif [ "$WARN" -gt 0 ] && [ "$CI_MODE" = false ]; then
  exit 1
else
  exit 0
fi
```

**分类**：分发内容——脚本本身随 `.claude/tests/` 分发，`--ci` flag 在任意 CI 环境行为一致。

### 2.3 Deprecation 策略

位置：CHANGELOG.md 开头，版本策略下方。

内容包含：

| 组件 | 策略 |
|------|------|
| Agent 定义 | 旧格式保留 1 个 MAJOR 版本；新增字段向后兼容 |
| 编排 Skill | 路径变更时原位置保留 `[MOVED]` 桩文件 1 个 MINOR 版本 |
| 规则文件 | 立即生效——内容变更即变更 |
| Smoke test | 检查项只增不减；废弃项标记 `# LEGACY`，下一个 MAJOR 版本移除 |
| 命令定义 | 参数兼容 1 个 MINOR 版本 |

版本号触发规则表：新增/删除 Agent = MAJOR；编排规则/prompt/Smoke 扩展 = MINOR；措辞/勘误 = PATCH。

废弃通知模板：`[组件名]: [内容]。将在 [版本号] 中移除。迁移方式：[说明]。`

用户兼容性检查：运行 `bash .claude/tests/smoke.sh`——通过即兼容。

**分类**：分发内容——写在 CHANGELOG.md 里，随 `.claude/` 一起分发。

---

## Sprint 3（v1.5.2）：文档层

**目标**：Token 成本参考 + FAQ 真实案例 + 演示录屏

### 3.1 Token 成本参考表

位置：README.md，"前置依赖" 之后。

内容：
- 按三种模式分列的 token 输入/输出估算表（基于中型 TS 项目 ~150 文件）
- 影响消耗的因素表（项目规模、功能复杂度、Agent 重试、Superpowers 可用性）
- 省钱技巧（小改动用 Incremental、写清楚需求、CLAUDE.md 写完整、信任 Validator）

设计原则：
- 以 token 数而非美元计价（模型价格变动时 token 数不变）
- 明示"数量级参考，不是精确报价"
- 用户行为 → 消耗的因果链条清晰

### 3.2 FAQ 真实案例

在三个最常见痛点下各加一个 `### 真实案例` 子节：

- **Q1（Agent 输出不符合预期）**：NestJS 项目 CLAUDE.md 里 `typecheck` 命令与实际 `package.json` 不一致
- **Q6（Incremental vs Full 边界）**：用户以为"改字符串"是 Incremental，Quick Researcher 发现 12 个文件跨 3 模块
- **Q8（跨项目复制后不工作）**：Go 项目未修改 builder-rules.md 的 paths 和 CLAUDE.md 的命令

每个案例格式：场景 → 排查过程 → 修复 → 教训。

### 3.3 演示录屏

形式：外部视频（YouTube 不公开列出）+ README 链接 + `docs/demo-script.md` 脚本存档。

3 分钟内容脚本：

| 时间 | 画面 | 旁白 |
|------|------|------|
| 0:00-0:15 | 终端全屏 | Feature Factory 概念引入 |
| 0:15-0:45 | 输入命令，Researcher 执行 | Researcher 扫描 |
| 0:45-1:15 | Planner 输出 | Domain Glossary + Story + Brief |
| 1:15-1:30 | 用户批准蓝图 | 唯一审批点 |
| 1:30-2:00 | 并行 Builder，TDD Cycle Log | 并行构建 |
| 2:00-2:20 | Test Verifier 输出 | 验收测试 |
| 2:20-2:40 | Validator 输出 CLEAN | 质量门禁 |
| 2:40-3:00 | Ready for PR | 总结 |

README 链入：
```markdown
> 🎬 **3 分钟演示**：[观看 Feature Factory 完整流水线](https://youtu.be/XXXXX)
```

---

## 整体影响评估

### 文件变更总览

| 文件 | Sprint | 操作 |
|------|--------|------|
| `.claude/skills/feature-factory/SKILL.md` | S1 | 修改（~580 行 → ~120 行） |
| `.claude/skills/feature-factory/rules.md` | S1 | 新增 |
| `.claude/skills/feature-factory/prompts/full-mode/*.md` (6) | S1 | 新增 |
| `.claude/skills/feature-factory/prompts/debug-mode/*.md` (5) | S1 | 新增 |
| `.claude/skills/feature-factory/prompts/incremental-mode/*.md` (5) | S1 | 新增 |
| `.claude/skills/feature-factory/prompts/shared/*.md` (4) | S1 | 新增 |
| `.claude/agents/planner.md` | S1 | 修改（Phase 0 重写） |
| `install.sh` | S1 | 修改（+Superpowers 引导） |
| `install.ps1` | S1 | 修改（+Superpowers 引导） |
| `.claude/tests/smoke.sh` | S1+S2 | 修改（+prompt 文件检查 + 依赖声明 + `--ci`） |
| `.github/workflows/smoke.yml` | S2 | 新增 |
| `CHANGELOG.md` | S2 | 修改（+Deprecation 策略） |
| `README.md` | S3 | 修改（+成本表 + 录屏链接） |
| `.claude/FAQ.md` | S3 | 修改（+3 个真实案例） |
| `docs/demo-script.md` | S3 | 新增 |

### 不影响的部分

- 7 个 Agent 定义（除 planner.md）
- 2 个命令定义
- 3 个规则文件
- domain-modeling skill
- VERSION 和 LICENSE
- `.gitignore`

### 用户侧影响

- 现有用户升级 v1.4.0 → v1.5.0：复制新 `.claude/skills/feature-factory/` 目录和修改后的 `planner.md` 即可
- 不影响已在运行的流水线——SKILL.md 精简是阅读性变化，Agent prompt 模板是结构性变化，内容不变
- smoke.sh 可验证升级完整性
