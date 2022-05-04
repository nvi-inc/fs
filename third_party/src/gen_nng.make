#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ $# -lt 1 ]; then
	echo -e "Usage: $0 <version>\t\twhere <version> is the NNG version."
	exit 1
fi

export VERSION=$1
shift

tar xzf "nng-${VERSION}.tar.gz"
#
# This embedded patch makes nng-1.3.0 back compatible with CMake >= 3.8 as
# that version will still compile on FSL8 (i.e. Debian 5.0 lenny).
#
( cd "nng-$VERSION"
patch -p0 <<EOF
--- CMakeLists.txt.orig	2020-03-01 05:02:41.000000000 +0000
+++ CMakeLists.txt	2020-12-07 08:05:20.000000000 +0000
@@ -25,7 +25,7 @@
 #   IN THE SOFTWARE.
 #
 
-cmake_minimum_required(VERSION 3.13)
+cmake_minimum_required(VERSION 3.8)
 
 project(nng C)
 include(CheckFunctionExists)
@@ -155,11 +155,11 @@
     set(NNG_SANITIZER_FLAGS "-fsanitize=\${NNG_SANITIZER}")
 endif ()
 
-include(CheckAtomicLib)
-CheckAtomicLib()
-if (NOT HAVE_C_ATOMICS_WITHOUT_LIB AND HAVE_C_ATOMICS_WITH_LIB)
-    list(APPEND NNG_LIBS "atomic")
-endif ()
+#include(CheckAtomicLib)
+#CheckAtomicLib()
+#if (NOT HAVE_C_ATOMICS_WITHOUT_LIB AND HAVE_C_ATOMICS_WITH_LIB)
+#    list(APPEND NNG_LIBS "atomic")
+#endif ()
 
 
 if (NNG_ENABLE_COVERAGE)
EOF
)

mkdir "build"
( cd build; cmake "../nng-${VERSION}" )

SOURCES=$(\
	grep '^libnng\.a.*\.o' "build/src/CMakeFiles/nng.dir/build.make" \
	| sed 's,libnng.a: src/CMakeFiles/nng.dir/,,' \
	| sed 's,\.o$,\\,'\
)

FLAGS="$(\
	grep -v '^#' "build/src/CMakeFiles/nng.dir/flags.make" \
	| sed 's/C_FLAGS\s*=\s*\(.*\)/CFLAGS="\1"/' \
	| sed 's/C_DEFINES\s*=\s*\(.*\)/CPPFLAGS="\1"/' \
	| sed 's/C_INCLUDES\s*=\s*\(.*\)/CPPFLAGS="$CPPFLAGS \1"/'\
)"
eval "$FLAGS"

# Fix up absolute pathnames to match nng.make's relative path convention
CPPFLAGS=$(\
	echo ${CPPFLAGS} \
	| sed ":a; s,${PWD}/nng-${VERSION},\$(NNG_DIR),; ta"\
)

HEADERS="$(find nng-${VERSION}/include -type f -printf '%P ')"

export SOURCES CFLAGS CPPFLAGS HEADERS
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < nng.make.template   > nng.make

rm -r build "nng-${VERSION}"
