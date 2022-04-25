#!/bin/bash

########################################

# Download files from the GitHub

# Use:

# chmod u+x setup.sh
# ./setup.sh

########################################

# Config

fontDir="/usr/share/fonts/"

########################################

# Functions

basePkg ()
{

	echo "##### Base packages"

	echo -n "Sudo password:"
	read -s password
	sudo -S apt install git curl make cmake zsh ranger neovim tmux fzf silversearcher-ag nodejs -y <<<"$password"
}

nerdFonts ()
{
	echo "##### Nerdfonts"

	cp -f assets/fonts/* $fontDir

	fc-cache -f -v

	echo "'Hack' sould be visible"
	fc-list | grep "Hack"
}

starship ()
{
	echo "##### Starship"

	curl -sS https://starship.rs/install.sh | sh
	mkdir -p ~/.config

	cp -f starship.toml ~/.config/starship.toml
}

usingZsh ()
{
	echo "##### ZSH"

	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	chsh -s /bin/zsh

	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

	cp -f .zshrc ~/.zshrc
	cp -f custom.zsh-theme $ZSH/themes
}

settingTMUX ()
{
	echo "##### TMUX"

	cp -f .tmux.conf ~/.tmux.conf
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	~/.tmux/plugins/tpm/scripts/install_plugins.sh

	cd ~/.tmux/plugins/tmux-mem-cpu-load
	cmake .
	make
	make install
}

settingRanger ()
{
	echo "##### Ranger"

	mkdir -p ~/.config/ranger
	cp -f rc.conf ~/.config/ranger/rc.conf
}

settingAlacritty ()
{
	echo "##### Alacritty"

	mkdir -p ~/.config/alacritty
	cp -f alacritty.yml ~/.config/alacritty/alacritty.yml
}

settingNeoVim ()
{

	echo "##### NeoVim"

	mkdir -p ~/.config/nvim/
	cp -f init.vim ~/.config/nvim/init.vim

	mkdir -p ~/.vim
	cp -f coc-settings.json ~/.vim/coc-settings.json
}

########################################

# Main

basePkg
nerdFonts
starship
usingZsh
settingTMUX
settingRanger
settingAlacritty
settingNeoVim