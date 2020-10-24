########################################
#############  General  ################
########################################
#
export ZSH="/Users/mike/.oh-my-zsh"

ZSH_THEME="custom"

plugins=(
  git
  npm
)

source $ZSH/oh-my-zsh.sh

# For zsh autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export PATH="/usr/local/opt/bison/bin:$PATH"

# For nvm -> utility to update node
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Make FZF ignore some folders
export FZF_DEFAULT_COMMAND="fd --type file --hidden --exclude '.git' --exclude 'node_modules'"

########################################
#############  Aliases  ################
########################################

# To use my command tmstp that print a nice timestamp
alias tmstp="/Users/mike/Documents/Scripts/tmstp.sh"

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

alias gdiff="git diff"
