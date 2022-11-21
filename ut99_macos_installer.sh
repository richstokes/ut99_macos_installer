#!/bin/bash
set -e

INTEL_INSTALLER_URL="http://home.macintosh.garden/~vmgl/Files/Intel_OS_X.zip"
OLD_UNREAL_PATCH_URL="https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469c/OldUnreal-UTPatch469c-macOS.dmg"
ASSETS_DIR="$HOME/Library/Application Support/Unreal Tournament"

echo "This script will install Unreal Tournament 99 on your Mac."
echo "Press enter to continue or Ctrl+C to cancel."
read

# Check we're on a mac
if [ "$(uname)" != "Darwin" ]; then
    echo "This script is for Mac OS X only"
    exit 1
fi

# Get file name from OLD_UNREAL_PATCH_URL
OLD_UNREAL_PATCH_FILE=$(basename "$OLD_UNREAL_PATCH_URL")
# echo "Downloading $OLD_UNREAL_PATCH_FILE"

# Make temp dir
TEMP_DIR=$(mktemp -d)
echo "Created temp dir: $TEMP_DIR"

# Download OLD_UNREAL_PATCH_URL
echo "Downloading $OLD_UNREAL_PATCH_FILE..  "
curl -s -L -o "$TEMP_DIR/$OLD_UNREAL_PATCH_FILE" "$OLD_UNREAL_PATCH_URL"

# Mount OLD_UNREAL_PATCH_URL
echo "Mounting $OLD_UNREAL_PATCH_FILE.."
hdiutil attach "$TEMP_DIR/$OLD_UNREAL_PATCH_FILE" -mountpoint "$TEMP_DIR/ut99_patch" -quiet

# Copy UnrealTournament.app to /Applications
echo "Copying UnrealTournament.app to /Applications.."
cp -R "$TEMP_DIR/ut99_patch/UnrealTournament.app" /Applications

# Unmount OLD_UNREAL_PATCH_URL
echo "Unmounting $OLD_UNREAL_PATCH_FILE.."
hdiutil detach "$TEMP_DIR/ut99_patch" -quiet
echo ""

# Check if assets dir exists
if [ ! -d "$ASSETS_DIR" ]; then
    echo "Creating assets dir: $ASSETS_DIR.."
    mkdir -p "$ASSETS_DIR"
else
    echo "Assets dir already exists: $ASSETS_DIR."
    echo "Press enter to continue and overwrite any existing files, or CTRL+C to exit.."
    read
fi

# Download INTEL_INSTALLER_URL
echo "Downloading $INTEL_INSTALLER_URL.."
curl "$INTEL_INSTALLER_URL" \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8' \
  -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Connection: keep-alive' \
  -H 'Sec-GPC: 1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36' \
  --compressed \
  --insecure \
  -s -L -o "$TEMP_DIR/Intel_OS_X.zip"

# Unzip INTEL_INSTALLER_URL
echo "Unzipping $INTEL_INSTALLER_URL.."
mkdir "$TEMP_DIR/assets"
unzip -q "$TEMP_DIR/Intel_OS_X.zip" -d "$TEMP_DIR"
unzip -q "$TEMP_DIR/Intel OS X/UT99_v451wx4_(Intel).zip" -d "$TEMP_DIR/assets"
ASSETS_ROOT="$TEMP_DIR/assets/Unreal Tournament (Intel)/Unreal Tournament.app/drive_c/UnrealTournament"
# ls -altr "$ASSETS_ROOT"
echo ""

# Copy required files from assets dir to $ASSETS_DIR
echo "Copying assets in place.."
cp -R "$ASSETS_ROOT/Maps" "$ASSETS_DIR"
cp -R "$ASSETS_ROOT/Textures" "$ASSETS_DIR"
cp -R "$ASSETS_ROOT/Sounds" "$ASSETS_DIR"
cp -R "$ASSETS_ROOT/Music" "$ASSETS_DIR"

# Delete unneeded textures
rm "$ASSETS_DIR/Textures/LadderFonts.utx"
rm "$ASSETS_DIR/Textures/UWindowFonts.utx"
echo ""

echo "You should now be able to run Unreal Tournament 99 from /Applications/UnrealTournament.app"

# Delete temp dir
# echo "Deleting temp dir: $TEMP_DIR.."
rm -rf "$TEMP_DIR"
