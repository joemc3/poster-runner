---
description: Load project context (PRD, TAD, specs) - run at session start
---

# Load Project Context

Load the essential project documentation to prime your context for the session.

## Your Task

This command should be run automatically at the start of every session (as specified in CLAUDE.md Session Start Protocol).

1. **Read core documentation:**

   Use @ references to load the key documents:
   - @docs/PRD.md - Product Requirements Document
   - @docs/TAD.md - Technical Architecture Document
   - Check @docs/specs/ for any relevant specifications

2. **Summarize what you learned:**

   Provide a brief summary of:
   - Project name and purpose (from PRD)
   - Target platform/stack (from TAD)
   - Key features/epics (from PRD)
   - Technical architecture overview (from TAD)
   - Any critical constraints or requirements

3. **Display context summary:**

## Example Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
              PROJECT CONTEXT LOADED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 PROJECT: [Project Name]
   [Brief description from PRD]

🎯 GOAL
   [Main objective/purpose]

💻 STACK
   Platform:  [Web/Mobile/Desktop]
   Backend:   [Supabase/Firebase/etc]
   Frontend:  [React/Flutter/etc]
   Database:  [PostgreSQL/etc]

🏗️ ARCHITECTURE
   [Brief architecture summary from TAD]
   - [Key component 1]
   - [Key component 2]
   - [Key component 3]

📦 CORE FEATURES (from PRD)
   1. [Feature/Epic 1]
   2. [Feature/Epic 2]
   3. [Feature/Epic 3]

⚠️  CRITICAL CONSTRAINTS
   - [Performance requirement]
   - [Security requirement]
   - [Compliance requirement]

📚 SPECS AVAILABLE
   ✓ docs/specs/spec-1.md - [Brief description]
   ✓ docs/specs/spec-2.md - [Brief description]
   ✓ docs/specs/spec-3.md - [Brief description]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Context loaded and ready

For detailed specs during work, use @ references:
  @docs/PRD.md - Full product requirements
  @docs/TAD.md - Full technical architecture
  @docs/specs/[spec-name].md - Specific component specs
```

## When Context is Incomplete

If PRD/TAD/specs are placeholder templates (not filled in):

```
⚠️  PROJECT CONTEXT NOT YET CONFIGURED

The following files contain placeholder content:
  - docs/PRD.md (template only)
  - docs/TAD.md (template only)
  - docs/specs/*.md (templates only)

This appears to be a new project setup.

Next steps:
1. Fill in docs/PRD.md with your product requirements
2. Fill in docs/TAD.md with your technical architecture
3. Add specific component specs to docs/specs/
4. OR: Ask me to help you create these documents

Would you like me to:
a) Help you create a PRD based on your project idea
b) Set up the TAD for your chosen stack
c) Skip context loading and start working
```

## Smart Context Loading

**If working in a worktree (already started an issue):**

```
📍 Currently in worktree for Issue #3

Loading relevant context for this task:
  - @docs/PRD.md (Authentication section)
  - @docs/specs/auth-api.md (API spec)

Context loaded and ready to continue work on #3.
```

**If specs reference external documentation:**

Ask if user wants to load external docs:

```
📚 External references found in TAD:
  - Design system: https://design.example.com
  - API standards: https://api-guide.example.com

Would you like me to fetch these? (yes/no)
```

## Integration with Session Start

This command is called as part of the Session Start Protocol in CLAUDE.md:

```bash
# Session start runs:
export PATH="$PATH:/Users/joemc3/.local/bin"
git pull --rebase
~/.local/bin/bd sync
~/.local/bin/bd ready --limit 5
/context:prime  # ← This command
# Then ask: "Which issue would you like to work on?"
```

## Benefits

- Ensures consistent context across sessions
- Refreshes agent memory with current project state
- Helps provide accurate, project-specific guidance
- Reduces hallucination by grounding in actual specs
- Makes recommendations aligned with project goals

## Memory Optimization

For very large projects:
- Load only executive summaries initially
- Load detailed sections on-demand with @ references
- Cache frequently accessed specs

For small projects:
- Load everything upfront
- Keep full context available

Now load the project context!
