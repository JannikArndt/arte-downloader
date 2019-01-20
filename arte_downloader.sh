#!/bin/bash

set -e

BRed="\033[1;31m"         # RED
NC='\033[0m' # No Color

echo -e "${BRed}ARTE.tv downloader${NC}"
URL="$1"
[ -z "$URL" ] && read -p "$(tput setaf 4)Paste the URL here: $(tput sgr0)" URL

# Extract shortcode from URL
SHORTCODE=$(echo "$URL" | sed --regexp-extended 's/.*arte.tv\/.+\/videos\/([a-zA-Z0-9\-]+)\/.*/\1/')
echo "Shotcode: $SHORTCODE"
echo "Downloading JSON from ARTE API…"

# Download JSON with Video Data
JSON=$(curl -s https://api.arte.tv/api/player/v1/config/de/$SHORTCODE)

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
OUTPUT_FILE="$CLEANED_NAME.$SELECTED_FORMAT"

# Download
echo -e "${BRed}Saving file as $(pwd)/$OUTPUT_FILE...${NC}"
curl -C - -L $SELECTED_URL -o "$OUTPUT_FILE" --progress-bar
