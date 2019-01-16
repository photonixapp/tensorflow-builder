ARG PYTHON_VERSION=3.6.8-slim-stretch

FROM python:${PYTHON_VERSION} as tensorflow-builder

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        unzip \
        python3-dev

RUN echo "startup --batch" >>/etc/bazel.bazelrc
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/etc/bazel.bazelrc
ENV BAZEL_VERSION 0.18.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

ENV TENSORFLOW_VERSION 1.12.0
ENV CI_BUILD_PYTHON python3
RUN pip install numpy keras_applications keras_preprocessing

RUN curl -fSsL -O https://github.com/tensorflow/tensorflow/archive/v$TENSORFLOW_VERSION.tar.gz && \
    tar xvf v$TENSORFLOW_VERSION.tar.gz

WORKDIR /tensorflow-$TENSORFLOW_VERSION

RUN mkdir /wheels && \
     tensorflow/tools/ci_build/builds/configured CPU \
     bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
         tensorflow/tools/pip_package:build_pip_package && \
     bazel-bin/tensorflow/tools/pip_package/build_pip_package /wheels
