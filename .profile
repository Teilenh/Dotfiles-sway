export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY=/run/user/1000/wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

export XDG_CONFIG_HOME="$HOME/.config"
export FONTCONFIG_FILE="XDG_CONFIG_HOME/fontconfig/fonts.conf"
export $(dbus-launch)
