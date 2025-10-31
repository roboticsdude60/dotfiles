#!/usr/bin/env fish

function git_clone_for_worktrees --description "Clone with worktrees setup for convenience"
    argparse 'h/help' -- $argv
    or return

    if set -q _flag_help
        echo "Usage: git_clone_for_worktrees <repository_url>"
        echo ""
        echo "Clone a git repository as a bare repository and set up for worktrees."
        echo ""
        echo "Arguments:"
        echo "  repository_url    Git repository URL (e.g., git@gitlab.com:user/repo.git)"
        echo ""
        echo "This function:"
        echo "  1) Clones the bare repository into a hidden .bare subdirectory"
        echo "  2) Sets up a bit of configuration so that git and other tools know where to find things"
        echo "  3) Creates your first worktree for the primary branch (main/master)"
        return 0
    end

    if test (count $argv) -lt 1
        echo "Error: Expected at least one argument (repository URL)" >&2
        echo "Use --help for usage information" >&2
        return 1
    end

    set repo_url $argv[1]
    set clone_args $argv[2..-1]

    # Extract repository name from URL
    set folder_name (basename $repo_url)

    # Clone bare repository into a hidden .bare subdirectory
    echo "Cloning bare repository..."
    git clone --bare $clone_args $repo_url $folder_name/.bare
    or return 1

    # Step 3: Create .git file pointing to bare repository
    cd $folder_name
    echo "Setting up .git file to point to the bare repository..."
    echo "gitdir: ./.bare" > .git

    # Step 4: Configure remote fetch refspec
    echo "Configuring remote fetch..."
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    or return 1

    # Fetch from origin
    echo "Fetching from origin..."
    git fetch
    or return 1
    # And create worktree for primary branch
    echo "Setting up worktree for the primary branch..."
    # Try to determine the primary branch (main or master)
    set primary_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    if test -z "$primary_branch"
        # If HEAD reference isn't set, try common primary branch names
        if git show-ref --verify --quiet refs/remotes/origin/main
            set primary_branch main
        else if git show-ref --verify --quiet refs/remotes/origin/master
            set primary_branch master
        else
            echo "Error: Could not determine primary branch" >&2
            return 1
        end
    end

    echo "Creating worktree for branch $primary_branch"
    git worktree add $primary_branch origin/$primary_branch
    or return 1

    echo "Successfully set up a hidden .bare repository with worktrees available at: "(pwd)
end

# See also
# - https://git-scm.com/docs/git-clone#Documentation/git-clone.txt---bare
# - https://morgan.cugerone.com/blog/how-to-use-git-worktree-and-in-a-clean-way/
# - https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/
