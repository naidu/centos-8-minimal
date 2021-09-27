#!/bin/bash

while IFS="" read -r p || [ -n "$p" ]; do
  rpm_validate=${p::-7}
  #echo "checking for rpm -> $rpm_validate"
  if [[ ! -z `ls -al $2 | grep "$rpm_validate"` ]]; then
    echo "$p" > /tmp/rpms_to_load.txt
  fi
done < $1