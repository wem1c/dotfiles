# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/conor/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall

# Enable plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

### CUSTOM SETTINGS
## Aliases
alias ls="exa -lh"
alias sudo="sudo "
alias dotfiles="/usr/bin/env git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias pacdiff="DIFFPROG=delta pacdiff"
alias arch-rankmirrors="sudo reflector --protocol https --verbose --latest 25 --sort rate --save /etc/pacman.d/mirrorlist"
alias eos-rankmirrors="eos-rankmirrors --sort rate"

# pip
alias pir='pip install -r requirements.txt'

# Django
alias dj="python manage.py"
alias djrs="python manage.py runserver"
alias djsh="python manage.py shell"
alias djm="python manage.py migrate"
alias djmm="python manage.py makemigrations"
alias djmmm="python manage.py makemigrations & python manage.py migrate"
alias djcd="python manage.py check --deploy"

# systemctl
alias sc="systemctl"
alias scsr="systemctl start"
alias scsp="systemctl stop"
alias scr="systemctl restart"
alias sce="systemctl enable"
alias scen="systemctl enable --now"
alias scd="systemctl disable"
alias scs="systemctl status"

## Environment Variables
export BAT_THEME=OneHalfLight

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

## Arrow-driven autocompletion
zstyle ':completion:*' menu select

## Keybinds
bindkey ';5D' backward-word
bindkey ';5C' forward-word
bindkey ';6D' beginning-of-line
bindkey ';6C' end-of-line

# Kitty
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;7C' end-of-line
bindkey '^[[1;7D' beginning-of-line


## Load Starship prompt
eval "$(starship init zsh)"

## Load FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
