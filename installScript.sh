#!/usr/bin/env sh
set -euo

##### VARIABLES #####
PATH_TO_REPO="/etc/apk/repositories"
BACKUP_SUFFIX=".bak-$(date +%Y%m%d%H%M)"
CONTAINER_NAME="arch-JV"
CONTAINER_IMAGE="archlinux:latest"
USER="${SUDO_USER:-$(whoami)}"
USER_UID="$(id -u ${USER})"

echo "###############################################################"
echo "SCRIPT POST-INSTALLATION ALPINE LINUX GAMING"
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

echo "###############################################################"
echo "activation de elogind et dbus"
rc-update add dbus default
rc-update add elogind default
service dbus start
service elogind start


echo "###############################################################"
echo " creation du conteneur JV"
doas -u "${USER}" distrobox-create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}" --persistent-home --pkgmanager pacman --as-root
doas -u "${USER}" distrobox-enter ${CONTAINER_NAME} -- sh -c "set -euo pacman -S --noconfirm \
        steam lutris \
        wine winetricks \
        lib32-vulkan-radeon vulkan-radeon \
        lib32-mesa mesa \
        gamemode lib32-gamemode \
        mangohud lib32-mangohud umu-launcher
"

##### SCRIPTS UTILES #####
echo "###############################################################"
echo "  Création des scripts utiles"

# Création du répertoire Wallpapers
doas -u "${USER}" mkdir -p "/home/${USER}/Images/Wallpapers"

# Script pour démarrer Steam
doas -u "${USER}" sh -c "
cat > /home/${USER}/start-gaming <<'GAMINGEOF'
#!/bin/sh
# Script pour démarrer Steam dans distrobox
export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\"
echo \" Démarrage de Steam ...\"
distrobox-enter arch-JV -- steam
GAMINGEOF
chmod +x /home/${USER}/start-gaming
"

# Script d'entrée dans le conteneur
doas -u "${USER}" sh -c "
cat > /home/${USER}/gaming-shell <<'SHELLEOF'
#!/bin/sh
# Script pour ouvrir un shell dans le conteneur gaming
export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\"
echo \" ouverture de la distrobox arch-JV...\"
distrobox-enter arch-JV
SHELLEOF
chmod +x /home/${USER}/gaming-shell
"

# Script pour sélectionner des wallpapers avec rofi
doas -u "${USER}" sh -c "
cat > /home/${USER}/wallpaper-picker <<'WALLPAPEREOF'
#!/bin/sh
# Script pour sélectionner et appliquer un wallpaper avec rofi + swww

WALLPAPER_DIR=\"/home/${USER}/Images/Wallpapers\"

# Vérifier que le répertoire existe
if [ ! -d \"\$WALLPAPER_DIR\" ]; then
    echo \"Erreur: Le répertoire \$WALLPAPER_DIR n'existe pas\"
    exit 1
fi

# Vérifier qu'il y a des images
if [ -z \"\$(find \"\$WALLPAPER_DIR\" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) 2>/dev/null)\" ]; then
    echo \"Aucune image trouvée dans \$WALLPAPER_DIR\"
    echo \"Formats supportés: jpg, jpeg, png, webp, bmp\"
    exit 1
fi

# Lister les images et les afficher avec rofi
cd \"\$WALLPAPER_DIR\"
SELECTED=\$(find . -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | sed 's|^\./||' | sort | rofi -dmenu -i -p \"Choisir un wallpaper\")

# Si une sélection a été faite
if [ -n \"\$SELECTED\" ]; then
    WALLPAPER_PATH=\"\$WALLPAPER_DIR/\$SELECTED\"
    echo \" Application du wallpaper: \$SELECTED\"
    swww img \"\$WALLPAPER_PATH\"
    if [ \$? -eq 0 ]; then
        echo \" Wallpaper appliqué avec succès\"
    else
        echo \" Erreur lors de l'application du wallpaper\"
    fi
else
    echo \"Aucune sélection\"
fi
WALLPAPEREOF
chmod +x /home/${USER}/wallpaper-picker
"

##### FINALISATION #####
echo "###############################################################"
echo " Création du répertoire de configuration"
doas -u "${USER}" sh -c "
    mkdir -p ~/.config/sway
    mkdir -p ~/.config/waybar
    mkdir -p ~/.config/pipewire
"

#### CONFIGURATION UTILISATEUR #####
echo "###############################################################"
echo " Configuration de l'utilisateur ${USER}"
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
  TERMINÉE ! 
═══════════════════════════════════════════════════════════════

PROCHAINES ÉTAPES :

  REDÉMARRER LE SYSTÈME :
   sudo reboot

  DÉMARRER SWAY :
   sway

  SCRIPTS DISPONIBLES DANS VOTRE HOME :
   ./start-gaming           # Démarre Steam
   ./gaming-shell          # rentré dans la distrobox
   ./wallpaper-picker      # selection du wallpaper avec rofi

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
