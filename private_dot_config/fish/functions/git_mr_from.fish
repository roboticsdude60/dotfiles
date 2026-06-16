function git_mr_from -d "create a new MR including the selected commits"

    # prompt the user for the commit hash(s) using fzf
    set -l commit_hashes (git log --oneline | fzf -m --reverse --header="Select commit:" | awk '{print $1}')

    if not test -n "$commit_hashes"
        echo "No commits selected"
        return 1
    end

    # get the branch name from user input
    read -P "branch name: " -c "josephscholl-" branchName

    if not test -n "$branchName"
        echo "Branch name for MR cannot be empty"
        return 2
    end

    # ask to confirm
    # but first print out the commits that will be included
    git --no-pager show --oneline --shortstat $commit_hashes

    read -P "Create $branchName with selected $(count $commit_hashes) commit(s)? (Y/n): " confirmed -n 1

    switch $confirmed
    case Y y ""
        echo git worktree add ../$branchName -b $branchName origin/master
        git worktree add ../$branchName -b $branchName origin/master
        echo pushd ../$branchName
        pushd ../$branchName

        # cherry pick to the new branch
        echo git cherry-pick $commit_hashes
        git cherry-pick $commit_hashes

        # push to remote
        echo git push
        git push

        read -P "finish creating gitlab MR in browser? (Y/n):" create_mr

        switch $create_mr
        case Y y ""
            open "https://gitlab.com/techcyte/techcyte-frontend/-/merge_requests/new?merge_request%5Bsource_branch%5D=$branchName"
        end

        popd
    case n N *
        return
    end
end
