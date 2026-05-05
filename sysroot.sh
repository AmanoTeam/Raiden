cd /tmp

wget https://github.com/AmanoTeam/musl-sysroot/releases/download/musl-sysroot/${CROSS_COMPILE_TRIPLET}.tar.xz
tar xf ${CROSS_COMPILE_TRIPLET}.tar.xz

git clone https://git.musl-libc.org/git/musl --depth 1
cd musl

./configure --host=${CROSS_COMPILE_TRIPLET} --prefix=/tmp/${CROSS_COMPILE_TRIPLET}
make
make install

tar \
	--directory='/tmp' \
	--create \
	--file=- \
	"${CROSS_COMPILE_TRIPLET}" |
		xz \
			--threads='0' \
			--compress \
			-9 > "/tmp/${CROSS_COMPILE_TRIPLET}.tar.xz"
