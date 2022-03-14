#!/bin/bash -e

#
# Evironment variables
#
#    CMVERBOSE  : increase verbosity (set any value)
#    CMISO      : official ISO to use (i.e. CentOS-8.1.1911-x86_64-boot.iso)
#    CMOUT      : resultig ISO file name (i.e. CentOS-8.1.1911-x86_64-minimal.iso)
#    CMETH      : dependency resolving method to use (deep or fast)

# Color codes for printing colored output
RESET=`tput sgr0`

COLOR_BLACK=`tput setaf 0`
COLOR_RED=`tput setaf 1`
COLOR_GREEN=`tput setaf 2`
COLOR_YELLOW=`tput setaf 3`
COLOR_BLUE=`tput setaf 4`
COLOR_MAGENTA=`tput setaf 5`
COLOR_CYAN=`tput setaf 6`
COLOR_WHITE=`tput setaf 7`

# Default values
#
# default official ISO to use
iso="CentOS-Stream.iso"
#
# resulting ISO file name and volume label
# such values will be determined again according to source image during ISO unpack
out="CentOS-Stream-Minimal.iso"
lbl="CentOS-Stream-Minimal"
#
# dependency resolving method
# deep: check dependency of every package one by one
# fast: check core package depedencies only
met="fast"
#
# no need to change further

pw="$(pwd)"
dp="${pw}/image"
md="${pw}/mtemp"
bo="${dp}/BaseOS"
ap="${dp}/AppStream"

function cmusage() {
   echo "Usage: ${0} <run [force] | clean | debug [package [package ..]] | step ..>"
   echo
   exit 1
}

function cmusagestep() {
   echo "Usage: ${0} step .."
   echo
   echo " Workflow steps:"
   echo "    isounpack"
   echo "    createtemplate"
   echo "    scandeps"
   echo "    createrepo"
   echo "    createiso"
   echo
   echo " Some usefull functions:"
   echo "    rpmname <package> [package ..]"
   echo "    rpmurl <package> [package ..]"
   echo "    rpmdownload <package> [package ..]"
   echo "    fulldeps <package> [package ..]"
   echo
   exit 1
}

function cmnotcentos() {
   echo
   echo " ! This script is not suitable to use in this platform"
   echo
   exit 1
}

function cmcheck() {
  if [ "${PIPESTATUS[0]}" != "0" ]; then
    exit 1
  fi
}

function cmpipe() {
   while read line; do
      echo "   ${1}${line}"
   done
}

function cmdot() {
   if [ "${CMVERBOSE}" != "" ]; then
      cmpipe
   else
      echo -n "   "
      while read line; do
         echo -n "."
      done
      echo " done"
   fi
}


function cmisounpack() {
   if [ ! -e "${iso}" ]; then
      echo
      echo " ! Reference ISO (${iso}) not found."
      echo
      echo "   You can download CentOS 8 from following resource;"
      echo "   http://isoredirect.centos.org/centos/8/isos/x86_64/"
      echo
      echo "   If you want to use different minor release, please"
      echo "   specify it like below;"
      echo
      echo "   CMISO='/path/to/file.iso' ./bootstrap.sh .."
      echo
      exit 1
   fi
   echo " ~ unpacking ISO "
   if [ ! -d "${md}" ]; then
      mkdir -p "${md}"
      7z x -y "${iso}" -o"${md}"/ || exit 1
      cmcheck
      echo "   ${md} unpacked"
   fi
}

function cmclean() {
   rm -rf "${dp}"
   rm -f target_comps.xml "${out}" .[cpmrdtfu]*
}

function cmcreatetemplate() {
   if [ ! -d "${md}" ]; then
      if [ "${CMSTEP}" != "" ]; then
         echo " ! ISO not unpacked, please run;"
         echo "   ${0} step isounpack"
         echo
      fi
      return
   fi
   echo -n " ~ Preparing image template "
   echo -n "."
   mkdir -p "${dp}"
   mkdir -p "${bo}/Packages"
   mkdir -p "${ap}/Packages"
   echo -n "."
   cp -r "${md}/EFI" "${dp}/"
   cmcheck
   echo -n "."
   
   cp "templ_discinfo" "${dp}/.discinfo"
   cp "templ_media.repo" "${dp}/media.repo"
   cp "ks.cfg" "${dp}/"
   cp -r "ks_configs" "${dp}/"
   echo -n "."
   cp -r "${md}/isolinux" "${dp}/"
   yes | cp -fr isolinux.cfg "${dp}/isolinux/" 
   echo -n "."
   cp -r "${md}/images" "${dp}/"
   cmcheck
   rm -f "${dp}/.treeinfo"
   touch "${dp}/.treeinfo"
   while IFS=  read line; do
      imgf="$(echo "${line}" | grep "^images/" | awk -F" = " {'print $1'})"
      if [ "${imgf}" != "" ]; then
         if [ ! -e "${dp}/${imgf}" ]; then
            echo
            echo
            echo " ! Image '${imgf}' not found in base ISO"
            echo
            exit 1
         fi
         sum="$(sha256sum "${dp}/${imgf}" | awk {'print $1'})"
         echo "${imgf} = sha256:${sum}" >> "${dp}/.treeinfo"
         echo -n "."
      else
         echo "${line}" >> "${dp}/.treeinfo"
      fi
   done < "templ_treeinfo"
   if [ -e "${md}/.treeinfo" ]; then
      ts="$(cat ${md}/.treeinfo | grep "timestamp = " | head -1 | awk -F"= " {'print $2'} | tr -d "\n\r")"
      if [ "${ts}" != "" ]; then
         sed -i "s/\\(timestamp = \\)[0-9]\\+/\\1${ts}/g" "${dp}/.treeinfo"
      fi
   fi
   if [ -e "${md}/.discinfo" ]; then
      ts="$(head -1 ${md}/.discinfo | tr -d "\n\r")"
      if [ "${ts}" != "" ]; then
         sed -i "s/[0-9]\\+\.[0-9]\\+/${ts}/g" "${dp}/.discinfo"
      fi
   fi
   echo " done"
}

function resolvedeep() {
   # input arguments
   # package [package ..]
   s="${CMSEP}-"
   tf="${CMTEMP}"
   vb="${CMVERBOSE}"
   repoquery --requires --resolve "${@}" 2>/dev/null | \
      awk -F":" {'print $1'} | \
      sed 's/\-[0-9]\+$//g' | \
      sort | uniq | \
   while read line; do
      if [ "${line}" == "glibc-all-langpacks" -o "$(echo "${line}" | grep "glibc-langpack-[a-z0-9]\+$")" != "" ]; then
         if [ "${vb}" != "" ]; then
            echo "       skip: ${@}	${line}"
         fi
         continue
      fi
      if [ "$(cat "${tf}" | grep "^${line}$")" == "" ]; then
         echo "${s} ${line}" >> .tree
         echo "${line}" >> "${tf}"
         if [ "${vb}" != "" ]; then
            echo "    package: ${@}	${line}"
         else
            echo -n ","
         fi
         CMSEP="${s}" resolvedeep "${line}"
      fi
   done
}

function cmrpmdownload() {
   # input arguments
   # package [package ..]
   if [ "${1}" == "" ]; then
      echo "Usage: ${0} rpmdownload <package>"
      echo 
      exit 1
   fi
   mkdir -p rpms
   yumdownloader --urlprotocol http --urls "${@}" 2>/dev/null | \
      grep "^http" | \
      sort | uniq | \
   while read u; do
      if [ "${u}" != "" ]; then
         f=`echo "${u}" | awk -F"/" {'print $NF'}`
         if [ -e "rpms/${f}" ]; then
            if [ "$(file "rpms/${f}" | grep "RPM ")" != "" ]; then
               echo " - exists (rpms/${f})"
               continue
            fi
            rm -f "rpms/${f}"
         fi
         echo "   ${f} [${u}]"
         curl -s "${u}" -o "rpms/${f}"
         if [ "${?}" == "0" ]; then
            if [ "$(file "rpms/${f}" | grep "RPM ")" == "" ]; then
               rm -f "rpms/${f}"
               echo " ! failed"
            fi
         else
            rm -f "rpms/${f}"
            echo " ! failed"
         fi
      fi
   done
}

function rpmdownloadusingdnf() {
   if [ "${1}" == "" ]; then
      echo " ! Pacakge name required for rpmdownloadusingdnf"
      echo 
      exit 1
   fi
   mkdir -p rpms
   pkg="$(echo "${@}" | rev | cut -d/ -f1 | cut -d- -f3- | rev)"
   dnf download --arch=noarch,x86_64 --releasever=8 --installroot=/root/temp/ --resolve --alldeps --destdir=/root/rpms ${pkg} -x \*i686
}

function cmrpmurlusingdnf() {
   # input arguments
   # package [package ..]
   if [ "${CMSTEP}" != "" -a "${1}" == "" ]; then
      echo "Usage: ${0} step rpmurlusingdnf <package> [package ..]"
      echo 
      exit 1
   fi
   dnf download -x \*i686 --urls "${@}" | \
      grep "^https" | \
      sort | uniq > "${pw}/.urls"
   
   [ ! -f ${pw}/.urls ] && {
      echo "Not all dependent packages found.  Please fix before proceeding !!"
      echo
      exit 1
   } || true
}

function cmcopyrpmtorepo() {
   # input argument
   # package 
   vb="${CMVERBOSE}"
   if [ "${1}" == "" ]; then
     echo "Usage: ${0} step copyrpmtorepo <package>"
     echo
     exit 1
   fi
   
   rpmurl="$(dnf download --releasever=8 --installroot=/root/temp/ -x \*i686 --urls $(echo ${1} | sed 's/\-[0-9].*//g') | grep 'http:' \
          || echo http://mirror.pulsant.com/sites/centos/8-stream/AppStream/x86_64/os/Packages/${1})"
   case $rpmurl in
     *BaseOS*)
       if [ -d "${bo}/Packages" ]; then
         cp "rpms/${1}" "${bo}/Packages/"
         echo "Copied ${COLOR_BLUE}${1}${RESET} to ${COLOR_GREEN}BaseOS${RESET}/Packages/"
       fi
       ;;
     *)
       if [ -d "${ap}/Packages" ]; then
         cp "rpms/${1}" "${ap}/Packages/"
         echo "Copied ${COLOR_BLUE}${1}${RESET} to ${COLOR_YELLOW}AppStream${RESET}/Packages/"
       fi
       ;;
   esac
}

function cmcollectrpms() {
   tp="$(cat .pkgs | sort | uniq | wc -l)"
   echo " ~ Searching RPMs for ${tp} package(s)"
   if [ "${CMVERBOSE}" == "" ]; then
      echo -n "   "
   fi
   rm -f .miss .rslv .dler
   mkdir -p rpms
   [ -d "rpms.cache" ] && cp rpms.cache/* rpms/ || true
   dnf groupinstall --downloadonly -y --nobest --releasever=8 --installroot=/root/temp/ --destdir=/root/rpms/ $(grep "^@" packages.txt | sed "s/^@//") -x \*i686 $(grep "^-" packages.txt | sed "s/^-/-x /") 
   dnf download --arch=noarch,x86_64 --releasever=8 --installroot=/root/temp/ --resolve --alldeps --destdir=/root/rpms/ $(grep -v "^#" packages.txt | grep -v "^@" | grep -v "^-") -x \*i686

   # dnf download --arch=noarch,x86_64 --urls --releasever=8 --installroot=/root/temp/ -x \*i686 $(ls rpms | sort | uniq | sed 's/\-[0-9].*//g') | grep 'http:' > .urls
   echo "$(ls rpms | sort | uniq)" | while read r; do
      if [ -e "rpms/${r}" ]; then
         cmcopyrpmtorepo ${r}
      fi
   done

   if [ "${CMVERBOSE}" == "" ]; then
      echo " done"
   fi
}

function cmcreaterepo() {
   if [ ! -d "${bo}/Packages" ]; then
      echo " ! Image temmplate is not ready, please run;"
      echo "   ${0} step createtemplate"
      echo "   ${0} step scandeps"
      echo
      exit 1
   fi

   echo " ~ Creating repodata "
   cd "${bo}"
   cmcheck
   rm -rf repodata
   cp "${pw}"/base_comps.xml comps.xml
   createrepo_c --workers 8 -g comps.xml . 2>&1 | cmdot
   cmcheck
   cd "${pw}"

   cd "${ap}"
   cmcheck
   rm -rf repodata
   cp "${pw}"/appstream_comps.xml comps.xml
   createrepo_c --workers 8 -g comps.xml . 2>&1 | cmdot
   cmcheck
   cd "${pw}"

   cd "${ap}"
   cp "${pw}"/modules.yaml.xz .
   xz -d modules.yaml.xz
   modifyrepo_c --mdtype=modules modules.yaml repodata/
   cmcheck
   cd "${pw}"

   rm -f "${uc}"
}

function cmcreateiso() {
   if [ ! -d "${bo}/repodata" ]; then
      echo " ! Repo is not ready, please run;"
      echo "   ${0} step createrepo"
      echo
      exit 1
   fi

   if [[ -f .miss && $(wc -l < .miss) -ge 1 ]]; then
      echo " ! Below packages failed to get downloaded;"
      echo "   $(cat .miss)"
      echo "   Please fix them before proceeding to build the iso"
      echo 
      exit 1 
   fi

   lbl="$(cat "${dp}/isolinux/isolinux.cfg" | grep "LABEL=" | awk -F"LABEL=" {'print $2'} | awk {'print $1'} | grep -v "^$" | head -1 | tr -d "\n\r")"
   if [ "${CMOUT}" == "" ]; then
      ver="$(cat "${dp}/isolinux/isolinux.cfg" | grep "LABEL=CentOS" | head -1 | awk -F"LABEL=CentOS-" {'print $2'} | awk -F"-x86_64" {'print $1'} | sed 's/\-/\./g')"
      if [ "${ver}" == "8.BaseOS" ]; then
         ver="8.0.1905"
      elif [ "${ver}" == "Stream.8" ]; then
         ver="8.0.20191219"
      fi
      out="CentOS-x86_64-minimal.iso"
   fi
   echo " ~ Creating ISO image"
   cd "${dp}"
   chmod 664 isolinux/isolinux.bin
   rm -f "${pw}/${out}"
   mkisofs \
      -input-charset utf-8 \
      -o "${pw}/${out}" \
      -b isolinux/isolinux.bin \
      -c isolinux/boot.cat \
      -no-emul-boot \
      -V "${lbl}" \
      -boot-load-size 4 \
      -boot-info-table \
      -eltorito-alt-boot \
      -e images/efiboot.img \
      -no-emul-boot \
      -R -J -v -T . 2>&1 | cmdot
      cmcheck
   if [ -e "/usr/bin/isohybrid" ]; then
      echo " ~ ISO hybrid"
      isohybrid --uefi "${pw}/${out}" | cmdot
      cmcheck
   fi
   if [ -e "/usr/bin/implantisomd5" ]; then
      echo " ~ Implant ISO MD5"
      implantisomd5 --force --supported-iso "${pw}/${out}" | cmdot
      cmcheck
   fi
   cd "${pw}"
   isz="$(du -h "${out}" | awk {'print $1'})"
   echo " ~ ISO image ready: ${out} (${isz})"
}

function cmjobfull() {
   cmclean
   cmisounpack
   cmcreatetemplate
   cmcollectrpms
   cmcreaterepo
   cmcreateiso
}

function cmjobquick() {
   if [ "${CMISO}" != "" ]; then
      cmisounpack
   fi
   cmcreatetemplate
   cmcreaterepo
   cmcreateiso
}

if [ ! -e /etc/centos-release ]; then
   cmnotcentos
fi
if [ "$(cat /etc/centos-release | grep "CentOS Linux release 8\|CentOS Stream release 8")" == "" ]; then
   cmnotcentos
fi
if [ ! -e "/usr/bin/repoquery" -o ! -e "/usr/bin/createrepo" -o ! -e "/usr/bin/yumdownloader" -o ! -e "/usr/bin/curl" -o ! -e "/usr/bin/mkisofs" ]; then
   echo
   echo " ! Some additional packages needs to be installed."
   echo "   Please run following command to have them all:"
   echo
   echo "   dnf -y install yum-utils createrepo syslinux genisoimage isomd5sum bzip2 curl file"
   echo
   exit 1
fi
if [ "${CMISO}" != "" ]; then
   iso="${CMISO}"
fi
if [ "${CMOUT}" != "" ]; then
   out="${CMOUT}"
fi
if [ "${CMETH}" != "" ]; then
   met="${CMETH}"
fi
if [ ! -e "packages.txt" ]; then
   touch "packages.txt"
fi

if [ "${1}" == "run" ]; then
   shift
   if [ "${1}" == "force" ]; then
      cmjobfull
   elif [ -d "${bo}/Packages" ]; then
      cmjobquick
   else
      cmjobfull
   fi
elif [ "${1}" == "clean" ]; then
   cmclean
elif [ "${1}" == "debug" ]; then
   shift
   if [ "${1}" == "" ]; then
      cmusage
   fi
   cmjobsingle "${@}"
elif [ "${1}" == "step" ]; then
   shift
   if [ "${1}" == "" ]; then
      cmusagestep
   fi
   cmd="cm${1}"
   shift
   CMVERBOSE=1 CMSTEP=1 ${cmd} "${@}"
else
   cmusage
fi

