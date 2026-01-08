# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **development container** for Hugo Extended - not a Hugo site itself. It provides a containerized environment with Hugo Extended v0.152.2, designed to be used as a submodule in Hugo projects.

## Architecture

- **Containerfile**: Multi-stage build using Alpine Linux
  - Stage 1: Builds Hugo Extended from source using Go 1.23
  - Stage 2: Minimal runtime with git, rsync, and openssh-client
- **Scripts/**: Convenience wrappers for common Hugo operations via Podman

### Intended Usage Pattern

This repo is meant to be added as a git submodule to a Hugo site project:

```bash
git submodule add https://github.com/Gzmomo001/hugo-dev-container.git hugo_dev
```

The Hugo project then uses the scripts from `hugo_dev/scripts/` to run Hugo in the container.

## Building the Container Image

From the parent Hugo project directory (after adding as submodule):

```bash
podman build -t hugo-dev:latest -f hugo_dev/Containerfile .
```

## Running Hugo

All scripts mount the current directory (`${PWD}`) as `/src:z` inside the container. Run these from your Hugo site root, not from this repository.

### Development Server (with live reload and draft posts)
```bash
./hugo_dev/scripts/hugo-dev.sh
```
Serves on port 1313. Customize via `HUGO_PORT` and `HUGO_IMAGE` env vars.

### Production Build
```bash
./hugo_dev/scripts/hugo-build.sh
```
Builds the site to `public/` using default Hugo command.

### Clean Build
```bash
./hugo_dev/scripts/hugo-clean.sh
```
Removes `public/` and `resources/` directories, then builds with `--cleanDestinationDir`.

## Manual Container Usage

```bash
# Development
podman run --rm -it -p 1313:1313 -v "${PWD}:/src:z" hugo-dev:latest

# Production (uses default CMD which is `hugo server`)
podman run --rm -it -v "${PWD}:/src:z" hugo-dev:latest hugo
```

## Environment Variables

- `HUGO_IMAGE`: Container image name (default: `hugo-dev:latest`)
- `HUGO_PORT`: Port for dev server (default: `1313`)

## Key Features of the Container

- Hugo Extended v0.152.2 with SCSS and image processing
- Git integration for `.Lastmod` front matter
- Live reload in development mode
- Alpine-based for minimal size
