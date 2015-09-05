#!/bin/bash
set -e


PROJECT_NAME="$(readlink -f $0|xargs dirname|xargs basename)"
PROJECT_PATH="$(readlink -f $0|xargs dirname)"

IMAGE_NAME="${IMAGE_NAME:-${PROJECT_NAME}}"
CONTAINER_NAME="${CONTAINER_NAME:-${PROJECT_NAME}}"

SOURCE_DIR="${SOURCE_DIR:-src}"
TESTS_DIR="${TESTS_DIR:-tests}"
BUILD_DIR="${BUILD_DIR:-build}"

SOURCE_PATH="${PROJECT_PATH}/${SOURCE_DIR}"
TESTS_PATH="${PROJECT_PATH}/${TESTS_DIR}"
BUILD_PATH="${PROJECT_PATH}/${BUILD_DIR}"

BUILD_ENTRYPOINT="ansible-playbook site.yml -e build_path='${BUILD_PATH}'"
TEST_ENTRYPOINT="bats"
SHELL_ENTRYPOINT="bash"


docker_prepare() {
    local force_build=0

    if [ "$1" == "-f" ]; then
        force_build=1
    fi

    if [ -n "$(docker ps -q --filter "name=${CONTAINER_NAME}\$")" ]; then
        printf 'Container "%s" is currently working...\n' "${CONTAINER_NAME}" 1>&2
        exit 1
    fi

    if [ -z "$(docker images -q "${IMAGE_NAME}")" -o "${force_build}" -eq 1 ]; then
        docker build --pull -t "${IMAGE_NAME}" .
    fi

    if [ -n "$(docker ps -aq --filter "name=${CONTAINER_NAME}\$")" ]; then
        docker rm -vf "${CONTAINER_NAME}"
    fi
}

docker_build() {
    docker_prepare

    docker run \
        --name "${CONTAINER_NAME}" \
        --privileged \
        --rm \
        -t \
        -v "${PROJECT_PATH}:${PROJECT_PATH}" \
        -w "${SOURCE_PATH}" \
        "${IMAGE_NAME}" \
        ${BUILD_ENTRYPOINT} \
        "$@"
}

docker_test() {
    docker_prepare

    docker run \
        --name "${CONTAINER_NAME}" \
        --privileged \
        --rm \
        -t \
        -v "${PROJECT_PATH}:${PROJECT_PATH}" \
        -w "${TESTS_PATH}" \
        "${IMAGE_NAME}" \
        ${TEST_ENTRYPOINT} \
        "$@" \
        .
}

docker_shell() {
    docker_prepare

    docker run \
        --name "${CONTAINER_NAME}" \
        --privileged \
        --rm \
        -it \
        -v "${PROJECT_PATH}:${PROJECT_PATH}" \
        -w "${SOURCE_PATH}" \
        "${IMAGE_NAME}" \
        ${SHELL_ENTRYPOINT} \
        "$@"
}

docker_clean() {
    if [ -n "$(docker ps -aq --filter "name=${CONTAINER_NAME}\$")" ]; then
        docker rm -fv "${CONTAINER_NAME}"
    fi
    docker rmi -f "${IMAGE_NAME}"
}

usage() {
    printf 'Usage: %s [command] <arguments>\n' "$0"
    exit 1
}

main() {
    local command="$1"

    shift 1

    case "${command}" in
        prepare)
            docker_prepare -f
            ;;
        build)
            docker_build "$@"
            ;;
        test)
            docker_test "$@"
            ;;
        shell)
            docker_shell "$@"
            ;;
        clean)
            docker_clean
            ;;
        *)
            printf 'Unknown command "%s"\n' "${command}" 1>&2
            usage
            ;;
    esac
}

main "$@"
