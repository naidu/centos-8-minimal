FROM centos:8
MAINTAINER alex4108@live.com

ENV TERM xterm-256color
ENV USERHOME=/root

RUN dnf clean all && rm -rf /var/cache/dnf && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

RUN dnf update -y && \
  dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip

RUN curl -L -o /root/CentOS-Stream.iso http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20220204-boot.iso && \
  echo $(sha256sum /root/CentOS-Stream.iso)

#COPY iso-input/CentOS-Stream.iso /root/

COPY create_iso_in_container.sh \
     iso-input/isolinux.cfg \
     ks.cfg \
     .bash_profile \
     bootstrap.sh \
     packages.txt \
     templ_discinfo \
     templ_comps.xml \
     templ_media.repo \
     templ_treeinfo /root/ 

USER 0
WORKDIR $USERHOME

RUN ./create_iso_in_container.sh
CMD ["/bin/bash", "-l"]
