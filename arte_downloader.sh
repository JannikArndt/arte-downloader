#!/bin/bash

set -e

BRed="\033[1;31m"         # RED
NC='\033[0m' # No Color

echo -e "${BRed}ARTE.tv downloader${NC}"
URL="$1"
[ -z "$URL" ] && read -p "$(tput setaf 4)Paste the URL here: $(tput sgr0)" URL

# Extract shortcode from URL
SHORTCODE=$(echo "$URL" | sed -E 's/.*arte.tv\/.+\/videos\/([a-zA-Z0-9\-]+)\/.*/\1/')
echo "Shotcode: $SHORTCODE"
echo "Downloading JSON from ARTE API…"

# Download JSON with Video Data
JSON=$(curl -s https://api.arte.tv/api/player/v2/config/fr/$SHORTCODE)


TITLE=$(echo $JSON | jq -r '.data.attributes.metadata.title')
FILES=$(echo $JSON | jq '.data.attributes.streams | map({version: .versions[0].label, quality: .mainQuality.label, url: .url})' )

echo -e "\n${BRed}$TITLE${NC}"

# Extract Qualities and URLS
QUALITIES=$(echo $FILES | jq -r '.[] | ("\(.version) (Quality \(.quality))")' | nl -s ': ' )
NUMBER_OF_QUALITIES=$(echo $FILES | jq length)

echo -e "Available qualities: \n$QUALITIES"
read -p "$(tput setaf 4)Choose quality (1-$NUMBER_OF_QUALITIES) $(tput sgr0)" CHOSEN_QUALITY

SELECTED_FILE=$(echo $FILES | jq '.['$CHOSEN_QUALITY-1']')
SELECTED_URL=$(echo $SELECTED_FILE | jq -r '.url')
SELECTED_VERSION=$(echo $SELECTED_FILE | jq -r '.version')
CLEANED_NAME=$(echo "$TITLE ($SELECTED_VERSION)" | sed -e 's/[<>:"/\|?*]/_/g')

# Download
yt-dlp "$SELECTED_URL" --all-subs -o "$CLEANED_NAME.%(ext)s" 
echo -e "${BRed}File saved in current directory, with available subtitles${NC}"