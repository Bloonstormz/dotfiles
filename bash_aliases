# perl to remove any trailing new line
# tee to output copied content to stdout, while still passing args to xclip
# echo "" to ensure new line
alias copy='perl -pe "chomp if eof" | tee >(xclip -selection c) && echo ""'
alias gitpb="git branch -vv | awk '\$3 \$4 ~ /:gone]$/ { print \$1 }' | xargs -n 1 git branch -D" # Remove branches that have been deleted on upstream
alias sd='shutdown -P 0'
alias g='git'

function gf() {
    local remote
    for remote in $(git remote); do
        git fetch "$remote" &
    done
    wait
}
