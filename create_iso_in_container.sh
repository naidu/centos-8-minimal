#!/bin/bash

./bootstrap.sh clean
./bootstrap.sh step isomount
./bootstrap.sh step createtemplate
./bootstrap.sh step scandeps
./bootstrap.sh step createrepo
./bootstrap.sh step createiso
./bootstrap.sh step isounmount
cp ./CentOS-Stream.iso /tmp/
