#!/bin/bash

declare packages=(
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/musl-1.2.4-r0.apk'
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/musl-dev-1.2.4-r0.apk'
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/ppc64le/linux-headers-6.3-r0.apk'
)

declare extra_configure_flags='--with-abi=elfv2'

declare triple='powerpc64le-unknown-linux-musl'

declare ld='ld-musl-powerpc64le.so.1'

declare sysroot='http://web.archive.org/web/0if_/https://dl-cdn.alpinelinux.org/alpine/edge/releases/ppc64le/alpine-minirootfs-3.10.0-ppc64le.tar.gz'

declare os='alpine'
