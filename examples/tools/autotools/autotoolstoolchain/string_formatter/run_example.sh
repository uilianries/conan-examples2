#!/bin/bash

echo "- AutotoolsToolchain: The toolchain generator for Autotools -"

set -ex

# Remove cache
rm -rf conanbuild* conanrun* conanauto* deactivate* *.pc aclocal* auto* config.* Makefile.in depcomp install-sh missing Makefile configure string_formatter

# Try to build libfmt first if needed. The fmt project fails to build with bash activated on Windows
conan install -r conancenter . --build=missing ${PROFILE_ARGS} -c tools.microsoft.bash:active=False
# Then generate conanbuild.sh
conan install -r conancenter . --build=missing ${PROFILE_ARGS} -v trace
source conanbuild.sh

# Remove : from the path when building on Windows
PKG_CONFIG_PATH="${PKG_CONFIG_PATH//:}"

# Build the example
aclocal
automake --add-missing
autoconf
./configure
make

source deactivate_conanbuild.sh

# Make dynamic library available on PATH
source conanrun.sh

output=$(./string_formatter)

if [[ "$output" != 'Conan - The C++ Package Manager!' ]]; then
    echo "ERROR: The String Formatter output does not match with the expected value: 'Conan - The C++ Package Manager!'"
    exit 1
fi

echo 'AutotoolsToolchain example has been executed with SUCCESS!'
exit 0
