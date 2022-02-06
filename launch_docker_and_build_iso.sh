#/bin/bash -e

ISO_INPUT_FOLDER=iso-input
ISO_INPUT_MOUNT_FOLDER=mtemp
ISO_OUTPUT_FOLDER=iso-out

DOCKER_INSTANACE_NAME="build-centos-8-minimal-iso"

CENTOS_BASE_IMAGE_NAME="CentOS-8.1.1911-x86_64-boot.iso"

docker rm ${DOCKER_INSTANACE_NAME}
docker rmi centos-8-minimal centos:8 

mkdir -p ${ISO_INPUT_FOLDER}
[ ! -f ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} ] && curl -L -o ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME} http://ftp.iij.ad.jp/pub/linux/centos-vault/8.1.1911/isos/x86_64/${CENTOS_BASE_IMAGE_NAME}
echo $(sha256sum ${ISO_INPUT_FOLDER}/${CENTOS_BASE_IMAGE_NAME})

[ ! -f ${ISO_INPUT_FOLDER}/bootstrap.zip ] && curl -L -o ${ISO_INPUT_FOLDER}/bootstrap.zip https://github.com/uboreas/centos-8-minimal/archive/ef31f862908af773c74c234353e6bbad48b1ef5e.zip

mkdir -p ./${ISO_OUTPUT_FOLDER}  
docker image build --tag centos-8-minimal -f Dockerfile .  

docker container run --privileged --name ${DOCKER_INSTANACE_NAME} -it -v "$(pwd)/${ISO_OUTPUT_FOLDER}:/mnt" centos-8-minimal  
