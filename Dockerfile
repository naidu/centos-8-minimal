FROM centos:8
MAINTAINER alex4108@live.com

ENV TERM xterm-256color
ENV USERHOME=/root

RUN dnf clean all && rm -rf /var/cache/dnf && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

RUN dnf update -y && \
  dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip
COPY iso-input/CentOS-8.1.1911-x86_64-boot.iso \
     iso-input/bootstrap.zip \
     create_iso_in_container.sh \
     iso-input/isolinux.cfg \
     ks.cfg \
     bootstrap.sh \
     packages.txt \
     templ_discinfo \
     templ_media.repo \
     templ_treeinfo /root/ 

USER 0
WORKDIR $USERHOME

# RUN ./create_iso_in_container.sh
CMD ["/bin/bash", "-l"]
