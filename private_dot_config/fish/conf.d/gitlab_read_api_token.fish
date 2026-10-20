# Load a token with read_api permissions, for reading merge requests and the
# package registry. Writes are not possible with it: creating or editing a merge
# request goes through `md-to-glab-mr`, which uses a separate api-scope token in
# Keychain and previews each apply in an approval dialog.
# Chezmoi's create_private_empty_read-api-token creates a mode-600 placeholder
# only if missing. Set the token locally; future applies preserve it.
if test -r ~/.config/gitlab/read-api-token
    read -l token < ~/.config/gitlab/read-api-token
    if test -n "$token"
        set -gx GITLAB_TOKEN "$token"
    end
end
