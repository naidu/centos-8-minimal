FROM centos:8
MAINTAINER alex4108@live.com
RUN dnf update -y
RUN dnf install -y yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file git wget unzip
RUN curl -L -o /root/CentOS-Stream.iso http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-8.4.2105-x86_64-boot.iso
RUN echo $(sha256sum /root/CentOS-Stream.iso)
COPY create_iso_in_container.sh /root/
COPY bootstrap.sh /root/
COPY packages.txt /root/
COPY templ_comps.xml /root/
COPY templ_discinfo /root/
COPY templ_media.repo /root/
COPY templ_treeinfo /root/
RUN chmod +x /root/create_iso_in_container.sh && /root/create_iso_in_container.sh
CMD ["/bin/bash"]
