FROM centos:8
MAINTAINER alex4108@live.com

ENV USERHOME=/root

RUN dnf clean all && rm -rf /var/cache/dnf && \
  sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* && \
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

RUN dnf upgrade -yv && \
  dnf update -yv && \
  dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip
COPY iso-input/CentOS-8.1.1911-x86_64-boot.iso /root
RUN curl -L -o /root/bootstrap.zip https://github.com/uboreas/centos-8-minimal/archive/ef31f862908af773c74c234353e6bbad48b1ef5e.zip && \
  unzip /root/bootstrap.zip -d /root/ && \
  rm -f /root/bootstrap.zip 
RUN mv /root/centos-8-minimal-ef31f862908af773c74c234353e6bbad48b1ef5e/* /root/
COPY create_iso_in_container.sh /root/
RUN sed -i 's/curl -s/curl -L -s/g' /root/bootstrap.sh

USER 0
WORKDIR $USERHOME

RUN ./create_iso_in_container.sh
CMD ["/bin/bash"]
