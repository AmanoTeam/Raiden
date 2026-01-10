# musl-gcc-cross

This is a GCC cross-compiler targeting Linux musl. You can use it to create fully statically linked binaries that work on any Linux distro, or dynamically linked binaries suitable for use in Linux distros based on musl libc, such as Alpine Linux and Void Linux.

## releases

The current release is based on GCC 15 and supports cross-compiling for the `x86`, `x86_64`, `loongarch`, `powerpc`, `s390x`, `mips`, `riscv64`, `arm`, and `aarch64` targets. The toolchain includes support for the C and C++ frontends.

You can download the prebuilt toolchains from the [releases](https://github.com/AmanoTeam/Raiden/releases) page.
