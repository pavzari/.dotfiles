# zmodload zsh/zprof
# for i in $(seq 1 10); do time zsh -i -c exit; done

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt BANG_HIST
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS

# Basic auto/tab complete
autoload -U compinit
zmodload zsh/complist
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

setopt GLOBDOTS
setopt AUTOCD

# Vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Different cursor for normal/insert modes
cursor_mode() {
    cursor_block='\e[2 q'
    cursor_beam='\e[5 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}
cursor_mode

# Text objects for brackets and quotes
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Aliases
alias zsc="source ~/.zshrc"
alias bsc="source ~/.bashrc"

alias nedit="cd ~/.config/nvim && vim"
alias tedit="vim ~/.config/tmux/tmux.conf"
alias zedit="vim ~/.zshrc"
alias bedit="vim ~/.bashrc"

alias notes="cd ~/notes"
alias code="cd ~/code"
alias misc="cd ~/misc"
alias ...="cd ../.."
alias ..="cd .."

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cat='batcat --style=plain'

alias vim="nvim"
alias vima="NVIM_APPNAME='nvim_alt' vim"

alias ds="du -Sh | sort -n -r | less"

alias tat="__tmux_attach.sh"
alias ses="__tmux_sessionizer.sh"
alias nts="__add_repo_notes.sh"

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

function venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    else
        if [ -d "venv" ]; then
            source venv/bin/activate
        elif [ -d ".venv" ]; then
            source .venv/bin/activate
        else
            echo "Python virtual environment not found in the current directory."
        fi
    fi
}

function cds() {
  session=$(tmux display-message -p '#{session_path}')
  cd "$session"
}

function cdir() {
    mkdir -p "$1" && cd "$1";
}

function extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1;;
             *.tar.gz)    tar xzf $1;;
             *.tar.xz)    tar xvf $1;;
             *.bz2)       bunzip2 $1;;
             *.rar)       rar x $1;;
             *.gz)        gunzip $1;;
             *.tar)       tar xf $1;;
             *.tbz2)      tar xjf $1;;
             *.tgz)       tar xzf $u;;
             *.zip)       unzip $1;;
             *.Z)         uncompress $1;;
             *.7z)        7z x $1;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

. "$HOME/.local/bin/env"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi


export EDITOR=nvim
export VISUAL=nvim

export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/opt/nvim-linux64/bin
export PATH="$HOME/.dotfiles/scripts:$PATH"

# mason installed lsps and tools
export PATH=$PATH:$HOME/.local/share/nvim/mason/bin

export FZF_DEFAULT_OPTS="--color=gutter:-1"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export MANPAGER='nvim --clean +Man!' 

# Default tmux session on shell startup
if [[ -z "$TMUX" && -o interactive && "$TERM_PROGRAM" != "tmux" ]]; then
    # for zsh: check if running in tmux as 'tmux new-window "command"'
    # sources .zshrc and __tmux_attach runs instead
    __tmux_attach.sh
fi

source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/usr/share/doc/fzf/examples/key-bindings.zsh"
source "/usr/share/doc/fzf/examples/completion.zsh"

# Remove underline for dirs and commands
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_pathseparator]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=none
ZSH_HIGHLIGHT_STYLES[precommand]=none

# Keybinds
bindkey -s '^F' "__tmux_sessionizer.sh\n"
bindkey -s '^G' "__fuzzy_finder.sh\n"
bindkey -s '^B' "ranger\n"
bindkey '^Y' autosuggest-accept
bindkey '^E' fzf-cd-widget

eval "$(starship init zsh)"

# zprof
