function zed_open_worktree -d "Open a git worktree in Zed editor"
    if test (count $argv) -eq 0
        echo "Usage: zed_open_worktree <worktree-path>"
        echo "Available worktrees:"
        git worktree list
        return 1
    end

    zed $argv[1]
end