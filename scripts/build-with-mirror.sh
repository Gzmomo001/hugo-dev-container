#!/bin/bash
# Smart build script with automatic mirror detection

set -e

# Configuration
IMAGE_NAME="${HUGO_IMAGE:-hugo-dev:latest}"
CONTAINERFILE="${CONTAINERFILE:-Containerfile}"
USE_MIRROR="${USE_MIRROR:-auto}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to detect country
detect_country() {
    local country
    country=$(curl -s --connect-timeout 3 ipinfo.io/country 2>/dev/null || echo "Unknown")

    case "$country" in
        CN)
            echo "China"
            ;;
        Unknown)
            echo "Unknown"
            ;;
        *)
            echo "Other"
            ;;
    esac
}

# Main logic
echo -e "${GREEN}=== Hugo Dev Container Build ===${NC}"
echo ""

# Determine which registry to use
if [ "$USE_MIRROR" = "auto" ]; then
    echo -e "${YELLOW}Detecting network location...${NC}"
    country=$(detect_country)

    if [ "$country" = "China" ]; then
        IMAGE_REGISTRY="docker.1ms.run"
        ALPINE_MIRROR="auto"
        echo -e "${GREEN}✓ Detected: China (CN)${NC}"
        echo -e "${GREEN}✓ Using mirror: docker.1ms.run + Aliyun Alpine${NC}"
    elif [ "$country" = "Unknown" ]; then
        IMAGE_REGISTRY="docker.io"
        ALPINE_MIRROR="auto"
        echo -e "${YELLOW}⚠ Could not detect location, using China-safe mirrors${NC}"
        echo -e "${YELLOW}✓ Using registry: docker.io + Aliyun Alpine (fallback)${NC}"
    else
        IMAGE_REGISTRY="docker.io"
        ALPINE_MIRROR="global"
        echo -e "${GREEN}✓ Detected: International network${NC}"
        echo -e "${GREEN}✓ Using registry: docker.io + Official Alpine${NC}"
    fi
elif [ "$USE_MIRROR" = "china" ]; then
    IMAGE_REGISTRY="docker.1ms.run"
    ALPINE_MIRROR="auto"
    echo -e "${GREEN}✓ Forced China mirror mode${NC}"
    echo -e "${GREEN}✓ Using mirror: docker.1ms.run + Aliyun Alpine${NC}"
elif [ "$USE_MIRROR" = "global" ]; then
    IMAGE_REGISTRY="docker.io"
    ALPINE_MIRROR="global"
    echo -e "${GREEN}✓ Forced global registry mode${NC}"
    echo -e "${GREEN}✓ Using registry: docker.io + Official Alpine${NC}"
else
    echo -e "${RED}Error: Invalid USE_MIRROR value: $USE_MIRROR${NC}"
    echo "Valid values: auto, china, global"
    exit 1
fi

echo ""
echo -e "${YELLOW}Building image: ${IMAGE_NAME}${NC}"
echo -e "${YELLOW}Registry: ${IMAGE_REGISTRY}${NC}"
echo -e "${YELLOW}Alpine Mirror: ${ALPINE_MIRROR}${NC}"
echo ""

# Build the image
podman build \
    --build-arg "IMAGE_REGISTRY=${IMAGE_REGISTRY}" \
    --build-arg "ALPINE_MIRROR=${ALPINE_MIRROR}" \
    -t "${IMAGE_NAME}" \
    -f "${CONTAINERFILE}" \
    .

echo ""
echo -e "${GREEN}=== Build completed successfully! ===${NC}"
echo ""
echo "To use the container:"
echo "  ./scripts/hugo-dev.sh          # Development server"
echo "  ./scripts/hugo-build.sh        # Production build"
echo ""
