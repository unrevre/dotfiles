#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export ARCHFLAGS="-arch x86_64"
export VIRTUAL_ENV_DISABLE_PROMPT=1

PS1="\[\033[38;5;4m\]┌─[\u@\h] \[\033[38;5;2m\]\W\[\033[38;5;3m\]\$(get_git_branch)\n\
\[\033[38;5;4m\]└─╼ $\[\033[0m\]\$(get_virtualenv) "

alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'

HISTCONTROL=ignoredups

stty -ixon

bind '"\C-f"':shell-forward-word
bind '"\C-b"':shell-backward-word
bind '"\C-d"':shell-kill-word

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

completions=(
)

for f in "${completions[@]}"; do [[ -r "$f" ]] && . "$f"; done

function up() {
    if [[ $# -eq 0 || $1 -gt 0 ]]; then
        cd $(eval printf '../'%.0s {1..$1}) && pwd;
    fi
}

function get_git_branch() {
    if git --version &> /dev/null; then
        # On branches, this will return the branch name
        # On non-branches, (no branch)
        ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
        [[ "$ref" != "" ]] && echo " :$ref:"
    fi
}

function get_virtualenv() {
    [[ -n "$VIRTUAL_ENV" ]] && echo " (${VIRTUAL_ENV##*/})"
}
