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
   ```bash
   podman build -t hugo-dev:latest -f hugo_dev/Containerfile .
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

## License
MIT License
