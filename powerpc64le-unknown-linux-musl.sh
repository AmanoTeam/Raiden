#!/bin/bash

declare extra_configure_flags='--with-abi=elfv2 --without-long-double-128'

declare triplet='powerpc64le-unknown-linux-musl'

declare ld='ld-musl-powerpc64le.so.1'

declare os='alpine'
