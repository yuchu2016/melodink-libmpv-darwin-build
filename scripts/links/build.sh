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
    if [ ! -f ${OUTPUT_DIR}/bin/$BINARY ]; then
        REAL_PATH=$(which $BINARY)
        if [ "$BINARY" = "cmake" ]; then
            # Create cmake wrapper for cmake 4.x compatibility
            cat > ${OUTPUT_DIR}/bin/$BINARY << CMEOF
#!/bin/sh
export CMAKE_POLICY_VERSION_MINIMUM=3.5
exec $REAL_PATH "\\$@"
CMEOF
            chmod +x ${OUTPUT_DIR}/bin/$BINARY
        else
            cp $REAL_PATH ${OUTPUT_DIR}/bin/$BINARY
        fi
    fi
done

# cmake needs its modules directory (CMAKE_ROOT)
if [ -d /opt/homebrew/share/cmake ]; then
    mkdir -p ${OUTPUT_DIR}/share
    ln -sf /opt/homebrew/share/cmake ${OUTPUT_DIR}/share/cmake
fi
