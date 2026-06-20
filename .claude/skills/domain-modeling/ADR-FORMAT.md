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

## Filled Example

Below is a concrete ADR showing the expected level of detail. Use it as a reference when writing your own.

```markdown
# ADR-0004: Use event sourcing for invoice state transitions

## Status
Accepted

## Context
Invoice state transitions (draft → sent → overdue → paid/written_off) are the core
domain concern. Each transition triggers side effects: sending reminder emails, updating
AR aging reports, logging audit trails.

Alternatives considered:
- **In-place status column + trigger-based audit log** — simpler to implement but loses
  the *why* of each transition. Hard to retroactively answer "when exactly did invoice
  INV-042 go overdue?"
- **Event sourcing with a dedicated `invoice_events` table** — each transition is an
  append-only event. Full auditability, easy to replay or add new projections later.

This decision is hard to reverse because the event schema becomes the backbone of
reporting, and migrating off event sourcing means rewriting all read models.

## Decision
We'll use the `invoice_events` table (Postgres) as the write-side event store.
Each row has: `event_id (uuid)`, `invoice_id (fk)`, `event_type (enum)`, `payload
(jsonb)`, `occurred_at (timestamptz)`. The `invoices.status` column remains as a
materialized view maintained by a post-event projector — readers query `invoices.status`
directly, not the event log.

Rejected: In-place status column with trigger-based audit log. It handles the happy path
but loses transition history — we can't distinguish "status set to overdue by the cron
job" from "status corrected by an admin", which matters for compliance.

## Consequences
- **Easier**: Full audit trail for every state change. New projections (e.g., "average
  time from sent to paid") can be added without touching write paths.
- **Harder**: Simple status reads now require the projector to have run. Eventual
  consistency means a just-emitted event may not yet be visible in `invoices.status`.
  Debugging requires tracing the event log.
- **Migration path**: If we abandon event sourcing, the `invoices.status` column is
  already the authoritative read side — we'd drop the events table and go back to direct
  status writes. Existing projections would need rewriting.
```
