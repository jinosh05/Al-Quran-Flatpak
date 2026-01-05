#!/usr/bin/env bash
set -e

# --- Configuration ---
APP_ID="com.jino.quran.app"
FLATPAK_FILE="Al-Quran-Multilingual-Pro.flatpak"

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting Flatpak Upload Process...${NC}"

# 1. Check Prerequisites
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Please install it: https://cli.github.com/"
    echo "Then login using: gh auth login"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Error: You are not logged in to GitHub CLI.${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

if [ ! -f "$FLATPAK_FILE" ]; then
    echo -e "${RED}❌ Error: Flatpak file '$FLATPAK_FILE' not found.${NC}"
    echo "Please run ./build_flatpak.sh first."
    exit 1
fi

# 2. Get Release Tag
if [ -z "$1" ]; then
    DATE_TAG="v$(date +'%Y.%m.%d-%H%M')"
    echo -e "${YELLOW}⚠️ No version tag provided. Using generated tag: $DATE_TAG${NC}"
    TAG="$DATE_TAG"
else
    TAG="$1"
fi

# 3. Create Release and Upload
echo -e "${GREEN}📦 Creating release '$TAG' and uploading '$FLATPAK_FILE'...${NC}"

# Check if release exists
if gh release view "$TAG" &> /dev/null; then
    echo -e "${YELLOW}ℹ️ Release '$TAG' already exists. Uploading artifact to existing release...${NC}"
    gh release upload "$TAG" "$FLATPAK_FILE" --clobber
else
    echo -e "${GREEN}✨ Creating new release...${NC}"
    gh release create "$TAG" "$FLATPAK_FILE" \
        --title "Release $TAG" \
        --notes "Flatpak build for version $TAG"
fi

echo -e "${GREEN}🎉 Upload Complete!${NC}"
echo -e "🔗 View release: $(gh release view "$TAG" --json url -q .url)"
