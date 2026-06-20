# CONTEXT.md Format

`CONTEXT.md` is a **glossary** — it defines the project's domain terms and nothing else. No implementation details, no specs, no scratch notes.

## Template

```markdown
# Domain Glossary

## <Term Name>
- **Definition**: precise, one sentence
- **Synonyms**: aliases used in code (function names, variable names, file names)
- **Not to be confused with**: similar but distinct terms in this project
- **See also**: related terms in this glossary

## Relationships
- A <Term1> has many <Term2>
- A <Term3> belongs to one <Term4>

## Flagged ambiguities
- "<old-term>" was previously used to mean <X>. Resolved: now means <Y>.
```

## Rules

1. **One term = one `##` section.** Don't group unrelated terms together.
2. **Definitions are one sentence.** If you need more, the term is too broad — split it.
3. **"Not to be confused with" is mandatory.** Every domain has near-misses. Name them.
4. **"Synonyms" lists code identifiers.** Use backticks: `processOrder`, `order.ts`.
5. **Relationships use active verbs**: "has many", "belongs to", "references", "creates".
6. **Flagged ambiguities is a log.** Append to it; never delete entries. It shows how the language evolved.
7. **No implementation details.** This is not where you document API shapes, database schemas, or file paths.
8. **Create lazily.** If no terms have been resolved, don't create an empty file.

## Filled Example

Below is a concrete CONTEXT.md showing the expected level of detail. Use it as a reference.

```markdown
# Domain Glossary

## Invoice
- **Definition**: A payment request sent to a customer for goods or services delivered.
- **Synonyms**: `Invoice`, `invoice.ts`, `invoices` table, `InvoiceStatus`
- **Not to be confused with**: Order (an order becomes an invoice after fulfillment), Quote (a quote is a price estimate, not a payment request)
- **See also**: InvoiceLine, Payment, Customer

## InvoiceLine
- **Definition**: A single billable item within an invoice (product, quantity, unit price).
- **Synonyms**: `InvoiceLine`, `line_items`, `invoice_lines` table
- **Not to be confused with**: OrderLine (order lines are picked/fulfilled; invoice lines are billed)
- **See also**: Invoice, Product

## Reminder
- **Definition**: An automated notification sent to a customer when their invoice is overdue.
- **Synonyms**: `Reminder`, `reminder_job.ts`, `sendReminder()`
- **Not to be confused with**: Notification (reminders are one type of notification; others include welcome emails, password resets)
- **See also**: Invoice, ReminderPolicy

## ReminderPolicy
- **Definition**: Configuration rules defining when reminders are sent (e.g., "7 days overdue → first reminder, 14 days → second reminder, 30 days → final notice").
- **Synonyms**: `ReminderPolicy`, `reminder_policies` table, `policy_config`
- **Not to be confused with**: EscalationPolicy (escalation is about human follow-up after automated reminders fail)
- **See also**: Reminder

## Relationships
- An Invoice has many InvoiceLines
- An Invoice has many Payments
- A Reminder belongs to one Invoice
- A ReminderPolicy has many Reminders

## Flagged ambiguities
- "Reminder" was previously used interchangeably with "Notification". Resolved: Reminder is specifically overdue-payment related; Notification is the broader category.
```
