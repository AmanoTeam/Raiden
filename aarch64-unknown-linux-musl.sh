#!/bin/bash

declare packages=(
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/aarch64/musl-1.1.24_17.aarch64-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/aarch64/musl-devel-1.1.24_17.aarch64-musl.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/aarch64/kernel-libc-headers-5.10.4_1.aarch64.xbps'
	'https://web.archive.org/web/0if_/https://alpha.de.repo.voidlinux.org/current/aarch64/libexecinfo-devel-1.1_3.aarch64-musl.xbps'
)

declare extra_configure_flags=''

declare triplet='aarch64-unknown-linux-musl'

declare ld='ld-musl-aarch64.so.1'

declare sysroot='https://web.archive.org/web/0if_/https://repo-default.voidlinux.org/live/current/void-aarch64-musl-ROOTFS-20230628.tar.xz'

declare os='void'
