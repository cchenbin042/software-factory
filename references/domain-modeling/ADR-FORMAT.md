# ADR Format

An Architecture Decision Record (ADR) captures a decision that was **hard to reverse**, **surprising without context**, and the **result of a real trade-off**. If any of the three is missing, skip the ADR.

## Template

```markdown
# ADR-NNNN: <Title — imperative, one line>

## Status
Proposed | Accepted | Deprecated | Superseded by [ADR-NNNN](.)

## Context
What problem are we solving? What constraints are we under?
What alternatives were considered?
Why is this decision hard to reverse?

## Decision
What did we decide? Be specific — exact approach, not a hand-wave.
What was the rejected alternative? Why was it rejected?

## Consequences
What becomes easier because of this decision?
What becomes harder?
What is the migration path if we change our minds later?
```

## Rules

1. **Number sequentially**: 0001, 0002, 0003. Never renumber.
2. **Status starts as "Proposed".** Change to "Accepted" once approved. Use "Deprecated" or "Superseded by ADR-NNNN" when overridden.
3. **Context names the rejected alternative.** Without it, the reader can't see the trade-off.
4. **Decision is precise.** "We'll use Postgres" is too vague. "We'll use Postgres for the write model, with event sourcing via the `events` table using `jsonb` for payloads" is specific.
5. **Consequences are honest.** Every decision makes something harder. Name it.
6. **One decision per ADR.** Don't bundle unrelated choices into one file.
7. **Create sparingly.** Most discussions don't need an ADR. Only create when all three criteria (hard to reverse + surprising + real trade-off) are met.
