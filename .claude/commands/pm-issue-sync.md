---
description: Sync current progress to GitHub issue (posts status update comment)
---

# Sync Progress to GitHub

Post a progress update comment to the GitHub issue you're working on.

## Usage

User provides: Issue number (e.g., `/pm:issue-sync 2`)

## Your Task

1. **Gather current state:**
   ```bash
   # Get BEADS status
   ~/.local/bin/bd show <beads-id>

   # Get recent commits on current branch
   git log --oneline -5

   # Get current diff (what's changed)
   git status
   git diff --stat
   ```

2. **Determine what to report:**
   - What has been completed since last update
   - What files were changed/created
   - Current state of the work
   - What's left to do
   - Any blockers or issues discovered
   - Estimated completion (if applicable)

3. **Check for discovered issues:**
   ```bash
   # Check if any new tasks were created during this work
   ~/.local/bin/bd list --status pending | grep "discovered-from.*<current-beads-id>"
   ```

4. **Generate progress summary:**
   - Be specific and concrete
   - Mention actual files and changes
   - Highlight any important decisions or discoveries
   - List any new tasks that were created
   - Include next steps

5. **Post to GitHub:**
   ```bash
   gh issue comment <number> --body "**Progress Update** - $(date +'%Y-%m-%d %H:%M')

   ## Completed This Session
   - [Specific accomplishment 1]
   - [Specific accomplishment 2]
   - [Specific accomplishment 3]

   ## Files Changed
   \`\`\`
   [output of git diff --stat or list of key files]
   \`\`\`

   ## Current State
   [Brief description of current state - e.g., \"Database schema complete, migrations tested\"]

   ## Next Steps
   - [ ] [What needs to be done next]
   - [ ] [Additional work items]

   ## Blockers/Issues
   [Any blockers discovered, or \"None\" if clear]

   ## Discovered Tasks
   [List any new tasks created: \"Created #N: description\" or \"None\"]

   ---
   🤖 Claude Code Agent | Branch: \`$(git branch --show-current)\`"
   ```

6. **Update BEADS notes:**
   ```bash
   ~/.local/bin/bd update <beads-id> --notes "Synced to GitHub. Progress: [summary]. Last sync: $(date)"
   ```

7. **Sync BEADS to git:**
   ```bash
   ~/.local/bin/bd sync
   git add .beads/
   git commit -m "chore: sync progress on issue #<number>

   ref bd-<id>"
   git push
   ```

8. **Confirm to user:**
   - Show that sync was successful
   - Display the comment that was posted
   - Show GitHub issue URL

## Example Output

```
✓ Synced progress to GitHub Issue #2

Posted comment:
---
**Progress Update** - 2024-01-15 14:30

## Completed This Session
- Created users table schema with email, password_hash, timestamps
- Added sessions table for JWT token tracking
- Implemented password_resets table for reset flow
- Added database indexes on email and token fields
- Created migration files in db/migrations/

## Files Changed
```
 db/migrations/001_create_users.sql       | 15 ++++++
 db/migrations/002_create_sessions.sql    | 12 +++++
 db/migrations/003_create_resets.sql      | 11 +++++
 3 files changed, 38 insertions(+)
```

## Current State
Database schema design complete. All tables created with proper relationships and indexes. Migration files ready for testing.

## Next Steps
- [ ] Test migrations on local database
- [ ] Run schema validation
- [ ] Document schema in TAD
- [ ] Ready for code review

## Blockers/Issues
None

## Discovered Tasks
None
---

GitHub: https://github.com/owner/repo/issues/2#issuecomment-xxxxx
```

## When to Sync

Sync progress when:
- ✅ Completing a significant milestone (e.g., finished one deliverable of several)
- ✅ Before taking a break or ending session
- ✅ After discovering new tasks or blockers
- ✅ When making important technical decisions
- ✅ Every 1-2 hours for long-running work
- ✅ When user explicitly asks

Don't sync:
- ❌ After every tiny change
- ❌ Multiple times with no real progress
- ❌ For minor typo fixes or formatting

## Smart Summaries

**Good summary:**
```
Completed database schema design:
- Created users table with bcrypt password hashing support
- Added sessions table with 24-hour expiration
- Implemented password reset tokens with 1-hour expiry
- Files: db/migrations/001-003_*.sql
```

**Bad summary:**
```
Made some changes to the database stuff. Still working on it.
```

## Handling Different Scenarios

**Almost done:**
```
## Current State
~90% complete. Schema design and migrations done. Just need final validation and documentation.

## Next Steps
- [ ] Test migrations
- [ ] Document schema
- [ ] Ready for completion
```

**Blocked:**
```
## Current State
Blocked on database driver installation issue.

## Blockers/Issues
❌ PostgreSQL driver failing to install on M1 Mac
Created #15: Fix PostgreSQL driver installation on M1
Need to resolve before continuing.

## Next Steps
- [ ] Resolve driver issue (#15)
- [ ] Resume schema testing
```

**Discovered new work:**
```
## Discovered Tasks
- Created #16: Add database migration rollback scripts
- Created #17: Implement database seeding for development

These are nice-to-haves, not blockers for current work.
```

Now sync your progress to GitHub!
