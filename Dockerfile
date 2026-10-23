# Total.js runtime for AI and voice apps (CPU)
#
# A drop-in replacement for totaljs/run on Debian (glibc) instead of Alpine (musl):
# same working directory, same entrypoint and same start command, so an application
# only has to change the image in its index.yaml.
#
# Native AI libraries (for example onnxruntime-node) are linked against glibc and
# have no musl build, so they cannot run on the Alpine image.
#
# The base image is pinned to a Node.js major version on purpose: a rebuild must
# never move the applications to another major version by surprise.

FROM node:24-slim

# The same tools as totaljs/run, plus the tools used by AI and voice applications:
# ffmpeg and libsndfile (audio), Python (TotalFusion and Python libraries),
# git, curl and certificates (downloading models and dependencies).
RUN apt-get update && apt-get install -y --no-install-recommends \
	bash \
	zip \
	unzip \
	tar \
	graphicsmagick \
	tini \
	ffmpeg \
	libsndfile1 \
	python3 \
	python3-pip \
	python3-venv \
	git \
	curl \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Debian puts tini in /usr/bin, Alpine in /sbin. Both paths work.
RUN ln -sf /usr/bin/tini /sbin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
WORKDIR /www

EXPOSE 8000

CMD [ "/bin/bash", "-c", "mkdir -p logs;npm i;npm start > logs/debug.log 2>&1" ]
