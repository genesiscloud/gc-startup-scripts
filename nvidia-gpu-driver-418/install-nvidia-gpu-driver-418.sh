#!/bin/sh
set -eux
__nvidia_full_version="418_418.56-0ubuntu1"
__nvidia_short_version="418"
is_installed=false
for i in $(seq 1 5)
do
  echo "Connecting to http://archive.ubuntu.com site for $i time"
  if curl -s --head  --request GET http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version} | grep "HTTP/1.1" > /dev/null ;
  then
      echo "Connected to http://archive.ubuntu.com. Start downloading and installing the NVIDIA driver..."
      __tempdir="$(mktemp -d)"
      apt-get install -y --no-install-recommends "linux-headers-$(uname -r)" dkms
      wget -P "${__tempdir}" http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version}/nvidia-kernel-common-${__nvidia_full_version}_amd64.deb
      wget -P "${__tempdir}" http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version}/nvidia-kernel-source-${__nvidia_full_version}_amd64.deb
      wget -P "${__tempdir}" http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version}/nvidia-dkms-${__nvidia_full_version}_amd64.deb
      dpkg -i "${__tempdir}"/nvidia-kernel-common-${__nvidia_full_version}_amd64.deb "${__tempdir}"/nvidia-kernel-source-${__nvidia_full_version}_amd64.deb "${__tempdir}"/nvidia-dkms-${__nvidia_full_version}_amd64.deb
      wget -P "${__tempdir}" http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version}/nvidia-utils-${__nvidia_full_version}_amd64.deb
      wget -P "${__tempdir}" http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-${__nvidia_short_version}/libnvidia-compute-${__nvidia_full_version}_amd64.deb
      dpkg -i "${__tempdir}"/nvidia-utils-${__nvidia_full_version}_amd64.deb "${__tempdir}"/libnvidia-compute-${__nvidia_full_version}_amd64.deb
      rmmod nouveau
      modprobe nvidia
      nvidia-smi
      is_installed=true
      rm -r "${__tempdir}"
      break
  fi
  sleep 2
done
if [ $is_installed = true ];
then
  echo "NVIDIA driver has been installed."
else
  echo "NVIDIA driver has NOT been installed. Because we can NOT reach to http://archive.ubuntu.com site which hosted necessary deb packages for installation."
fi