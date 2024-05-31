#!/bin/bash

declare extra_configure_flags='--with-arch=armv6 --with-fpu=vfp --with-float=hard'

declare triplet='arm-unknown-linux-musleabihf'

declare ld='ld-musl-armhf.so.1'

declare os='void'
