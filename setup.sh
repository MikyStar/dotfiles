#!/bin/bash

########################################

# Download files from the GitHub

# Use:

# chmod u+x setup.sh
# ./setup.sh

########################################

# Config

fontDir="/usr/share/fonts/"
nvimLocation="~/Repos/neovim "

########################################

# Functions

basePkg ()
{

	echo "##### Base packages"

	echo -n "Sudo password:"
	read -s password
	sudo -S apt install git curl make cmake zsh ranger tmux fzf silversearcher-ag nodejs npm -y <<<"$password"
}

frenchTimezone ()
{

	echo "##### French Timezone"

	sudo -s rm /etc/localtime <<<"$password"
	sudo -s ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime <<<"$password"
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

	git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

	cp -f .zshrc ~/.zshrc
	rm $ZSH/themes/*
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
	sudo -s make install <<<"$password"
	cd ~/dotfiles
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

	sudo -s apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen <<<"$password"
	mkdir -p $nvimLocation
	git clone https://github.com/neovim/neovim $nvimLocation
	cd $nvimLocation
	make CMAKE_INSTALL_PREFIX=$nvimLocation
	make install
	sudo -s make install <<<"$password"

	mkdir -p ~/.vim/bundle
	cp -f .vimrc ~/.vimrc
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

	mkdir -p ~/.config/nvim/
	cp -f init.vim ~/.config/nvim/init.vim

	mkdir -p ~/.vim
	cp -f coc-settings.json ~/.vim/coc-settings.json

	nvim +PluginInstall +qall
}

########################################

# Main

basePkg
frenchTimezone
nerdFonts
starship
usingZsh
settingTMUX
settingRanger
settingAlacritty
settingNeoVim
