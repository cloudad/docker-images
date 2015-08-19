FROM ubuntu-debootstrap:vivid


RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    software-properties-common \
 && find \
    /var/cache/apt/archives/ \
    /var/lib/apt/lists/ \
    -type f \
    -exec rm {} +

RUN apt-add-repository ppa:ansible/ansible \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
    ansible \
    debootstrap \
 && find \
    /var/cache/apt/archives/ \
    /var/lib/apt/lists/ \
    -type f \
    -exec rm {} +
