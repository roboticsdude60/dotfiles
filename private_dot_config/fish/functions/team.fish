function team
    set -l people ben molly kevin me team
    set -l actions mr msg

    set -l person_arg ""
    set -l action_arg ""

    for arg in $argv
        if contains -- $arg $people; set person_arg $arg; end
        if contains -- $arg $actions; set action_arg $arg; end
    end

    set -l person $person_arg
    set -l action $action_arg

    while true
        while test -z "$person" -o -z "$action"
            if test -z "$person"
                set person (printf '%s\n' $people | gum choose --header "Who?" )
                set -l s $status
                if test $s -eq 130; return; end
                if test -z "$person"; set action ""; end
            end
            if test -z "$action"
                set action (printf '%s\n' $actions | gum choose --header "Action?" )
                set -l s $status
                if test $s -eq 130; return; end
                if test -z "$action"; set person ""; end
            end
        end

        switch $action
            case mr
                _team_mr $person
                set -l s $status
                if test $s -eq 130; return; end
                if test $s -eq 1
                    set action ""
                    continue
                end
                return
            case msg
                _team_msg $person
                return
        end
    end
end

function _team_gitlab_username
    switch $argv[1]
        case ben;   echo bnjmnmrtn
        case molly; echo molly.carpadakis
        case kevin; echo kevin.burch
        case me;    echo joseph.scholl
    end
end

function _team_chat_url
    switch $argv[1]
        case ben;   echo "https://chat.google.com/app/chat/lyI-REAAAAE"
        case molly; echo "https://chat.google.com/app/chat/gP9swMAAAAE"
        case kevin; echo "https://chat.google.com/app/chat/u1a8HCAAAAE"
        case team;  echo "https://chat.google.com/app/chat/AAQAlKk2ZVQ"
    end
end

function _team_msg
    set -l person $argv[1]
    if test "$person" = me
        echo "Can't message yourself"
        return 1
    end
    open (_team_chat_url $person)
end

function _team_mr
    set -l person $argv[1]
    set -l username (_team_gitlab_username $person)

    gum spin --title "Fetching $person's MRs..." -- glab api "merge_requests?author_username=$username&state=opened&scope=all&order_by=updated_at&sort=desc" | string collect | read -l mrs

    if test $pipestatus[1] -eq 130; return 130; end

    set -l count (echo $mrs | fx .length)
    if test "$count" = 0
        echo "No open MRs for $person"
        return
    end

    while true
    	echo $mrs | fx ".map(x => [x.references.full.split('/').at(-1), x.title, x.detailed_merge_status].join('\t')).join('\n')" | gum table --separator (printf '\t') --columns "MR,Title,Status" | read -l selected

        set -l s $status
        if test $s -eq 130; return 130; end
        test -n "$selected"; or return 1

        set -l ref (echo $selected | cut -f1)
        set -l mr (echo $mrs | fx "x => x.find(mr => mr.references.full.endsWith('$ref'))")

        set -l title        (echo $mr | fx ".title")
        set -l web_url      (echo $mr | fx ".web_url")
        set -l project_path (echo $mr | fx ".references.full.split('!')[0]")

        set -l action (gum choose --header $title \
            "open in browser" \
            "copy url" \
            "approve" )
        set -l s $status
        if test $s -eq 130; return 130; end
        test -n "$action"; or continue

        switch $action
            case "open in browser"
                open $web_url
            case "copy url"
                echo -n $web_url | pbcopy
                echo "Copied"
            case approve
            	set -l iid  (echo $mr | fx ".iid")
             	set -l repo (echo $mr | fx ".references.full.split('!')[0]")
            	gum confirm "Approve MR?"
             	and glab mr approve $iid --repo $repo

        end
        return
    end
end
