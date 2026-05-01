export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export STARSHIP_CACHE=~/.starship/cache
eval "$(starship init zsh)"

# Format man pages
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Node.js (bundled ICU)
export PATH="/opt/node/bin:$PATH"


######################
### Key Bindings  ####
######################
# Enable vim bindings
bindkey -v

# Zsh-specific settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt BANG_HIST
setopt appendhistory
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_ignore_space
setopt extended_history

##################
### Functions  ###
##################
# Backup function
backup() {
  if [[ -n "$1" ]]; then
    cp "$1" "$1.bak"
  else
    echo "Usage: backup <filename>"
  fi
}

# Enhanced copy function
copy() {
  local count=$#
  if [[ $count -eq 2 ]] && [[ -d "$1" ]]; then
    local from="${1%/}"  # Remove trailing slash
    local to="$2"
    command cp -r "$from" "$to"
  else
    command cp "$@"
  fi
}

# mkcd DIR
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  local file="$1"
  if [[ -f "$file" ]]; then
    case "$file" in
      *.tar.bz2) tar xjf "$file" ;;
      *.tar.gz) tar xzf "$file" ;;
      *.bz2) bunzip2 "$file" ;;
      *.rar) unrar x "$file" ;;
      *.gz) gunzip "$file" ;;
      *.tar) tar xvf "$file" ;;
      *.tbz2) tar xjf "$file" ;;
      *.tgz) tar xzf "$file" ;;
      *.zip) unzip "$file" ;;
      *.Z) uncompress "$file" ;;
      *.7z) 7z x "$file" ;;
      *) echo "'$file' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$file' is not a valid file"
  fi
}

##################
### Aliases    ###
##################
# ls replacements (matching fish exactly)
alias la='eza -al --color=always --group-directories-first --icons'
alias ls='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.='eza -a | grep -e "^\."'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Shortcuts
alias please='sudo'
alias ff='fastfetch'
alias q='exit'
alias h='history'
alias c='clear'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcl='git clone'
alias gl='git log --oneline'
alias gd='git diff'
alias gpush='git push'
alias gpull='git pull'

# Zsh-specific aliases
alias zshconfig='$EDITOR ~/.config/zsh/config.zsh'

# Zsh-specific plugins
source $HOME/.config/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
