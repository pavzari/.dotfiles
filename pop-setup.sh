#!/bin/bash

R='\e[1;91m'
G='\e[1;92m'
Y='\e[1;93m'
N='\e[0m'

APT_INSTALL=(
	gnome-tweaks
	ranger
	htop
	qbittorrent
	calibre
	pavucontrol
	ripgrep
	wget
	slack-desktop
	jq
	curl
	make
	unzip
	# pyenv
	build-essential
	libssl-dev
	zlib1g-dev
	libbz2-dev
	libreadline-dev
	libsqlite3-dev
	llvm
	libncurses5-dev
	libncursesw5-dev
	xz-utils
	tk-dev
	libffi-dev
	liblzma-dev
	python-openssl
	# tf
	gnupg
	software-properties-common
	# docker
	ca-certificates
	# nvim/clipboard
	xclip
)

DEB_INSTALL=(
	https://zoom.us/client/6.0.12.5501/zoom_amd64.deb
)

FLATPAK_INSTALL=(
	com.skype.Client
	com.stremio.Stremio
)

DOWNLOAD_DIR="$HOME/Downloads/post-install-downloads"
PYTHON_VERSION="3.12"
NVIM_VERSION="0.10.0"

function install_apt() {
	echo -e "${Y}Updating and upgrading...${N}"
	if sudo apt -y update && sudo apt -y upgrade 2>&1; then
		echo -e "${Y}Installing packages...${N}"
		for program in ${APT_INSTALL[@]}; do
			if ! dpkg -l | grep -q $program; then
				echo -e "${Y}Installing $program...${N}"
				sudo apt install $program -y &>/dev/null
			else
				echo -e "${G}The package $program is already installed.${N}"
			fi
		done
	fi
}

function install_deb() {
	echo -e "${Y}Installing .deb packages...${N}"
	mkdir -p $DOWNLOAD_DIR
	for url in "${DEB_INSTALL[@]}"; do
		file_name=$(basename "$url")
		wget -q -O "${DOWNLOAD_DIR}$file_name" "$url"
		if sudo apt install -y "${DOWNLOAD_DIR}$file_name" &>/dev/null; then
			echo -e "${G}Installed: $file_name${N}"
		else
			echo -e "${R}Failed to install: $file_name${N}"
		fi
		rm "${DOWNLOAD_DIR}$file_name"
	done
	rm -rf "${DOWNLOAD_DIR}"
	echo -e "${G}.deb package installations completed.${N}"
}

function install_flatpak() {
	if ! flatpak remote-list | grep -q "flathub"; then
		echo -e "${Y}Adding Flathub repository...${N}"
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	else
		echo -e "${Y}Flathub repository is already added.${N}"
	fi

	for program in ${FLATPAK_INSTALL[@]}; do
		if ! flatpak list | grep -q $program; then
			echo -e "${Y}Installing $program...${N}"
			flatpak install flathub $program -y &>/dev/null
		else
			echo -e "${Y}$program flatpak is already installed.${N}"
		fi
	done
}

function install_pyenv() {
	if command -v pyenv &>/dev/null; then
		echo -e "${G}Pyenv already installed.${N}"
	else
		echo -e "${Y}Installing pyenv...${N}"
		if curl https://pyenv.run | bash >/dev/null 2>&1; then
			{
				printf '\n\n# PYENV: \n'
				printf 'export PYENV_ROOT="$HOME/.pyenv"\n'
				printf 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"\n'
				printf 'eval "$(pyenv init -)"\n'
			} >>"$HOME/.bashrc"
			echo -e "${G}Pyenv installation and configuration completed.${N}"
		else
			echo -e "${R}Pyenv installation failed.${N}"
		fi
	fi
}

function install_python() {
	# need to figure out how to source .bashrc from here...
	export PATH="$HOME/.pyenv/bin:$PATH"
	eval "$(pyenv init --path)"
	eval "$(pyenv init -)"

	if pyenv versions | grep -q "${PYTHON_VERSION}"; then
		echo -e "${G}Python ${PYTHON_VERSION} is already installed.${N}"
	else
		echo -e "${Y}Installing Python ${PYTHON_VERSION}...${N}"
		pyenv install ${PYTHON_VERSION} >/dev/null 2>&1
		pyenv global ${PYTHON_VERSION} >/dev/null 2>&1
		echo -e "${G}Python ${PYTHON_VERSION} installation completed.${N}"
	fi
}

function install_awscli() {
	local AWS_CLI="curl \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o \
        "awscliv2.zip" 2>&1 &&
        unzip awscliv2.zip  2>&1 &&
        sudo ./aws/install 2>&1"
	echo -e "${Y}Installing AWS CLI...${N}"

	if command -v aws &>/dev/null; then
		echo -e "${G}AWS CLI already installed.${N}"
	else
		if eval "$AWS_CLI" >/dev/null 2>&1; then
			echo -e "${G}AWS CLI installed.${N}"
			rm -rf awscliv2.zip aws
		fi
	fi
}

function install_terraform() {
	if command -v terraform &>/dev/null; then
		echo -e "${G}Terraform already installed.${N}"
	else
		echo -e "${Y}Installing Terraform...${N}"
		wget -q -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>&1
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list 2>&1
		sudo apt update -y &>/dev/null
		if sudo apt install -y terraform >/dev/null 2>&1; then
			echo -e "${G}Terraform installed.${N}"
		fi
	fi
}

function install_docker() {
	echo -e "${Y}Setting up Docker's apt repository...${N}"
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	sudo apt update -y &>/dev/null
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>/dev/null

	if sudo docker run hello-world >/dev/null 2>&1; then
		echo -e "${G}Docker installation completed.${N}"
	else
		echo -e "${R}Docker installation failed.${N}"
	fi
}

function install_nvm_node() {
	echo -e "${Y}Installing nvm and node...${N}"
	curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash &>/dev/null
	source ~/.nvm/nvm.sh &>/dev/null
	nvm install node &>/dev/null
	nvm use node &>/dev/null
}

function install_neovim() {
	echo -e "${Y}Installing neovim...${N}"
	curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz &>/dev/null
	sudo rm -rf /opt/nvim
	sudo tar -C /opt -xzf nvim-linux64.tar.gz &>/dev/null
	rm nvim-linux64.tar.gz
}

function add_fonts() {
	echo -e "${Y}Adding fonts...${N}"
	mkdir -p ~/.local/share/fonts
	wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip &>/dev/null
	unzip JetBrainsMono.zip -d JetBrainsMono &>/dev/null
	cp JetBrainsMono/*.ttf ~/.local/share/fonts
	rm -rf JetBrainsMono.zip JetBrainsMono
	sudo fc-cache -fv &>/dev/null
}

function gsettings_config() {
	echo -e "${Y}Applying gsettings...${N}"
	declare -a gsettings_list=(
		"org.gnome.mutter edge-tiling false"
		"org.gnome.shell.extensions.pop-shell tile-by-default true"
		"org.gnome.shell.extensions.pop-shell active-hint true"
		"org.gnome.shell.extensions.pop-shell active-hint-border-radius 'uint32 0'"
		# "org.gtk.settings.color-chooser selected-color '(true, 0.70196078431372544, 0.541176470)'"
		"org.gnome.nautilus.preferences default-folder-viewer 'list-view'"
		"org.gnome.nautilus.list-view default-zoom-level 'small'"
		"org.gnome.shell.extensions.pop-shell show-title false"
		"org.gnome.shell.extensions.pop-shell gap-inner 'uint32 1'"
		"org.gnome.shell.extensions.pop-shell gap-outer 'uint32 1'"
		"org.gnome.desktop.interface clock-format 12h"
		"org.gnome.desktop.interface clock-show-weekday true"
		"org.gnome.desktop.wm.preferences button-layout 'appmenu:close'"
		"org.gnome.shell.extensions.pop-cosmic overlay-key-action 'LAUNCHER'"
		"org.gnome.shell.extensions.pop-cosmic show-workspaces-button false"
		"org.gnome.shell.extensions.pop-cosmic show-applications-button false"
		"org.gnome.shell.extensions.dash-to-dock manualhide true"
		"org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'"
		"org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'"
		"org.gnome.settings-daemon.plugins.power power-button-action 'interactive'"
		"org.gnome.desktop.interface show-battery-percentage true"
		"org.gnome.desktop.interface enable-animations false"
		"org.gnome.desktop.interface font-name 'Ubuntu 11'"
		"org.gnome.desktop.interface document-font-name 'Sans 11'"
		"org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 13'"
		"org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 11'"
	)
	gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up "['<Shift>F3']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys volume-mute "['<Shift>F1']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['<Shift>F1']"
	gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ use-system-font false
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ font 'JetBrainsMono Nerd Font Mono 15'

	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ cursor-blink-mode 'on'

	for setting in "${gsettings_list[@]}"; do
		if eval gsettings set $setting >/dev/null 2>&1; then
			echo -e "${G}$setting${N}"
		else
			echo -e "${R}$setting${N}"
		fi
	done
}

function bashrc_append() {
	echo -e "${Y}Adding config to .bashrc...${N}"

	BASHRC_ADDITIONS="
# MY ADDITIONS:
alias notes='cd /home/pav/notes'
alias vim='nvim'

# Git status for PS1:
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

parse_git_status() {
  if [[ -d .git ]] || git rev-parse --is-inside-work-tree &> /dev/null; then
    local status
    status=$(git status 2>/dev/null | tr -d '\n')
    if [[ \"$status\" == *\"working tree clean\"* ]]; then
      echo \" ✔\"
    else
      echo \" ✘\"
    fi
  fi
}

# Python venv activation:
venv() {
    if [ -d \"venv\" ]; then
        source venv/bin/activate
    elif [ -d \".venv\" ]; then
        source .venv/bin/activate
    else
        echo \"Python virtual environment not found in the current directory.\"
    fi
}

export PS1=\"\\[\e[32m\\]\u@\h\\[\e[00m\\]:\\[\e[94m\\]\w\\[\e[91m\\]\\\$(parse_git_status) \\\$(parse_git_branch)\\[\e[00m\\]$ \"
export PATH=\$PATH:/opt/nvim-linux64/bin
export EDITOR=nvim
"
	echo "$BASHRC_ADDITIONS" >>~/.bashrc
}

function cleanup() {
	sudo apt update -y &>/dev/null
	sudo apt upgrade -y &>/dev/null
	echo -e "${Y}Cleaning up...${N}"
	flatpak update -y &>/dev/null
	flatpak uninstall --unused -y &>/dev/null
	sudo apt autoremove -y &>/dev/null
	sudo apt clean &>/dev/null

	# eval "$(cat ~/.bashrc | tail -n +10)" # skip the non-interactive execution breaker at the top of default .bashrc
	echo -e "${G}Completed.${N}"
	echo -e "${R}Reload the shell: Alt + F2 + r.${N}"

	# echo -e "${R}Reloading the shell...${N}"
	# sleep 3
	# gnome-session-quit --logout --no-prompt
}

function main() {
	install_apt
	install_deb
	install_flatpak
	install_neovim
	install_pyenv
	install_python
	install_nvm_node
	install_awscli
	install_terraform
	install_docker
	add_fonts
	gsettings_config
	bashrc_append
	cleanup
}

main
