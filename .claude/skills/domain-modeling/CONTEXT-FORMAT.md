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
