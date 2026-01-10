# Registry selection - can be overridden via --build-arg
ARG IMAGE_REGISTRY="docker.io"

FROM ${IMAGE_REGISTRY}/library/alpine:3.20

# Configure Alpine mirror BEFORE any apk operations
# Try to detect location via build arg or environment, otherwise use China-safe default
RUN if [ "${ALPINE_MIRROR:-auto}" != "global" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi && \
    apk update

# Install git for lastmod feature, rsync for convenience, and Hugo Extended
# Hugo is installed from Alpine's edge/community repository (official package)
# Repository URL is selected based on ALPINE_MIRROR build arg
RUN if [ "${ALPINE_MIRROR:-auto}" = "global" ]; then \
        REPO_URL="https://dl-cdn.alpinelinux.org/alpine/edge/community"; \
    else \
        REPO_URL="https://mirrors.aliyun.com/alpine/edge/community"; \
    fi && \
    apk add --no-cache \
        git \
        rsync \
        openssh-client \
        --repository="${REPO_URL}" \
        hugo

# Set up working directory
WORKDIR /src

# Expose Hugo dev server port
EXPOSE 1313

# Default to development server
CMD ["hugo", "server", "-D", "--bind", "0.0.0.0"]
