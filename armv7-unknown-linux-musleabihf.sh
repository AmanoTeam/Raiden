#!/bin/bash

declare extra_configure_flags='--with-arch=armv7-a --with-fpu=vfpv3 --with-float=hard'

declare triplet='armv7l-unknown-linux-musleabihf'

declare ld='ld-musl-armhf.so.1'

declare os='void'
