to install & configure the system run `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply roboticsdude60`

## GitLab authentication

I want agentic/automated Git fetches from gitlab to work without giving agents push access. We can do this by use HTTPS with a GitLab token scoped to **`read_repository`** for fetch. 
Pushes should use my existing passphrase-protected SSH key.

- **Token file:** chezmoi stubs out `~/.config/gitlab/fetch-token` with mode `600`. Put the `read_repository` token there locally. Future chezmoi applies should preserve the token.
- Export the contents of this file as `GITLAB_FETCH_TOKEN`. 
- **Git helper:** when Git needs a username and password for GitLab HTTPS, it
  runs a small command that supplies `oauth2` and `GITLAB_FETCH_TOKEN` instead of
  prompting you. The empty `helper =` entry prevents earlier helpers from using
  saved Keychain credentials. This works for both `git fetch` and `jj git fetch`;
  SSH pushes still use your SSH key.

To configure a newly cloned repo, use `$configure-gitlab-fetch` in Codex or
`/configure-gitlab-fetch` in Claude Code. Chezmoi manages this shared personal
skill in `~/.agents/skills`, with a symlink in `~/.claude/skills`.
