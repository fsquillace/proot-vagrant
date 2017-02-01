#!/bin/bash

set -eu

MAX_OLD_VERSIONS=10

# ARCH can be one of: x86, x86_64, arm
HOST_ARCH=$(uname -m)
if [ $HOST_ARCH == "i686" ] || [ $HOST_ARCH == "i386" ]
then
    ARCH="x86"
elif [ $HOST_ARCH == "x86_64" ]
then
    ARCH="x86_64"
elif [[ $HOST_ARCH =~ .*(arm).* ]]
then
    ARCH="arm"
else
    echo "Unknown architecture ${HOST_ARCH}" >&2
    exit 11
fi

STATIC_BUILD_DIR=${HOME}/proot-static-build

# Cleanup and initialization
[[ -e "${STATIC_BUILD_DIR}" ]] && sudo rm -rf "${STATIC_BUILD_DIR}"
trap "sudo rm -rf ${STATIC_BUILD_DIR}" EXIT QUIT ABRT KILL TERM INT

# Building proot binary
cd $HOME
git clone https://github.com/fsquillace/proot-static-build.git
cd proot-static-build
make proot proot-url=https://github.com/fsquillace/PRoot.git

# Upload binary file
# The put is done via a temporary filename in order to prevent outage on the
# production file for a longer period of time.
# The put command returns a exit code 1 even when it works fine, suppressing it
droxi put -f -O /Public/proot out/proot || echo "Uploaded"
droxi mv -f /Public/proot/proot /Public/proot/proot-${ARCH}

DATE=$(date +'%Y-%m-%d-%H-%M-%S')
droxi cp -f /Public/proot/proot-${ARCH} /Public/proot/proot-${ARCH}.${DATE}

# Cleanup old files
droxi ls /Public/proot/proot-${ARCH}.* | sed 's/ .*$//' | head -n -${MAX_OLD_VERSIONS} | xargs -I {} droxi rm "{}"
