#!/usr/bin/env bash
set -euo pipefail

# 1. Fetch the latest version and build ID from the official manifest
echo "Fetching latest version from manifest..."
MANIFEST_JSON=$(curl -fsSL "https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_amd64.json")
URL=$(echo "$MANIFEST_JSON" | jq -r '.url')

# Extract the version string (e.g., "1.0.11-6118976565149696")
FULL_VERSION=$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+-[0-9]+')

VERSION=$(echo "$FULL_VERSION" | cut -d'-' -f1)
BUILD_ID=$(echo "$FULL_VERSION" | cut -d'-' -f2)

echo "Latest found version: $VERSION (Build: $BUILD_ID)"

# Map Nix platforms to Google Storage paths
declare -A PLATFORMS=(
  ["x86_64-linux"]="linux-x64/cli_linux_x64.tar.gz"
  ["aarch64-linux"]="linux-arm/cli_linux_arm64.tar.gz"
  ["aarch64-darwin"]="darwin-arm/cli_mac_arm64.tar.gz"
  ["x86_64-darwin"]="darwin-x64/cli_mac_x64.tar.gz"
)

# 2. Calculate hashes for each platform
HASH_X86_LINUX=""
HASH_ARM_LINUX=""
HASH_ARM_MAC=""
HASH_X86_MAC=""

for sys in "${!PLATFORMS[@]}"; do
  path=${PLATFORMS[$sys]}
  url="https://storage.googleapis.com/antigravity-public/antigravity-cli/${VERSION}-${BUILD_ID}/${path}"
  
  echo "Prefetching hash for $sys..."
  
  # Use nix-prefetch-url with --unpack to handle archives
  # Note: if the archive contains only a single file, nix-prefetch-url returns the file hash,
  # but fetchzip in Nix always creates a directory. We force a directory hash calculation.
  STORE_PATH=$(nix-prefetch-url --unpack --print-path "$url" | tail -n1)
  
  if [ -d "$STORE_PATH" ]; then
    RAW_HASH=$(nix hash path "$STORE_PATH")
  else
    # Wrap single file in a temporary directory to match fetchzip's behavior
    TMP_HASH_DIR=$(mktemp -d)
    cp "$STORE_PATH" "$TMP_HASH_DIR/antigravity"
    RAW_HASH=$(nix hash path "$TMP_HASH_DIR")
    rm -rf "$TMP_HASH_DIR"
  fi

  # Convert to SRI format (sha256-...)
  SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$RAW_HASH")

  case "$sys" in
    "x86_64-linux")   HASH_X86_LINUX="$SRI_HASH" ;;
    "aarch64-linux")  HASH_ARM_LINUX="$SRI_HASH" ;;
    "aarch64-darwin") HASH_ARM_MAC="$SRI_HASH" ;;
    "x86_64-darwin")  HASH_X86_MAC="$SRI_HASH" ;;
  esac
done

# 3. Generate new meta.json
cat <<EOF > meta.json
{
  "version": "$VERSION",
  "build_id": "$BUILD_ID",
  "hashes": {
    "x86_64-linux": "$HASH_X86_LINUX",
    "aarch64-linux": "$HASH_ARM_LINUX",
    "aarch64-darwin": "$HASH_ARM_MAC",
    "x86_64-darwin": "$HASH_X86_MAC"
  }
}
EOF

echo "meta.json successfully updated!"
