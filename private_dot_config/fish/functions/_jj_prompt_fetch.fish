function _jj_prompt_fetch --description 'Fetch jj prompt info asynchronously'
    set --local var_name $argv[1]
    
    # Make a single jj call to get all info separated by newlines
    set jj_info (jj log --quiet --no-graph -r @ -T 'change_id.shortest() ++ "\n" ++ bookmarks.map(|bookmark| bookmark.name() ++ "|" ++ if(bookmark.synced(), "synced", "unsynced")).join(", ") ++ "\n" ++ description.first_line() ++ "\n" ++ if(conflict, "conflict", "") ++ " " ++ if(empty, "empty", "") ++ " " ++ if(divergent, "divergent", "") ++ " " ++ if(hidden, "hidden", "")' 2>/dev/null)
    
    test -z "$jj_info" && set --universal $var_name "" && exit
    
    # Access list elements directly
    set change_id_raw $jj_info[1]
    set bookmark_raw $jj_info[2]
    set description_raw $jj_info[3]
    set flags_raw (string trim $jj_info[4])
    
    # Build prompt_part1 with colors
    set change_id "["(set_color --bold magenta)$change_id_raw(set_color normal)"]"" "
    
    # Handle bookmarks or description
    if test -n "$bookmark_raw"
        # Process bookmark names to get just the last part after slashes
        set bookmark_parts (string split ", " $bookmark_raw)
        set short_bookmarks
        
        # Set max length based on count
        set bookmark_count (count $bookmark_parts)
        if test $bookmark_count -le 1
            set max_len 24
        else
            set max_len 12
        end
        
        for bookmark in $bookmark_parts
            # Split name and synced status
            set bookmark_info (string split "|" $bookmark)
            set bookmark_name $bookmark_info[1]
            set bookmark_synced $bookmark_info[2]
            
            set bookmark_base (path basename $bookmark_name)
            
            # Truncate if needed
            if test (string length $bookmark_base) -gt $max_len
                set bookmark_base (string sub -l (math $max_len - 1) $bookmark_base)"…"
            end
            
            # Add * if not synced
            if test "$bookmark_synced" = "unsynced"
                set bookmark_base $bookmark_base"*"
            end
            
            set short_bookmarks $short_bookmarks $bookmark_base
        end
        set info_part (set_color magenta)(string join ", " $short_bookmarks)(set_color normal)" "
    else if test -n "$description_raw"
        # Truncate description if needed
        if test (string length $description_raw) -le 24
            set desc_display $description_raw
        else
            set desc_display (string sub -l 23 $description_raw)"…"
        end
        set info_part "\""$desc_display"\" "
    else
        set info_part "(no description) "
    end
    
    # Add status flags if any
    if test -n "$flags_raw"
        set status_flags (string replace -ra '\s+' ' ' $flags_raw | string replace -ra '^ | $' '')
        if test -n "$status_flags"
            set status_flags "("(string replace -a ' ' ') (' $status_flags)") "
        end
    else
        set status_flags ""
    end
    
    set prompt_part1 "$change_id$info_part$status_flags"
    
    set prompt_part2 (jj log --ignore-working-copy --quiet --reversed -r "fork_point(trunk()..@)::" --no-graph --color always -T "if(current_working_copy, '●', '○')++' '" 2>/dev/null)
    
    # Color the prompt part2 yellow from the character ● onwards
    set prompt_part2 (string replace -r '(.*●)' (set_color yellow)'$1'(set_color normal) $prompt_part2)
    
    set --universal $var_name "$prompt_part1$prompt_part2"
end

