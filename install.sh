#!/bin/bash

echo "instaling Packages"
list=""; for i in `cat packages1.txt`; do list="$list $i"; done; dnf -y install $list


#dnf -y install $(cat packages1.txt)


