
#!/usr/bin/env sh
#
# Big Thanks to Senioradmin for this script, it's be a big help to me : https://codeberg.org/senioradmin/alpine-sway 
set -eu

##### VARIABLES #####
PATH_TO_REPO="/etc/apk/repositories"
BACKUP_SUFFIX=".bak-$(date +%Y%m%d%H%M)"
# CONTAINER_NAME="arch-JV"
# CONTAINER_IMAGE="archlinux:latest"
if [ "$(id -u)" -eq 0 ]; then
    USER="$(logname 2>/dev/null || echo root)"
else
    USER="$(id -un)"
fi

USER_UID="$(id -u ${USER})"

clear
echo "###############################################################"
echo "SCRIPT de POST-INSTALLATION ALPINE LINUX"
echo "###############################################################"


echo "###############################################################"
echo "sauvegarde des dépot actuels" 
cp "${PATH_TO_REPO}" "${PATH_TO_REPO}${BACKUP_SUFFIX}"

echo "###############################################################"
echo "[INFO] Configuration des dépôts (edge + testing)..."
cat > "${PATH_TO_REPO}" <<EOF
http://mirrors.hostico.ro/alpinelinux/edge/main
http://mirrors.hostico.ro/alpinelinux/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://alpinelinux.mirrors.ovh.net/edge/main
http://alpinelinux.mirrors.ovh.net/edge/community
@testing http://mirrors.hostico.ro/alpinelinux/edge/testing
EOF
echo "[OK] Dépôts configurés"
echo
##### MAJ sys #####
echo "###############################################################"
echo "[INFO] Mise à jour du système..."
apk update && apk upgrade --available
echo "[OK] Système mis à jour"
echo

##### ESSENTIAL PACKAGE #####
echo "###############################################################"
echo "[INFO] Installation des paquets essentiels..."
apk add alpine-base zsh binutils font-dejavu firefox-esr elogind kitty greetd greetd-agreety grep grim slurp btop iproute2 linux-firmware-amd linux-firmware-amd-ucode linux-stable linux-pam mc mousepad neovim openssh openssl pciutils procps rofi fastfetch lshw gamemode@testing ethtool sway swaylock swaylockd thunar thunar-archive-plugin nftables thunar-volman-plugin ffmpeg udev-init-scripts udev-init-scripts-openrc usbutils util-linux waybar sway-zsh-completion swaync swaync-zsh-completion yad xdg-user-dirs brightnessctl wf-recorder xdg-utils gvfs gvfs-mtp gvfs-nfs pamixer polkit-gnome network-manager-applet playerctl xdg-desktop-portal-wlr jq mpd swww swayimg ncmpcpp  swayidle wl-clipboard xwayland ly pipewire pipewire-pulse pipewire-alsa pavucontrol wireplumber mesa-dri-gallium mesa-va-gallium mesa-vulkan-ati vulkan-headers vulkan-tools libdrm libinput distrobox font-noto font-noto-cjk font-noto-emoji font-jetbrains-mono-nerd font-awesome font-raleway font-manager font-manager-thunar wlsunset openrc-user libinput-zsh-completion 
echo "[OK] Installation terminée"
echo

echo "###############################################################"
echo "[INFO] Configuration des services système..."
# setup services
setup-devd udev
rc-update add elogind
rc-update add dbus
#adduser ${USER} seat
#adduser greetd seat
adduser ${USER} video
adduser ${USER} input
adduser ${USER} audio
adduser greetd video
echo "Activation des services utilisateur OpenRC"

# Activation du service utilisateur pour l'utilisateur
# Activation du service utilisateur OpenRC
rc-update -U add pipewire default
rc-update -U add pipewire-pulse default
rc-update -U add wireplumber default
echo "activation de pipewire" 
rc-service -U pipewire start
# config greetd
cat > /etc/conf.d/greetd <<EOF
# Configuration pour /etc/init.d/greetd
#cfgfile="/etc/greetd/config.toml"
EOF

cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 2

[default_session]
command = agreety --cmd "dbus-run-session sway"
user = "greetd"
EOF
rc-update add greetd
echo "[OK] Services système configurés"
echo
####### Set manually XDG_RUNTIME_DIR if neccesary

# cat << EOF > /home/${USER}/.profile
# if [ -z "$XDG_RUNTIME_DIR" ]; then
#   XDG_RUNTIME_DIR="/run/user/$(id -u)"
#   mkdir -pm 0700 \$XDG_RUNTIME_DIR
#   export XDG_RUNTIME_DIR
# fi
# export TERMINAL=foot
# EOF

# chown ${USER}: /home/${USER}/.profile


#echo "###############################################################"
#echo " creation du conteneur Arch"
#su - "${USER}" -c "distrobox-create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}" "
#su - "${USER}" -c "distrobox-enter ${CONTAINER_NAME} -- sh -c "pacman -Syu --noconfirm \
#        steam lutris \
#        wine winetricks \
#        lib32-vulkan-radeon vulkan-radeon \
#        lib32-mesa mesa \
#        gamemode lib32-gamemode \
#        mangohud lib32-mangohud umu-launcher
#" "

##### SCRIPTS UTILES #####
#echo "###############################################################"
#echo "  Création des scripts utiles"

#echo "Création du répertoire Wallpapers"
#doas -u "${USER}" mkdir -p "/home/${USER}/Images/Wallpapers"

#echo "Script pour démarrer Steam"
#doas -u "${USER}" sh -c "
#cat > /home/${USER}/start-gaming <<'GAMINGEOF'
##!/bin/sh
# Script pour démarrer Steam dans distrobox
#export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\"
#echo \" Démarrage de Steam ...\"
#distrobox-enter arch-JV -- steam
#GAMINGEOF
#chmod +x /home/${USER}/start-gaming
#"

#echo " Script d'entrée dans le conteneur"
#doas -u "${USER}" sh -c "
#cat > /home/${USER}/gaming-shell <<'SHELLEOF'
##!/bin/sh
## Script pour ouvrir un shell dans le conteneur gaming
#export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\"
#echo \" ouverture de la distrobox arch-JV...\"
#distrobox-enter arch-JV
#SHELLEOF
#chmod +x /home/${USER}/gaming-shell
#"

#echo  "Script pour sélectionner des wallpapers avec rofi"
#doas -u "${USER}" sh -c "
#cat > /home/${USER}/wallpaper-picker <<'WALLPAPEREOF'
##!/bin/sh
## Script pour sélectionner et appliquer un wallpaper avec rofi + swww

#WALLPAPER_DIR=\"/home/${USER}/Images/Wallpapers\"

## Vérifier que le répertoire existe
#if [ ! -d \"\$WALLPAPER_DIR\" ]; then
#    echo \"Erreur: Le répertoire \$WALLPAPER_DIR n'existe pas\"
#    exit 1
#fi

## Vérifier qu'il y a des images
#if [ -z \"\$(find \"\$WALLPAPER_DIR\" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) 2>/dev/null)\" ]; then
#    echo \"Aucune image trouvée dans \$WALLPAPER_DIR\"
#    echo \"Formats supportés: jpg, jpeg, png, webp, bmp\"
#    exit 1
#fi

## Lister les images et les afficher avec rofi
#cd \"\$WALLPAPER_DIR\"
#SELECTED=\$(find . -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | sed 's|^\./||' | sort | rofi -dmenu -i -p \"Choisir un wallpaper\")
#
## Si une sélection a été faite
#if [ -n \"\$SELECTED\" ]; then
#    WALLPAPER_PATH=\"\$WALLPAPER_DIR/\$SELECTED\"
#    echo \" Application du wallpaper: \$SELECTED\"
#    swww img \"\$WALLPAPER_PATH\"
#    if [ \$? -eq 0 ]; then
#        echo \" Wallpaper appliqué avec succès\"
#    else
#        echo \" Erreur lors de l'application du wallpaper\"
#    fi
#else
#    echo \"Aucune sélection\"
#fi
#WALLPAPEREOF
#chmod +x /home/${USER}/wallpaper-picker
#"

##### FINALISATION #####
echo "###############################################################"
echo "[INFO] Finalisation de l'installation"
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/pipewire


cat <<EOF
═══════════════════════════════════════════════════════════════
  TERMINÉE ! 
═══════════════════════════════════════════════════════════════

PROCHAINES ÉTAPES :

  REDÉMARRER LE SYSTÈME :
   doas reboot

  DÉMARRER SWAY :
   sway

  CONFIGURATION :
   • Sway : ~/.config/sway/config
   • Waybar : ~/.config/waybar/
   • Wallpapers : ~/.local/share/wallpapers/

  SERVICES ACTIVÉS :
   • Services système : dbus, elogind
   • Services utilisateur OpenRC : pipewire, pipewire-pulse, wireplumber

 INTERFACE :
   • Compositeur : Sway (Wayland)
   • Barre : Waybar   
   • Notifications : swaync
   • Fond d'écran : swww + rofi menu
   • Terminal : Kitty
   • Lanceur : rofi

═══════════════════════════════════════════════════════════════
EOF


echo "[INFO]Redémarrage dans 35 secondes . . . "
sleep 35 && doas reboot
