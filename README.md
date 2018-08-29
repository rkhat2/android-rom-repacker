# Android-rom-repacker

[![Travis CI Build Status](https://travis-ci.org/rkhat2/android-rom-repacker.svg?branch=android-5)](https://travis-ci.org/rkhat2/android-rom-repacker)

Android-rom-repacker is a kit to unpack/repack android ext4 and boot images

## Prebuilt binaries

You can get prebuilt binaries from [here](https://www.github.com/rkhat2/android-rom-repacker/releases). Use tags that start with android-5

## Prerequisite

* CMake version 3.10 or higher

* Git

* The following packages

```bash
apt-get install build-essential git zlib1g-dev libpcre3-dev liblz4-dev
```

#### Clang Compiler

Not supported

#### GCC Compiler

```bash
apt-get install gcc-multilib g++-multilib
```

## How to build

#### Clang Compiler

Not supported

#### GCC Compiler

```bash
mkdir build && cd build

cmake ..

make
```

## Useful commands

```bash
# download, update and patch external dependencies without building
make external 

# default clean command doesn't clean external depdendencies' build. Use this instead.
make all-clean
```