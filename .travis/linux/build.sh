#!/bin/bash -ex

docker run -v $(pwd):/android-rom-repacker ubuntu:18.04 /bin/bash -ex /android-rom-repacker/.travis/linux/docker.sh
