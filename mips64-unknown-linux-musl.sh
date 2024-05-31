#!/bin/bash

declare extra_configure_flags='--with-arch=mips3 --with-tune=mips64 --with-mips-plt --with-float=soft --with-abi=64'

declare triplet='mips64-unknown-linux-musl'

declare ld='ld-musl-mips64-sf.so.1'

declare os='alpine'
