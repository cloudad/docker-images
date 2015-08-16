#!/bin/sh
set -e


declare IMAGE_NAME='docker-images'
declare CONTAINER_NAME='docker-images'
declare BUILD_PATH='/usr/src/docker-images'
declare ARG


docker_prepare() {
    docker build --pull -t "${IMAGE_NAME}" .
}

docker_build() {
    docker run \
        --name "${CONTAINER_NAME}" \
        --privileged \
        --rm \
        -t \
        -v "$(readlink -f $0|xargs dirname):${BUILD_PATH}" \
        "${CONTAINER_NAME}" \
        "$@"
}

docker_clean() {
    docker rm -f -v "${CONTAINER_NAME}"
    docker rmi -f "${IMAGE_NAME}"
}

usage() {
    echo "Usage: $0 [command] [...]" 1>&2
    exit 1
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            prepare)
                echo '>>> prepare:'
                docker_prepare
                ;;
            build)
                echo '>>> build:'
                docker_build
                ;;
            clean)
                echo '>>> clean:'
                docker_clean
                ;;
            *)
                echo 'Unknown command "'$1'"' 1>&2
                usage
                ;;
        esac

        shift 1
    done
}

main "$@"
