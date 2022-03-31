#!/bin/bash -e

if [ "${1}" == "" ]; then
  CMOUT="CentOS-x86_64-minimal.iso"
else
  CMOUT="${1}"
fi
           ./bootstrap.sh clean
CMISO="$1" ./bootstrap.sh step isounpack
           ./bootstrap.sh step createtemplate
           ./bootstrap.sh step collectrpms
           ./bootstrap.sh step collectpymodules
           ./bootstrap.sh step createrepo
           ./bootstrap.sh step createiso

cp ./${CMOUT} /mnt/
