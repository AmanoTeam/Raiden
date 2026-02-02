#!/bin/bash

declare extra_configure_flags='--with-arch=armv7-a --with-fpu=vfpv3 --with-float=hard'

declare triplet='armv7-unknown-linux-musleabihf'

repository='https://dl-cdn.alpinelinux.org/alpine/'
release='edge'
resource='main community'
architecture='armv7'
format='apk'
