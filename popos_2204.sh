#!/usr/bin/env bash

R='\e[1;91m'
G='\e[1;92m'
Y='\e[1;93m'
N='\e[0m'

APT_INSTALL=(
    slack-desktop
    gnome-tweaks
    qbittorrent
    pavucontrol
    calibre
    ripgrep
    ranger
    tmux
    stow
    htop
    fzf
    bat
    wget
    git
    jq
    curl
    make
    unzip
    # pyenv deps:
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
    # tf deps:
    gnupg
    software-properties-common
    # docker deps:
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
        for program in "${APT_INSTALL[@]}"; do
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
    mkdir -p "$DOWNLOAD_DIR"
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

    for program in "${FLATPAK_INSTALL[@]}"; do
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
        if curl -s https://pyenv.run | bash >/dev/null 2>&1; then
            echo -e "${G}Pyenv installation and configuration completed.${N}"
        else
            echo -e "${R}Pyenv installation failed.${N}"
        fi
    fi
}

function install_python() {
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
    local AWS_CLI='curl \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o \
        "awscliv2.zip" 2>&1 &&
        unzip awscliv2.zip  2>&1 &&
        sudo ./aws/install 2>&1'
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
        wget -q -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &>/dev/null
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
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>/devcn
    if sudo docker run hello-world >/dev/null 2>&1; then
        echo -e "${G}Docker installation completed.${N}"
    else
        echo -e "${R}Docker installation failed.${N}"
    fi
}

function install_fnm_node() {
    echo -e "${Y}Installing fnm and node...${N}"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell &>/dev/null
    "$HOME/.local/share/fnm/fnm" install --lts &>/dev/null
    LTS_VERSION=$("$HOME/.local/share/fnm/fnm" list | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -n 1)
    "$HOME/.local/share/fnm/fnm" default "$LTS_VERSION" &>/dev/null
}

function install_neovim() {
    echo -e "${Y}Installing neovim...${N}"
    curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz &>/dev/null
    sudo rm -rf /opt/nvim*
    sudo tar -C /opt -xzf nvim-linux64.tar.gz &>/dev/null
    rm nvim-linux64.tar.gz
}

function install_tailscale() {
    echo -e "${Y}Installing tailscale...${N}"
    curl -fsSL https://tailscale.com/install.sh | sh &>/dev/null
}

function install_syncthing() {
    echo -e "${Y}Installing syncthing...${N}"
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg &>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list &>/dev/null
    sudo apt update &>/dev/null
    sudo apt install syncthing &>/dev/null
    sudo systemctl enable syncthing@"$USER".service &>/dev/null
    sudo systemctl start syncthing@"$USER".service &>/dev/null
    sleep 5

    CONFIG_FILE=~/.local/state/syncthing/config.xml

    if [[ -f "$CONFIG_FILE" ]]; then
        # Disable relays
        sed -i 's|<relaysEnabled>true</relaysEnabled>|<relaysEnabled>false</relaysEnabled>|g' "$CONFIG_FILE"

        # Change the GUI address to 0.0.0.0:8384 for access outside localhost
        sed -i 's|<address>127.0.0.1:8384</address>|<address>0.0.0.0:8384</address>|g' "$CONFIG_FILE"
    else
        echo "Syncthing config file not found: $CONFIG_FILE"
    fi
    sudo systemctl restart syncthing@"$USER".service &>/dev/null
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

function popos_gsettings_config() {
    echo -e "${Y}Applying gsettings...${N}"
    declare -a gsettings_list=(
        "org.gnome.mutter edge-tiling false"
        "org.gnome.shell.extensions.pop-shell tile-by-default true"
        # "org.gnome.shell.extensions.pop-shell active-hint true"
        # "org.gnome.shell.extensions.pop-shell active-hint-border-radius 'uint32 0'"
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
    gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down "['<Shift>F2]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
    # gsettings set org.gnome.shell.extensions.pop-shell hint-color-rgba "rgba(179,142,61,0.351351)"

    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ font 'JetBrainsMono Nerd Font Mono 15'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ cursor-blink-mode 'on'

    for setting in "${gsettings_list[@]}"; do
        if eval gsettings set $setting >/dev/null 2>&1; then
            echo -e "${G}$setting${N}"
        else
            echo -e "${R}$setting${N}"
        fi
    done

    # Enable Wayland
    FILE_PATH="/etc/gdm3/custom.conf"
    sudo sed -i 's/^WaylandEnable=false/WaylandEnable=true/' "$FILE_PATH"
    # sudo systemctl restart gdm.service

    # Make some of the gnome title bars smaller.
    mkdir -p "$HOME/.config/gtk-3.0"
    cat >"$HOME/.config/gtk-3.0/gtk.css" <<EOF
headerbar entry,
headerbar spinbutton,
headerbar button,
headerbar separator {
  margin-top: 1px;
  margin-bottom: 1px;
  border-width: 0px;
  /*min-height: 0px;*/
}
headerbar {
  min-height: 24px;
  padding-left: 1px;
  padding-right: 1px;
  margin: 0px;
  padding: 0px;
  border-radius: 0px;
}
decoration {
  box-shadow: none;
}
EOF
}

function install_starship() {
    echo -e "${Y}Installing starship prompt...${N}"
    yes | curl -sS https://starship.rs/install.sh | sh &>/dev/null
}

function install_zsh() {
    echo -e "${Y}Installing zsh...${N}"
    sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting &>/dev/null
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
    fi
}

function install_wezterm() {
    # Ubuntu22 stable
    curl -LO https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb &>/dev/null
    sudo apt install -y ./wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb &>/dev/null
    rm wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb
}

function install_ghostty() {
    echo -e "${Y}Installing ghostty...${N}"
    sudo apt install -y llvm lld llvm-dev liblld-dev clang libclang-dev libglib2.0-dev libgtk-4-dev libadwaita-1-dev git
    wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz -O /tmp/zig.tar.xz
    tar -xf /tmp/zig.tar.xz -C /tmp
    export PATH="/tmp/zig-linux-x86_64-0.13.0:$PATH"
    git clone git@github.com:ghostty-org/ghostty.git ghostty
    cd ghostty && zig build -p $HOME/.local -Doptimize=ReleaseFast

    rm -f /tmp/zig.tar.xz
    rm -rf /tmp/zig-linux-x86_64-0.13.0
    rm -rf ghostty

    # Edit .local/share/applications/com.mitchellh.ghostty.desktop to include full Exec path
    # to bin $HOME/.local/bin/ghostty if pop app launcher does not start the term.
}

function install_uv() {
    echo -e "${Y}Installing uv...${N}"
    curl -LsSf https://astral.sh/uv/install.sh | sh &>/dev/null
}

function cleanup() {
    # Remove pre-installed stuff:
    sudo apt remove pop-shop &>/dev/null
    sudo apt remove --purge libreoffice* &>/dev/null
    apt remove pop-shop &>/dev/null

    sudo apt update -y &>/dev/null
    sudo apt upgrade -y &>/dev/null
    echo -e "${Y}Cleaning up...${N}"
    flatpak update -y &>/dev/null
    flatpak uninstall --unused -y &>/dev/null
    sudo apt autoremove -y &>/dev/null
    sudo apt clean &>/dev/null

    # echo -e "${R}Reload the shell: Alt + F2 + r.${N}"
    # gnome-session-quit --logout --no-prompt

    echo -e "${R}Rebooting to apply changes...${N}"
    sleep 5
    sudo reboot
}

function main() {
    install_apt
    install_deb
    install_flatpak
    install_neovim
    install_pyenv
    install_python
    install_fnm_node
    install_awscli
    install_terraform
    install_docker
    install_tailscale
    install_syncthing
    install_uv
    install_starship
    install_wezterm
    install_ghostty
    add_fonts
    popos_gsettings_config
    cleanup
}

main
