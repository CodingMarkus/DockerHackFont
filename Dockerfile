# -=< Create Base Image >=-

# Start with a very simple Alpine Linux
FROM alpine


# -=< Install Required Packages >=-

# We can't install packages without running update first
RUN apk update

# Install tools we need to build dependencies later on
RUN apk add gcc g++ make patch python3 py3-pip python3-dev util-linux-dev

# Install tools we need to download dependencies
RUN apk add curl git

# Install libraries dependencies require
RUN apk add zlib-dev libxml2-dev libxslt-dev


# -=< Add Files >=-

# Copy the build files to the image
COPY Makefile /hack/
COPY build-subsets.sh /hack/
COPY build-ttf.sh /hack/
COPY build-woff.sh /hack/
COPY build-woff2.sh /hack/

# Copy the build folders to the image
COPY config /hack/config/
COPY postbuild_processing /hack/postbuild_processing/
COPY source /hack/source/
COPY tools /hack/tools/


# -=< Patch Alpine Linux >=-

# Copy the patch file to the image
COPY docker-files /hack/docker/

# We need to patch stdbool.h as C++ doesn't actually know _Bool data type
# but building ttfautohint requires the _Bool data type even in C++ files.
RUN patch /usr/include/stdbool.h /hack/docker/stdbool.h.patch


# -=< Install the actual dependencies >=-

WORKDIR /hack
RUN ./build-ttf.sh --install-dependencies-only
RUN ./build-woff.sh --install-dependencies-only
RUN ./build-woff2.sh --install-dependencies-only


# -=< Install Optional Packages >=-

# Install bash as some extra tools need it
RUN apk add bash

# Install tools we need to create archives
RUN apk add zip xz

# Install a simple to use editor as vi just sucks for most people
RUN apk add nano


# -=< Add Optional Files >=-

# Copy the alt modification files to the image
COPY alt-hack /hack/alt-hack/

# Copy alt modificaton script to the image
COPY create-alt-hack.sh /hack/
