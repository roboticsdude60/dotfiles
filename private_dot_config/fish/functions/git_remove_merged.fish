
function git_remove_merged -d "remove worktrees/branches that have been merged into master"
    git fetch --prune
    set --local merged_branches (git branch --merged master --format '%(refname:short)' | grep -vE '^\*|master|main' )
    for branch in $merged_branches
        if test -d (git worktree list | grep $branch)
            git worktree remove $branch
        end
        git branch -d $branch
    end

    git branch --merged master --format '%(refname:short)' | grep -vE '^\*|master|main'
end
