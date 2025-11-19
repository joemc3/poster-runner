---
description: Quick project status summary (concise version of dashboard)
---

# Quick Project Status

Display a concise project status overview - faster than full dashboard.

## Your Task

1. **Gather essential data:**

   ```bash
   # Get task counts by status
   gh issue list --label task --state open --json state | wc -l
   gh issue list --label task --state closed --json state | wc -l

   # Get in-progress and ready work
   ~/.local/bin/bd list --status in_progress
   ~/.local/bin/bd ready --limit 3

   # Get blocked tasks
   ~/.local/bin/bd blocked

   # Get current branch (if in worktree)
   git branch --show-current
   ```

2. **Calculate key metrics:**
   - Overall completion percentage
   - Tasks in progress count
   - Tasks ready to start count
   - Tasks blocked count

3. **Display concise status:**

## Example Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        PROJECT STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Progress: 40% (6/15 tasks complete)

⚡ In Progress: 2
  #3: Implement user signup API
  #12: Implement data export

🎯 Ready: 3
  #4: Implement user login API (P1)
  #13: Add data import (P2)
  #18: Add error logging (P3)

🚫 Blocked: 4 tasks

🔀 Open PRs: 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Next: Work on #4 (high priority, unblocks 2 tasks)

For detailed view: /pm:dashboard
```

## Current Context (if in worktree)

If the agent is currently in a worktree working on an issue, show additional context:

```
📍 Currently Working On
  Issue: #3 - Implement user signup API
  Branch: feature/issue-3-signup-api
  Status: In progress (2 hours)
  Last sync: 1 hour ago

  💡 Consider running: /pm:issue-sync 3
```

## Color/Emoji Legend

- 📊 Metrics
- ⚡ In Progress
- 🎯 Ready
- 🚫 Blocked
- 🔀 Pull Requests
- 📍 Current Context
- 💡 Suggestion

## When to Use This vs Dashboard

**Use /pm:status when:**
- Quick check-in at session start
- Want to know what to work on next
- Checking if anything is blocked
- Fast status update

**Use /pm:dashboard when:**
- Need full epic breakdown
- Planning next sprint
- Reviewing entire project
- Presenting to stakeholders
- Need detailed dependency view

## Next Action Suggestions

Based on current state, suggest ONE specific next action:

**Examples:**
- "Next: Complete #3 (signup API) - 80% done, blocks 3 tasks"
- "Next: Start #4 (login API) - high priority, ready to work"
- "Next: Review PR #20 - data management epic almost complete"
- "Next: Unblock #5 - resolve dependency on #4"
- "Warning: #3 in progress for 24 hours with no update - check status"

## Abbreviated Format (optional)

If user wants even more concise, provide one-liner:

```
Status: 40% | In Progress: 2 | Ready: 3 | Blocked: 4 | Next: #4
```

Now display the quick project status!
