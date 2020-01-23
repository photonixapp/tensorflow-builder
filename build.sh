#!/bin/sh
docker build -t tensorflow-builder .
mkdir -p wheels
docker run --rm -it --mount type=bind,source="$(pwd)"/wheels,target=/host_wheels tensorflow-builder bash -c "cp /wheels/* /host_wheels/"
echo "\nHopefully your package is now in the 'wheels' directory."
