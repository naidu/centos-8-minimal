#!/bin/bash

while IFS="" read -r p || [ -n "$p" ]; do
  echo "checking for rpm -> $p"
  if [ ! -f "$2" ]; then
    echo "RPM NOT FOUND -> $p"
  fi
done < $1