#!/bin/bash

set -eu

declare -r workdir="${PWD}"

declare -r revision="$(git rev-parse --short HEAD)"

declare -r toolchain_directory='/tmp/raiden'
declare -r share_directory="${toolchain_directory}/usr/local/share/raiden"

declare -r environment="LD_LIBRARY_PATH=${toolchain_directory}/lib PATH=${PATH}:${toolchain_directory}/bin"

declare -r gmp_tarball='/tmp/gmp.tar.xz'
declare -r gmp_directory='/tmp/gmp-6.3.0'

declare -r mpfr_tarball='/tmp/mpfr.tar.xz'
declare -r mpfr_directory='/tmp/mpfr-4.2.2'

declare -r mpc_tarball='/tmp/mpc.tar.gz'
declare -r mpc_directory='/tmp/mpc-1.3.1'

declare -r isl_tarball='/tmp/isl.tar.xz'
declare -r isl_directory='/tmp/isl-0.27'

declare -r binutils_tarball='/tmp/binutils.tar.xz'
declare -r binutils_directory='/tmp/binutils-with-gold-2.44'

declare -r gcc_tarball='/tmp/gcc.tar.xz'
declare -r gcc_directory='/tmp/gcc-releases-gcc-15'

declare -r zstd_tarball='/tmp/zstd.tar.gz'
declare -r zstd_directory='/tmp/zstd-dev'

declare -r sysroot_tarball='/tmp/sysroot.tar.xz'

declare -r max_jobs='30'

declare -r pieflags='-fPIE'
declare -r optflags='-w -O2'
declare -r linkflags='-Xlinker -s'

declare -ra targets=(
	'loongarch64-unknown-linux-musl'
	'powerpc64le-unknown-linux-musl'
	's390x-unknown-linux-musl'
	'arm-unknown-linux-musleabihf'
	'armv7l-unknown-linux-musleabihf'
	'mips64-unknown-linux-musl'
	'x86_64-unknown-linux-musl'
	'aarch64-unknown-linux-musl'
	'riscv64-unknown-linux-musl'
	'i386-unknown-linux-musl'
)

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
		--url 'https://mirrors.kernel.org/gnu/gmp/gmp-6.3.0.tar.xz' \
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
		--url 'https://mirrors.kernel.org/gnu/mpfr/mpfr-4.2.2.tar.xz' \
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
		--url 'https://mirrors.kernel.org/gnu/mpc/mpc-1.3.1.tar.gz' \
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
		--url 'https://sourceforge.net/projects/libisl/files/isl-0.27.tar.xz' \
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
		--url 'https://mirrors.kernel.org/gnu/binutils/binutils-with-gold-2.44.tar.xz' \
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
	
	patch --directory="${binutils_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Revert-gold-Use-char16_t-char32_t-instead-of-uint16_.patch"
	patch --directory="${binutils_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Disable-annoying-linker-warnings.patch"
	patch --directory="${binutils_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Add-relative-RPATHs-to-binutils-host-tools.patch"
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
		--url 'https://github.com/gcc-mirror/gcc/archive/refs/heads/releases/gcc-15.tar.gz' \
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
	
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/patches/0001-Fix-libgcc-build-on-musl.patch"
	
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Fix-libgcc-build-on-arm.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Change-the-default-language-version-for-C-compilatio.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Turn-Wimplicit-int-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Turn-Wint-conversion-back-into-an-warning.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Revert-GCC-change-about-turning-Wimplicit-function-d.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Add-relative-RPATHs-to-GCC-host-tools.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Add-ARM-and-ARM64-drivers-to-OpenBSD-host-tools.patch"
	patch --directory="${gcc_directory}" --strip='1' --input="${workdir}/submodules/obggcc/patches/0001-Fix-missing-stdint.h-include-when-compiling-host-tools-on-OpenBSD.patch"
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

# Fix Autotools mistakenly detecting shared libraries as not supported on OpenBSD
while read file; do
	sed \
		--in-place \
		--regexp-extended \
		's|test -f /usr/libexec/ld.so|true|g' \
		"${file}"
done <<< "$(find '/tmp' -type 'f' -name 'configure')"

# Force GCC and binutils to prefix host tools with the target triplet even in native builds
sed \
	--in-place \
	's/test "$host_noncanonical" = "$target_noncanonical"/false/' \
	"${gcc_directory}/configure" \
	"${binutils_directory}/configure"

[ -d "${gmp_directory}/build" ] || mkdir "${gmp_directory}/build"

cd "${gmp_directory}/build"

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
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
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
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
	CFLAGS="${optflags}" \
	CXXFLAGS="${optflags}" \
	LDFLAGS="${linkflags}"

make all --jobs
make install

[ -d "${isl_directory}/build" ] || mkdir "${isl_directory}/build"

cd "${isl_directory}/build"
rm --force --recursive ./*

../configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${toolchain_directory}" \
	--with-gmp-prefix="${toolchain_directory}" \
	--enable-shared \
	--disable-static \
	CFLAGS="${pieflags} ${optflags}" \
	CXXFLAGS="${pieflags} ${optflags}" \
	LDFLAGS="-Xlinker -rpath-link -Xlinker ${toolchain_directory}/lib ${linkflags}"

make all --jobs
make install

[ -d "${zstd_directory}/.build" ] || mkdir "${zstd_directory}/.build"

cd "${zstd_directory}/.build"
rm --force --recursive ./*

cmake \
	-S "${zstd_directory}/build/cmake" \
	-B "${PWD}" \
	-DCMAKE_C_FLAGS="-DZDICT_QSORT=ZDICT_QSORT_MIN ${optflags}" \
	-DCMAKE_INSTALL_PREFIX="${toolchain_directory}" \
	-DBUILD_SHARED_LIBS=ON \
	-DZSTD_BUILD_PROGRAMS=OFF \
	-DZSTD_BUILD_TESTS=OFF \
	-DZSTD_BUILD_STATIC=OFF \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON

cmake --build "${PWD}"
cmake --install "${PWD}" --strip

# We prefer symbolic links over hard links.
cp "${workdir}/submodules/obggcc/tools/ln.sh" '/tmp/ln'

export PATH="/tmp:${PATH}"

# The gold linker build incorrectly detects ffsll() as unsupported.
if [[ "${CROSS_COMPILE_TRIPLET}" == *'-android'* ]]; then
	export ac_cv_func_ffsll=yes
fi

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
		--enable-gold \
		--enable-ld \
		--enable-lto \
		--enable-separate-code \
		--enable-rosegment \
		--enable-relro \
		--enable-compressed-debug-sections='all' \
		--enable-default-compressed-debug-sections-algorithm='zstd' \
		--disable-gprofng \
		--disable-default-execstack \
		--without-static-standard-libraries \
		--with-sysroot="${toolchain_directory}/${triplet}" \
		--with-zstd="${toolchain_directory}" \
		CFLAGS="${optflags}" \
		CXXFLAGS="${optflags}" \
		LDFLAGS="${linkflags}"
	
	make all --jobs
	make install
	
	if ! (( is_native )); then
		extra_configure_flags+=" --with-cross-host=${CROSS_COMPILE_TRIPLET}"
		extra_configure_flags+=" --with-toolexeclibdir=${toolchain_directory}/${triplet}/lib/"
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
		--with-bugurl='https://github.com/AmanoTeam/Raiden/issues' \
		--with-pkgversion="Raiden v1.0-${revision}" \
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
		--enable-gnu-indirect-function \
		--disable-gnu-unique-object \
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
		--enable-cxx-flags="${linkflags}" \
		--enable-host-pie \
		--enable-host-shared \
		--enable-host-bind-now \
		--with-specs='%{!fno-plt:%{!fplt:-fno-plt}}' \
		--disable-libsanitizer \
		--disable-fixincludes \
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
		--without-static-standard-libraries \
		${extra_configure_flags} \
		CFLAGS="${optflags}" \
		CXXFLAGS="${optflags}" \
		LDFLAGS="${linkflags}"
	
	declare args=''
	
	if (( is_native )); then
		args+="${environment}"
	fi
	
	env ${args} make \
		CFLAGS_FOR_TARGET="${optflags} ${linkflags}" \
		CXXFLAGS_FOR_TARGET="${optflags} ${linkflags}" \
		gcc_cv_objdump="${CROSS_COMPILE_TRIPLET}-objdump" \
		all --jobs="${max_jobs}"
	make install
	
	rm "${toolchain_directory}/bin/${triplet}-${triplet}-"* || true
	
	cd "${toolchain_directory}/${triplet}/lib64" 2>/dev/null || cd "${toolchain_directory}/${triplet}/lib"
	
	[ -f './libiberty.a' ] && unlink './libiberty.a'
	
	cd "${toolchain_directory}/lib/bfd-plugins"
	
	if ! [ -f './liblto_plugin.so' ]; then
		ln --symbolic "../../libexec/gcc/${triplet}/"*'/liblto_plugin.so' './'
	fi
	
	if [ "${CROSS_COMPILE_TRIPLET}" = "${triplet}" ]; then
		ln \
			--symbolic \
			--relative \
			"${toolchain_directory}/${triplet}/include/c++" \
			"${toolchain_directory}/include"
	fi
done

# Delete libtool files and other unnecessary files GCC installs
rm --force --recursive "${toolchain_directory}/share"

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
if ! (( is_native )); then
	[ -d "${toolchain_directory}/lib" ] || mkdir "${toolchain_directory}/lib"
	
	# libstdc++
	declare name=$(realpath $("${cc}" --print-file-name='libstdc++.so'))
	
	# libestdc++
	if ! [ -f "${name}" ]; then
		declare name=$(realpath $("${cc}" --print-file-name='libestdc++.so'))
	fi
	
	declare soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
	
	cp "${name}" "${toolchain_directory}/lib/${soname}"
	
	# OpenBSD does not have a libgcc library
	if [[ "${CROSS_COMPILE_TRIPLET}" != *'-openbsd'* ]]; then
		# libgcc_s
		declare name=$(realpath $("${cc}" --print-file-name='libgcc_s.so.1'))
		
		# libegcc
		if ! [ -f "${name}" ]; then
			declare name=$(realpath $("${cc}" --print-file-name='libegcc.so'))
		fi
		
		declare soname=$("${readelf}" -d "${name}" | grep 'SONAME' | sed --regexp-extended 's/.+\[(.+)\]/\1/g')
		
		cp "${name}" "${toolchain_directory}/lib/${soname}"
	fi
fi

mkdir --parent "${share_directory}"

cp --recursive "${workdir}/tools/dev/"* "${share_directory}"
