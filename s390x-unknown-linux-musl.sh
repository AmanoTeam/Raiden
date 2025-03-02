#!/bin/bash

declare extra_configure_flags='--with-arch=z196 --with-tune=zEC12 --with-zarch --without-long-double-128'

declare triplet='s390x-unknown-linux-musl'

declare ld='ld-musl-s390x.so.1'

declare os='alpine'
