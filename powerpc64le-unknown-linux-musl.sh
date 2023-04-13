#!/bin/bash

declare packages=(
	'https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/musl-1.2.3_git20230322-r0.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/musl-dev-1.2.3_git20230322-r0.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/linux-headers-6.2-r0.apk'
)

declare extra_configure_flags='--with-abi=elfv2'

declare triple='powerpc64le-unknown-linux-musl'

declare ld='ld-musl-powerpc64le.so.1'

declare sysroot='https://dl-cdn.alpinelinux.org/alpine/edge/releases/ppc64le/alpine-minirootfs-3.9.0_rc5-ppc64le.tar.gz'

declare os='alpine'
