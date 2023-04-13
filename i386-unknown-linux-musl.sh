#!/bin/bash

declare packages=(
	'https://dl-3.alpinelinux.org/alpine/edge/main/x86/musl-1.2.3_git20230322-r3.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/x86/musl-dev-1.2.3_git20230322-r3.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/x86/linux-headers-6.2-r0.apk'
)

declare extra_configure_flags='--with-arch=i586 --with-tune=generic'

declare triple='i386-unknown-linux-musl'

declare ld='ld-musl-i386.so.1'

declare sysroot='https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86/alpine-minirootfs-3.17.0-x86.tar.gz'

declare os='alpine'
