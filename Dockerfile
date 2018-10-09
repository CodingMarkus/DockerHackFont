# -=< Base Image >=-

# Start with a very simple Alpine Linux
FROM alpine

# -=< Install Required Packages >=-

# We can't install packages without running update first
RUN apk update

# Install what we need to build
RUN apk add gcc g++ make patch python py-pip python-dev

# Install tools we need to download dependencies
RUN apk add curl git

# Install libraries we need to build dependencies
RUN apk add zlib-dev libxml2-dev libxslt-dev

# -=< Adding Files >=-

# Copy the entire repo + sub repo to the folder /build
COPY . /build/

# -=< Prepare the Build >=-

# We need to patch stdbool.h as C++ doesn't know _Bool data type
# but building ttfautohint requires the _Bool data type.
RUN patch /usr/include/stdbool.h /build/docker/stdbool.h.patch

# Install further dependencies
WORKDIR /build
RUN ./build-ttf.sh --install-dependencies-only
RUN ./build-woff.sh --install-dependencies-only
RUN ./build-woff2.sh --install-dependencies-only
