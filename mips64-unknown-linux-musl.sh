#!/bin/bash

declare packages=(
	'https://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/v3.14/main/mips64/musl-1.2.2-r3.apk'
	'https://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/v3.14/main/mips64/musl-dev-1.2.2-r3.apk'
	'https://web.archive.org/web/0if_/https://dl-3.alpinelinux.org/alpine/v3.14/main/mips64/linux-headers-5.10.41-r0.apk'
)

declare extra_configure_flags='--with-arch=mips3 --with-tune=mips64 --with-mips-plt --with-float=soft --with-abi=64'

declare triplet='mips64-unknown-linux-musl'

declare ld='ld-musl-mips64-sf.so.1'

declare sysroot='https://web.archive.org/web/0if_/https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/mips64/alpine-minirootfs-3.14.2-mips64.tar.gz'

declare os='alpine'
