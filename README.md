# run-ai
Total.js runtime for AI and voice apps on Debian (glibc).

A drop-in replacement for [totaljs/run](https://github.com/totaljs/run) based on Debian instead of Alpine. The working directory, the entrypoint and the start command are the same, so an application only has to change the image in its `index.yaml`.

```yaml
services:
  main_app:
    image: ghcr.io/totaljs-es/run-ai:npm
```

## Why Debian (glibc)

Native AI libraries such as `onnxruntime-node` are linked against glibc and have no musl build, so they cannot run on the Alpine image. This image keeps the same tools as `totaljs/run` and adds the tools used by AI and voice applications.

## What it includes

- Node.js 24 (Debian slim, `linux/amd64` and `linux/arm64`)
- `bash`, `zip`, `unzip`, `tar`, `graphicsmagick`, `tini` (same as `totaljs/run`)
- `ffmpeg` and `libsndfile` for audio
- Python 3 with `pip` and `venv`
- `git`, `curl` and CA certificates

## GPU image (NVIDIA)

For applications that use the GPU there is a second image, built from `Dockerfile.gpu` on top of the NVIDIA CUDA runtime with cuDNN (CUDA 12.9 by default, `linux/amd64`). It has the same tools and the same start command.

```yaml
services:
  main_app:
    image: ghcr.io/totaljs-es/run-ai-gpu:npm
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

The server needs an NVIDIA GPU, the NVIDIA driver and the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). To use another CUDA version, build with `--build-arg CUDA_VERSION=13.4.3`.

This image is for NVIDIA GPUs on `x86_64` servers and workstations. It does not target the Jetson boards, which need NVIDIA's own L4T base images.

## Updates

The image is rebuilt on every change of the `Dockerfile` and every Monday, so the security updates of the base image are included. The Node.js major version is pinned in the `Dockerfile`: a rebuild never changes it by surprise.

After a new image is published, pull it on the server and recreate the applications (`docker restart` keeps the old image):

```bash
docker pull ghcr.io/totaljs-es/run-ai:npm
docker pull ghcr.io/totaljs-es/run-ai-gpu:npm
```
