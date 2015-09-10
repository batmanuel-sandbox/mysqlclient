# EupsPkg config file. Sourced by 'eupspkg'

# Breaks on Darwin w/o this
export LANG=C
export LC_CTYPE=C
export LC_ALL=C

prep()
{
	# Apply standard patches
	default_prep

	# Apply the necessary patche if building with clang
	detect_compiler
	if [[ $COMPILER_TYPE == clang ]]; then
		msg "clang detected: applying clang-preprocessor-output-difference.patch"
		patch -s -p1 < ./patches/clang/clang-preprocessor-output-difference.patch
	fi
}

config()
{
	./configure --prefix="$PREFIX" --without-server --enable-thread-safe-client --enable-local-infile --with-ssl --libdir=$PREFIX/lib

	detect_compiler

	# Hack for clang compatibility on Linux
	if [[ $COMPILER_TYPE == clang && $(uname) == Linux ]]; then
		echo '/* LSST: clang compatibility hack */' >> include/config.h
		echo '#define HAVE_GETHOSTBYNAME_R_GLIBC2_STYLE 1' >> include/config.h
	fi

	# SOCKET_SIZE_TYPE gets misdetected on Darwin
	if [[ $COMPILER_TYPE == clang && $(uname) == Darwin ]]; then
		sed -i \~ 's|^#define SOCKET_SIZE_TYPE .*|#define SOCKET_SIZE_TYPE socklen_t|' include/config.h
	fi
}

install()
{
	default_install

	( cd $PREFIX/lib && ln -s mysql/* . )
}
