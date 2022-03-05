#/bin/bash

ISO_INPUT_FOLDER=iso-input
ISO_INPUT_MOUNT_FOLDER=mtemp
ISO_OUTPUT_FOLDER=iso-out

DOCKER_INSTANACE_NAME="build-centos-8-minimal-iso"

CENTOS_BASE_IMAGE_NAME="CentOS-Stream.iso"
CENTOS_BASE_IMAGE_URL="http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso"

docker rm ${DOCKER_INSTANACE_NAME}
docker rmi centos-8-minimal centos:8 

mkdir -p ${ISO_INPUT_FOLDER}
[ ! -f ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} ] && curl -L -o ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} ${CENTOS_BASE_IMAGE_URL}
echo $(sha256sum ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME})

# Download needed xml files for creating local repo
mkdir -p ${ISO_INPUT_FOLDER}/repo
pushd ${ISO_INPUT_FOLDER}/repo
[ ! -f base_comps.xml ] && wget -O base_comps.xml "https://vault.centos.org/centos/8/BaseOS/x86_64/os/repodata/2ee4c293f48ab2cf5032d33a52ec6c148fd4bccf1810799e9bf60bde7397b99a-comps-BaseOS.x86_64.xml"
[ ! -f appstream_comps.xml ] && wget -O appstream_comps.xml "https://vault.centos.org/centos/8/AppStream/x86_64/os/repodata/5ea46cc5dfdd4a6f9c181ef29daa4a386e7843080cd625843267860d444df2f3-comps-AppStream.x86_64.xml"

[ ! -f modules.yaml.xz ] && {
  URL_PATH_TO_APPSTREAM_MODULES="https://vault.centos.org/centos/8/AppStream/x86_64/os/repodata/"
  MODULES_FILE_NAME=$(wget -q -O - "$URL_PATH_TO_APPSTREAM_MODULES" | grep -m 1 -o -E "[a-zA-Z0-9]*?-modules.yaml.xz" | head -1)
  wget -O modules.yaml.xz "${URL_PATH_TO_APPSTREAM_MODULES}${MODULES_FILE_NAME}"
}
popd

mkdir -p ./${ISO_OUTPUT_FOLDER}  
DOCKER_BUILDKIT=1 docker image build --no-cache --tag centos-8-minimal -f Dockerfile .  

docker container run --privileged --name ${DOCKER_INSTANACE_NAME} -it -v "$(pwd)/${ISO_OUTPUT_FOLDER}:/mnt" centos-8-minimal #./create_iso_in_container.sh
