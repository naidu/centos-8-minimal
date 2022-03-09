FROM naidu/centos-stream:latest
MAINTAINER me@btrnaidu.com

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  dnf update -y && \
  dnf install -y p7zip p7zip-plugins xz

RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && \
  dnf update -y

#COPY iso-input/CentOS-Stream.iso /root/

COPY create_iso_in_container.sh \
     download_files_for_build.sh \
     iso-input/isolinux.cfg \
     config \
     # Downloaded xmls for repo 
     #iso-input/repo \
     packages.txt /root/ 

RUN ./download_files_for_build.sh
RUN ./create_iso_in_container.sh
CMD ["/bin/bash"]
