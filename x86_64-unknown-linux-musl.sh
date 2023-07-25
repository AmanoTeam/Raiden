#!/bin/bash

declare packages=(
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/musl-1.1.24_17.x86_64-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/musl-devel-1.1.24_17.x86_64-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/kernel-libc-headers-5.10.4_1.x86_64.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/musl/libexecinfo-devel-1.1_3.x86_64-musl.xbps'
)

declare extra_configure_flags=''

declare triplet='x86_64-unknown-linux-musl'

declare ld='ld-musl-x86_64.so.1'

declare sysroot='https://web.archive.org/web/0if_/https://repo-default.voidlinux.org/live/current/void-x86_64-musl-ROOTFS-20230628.tar.xz'

declare os='void'
