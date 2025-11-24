#!/bin/bash

# A script to deploy the contents of dist/codexquest to an FTP server.

# Configuration file
CONFIG_FILE=".web"

# --- Pre-flight checks ---

# Check if lftp is installed
if ! command -v lftp &> /dev/null; then
    echo "Error: lftp is not installed."
    echo "Please install lftp to use this script (e.g., 'sudo apt-get install lftp' or 'brew install lftp')."
    exit 1
fi

# Check for configuration file
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    echo "Please create it based on the '.web-template' file and add your server credentials."
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"

# Check that required variables are set
if [ -z "$FTP_HOST" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$REMOTE_DIR" ]; then
    echo "Error: One or more required variables (FTP_HOST, FTP_USER, FTP_PASS, REMOTE_DIR) are not set in '$CONFIG_FILE'."
    exit 1
fi

# --- Deployment ---

LOCAL_DIR="dist/codexquest"

# Check if the local directory exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Error: Local directory '$LOCAL_DIR' not found. Did you build the project?"
    exit 1
fi

echo "Connecting to $FTP_HOST..."
echo "Deploying files from '$LOCAL_DIR' to '$REMOTE_DIR'..."

# Use lftp to mirror the directory.
# -R: Reverse mirror (upload)
# -e: Delete files on the remote that don't exist locally
# -v: Verbose output
# --parallel=10: Use up to 10 parallel connections for speed
lftp -c "set ftp:ssl-allow no; open -u ${FTP_USER},${FTP_PASS} ${FTP_HOST}; mirror -R -e -v --parallel=10 '${LOCAL_DIR}' '${REMOTE_DIR}'"

# --- Verification ---

if [ $? -eq 0 ]; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed. Please check the output above for errors."
    exit 1
fi
