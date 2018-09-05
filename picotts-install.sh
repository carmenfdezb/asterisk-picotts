#!/bin/bash

# Installer for SVOX Pico TTS on non-Debian platforms
# Author: Steven Mirabito <smirabito@csh.rit.edu>
# Patches from:
#   @jerrm from PIAF Forum and
#    Ward Mundy & Associates LLC, 7-7-2017 and 11-04-2017
# http://incrediblepbx.com/picotts.tar.gz

# Check architechure
if [ $(uname -m) == 'x86_64' ]; then
 if [[ "$release" = "7" ]]; then
    pkgarch="amd64"
 else
    pkgarch="i386"
    yum -y install popt.i686
 fi
else
    pkgarch="i386"
fi

test=`cat /etc/redhat-release | grep 6`
if [[ -z $test ]]; then
 release="7"
else
 release="6"
fi

# Get work directories set up
cd /usr/src
mkdir libttspico

# Download and extract Pico TTS libraries
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico0_1.0%2bgit20130326-3_${pkgarch}.deb
ar x libttspico0_1.0+git20130326-3_${pkgarch}.deb data.tar.xz
tar -xf data.tar.xz -C "libttspico"
rm -f data.tar.xz

# Dowload and extract Pico TTS voice data
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico-data_1.0%2bgit20130326-3_all.deb
ar x libttspico-data_1.0+git20130326-3_all.deb data.tar.xz
tar -xf data.tar.xz -C "libttspico"
rm -f data.tar.xz

# Download and extract Pico TTS utilities (pico2wave)
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico-utils_1.0%2bgit20130326-3_${pkgarch}.deb
ar x libttspico-utils_1.0+git20130326-3_${pkgarch}.deb data.tar.xz
tar -xf data.tar.xz -C "libttspico"
rm -f data.tar.xz

# Delete packages
rm -f libttspico*.deb

# Move files into place
mv "libttspico/usr/lib/"*-linux-gnu/* "libttspico/usr/lib"
rmdir "libttspico/usr/lib/"*-linux-gnu
mv libttspico/usr/bin/* /usr/bin/
mv libttspico/usr/lib/* /usr/lib/
mv libttspico/usr/share/pico /usr/share/
mv libttspico/usr/share/doc/* /usr/share/doc/
mv libttspico/usr/share/man/man1/* /usr/share/man/man1/

# Load new libraries
ldconfig

# Install picospeaker
cd /usr/src
git clone git://github.com/the-kyle/picospeaker.git picospeaker
install -D -m755 picospeaker/picospeaker /usr/bin/picospeaker
rm -rf picospeaker

# CentOS 7 patch
if [[ "$release" = "7" ]]; then
 mv /usr/lib/libttspico.so.0* /usr/lib64/
 ln -s /usr/lib64/libttspico.so.0 /usr/lib/libttspico.so.0
else
 ln -s /usr/lib64/libttspico.so.0 /usr/lib/libttspico.so.0
fi
