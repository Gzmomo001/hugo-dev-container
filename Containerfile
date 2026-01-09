# Registry selection - can be overridden via --build-arg
ARG IMAGE_REGISTRY="docker.io"
ARG USE_LOCAL_HUGO=false

FROM ${IMAGE_REGISTRY}/library/golang:1.23-alpine AS hugo_builder

# Configure Alpine mirror BEFORE any apk operations
# Try to detect location via build arg or environment, otherwise use China-safe default
RUN if [ "${ALPINE_MIRROR:-auto}" != "global" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi && \
    apk update

# Install build dependencies
RUN apk add --no-cache git gcc musl-dev

# Build Hugo Extended v0.152.2 from source
# Strategy: Clone minimal source code, use Go proxy for dependencies, compile locally
# This avoids downloading 19MB pre-built binary and uses fast goproxy.cn for dependencies
ENV HUGO_VERSION=0.152.2
RUN if [ "${ALPINE_MIRROR:-auto}" != "global" ]; then \
        export GOPROXY=https://goproxy.cn,https://goproxy.io,direct; \
        export GOSUMDB=off; \
        export GO111MODULE=on; \
    fi && \
    mkdir -p /src && cd /src && \
    git clone --depth 1 --branch v${HUGO_VERSION} https://github.com/gohugoio/hugo.git && \
    cd hugo && \
    go mod download && \
    go build -tags extended -ldflags "-s -w" -o /usr/local/bin/hugo && \
    hugo version && \
    cd / && rm -rf /src

# Final runtime image
FROM ${IMAGE_REGISTRY}/library/alpine:3.20

# Configure Alpine mirror BEFORE any apk operations
# Try to detect location via build arg or environment, otherwise use China-safe default
RUN if [ "${ALPINE_MIRROR:-auto}" != "global" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi && \
    apk update

# Install git for lastmod feature and rsync for convenience
RUN apk add --no-cache git rsync openssh-client

# Copy Hugo from builder
COPY --from=hugo-builder /go/bin/hugo /usr/local/bin/hugo

# Set up working directory
WORKDIR /src

# Expose Hugo dev server port
EXPOSE 1313

# Default to development server
CMD ["hugo", "server", "-D", "--bind", "0.0.0.0"]
