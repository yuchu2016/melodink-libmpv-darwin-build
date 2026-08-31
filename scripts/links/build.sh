#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

mkdir -p ${OUTPUT_DIR}/bin

# check BINARY presence in PATH
for BINARY in ${BINARIES}; do
    [ -z $(which $BINARY) ] &&
        echo $BINARY not found in \$PATH &&
        false || true
done

# sym link BINARY
for BINARY in ${BINARIES}; do
    [ ! -h ${OUTPUT_DIR}/bin/$BINARY ] &&
        cp $(which $BINARY) ${OUTPUT_DIR}/bin/$BINARY ||
        true
done

# cmake needs its modules directory (CMAKE_ROOT)
# when binary is copied, it looks relative to the binary location
if [ -d /opt/homebrew/share/cmake ]; then
    mkdir -p ${OUTPUT_DIR}/share
    ln -sf /opt/homebrew/share/cmake ${OUTPUT_DIR}/share/cmake
fi
