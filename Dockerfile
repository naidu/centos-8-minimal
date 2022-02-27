FROM centos:8
MAINTAINER alex4108@live.com

ENV TERM xterm-256color
ENV USERHOME=/root

RUN find /etc/yum.repos.d -type f -exec sed -i 's/mirrorlist=http/\#mirrorlist=http/g' {} \; && \
  find /etc/yum.repos.d -type f -exec sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' {} \; && \
  find /etc/yum.repos.d -type f -exec sed -i 's|baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' {} \;

RUN dnf update -y && \
  dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  dnf update -y && \
  dnf install -y p7zip p7zip-plugins

RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && \
  dnf update -y

RUN sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
RUN dnf install p7zip p7zip-plugins -y

# RUN curl -L -o /root/CentOS-Stream.iso http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso && \
#   echo $(sha256sum /root/CentOS-Stream.iso)

COPY iso-input/CentOS-Stream.iso /root/

COPY create_iso_in_container.sh \
     iso-input/isolinux.cfg \
     ks.cfg \
     .bash_profile \
     bootstrap.sh \
     packages.txt \
     templ_discinfo \
     templ_media.repo \
     # Backup of downloaded rpms
     temp \
     # Downloaded xmls for repo 
     iso-input/repo/base_comps.xml iso-input/repo/appstream_comps.xml iso-input/repo/modules.yaml.xz \
     templ_treeinfo /root/ 

USER 0
WORKDIR $USERHOME

#RUN ./create_iso_in_container.sh
CMD ["/bin/bash"]
