# -=< Base Image >=-

# Start with a very simple Alpine Linux
FROM alpine


# -=< Install Required Packages >=-

# We can't install packages without running update first
RUN apk update

# Install what we need to prepare and build C/C++ source code
RUN apk add gcc g++ make patch

# Install Pyhon, Python Dependencies (PIP) and dev headers for C bridging
RUN apk add python py-pip python-dev

# Install tools we need to download dependencies
RUN apk add curl git

# Install libraries we need to build dependencies
RUN apk add zlib-dev


# -=< Adding Files >=-

COPY . /build/


# -=< Build It >=-

# We need to patch stdbool.h as C++ doesn't know _Bool data type
# but building ttfautohint requires the _Bool data type.
RUN patch /usr/include/stdbool.h /build/docker/stdbool.h.patch
