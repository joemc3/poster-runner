# Migrating an Existing Project to CCPM Workflow

This guide helps you apply the CCPM workflow to an existing project. No matter how your work is currently tracked, you can migrate smoothly.

## Getting Started

**If you're in an existing project and want to migrate to this workflow**, you first need to get the migration tools. Here's the easiest way:

### Bootstrap Migration (Recommended)

Open Claude Code in your existing project and say:

```
I want to migrate my project to the CCPM workflow. Please help me:

1. Fetch the migration guide and tools from this template repository:
   https://github.com/YOUR_USERNAME/cc-workflow-template

   Specifically download:
   - MIGRATION.md → save to project root
   - .claude/commands/project-migrate.md → save to .claude/commands/

2. Create .claude/commands/ directory if it doesn't exist

3. Once the files are in place, run /project-migrate to start the migration

Can you do this for me?
```

Claude will:
- Fetch the migration files from the template repo
- Put them in the right locations
- Run the migration assistant to help you migrate your project

### Manual Bootstrap (Alternative)

If you prefer to do it manually:

1. **Download migration files:**
   ```bash
   # Create directory if needed
   mkdir -p .claude/commands

   # Download MIGRATION.md
   curl -o MIGRATION.md https://raw.githubusercontent.com/YOUR_USERNAME/cc-workflow-template/main/MIGRATION.md

   # Download migration command
   curl -o .claude/commands/project-migrate.md https://raw.githubusercontent.com/YOUR_USERNAME/cc-workflow-template/main/.claude/commands/project-migrate.md
   ```

2. **Run the migration:**
   ```bash
   /project-migrate
   ```

### What Happens Next

Once you have the migration files in place and run `/project-migrate`, Claude will:
- Ask questions about your current project state
- Scan existing issues and docs
- Import/create GitHub issues and BEADS entries
- Set up the full CCPM workflow
- Guide you through customization

---

## Quick Start (After Bootstrap)

Once you have `/project-migrate` available, run it:
```bash
/project-migrate
```

This will guide you through the migration interactively. For more control or understanding, read the scenarios below.

---

## Migration Scenarios

### Scenario 1: GitHub Issues Exist, No BEADS

**Your situation:**
- Work tracked in GitHub issues
- No `.beads/` directory
- May or may not have PRD/TAD

**Migration steps:**

1. **Initialize BEADS:**
   ```bash
   export PATH="$PATH:/Users/joemc3/.local/bin"
   bd --version  # Verify BEADS is installed
   bd init
   ```

2. **Import existing issues:**

   **Prompt for Claude:**
   ```
   I have existing GitHub issues. Please:
   1. List all open issues (use gh issue list)
   2. Identify which are epics vs tasks (ask me if unclear)
   3. Create corresponding BEADS entries for each
   4. Set up appropriate dependencies based on issue relationships
   5. Update issue labels (add 'epic' or 'task' as appropriate)
   6. Show me the mapping (GitHub # → BEADS ID)
   ```

3. **Create missing context docs** (if needed):

   **Prompt for Claude:**
   ```
   I don't have a formal PRD/TAD. Please:
   1. Review my README and any existing docs
   2. Ask me questions to understand the product and architecture
   3. Create a basic PRD in docs/PRD.md covering goals, users, features
   4. Create a basic TAD in docs/TAD.md covering architecture and stack
   5. Keep them concise - we can expand later
   ```

4. **Sync everything:**
   ```bash
   bd sync
   git add .beads/ docs/
   git commit -m "chore: migrate to CCPM workflow with BEADS"
   git push
   ```

---

### Scenario 2: Work Tracked in Docs Only

**Your situation:**
- TODOs in CLAUDE.md, README, or other docs
- No GitHub issues
- No BEADS

**Migration steps:**

1. **Extract tasks from docs:**

   **Prompt for Claude:**
   ```
   I have tasks scattered in documentation. Please:
   1. Read my CLAUDE.md, README.md, and docs/ directory
   2. Extract all TODOs, action items, and planned features
   3. Categorize them into epics and tasks
   4. For each epic: create a GitHub issue (label: epic)
   5. For each task: create a GitHub issue (label: task) under the appropriate epic
   6. Show me the breakdown for approval before creating issues
   ```

2. **Initialize BEADS and import:**
   ```bash
   bd init
   ```

   **Prompt for Claude:**
   ```
   Now create BEADS entries for each GitHub issue we just created.
   Set up dependencies based on the epic/task relationships.
   ```

3. **Clean up docs:**

   **Prompt for Claude:**
   ```
   Update CLAUDE.md and README to remove embedded task lists.
   Replace with: "See GitHub issues for current work."
   Keep the project context and instructions.
   ```

4. **Sync:**
   ```bash
   bd sync
   git add .
   git commit -m "chore: migrate task tracking to GitHub issues + BEADS"
   git push
   ```

---

### Scenario 3: Mixed Tracking (Issues + Docs)

**Your situation:**
- Some work in GitHub issues
- Some TODOs in docs
- Unclear what's actually current

**Migration steps:**

1. **Audit current state:**

   **Prompt for Claude:**
   ```
   I have mixed tracking. Please help me audit:
   1. List all open GitHub issues
   2. Scan CLAUDE.md, README, and docs/ for TODOs
   3. Identify duplicates between issues and docs
   4. Identify which tasks/TODOs are still relevant
   5. Show me a reconciliation plan
   ```

2. **Consolidate to GitHub:**

   **Prompt for Claude:**
   ```
   Based on the audit:
   1. Create GitHub issues for any doc-based TODOs that don't have issues
   2. Close or update stale issues
   3. Ensure all current work has a GitHub issue
   4. Label issues appropriately (epic/task)
   ```

3. **Initialize BEADS and import:**
   ```bash
   bd init
   ```

   **Prompt for Claude:**
   ```
   Create BEADS entries for all current GitHub issues.
   Set up dependencies and priorities based on issue relationships.
   ```

4. **Update docs:**

   **Prompt for Claude:**
   ```
   Remove task lists from docs.
   Update CLAUDE.md to reflect the new workflow.
   Keep project context and technical guidance.
   ```

---

### Scenario 4: No Formal Tracking

**Your situation:**
- No GitHub issues
- No documented TODOs
- Work happens ad-hoc
- May have some mental model or notes

**Migration steps:**

1. **Document current understanding:**

   **Prompt for Claude:**
   ```
   I don't have formal tracking. Let's build it from scratch:
   1. Ask me about the project (what it does, goals, status)
   2. Ask what features exist vs what's planned
   3. Ask about known bugs or tech debt
   4. Create a basic PRD capturing this (docs/PRD.md)
   5. Create a basic TAD with current architecture (docs/TAD.md)
   ```

2. **Break down into issues:**

   **Prompt for Claude:**
   ```
   Based on the PRD/TAD we created:
   1. Identify major features/areas (these are epics)
   2. Break down each epic into concrete tasks
   3. Create GitHub issues for all epics and tasks
   4. Show me the breakdown before creating issues
   ```

3. **Initialize BEADS:**
   ```bash
   bd init
   ```

   **Prompt for Claude:**
   ```
   Create BEADS entries for all GitHub issues.
   Set up dependencies and priorities.
   Ask me if you need clarification on relationships.
   ```

4. **Commit the structure:**
   ```bash
   bd sync
   git add .beads/ docs/ CLAUDE.md
   git commit -m "chore: establish CCPM workflow and project tracking"
   git push
   ```

---

## Handling Work in Progress

### If you have uncommitted work:
```bash
git status
git diff  # Review changes
```

**Options:**
1. **Complete and commit current work first**, then migrate
2. **Stash work**, migrate, then reapply:
   ```bash
   git stash
   # ... do migration ...
   git stash pop
   ```
3. **Create issue for current work**, commit as WIP, then migrate:
   ```bash
   git add .
   git commit -m "wip: [description]"
   ```

### If you have open Pull Requests:

**Prompt for Claude:**
```
I have open PRs. Please:
1. List all open PRs (gh pr list)
2. For each PR, ensure there's a corresponding GitHub issue
3. Create BEADS entry for each issue
4. Mark BEADS status as 'in_progress' for PRs under review
5. Leave the PRs alone - we'll merge them normally
```

---

## Creating Minimal PRD/TAD

If you don't have product/technical docs, you need just enough to enable the workflow:

### Minimal PRD Template

**Prompt for Claude:**
```
Help me create a minimal PRD. Ask me:
1. What does this project do? (1-2 sentences)
2. Who is it for?
3. What are the 3-5 main features/capabilities?
4. What's the current status? (prototype, MVP, production, etc.)
5. What are we trying to accomplish next?

Then create docs/PRD.md with this info in a simple structure.
```

### Minimal TAD Template

**Prompt for Claude:**
```
Help me create a minimal TAD. Ask me:
1. What's the tech stack? (language, framework, database)
2. Is it web/mobile/desktop/CLI?
3. Any external services? (auth, storage, APIs)
4. How is it deployed/run?
5. Any important architectural decisions or constraints?

Then create docs/TAD.md with this info in a simple structure.
```

**Remember:** These docs can grow over time. Start minimal, add detail as you work.

---

## Updating CLAUDE.md for Your Project

After migration, customize CLAUDE.md:

1. **Project Overview section:**
   - Replace placeholders with your actual stack
   - Update platform, backend, target audience

2. **Development Guidelines section:**
   - Add your actual framework and tools
   - Document your testing strategy
   - Note any code style rules

3. **Specifications section:**
   - Update with your actual spec file names
   - Remove placeholder specs, add real ones

4. **Remove this migration reference** from CLAUDE.md Step 0 (it's one-time)

---

## Common Migration Issues

### "I have too many old/stale issues"

**Options:**
1. **Bulk close stale issues:**
   ```bash
   # Review first!
   gh issue list --label "needs-triage"
   # Then close with comment
   gh issue close <number> --comment "Closing during migration cleanup"
   ```

2. **Prompt for Claude:**
   ```
   I have many old issues. Help me:
   1. List all issues older than 6 months
   2. Group by relevance (active, stale, unclear)
   3. Generate bulk close commands for confirmed stale issues
   4. Show me the plan before executing
   ```

### "I don't know if issues are epics or tasks"

**Rule of thumb:**
- **Epic:** A feature area or large capability, takes 3+ tasks to complete
- **Task:** A single, concrete piece of work, completable in 1-3 sessions

**Prompt for Claude:**
```
I'm unsure which issues are epics vs tasks. For each issue:
1. Estimate complexity (small/medium/large)
2. Check if it can be broken down further
3. Suggest classification
4. Ask me for confirmation before labeling
```

### "My project structure is different"

**The workflow is flexible:**
- Don't have a `docs/` folder? Put PRD/TAD wherever makes sense
- Update CLAUDE.md to reference the correct paths
- BEADS and GitHub issues work regardless of project structure

### "I don't want to use BEADS, just GitHub issues"

**Totally fine!** You can use just GitHub issues. The workflow still works:
- Skip `bd` commands
- Use `gh issue list`, `gh issue view`, etc.
- Track dependencies in issue descriptions
- Lose: agent memory, rich metadata, offline tracking
- Gain: Simpler workflow, one tool only

To adapt this template for GitHub-only:
1. Remove BEADS references from CLAUDE.md
2. Remove session start/end BEADS sync steps
3. Keep the epic/task model, branch workflow, and session protocols
4. Use issue comments for progress tracking

---

## Migration Checklist

After migration, verify:

- [ ] `.beads/` directory exists and synced to git
- [ ] All current work has GitHub issues
- [ ] Issues labeled as `epic` or `task`
- [ ] BEADS entries created for all issues
- [ ] docs/PRD.md exists (even if minimal)
- [ ] docs/TAD.md exists (even if minimal)
- [ ] CLAUDE.md updated with project specifics
- [ ] README.md references the workflow
- [ ] Session start protocol works (`bd ready`, `/context-prime`)
- [ ] Test starting work on an issue (`/pm-issue-start`)
- [ ] Everything committed and pushed

---

## Getting Help

**If migration fails or you get stuck:**

1. **Check the current state:**
   ```bash
   git status
   bd list
   gh issue list
   ```

2. **Prompt for Claude:**
   ```
   My migration is stuck. Here's the error: [paste error]
   Here's my current state: [describe situation]
   Help me recover and continue.
   ```

3. **Reset if needed:**
   ```bash
   # BEADS reset (destructive!)
   rm -rf .beads/
   bd init

   # Git reset to before migration
   git log  # Find commit before migration
   git reset --hard <commit-hash>
   ```

4. **Ask in the project:** File an issue at the workflow template repo with your situation

---

## After Migration: Next Steps

Once migrated:

1. **Test the workflow:**
   - Start a session (run session start protocol)
   - Pick an issue to work on
   - Make a small change
   - Run session end protocol
   - Verify everything synced

2. **Customize CLAUDE.md:**
   - Add project-specific guidelines
   - Document any special workflows
   - Add links to important resources

3. **Start working:**
   - Use `/pm-dashboard` to see status
   - Use `/pm-issue-start` to begin work
   - Follow the session protocols

4. **Iterate:**
   - Adjust priorities as you go
   - Add specs as needed
   - Refine PRD/TAD with more detail

---

## Philosophy

This migration isn't about perfect tracking - it's about **enabling better collaboration between you and Claude**. Start simple, evolve as you work. The workflow serves the project, not the other way around.
