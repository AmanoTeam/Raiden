#!/bin/bash

declare extra_configure_flags='--with-arch=i586 --with-tune=generic'

declare triplet='i386-unknown-linux-musl'

declare ld='ld-musl-i386.so.1'

repository='https://dl-cdn.alpinelinux.org/alpine/'
release='edge'
resource='main community'
architecture='x86'
