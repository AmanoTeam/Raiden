#/bin/bash

kopt="${-}"

set +u
set -e

if [ -z "${RAIDEN_HOME}" ]; then
	RAIDEN_HOME="$(realpath "$(( [ -n "${BASH_SOURCE}" ] && dirname "$(realpath "${BASH_SOURCE[0]}")" ) || dirname "$(realpath "${0}")")""/../../../../..")"
fi

set -u

CROSS_COMPILE_TRIPLET='armv7l-unknown-linux-musleabihf'
CROSS_COMPILE_SYSTEM='linux'
CROSS_COMPILE_ARCHITECTURE='armv7l'
CROSS_COMPILE_SYSROOT="${RAIDEN_HOME}/${CROSS_COMPILE_TRIPLET}"

CMAKE_TOOLCHAIN_FILE="${RAIDEN_HOME}/build/cmake/${CROSS_COMPILE_TRIPLET}.cmake"

CC="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-gcc"
CXX="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-g++"
AR="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-ar"
AS="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-as"
LD="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-ld"
NM="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-nm"
RANLIB="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-ranlib"
STRIP="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-strip"
OBJCOPY="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-objcopy"
READELF="${RAIDEN_HOME}/bin/${CROSS_COMPILE_TRIPLET}-readelf"

export \
	CROSS_COMPILE_TRIPLET \
	CROSS_COMPILE_SYSTEM \
	CROSS_COMPILE_ARCHITECTURE \
	CROSS_COMPILE_SYSROOT \
	CMAKE_TOOLCHAIN_FILE \
	CC \
	CXX \
	AR \
	AS \
	LD \
	NM \
	RANLIB \
	STRIP \
	OBJCOPY \
	READELF

[[ "${kopt}" = *e*  ]] || set +e
[[ "${kopt}" = *u*  ]] || set +u
