#!/bin/bash

declare extra_configure_flags='--with-arch=armv8-a --with-abi=lp64'

declare triplet='aarch64-unknown-linux-musl'

repository='https://dl-cdn.alpinelinux.org/alpine/'
release='edge'
resource='main community'
architecture='aarch64'
format='apk'
