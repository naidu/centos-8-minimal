#!/bin/bash

CMISO="$1"  ./bootstrap.sh clean
CMISO="$1" ./bootstrap.sh step isomount
CMISO="$1" ./bootstrap.sh step createtemplate
CMISO="$1" ./bootstrap.sh step scandeps
CMISO="$1" ./bootstrap.sh step createrepo
CMISO="$1" ./bootstrap.sh step createiso
CMISO="$1" ./bootstrap.sh step isounmount
