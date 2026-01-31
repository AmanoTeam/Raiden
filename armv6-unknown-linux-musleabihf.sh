#!/bin/bash

declare extra_configure_flags='--with-arch=armv6 --with-fpu=vfp --with-float=hard'

declare triplet='arm-unknown-linux-musleabihf'

repository='https://dl-cdn.alpinelinux.org/alpine/'
release='edge'
resource='main community'
architecture='armhf'
format='apk'
