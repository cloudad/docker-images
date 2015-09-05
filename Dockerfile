FROM ubuntu-debootstrap:vivid


RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    software-properties-common \
 && find \
    /var/cache/apt/archives/ \
    /var/lib/apt/lists/ \
    -type f \
    -exec rm {} +

RUN apt-add-repository ppa:ansible/ansible \
 && apt-add-repository ppa:duggan/bats \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    ansible \
    bats \
    debootstrap \
 && find \
    /var/cache/apt/archives/ \
    /var/lib/apt/lists/ \
    -type f \
    -exec rm {} +
