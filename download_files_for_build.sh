#!/bin/bash -e

pushd /root

[ ! -f CentOS-Stream.iso ] && {
  curl -L -o CentOS-Stream.iso http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso
  echo $(sha256sum /root/CentOS-Stream.iso)
}

[ ! -f base_comps.xml ] && wget -O base_comps.xml "https://vault.centos.org/centos/8/BaseOS/x86_64/os/repodata/2ee4c293f48ab2cf5032d33a52ec6c148fd4bccf1810799e9bf60bde7397b99a-comps-BaseOS.x86_64.xml"

[ ! -f appstream_comps.xml ] && wget -O appstream_comps.xml "https://vault.centos.org/centos/8/AppStream/x86_64/os/repodata/5ea46cc5dfdd4a6f9c181ef29daa4a386e7843080cd625843267860d444df2f3-comps-AppStream.x86_64.xml"

[ ! -f modules.yaml.xz ] && {
  URL_PATH_TO_APPSTREAM_MODULES="https://vault.centos.org/centos/8/AppStream/x86_64/os/repodata/"
  MODULES_FILE_NAME=$(wget -q -O - "$URL_PATH_TO_APPSTREAM_MODULES" | grep -m 1 -o -E "[a-zA-Z0-9]*?-modules.yaml.xz" | head -1)
  wget -O modules.yaml.xz "${URL_PATH_TO_APPSTREAM_MODULES}${MODULES_FILE_NAME}"
}

popd
