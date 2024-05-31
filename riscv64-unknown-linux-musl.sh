#!/bin/bash

declare extra_configure_flags='--with-arch=rv64gc --with-abi=lp64d'

declare triplet='riscv64-unknown-linux-musl'

declare ld='ld-musl-riscv64.so.1'

declare os='alpine'
