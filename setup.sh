#!/bin/bash

########################################

# Download files from the GitHub

# Use:

# chmod u+x setup.sh
# sudo setup.sh

########################################

# Config

pkgInstall="apt install"
fontDir="/usr/share/fonts/"

########################################

# Functions

basePkg ()
{

	echo "##### Base packages"

	eval "$pkgInstall git curl make cmake zsh ranger neovim tmux fzf ag nodejs"
}

nerdFonts ()
{
	echo "##### Nerdfonts"

	curl -LO https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip -o fonts.zip
	unzip fonts.zip
	rm fonts.zip
	mv ttf/*.ttf $fontDir

	fc-cache -f -v
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

	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	cp -f .zshrc ~/.zshrc
	cp -f custom.zsh-theme $ZSH/themes
}

settingTMUX ()
{
	echo "##### TMUX"

	cp -f .tmux.conf ~/.tmux.conf
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

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