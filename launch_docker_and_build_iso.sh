#/bin/bash -e

ISO_INPUT_FOLDER=iso-input
ISO_INPUT_MOUNT_FOLDER=mtemp
ISO_OUTPUT_FOLDER=iso-out

DOCKER_INSTANACE_NAME="build-centos-8-minimal-iso"

CENTOS_BASE_IMAGE_NAME="CentOS-Stream.iso"
CENTOS_BASE_IMAGE_URL="http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20220204-boot.iso"

docker rm ${DOCKER_INSTANACE_NAME}
docker rmi centos-8-minimal centos:8 

mkdir -p ${ISO_INPUT_FOLDER}
[ ! -f ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} ] && curl -L -o ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} ${CENTOS_BASE_IMAGE_URL}
echo $(sha256sum ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME})

mkdir -p ./${ISO_OUTPUT_FOLDER}  
docker image build --tag centos-8-minimal -f Dockerfile .  

docker container run --privileged --name ${DOCKER_INSTANACE_NAME} -it -v "$(pwd)/${ISO_OUTPUT_FOLDER}:/mnt" centos-8-minimal ./create_iso_in_container.sh
