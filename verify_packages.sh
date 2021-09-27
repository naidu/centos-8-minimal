#!/bin/bash

while IFS="" read -r p || [ -n "$p" ]; do
  echo "checking for rpm -> $p"
  rpm_validate=$p | tr -d '.x86_64'
  if [ ! -f "rpm_validate".* ]; then
    echo "RPM NOT FOUND -> $p"
  fi
done < $1