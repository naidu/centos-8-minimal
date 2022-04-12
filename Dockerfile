FROM centos:8

ENV TERM xterm-256color
ENV USERHOME=/root

RUN dnf --disablerepo '*' --enablerepo extras swap centos-linux-repos centos-stream-repos -y && \ 
    dnf distro-sync -y

RUN dnf update -y && \
    dnf install -y yum-utils \
                   createrepo \
                   syslinux \
                   genisoimage \
                   isomd5sum \
                   bzip2 \
                   curl \
                   file \
                   git \
                   wget \
                   unzip \
                   python3-pip

RUN python3 -m pip install --upgrade pip

USER 0
WORKDIR $USERHOME

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  dnf update -y && \
  dnf install -y p7zip p7zip-plugins xz

RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && \
  dnf update -y

#COPY iso-input/CentOS-Stream.iso /root/

COPY iso-input/isolinux.cfg \
     # Downloaded xmls for repo 
     #iso-input/repo \
     config /root/

RUN ./download_files_for_build.sh
RUN ./create_iso_in_container.sh
CMD ["/bin/bash", "-l"]
