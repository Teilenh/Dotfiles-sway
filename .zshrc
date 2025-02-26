export XDG_RUNTIME_DIR=/run/user/$(id -u)
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

alias LaunchHypr='dbus-run-session Hyprland'
export XDG_CONFIG_HOME="$HOME/.config"
export FONTCONFIG_FILE="XDG_CONFIG_HOME/fontconfig/fonts.conf"

export $(dbus-launch)
# Spécifier le chemin des commandes
export PATH="$HOME/bin:$PATH"

# Thème et couleurs
autoload -U colors && colors
export ZSH_COLOR="on"

# Activer l'autocomplétion
autoload -Uz compinit
compinit

# Activer l'historique
HISTSIZE=2000
SAVEHIST=2000
HISTFILE=~/.zsh_history

# Options pour l'historique
setopt append_history
setopt share_history

# Activer la complétion avancée
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
PROMPT='%F{yellow}%n %F{blue}• [%F{yellow}%~%f%F{blue}]%f %F{cyan}➜ %f'  # Utilisateur • [répertoire] ➜

# --- Configuration de l'autocomplétion avancée ---

# Activer l'autocomplétion Zsh
autoload -U compinit
compinit

# Activer les options d'autocomplétion
zstyle ':completion:*' menu select    # Afficher le menu de complétion avec des flèches
zstyle ':completion:*' list-colors 'yes'  # Activer les couleurs dans les suggestions
zstyle ':completion:*:default' matcher-list 'm:{a-z}={A-Z}'  # Complétion insensible à la casse
zstyle ':completion:*:*:*:*' completion 10

# Définir un délai d'attente pour l'autocomplétion
zstyle ':completion:*' completer _complete _expand _approximate
zstyle ':completion:*' file-patterns '*(.D)'

# Configurer la sortie de l'environnement graphique avec Sway
export SWAYSOCK=$(find /run/user/$(id -u) -name 'wayland-0')

# Définir des variables d'environnement pour OpenRC si nécessaire
export PATH=$PATH:/etc/init.d

# --- Paramètres de session ---

# Paramètres pour l'optimisation de la performance
setopt HIST_IGNORE_ALL_DUPS  # Ignore les doublons dans l'historique
setopt INC_APPEND_HISTORY  # Ajouter les commandes au fichier d'historique au fur et à mesure

alias GLFfetch="$(which fastfetch) --config ~/.config/fastfetch/GLFfetch/challenge.jsonc"
