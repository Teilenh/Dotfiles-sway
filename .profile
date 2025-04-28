export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export WAYLAND_DISPLAY=/run/user/1000/wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=
export $(dbus-launch)
