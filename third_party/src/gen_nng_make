#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


export VERSION=$1
shift

tar xzf "nng-${VERSION}.tar.gz"

mkdir "build"
cmake -S "nng-${VERSION}" -B build 

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

HEADERS="$(find nng-1.3.0/include -type f -printf '%P ')"

export SOURCES CFLAGS CPPFLAGS HEADERS
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < nng.make.template   > nng.make

rm -r build "nng-${VERSION}"
