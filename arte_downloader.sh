#!/bin/bash

# curl jq sed requested !

set -e

# STORE=$(pwd)

STORE="$HOME/Videos/Arte"
mkdir -p $STORE

BRed="\033[1;31m" # RED
NC='\033[0m'      # No Color

echo -e "${BRed}ARTE.tv downloader${NC}"
URL="$1"
[ -z "$URL" ] && read -p "$(tput setaf 4)Paste the URL here: $(tput sgr0)" URL

# Extract shortcode from URL
LANG_SHORTCODE=$(echo "$URL" | sed -E 's/^https?:\/\/www\.arte.tv\/(\w\w)\/videos\/([^/]*)\/.*$/\1\/\2/')
JSON_URL="https://api.arte.tv/api/player/v1/config/$LANG_SHORTCODE"
cat << EOT

Shortcode: $LANG_SHORTCODE
Downloading JSON from :
$JSON_URL

EOT

# Download JSON with Video Data
JSON=$(curl -s $JSON_URL)

TITLE=$(echo $JSON | jq -r '.videoJsonPlayer.VTI')
FILES=$(echo $JSON | jq '.videoJsonPlayer.VSR | map({version: .versionLibelle, quality: .quality, width: .width, height: .height, mediaType: .mediaType, bitrate: .bitrate, url: .url})' )

echo -e "\n${BRed}$TITLE${NC}"

# Extract Qualities and URLS
QUALITIES=$(echo $FILES | jq -r '.[] | ("\(.version) (Quality \(.quality) \(.mediaType) \(.width) x \(.height) @ \(.bitrate)fps)")' | nl -s ': ' )
NUMBER_OF_QUALITIES=$(echo $FILES | jq length)
echo -e "Available qualities: \n$QUALITIES"
read -p "$(tput setaf 4)Choose quality (1-$NUMBER_OF_QUALITIES) $(tput sgr0)" CHOSEN_QUALITY

SELECTED_FILE=$(echo $FILES | jq '.['$CHOSEN_QUALITY-1']')
SELECTED_URL=$(echo $SELECTED_FILE | jq -r '.url')
SELECTED_FORMAT=$(echo $SELECTED_FILE | jq -r '.mediaType')
SELECTED_VERSION=$(echo $SELECTED_FILE | jq -r '.version')
CLEANED_NAME=$(echo "$TITLE ($SELECTED_VERSION)" | sed -e 's/[<>:"/\|?*]/_/g')
OUTPUT_FILE="$STORE/$CLEANED_NAME.$SELECTED_FORMAT"

# Download
echo -e "${BRed}Saving file as $OUTPUT_FILE...${NC}"
curl -C - -L $SELECTED_URL -o "$OUTPUT_FILE" --progress-bar
