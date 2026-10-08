---
name: configure-gitlab-fetch
description: Configure a local GitLab repository for automated HTTPS fetches with the existing read-only token and SSH pushes. Use when setting up a newly cloned repo or fixing its fetch/push authentication setup.
---

Configure the requested repository's `origin` to fetch over HTTPS and push over
SSH. Change only its local Git configuration; preserve unrelated settings.

- Inspect the existing fetch and push URLs. Preserve the GitLab host and project
  path, and any existing explicit SSH push URL. If none exists, preserve the
  current SSH fetch URL as the push URL or derive the equivalent SSH URL from
  the HTTPS URL. Set the push URL before changing the fetch URL.
- The global credential helper for `https://gitlab.com` already uses
  `GITLAB_FETCH_TOKEN`. Shell startup loads it from
  `~/.config/gitlab/fetch-token`. Reuse this setup; do not replace global helpers
  or use `GITLAB_TOKEN`, which serves a separate API/package purpose.
- Never print the token or put it in a URL, Git config, or committed file. If the
  variable is missing, load the private file into the process environment without
  displaying it. If the token is missing or empty, report that setup is needed.
- Resolve SSH host aliases before constructing an HTTPS URL. If the host is not
  `gitlab.com`, explain that the existing helper does not cover it; do not send
  the token to another host or expand global configuration automatically.
- Verify with `git ls-remote origin HEAD` and report the fetch/push URLs and
  whether read access succeeded. Do not push or unlock push credentials.

Current Jujutsu uses the same Git remotes and credential helper, so this also
configures `jj git fetch`. Linked worktrees normally share remote settings;
mention that when applicable.
