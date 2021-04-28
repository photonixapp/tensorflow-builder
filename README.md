# tensorflow-builder

Docker-based build environment that creates Tensorflow packages that don't use optimised CPU instructions such as AVX, AVX2, SSE4.1, SSE4.2 and FMA. This is the version of Tensorflow that is used in [Photonix](https://github.com/damianmoore/photonix) to maintain compatibility with as many people's machines as possible. Performance testing [detailed here](https://github.com/damianmoore/photonix/issues/48#issuecomment-455368921) showed a 13% longer execution time than the official, optimised builds.


## Building

Running the commands below should build Python Wheel packages for each supported architecture in the `wheels` directory. Beware that building will probably take many hours. We usually create the largest possible VPS on DIgitalOcean with 32 CPU cores and it can build each architecture in about an hour. Check out the [releases page](https://github.com/damianmoore/tensorflow-builder/releases) to make use of our builds.

```
./build.sh amd64
./build.sh arm32v7
./build.sh arm64v8
```

## Todo

- Provide options for passing in custom PyPI server credentials and having wheels automatically uploaded using pypi-uploader
