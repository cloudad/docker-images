#!/bin/bash
set -e


PROJECT_NAME="$(readlink -f $0|xargs dirname|xargs basename)"
PROJECT_PATH="$(readlink -f $0|xargs dirname)"

IMAGE_NAME="${IMAGE_NAME:-${PROJECT_NAME}}"
CONTAINER_NAME="${CONTAINER_NAME:-${PROJECT_NAME}}"

SOURCE_DIR="${SOURCE_DIR:-src}"
BUILD_DIR="${BUILD_DIR:-build}"

SOURCE_PATH="${PROJECT_PATH}/${SOURCE_DIR}"
BUILD_PATH="${PROJECT_PATH}/${BUILD_DIR}"
BUILD_ENTRYPOINT="ansible-playbook site.yml -i suites -e build_path='${BUILD_PATH}'"
SHELL_ENTRYPOINT="bash"


docker_prepare() {
    if [ -z "$(docker images -q "${IMAGE_NAME}")" ]; then
        docker build --pull -t "${IMAGE_NAME}" .
    fi

    if [ -n "$(docker ps -q --filter "name=${CONTAINER_NAME}\$")" ]; then
        printf 'Container "%s" is currently working...\n' "${CONTAINER_NAME}" 1>&2
        exit 1
    fi

    if [ -n "$(docker ps -aq --filter "name=${CONTAINER_NAME}\$")" ]; then
        docker rm -vf "${CONTAINER_NAME}"
    fi
}

docker_build() {
    docker_prepare

    docker run \
        --name "${CONTAINER_NAME}" \
        --entrypoint="${BUILD_ENTRYPOINT}" \
        --privileged \
        --rm \
        -t \
        -v "${PROJECT_PATH}:${PROJECT_PATH}" \
        -w "${SOURCE_PATH}" \
        "${CONTAINER_NAME}" \
        "$@"
}

docker_shell() {
    docker_prepare

    docker run \
        --name "${CONTAINER_NAME}" \
        --entrypoint "${SHELL_ENTRYPOINT}" \
        --privileged \
        --rm \
        -it \
        -v "${PROJECT_PATH}:${PROJECT_PATH}" \
        -w "${SOURCE_PATH}" \
        "${CONTAINER_NAME}" \
        "$@"
}

docker_clean() {
    docker rm -fv "${CONTAINER_NAME}"
    docker rmi -f "${IMAGE_NAME}"
}

usage() {
    printf 'Usage: %s [command] [...]\n' "$0"
    exit 1
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            build)
                echo '>>> build:'
                docker_build
                ;;
            shell)
                echo '>>> shell:'
                docker_shell
                ;;
            clean)
                echo '>>> clean:'
                docker_clean
                ;;
            *)
                printf 'Unknown command "%s"\n' "$1" 1>&2
                usage
                ;;
        esac

        shift 1
    done
}

main "$@"
