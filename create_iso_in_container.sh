#!/bin/bash -e

CMOUT="CentOS-x86_64-minimal.iso"

./bootstrap.sh clean
CMISO="$1" ./bootstrap.sh step isounpack
./bootstrap.sh step createtemplate
./bootstrap.sh step collectrpms
./bootstrap.sh step createrepo
CMOUT="$1" ./bootstrap.sh step createiso

cp ./${CMOUT} /mnt/
