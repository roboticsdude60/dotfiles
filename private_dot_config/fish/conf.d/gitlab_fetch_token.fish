# Load a token with read_repository permissions for agentic/automated Git fetches.
# HTTPS fetches need a Git credential helper, configured globally or per repo.
# Chezmoi's create_private_empty_fetch-token creates a mode-600 placeholder only
# if missing. Set the token locally; future applies preserve it.
if test -r ~/.config/gitlab/fetch-token
    read -l token < ~/.config/gitlab/fetch-token
    if test -n "$token"
        set -gx GITLAB_FETCH_TOKEN "$token"
    end
end
