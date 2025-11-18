You are helping migrate an existing project to the CCPM workflow. Guide the user through this interactively.

## Your Task

Follow this step-by-step migration process:

### Step 1: Understand Current State

Ask the user these questions (ask all at once):

1. **Do you have existing GitHub issues?** (yes/no)
2. **Do you have work tracked in docs** (CLAUDE.md, README, TODO files, etc.)? (yes/no)
3. **Do you have a `.beads/` directory already?** (yes/no)
4. **Do you have docs/PRD.md and docs/TAD.md?** (yes/no)
5. **Do you have any work in progress** (uncommitted changes, open PRs)? (yes/no)

Wait for their answers before proceeding.

---

### Step 2: Assess and Plan

Based on their answers, determine the migration scenario:
- **GitHub issues + no BEADS:** Scenario 1
- **Docs only:** Scenario 2
- **Mixed:** Scenario 3
- **Nothing formal:** Scenario 4

Tell the user which scenario they're in and explain the migration plan:
1. What you'll scan/import
2. What you'll create
3. What you'll update
4. What they need to review/approve

Ask: **"Does this plan sound good? Ready to proceed?"**

---

### Step 3: Execute Migration

Based on the scenario, execute these steps:

#### For all scenarios:
1. **Check BEADS installation:**
   ```bash
   export PATH="$PATH:/Users/joemc3/.local/bin"
   ~/.local/bin/bd --version
   ```
   If not installed, tell user to install BEADS first (see main README)

2. **Initialize BEADS if needed:**
   ```bash
   ~/.local/bin/bd init
   ```

#### If they have GitHub issues:
1. **List all open issues:**
   ```bash
   gh issue list --limit 100
   ```

2. **Classify issues:** Review the list and propose which are epics vs tasks. Ask user for confirmation.

3. **Label issues:**
   ```bash
   gh issue edit <number> --add-label "epic"
   gh issue edit <number> --add-label "task"
   ```

4. **Create BEADS entries:** For each issue:
   ```bash
   ~/.local/bin/bd create "<issue title>" -t task/epic -p <priority 0-4>
   # Note the BEADS ID created
   ```

5. **Set up dependencies:** Ask user about relationships between issues, then:
   ```bash
   ~/.local/bin/bd dep add <child-id> <parent-id> --type parent-child
   ```

6. **Update issue descriptions:** Add BEADS ID reference to each GitHub issue:
   ```bash
   gh issue comment <number> --body "🔗 Tracked in BEADS: bd-<id>"
   ```

#### If they have work in docs only:
1. **Scan documentation:**
   ```bash
   # Read these files to find TODOs and tasks
   cat CLAUDE.md README.md
   ```
   Also read any files in docs/ directory

2. **Extract and categorize:** Show user the tasks/TODOs you found, grouped as potential epics and tasks

3. **Get approval:** Show proposed GitHub issues to create. Ask: **"Should I create these issues?"**

4. **Create GitHub issues:**
   ```bash
   gh issue create --title "Epic: <name>" --label "epic" --body "<description>"
   gh issue create --title "Task: <name>" --label "task" --body "<description> Part of #<epic-number>"
   ```

5. **Create BEADS entries:** Same as above scenario

6. **Clean up docs:** Remove task lists from CLAUDE.md/README, replace with note: "See GitHub issues for current work"

#### If they have mixed tracking:
1. Do both scans (GitHub issues + docs)
2. Show reconciliation: identify duplicates, conflicts, stale items
3. Ask user to clarify what's current
4. Proceed with consolidation to GitHub + BEADS

#### If they have nothing formal:
1. **Interview user:** Ask about:
   - What does the project do?
   - What features exist vs planned?
   - Known bugs or tech debt?
   - Technology stack?
   - Deployment/architecture?

2. **Create basic PRD:**
   Write a minimal docs/PRD.md based on their answers

3. **Create basic TAD:**
   Write a minimal docs/TAD.md based on their answers

4. **Break down into epics and tasks:**
   Based on PRD/TAD, propose epics and tasks. Get approval.

5. **Create issues and BEADS entries:**
   Same as above scenarios

---

### Step 4: Handle Work in Progress

If they have uncommitted changes or open PRs:

**For uncommitted changes:**
1. Show `git status`
2. Offer options:
   - Commit as WIP now
   - Stash during migration
   - Complete work first
3. Execute their choice

**For open PRs:**
1. List them: `gh pr list`
2. Ensure each has a GitHub issue
3. Create BEADS entries for those issues
4. Mark BEADS status as `in_progress`

---

### Step 5: Sync and Verify

1. **Sync BEADS:**
   ```bash
   ~/.local/bin/bd sync
   ```

2. **Show results:**
   ```bash
   ~/.local/bin/bd stats
   ~/.local/bin/bd ready --limit 5
   gh issue list --label epic
   gh issue list --label task
   ```

3. **Commit migration:**
   ```bash
   git add .beads/ docs/
   git commit -m "chore: migrate to CCPM workflow

   - Initialized BEADS tracking
   - Created/imported GitHub issues
   - Set up project documentation
   - Established epic and task structure"
   ```

4. **Show user the mapping:** Display table of:
   - GitHub Issue # → BEADS ID
   - Epic → Child Tasks
   - Current priorities

---

### Step 6: Update Project Files

1. **Update CLAUDE.md:**
   - Fill in placeholders (platform, stack, etc.) based on what you learned
   - Update specs list with actual files
   - Customize guidelines section
   - Ask user for any missing info

2. **Update README.md:**
   - Ensure it mentions the workflow
   - Add link to MIGRATION.md
   - Update project description if needed

3. **Commit updates:**
   ```bash
   git add CLAUDE.md README.md
   git commit -m "docs: customize workflow for project"
   ```

---

### Step 7: Test and Finish

1. **Test the workflow:**
   ```bash
   # Session start protocol
   export PATH="$PATH:/Users/joemc3/.local/bin"
   ~/.local/bin/bd sync
   ~/.local/bin/bd ready --limit 5
   ```

2. **Show dashboard:**
   ```bash
   /pm-dashboard
   ```

3. **Provide next steps:**
   - "Migration complete! ✅"
   - Show available work
   - Suggest starting with highest priority task
   - Remind about session start/end protocols

4. **Push everything:**
   ```bash
   git push
   ```

---

## Important Guidelines

- **Ask before executing destructive actions** (creating many issues, labeling, closing issues)
- **Show what you'll do before doing it** when working with GitHub issues
- **If user is unsure about something,** refer them to MIGRATION.md scenarios
- **If BEADS commands fail,** check that PATH is set and bd is installed
- **Keep commits logical:** separate migration structure from documentation updates
- **Validate at each step:** Don't proceed if something fails

---

## Remember

Migration is about **enabling the workflow**, not perfection. If user wants to keep things minimal (fewer docs, simpler tracking), that's fine. The core requirement is:
1. Work has GitHub issues
2. BEADS tracks those issues
3. Session protocols can function

Everything else can evolve over time.
