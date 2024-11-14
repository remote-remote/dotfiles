if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH=~/.oh-my-zsh
ZSH_THEME="spaceship"
plugins=(
  git
	# vi-mode
)
source $ZSH/oh-my-zsh.sh
export EDITOR='vim'
export PATH="$PATH:/Users/jasonamador/bin"
export PATH="$PATH:/Users/jasonamador/.local/bin"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Node Version Control
export NVM_SYMLINK_CURRENT=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C ~/bin/vault vault

export NPM_TOKEN=$(cat ~/.npmrc | grep authToken= | cut -d''='' -f2)

complete -o nospace -C /usr/local/bin/terraform terraform

function cpp {
  g++ $1 -o ./build/main
  cat $2 | xargs ./build/main
}
fpath=($fpath "$HOME/.zfunctions")

# ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

## aliases
alias vim="nvim"
alias vimdiff="nvim -d"
alias awk="gawk"
alias gbc='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR='nvim'

source ~/.config/zsh/local.zsh
