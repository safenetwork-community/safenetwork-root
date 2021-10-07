#!/bin/sh

PLATFORM_ARCH=`uname -m`

case "$PLATFORM_ARCH" in
  "armv7l")
  PLATFORM_ARCH="armv7"
  ;;
esac

echo $PLATFORM_ARCH

# Create safe folders
mkdir -p ~/.safe/cli

# Install the safe network command line interface
curl -L $(curl --silent https://api.github.com/repos/maidsafe/sn_cli/releases/latest | \
  jq --arg PLATFORM_ARCH "$PLATFORM_ARCH" \
  -r '.assets[] | select(.name | endswith($PLATFORM_ARCH+"-unknown-linux-musl.tar.gz")).browser_download_url') | \
  tar xz -C ~/.safe/

# Make profile file with exported PATH and refresh the shell (while building)
echo 'export PATH=$PATH:/root/.safe/cli' > ~/.profile && source ~/.profile


