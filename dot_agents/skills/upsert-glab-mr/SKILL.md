---
name: upsert-glab-mr
description: Create or update a GitLab merge request from a markdown file using md-to-glab-mr, including uploading before/after screenshots inline. Use when opening a merge request, updating an existing one's title or description, or adding screenshots to one.
---

Write a markdown file describing the merge request, then run `md-to-glab-mr` on it.
The file is the source of truth: re-running updates the existing merge request to
match, so iterate on the file rather than tracking what you already created.

## The file

Put it **outside the repository** — these are Jujutsu workspaces, and `jj` snapshots
untracked files, so a draft left in the tree gets committed. Use
`~/.local/state/mr-apply/drafts/<branch>.md` and reference screenshots by absolute
path.

```markdown
---
source_branch: feature/sample-sorting
title: Fix sample sorting
---

## What changed

Sorting now respects the collection order.

Before: ![before](/absolute/path/to/project/test-results/before.png)
After:  ![after](/absolute/path/to/project/test-results/after.png)
```

Front matter is plain `key: value` lines, not YAML, and supports four keys.
`source_branch` and `title` are required. `repo` defaults to
the current repository's `origin` remote. `target_branch` defaults to the origin branch at `jj trunk()` **of the directory you run from**, so
run from the repository, or set it explicitly. Any other key is an error. Title and
description become exactly what the file says — nothing is prefixed or rewritten.
A title starting with `Draft:` makes a draft; only do that if the user asks.

## Running it

From the repository:

    md-to-glab-mr ~/.local/state/mr-apply/drafts/my-branch.md --dry-run
    md-to-glab-mr ~/.local/state/mr-apply/drafts/my-branch.md

Always `--dry-run` first. It validates the file, checks with GitLab that both
branches exist and whether it will create or update, and prints the same summary
as a real run, without uploading or writing anything. The real run **opens a dialog the user must approve** — expect a pause, and
if it comes back denied, ask what they want changed instead of re-running.

## Screenshots

Local images in the body are uploaded and their links replaced in the submitted
description. The draft file is never modified. Put before/after shots inline with
labels so they appear where the Markdown puts them.

Playwright writes to `test-results/`. Relative paths resolve against the markdown
file, so prefer absolute ones. Uploads are cached by file **content**, so an
unchanged screenshot is not re-uploaded and a regenerated one is. Only `.png`,
`.jpg`, `.jpeg`, `.gif`, `.webp` and `.svg` up to 20 MiB are accepted, and a
missing or non-image reference fails before anything reaches GitLab. Existing URLs
and `/uploads/` links are left alone.

## What it does not do

- **It cannot push.** The source branch must already be on the remote; `--dry-run`
  fails if it is not. If a push is needed, ask the user to run `jj git push` with
  their SSH key.
- **No assignee, reviewer, label or milestone.** Deliberately out of scope; the user
  sets those in the GitLab UI. Don't ask for them in the file.
- It will not merge, approve, close or delete anything, and it refuses when more than
  one open merge request matches the branch.

## When something is wrong

- `no token in Keychain` — ask the user to run `md-to-glab-mr authorize` in their
  own terminal (it reads from a TTY, so you can't). Never ask for the token in chat,
  and don't try to read it.
- `GitLab returned 409 ...` — an MR exists for that branch but wasn't found as open;
  check `source_branch` matches.
- `cannot resolve a single origin branch for jj trunk()` — set `target_branch`.
- `md-to-glab-mr auth-status` checks token authorization;
  `md-to-glab-mr audit 20` shows what has run.

Reads need no approval: `glab mr list` and `glab mr view` work directly with the
ambient read-only token, so use those to inspect existing merge requests.
