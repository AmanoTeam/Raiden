#!/bin/bash

declare packages=(
	'https://alpha.de.repo.voidlinux.org/current/musl/musl-devel-1.1.24_15.armv6l-musl.xbps'
	'https://alpha.de.repo.voidlinux.org/current/kernel-libc-headers-5.10.4_1.armv6l.xbps'
	'https://alpha.de.repo.voidlinux.org/current/musl/libexecinfo-devel-1.1_3.armv6l-musl.xbps'
)

declare extra_configure_flags='--with-arch=armv6 --with-fpu=vfp --with-float=hard'

declare triple='arm-unknown-linux-musleabihf'

declare ld='ld-musl-armhf.so.1'

declare sysroot='https://repo-default.voidlinux.org/live/current/void-armv6l-musl-ROOTFS-20221001.tar.xz'

declare os='void'
