#######################################
###########  ZSH Plugins  ##############
########################################

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="custom"
export ZSHRC="$HOME/.zshrc"
export EDITOR="nvim"
# export EDITOR="$HOME/Repos/neovim/bin/nvim"

# Cloned inside .oh-my-zsh/plugins
plugins=(
  fzf-tab
  git
  npm
  zsh-autosuggestions
  zsh-syntax-highlighting
  wd
)

source $ZSH/oh-my-zsh.sh

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

alias gl="git log"

alias gtree="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

alias gtreelong="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"

alias gdiff="git diff"

alias gmerge="git merge --no-ff"

alias gstash="git stash -u"
alias gpop="git stash pop"
alias gpush="git push"
alias gpull="git pull"

alias conflicts="git diff --name-only --diff-filter=U"

#################### Cli-Task-Manager
alias t="task"
alias tt="task --storage $HOME/.global-tasks.json --clear --group state --sort desc"

#################### Others
alias ed="$EDITOR"

#########################################
#############  Functions  ###############
#########################################

auto_tmux() {
  if [ -z "$TMUX" ]; then
    if tmux has-session -t main 2>/dev/null; then
      tmux attach -t main
    else
      tmux new -s main
    fi
  fi
}

#########################################
###############  Tools  #################
#########################################

# If not in a SSH session, auto attach tmux
[ -n "$SSH_CONNECTION" ] || auto_tmux

# For nvm -> utility to update node
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Make FZF ignore some folders
export FZF_DEFAULT_COMMAND='ag --hidden --ignore-case --ignore .git -g ""'
export FZF_COMPLETION_TRIGGER='**'

# Completion for hidden path
setopt globdots

# Starship Shell UI
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/mikeaubenas/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

## To have FZF keybindings like writing **/<Tab> would open FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fnm
export PATH="/home/user/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"

# Rust
. "$HOME/.cargo/env"
