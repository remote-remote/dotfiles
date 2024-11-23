# ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

function cpp {
  g++ $1 -o ./build/main
  cat $2 | xargs ./build/main
}

complete -o nospace -C /usr/local/bin/terraform terraform
export NPM_TOKEN=$(cat ~/.npmrc | grep authToken= | cut -d''='' -f2)
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

