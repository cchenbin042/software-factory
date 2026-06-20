---
# paths 不适用：此为 Schema 参考文件，不参与 Builder 代码检查
paths: []
---

# Handoff Block Schema

Agent 之间传递上下文的唯一格式。Orchestrator 维护累积 Block，每个 Agent 完成后追加其字段。

## 完整 Schema

```yaml
# ===== Schema 版本 =====
schema_version: 1

# ===== 所有 Agent 共享 =====
feature:
  summary: "一句话功能描述"          # ≤80 字符
  mode: full | debug | incremental

# ===== Researcher 产出 =====
files_map:
  patterns:                         # 命名模式，非文件清单
  similar_features:                 # 仅最相关的 1–2 个
  risks:                            # 仅 Critical / Important

# ===== Planner 产出 =====
domain_glossary:                    # ≤8 个术语
  - term: X
    definition: ...
    in_code: X
    not_to_confuse: Y
acceptance_criteria:                # 编号清单
  - id: AC-1
    summary: "..."

# ===== Builder 产出（Backend + Frontend 各自产出）=====
api_contract:                       # 仅 Backend Builder
  - method: POST
    path: /api/x
    request: '{ ... }'
    response: '{ ... }'
    auth: required | optional | none
files_created:                      # 路径 + 一行用途，双方追加
tdd_log_summary:
  total_cycles: N
  all_green: true | false
  typecheck: pass | fail
  lint: pass | fail

# ===== Test Verifier 产出 =====
acceptance_results:
  - criterion: AC-1
    result: pass | fail | untestable
    note: ""                        # 仅 fail/untestable 时填写，≤60 字符

# ===== Validator 产出 =====
validation_verdict: clean | issues_found | blocked
critical_issues:                    # 仅 blocked 时填写
  - check: "..."
    file: path/to/file
    line: N
```

## 组装规则

- 初始 Handoff 仅含 feature.summary + feature.mode
- 每个 Agent 完成后，Orchestrator 将其 Handoff 字段合并到累积 Block
- 给下一 Agent 的 prompt = `Handoff: {累积 Block}\nTask: [一句描述]`
- Validator 接收完整累积 Handoff（≤1.2K tokens）
