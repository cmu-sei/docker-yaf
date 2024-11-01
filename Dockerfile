ARG FIXBUF_VERSION=2
FROM cmusei/fixbuf:${FIXBUF_VERSION} AS build
LABEL maintainer="maheckathorn@cert.org"

ARG YAF_VERSION=2.16.1

# Pre-reqs:
# curl for downloading
# build-essentials for build tools
# ca-certs to download https
# 
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        pkg-config \
        ca-certificates \
        libglib2.0-dev \
        libssl-dev \
        libpcap-dev \
        zlib1g-dev \
        libpcre3-dev \
        && apt-get clean && \
        rm -rf /var/lib/apt/lists/*

WORKDIR /netsa

ARG enable_dpi=''

RUN curl https://tools.netsa.cert.org/releases/yaf-$YAF_VERSION.tar.gz | \
        tar -xz && cd yaf-* && \
        ./configure --prefix=/netsa ${enable_dpi} \
        --enable-plugins \
        --enable-applabel \
        --with-libfixbuf=/netsa/lib/pkgconfig && \
        make && \
        make install && \
        cd ../ && rm -rf yaf-$YAF_VERSION

FROM debian:11-slim
LABEL maintainer="maheckathorn@cert.org"

RUN apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
        libglib2.0-0 \
        libpcap0.8 \
        zlib1g \
        libssl1.1 \
        libpcre3 \
        && apt-get clean && \
        rm -rf /var/lib/apt/lists/*

COPY --from=build /netsa/ /netsa/

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /

ENV PATH=$PATH:/netsa/bin

ENTRYPOINT ["docker-entrypoint.sh"]