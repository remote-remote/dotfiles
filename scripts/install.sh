#!/bin/zsh
exec > >(tee -a /root/dotfiles/install.log) 2>&1

function have() {
  command -v $1 &> /dev/null
}

if [ `uname` = 'Darwin' ]; then
  ! have brew && \
    echo "Installing Homebrew..." && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  INSTALLER='brew'
fi

if [ `uname` = 'Linux' ]; then
  INSTALLER='apt-get'
fi

if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  nvm install node
fi

! have stow && \
  echo "Installing stow..." && \
  $INSTALLER install stow -y

! have gawk && \
  echo "Installing gawk..." && \
  $INSTALLER install gawk -y

! have fzf && \
  echo "Installing fzf..." && \
  $INSTALLER install fzf -y

! have rg && \
  echo "Installing ripgrep..." && \
  $INSTALLER install ripgrep -y

cd $HOME/dotfiles

if [ ! -L "$HOME/.config/tmux" ]; then
  echo "Stowing tmux"
  stow tmux
fi

! have tmux && \
  echo "Installing tmux..." && \
  $INSTALLER install tmux -y

if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
  $HOME/.config/tmux/plugins/tpm/bin/install_plugins
fi

if [ ! -L "$HOME/.config/nvim" ]; then
  echo "Stowing nvim"
  stow nvim
fi

! have nvim && \
  echo "Installing Neovim..." && \
  $INSTALLER install neovim -y

if [ ! -L "$HOME/.config/zsh" ]; then
  echo "Stowing zsh"
  stow zsh
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
