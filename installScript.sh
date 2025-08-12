#!/usr/bin/env sh

set -euo pipefail

##### VAR #####
PATH_TO_REPO="/etc/apk/repositories"
BACKUP_SUFFIX=".bak-$(date + %Y%m%d%H%M )"
CONTAINER_NAME="arch-JV"
CONTAINER_IMAGE="archlinux:latest"
USER="${SUDO_USER:-$(whoami)}"
USER_UID="$(ID -u ${USER})"


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
echo "Installation des package essentiel"
apk add sway sway bg waybar swaync mako pipewire pipewire-pulse pipewire-alsa wireplumber mesa@edge mesa-vulkan-amd@edge vulkan-headers@edge libdrm@edge libinput@edge podman-distro distrobox seatd seatd-openrc


echo "###############################################################"
echo "activation de seatd"
rc-update add seatd default
service seatd start


echo "###############################################################"
echo " creation du conteneur JV"
doas -u "${USER}" distrobox-create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}" --persistent-home --pkgmanager pacman --as-root
doas -u "${USER}" distrobox-enter ${CONTAINER_NAME} -- sh -c "set -euo pipefail pacman -Syu --noconfirm steam lutris proton-ge-custom proton-plus umu-launcher"


echo "###############################################################"
ECHO "activation de pipewire" 
rc-update -U add pipewire
rc-service -U pipewire start

