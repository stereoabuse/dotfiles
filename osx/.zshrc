# Update your PATH if needed
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Oh-my-zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Theme settings
ZSH_THEME="robbyrussell"
# Uncomment to choose random themes from this list
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment to enable case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment to enable hyphen-insensitive completion
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to manage auto-update behavior
# zstyle ':omz:update' mode disabled  # Disable automatic updates
# zstyle ':omz:update' mode auto      # Update automatically without asking
# zstyle ':omz:update' mode reminder  # Remind to update when it's time

# Uncomment to set how often to auto-update (in days)
# zstyle ':omz:update' frequency 13

# Uncomment if pasting URLs or other text gets messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable command auto-correction
# ENABLE_CORRECTION="true"

# Uncomment to show red dots while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment to speed up repository status checks for large repos
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment to change history timestamp format
# HIST_STAMPS="mm/dd/yyyy"

# Use a custom folder instead of $ZSH/custom
# ZSH_CUSTOM=/path/to/new-custom-folder

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# Uncomment to manually set language environment
# export LANG=en_US.UTF-8

# Set preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Custom aliases and exports

# Move frequently updated paths to the top for easy editing
export PATH="/usr/local/Cellar/poppler/[version]/bin:$PATH"

# Aliases
alias python3="/usr/local/bin/python3.12"
alias today="~/.scripts/today"
alias ai="python3 ai"
alias ll="ls -la"
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
alias refresh="source ~/.zshrc"
alias c="clear"
alias h="history"
alias mkdirp="mkdir -p"
alias mkcd='function mkcd() { mkdir -p "$1" && cd "$1"; }'

# --- End of Oh-My-Zsh Setup ---
# --- User Configuration ---
