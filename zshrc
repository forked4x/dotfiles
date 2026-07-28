export EDITOR=nvim
export MANPAGER="nvim +Man!"
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt globdots # glob (*) finds hidden files

function ls() { /bin/ls -al --color "$@" | less -FRS }
function lt()  { /bin/ls -alt --color "$@" | less -FRS }
function lS()  { /bin/ls -alS --color "$@" | less -FRS }
function mkcd() { mkdir -p "$@" && cd "$@"; }
function s() {
    kitten ssh --kitten login_shell=zsh $@
    if [ $? -eq 127 ]; then kitten ssh --kitten $@; fi
}
function tpclean() { # drop TablePlus query history dupes, keeping the day's first run
    local h="$HOME/Library/Application Support/com.tinyapp.TablePlus/Data/History"
    find "$h" -name '*.sql' -type f -print0 | sort -z | xargs -0 md5 -r | awk '
        { p = substr($0, 34); d = p; sub(/\/[^\/]*$/, "", d); k = $1 d
          if (k in seen) { n++; printf "%s%c", p, 0 } else seen[k] = 1 }
        END { printf "removing %d duplicate queries\n", n > "/dev/stderr" }' | xargs -0 rm
}
alias cc="claude --allow-dangerously-skip-permissions --permission-mode plan"
alias codex="codex --dangerously-bypass-approvals-and-sandbox"
alias v="nvim"
alias uuid="uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n' | tee >(pbcopy)"

export HOMEBREW_NO_ASK=1
export HOMEBREW_NO_ENV_HINTS=1

if [[ $(uname) == "Darwin" ]]; then
    if [[ ! -d /opt/homebrew ]]; then
        xcode-select --install
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew bundle --file=~/.dotfiles/Brewfile
        ln -sf /opt/homebrew/bin/python3 /opt/homebrew/bin/python
        ln -sf /opt/homebrew/bin/pip3 /opt/homebrew/bin/pip
        curl -L "https://www.python.org/ftp/python/2.7.18/python-2.7.18-macosx10.9.pkg" \
            --output ~/Downloads/python-2.7.18-macosx10.9.pkg
        open -W ~/Downloads/python-2.7.18-macosx10.9.pkg
    fi
    if [[ ! -d ~/.dotfiles ]]; then
        git clone git@github.com:forked4x/dotfiles.git ~/.dotfiles
        git config --global core.excludesFile ~/.dotfiles/.gitignore
        ln -sf ~/.dotfiles/zshrc ~/.zshrc
        touch ~/.hushlogin
        defaults -currentHost write -globalDomain NSStatusItemSpacing -int 8
        defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6
    fi
    if [[ ! -d ~/.config/hammerspoon ]]; then
        defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
        mkdir -p ~/.config/hammerspoon
        ln -sf ~/.dotfiles/hammerspoon.lua ~/.config/hammerspoon/init.lua
    fi
    if [[ ! -d ~/.config/kitty ]]; then
        mkdir -p ~/.config/kitty
        ln -sf ~/.dotfiles/kitty.conf ~/.config/kitty/kitty.conf
        echo "protocol file" > ~/.config/kitty/launch-actions.conf
        echo "action launch --type=os-window -- \$EDITOR -- \$FILE_PATH" >> ~/.config/kitty/launch-actions.conf
        echo "copy --dest .Brewfile .dotfiles/Brewfile" > ~/.config/kitty/ssh.conf
        echo "copy --dest .config/nvim/init.lua .dotfiles/neovim.lua" >> ~/.config/kitty/ssh.conf
        echo "copy --dest .gitignore .dotfiles/.gitignore" >> ~/.config/kitty/ssh.conf
        echo "copy --dest .zshrc .dotfiles/zshrc" >> ~/.config/kitty/ssh.conf
        curl -Lo ~/.config/kitty/kitty-dark.icns https://github.com/DinkDonk/kitty-icon/raw/refs/heads/main/kitty-dark.icns
        fileicon set /Applications/kitty.app ~/.config/kitty/kitty-dark.icns
        killall Dock
    fi
    if [[ ! -d ~/.config/nvim ]]; then
        mkdir -p ~/.config/nvim
        ln -sf ~/.dotfiles/neovim.lua ~/.config/nvim/init.lua
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    eval "$(zoxide init zsh)"
    export PATH="$PATH:$HOME/go/bin"

elif [[ $(uname) == "Linux" ]]; then
    if [[ ! -d /home/linuxbrew ]]; then
        echo "Homebrew not installed."
        function brew() {
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            unset -f brew
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            brew bundle --file=~/.Brewfile
            git config --global core.excludesFile ~/.gitignore
            ln -sf /home/linuxbrew/.linuxbrew/bin/python3 /home/linuxbrew/.linuxbrew/bin/python
            ln -sf /home/linuxbrew/.linuxbrew/bin/pip3 /home/linuxbrew/.linuxbrew/bin/pip
            eval "$(zoxide init zsh)"
        }
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        eval "$(zoxide init zsh)"
    fi
fi

# Plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
declare -A ZINIT; ZINIT[NO_ALIASES]=1; source "${ZINIT_HOME}/zinit.zsh"

zinit light sindresorhus/pure
zinit light jeffreytse/zsh-vi-mode
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # smartcase completion
autoload -Uz compinit && compinit

if command -v fzf >/dev/null 2>&1; then
    zinit ice lucid wait
    zinit snippet OMZP::fzf
    zinit light Aloxaf/fzf-tab
    export FZF_DEFAULT_OPTS="--bind 'tab:accept'"
    zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
fi

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zle_highlight+=(paste:none)
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
