if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    atuin init fish | source

    abbr -a tsc "bunx tsc --noEmit"
    abbr -a pairs "shuf -e james isaac nathan joseph | xargs -n2 | tee /dev/tty | pbcopy"

    # TODO only add git abbreviations if we are in a git repo
    # if git rev-parse --is-inside-work-tree

    # git abbreviations
    abbr -a lg 'lazygit'
    abbr -a g 'git'
    abbr -a ga 'git add'
    abbr -a gb 'git branch'
    abbr -a gf 'git fetch'
    abbr -a gg 'git pull'
    abbr -a gl 'git log'
    abbr -a gst 'git status'
    # stash
    abbr -a gs 'git stash'
    abbr -a gsp 'git stash pop'
    abbr -a gspu 'git stash push'
    # checkout
    abbr -a gco 'git checkout'
    abbr -a gcom 'git checkout master'
    abbr -a --set-cursor=@ gnb 'git fetch && git checkout origin/master -b josephscholl.@'
    # commit
    abbr -a gc 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a --set-cursor=@ gcm 'git commit -m "@"'
    # rebase
    abbr -a gr 'git rebase'
    abbr -a gra 'git rebase --abort'
    abbr -a grc 'git rebase --continue'
    abbr -a grom 'git fetch && git rebase origin/master --autostash'
    # push
    abbr -a gp 'git push'
    abbr -a gpf 'git push --force-with-lease'
end
