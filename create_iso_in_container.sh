#!/bin/bash -e

CMISO="$1" ./bootstrap.sh clean
CMISO="$1" ./bootstrap.sh step isounpack
CMISO="$1" ./bootstrap.sh step createtemplate
CMISO="$1" ./bootstrap.sh step collectrpms
CMISO="$1" ./bootstrap.sh step createrepo
CMISO="$1" ./bootstrap.sh step createiso

cp ./CentOS-*-minimal.iso /mnt/
