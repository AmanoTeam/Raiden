#!/bin/bash

set -eu

declare -r workdir="${PWD}"

declare -r revision="$(git rev-parse --short HEAD)"

declare -r toolchain_directory='/tmp/raiden'
declare -r share_directory="${toolchain_directory}/usr/local/share/raiden"

declare -r environment="LD_LIBRARY_PATH=${toolchain_directory}/lib PATH=${PATH}:${toolchain_directory}/bin"

declare -r gcc_major='15'

declare -r gmp_tarball='/tmp/gmp.tar.xz'
declare -r gmp_directory='/tmp/gmp-6.3.0'

declare -r mpfr_tarball='/tmp/mpfr.tar.xz'
declare -r mpfr_directory='/tmp/mpfr-4.2.2'

declare -r mpc_tarball='/tmp/mpc.tar.gz'
declare -r mpc_directory='/tmp/mpc-1.3.1'

declare -r isl_tarball='/tmp/isl.tar.xz'
declare -r isl_directory='/tmp/isl-0.27'

declare -r binutils_tarball='/tmp/binutils.tar.xz'
declare -r binutils_directory='/tmp/binutils'

declare -r gcc_tarball='/tmp/gcc.tar.xz'
declare -r gcc_directory="/tmp/gcc-releases-gcc-${gcc_major}"

declare -r zlib_tarball='/tmp/zlib.tar.gz'
declare -r zlib_directory='/tmp/zlib-develop'

declare -r zstd_tarball='/tmp/zstd.tar.gz'
declare -r zstd_directory='/tmp/zstd-dev'

declare -r nz_directory="${workdir}/submodules/nz"
declare -r nz_prefix='/tmp/nz'

declare -r sysroot_tarball='/tmp/sysroot.tar.xz'

declare -r max_jobs='30'

declare -r ccflags='-w -O2'
declare -r linkflags='-Xlinker -s'

declare -ra targets=(
	'i386-unknown-linux-musl'
	'x86_64-unknown-linux-musl'
	'armv6-unknown-linux-musleabihf'
	'armv7-unknown-linux-musleabihf'
	'aarch64-unknown-linux-musl'
)

declare -r gcc_wrapper='/tmp/gcc-wrapper'
declare -r clang_wrapper='/tmp/clang-wrapper'

declare build_nz='1'

declare exe=''
declare dll='.so'

declare musl_version='1.2'

declare -r PKG_CONFIG_PATH="${toolchain_directory}/lib/pkgconfig"
declare -r PKG_CONFIG_LIBDIR="${PKG_CONFIG_PATH}"
declare -r PKG_CONFIG_SYSROOT_DIR="${toolchain_directory}"

declare -r pkg_cv_ZSTD_CFLAGS="-I${toolchain_directory}/include"
declare -r pkg_cv_ZSTD_LIBS="-L${toolchain_directory}/lib -lzstd"
declare -r ZSTD_CFLAGS="-I${toolchain_directory}/include"
declare -r ZSTD_LIBS="-L${toolchain_directory}/lib -lzstd"

export \
	PKG_CONFIG_PATH \
	PKG_CONFIG_LIBDIR \
	PKG_CONFIG_SYSROOT_DIR \
	pkg_cv_ZSTD_CFLAGS \
	pkg_cv_ZSTD_LIBS \
	ZSTD_CFLAGS \
	ZSTD_LIBS

declare build_type="${1}"

if [ -z "${build_type}" ]; then
	build_type='native'
fi

declare is_native='0'

if [ "${build_type}" = 'native' ]; then
	is_native='1'
fi

set +u

if [ -z "${CROSS_COMPILE_TRIPLET}" ]; then
	declare CROSS_COMPILE_TRIPLET=''
fi

set -u

declare -r \
	build_type \
	is_native

if ! [ -f "${gmp_tarball}" ]; then
	curl \
		--url 'https://gnu.mirror.constant.com/gmp/gmp-6.3.0.tar.xz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${gmp_tarball}"
	
	tar \
		--directory="$(dirname "${gmp_directory}")" \
		--extract \
		--file="${gmp_tarball}"
	
	patch --directory="${gmp_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Remove-hardcoded-RPATH-and-versioned-SONAME-from-libgmp.patch"
fi

if ! [ -f "${mpfr_tarball}" ]; then
	curl \
		--url 'https://gnu.mirror.constant.com/mpfr/mpfr-4.2.2.tar.xz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${mpfr_tarball}"
	
	tar \
		--directory="$(dirname "${mpfr_directory}")" \
		--extract \
		--file="${mpfr_tarball}"
	
	patch --directory="${mpfr_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Remove-hardcoded-RPATH-and-versioned-SONAME-from-libmpfr.patch"
fi

if ! [ -f "${mpc_tarball}" ]; then
	curl \
		--url 'https://gnu.mirror.constant.com/mpc/mpc-1.3.1.tar.gz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${mpc_tarball}"
	
	tar \
		--directory="$(dirname "${mpc_directory}")" \
		--extract \
		--file="${mpc_tarball}"
	
	patch --directory="${mpc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Remove-hardcoded-RPATH-and-versioned-SONAME-from-libmpc.patch"
fi

if ! [ -f "${isl_tarball}" ]; then
	curl \
		--url 'https://deb.debian.org/debian/pool/main/i/isl/isl_0.27.orig.tar.xz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${isl_tarball}"
	
	tar \
		--directory="$(dirname "${isl_directory}")" \
		--extract \
		--file="${isl_tarball}"
	
	patch --directory="${isl_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Remove-hardcoded-RPATH-and-versioned-SONAME-from-libisl.patch"
fi

if ! [ -f "${binutils_tarball}" ]; then
	curl \
		--url 'https://github.com/AmanoTeam/binutils-snapshots/releases/latest/download/binutils.tar.xz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${binutils_tarball}"
	
	tar \
		--directory="$(dirname "${binutils_directory}")" \
		--extract \
		--file="${binutils_tarball}"
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-darwin'* ]]; then
		sed \
			--in-place \
			's/$$ORIGIN/@loader_path/g' \
			"${workdir}/submodules/obggcc/patches/0001-Add-relative-RPATHs-to-binutils-host-tools.patch"
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'bsd'* ]] || [[ "${CROSS_COMPILE_TRIPLET}" = *'dragonfly' ]] then
		sed \
			--in-place \
			's/-Xlinker -rpath/-Xlinker -z -Xlinker origin -Xlinker -rpath/g' \
			"${workdir}/submodules/obggcc/patches/0001-Add-relative-RPATHs-to-binutils-host-tools.patch"
	fi
	
	patch --directory="${binutils_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Add-relative-RPATHs-to-binutils-host-tools.patch"
	patch --directory="${binutils_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Don-t-warn-about-local-symbols-within-the-globals.patch"
fi

if ! [ -f "${zlib_tarball}" ]; then
	curl \
		--url 'https://github.com/madler/zlib/archive/refs/heads/develop.tar.gz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${zlib_tarball}"
	
	tar \
		--directory="$(dirname "${zlib_directory}")" \
		--extract \
		--file="${zlib_tarball}"
	
	patch --directory="${zlib_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Remove-versioned-SONAME-from-libz.patch"
fi

if ! [ -f "${zstd_tarball}" ]; then
	curl \
		--url 'https://github.com/facebook/zstd/archive/refs/heads/dev.tar.gz' \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${zstd_tarball}"
	
	tar \
		--directory="$(dirname "${zstd_directory}")" \
		--extract \
		--file="${zstd_tarball}"
fi

if ! [ -f "${gcc_tarball}" ]; then
	curl \
		--url "https://github.com/gcc-mirror/gcc/archive/releases/gcc-${gcc_major}.tar.gz" \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--silent \
		--output "${gcc_tarball}"
	
	tar \
		--directory="$(dirname "${gcc_directory}")" \
		--extract \
		--file="${gcc_tarball}"
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-darwin'* ]]; then
		sed \
			--in-place \
			's/$$ORIGIN/@loader_path/g' \
			"${workdir}/submodules/obggcc/patches/0007-Add-relative-RPATHs-to-GCC-host-tools.patch"
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'bsd'* ]] || [[ "${CROSS_COMPILE_TRIPLET}" = *'dragonfly' ]] then
		sed \
			--in-place \
			's/-Xlinker -rpath/-Xlinker -z -Xlinker origin -Xlinker -rpath/g' \
			"${workdir}/submodules/obggcc/patches/0007-Add-relative-RPATHs-to-GCC-host-tools.patch"
	fi
	
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/patches/0001-Fix-libgcc-build-on-musl.patch"
	
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Turn-Wimplicit-function-declaration-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0002-Fix-libsanitizer-build-on-older-platforms.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0003-Change-the-default-language-version-for-C-compilation-from-std-gnu23-to-std-gnu17.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/gcc-15/0004-Turn-Wimplicit-int-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0005-Turn-Wint-conversion-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/gcc-15/0006-Turn-Wincompatible-pointer-types-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0007-Add-relative-RPATHs-to-GCC-host-tools.patch"
	
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/gcc-15/0001-Enable-automatic-linking-of-libatomic.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-AArch64-enable-libquadmath.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Prevent-libstdc-from-trying-to-implement-math-stubs.patch"
fi

# Follow Debian's approach for removing hardcoded RPATH from binaries
# https://wiki.debian.org/RpathIssue
sed \
	--in-place \
	--regexp-extended \
	's/(hardcode_into_libs)=.*$/\1=no/' \
	"${isl_directory}/configure" \
	"${mpc_directory}/configure" \
	"${mpfr_directory}/configure" \
	"${gmp_directory}/configure" \
	"${gcc_directory}/libsanitizer/configure"

# Avoid using absolute hardcoded install_name values on macOS
sed \
	--in-place \
	's|-install_name \\$rpath/\\$soname|-install_name @rpath/\\$soname|g' \
	"${isl_directory}/configure" \
	"${mpc_directory}/configure" \
	"${mpfr_directory}/configure" \
	"${gmp_directory}/configure"

# Force GCC and binutils to prefix host tools with the target triplet even in native builds
sed \
	--in-place \
	's/test "$host_noncanonical" = "$target_noncanonical"/false/' \
	"${gcc_directory}/configure" \
	"${binutils_directory}/configure"

declare disable_assembly='--disable-assembly'

if [[ "${CROSS_COMPILE_TRIPLET}" != 'mips64el-'* ]]; then
	disable_assembly=''
fi

[ -d "${gmp_directory}/build" ] || mkdir "${gmp_directory}/build"

cd "${gmp_directory}/build"

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	${disable_assembly} \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${mpfr_directory}/build" ] || mkdir "${mpfr_directory}/build"

cd "${mpfr_directory}/build"

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--with-gmp="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${mpc_directory}/build" ] || mkdir "${mpc_directory}/build"

cd "${mpc_directory}/build"

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--with-gmp="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${isl_directory}/build" ] || mkdir "${isl_directory}/build"

cd "${isl_directory}/build"
rm --force --recursive ./*

declare isl_ldflags=''

if [[ "${CROSS_COMPILE_TRIPLET}" != *'-darwin'* ]]; then
	isl_ldflags+=" -Xlinker -rpath-link -Xlinker ${toolchain_directory}/lib"
fi

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--with-gmp-prefix="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	--with-pic \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags} ${isl_ldflags}"

make all --jobs
make install

[ -d "${zlib_directory}/build" ] || mkdir "${zlib_directory}/build"

cd "${zlib_directory}/build"
rm --force --recursive ./*

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

unlink "${toolchain_directory}/lib/libz.a"

[ -d "${zstd_directory}/.build" ] || mkdir "${zstd_directory}/.build"

cd "${zstd_directory}/.build"
rm --force --recursive ./*

declare cmake_flags=''

if [[ "${CROSS_COMPILE_TRIPLET}" = *'-darwin'* ]]; then
	cmake_flags+=' -DCMAKE_SYSTEM_NAME=Darwin'
fi

cmake \
	-S "${zstd_directory}/build/cmake" \
	-B "${PWD}" \
	${cmake_flags} \
	-DCMAKE_C_FLAGS="-DZDICT_QSORT=ZDICT_QSORT_MIN ${ccflags}" \
	-DCMAKE_INSTALL_PREFIX="${toolchain_directory}" \
	-DBUILD_SHARED_LIBS=ON \
	-DZSTD_BUILD_PROGRAMS=OFF \
	-DZSTD_BUILD_TESTS=OFF \
	-DZSTD_BUILD_STATIC=OFF \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON

cmake --build "${PWD}"
cmake --install "${PWD}" --strip

if (( build_nz )); then
	[ -d "${nz_directory}/build" ] || mkdir "${nz_directory}/build"
	
	cd "${nz_directory}/build"
	rm --force --recursive ./*
	
	cmake \
		-S "${nz_directory}" \
		-B "${PWD}" \
		-DCMAKE_C_FLAGS="${ccflags}" \
		-DCMAKE_CXX_FLAGS="${ccflags}" \
		-DCMAKE_INSTALL_PREFIX="${nz_prefix}"
	
	cmake --build "${PWD}" -- --jobs='1'
	cmake --install "${PWD}" --strip
	
	mkdir --parent "${toolchain_directory}/lib/nouzen"
	mv "${nz_prefix}/lib/"* "${toolchain_directory}/lib/nouzen"
	rmdir "${nz_prefix}/lib"
fi

# We prefer symbolic links over hard links.
cp "${workdir}/submodules/obggcc/tools/ln.sh" '/tmp/ln'

export PATH="/tmp:${PATH}"

if [[ "${CROSS_COMPILE_TRIPLET}" = 'arm'*'-android'* ]] || [[ "${CROSS_COMPILE_TRIPLET}" = 'i686-'*'-android'* ]] || [[ "${CROSS_COMPILE_TRIPLET}" = 'mipsel-'*'-android'* ]]; then
	export \
		ac_cv_func_fseeko='no' \
		ac_cv_func_ftello='no'
fi

if [[ "${CROSS_COMPILE_TRIPLET}" = 'armv5'*'-android'* ]]; then
	export PINO_ARM_MODE='true'
fi

if [[ "${CROSS_COMPILE_TRIPLET}" = *'-haiku' ]]; then
	export ac_cv_c_bigendian='no'
fi

make \
	-C "${workdir}/submodules/obggcc/tools/gcc-wrapper" \
	PREFIX="$(dirname "${gcc_wrapper}")" \
	CFLAGS="-D WCLANG ${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}"  \
	FLAVOR='RAIDEN' \
	gcc

cp "${gcc_wrapper}" "${clang_wrapper}"

make \
	-C "${workdir}/submodules/obggcc/tools/gcc-wrapper" \
	PREFIX="$(dirname "${gcc_wrapper}")" \
	CFLAGS="${ccflags}" \
	CXXFLAGS="${ccflags}" \
	LDFLAGS="${linkflags}" \
	FLAVOR='RAIDEN' \
	gcc

for target in "${targets[@]}"; do
	source "${workdir}/${target}.sh"
	
	cd "$(mktemp --directory)"
	
	curl \
		--url "https://github.com/AmanoTeam/musl-sysroot/releases/latest/download/${triplet}.tar.xz" \
		--retry '30' \
		--retry-all-errors \
		--retry-delay '0' \
		--retry-max-time '0' \
		--location \
		--output "${sysroot_tarball}"
	
	tar \
		--directory="${toolchain_directory}" \
		--extract \
		--file="${sysroot_tarball}"
	
	unlink "${sysroot_tarball}"
	
	[ -d "${binutils_directory}/build" ] || mkdir "${binutils_directory}/build"
	
	cd "${binutils_directory}/build"
	rm --force --recursive ./*
	
	../configure \
		--host="${CROSS_COMPILE_TRIPLET}" \
		--target="${triplet}" \
		--prefix="${toolchain_directory}" \
		--disable-gold \
		--enable-ld \
		--enable-lto \
		--enable-separate-code \
		--enable-rosegment \
		--enable-relro \
		--enable-compressed-debug-sections='all' \
		--enable-default-compressed-debug-sections-algorithm='zstd' \
		--disable-gprofng \
		--disable-default-execstack \
		--disable-warn-rwx-segments \
		--without-static-standard-libraries \
		--with-sysroot="${toolchain_directory}/${triplet}" \
		--with-zstd="${toolchain_directory}" \
		--with-system-zlib \
		CFLAGS="-I${toolchain_directory}/include ${ccflags}" \
		CXXFLAGS="-I${toolchain_directory}/include ${ccflags}" \
		LDFLAGS="-L${toolchain_directory}/lib ${linkflags}"
	
	make all --jobs
	make install
	
	if ! (( is_native )); then
		extra_configure_flags+=" --with-cross-host=${CROSS_COMPILE_TRIPLET}"
		extra_configure_flags+=" --with-toolexeclibdir=${toolchain_directory}/${triplet}/lib/"
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" != *'-darwin'* ]]; then
		extra_configure_flags+=' --enable-host-bind-now'
	fi
	
	[ -d "${gcc_directory}/build" ] || mkdir "${gcc_directory}/build"
	
	cd "${gcc_directory}/build"
	
	rm --force --recursive ./*
	
	../configure \
		--host="${CROSS_COMPILE_TRIPLET}" \
		--target="${triplet}" \
		--prefix="${toolchain_directory}" \
		--with-linker-hash-style='both' \
		--with-gmp="${toolchain_directory}" \
		--with-mpc="${toolchain_directory}" \
		--with-mpfr="${toolchain_directory}" \
		--with-isl="${toolchain_directory}" \
		--with-zstd="${toolchain_directory}" \
		--with-system-zlib \
		--with-sysroot="${toolchain_directory}/${triplet}" \
		--with-gcc-major-version-only \
		--with-native-system-header-dir='/include' \
		--with-default-libstdcxx-abi='new' \
		--enable-__cxa_atexit \
		--enable-cet='auto' \
		--enable-checking='release' \
		--enable-clocale='gnu' \
		--enable-default-pie \
		--enable-default-ssp \
		--enable-libstdcxx-backtrace \
		--enable-libstdcxx-filesystem-ts \
		--enable-libstdcxx-static-eh-pool \
		--with-libstdcxx-zoneinfo='static' \
		--with-libstdcxx-lock-policy='atomic' \
		--enable-libssp \
		--enable-standard-branch-protection \
		--enable-libstdcxx-backtrace \
		--enable-link-serialization='1' \
		--enable-linker-build-id \
		--enable-lto \
		--enable-shared \
		--enable-threads='posix' \
		--enable-libstdcxx-threads \
		--enable-languages='c,c++' \
		--enable-plugin \
		--enable-libstdcxx-time='yes' \
		--enable-host-pie \
		--enable-host-shared \
		--enable-libgomp \
		--enable-tls \
		--with-specs='%{!Qy: -Qn}' \
		--with-pic \
		--with-gnu-as \
		--with-gnu-ld \
		--disable-gnu-unique-object \
		--disable-gnu-indirect-function \
		--disable-libsanitizer \
		--disable-fixincludes \
		--disable-symvers \
		--disable-multilib \
		--disable-bootstrap \
		--disable-libstdcxx-pch \
		--disable-nls \
		--disable-canonical-system-headers \
		--disable-libstdcxx-verbose \
		--without-static-standard-libraries \
		${extra_configure_flags} \
		CFLAGS="${ccflags}" \
		CXXFLAGS="${ccflags}" \
		LDFLAGS="-L${toolchain_directory}/lib ${linkflags}"
	
	declare args=''
	
	if (( is_native )); then
		args+="${environment}"
	fi
	
	env ${args} make \
		CFLAGS_FOR_TARGET="${ccflags} ${linkflags}" \
		CXXFLAGS_FOR_TARGET="${ccflags} ${linkflags}" \
		gcc_cv_objdump="${CROSS_COMPILE_TRIPLET}-objdump" \
		all --jobs="${max_jobs}"
	make install
	
	cat "${workdir}/submodules/obggcc/patches/c++config.h" >> "${toolchain_directory}/${triplet}/include/c++/${gcc_major}/${triplet}/bits/c++config.h"
	
	rm "${toolchain_directory}/bin/${triplet}-${triplet}-"* || true
	
	cd "${toolchain_directory}/${triplet}/lib64" 2>/dev/null || cd "${toolchain_directory}/${triplet}/lib"
	
	if [[ "$(basename "${PWD}")" = 'lib64' ]]; then
		mv './'* '../lib' || true
		rmdir "${PWD}"
		cd '../lib'
	fi
	
	[ -f './libiberty.a' ] && unlink './libiberty.a'
	
	ln \
		--symbolic \
		--relative \
		"${toolchain_directory}/lib/gcc/${triplet}/${gcc_major}/"*'.'{a,o} \
		'./'
	
	declare gcc_include_dir="${toolchain_directory}/lib/gcc/${triplet}/${gcc_major}/include"
	declare clang_include_dir="${gcc_include_dir}/clang"
	
	mkdir "${clang_include_dir}"
	
	ln \
		--symbolic \
		--relative \
		"${gcc_include_dir}/"*'.h' \
		"${clang_include_dir}"
	
	rm \
		--force \
		"${clang_include_dir}/"*'intrin'*'.h' \
		"${clang_include_dir}/arm"*'.h' \
		"${clang_include_dir}/stdatomic.h"
	
	ln \
		--symbolic \
		--relative \
		--force \
		"${toolchain_directory}/libexec/gcc/${triplet}/${gcc_major}/liblto_plugin.so" \
		"${toolchain_directory}/lib/bfd-plugins"
	
	cp "${gcc_wrapper}" "${toolchain_directory}/bin/${triplet}${musl_version}-gcc"
	cp "${gcc_wrapper}" "${toolchain_directory}/bin/${triplet}${musl_version}-g++"
	cp "${gcc_wrapper}" "${toolchain_directory}/bin/${triplet}${musl_version}-c++"
	
	cp "${clang_wrapper}" "${toolchain_directory}/bin/${triplet}${musl_version}-clang"
	cp "${clang_wrapper}" "${toolchain_directory}/bin/${triplet}${musl_version}-clang++"
	
	ln \
		--symbolic \
		--relative \
		--force \
		"${toolchain_directory}/bin/${triplet}${musl_version}-clang" \
		"${toolchain_directory}/bin/${triplet}-clang"
	
	ln \
		--symbolic \
		--relative \
		--force \
		"${toolchain_directory}/bin/${triplet}${musl_version}-clang++" \
		"${toolchain_directory}/bin/${triplet}-clang++"
	
	cp "${workdir}/submodules/obggcc/tools/pkg-config.sh" "${toolchain_directory}/bin/${triplet}-pkg-config"
	sed --in-place 's/OBGGCC/RAIDEN/g' "${toolchain_directory}/bin/${triplet}-pkg-config"
	
	if (( build_nz )); then
		mkdir 'nouzen'
		
		cp --recursive "${nz_prefix}/"* "${PWD}/nouzen"
		
		mkdir --parent "${PWD}/nouzen/lib"
		
		ln \
			--symbolic \
			--relative \
			"${toolchain_directory}/lib/nouzen/lib"* \
			"${PWD}/nouzen/lib"
		
		mkdir --parent './nouzen/etc/nouzen/sources.list'
		
		echo -e "repository = ${repository}\nrelease = ${release}\nresource = ${resource}\narchitecture = ${architecture}\nformat = ${format}" > './nouzen/etc/nouzen/sources.list/raiden.conf'
		
		cd '../bin'
		
		ln --symbolic '../lib/nouzen/bin/'* .
		
		cd "${toolchain_directory}/bin"
		
		ln --symbolic "../${triplet}/bin/nz" "./${triplet}-nz"
		ln --symbolic "../${triplet}/bin/apt" "./${triplet}-apt"
		ln --symbolic "../${triplet}/bin/apt-get" "./${triplet}-apt-get"
	fi
done

# Delete libtool files and other unnecessary files GCC installs
rm \
	--force \
	--recursive \
	"${toolchain_directory}/share" \
	"${toolchain_directory}/lib/lib"*'.a' \
	"${toolchain_directory}/include" \
	"${toolchain_directory}/lib/pkgconfig" \
	"${toolchain_directory}/lib/cmake"

find \
	"${toolchain_directory}" \
	-name '*.la' -delete -o \
	-name '*.py' -delete -o \
	-name '*.json' -delete

declare cc='gcc'
declare readelf='readelf'

if ! (( is_native )); then
	cc="${CC}"
	readelf="${READELF}"
fi

# Bundle both libstdc++ and libgcc within host tools
if ! (( is_native )) && [[ "${CROSS_COMPILE_TRIPLET}" != *'-darwin'* ]]; then
	[ -d "${toolchain_directory}/lib" ] || mkdir "${toolchain_directory}/lib"
	
	# libestdc++
	declare name=$(realpath $("${cc}" --print-file-name="libestdc++${dll}"))
	
	# libstdc++
	if ! [ -f "${name}" ]; then
		declare name=$(realpath $("${cc}" --print-file-name="libstdc++${dll}"))
	fi
	
	declare soname=''
	
	if [[ "${CROSS_COMPILE_TRIPLET}" != *'-mingw32' ]]; then
		soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
	fi
	
	cp "${name}" "${toolchain_directory}/lib/${soname}"
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
		cp "${name}" "${toolchain_directory}/bin/${soname}"
	fi
	
	# libegcc
	declare name=$(realpath $("${cc}" --print-file-name="libegcc${dll}"))
	
	if ! [ -f "${name}" ]; then
		# libgcc_s
		declare name=$(realpath $("${cc}" --print-file-name="libgcc_s${dll}"))
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
		if ! [ -f "${name}" ]; then
			# libgcc_s_seh
			declare name=$(realpath $("${cc}" --print-file-name="libgcc_s_seh${dll}"))
		fi
		
		if ! [ -f "${name}" ]; then
			# libgcc_s_sjlj
			declare name=$(realpath $("${cc}" --print-file-name="libgcc_s_sjlj${dll}"))
		fi
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" != *'-mingw32' ]]; then
		soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
	fi
	
	cp "${name}" "${toolchain_directory}/lib/${soname}"
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
		cp "${name}" "${toolchain_directory}/bin/${soname}"
	fi
	
	# libatomic
	declare name=$(realpath $("${cc}" --print-file-name="libatomic${dll}"))
	
	if [[ "${CROSS_COMPILE_TRIPLET}" != *'-mingw32' ]]; then
		soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
	fi
	
	cp "${name}" "${toolchain_directory}/lib/${soname}"
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
		cp "${name}" "${toolchain_directory}/bin/${soname}"
	fi
	
	# libiconv
	declare name=$(realpath $("${cc}" --print-file-name="libiconv${dll}"))
	
	if [ -f "${name}" ]; then
		if [[ "${CROSS_COMPILE_TRIPLET}" != *'-mingw32' ]]; then
			soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
		fi
		
		cp "${name}" "${toolchain_directory}/lib/${soname}"
		
		if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
			cp "${name}" "${toolchain_directory}/bin/${soname}"
		fi
	fi
	
	# libcharset
	declare name=$(realpath $("${cc}" --print-file-name="libcharset${dll}"))
	
	if [ -f "${name}" ]; then
		if [[ "${CROSS_COMPILE_TRIPLET}" != *'-mingw32' ]]; then
			soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
		fi
		
		cp "${name}" "${toolchain_directory}/lib/${soname}"
		
		if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
			cp "${name}" "${toolchain_directory}/bin/${soname}"
		fi
	fi
	
	if [[ "${CROSS_COMPILE_TRIPLET}" = *'-mingw32' ]]; then
		for target in "${targets[@]}"; do
			for source in "${toolchain_directory}/"{bin,lib}"/lib"*'.dll'; do
				cp "${source}" "${toolchain_directory}/libexec/gcc/${target}/${gcc_major}"
			done
		done
		
		rm "${toolchain_directory}/lib/lib"*'.'{dll,lib}
	fi
fi

mkdir --parent "${share_directory}"

cp --recursive "${workdir}/tools/dev/"* "${share_directory}"

[ -d "${toolchain_directory}/build" ] || mkdir "${toolchain_directory}/build"

ln \
	--symbolic \
	--relative \
	"${share_directory}/"* \
	"${toolchain_directory}/build"
