#!/bin/bash

declare packages=(
	'https://alpha.de.repo.voidlinux.org/current/musl/musl-devel-1.1.24_15.x86_64-musl.xbps'
	'https://alpha.de.repo.voidlinux.org/current/kernel-libc-headers-5.10.4_1.x86_64.xbps'
	'https://alpha.de.repo.voidlinux.org/current/musl/libexecinfo-devel-1.1_3.x86_64-musl.xbps'
)

declare extra_configure_flags=''

declare triple='x86_64-unknown-linux-musl'

declare ld='ld-musl-x86_64.so.1'

declare sysroot='https://repo-default.voidlinux.org/live/current/void-x86_64-musl-ROOTFS-20221001.tar.xz'

declare os='void'
