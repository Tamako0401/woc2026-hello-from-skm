#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: $0 [-b /path/to/busybox] [-k /path/to/linux] [-t <target>]" 1>&2
	exit 1
}

config_rootfs() {
	pushd "$BUSYBOX"/_install >/dev/null
	mkdir -p usr/share/udhcpc/ etc/init.d/
	cat <<EOF >etc/init.d/rcS
mkdir -p /proc
mount -t proc none /proc
ifconfig lo up
ifconfig eth0 up
udhcpc -i eth0
mount -t devtmpfs none /dev
mkdir -p /dev/pts
mount -t devpts nodev  /dev/pts
telnetd -l /bin/sh
clear
EOF
	chmod a+x etc/init.d/rcS bin/*

	cat <<EOF >etc/inittab
::sysinit:/etc/init.d/rcS
::once:-/bin/sh
::ctrlaltdel:/sbin/reboot
::ctrlaltbreak:/sbin/poweroff
#::shutdown:/bin/umount -a -r
#::shutdown:/sbin/swapoff -a
EOF
	# cp ../examples/inittab etc/

	cp ../examples/udhcp/simple.script usr/share/udhcpc/default.script
	popd >/dev/null
}

KERNEL=./linux
TARGET=

while getopts b:k:t: option; do
	case "$option" in
	b) BUSYBOX=${OPTARG} ;;
	k) KERNEL=${OPTARG} ;;
	t) TARGET=${OPTARG} ;;
	*) usage ;;
	esac
done

if [[ ! -d "$KERNEL" ]]; then
	echo "Kernel directory '$KERNEL' not found" >&2
	exit 1
fi

echo "Building linux kernel..."
pushd "$KERNEL" >/dev/null
yes "" | make LLVM=1 CLIPPY=1 "$TARGET" -j"$(nproc)"
popd >/dev/null

echo "Building busybox initrd..."
yes "" | make -j"$(nproc)"
make install
find _install/ | cpio -o -H newc | gzip > ./rootfs.img
popd >/dev/null

echo "Setting up the rootfs"
config_rootfs
