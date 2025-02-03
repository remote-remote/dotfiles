if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
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
  mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
fi
