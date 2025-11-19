---
description: Display comprehensive project dashboard (epics, tasks, progress, status)
---

# Project Dashboard

Display a comprehensive overview of the entire project status.

## Your Task

1. **Gather all project data:**

   ```bash
   # Get all GitHub epics
   gh issue list --label epic --json number,title,state,labels

   # Get all GitHub tasks
   gh issue list --label task --json number,title,state,labels

   # Get BEADS statistics
   ~/.local/bin/bd stats

   # Get ready work
   ~/.local/bin/bd ready --limit 10

   # Get in-progress work
   ~/.local/bin/bd list --status in_progress

   # Get blocked work
   ~/.local/bin/bd blocked

   # Get open PRs
   gh pr list --json number,title,author,headRefName
   ```

2. **Calculate metrics:**
   - Total epics (open vs closed)
   - Total tasks (open vs closed)
   - Completion percentage per epic
   - Overall project completion
   - Tasks ready to start
   - Tasks in progress (and by whom/which agent)
   - Tasks blocked
   - Open pull requests

3. **Organize by epic:**
   - Group tasks under their parent epics
   - Show completion status for each epic
   - Highlight blocked tasks
   - Show task dependencies

4. **Display dashboard:**

## Example Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    PROJECT DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 OVERALL PROGRESS
  Total Epics:     3 (2 open, 1 closed)
  Total Tasks:     15 (9 open, 6 closed)
  Completion:      40% (6/15 tasks complete)

🎯 CURRENT ACTIVITY
  In Progress:     2 tasks
  Ready to Start:  3 tasks
  Blocked:         4 tasks
  Open PRs:        1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 EPIC #1: User Authentication System [OPEN] 20% (1/5)
├─ ✅ #2: Design authentication database schema (bd-a1b2)
│    PR #7 merged | Completed 2024-01-15
├─ 🔵 #3: Implement user signup API endpoint (bd-c3d4) [IN PROGRESS]
│    Branch: feature/issue-3 | Agent working
├─ ⚪ #4: Implement user login API endpoint (bd-e5f6) [READY]
├─ ⏸️  #5: Implement password reset flow (bd-g7h8) [BLOCKED by #4]
└─ ⏸️  #6: Create authentication UI components (bd-i9j0) [BLOCKED by #3, #4, #5]

📦 EPIC #8: Data Management [OPEN] 60% (3/5)
├─ ✅ #9: Design data models (bd-j1k2)
├─ ✅ #10: Implement CRUD APIs (bd-l3m4)
├─ ✅ #11: Add data validation (bd-n5o6)
├─ 🔵 #12: Implement data export (bd-p7q8) [IN PROGRESS]
└─ ⚪ #13: Add data import (bd-r9s0) [READY]

📦 EPIC #14: Reporting Dashboard [CLOSED] 100% (5/5)
└─ All tasks completed ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 READY TO START (no blockers)
1. #4: Implement user login API endpoint (P1, backend)
2. #13: Add data import (P2, backend)
3. #18: Add error logging (P3, infrastructure)

⚡ IN PROGRESS
1. #3: Implement user signup API endpoint
   └─ Agent: Claude | Branch: feature/issue-3 | 2 hours ago
2. #12: Implement data export
   └─ Agent: Claude | Branch: feature/issue-12 | 30 mins ago

🚫 BLOCKED
1. #5: Implement password reset flow
   └─ Blocked by: #4 (Login API)
2. #6: Create authentication UI components
   └─ Blocked by: #3, #4, #5
3. #17: Integration tests
   └─ Blocked by: #3, #4
4. #19: Performance optimization
   └─ Blocked by: All core features

🔀 OPEN PULL REQUESTS
1. PR #7: feat(auth): database schema ← merged
2. PR #20: feat(data): CRUD APIs [OPEN]
   └─ Closes #10 | 3 files changed | Ready for review

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 RECOMMENDATIONS

Priority actions:
1. Complete #3 (signup API) - blocks 2 other tasks
2. Start #4 (login API) - blocks 2 other tasks
3. Merge PR #20 to close out data management epic

Bottlenecks:
- Epic #1 (Auth) is critical path - 4 tasks blocked
- Consider parallelizing #4 and #3 if possible

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📎 Quick Links
  GitHub Issues: https://github.com/owner/repo/issues
  Pull Requests:  https://github.com/owner/repo/pulls
  Project Board:  https://github.com/owner/repo/projects/1

Last updated: 2024-01-15 14:45
```

## Legend

- ✅ Completed
- 🔵 In Progress
- ⚪ Ready to Start
- ⏸️  Blocked
- 🚫 Blocker

## Additional Features

**If user requests specific epic:**
```bash
/pm:dashboard --epic 1
```
Show detailed view of just that epic with all task details.

**If user requests just stats:**
```bash
/pm:dashboard --summary
```
Show just the top summary section without detailed epic breakdowns.

**If user requests priorities:**
```bash
/pm:dashboard --priorities
```
Show tasks ordered by priority (P0 → P4) instead of by epic.

## Smart Recommendations

Based on current state, suggest:
- Critical path tasks (blocks most other work)
- Quick wins (high-value, low-effort tasks ready to start)
- Parallel work opportunities (tasks that can be done simultaneously)
- Bottlenecks (epics or tasks blocking significant work)
- Stale work (tasks in progress for >24 hours with no updates)

## Data Sources

- **GitHub Issues**: Source of truth for epics and tasks
- **BEADS**: Dependencies, detailed status, agent memory
- **Git**: Branch status, PRs, commits
- **Combined view**: Best of both systems

Now display the project dashboard!
