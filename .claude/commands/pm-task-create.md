---
description: Create a new task issue (discovered during development)
---

# Create New Task

Create a new task that was discovered during development work.

## Usage

The user will provide:
- Task description/title
- Optional: Parent epic number
- Optional: Priority (0-4)
- Optional: Current issue being worked on (for dependency linking)

## Your Task

1. **Parse the user's request:**
   - Extract task title/description
   - Determine parent epic (if provided)
   - Determine priority (default: P2)
   - Determine type (task, bug, enhancement)
   - Determine relevant labels (backend, frontend, database, etc.)

2. **Create GitHub issue:**
   ```bash
   gh issue create \
     --label "task,[other-labels]" \
     --title "Task: [description]" \
     --body "Brief description of the task.

   **Part of:** #[epic-number] (Epic: [name])
   **Discovered during:** #[current-issue] (if applicable)
   **Type:** [task/bug/enhancement]
   **Priority:** P[0-4]

   **Deliverables:**
   - [What needs to be done]
   - [Expected outcomes]

   **Context:**
   [Why this task is needed, what problem it solves]"
   ```

3. **Create BEADS entry:**
   ```bash
   ~/.local/bin/bd create "[description]" \
     -t [task/bug] \
     -p [0-4] \
     -l "[labels]" \
     --notes "GitHub issue #[number]. Discovered during [context]."
   ```

4. **Link dependencies (if applicable):**
   ```bash
   # If this blocks current work
   ~/.local/bin/bd dep add [current-beads-id] [new-beads-id] --type blocks

   # If discovered during current work
   ~/.local/bin/bd dep add [new-beads-id] [current-beads-id] --type discovered-from
   ```

5. **Sync to git:**
   ```bash
   ~/.local/bin/bd sync
   git add .beads/
   git commit -m "chore: add task - [description]

   Created #[number]: [description]
   Discovered during: #[current-issue]

   fixes bd-[id]"
   git push
   ```

6. **Report back:**
   - Show the created issue number
   - Show the BEADS ID
   - Show the GitHub URL
   - Indicate if it blocks current work
   - Suggest next action (continue current work, or switch to new task if blocker)

## Example Usage

**User:** "Create a task to add input validation to the signup form, priority 1, part of epic #1"

**You create:**
- GitHub Issue #7: "Task: Add input validation to signup form"
- BEADS entry: bd-k1l2
- Link to epic #1
- Priority P1
- Labels: task, frontend, validation

**Output:**
```
✓ Created new task:
  GitHub: #7 - Task: Add input validation to signup form
  BEADS: bd-k1l2
  Epic: #1 (User Authentication System)
  Priority: P1
  Labels: task, frontend, validation

  URL: https://github.com/[owner]/[repo]/issues/7

This task is now tracked and ready to be worked on.
```

## Task Types

- **task**: New feature or functionality
- **bug**: Something broken that needs fixing
- **enhancement**: Improvement to existing feature

## Priority Levels

- **P0**: Critical blocker, drop everything
- **P1**: High priority, core functionality
- **P2**: Normal priority (default)
- **P3**: Low priority, nice to have
- **P4**: Backlog, future consideration

## Dependency Scenarios

1. **Discovered during current work** (not blocking):
   - Create task
   - Link as `discovered-from` current issue
   - Continue current work
   - New task available for later

2. **Blocker for current work**:
   - Create task
   - Link as `blocks` current issue
   - Ask user if they want to:
     a) Switch to new task first (unblock current)
     b) Mark current task as blocked, work on something else
     c) Continue anyway (if workaround possible)

3. **Related to epic but independent**:
   - Create task
   - Reference parent epic
   - No dependency links
   - Available in ready queue

Now create the task based on the user's request!
