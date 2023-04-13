#!/bin/bash

declare packages=(
	'https://alpha.de.repo.voidlinux.org/current/aarch64/musl-devel-1.1.24_15.aarch64-musl.xbps'
	'https://alpha.de.repo.voidlinux.org/current/aarch64/kernel-libc-headers-5.10.4_1.aarch64.xbps'
	'https://alpha.de.repo.voidlinux.org/current/aarch64/libexecinfo-devel-1.1_3.aarch64-musl.xbps'
)

declare extra_configure_flags=''

declare triple='aarch64-unknown-linux-musl'

declare ld='ld-musl-aarch64.so.1'

declare sysroot='https://repo-default.voidlinux.org/live/current/void-aarch64-musl-ROOTFS-20221001.tar.xz'

declare os='void'
