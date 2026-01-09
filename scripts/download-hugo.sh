#!/bin/bash
# Manual Hugo binary download for offline builds
# Use this script when GitHub downloads are too slow during container build

set -e

HUGO_VERSION="0.152.2"
BINARY_NAME="hugo_extended_${HUGO_VERSION}_linux-amd64"
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${BINARY_NAME}.tar.gz"

echo "=== Hugo Binary Download Script ==="
echo ""
echo "Hugo Version: ${HUGO_VERSION}"
echo "Target: Linux AMD64 (Extended)"
echo ""

# Check if hugo binary already exists
if [ -f "hugo" ] && [ -x "hugo" ]; then
    echo "✓ Hugo binary already exists"
    echo "  To re-download, remove it first: rm hugo"
    echo ""
    ./hugo version
    exit 0
fi

echo "Step 1: Downloading Hugo from GitHub releases..."
echo "  URL: ${DOWNLOAD_URL}"
echo ""

wget --timeout=60 --tries=5 --show-progress -O "hugo.tar.gz" "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo "✗ Download failed!"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check your internet connection"
    echo "  2. Try using a proxy/VPN"
    echo "  3. Download manually from: ${DOWNLOAD_URL}"
    exit 1
fi

echo ""
echo "Step 2: Extracting Hugo binary..."
tar -xzf "hugo.tar.gz" "${BINARY_NAME}"

if [ $? -ne 0 ]; then
    echo "✗ Extraction failed!"
    echo "  The downloaded file might be corrupted"
    exit 1
fi

echo ""
echo "Step 3: Moving to ./hugo..."
mv "${BINARY_NAME}" hugo

echo ""
echo "Step 4: Cleaning up..."
rm -f "hugo.tar.gz"

echo ""
echo "✓ Download completed successfully!"
echo ""
echo "Binary: ./hugo"
echo ""

./hugo version

echo ""
echo "Next steps:"
echo "  1. Test the binary: ./hugo version"
echo "  2. Build container: podman build -t hugo-dev:latest -f Containerfile ."
echo ""
