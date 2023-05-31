#!/bin/bash

declare packages=(
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/s390x/musl-1.2.4-r0.apk'
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/s390x/musl-dev-1.2.4-r0.apk'
	'http://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/edge/main/s390x/linux-headers-6.3-r0.apk'
)

declare extra_configure_flags='--with-arch=z196 --with-tune=zEC12 --with-zarch'

declare triple='s390x-unknown-linux-musl'

declare ld='ld-musl-s390x.so.1'

declare sysroot='http://web.archive.org/web/0if_/https://dl-cdn.alpinelinux.org/alpine/edge/releases/s390x/alpine-minirootfs-3.17.0-s390x.tar.gz'

declare os='alpine'
