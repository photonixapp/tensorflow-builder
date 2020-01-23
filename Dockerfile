ARG PYTHON_VERSION=3.8.1-slim-buster

FROM python:${PYTHON_VERSION} as tensorflow-builder

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        git \
        python-dev \
        unzip

ENV BAZEL_VERSION 0.29.1
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

RUN pip install -U pip six numpy wheel setuptools mock 'future>=0.17.1' && \
    pip install -U keras_applications keras_preprocessing --no-deps

ENV TENSORFLOW_VERSION 2.1.0

RUN curl -fSsL -O https://github.com/tensorflow/tensorflow/archive/v$TENSORFLOW_VERSION.tar.gz && \
    tar xvf v$TENSORFLOW_VERSION.tar.gz

WORKDIR /tensorflow-$TENSORFLOW_VERSION

RUN mkdir /wheels && \
     tensorflow/tools/ci_build/builds/configured CPU \
     bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
         tensorflow/tools/pip_package:build_pip_package && \
     bazel-bin/tensorflow/tools/pip_package/build_pip_package /wheels
