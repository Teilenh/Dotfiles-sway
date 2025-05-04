export XDG_RUNTIME_DIR=/run/user/$(id -u)
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

export XDG_CONFIG_HOME="$HOME/.config"
export FONTCONFIG_FILE="XDG_CONFIG_HOME/fontconfig/fonts.conf"

export $(dbus-launch)
# The following lines were added by compinstall
zstyle :compinstall filename '/home/teilen/.zshrc'

export PATH="$HOME/bin:$PATH"
export VISUAL=nano
export EDITOR=nano
# Thème et couleurs
autoload -U colors && colors
export ZSH_COLOR="on"

# autocomplétion
autoload -Uz compinit
compinit

# historique
HISTSIZE=2000
SAVEHIST=2000
HISTFILE=~/.zsh_history
setopt append_history
setopt share_history

# complétion avancée
setopt auto_cd              # Aller directement dans un répertoire en tapant son nom
setopt correct              # Corriger les fautes de frappe
setopt auto_list            # Lister les options d'achèvement
setopt glob_complete        # Compléter les glob patterns

# Alias utiles
alias ls='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../../'

# Prompt personnalisé
PROMPT='%F{magenta}%n %F{yellow}• [%F{white}%~%f%F{yellow}]%f %F{cyan}➜ %f'  # Utilisateur • [répertoire] ➜

# Activer les options d'autocomplétion
zstyle ':completion:*' menu select    # Afficher le menu de complétion avec des flèches
zstyle ':completion:*' list-colors 'yes'  # Activer les couleurs dans les suggestions
zstyle ':completion:*:default' matcher-list 'm:{a-z}={A-Z}'  # Complétion insensible à la casse

# --- Paramètres de session ---

# Paramètres pour l'optimisation de la performance
setopt HIST_IGNORE_ALL_DUPS  # Ignore les doublons dans l'historique
setopt INC_APPEND_HISTORY  # Ajouter les commandes au fichier d'historique au fur et à mesure

alias GLFfetch="$(which fastfetch) --logo-type kitty-direct --config ~/.config/fastfetch/GLFfetch/challenge.jsonc"
alias CavaBG="bash ~/.config/hypr/scripts/backgroundKitten.sh"
alias Musique="mpv ~/Musique/*"


# Configurer sortie de l'environnement avec Sway
export SWAYSOCK=$(find /run/user/$(id -u) -name 'wayland-0')
# variables d'environnement pour OpenRC
export PATH=$PATH:/etc/init.d

