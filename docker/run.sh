#!/bin/bash
set -u

work_dir="$(pwd)"

root_dir=$(cd "$(dirname ${BASH_SOURCE:-$0})/.."; pwd)

image=${IMAGE:-""}
if [ -z "$image" ]; then
    image="denv:latest"
fi
echo "image: $image"

container_name=${CONTAINER_NAME:-""}
if [ -z "$container_name" ]; then
    container_name="${image//:/-}"
    # suffix="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
    suffix="$(date "+%Y%m%dT%H%M%S")"
    container_name="${container_name}_${suffix}"
fi
echo "container name: $container_name"

dkr_home=/dkrhome
echo "docker home: $dkr_home"

dkr_work_dir="${dkr_home}/work"
mnt_work=(--mount type=bind,src="$work_dir",dst="$dkr_work_dir")
echo "mount work: $work_dir -> $dkr_work_dir"

dotvim_dir="${root_dir}/etc/vim"
dkr_dotvim_dir="${dkr_home}/.vim"
dkr_dotvim_nvim_dir="${dkr_home}/.config/nvim"
mnt_vim=(
    --mount type=bind,src="$dotvim_dir",dst="$dkr_dotvim_dir"
    --mount type=bind,src="$dotvim_dir",dst="$dkr_dotvim_nvim_dir"
)
echo "mount vim: $dotvim_dir -> $dkr_dotvim_dir"

tmuxconf="${root_dir}/etc/tmux/.tmux.conf"
dkr_tmuxconf="${dkr_home}/.tmux.conf"
mnt_tmuxconf=(--mount type=bind,src="$tmuxconf",dst="$dkr_tmuxconf")
echo "mount tmux conf: $tmuxconf -> $dkr_tmuxconf"

set_user=(
    -u=$(id -u):$(id -g)
    -v /etc/group:/etc/group:ro
    -v /etc/passwd:/etc/passwd:ro
    $(for i in $(id -G "$USER"); do echo --group-add "$i"; done)
)

shrc="${root_dir}/docker/.bashrc"
dkr_shrc="${dkr_home}/.bashrc"
sh_hist="${HOME}/.bash_history"
dkr_sh_hist="${dkr_home}/.bash_history"
mnt_bash=(
    --mount type=bind,src="$shrc",dst="$dkr_shrc"
    --mount type=bind,src="$sh_hist",dst="$dkr_sh_hist"
)
echo "mount bashrc: $shrc -> $dkr_shrc"
echo "mount bash history: $sh_hist -> $dkr_sh_hist"

dkr_root_dir="${dkr_home}/dotfiles"
mnt_root=(--mount type=bind,src="$root_dir",dst="$dkr_root_dir",readonly)
echo "mount root: $root_dir -> $dkr_root_dir"

mnt_host=(--mount type=bind,src=/,dst=/mnt/host,readonly)
echo "mount host: / -> /mnt/host"

detachkeys="ctrl-\\,ctrl-\\"

docker run -it --rm \
    --name "$container_name" \
    "${set_user[@]}" \
    "${mnt_work[@]}" \
    "${mnt_vim[@]}" \
    "${mnt_tmuxconf[@]}" \
    "${mnt_bash[@]}" \
    "${mnt_host[@]}" \
    -e "TERM=$TERM" \
    --detach-keys="$detachkeys" \
    -w "$dkr_work_dir" \
    "$image" /bin/bash
