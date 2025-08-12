#!/usr/bin/env sh
set -euo pipefail

##### VARIABLES #####
PATH_TO_REPO="/etc/apk/repositories"
BACKUP_SUFFIX=".bak-$(date +%Y%m%d%H%M)"
CONTAINER_NAME="arch-JV"
CONTAINER_IMAGE="archlinux:latest"
USER="${SUDO_USER:-$(whoami)}"
USER_UID="$(id -u ${USER})"

echo "###############################################################"
echo "🚀 SCRIPT POST-INSTALLATION ALPINE LINUX GAMING"
echo "###############################################################"


echo "###############################################################"
echo "sauvegarde des dépot actuels" 
cp "${PATH_TO_REPO}" "${PATH_TO_REPO}${BACKUP_SUFFIX}"

echo "###############################################################"
echo "Configuration des dépots edge"
cat > "${PATH_TO_REPO}" <<EOF 
http://mirrors.ircam.fr/pub/alpine/v$(cut -d. -f1-2 /etc/alpine-release)/main
http://mirrors.ircam.fr/pub/alpine/v$(cut -d. -f1-2 /etc/alpine-release)/community
http://mirrors.ircam.fr/pub/alpine/edge/main @edge
http://mirrors.ircam.fr/pub/alpine/edge/community @edge
http://mirrors.ircam.fr/pub/alpine/edge/testing @testing
EOF

##### MAJ sys #####
echo "MAJ systéme"
apk update && apk upgrade --available

##### ESSENTIAL PACKAGE #####
echo "###############################################################"
echo "Installation des packages essentiels"
apk add sway swww swayimg waybar kitty swaync sway-zsh-completion swaync-zsh-completion ly pipewire pipewire-openrc pipewire-tools pipewire-pulse-openrc pipewire-alsa wireplumber wireplumber-openrc mesa-dri-gallium@edge mesa-va-gallium@edge mesa-vulkan-ati@edge vulkan-headers@edge vulkan-tools@edge libdrm@edge libinput@edge distrobox elogind elogind-openrc dbus dbus-openrc font-noto terminus-font rofi-wayland wlsunset wlsunset-openrc firefox-esr openrc-user@edge libinput-zsh-completion

apk add ibdrm@edge libinput@edge distrobox dbus dbus-openrc elogind elogind-openrc font-noto terminus-font firefox openrc-user@edge

echo "###############################################################"
echo "activation de elogind et dbus"
rc-update add dbus default
rc-update add elogind default
service dbus start
service elogind start


echo "###############################################################"
echo " creation du conteneur JV"
doas -u "${USER}" distrobox-create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}" --persistent-home --pkgmanager pacman --as-root
doas -u "${USER}" distrobox-enter ${CONTAINER_NAME} -- sh -c "set -euo pipefail pacman -S --noconfirm \
        steam lutris \
        wine winetricks \
        lib32-vulkan-radeon vulkan-radeon \
        lib32-mesa mesa \
        gamemode lib32-gamemode \
        mangohud lib32-mangohud umu-launcher
"


echo "###############################################################"


#### CONFIGURATION UTILISATEUR #####
echo "###############################################################"
echo "👤 Configuration de l'utilisateur ${USER}"
addgroup "${USER}" input 2>/dev/null || true
addgroup "${USER}" video 2>/dev/null || true
addgroup "${USER}" audio 2>/dev/null || true

##### ACTIVATION DES SERVICES UTILISATEUR #####
echo "###############################################################"
echo "🔧 Activation des services utilisateur OpenRC"

# Activation du service utilisateur pour l'utilisateur
doas -u "${USER}" sh -c "
    # Activation du service utilisateur OpenRC
    rc-update -U add pipewire default
    rc-update -U add pipewire-pulse default
    rc-update -U add wireplumber default
ECHO "activation de pipewire" 
rc-update -U add pipewire
rc-service -U pipewire start
    
    # Création des répertoires de configuration
    mkdir -p ~/.config/sway
    mkdir -p ~/.config/waybar
    mkdir -p ~/.config/pipewire
    mkdir -p ~/.local/share/wallpapers
"


cat <<EOF
═══════════════════════════════════════════════════════════════
 🎮 POST-INSTALLATION ALPINE LINUX GAMING TERMINÉE ! 🎮
═══════════════════════════════════════════════════════════════

PROCHAINES ÉTAPES :

  REDÉMARRER LE SYSTÈME :
   sudo reboot

  DÉMARRER SWAY :
   sway

  SCRIPTS DISPONIBLES DANS VOTRE HOME :
   ./start-gaming           # Démarrer Steam
   ./gaming-shell          # Shell dans le conteneur  
   ./wallpaper-picker      # Sélecteur de wallpaper avec rofi

  GESTION DES WALLPAPERS :
   • Placez vos images dans ~/Images/Wallpapers/
   • Lancez ./wallpaper-picker pour choisir
   • Formats: jpg, jpeg, png, webp, bmp

  SERVICES UTILISATEUR (dans Sway) :
   rc-service --user pipewire start
   rc-service --user pipewire-pulse start
   rc-service --user wireplumber start

  CONFIGURATION :
   • Sway : ~/.config/sway/config
   • Waybar : ~/.config/waybar/
   • Conteneur gaming : arch-JV (Arch Linux)
   • Wallpapers : ~/.local/share/wallpapers/

  SERVICES ACTIVÉS :
   • Services système : dbus, elogind
   • Services utilisateur OpenRC : pipewire, pipewire-pulse, wireplumber
   • Conteneur gaming avec Steam, Lutris, Wine

 INTERFACE :
   • Compositeur : Sway (Wayland)
   • Barre : Waybar   
   • Notifications : swaync
   • Fond d'écran : swww + rofi picker
   • Terminal : Kitty
   • Lanceur : rofi-wayland

═══════════════════════════════════════════════════════════════
EOF
