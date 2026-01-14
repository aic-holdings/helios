#!/bin/bash
# Install Helios Native Messaging Host

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_NAME="com.helios.native"
HOST_PATH="$SCRIPT_DIR/dist/index.js"

# Detect OS and set manifest directory
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    MANIFEST_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
    # Also try chromium
    if [[ ! -d "$HOME/.config/google-chrome" ]]; then
        MANIFEST_DIR="$HOME/.config/chromium/NativeMessagingHosts"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    MANIFEST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
else
    echo "Unsupported OS: $OSTYPE"
    echo "For Windows, run install.ps1 instead"
    exit 1
fi

# Create manifest directory if it doesn't exist
mkdir -p "$MANIFEST_DIR"

# Get extension ID (user needs to provide this or we use wildcard for dev)
EXTENSION_ID="${1:-}"
if [[ -z "$EXTENSION_ID" ]]; then
    echo "Usage: ./install.sh <extension-id>"
    echo ""
    echo "To find your extension ID:"
    echo "1. Go to chrome://extensions"
    echo "2. Enable 'Developer mode'"
    echo "3. Find Helios and copy the ID"
    echo ""
    echo "Installing with wildcard for development..."
    ALLOWED_ORIGINS='"chrome-extension://*/*"'
else
    ALLOWED_ORIGINS="\"chrome-extension://$EXTENSION_ID/\""
fi

# Create the manifest
MANIFEST_FILE="$MANIFEST_DIR/$HOST_NAME.json"

cat > "$MANIFEST_FILE" << EOF
{
  "name": "$HOST_NAME",
  "description": "Helios browser automation native messaging host",
  "path": "$HOST_PATH",
  "type": "stdio",
  "allowed_origins": [
    $ALLOWED_ORIGINS
  ]
}
EOF

# Make the host executable
chmod +x "$HOST_PATH"

# Create a wrapper script that runs with node
WRAPPER_PATH="$SCRIPT_DIR/helios-native-host"
cat > "$WRAPPER_PATH" << EOF
#!/bin/bash
exec node "$HOST_PATH" "\$@"
EOF
chmod +x "$WRAPPER_PATH"

# Update manifest to use wrapper
sed -i "s|$HOST_PATH|$WRAPPER_PATH|g" "$MANIFEST_FILE"

echo "Native messaging host installed successfully!"
echo ""
echo "Manifest: $MANIFEST_FILE"
echo "Host: $WRAPPER_PATH"
echo ""
echo "Now update your extension to use native messaging:"
echo "  chrome.runtime.connectNative('$HOST_NAME')"
