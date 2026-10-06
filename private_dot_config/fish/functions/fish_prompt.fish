function fish_prompt --description Hydro
    set --local location "$_hydro_color_start$hydro_symbol_start$hydro_color_normal$_hydro_color_pwd$_hydro_pwd$hydro_color_normal"
    set --local status_info $_hydro_status

    if jj_prompt_is_repo
        set --local vcs_info (fish_jj_prompt)
        test -n "$vcs_info"; or set vcs_info 'jj …'
        set --local sections (string split -m 2 \t -- "$vcs_info")
        if test (count $sections) -eq 3
            set --local left $sections[1]
            set --local description $sections[2]
            set --local right $sections[3]
            set --local width $COLUMNS
            test -n "$width"; or set width 80

            if test -n "$right"
                set --local available (math "$width - 1 - "(string length --visible -- "$left")" - "(string length --visible -- "$right")" - 4")
                if test $available -gt 3
                    if test "$description" = '(no description)'
                        set description (string shorten -m $available -- "$description")
                    else
                        set description '"'(string shorten -m (math "$available - 2") -- "$description")'"'
                    end
                    set --local used (math (string length --visible -- "$left") + (string length --visible -- "$description") + (string length --visible -- "$right"))
                    set --local gap (math "$width - 1 - $used - 2")
                    set vcs_info "$left  $description"(string repeat -n $gap ' ')"$right"
                else
                    test "$description" = '(no description)'; or set description "\"$description\""
                    set vcs_info "$left  $description  $right"
                end
            else
                set --local available (math "$width - 1 - "(string length --visible -- "$left")" - 2")
                if test $available -gt 3
                    if test "$description" = '(no description)'
                        set description (string shorten -m $available -- "$description")
                    else
                        set description '"'(string shorten -m (math "$available - 2") -- "$description")'"'
                    end
                else
                    test "$description" = '(no description)'; or set description "\"$description\""
                end
                set vcs_info "$left  $description"
            end
        end

        # Hydro can add its own newline; jj repositories always use two lines.
        if test -n "$_hydro_newline"
            set status_info (string replace -a -- "$_hydro_newline" '' "$status_info")
        end
        echo -e -n "$vcs_info\n$location $_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$status_info$hydro_color_normal "
    else
        set --local vcs_info $_hydro_color_git$_hydro_git$hydro_color_normal
        echo -e -n "$location $vcs_info$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$status_info$hydro_color_normal "
    end
end
