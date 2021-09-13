#!/bin/bash

/root/bootstrap.sh clean
/root/bootstrap.sh step isomount
/root/bootstrap.sh step createtemplate
/root/bootstrap.sh step scandeps
/root/bootstrap.sh step createrepo
/root/bootstrap.sh step createiso
/root/bootstrap.sh step isounmount
cp ./CentOS-Stream.iso /mnt/
