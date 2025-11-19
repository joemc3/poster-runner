---
description: Break down PRD/specs into epics and tasks, creating GitHub issues and BEADS entries
---

# Epic Breakdown - Automated Task Creation

You are being asked to break down the project requirements into actionable epics and tasks.

## Your Task

1. **Read the specifications:**
   - Load and read @docs/PRD.md
   - Load and read @docs/TAD.md
   - Load any relevant spec files from @docs/specs/

2. **Identify epics:**
   - Identify major features or functional areas (3-8 epics typically)
   - Each epic should represent a significant deliverable
   - Examples: "User Authentication", "Data Management", "Reporting Dashboard"

3. **Break down each epic into tasks:**
   - For each epic, identify 3-10 concrete tasks
   - Tasks should be specific, actionable work items
   - Consider dependencies (e.g., "DB schema" must come before "API endpoints")
   - Include both backend and frontend work where applicable

4. **Create GitHub issues:**
   - For each epic, create a GitHub issue with label `epic`
   - For each task, create a GitHub issue with label `task` and appropriate domain labels (backend, frontend, database, etc.)
   - Include in each task issue:
     - Clear title: "Task: [specific action]"
     - Description of deliverables
     - Reference to parent epic: "Part of #N (Epic: Name)"
     - Dependencies: "Depends on #M" if applicable
     - Priority level (P0-P4)

5. **Create BEADS entries:**
   - For each task, create a BEADS entry using `~/.local/bin/bd create`
   - Include the GitHub issue number in the BEADS notes
   - Set appropriate priority and labels

6. **Set up dependencies:**
   - Use `~/.local/bin/bd dep add` to link tasks that have dependencies
   - Use type `blocks` for hard dependencies
   - Ensure no circular dependencies

7. **Commit to git:**
   ```bash
   ~/.local/bin/bd sync
   git add .beads/
   git commit -m "chore: break down project into epics and tasks

   Created N epics:
   - Epic #1: [name]
   - Epic #2: [name]
   ...

   Created M tasks linked to epics"
   git push
   ```

8. **Present the breakdown:**
   - Show a hierarchical view of epics and their tasks
   - Include GitHub issue numbers
   - Include BEADS IDs
   - Highlight which tasks are ready to start (no blockers)
   - Ask user for approval or adjustments

## Example Output Format

```
Project Breakdown Complete!

Epic #1: User Authentication System
  ├─ #2: Task: Design authentication database schema (bd-a1b2) [P1, Ready]
  ├─ #3: Task: Implement user signup API endpoint (bd-c3d4) [P1, Blocked by #2]
  ├─ #4: Task: Implement user login API endpoint (bd-e5f6) [P1, Blocked by #2]
  ├─ #5: Task: Implement password reset flow (bd-g7h8) [P2, Blocked by #2, #4]
  └─ #6: Task: Create authentication UI components (bd-i9j0) [P2, Blocked by #3, #4, #5]

Epic #7: [Next Epic Name]
  └─ ...

Ready to start:
- Issue #2: Design authentication database schema (no blockers)

Total: 3 epics, 15 tasks
GitHub: https://github.com/[owner]/[repo]/issues
```

## Important Notes

- ALWAYS create GitHub issues for BOTH epics and tasks (not just epics)
- ALWAYS create corresponding BEADS entries for tracking
- ALWAYS set up dependencies properly
- ALWAYS commit BEADS state to git
- Task issues should reference their parent epic: "Part of #N"
- Include all necessary labels for filtering (epic, task, backend, frontend, etc.)
- Priority: P0 (critical) → P4 (backlog)
- Ask user before proceeding if the breakdown seems unclear

## Git Commit Message Template

```
chore: break down [Epic Name] into tasks

Created tasks:
- #N: [task name] (bd-xxx)
- #M: [task name] (bd-yyy)

Dependencies:
- #M depends on #N

ref #[epic-number]
```

Now proceed with breaking down the project based on the PRD, TAD, and specs!
