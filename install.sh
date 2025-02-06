#!/bin/zsh

if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  # install a node version
fi

if ! command -v nvim &> /dev/null; then
  echo "Installing Neovim..."
  brew install neovim
fi

if ! command -v gawk &> /dev/null; then
  echo "Installing gawk..."
  brew install gawk
fi

if ! command -v fzf &> /dev/null; then
  echo "Installing fzf..."
  brew install fzf
fi

if ! command -v rg &> /dev/null; then
  echo "Installing ripgrep..."
  brew install ripgrep
fi

if ! command -v tmux &> /dev/null; then
  echo "Installing tmux..."
  brew install tmux
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing ohmyzsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  source ~/.zshrc
  mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then 
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
  ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi
