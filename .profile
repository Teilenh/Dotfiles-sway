export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY=/run/user/1000/wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DISPLAY=
export $(dbus-launch)
