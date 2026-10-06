function _jj_prompt_fetch --description 'Fetch jj prompt info asynchronously'
    set --local var_name $argv[1]

    # One jj call snapshots @, its nearest first-parent bookmark, and changes after it.
    set --local details (jj log --quiet --no-graph --color always -r '(@ | heads(bookmarks() & first_ancestors(@)) | (((bookmarks() & first_ancestors(@))::@ ~ ::heads(bookmarks() & first_ancestors(@))) & first_ancestors(@)))' -T 'if(current_working_copy, "W|" ++ change_id.shortest(4) ++ "|" ++ parents.map(|p| p.change_id().shortest(4)).join(",") ++ "|" ++ if(conflict, "conflict", "") ++ " " ++ if(empty, "empty", "") ++ " " ++ if(divergent, "divergent", "") ++ " " ++ if(hidden, "hidden", "") ++ "|" ++ self.diff().stat().total_added() ++ "|" ++ self.diff().stat().total_removed() ++ "|" ++ description.first_line() ++ "\n", "") ++ if(local_bookmarks, "B|" ++ local_bookmarks.first().name() ++ "|" ++ commit_id ++ "|" ++ if(current_working_copy, "at", "after") ++ "\n", "") ++ if(!local_bookmarks, "D\n", "")' 2>/dev/null)
    set --local jj_info
    set --local bookmark_name
    set --local bookmark_target
    set --local bookmark_relation
    set --local distance 0
    for line in $details
        set --local fields (string split -m 6 '|' -- $line)
        switch $fields[1]
            case W
                set jj_info $fields[2..7]
            case B
                # jj colors refs and commit IDs too; these are lookup keys.
                set bookmark_name (string replace -ra '\x1b\[[0-9;]*m' '' -- $fields[2])
                set bookmark_target (string replace -ra '\x1b\[[0-9;]*m' '' -- $fields[3])
                set bookmark_relation $fields[4]
            case D
                set distance (math $distance + 1)
        end
    end
    if test (count $jj_info) -lt 6
        set --universal $var_name ""
        return
    end

    set --local magenta (set_color --bold magenta)
    set --local normal (set_color normal)
    set --local left "$magenta@$jj_info[1]$normal"
    if test $jj_info[4] -gt 0; or test $jj_info[5] -gt 0
        set --local added_color (set_color brblack)
        set --local removed_color (set_color brblack)
        test $jj_info[4] -gt 0; and set added_color (set_color brgreen)
        test $jj_info[5] -gt 0; and set removed_color (set_color --dim red)
        set left "$left $added_color+$jj_info[4]$normal$removed_color−$jj_info[5]$normal"
    end
    if test -n "$jj_info[2]"
        set left "$left [$jj_info[2]]"
    end

    set --local right
    if test -n "$bookmark_name"
        set --local bookmark_display "$bookmark_name"
        set --local remote_status (_jj_prompt_remote_status $bookmark_name $bookmark_target)
        if test "$bookmark_relation" = at
            set right "at $magenta$bookmark_display$normal"
        else if test $distance -gt 0
            set right "$distance after $magenta$bookmark_display$normal"
        else
            set right "after $magenta$bookmark_display$normal"
        end
        if test -n "$remote_status"
            set right "$right $magenta$remote_status$normal"
        end
    end

    set --local flags (string trim -- (string replace -ra '\s+' ' ' -- $jj_info[3]))
    if test -n "$flags"
        set left "$left ("(string replace -a ' ' ') (' -- $flags)")"
    end

    set --local description
    if test -n "$jj_info[6]"
        set description (string replace -a \t ' ' -- $jj_info[6])
    else
        set description '(no description)'
    end

    set --universal $var_name "$left"\t"$description"\t"$right"
end
