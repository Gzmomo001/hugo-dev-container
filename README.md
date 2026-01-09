# Hugo Dev Container

Containerized Hugo Extended development environment with Podman support.

## Version
- Hugo Extended v0.152.2

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

   **Option A: Standard build (from source)**
   ```bash
   cd hugo_dev
   ./scripts/build-with-mirror.sh
   ```

   **Option B: Local build (fast, recommended for China)**
   ```bash
   cd hugo_dev
   ./scripts/download-hugo.sh  # Download Hugo first
   podman build -f Containerfile.local -t hugo-dev:latest .
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
podman run --rm -it -v "${PWD}:/src:z" hugo-dev:latest
```

## Requirements
- Podman or Docker
- Git (for submodule and lastmod feature)

## Build Optimization

### ⚠️ Important: GitHub Access in China

**Problem:** GitHub access is extremely slow or unstable in China (few KB/s or timeouts).
This affects all build methods that fetch from GitHub.

**Recommended Solution:** Use **Option B (Local build)** above - it's 10-100x faster.

### Automatic Mirror Detection

The container includes automatic mirror detection for faster builds in China:

- **Auto-detection**: Detects your location and automatically uses the fastest mirror
  - China: Uses `docker.1ms.run` for images and Aliyun mirrors for Alpine packages
  - China: Uses `goproxy.cn` for Go module downloads
  - International: Uses official `docker.io` registry and Go proxy

- **Smart build script**:
  ```bash
  ./scripts/build-with-mirror.sh
  ```

### Build Methods Comparison

| Method | Speed | Reliability | Best For |
|--------|-------|-------------|----------|
| **Local build** (Containerfile.local) | ⚡ Fastest (~30s) | ✅ 100% | China users |
| Standard build (Containerfile) | 🐌 Slow (5-10 min) | ⚠️ Unstable | Non-China |

**Why local build is faster:**
- No GitHub access during build
- Uses your host's network (may have proxy/VPN)
- Just copies pre-downloaded binary

**Why standard build is slow:**
- Must clone Hugo source from GitHub (~2MB, slow)
- Or download pre-built binary from GitHub (~19MB, very slow)
- SSL errors and timeouts are common

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

### Offline Build (When GitHub is Slow)

If GitHub downloads are too slow during automated build, you can download Hugo manually:

```bash
# 1. Download Hugo binary manually
./scripts/download-hugo.sh

# 2. Build container (will skip download step)
podman build -t hugo-dev:latest -f Containerfile .
```

**Why use offline build?**
- Bypasses slow GitHub access in container
- Uses your host machine's network (may have proxy/VPN)
- Faster than downloading during container build

### Performance Notes

The mirror optimization speeds up:
1. Base image pulling (golang:1.23-alpine, alpine:3.20)
2. Alpine package installation (apk add)
3. Go module downloads for Hugo build (via goproxy.cn)

**Key improvements:**
- Alpine mirrors are configured **before** any package downloads, eliminating slow CDN access
- Go proxy (goproxy.cn) enables fast Hugo module downloads
- Local build option completely bypasses GitHub access issues

**Build strategy recommendations:**
1. **China users**: Use `Containerfile.local` + `download-hugo.sh` (fastest, ~30s)
2. **International users**: Use `Containerfile` + `build-with-mirror.sh` (standard)
3. **If GitHub is slow**: Always use local build method

**Expected build times:**
- China (local build): ~30 seconds
- China (standard build): 5-10 minutes (may fail due to GitHub)
- International (standard build): 2-5 minutes

## License
MIT License
