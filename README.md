# Hugo Dev Container

Containerized Hugo Extended development environment with Podman support.

## Version
- Hugo Extended (latest from Alpine edge/community repository)

## Features
- SCSS processing support
- Image optimization
- Git integration for last modification dates
- Live reload development server
- Production build support

## Quick Start

### As Submodule in Hugo Project

1. Add as submodule:
   ```bash
   git submodule add https://github.com/Gzmomo001/hugo-dev-container.git hugo_dev
   ```

2. Build container image:
   ```bash
   cd hugo_dev
   ./scripts/build-with-mirror.sh
   ```

3. Use convenience scripts:
   ```bash
   # Development server
   ./hugo_dev/scripts/hugo-dev.sh

   # Production build
   ./hugo_dev/scripts/hugo-build.sh

   # Clean build
   ./hugo_dev/scripts/hugo-clean.sh
   ```

## Manual Usage

### Development Server
```bash
podman run --rm -it -p 1313:1313 -v "${PWD}:/src:z" hugo-dev:latest
```

### Production Build
```bash
podman run --rm -it -v "${PWD}:/src:z" hugo-dev:latest hugo
```

## Requirements
- Podman or Docker
- Git (for submodule and lastmod feature)

## Build Optimization

### Automatic Mirror Detection

The container includes automatic mirror detection for faster builds in China:

- **Auto-detection**: Detects your location and automatically uses the fastest mirror
  - China: Uses `docker.1ms.run` for images and Aliyun mirrors for Alpine packages
  - International: Uses official `docker.io` registry and Alpine CDN

- **Smart build script**:
  ```bash
  ./scripts/build-with-mirror.sh
  ```

### Manual Mirror Selection

You can manually control which mirror to use:

```bash
# Force China mirror (faster in China)
USE_MIRROR=china ./scripts/build-with-mirror.sh

# Force global registry
USE_MIRROR=global ./scripts/build-with-mirror.sh

# Use auto-detection (default)
USE_MIRROR=auto ./scripts/build-with-mirror.sh
```

### Direct Podman Build with Mirrors

For manual builds with specific registry:

```bash
# Using China mirror
podman build --build-arg IMAGE_REGISTRY=docker.1ms.run \
  -t hugo-dev:latest -f Containerfile .

# Using official registry
podman build --build-arg IMAGE_REGISTRY=docker.io \
  -t hugo-dev:latest -f Containerfile .
```

## How It Works

This container uses the official Alpine Linux package for Hugo Extended with intelligent mirror selection:

```dockerfile
# Automatically selects mirror based on ALPINE_MIRROR build arg
if [ "${ALPINE_MIRROR:-auto}" = "global" ]; then
    REPO_URL="https://dl-cdn.alpinelinux.org/alpine/edge/community";
else
    REPO_URL="https://mirrors.aliyun.com/alpine/edge/community";
fi
apk add --no-cache --repository="${REPO_URL}" hugo
```

**Supported Alpine Mirrors (for China):**
- **Aliyun (默认)**: `https://mirrors.aliyun.com/alpine/`
- **Tsinghua**: `https://mirrors.tuna.tsinghua.edu.cn/alpine/`
- **USTC**: `https://mirrors.ustc.edu.cn/alpine/`

**Benefits:**
- Single-stage build (faster, simpler)
- Official Alpine packages (well-maintained)
- Automatic updates via Alpine edge/community repository
- **Smart mirror selection for faster builds in China**
- No GitHub dependencies during build
- No Go compilation required

## Performance Notes

The mirror optimization speeds up:
1. Base image pulling (alpine:3.20)
2. Alpine package installation (apk add)

**Expected build times:**
- China (with mirror): ~1-2 minutes
- International (official): ~1-2 minutes

## License
MIT License
