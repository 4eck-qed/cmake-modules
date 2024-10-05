#!/bin/bash

if [[ -z "$(nproc)" ]]; then
    THREAD_COUNT=4
else
    THREAD_COUNT=$(nproc)
fi

# Rebuild (clean old stuff)
if [[ $1 == "r" ]]; then
    rm -r -f build/CMakeFiles
    rm -r -f build/build.ninja
    rm -r -f build/CMakeCache.txt
    ./build.sh $2
    exit 0
fi

cmake -DBUILD_SHARED_LIBS=ON -S . -B build
cd build
make -j${THREAD_COUNT}
cd ..
