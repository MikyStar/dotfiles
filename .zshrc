########################################
###########  ZSH Plugins  ##############
########################################

export ZSH="$HOME/.oh-my-zsh"

# Cloned inside .oh-my-zsh/plugins
plugins=(
  git
  npm
  zsh-autosuggestions
  zsh-syntax-highlightin
)

source $ZSH/oh-my-zsh.sh

########################################
############  Variables  ###############
########################################

# For nvm -> utility to update node
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Make FZF ignore some folders
export FZF_DEFAULT_COMMAND='ag --hidden --ignore-case --ignore .git -g ""'

########################################
#############  Aliases  ################
########################################

#################### TMUX
alias tmuxco="tmux a -t"

#################### Git
alias status="git status"
alias gs="git status -s"

alias ga="git add "

alias gc="git commit -m"

alias discard="git checkout -- "

alias unstage="git reset "

# This makes an alias for a push function that can take a message as argument
function push() {
    git add .

    if [ "$1" != "" ]
    then
        git commit -m "$1"
    else
        git commit -m update
    fi

    git push
}

alias gl="git log"

alias gtree="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

alias gtreelong="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"

alias gdiff="git diff"

alias gmerge="git merge --no-ff"

alias conflicts="git diff --name-only --diff-filter=U"

#################### Others
alias edit="vim"
alias sourceShell="source $HOME/.zshrc"

########################################
############  Functions  ###############
########################################

# Lets you quit Ranger normally with :q, but changes your location to where browsed in ranger if you quit with Q.
function ranger {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
                command
                ranger
                --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
    )

    ${ranger_cmd[@]} "$@"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
                cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}

####################

# Starship Shell UI
eval "$(starship init zsh)"
