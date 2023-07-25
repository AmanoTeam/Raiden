#!/bin/bash

declare packages=(
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/musl-1.1.24_17.armv7l-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/musl-devel-1.1.24_17.armv7l-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/kernel-libc-headers-5.10.4_1.armv7l.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/libexecinfo-devel-1.1_3.armv7l-musl.xbps'
)

declare extra_configure_flags='--with-arch=armv7-a --with-fpu=vfpv3 --with-float=hard'

declare triplet='armv7l-unknown-linux-musleabihf'

declare ld='ld-musl-armhf.so.1'

declare sysroot='https://web.archive.org/web/0if_/https://repo-default.voidlinux.org/live/current/void-armv7l-musl-ROOTFS-20230628.tar.xz'

declare os='void'
