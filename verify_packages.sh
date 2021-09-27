#!/bin/bash

rpms=()
rm -rf /tmp/rpms_to_load.txt
while IFS="" read -r p || [ -n "$p" ]; do
  rpm_validate=${p::-7}
  #echo "checking for rpm -> $rpm_validate"
  if [[ ! -z `ls -al $2 | grep "$rpm_validate"` ]]; then
   rpms+=($p)
  else
    echo "RPM found -> $p"
  fi
  for rpm in "${rpms[@]}"; do
    echo "$rpm" >> /tmp/rpms_to_load.txt
  done
done < $1