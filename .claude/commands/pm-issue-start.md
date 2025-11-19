---
description: Start work on a GitHub issue (creates feature branch and worktree)
---

# Start Work on Issue

Begin work on a specific GitHub issue by creating a feature branch and git worktree.

## Usage

User provides: Issue number (e.g., `/pm:issue-start 2`)

## Your Task

1. **Fetch and validate the issue:**
   ```bash
   gh issue view <number> --json title,number,labels,body
   ```
   - Verify issue exists
   - Check if it's already closed
   - Get issue title for branch naming

2. **Find corresponding BEADS entry:**
   ```bash
   ~/.local/bin/bd list | grep "#<number>"
   # Or search notes for the GitHub issue number
   ```

3. **Create feature branch:**
   ```bash
   # Sanitize issue title for branch name (lowercase, replace spaces with -, remove special chars)
   BRANCH_NAME="feature/issue-<number>-<sanitized-title>"

   git checkout -b "$BRANCH_NAME"
   ```

4. **Create git worktree (optional but recommended):**
   ```bash
   # Create worktree in parent directory
   WORKTREE_PATH="../issue-<number>-<sanitized-name>"

   git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

   # Change to worktree directory
   cd "$WORKTREE_PATH"
   ```

5. **Update BEADS status:**
   ```bash
   ~/.local/bin/bd update <beads-id> --status in_progress --notes "Started work in branch $BRANCH_NAME"
   ```

6. **Post comment to GitHub issue:**
   ```bash
   gh issue comment <number> --body "🚀 **Started Work**

   Agent started working on this issue.
   Branch: \`$BRANCH_NAME\`
   Started: $(date)

   🤖 Claude Code"
   ```

7. **Sync BEADS:**
   ```bash
   ~/.local/bin/bd sync
   git add .beads/
   git commit -m "chore: start work on issue #<number>

   ref bd-<id>"
   git push -u origin "$BRANCH_NAME"
   ```

8. **Display context to user:**
   - Show issue title and number
   - Show GitHub issue body (for context)
   - Show branch name
   - Show worktree path (if created)
   - Show BEADS ID and dependencies
   - Show current directory
   - List any blockers or dependencies

## Example Output

```
✓ Started work on Issue #2

Issue: Task: Design authentication database schema
GitHub: https://github.com/owner/repo/issues/2

Branch created: feature/issue-2-design-auth-schema
Worktree created: /Users/joemc3/tmp/issue-2-design-auth-schema
Current directory: /Users/joemc3/tmp/issue-2-design-auth-schema

BEADS: bd-a1b2 (status: in_progress)
Dependencies: None (ready to work!)
Blocks: 4 other tasks (#3, #4, #5, #6)

Issue Description:
---
Design and implement database schema for users, sessions, and password resets.

Deliverables:
- User table (id, email, password_hash, created_at, updated_at)
- Session table (id, user_id, token, expires_at)
- Password reset table (id, user_id, token, expires_at)
- Database migration files
- Indexes for performance
---

Ready to work! What would you like to do first?
```

## Error Handling

**If issue doesn't exist:**
```
❌ Error: Issue #<number> not found
Please check the issue number and try again.

Available issues:
[show ready work with: bd ready --limit 5]
```

**If issue is already closed:**
```
⚠️  Issue #<number> is already closed
Do you want to:
1. Reopen this issue
2. Work on a different issue

Available issues:
[show ready work]
```

**If already in worktree:**
```
⚠️  You're already in a worktree for issue #<current>
Do you want to:
1. Finish current work first (recommended)
2. Switch to issue #<new> (will leave current work in progress)
3. Work on both in parallel (advanced - creates second worktree)
```

**If BEADS entry not found:**
```
⚠️  No BEADS entry found for issue #<number>
This might be a manually created GitHub issue.

Would you like to:
1. Create a BEADS entry for tracking
2. Continue without BEADS tracking (GitHub only)
```

## Branch Naming Convention

`feature/issue-<number>-<sanitized-title>`

Examples:
- `feature/issue-2-design-auth-schema`
- `feature/issue-7-implement-signup-api`
- `feature/issue-15-add-password-validation`

## Worktree Benefits

- No branch switching needed
- Multiple agents can work in parallel on different issues
- Each issue has isolated workspace
- Can switch between issues by changing directories
- Prevents merge conflicts from accidental work on wrong branch

## After Starting

You should now:
1. Review the issue description and deliverables
2. Check any linked specs or documentation
3. Ask user what specific part to start with
4. Begin implementation
5. Periodically run `/pm:issue-sync <number>` to update GitHub

Now start work on the issue!
