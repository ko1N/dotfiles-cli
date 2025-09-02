# basic configuration
set fish_greeting ""

set -gx CLICOLOR 1
set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# colors
set -g fish_color_normal abb2bf
set -g fish_color_command c678dd
set -g fish_color_quote 98c379
set -g fish_color_redirection 56b6c2
set -g fish_color_end abb2bf
set -g fish_color_error e06c75
set -g fish_color_param e06c75
set -g fish_color_comment 5c6370
set -g fish_color_match 56b6c2 --underline
set -g fish_color_search_match --background=2e6399
set -g fish_color_operator c678dd
set -g fish_color_escape 56b6c2
set -g fish_color_cwd e06c75
set -g fish_color_autosuggestion abb2bf
set -g fish_color_valid_path e06c75 --underline
set -g fish_color_history_current 56b6c2
set -g fish_color_selection --background=5c6370
set -g fish_color_user 61afef
set -g fish_color_host 98c379
set -g fish_color_cancel 5c6370

# Completion Pager Colors
set -g fish_pager_color_completion abb2bf
set -g fish_pager_color_prefix 98c379
set -g fish_pager_color_description abb2bf
set -g fish_pager_color_progress abb2bf

# environment variables
set -gx SHELL fish
set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin
set -gx PATH $GOBIN $PATH

set -gx RUSTBIN $HOME/.cargo/bin
if command -v brew >/dev/null 2>&1
    set -gx RUSTBIN (brew --prefix rustup)/bin $RUSTBIN
end
set -gx PATH $RUSTBIN $PATH

if command -v brew >/dev/null 2>&1
    set -gx PATH (brew --prefix python3)/bin $PATH
end

set -gx PATH $HOME/.local/bin $PATH

set -gx PATH $HOME/.npmenv/bin $PATH

set -gx PATH $PATH $HOME/.lmstudio/bin

# secrets
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

# aliases
alias t="eza --git-repos --icons=auto --tree"
alias ls="eza --git-repos --icons=auto"
alias l="eza -lAh --git-repos --icons=auto"
alias ll="eza -alF --git-repos --icons=auto"
alias ..="cd .."

alias calc="qalc"

alias sshy="fish_ssh_yubikey"
alias sshyubi="fish_ssh_yubikey"
alias sshk="fish_ssh_remove_all_keys"

alias gs="git status"
alias ga="git add"
# alias gc="git commit"
function batdiff
    git diff --name-only --relative --diff-filter=d $argv | xargs bat --diff
end
alias gd="batdiff"
alias grm="git rebase origin/master"
alias gri1="git rebase -i HEAD~~"
alias gri2="git rebase -i HEAD~~~"
alias gri3="git rebase -i HEAD~~~~"
alias gri4="git rebase -i HEAD~~~~~"
alias gri5="git rebase -i HEAD~~~~~~"
alias gri6="git rebase -i HEAD~~~~~~~"
alias bd="batdiff"
alias grb="git rebase"

alias pbcopy="xclip -selection clipboard -in"
alias pbpaste="xclip -selection clipboard -out"

alias vetcert="cargo vet certify"
alias vetdiff="cargo vet diff --mode=local"
alias vetinspect="cargo vet inspect --mode=local"

alias gogo="cd $GOPATH/src"

alias k="kubectl"
alias hx="helix"

# Flag overrides
alias mv="mv -i"
alias rm="rm -i"
alias grep="grep --color=auto"

# Overrides (in case the tool is installed)
if command -v zoxide >/dev/null 2>&1
    alias cd="z"
end
if command -v fd >/dev/null 2>&1
    alias find="fd"
end
if command -v bat >/dev/null 2>&1
    alias cat="bat --style=plain"
end
if command -v nvim >/dev/null 2>&1
    alias vi="nvim"
    alias vim="nvim"
end
if command -v yazi >/dev/null 2>&1
    alias ranger="yazi"
    alias files="yazi"
end

# ansible logging aliases
alias ansible='ansible-log run ansible'
alias ansible-playbook='ansible-log run ansible-playbook'
alias ansible-vault='ansible-log run ansible-vault'
alias ansible-galaxy='ansible-log run ansible-galaxy'

# scripts
source $HOME/.config/fish/functions/fzf_navigation.fish
source $HOME/.config/fish/functions/fzf_tmux.fish
source $HOME/.config/fish/functions/fzf_git.fish
source $HOME/.config/fish/functions/fzf_pyenv.fish

# completions
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end

if command -v cells >/dev/null 2>&1
    cells completion fish | source
end

# start ssh agent
fish_ssh_agent

# prompt
starship init fish | source

# functions
function sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/patrick/.lmstudio/bin
# End of LM Studio CLI section
