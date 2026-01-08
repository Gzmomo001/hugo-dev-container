FROM docker.io/library/golang:1.23-alpine AS hugo-builder

# Install build dependencies
RUN apk add --no-cache git gcc musl-dev

# Build Hugo Extended v0.152.2
ENV HUGO_VERSION=0.152.2
RUN go install -tags extended github.com/gohugoio/hugo/v0.152.2@latest

# Final runtime image
FROM docker.io/library/alpine:3.20

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
