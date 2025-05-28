function __fish_git_worktree_paths
    set current_dir (pwd)
    git worktree list --porcelain 2>/dev/null | grep "^worktree " | sed 's/^worktree //' | while read -l path
        # Convert absolute path to relative path manually
        if string match -q "$current_dir/*" "$path"
            # Path is under current directory
            string replace "$current_dir/" "" "$path"
        else
            # Get common parent and build relative path
            set parent_dir (dirname "$current_dir")
            if string match -q "$parent_dir/*" "$path"
                echo "../"(basename "$path")
            else
                echo "$path"
            end
        end
    end
end