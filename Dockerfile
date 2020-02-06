FROM alpine:3.11 AS build

ARG ARCH=x86
ENV ARCH=$ARCH

ARG KERNEL_VERSION=4.19.101
ENV KERNEL_VERSION=$KERNEL_VERSION

RUN apk add --no-cache -U build-base autoconf automake coreutils pkgconfig \
                          bc elfutils-dev clang clang-dev llvm rsync bison \
                          flex tar xz bash

RUN mkdir -p /usr/src && \
    cd /usr/src && \
    wget https://cdn.kernel.org/pub/linux/kernel/v$(echo "$KERNEL_VERSION" | cut -f 1 -d '.').x/linux-${KERNEL_VERSION}.tar.xz && \
    tar -xvf linux-${KERNEL_VERSION}.tar.xz && \
    ln -s linux-${KERNEL_VERSION} linux

RUN cd /usr/src/linux && \
    make defconfig && \
    # XXX: wtf?! I don't know why this works or why I can't resolve the error :/
    make prepare || true && \
    make headers_install

WORKDIR /kernel-collector

COPY .dockerfiles/build.sh /build.sh
COPY . .

CMD ["/build.sh"]
