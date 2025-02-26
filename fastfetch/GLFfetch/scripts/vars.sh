#!/bin/sh
# Thanks to https://github.com/fearside/ProgressBar

function ProgressBar {
    (( _progress = ($1 * 100 / $2 * 100) / 100 ))
    (( _done = (_progress * bar_length) / 10 ))
    (( _left = bar_length * 10 - _done ))

    printf -v _fill "%${_done}s"
    printf -v _empty "%${_left}s"

    printf "[${_fill// /▇}${_empty// / }] ${_progress}%% Done\n"
}

bar_length=2  # Number between 1 and 10
today=$(date +%s)
install_date=$(stat -c %Y /etc/hostname)
install_date_day=$(stat -d "$install_date" +'%d/%m/%Y')
install_time=$(( (today - install_date) / 86400 ))
end_challenge=31
percentage=$(( install_time * 100 / end_challenge ))

