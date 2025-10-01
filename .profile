export XDG_CONFIG_HOME="$HOME/.config"
export FONTCONFIG_FILE="XDG_CONFIG_HOME/fontconfig/fonts.conf"

alias Launch="dbus-run-session sway"
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland
export _JAVA_AWT_WM_NONREPARENTING=1



# Themes
export GTK_THEME=Catppuccin-Mocha
export GTK_ICON_THEME=Zafiro-Nord-Black-Blue
export XCURSOR_THEME=Catppuccin-Mocha
export XCURSOR_SIZE=20
