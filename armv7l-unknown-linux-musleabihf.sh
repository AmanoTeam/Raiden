#!/bin/bash

declare packages=(
	'https://alpha.de.repo.voidlinux.org/current/musl/musl-devel-1.1.24_15.armv7l-musl.xbps'
	'https://alpha.de.repo.voidlinux.org/current/kernel-libc-headers-5.10.4_1.armv7l.xbps'
	'https://alpha.de.repo.voidlinux.org/current/musl/libexecinfo-devel-1.1_3.armv7l-musl.xbps'
)

declare extra_configure_flags='--with-arch=armv7-a --with-fpu=vfpv3 --with-float=hard'

declare triple='armv7l-unknown-linux-musleabihf'

declare ld='ld-musl-armhf.so.1'

declare sysroot='https://repo-default.voidlinux.org/live/current/void-armv7l-musl-ROOTFS-20221001.tar.xz'

declare os='void'
