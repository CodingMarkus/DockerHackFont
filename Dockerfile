# -=< Base Image >=-

# Start with a very simple Alpine Linux
FROM alpine


# -=< Install Required Packages >=-

# We can't install packages without running update first
RUN apk update

# Install tools we need to build dependencies later on
RUN apk add gcc g++ make patch python3 py3-pip python3-dev

# Symlink python3 to python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install tools we need to download dependencies
RUN apk add curl git

# Install libraries dependencies require
RUN apk add zlib-dev libxml2-dev libxslt-dev

# Install tools useful for alt-hack modifications
RUN apk add bash nano


# -=< Adding Files >=-

# Copy the entire repo + sub repo to the folder /build
COPY . /build/


# -=< Prepare the Build >=-

# We need to patch stdbool.h as C++ doesn't know _Bool data type
# but building ttfautohint requires the _Bool data type.
RUN patch /usr/include/stdbool.h /build/docker/stdbool.h.patch

# Install the actual dependencies
WORKDIR /build
RUN ./build-ttf.sh --install-dependencies-only
RUN ./build-woff.sh --install-dependencies-only
RUN ./build-woff2.sh --install-dependencies-only


# -=< Default Command >=-

# Unless otherwise specified, we just do this
WORKDIR /build
CMD make
