function cd_worktree -d "Change to a git worktree directory"
    if test (count $argv) -eq 0
        echo "Usage: cd_worktree <worktree-path>"
        echo "Available worktrees:"
        git worktree list
        return 1
    end

    cd $argv[1]
end
