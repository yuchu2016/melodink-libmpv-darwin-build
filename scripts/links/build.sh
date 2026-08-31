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
REAL_PATH_CMAKE=/usr/local/bin/cmake
[ -x "$REAL_PATH_CMAKE" ] || REAL_PATH_CMAKE=$(which cmake 2>/dev/null || echo cmake)
for BINARY in ${BINARIES}; do
    if [ ! -f ${OUTPUT_DIR}/bin/$BINARY ]; then
        REAL_PATH=$(which $BINARY)
        if [ "$BINARY" = "cmake" ]; then
            printf '#!/bin/sh\nexport CMAKE_POLICY_VERSION_MINIMUM=3.5\nexec %s "$@"\n' "$REAL_PATH_CMAKE" > ${OUTPUT_DIR}/bin/$BINARY
            chmod +x ${OUTPUT_DIR}/bin/$BINARY
        else
            cp $REAL_PATH ${OUTPUT_DIR}/bin/$BINARY
        fi
    fi
done

# cmake needs its modules directory (CMAKE_ROOT)
if [ -d /usr/local/share/cmake-3.31 ]; then
    mkdir -p ${OUTPUT_DIR}/share
    ln -sf /usr/local/share/cmake-3.31 ${OUTPUT_DIR}/share/cmake
elif [ -d /opt/homebrew/share/cmake ]; then
    mkdir -p ${OUTPUT_DIR}/share
    ln -sf /opt/homebrew/share/cmake ${OUTPUT_DIR}/share/cmake
fi
