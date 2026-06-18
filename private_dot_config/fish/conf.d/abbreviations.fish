#!/usr/bin/env fish

# abbreviations are only used for interactive sessions
status is-interactive; or return

abbr -a cc 'claude'
# abbr -a pairs "shuf -e james isaac nathan joseph | xargs -n2 | tee /dev/tty | pbcopy"

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
abbr -a --set-cursor=@ gnb 'git fetch && git checkout origin/master -b josephscholl-@'
# worktree
abbr -a gwl 'git worktree list'
abbr -a gwr 'git worktree remove'
abbr -a cdw 'cd_worktree'
abbr -a cdmw 'cd (git rev-parse --show-toplevel)'
abbr -a --set-cursor=@ gnw 'git worktree add ../josephscholl-@'
abbr -a --set-cursor=@ zow 'zed_open_worktree'
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
# merge requests
abbr -a gmr 'git_mr_from'
abbr -a gnmr 'git_mr_from'

# jj vcs abbreviations
abbr -a jjl 'jj log'
abbr -a jjsh 'jj show'
abbr -a jjst 'jj status'
abbr -a jjdi 'jj diff'

abbr -a jjn 'jj new'
abbr -a jjnt 'jj new \'trunk()\''
abbr -a jjdm --set-cursor=@ 'jj describe -m \'@\''
abbr -a jjcm --set-cursor=@ 'jj commit -m \'@\''
abbr -a jje 'jj edit'
abbr -a jjsp 'jj split'
abbr -a jjsq 'jj squash'
abbr -a jjrt 'jj rebase --onto \'trunk()\''
# resolving conflicts
abbr -a jjenc 'jj enc'
abbr -a jjm 'jj mergiraf'
# bookmarks
abbr -a jjb 'jj bookmark'
abbr -a jjbc 'jj bookmark create'
abbr -a jjbl 'jj bookmark list'
abbr -a jjbs 'jj bookmark set'
abbr -a jjba 'jj bookmark advance'
abbr -a jjbat --set-cursor=% 'jj bookmark advance --to @%'
# git remotes
abbr -a jjgf 'jj git fetch'
abbr -a jjgp 'jj git push'
abbr -a jjgpc 'jj git push --change'
# workspace
abbr -a jjw 'jj workspace'
abbr -a jjwl 'jj workspace list'
