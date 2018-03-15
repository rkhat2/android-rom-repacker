#!/bin/bash -ex

# Download dependencies
apt-get update
apt-get install -y wget
#required
apt-get install -y build-essential git zlib1g-dev libpcre3-dev
#clang
apt-get install -y clang libc++-dev libc++abi-dev
#gcc
# apt-get install -y gcc-multilib g++-multilib

# Get a recent version of CMake
wget https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh
mkdir /opt/cmake | sh cmake-3.10.2-Linux-x86_64.sh --exclude-subdir --prefix=/opt/cmake
export PATH=/opt/cmake/bin:$PATH

# Use clang compiler
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

cd /android-rom-repacker
mkdir build && cd build
cmake ..
make
