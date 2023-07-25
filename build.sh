#!/bin/bash

set -eu

declare -r current_source_directory="${PWD}"

declare -r revision="$(git rev-parse --short HEAD)"

declare -r toolchain_directory='/tmp/raiden'

declare -r gmp_tarball='/tmp/gmp.tar.xz'
declare -r gmp_directory='/tmp/gmp-6.2.1'

declare -r mpfr_tarball='/tmp/mpfr.tar.xz'
declare -r mpfr_directory='/tmp/mpfr-4.2.0'

declare -r mpc_tarball='/tmp/mpc.tar.gz'
declare -r mpc_directory='/tmp/mpc-1.3.1'

declare -r binutils_tarball='/tmp/binutils.tar.xz'
declare -r binutils_directory='/tmp/binutils-2.40'

declare -r gcc_tarball='/tmp/gcc.tar.gz'
declare -r gcc_directory='/tmp/gcc-master'

declare -r optflags='-Os'
declare -r linkflags='-Wl,-s'

declare -r max_jobs="$(($(nproc) * 8))"

declare build_type="${1}"

if [ -z "${build_type}" ]; then
	build_type='native'
fi

declare is_native='0'

if [ "${build_type}" == 'native' ]; then
	is_native='1'
fi

declare OBGGCC_TOOLCHAIN='/tmp/obggcc-toolchain'
declare CROSS_COMPILE_TRIPLET=''

declare cross_compile_flags=''

if ! (( is_native )); then
	source "./submodules/obggcc/toolchains/${build_type}.sh"
	cross_compile_flags+="--host=${CROSS_COMPILE_TRIPLET}"
fi

if ! [ -f "${gmp_tarball}" ]; then
	wget --no-verbose 'https://mirrors.kernel.org/gnu/gmp/gmp-6.2.1.tar.xz' --output-document="${gmp_tarball}"
	tar --directory="$(dirname "${gmp_directory}")" --extract --file="${gmp_tarball}"
fi

if ! [ -f "${mpfr_tarball}" ]; then
	wget --no-verbose 'https://mirrors.kernel.org/gnu/mpfr/mpfr-4.2.0.tar.xz' --output-document="${mpfr_tarball}"
	tar --directory="$(dirname "${mpfr_directory}")" --extract --file="${mpfr_tarball}"
fi

if ! [ -f "${mpc_tarball}" ]; then
	wget --no-verbose 'https://mirrors.kernel.org/gnu/mpc/mpc-1.3.1.tar.gz' --output-document="${mpc_tarball}"
	tar --directory="$(dirname "${mpc_directory}")" --extract --file="${mpc_tarball}"
fi

if ! [ -f "${binutils_tarball}" ]; then
	wget --no-verbose 'https://mirrors.kernel.org/gnu/binutils/binutils-2.40.tar.xz' --output-document="${binutils_tarball}"
	tar --directory="$(dirname "${binutils_directory}")" --extract --file="${binutils_tarball}"
fi

if ! [ -f "${gcc_tarball}" ]; then
	wget --no-verbose 'https://codeload.github.com/gcc-mirror/gcc/tar.gz/refs/heads/master' --output-document="${gcc_tarball}"
	tar --directory="$(dirname "${gcc_directory}")" --extract --file="${gcc_tarball}"
fi

sed --in-place 's/LDBL_MANT_DIG == 106/defined(__powerpc64__)/g' "${gcc_directory}/libgcc/dfp-bit.h"

[ -d "${gmp_directory}/build" ] || mkdir "${gmp_directory}/build"

cd "${gmp_directory}/build"

../configure \
	--prefix="${toolchain_directory}" \
	--enable-shared \
	--enable-static \
	${cross_compile_flags} \
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${mpfr_directory}/build" ] || mkdir "${mpfr_directory}/build"

cd "${mpfr_directory}/build"

../configure \
	--prefix="${toolchain_directory}" \
	--with-gmp="${toolchain_directory}" \
	--enable-shared \
	--enable-static \
	${cross_compile_flags} \
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${mpc_directory}/build" ] || mkdir "${mpc_directory}/build"

cd "${mpc_directory}/build"

../configure \
	--prefix="${toolchain_directory}" \
	--with-gmp="${toolchain_directory}" \
	--enable-shared \
	--enable-static \
	${cross_compile_flags} \
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

declare -ra targets=(
	'armv7l-unknown-linux-musleabihf'
	'powerpc64le-unknown-linux-musl'
	'x86_64-unknown-linux-musl'
	'aarch64-unknown-linux-musl'
	'arm-unknown-linux-musleabihf'
	'riscv64-unknown-linux-musl'
	's390x-unknown-linux-musl'
	'i386-unknown-linux-musl'
)

for target in "${targets[@]}"; do
	source "${current_source_directory}/${target}.sh"
	
	cd "$(mktemp --directory)"
	
	if [ "${os}" == 'void' ]; then
		declare sysroot_filename="./sysroot.tar.xz"
	else
		declare sysroot_filename="./sysroot.tar.gz"
	fi
	
	wget --no-verbose "${sysroot}" --output-document="${sysroot_filename}"
	tar --extract --file="${sysroot_filename}" || true
	
	if [ "${os}" == 'void' ]; then
		declare package_filename="./package.tar.xst"
	else
		declare package_filename="./package.tar.gz"
	fi
	
	for package in "${packages[@]}"; do
		wget --no-verbose "${package}" --output-document="${package_filename}"
		tar --extract --file="${package_filename}"
	done
	
	[ -d "${toolchain_directory}/${triplet}" ] || mkdir --parent "${toolchain_directory}/${triplet}"
	
	cp --recursive './usr/include' "${toolchain_directory}/${triplet}"
	cp --recursive './usr/lib' "${toolchain_directory}/${triplet}"
	
	if [ -d './lib' ]; then
		cp --remove-destination --recursive './lib/'* "${toolchain_directory}/${triplet}/lib"
	fi
	
	pushd "${toolchain_directory}/${triplet}/lib"
	
	if [ "${os}" == 'alpine' ]; then
		find . -xtype l | xargs ls -l | grep '/lib/' | awk '{print "unlink "$9" && ln -s $(basename "$11") $(basename "$9")"}' | bash
		
		unlink './libc.so'
		mv "${ld}" './libc.so'
		
		patchelf --set-soname 'libc.so' './libc.so'
	fi
	
	if [ -L "${ld}" ]; then
		unlink "${ld}"
	fi
	
	ln --symbolic './libc.so' "${ld}"
	
	while read filename; do
		if [[ "${filename}" =~ ^lib(pthread|resolv|rt|c|m|util|xnet)\.(so|a)$ || "${filename}" =~ ^.*\.o$ || "${filename}" =~ ^ld\-.*\.so.*$ ]]; then
			continue
		fi
		
		rm --recursive "${filename}"
	done <<< "$(ls)"
	
	[ -d "${binutils_directory}/build" ] || mkdir "${binutils_directory}/build"
	
	cd "${binutils_directory}/build"
	rm --force --recursive ./*
	
	../configure \
		--target="${triplet}" \
		--prefix="${toolchain_directory}" \
		--enable-gold \
		--enable-ld \
		--enable-lto \
		--disable-gprofng \
		--with-static-standard-libraries \
		${cross_compile_flags} \
		CFLAGS="${optflags}" \
		CXXFLAGS="${optflags}" \
		LDFLAGS="${linkflags}"
	
	make all --jobs="${max_jobs}"
	make install
	
	[ -d "${gcc_directory}/build" ] || mkdir "${gcc_directory}/build"
	
	cd "${gcc_directory}/build"
	
	rm --force --recursive ./*
	
	../configure \
		--target="${triplet}" \
		--prefix="${toolchain_directory}" \
		--with-linker-hash-style='gnu' \
		--with-gmp="${toolchain_directory}" \
		--with-mpc="${toolchain_directory}" \
		--with-mpfr="${toolchain_directory}" \
		--with-bugurl='https://github.com/AmanoTeam/Raiden/issues' \
		--with-pkgversion="Raiden v0.3-${revision}" \
		--with-sysroot="${toolchain_directory}/${triplet}" \
		--with-gcc-major-version-only \
		--with-native-system-header-dir='/include' \
		--enable-__cxa_atexit \
		--enable-cet='auto' \
		--enable-checking='release' \
		--enable-clocale='gnu' \
		--enable-default-ssp \
		--enable-gnu-indirect-function \
		--enable-libssp \
		--enable-libstdcxx-backtrace \
		--enable-link-serialization='1' \
		--enable-linker-build-id \
		--enable-lto \
		--enable-plugin \
		--enable-shared \
		--enable-threads='posix' \
		--enable-ld \
		--enable-gold \
		--enable-languages='c,c++' \
		--disable-gnu-unique-object \
		--disable-libsanitizer \
		--disable-symvers \
		--disable-sjlj-exceptions \
		--disable-target-libiberty \
		--disable-multilib \
		--disable-werror \
		--disable-libgomp \
		--disable-bootstrap \
		--disable-libstdcxx-pch \
		--disable-nls \
		--without-headers \
		${extra_configure_flags} \
		${cross_compile_flags} \
		libat_cv_have_ifunc=no \
		CFLAGS="${optflags}" \
		CXXFLAGS="${optflags}" \
		LDFLAGS="-Wl,-rpath-link,${OBGGCC_TOOLCHAIN}/${CROSS_COMPILE_TRIPLET}/lib ${linkflags}"
	
	LD_LIBRARY_PATH="${toolchain_directory}/lib" PATH="${PATH}:${toolchain_directory}/bin" make \
		CFLAGS_FOR_TARGET="${optflags} ${linkflags}" \
		CXXFLAGS_FOR_TARGET="${optflags} ${linkflags}" \
		all --jobs="${max_jobs}"
	make install
	
	cd "${toolchain_directory}/${triplet}/bin"
	
	for name in *; do
		rm "${name}"
		ln -s "../../bin/${triplet}-${name}" "${name}"
	done
	
	rm --recursive "${toolchain_directory}/share"
	rm --recursive "${toolchain_directory}/lib/gcc/${triplet}/"*"/include-fixed"
	
	patchelf --add-rpath '$ORIGIN/../../../../lib' "${toolchain_directory}/libexec/gcc/${triplet}/"*"/cc1"
	patchelf --add-rpath '$ORIGIN/../../../../lib' "${toolchain_directory}/libexec/gcc/${triplet}/"*"/cc1plus"
	patchelf --add-rpath '$ORIGIN/../../../../lib' "${toolchain_directory}/libexec/gcc/${triplet}/"*"/lto1"
done
