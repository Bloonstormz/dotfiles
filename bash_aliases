#!/bin/bash

# perl to remove any trailing new line
# tee to output copied content to stdout, while still passing args to xclip
# echo "" to ensure new line
alias copy='perl -pe "chomp if eof" | tee >(xclip -selection c) && echo ""'
alias gitpb="git branch -vv | awk '\$3 \$4 ~ /:gone]$/ { print \$1 }' | xargs -n 1 git branch -D" # Remove branches that have been deleted on upstream
alias sd='shutdown -P 0'
alias g='git'
alias gl='git log --oneline'
alias gitl='gl'
alias lg='lazygit'

# git reword reuse
alias grr='git commit --amend --edit -F .git/COMMIT_EDITMSG'
alias gitrr='grr'

# git reword
alias gr='git commit --amend'
alias gitr='gr'

function gf() {
    local remote
    for remote in $(git remote); do
        git fetch "$remote" &
    done
    wait
}

# C define search
function rgd() {
    local search_term="$1"
    shift
    rg "#define\s+$search_term" "$@"
}

[[ -e "$HOME/.config/.local_aliases" ]] && source "$HOME/.config/.local_aliases"
