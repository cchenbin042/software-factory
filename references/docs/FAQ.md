# FAQ / Troubleshooting

Feature Factory 常见问题和排查指南。如果你遇到的问题不在此列，请反馈——新问题会成为下一个 FAQ 条目。

---

## Agent 行为相关

### Q1: Agent 输出不符合预期怎么办？

Agent 的输出结构不完整、格式不对、或者内容明显错误时：

1. **先看输出本身**——Agent 可能没有被提供完整上下文（比如 Planner 没有收到 Researcher 的完整报告），也可能被分配了过大或过模糊的任务
2. **检查前置条件**——该 Agent 需要的输入是否齐全？（Researcher 需要用户需求，Planner 需要 Researcher 结果，Builder 需要 Planner 输出……）
3. **检查 CLAUDE.md**——项目 CLAUDE.md 中的架构规则是否与 Agent 的默认行为冲突？Agent 按通用规则工作，不会自动知道你的项目有其他约定
4. **尝试重试**——编排者会调用重试流程（"Your previous output had [problem]. Fix it and re-produce."），第一次失败很可能是上下文丢失或任务切割问题
5. **拆分任务**——如果同一个 Agent 同一类问题反复出现，把任务拆小。比如把一个大的 Builder 任务拆成"先做 migration"→"再做 service"→"最后做 route"三个小 Agent

### 真实案例

**场景**：用户在 NestJS 项目中使用 Feature Factory，Backend Builder 每次都
在 Step 4（验证）阶段报 `typecheck: command not found`。

**排查过程**：
1. 检查 CLAUDE.md → 写的 typecheck 命令是 `npm run typecheck`
2. 检查目标项目的 `package.json` → scripts 里没有 `typecheck`，实际命令是 `tsc --noEmit`
3. Builder 按照 CLAUDE.md 的指令调用了不存在的 npm script

**修复**：将 CLAUDE.md 中的命令改为项目实际使用的 `tsc --noEmit`。

**教训**：CLAUDE.md 里的命令必须跟项目的 `package.json`/`Makefile`/`pyproject.toml` 保持一致。
安装 Feature Factory 后第一件事就是验证 CLAUDE.md 里的命令能不能跑通。

### Q2: Researcher 说"没找到相关信息"怎么办？

这不一定是 Researcher 失败——可能是你的代码库确实没有任何相关文件，也可能是 Researcher 的搜索路径不够广。

1. **检查 CLAUDE.md 是否完整**——如果 CLAUDE.md 没有描述你的目录结构，Researcher 只能靠猜测去搜索
2. **给出更具体的路径提示**——"后端在 `src/api/` 目录下，数据库在 `src/models/`" 这类信息可以帮 Researcher 快速定位
3. **可能应切换到 Full 模式**——如果没有可参考的现有代码（新项目、新功能类别），Incremental 模式的 quick scan 可能不够，走 Full 模式的完整 Researcher 更好

### Q3: Planner 的 brainstorming 功能不可用？

Planner Agent 依赖 [Superpowers](https://github.com/anthropics/superpowers) 插件的 `brainstorming` Skill。如果 Superpowers 不可用：

- **Planner 不会崩溃**——它会检测到 brainstorming 不可用，降级为内部分析
- **降级后的代价**：缺少结构化的需求澄清过程（multi-step questioning → approach comparison → section-by-section approval），Planner 会直接产出 User Story + Technical Brief 作为一版输出
- **你可以手填补**：如果你对需求本身已经有明确想法，降级不影响产出质量。如果你希望深度讨论需求，建议先安装 Superpowers 再启动 Full 模式
- **安装 Superpowers**：`claude plugins install superpowers@superpowers-marketplace`

### Q4: Validator 报告 BLOCKED，但我不同意？

Validator 的判断可能过于严格（比如把一个命名不一致的 Minor 问题标为 Critical），也可能反映了你不同意的架构偏好。

1. **先看具体文件路径和行号**——Validator 的每个 Critical 问题都必须指向具体代码位置，如果是空的或模糊的，说明 Validator 自身有问题
2. **区分"Validator 对了但我选择忽略"和"Validator 判断错了"**：
   - 如果 Validator 的判断是正确但你认为优先级低，你可以明确说"记录为 Known Issue，不阻塞本次 PR"
   - 如果 Validator 判断本身有误（比如把 `console.error` 误判为泄露 secrets），反馈给 Validator 重跑
3. **你可以调整蓝图**——如果 Validator 的问题本质上是因为 Planner 的蓝图不完整或过度严格，调整 User Story 或 Technical Brief 中的边界定义，然后重新跑流水线
4. **Validator 不是上帝**——它是质量门禁，不是最终裁决者。你作为人类始终拥有最终决定权

---

## 参数与性能相关

### Q5: 如何调整 Agent 的 maxTurns？

每个 Agent 的 maxTurns 定义在其 `frontmatter` 中：

```yaml
# .claude/agents/<agent-name>.md
---
maxTurns: 15  # 调整为更大或更小的值
---
```

**参考值（基于项目规模和 Agent 类型）：**

| 项目规模 | Researcher | Planner | Builder | Verifier | Validator |
|--------|-----------|---------|---------|----------|-----------|
| 小型（<50 文件） | 10 | 8 | 12 | 10 | 10 |
| 中型（50-200 文件） | **15** | **12** | **20** | **15** | **15** |
| 大型（200+ 文件） | 20 | 15 | 25 | 20 | 20 |

默认值是针对中型项目的。如果你的项目特别大或特别小，按上表调整。

**注意**：maxTurns 不是"Agent 能做多少事"的指标，而是"Agent 输出长度 * 交互轮次"的上限。一个 Builder 在 20 turns 内可能已经做了足够多的事——瓶颈通常在输出长度，不在 maxTurns。

### Q6: Incremental 模式和 Full 模式的边界在哪里？

**适合 Incremental 的信号**（满足 **全部** 条件）：
- 改动范围可预测（单文件到 3-4 个文件）
- 不需要新增 API 端点或数据库 migration
- 改动是局部的——不影响现有行为语义
- 你不需要 User Story 和 Technical Brief 来对齐团队理解

**适合 Full 的信号**（满足 **任意一个** 即触发）：
- 需要新增 API 端点或修改现有端点契约
- 涉及数据库 schema 变更
- 改动范围不可预测（需要 Researcher 探索才知道）
- 涉及多个模块或跨层修改
- 团队需要一份用户故事来对需求达成共识

**模糊地带**：当你无法判断时，从 Incremental 开始。Incremental 的 Step 1（Quick Researcher Scan）会告诉你是否该升级到 Full——如果 Researcher 发现 8+ 文件受影响或跨模块依赖，编排者会自动建议升级。

### 真实案例

**场景**：用户想把所有 API 错误消息从英文改成中文，直觉是"Incremental——
只是改字符串而已"。

**Quick Researcher 发现**：
- 错误消息分散在 12 个 service 文件中
- 部分消息是前端 hardcode 的（不在后端）
- 有一个 shared error codes 常量文件被前后端共同引用
- 涉及 3 个模块、前后端两层

**编排者判断**：8+ 文件 + 跨模块 + 共享文件冲突风险 → 建议升级到 Full。
用户接受升级，Planner 产出了一份完整的迁移方案。

**教训**："只改字符串"从描述看是 Incremental，但从代码分布看可能是
Full。信任 Quick Researcher 的扫描结果——它比你更快地看到真实影响面。

---

## 执行流程相关

### Q7: Builder 测试失败后怎么处理？

有两次自动修复机会（编排者会触发），但不同失败原因的处理方式不同：

| 失败类型 | 处理 |
|---------|------|
| 新写的测试失败了 | Builder 的代码有 bug——自动重试修复（最多 2 次） |
| 已有测试被打破 | Builder 引入了回归——更严重，必须修复；重试提示会强调"已有测试是正确的，找出你打破的地方" |
| 2 次修复后仍然失败 | 升级到用户——编排者会展示全部失败输出，由你判断是代码问题还是测试问题 |
| 测试环境本身的错误（依赖缺失、配置不对） | 不是 Builder 的问题——你可能需要手动配置测试环境后再重跑 |

**关键原则**：不要让 Verifier 充当第二个 Builder。Verifier 只报告问题，不修代码。如果 Builder 不能解决自己的测试失败，说明任务分配有问题——要么拆分任务，要么人工介入。

### Q8: 跨项目复制 Feature Factory 后不工作？

Feature Factory 是跨项目可移植的，但前提是目标项目有正确的 CLAUDE.md。

**快速排查清单：**

1. **CLAUDE.md 是否存在？** —— 目标项目根目录必须有 CLAUDE.md，且必须包含：
   - 技术栈
   - 常用命令（`dev`, `test`, `lint`, `typecheck` 的实际命令）
   - 架构规则
   - 禁止做的事情

2. **Builder 的检查命令是否正确？** —— 如果 CLAUDE.md 中写的是 `npm test`，但你的项目实际用 `pytest`，Builder 在执行步骤 4 验证时会报错。检查 CLAUDE.md 中的命令是否与实际项目一致。

3. **Agent 定义是否需要调整？** —— Agent 的 frontmatter 保留默认值（`model: sonnet`, `maxTurns: 15` 等），这些默认值是为中型 Node/TS 项目设定的。如果你的项目是 Go/Python/Rust 或有特殊需求，可能需要调整 `tools` 列表（加/减特定工具）和 `maxTurns`。

4. **路径约定是否一致？** —— Feature Factory 不假定任何具体文件路径，但 Planner 产出的 Technical Brief 中列出的文件路径来自 Researcher 的扫描结果。如果 Researcher 报告中的路径与实际项目不一致，检查 CLAUDE.md 是否提供了足够的目录结构信息。

5. **权限模式** —— 所有 Agent 默认使用 `permissionMode: acceptEdits`。在目标项目的 Claude Code 设置中，确保相应的权限已配置。

---

### 真实案例

**场景**：用户把 `.claude/` 目录复制到 Go 项目后，Feature Factory 不工作。

**排查过程**：
1. CLAUDE.md 存在 ✅
2. Agent 定义完整 ✅
3. 检查 CLAUDE.md 的命令 → `npm test`（这是 Node 项目的命令，Go 项目用 `go test ./...`）
4. Builder 在执行步骤 4 验证时报错
5. `.claude/rules/builder-rules.md` 的 `paths` 列表写的是 `**/*.ts`, `**/*.tsx` 等——Go 文件 (`.go`) 存在但 TypeScript 路径不匹配

**修复**：
1. 把 CLAUDE.md 的命令改成 Go 项目的实际命令
2. 修改 `.claude/rules/builder-rules.md` 的 `paths`，确保包含 `**/*.go`
3. 重新运行 `bash .claude/tests/smoke.sh` 验证

**教训**：复制 `.claude/` 后需要做三件事：
1. CLAUDE.md 命令改对
2. 规则文件的 paths 覆盖你的语言
3. 跑 smoke.sh 确认

---

## 快速诊断

如果你的问题不在上述 FAQ 中，用这个诊断框架快速定位：

```
症状：[描述你看到的问题]
预期：[你期望看到什么]
发生阶段：[Full/Debug/Incremental 模式的哪一个 Step]
涉及 Agent：[Researcher / Planner / Builder / Verifier / Validator]
输出片段：[粘贴相关 Agent 输出的关键部分]
```

把这个信息带上，反馈给 Feature Factory 维护者。
