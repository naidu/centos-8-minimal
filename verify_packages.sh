#!/bin/bash

while IFS="" read -r p || [ -n "$p" ]; do
  rpm_validate="$((p | tr -d 'x86_64' | tr -d '.'))"
  echo "checking for rpm -> $rpm_validate"
  if [ ! -z `ls -al $2 | grep $rpm_validate` ]; then
    echo "RPM NOT FOUND -> $p"
  fi
done < $1