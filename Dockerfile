FROM centos:8
MAINTAINER alex4108@live.com

ENV TERM xterm-256color
ENV USERHOME=/root

RUN find /etc/yum.repos.d -type f -exec sed -i 's/mirrorlist=http/\#mirrorlist=http/g' {} \; && \
  find /etc/yum.repos.d -type f -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://vault.epel.cloud|g' {} \; && \
  find /etc/yum.repos.d -type f -exec sed -i 's|baseurl=http://mirror.centos.org|baseurl=https://vault.epel.cloud|g' {} \;

RUN dnf update -y && \
  dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  dnf update -y && \
  dnf install -y p7zip p7zip-plugins

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

USER 0
WORKDIR $USERHOME

RUN ./download_files_for_build.sh
RUN ./create_iso_in_container.sh
CMD ["/bin/bash"]
