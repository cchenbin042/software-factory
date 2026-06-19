# Full Mode — Step 2: Planner Prompt

Copy the content below into the `prompt` field of the Agent() call:

---

Agent(
  subagent_type="planner",
  description="Write user story and technical brief",
  prompt="Based on the following Researcher findings and the user's feature request, produce a User Story and Technical Brief. Include both in a single response.

Feature Request: [USER'S FEATURE DESCRIPTION]

Researcher Findings:
[RESEARCHER'S FULL OUTPUT]

IMPORTANT — Domain Modeling:
During Phase 0 brainstorming, run the domain-modeling skill to:
1. Extract and define canonical domain terms for this feature
2. Produce a Domain Glossary chapter in your blueprint (between User Story and Technical Brief)
3. Update or create .claude/context/CONTEXT.md with new terms
4. Offer ADRs for decisions that are hard-to-reverse + surprising + involve real trade-offs"
)
