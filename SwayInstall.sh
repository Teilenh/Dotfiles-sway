#!/bin/sh
#
# Big Thanks to Senioradmin for this script, it's be a big help to me : https://codeberg.org/senioradmin/alpine-sway 


set -e

echo "Launch the post install script :" 
echo "To continue press RETURN, to abort Ctrl-c"
read n

sed -i '/community/s/^#//g' /etc/apk/repositories

# save old world
cp /etc/apk/world  /tmp/world

# Packages to install
cat << EOF > /etc/apk/world
alpine-base
zsh
binutils
busybox-mdev-openrc
coreutils
dbus
dosfstools
e2fsprogs
eudev
evince
findutils
font-dejavu
firefox-esr
kitty
greetd
greetd-agreety
grep
grim
slurp
btop
iproute2
linux-firmware-other
linux-lts
linux-pam
libinput
mc
mousepad
nano
openssh
openssl
pciutils
procps
rofi-wayland
seatd-launch
shadow
shadow-login
sway
swaylock
swaylockd
swaylock-effects
thunar
udev-init-scripts
udev-init-scripts-openrc
usbutils
util-linux
waybar
sway-zsh-completion
swaync
swaync-zsh-completion
yad
xdg-user-dirs
brightnessctl
wf-recorder
xdg-utils
gvfs
gvfs-mtp
gvfs-nfs
cliphist
pamixer
polkit-gnome
network-manager-applet
playerctl
xdg-desktop-portal-wlr
jq
findutils
mdp
swww
swayimg
ncmpcpp 
swayiddle
wl-clipboard
xwayland
ly
pipewire
pipewire-pulse
pipewire-alsa
pwvucontrol
wireplumber
mesa-dri-gallium
mesa-va-gallium
mesa-vulkan-ati
vulkan-headers
vulkan-tools
libdrm@edge
libinput@edge
distrobox
font-noto
ttf-jetbrains-mono-nerd
terminus-font
wlsunset
openrc-user
libinput-zsh-completion
EOF

apk update
apk upgrade

# restore old world
while read pkg; do
  apk add $pkg
done  < /tmp/world

# Find user with id 1000
SUSER=$(id 1000|cut -d'(' -f2|cut -d')' -f1)

if [ -z $SUSER ]; then exit 1; fi

# setup services
setup-devd udev
rc-update add seatd
rc-update add dbus
adduser ${SUSER} seat
adduser greetd seat

# config greetd
cat << EOF > /etc/conf.d/greetd
# Configuration for /etc/init.d/greetd

# Path to config file to use.
#cfgfile="/etc/greetd/config.toml"

EOF


cat << EOF > /etc/greetd/config.toml
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 7

# The default session, also known as the greeter.
[default_session]

# agreety is the bundled agetty/login-lookalike. You can replace /bin/sh
# with whatever you want started, such as sway.
command = agreety --cmd "dbus-run-session sway"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the video group.
user = "greetd"
EOF

rc-update add greetd

# Set XDG_RUNTIME_DIR

cat << EOF > /home/${SUSER}/.profile
if [ -z "$XDG_RUNTIME_DIR" ]; then
  XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
  mkdir -pm 0700 \$XDG_RUNTIME_DIR
  export XDG_RUNTIME_DIR
fi
export TERMINAL=foot
EOF

chown ${SUSER}: /home/${SUSER}/.profile

# Set Menu to rofi
sed -i -e 's/set $menu dmenu_path | dmenu | xargs swaymsg exec --/set $menu rofi -show-icons -show drun | xargs swaymsg exec --/' /etc/sway/config

# Setup Keyboard Layout
KB=$(grep ^KEYMAP  /etc/conf.d/loadkmap |cut -d/ -f4|cut -c 1,2)

if [ ! -z "$KB" ]; then
    input_config="input * {
        xkb_layout \"$KB\"
    }"
    echo "$input_config" >> /etc/sway/config
fi

mkdir -p /home/${SUSER}/.config/sway
cp /etc/sway/config  /home/${SUSER}/.config/sway/
chown -R ${SUSER}: /home/${SUSER}/.config/sway

echo "###############################################################"
echo " creation du conteneur JV"
su - "${USER}" -c "distrobox-create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}" "

##### FINALISATION #####
echo "###############################################################"
echo " Création du répertoire de configuration"
doas -u "${USER}" sh -c "
    mkdir -p ~/.config/sway
    mkdir -p ~/.config/waybar
    mkdir -p ~/.config/pipewire
    mkdir -p ~/.local/share/wallpapers
"

#### CONFIGURATION UTILISATEUR #####
echo "###############################################################"
echo " Configuration de l'utilisateur ${USER}"
addgroup "${USER}" input 2>/dev/null || true
addgroup "${USER}" video 2>/dev/null || true
addgroup "${USER}" audio 2>/dev/null || true



echo "Setup done. Rebooting."
sleep 3
reboot

