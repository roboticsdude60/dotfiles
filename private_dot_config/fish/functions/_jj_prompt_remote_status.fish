function _jj_prompt_remote_status --description 'Compare local and remote bookmark change IDs' --argument-names bookmark_name local_target
    set --local refs (jj bookmark list --ignore-working-copy --all-remotes "exact:$bookmark_name" -T 'name ++ "|" ++ if(remote, remote, "") ++ "|" ++ if(self.normal_target(), self.normal_target().commit_id(), "") ++ "|" ++ if(tracked, "tracked", "") ++ "\n"' 2>/dev/null)
    set --local remote_target

    for ref in $refs
        set --local fields (string split '|' -- $ref)
        if test "$fields[1]" != "$bookmark_name"
            continue
        end
        if test "$fields[4]" = tracked; and test "$fields[2]" != git
            # Prefer origin if the bookmark tracks multiple real remotes.
            if test -z "$remote_target"; or test "$fields[2]" = origin
                set remote_target $fields[3]
            end
        end
    end

    if test -z "$local_target"; or test -z "$remote_target"; or test "$local_target" = "$remote_target"
        return
    end

    # Exclude trunk so rebasing a bookmark onto newer trunk does not count
    # trunk's changes as new local changes. Compare IDs, not commit hashes.
    set --local local_rev "trunk()..commit_id($local_target)"
    set --local remote_rev "trunk()..commit_id($remote_target)"
    set --local template 'change_id ++ "|" ++ if(self.contained_in("@LOCAL@"), "L", "") ++ if(self.contained_in("@REMOTE@"), "R", "") ++ "\n"'
    set template (string replace -a '@LOCAL@' $local_rev -- $template | string replace -a '@REMOTE@' $remote_rev)
    set --local changes (jj log --ignore-working-copy --quiet --no-graph -r "$local_rev | $remote_rev" -T "$template" 2>/dev/null)
    or return

    set --local local_ids
    set --local remote_ids
    for change in $changes
        set --local fields (string split '|' -- $change)
        if string match -q '*L*' -- $fields[2]; and not contains -- $fields[1] $local_ids
            set --append local_ids $fields[1]
        end
        if string match -q '*R*' -- $fields[2]; and not contains -- $fields[1] $remote_ids
            set --append remote_ids $fields[1]
        end
    end

    set --local local_only 0
    set --local remote_only 0
    for id in $local_ids
        contains -- $id $remote_ids; or set local_only (math $local_only + 1)
    end
    for id in $remote_ids
        contains -- $id $local_ids; or set remote_only (math $remote_only + 1)
    end

    test $local_only -gt 0; and printf '↑%s' $local_only
    test $remote_only -gt 0; and printf '↓%s' $remote_only
    test $local_only -eq 0; and test $remote_only -eq 0; and printf '*'
end
