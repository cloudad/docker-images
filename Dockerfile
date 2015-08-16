FROM ubuntu-debootstrap:vivid


ENV PROJECT_DIR=/usr/src/docker-images
ENV SOURCE_DIR=${PROJECT_DIR}/src
ENV BUILD_DIR=${PROJECT_DIR}/build

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    software-properties-common \
 && find /var/cache/apt/archives/ /var/lib/apt/lists/ -type f -exec rm {} +

RUN apt-add-repository ppa:ansible/ansible \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    ansible \
    debootstrap \
 && find /var/cache/apt/archives/ /var/lib/apt/lists/ -type f -exec rm {} +

VOLUME ${PROJECT_DIR}/
WORKDIR ${SOURCE_DIR}/
ENTRYPOINT [ \
    "ansible-playbook", \
    "--inventory-file=suites", \
    "site.yml" \
]
CMD []
