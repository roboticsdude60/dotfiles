To install and configure the system, run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply roboticsdude60
```

## GitLab authentication

GitLab fetches and API reads use separate read-only tokens. Pushes use my existing
passphrase-protected SSH key.

| Token | Scope | Storage | Used by |
| --- | --- | --- | --- |
| Fetch | `read_repository` | `~/.config/gitlab/fetch-token` | `git`/`jj` HTTPS fetches |
| Read | `read_api` | `~/.config/gitlab/read-api-token` | `glab` reads and package registry access |

Chezmoi creates the token directory with mode `700` and missing token files with
mode `600`. Set the file contents locally; future applies preserve them. Both fish
and zsh export the fetch token as `GITLAB_FETCH_TOKEN` and the read token as
`GITLAB_TOKEN`.

### Fetching and pushing

The GitLab HTTPS credential helper supplies `oauth2` and `GITLAB_FETCH_TOKEN`.
Its empty `helper =` entry clears earlier helpers so fetches use the read-only
token instead of saved Keychain credentials. SSH pushes use the existing SSH key.

To configure a newly cloned repo, use `$configure-gitlab-fetch` in Codex or
`/configure-gitlab-fetch` in Claude Code. Chezmoi manages this shared personal
skill in `~/.agents/skills`, with a symlink in `~/.claude/skills`.
