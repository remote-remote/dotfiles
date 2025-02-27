export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(
  git
)
source $ZSH/oh-my-zsh.sh
export EDITOR='nvim'
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

autoload -U +X bashcompinit && bashcompinit

fpath=($fpath "$HOME/.zfunctions")

## aliases
alias vim="nvim"
alias vimdiff="nvim -d"
alias awk="gawk"
alias gbc='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/.config/zsh/local.zsh
source ~/.config/zsh/dev.zsh

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
