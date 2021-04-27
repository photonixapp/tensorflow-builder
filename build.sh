#!/usr/bin/env bash

TENSORFLOW_VERSION="2.4.1"
BAZEL_VERSION="3.1.0" # Can be found by looking at the .bazelversion file in tensorflow repo at chosen version tag
NUMPY_VERSION="1.19.2"

if [ "$#" -lt 1 ]; then
  >&2 echo "Usage: $(basename $0) ARCH"
  >&2 echo "       ARCH can be one of [ amd64, arm32v7, arm64v8 ]"
  >&2 echo ""
  exit 1
fi

ARCH=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
echo $ARCH

if [[ "${ARCH}" == "amd64" ]]; then
  docker build -t tensorflow-builder -f Dockerfile.amd64 --build-arg TENSORFLOW_VERSION=${TENSORFLOW_VERSION} --build-arg BAZEL_VERSION=${BAZEL_VERSION} --build-arg NUMPY_VERSION=${NUMPY_VERSION} .
  mkdir -p wheels
  docker run --rm -it --mount type=bind,source="$(pwd)"/wheels,target=/host_wheels tensorflow-builder bash -c "cp /wheels/* /host_wheels/"
  echo "\nHopefully your package is now in the 'wheels' directory."

else
  # Clone Tensorflow repo if it doesn't exist already
  if [ ! -d "tensorflow" ]; then
    git clone https://github.com/tensorflow/tensorflow.git
  fi

  # Change into tensorflow directory and checkout tagged version
  cd tensorflow
  git reset --hard
  git checkout "tags/v${TENSORFLOW_VERSION}"

  echo "Add missing package to Tensorflow's Dockerfile"
  echo "RUN apt-get install -y libpython2.7-dev:armhf" >> tensorflow/tools/ci_build/Dockerfile.pi-python38

  echo "Setting Numpy to recommended version rather than whatever the latest is"
  sed -i "s|numpy|numpy==${NUMPY_VERSION}|g" tensorflow/tools/ci_build/install/install_pip_packages_by_version.sh

  if [[ "${ARCH}" == "arm32v7" ]]; then
    tensorflow/tools/ci_build/ci_build.sh PI-PYTHON38 tensorflow/tools/ci_build/pi/build_raspberry_pi.sh
  fi

  if [[ "${ARCH}" == "arm64v8" ]]; then
    tensorflow/tools/ci_build/ci_build.sh PI-PYTHON38 tensorflow/tools/ci_build/pi/build_raspberry_pi.sh AARCH64
  fi
fi
