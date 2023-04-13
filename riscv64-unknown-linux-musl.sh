#!/bin/bash

declare packages=(
	'https://dl-3.alpinelinux.org/alpine/edge/main/riscv64/musl-1.2.3_git20230322-r0.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/riscv64/musl-dev-1.2.3_git20230322-r0.apk'
	'https://dl-3.alpinelinux.org/alpine/edge/main/riscv64/linux-headers-6.2-r0.apk'
)

declare extra_configure_flags='--with-arch=rv64gc --with-abi=lp64d'

declare triple='riscv64-unknown-linux-musl'

declare ld='ld-musl-riscv64.so.1'

declare sysroot='https://dl-cdn.alpinelinux.org/alpine/edge/releases/riscv64/alpine-minirootfs-3.17.0-riscv64.tar.gz'

declare os='alpine'
