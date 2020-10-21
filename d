#!/bin/bash

# saner programming env: these switches turn some bugs into errors
set -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, getopt --test failed in this environment."
    exit 1
fi

OPTIONS=hbusld
LONGOPTS=help,build,up,stop,list,destroy

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi

# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"


uid=$(id -u)
gid=$(id -g)
image_name="stepik_intro_db"
container_name="stepik_intro_db"

function docker_help() {
    echo "Docker wrapper for primary development docker image"
    echo "Options:"
    echo "  -h, --help      Options description"
    echo "  -b, --build     Build '$image_name' image"
    echo "  -u, --up        Run '$container_name' container (if not exists) and attach to it"
    echo "  -s, --stop      Stop '$container_name' container"
    echo "  -l, --list      List info on all images and containers"
    echo "  -d, --destroy   Stop '$container_name' container and delete it"
}

function docker_build() {
    docker_build_impl
}

function docker_up() {
    local container_id
    container_id=$(docker ps --all --filter "name=$container_name" --format "{{.ID}}")
    if [[ -z "$container_id" ]]; then
        docker_create_impl
    fi
    docker_start_impl
    docker_attach_impl
}

function docker_stop() {
    docker_stop_impl
}

function docker_list() {
    docker_list_containers_impl
    echo ""
    docker_list_images_impl
}

function docker_destroy() {
    docker_stop_impl
    docker_rm_impl
}

######################### Impl #########################

function docker_build_impl() {
    local script_link
    script_link=$(readlink -f "$0")
    local docker_dir
    docker_dir=$(dirname "$script_link")
    docker build \
        --build-arg home="$HOME" \
        --no-cache \
        -t $image_name \
        -f "$docker_dir/Dockerfile" \
        "$docker_dir"
}

function docker_create_impl() {
    local script_link
    script_link=$(readlink -f "$0")
    local docker_dir
    docker_dir=$(dirname "$script_link")
    docker create \
        --interactive \
        --tty \
        --name $container_name \
        --volume "$docker_dir:$HOME" \
        $image_name \
        1>/dev/null
}

function docker_start_impl() {
    docker start $container_name 1>/dev/null
}

function docker_stop_impl() {
    docker stop $container_name 1>/dev/null
}

function docker_attach_impl() {
    docker attach $container_name
}

function docker_list_containers_impl() {
    docker ps -a
}

function docker_list_images_impl() {
    docker image ls
}

function docker_rm_impl() {
    docker rm $container_name 1>/dev/null
}


# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            docker_help
            shift
            ;;
        -b|--build)
            docker_build
            shift
            ;;
        -u|--up)
            docker_up
            shift
            ;;
        -s|--stop)
            docker_stop
            shift
            ;;
        -l|--list)
            docker_list
            shift
            ;;
        -d|--destroy)
            docker_destroy
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Runtime error while parsing arguments!"
            exit 3
            ;;
    esac
done
