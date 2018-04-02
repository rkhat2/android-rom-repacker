#!/bin/bash -ex

. .travis/common/pre-upload.sh

REV_NAME="android-rom-repacker-7"
ARCHIVE_NAME="${REV_NAME}-${GITDATE}-${GITREV}.tar.gz"
COMPRESSION_FLAGS="-czvf"

mkdir "$REV_NAME"

cp -a bin/. "$REV_NAME"

. .travis/common/post-upload.sh
