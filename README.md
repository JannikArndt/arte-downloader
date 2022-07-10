# Arte Downloader V2

> This is a fork of [this repo](https://github.com/JannikArndt/arte-downloader), which currently uses the v1 api from arte, they recently switched to a new version that uses HLS Streams, which prompted me to make a few changes to the script.


Since movies on Arte.tv are only available online for a _limited_ amount of time, you might want to download something before it's gone. This helps.

# How-To

1. Install [`yt-dlp`](https://github.com/yt-dlp/yt-dlp), an extended `youtube-dl` variant, using your preffered package manager.

2. Run the script from Terminal:

```bash
./arte_downloader.sh
```

Paste the url of the video, select a quality, that's it.

![screenshot](screenshot.png)

# Dependencies

This script uses `curl`, `jq`, `sed` and `yt-dlp`.


# How the V2 Arte API

1. Get video ID from provided URL
2. Get JSON for the video 
3. Parse JSON for metadata, versions and title
4. Use link in the json streams var to get m3u8 data
5. Use the m3u8 data to get streams
   1. The video
   2. The audio
   3. Subs which are linked in the main m3u8 file 
6. Assemble the streams into full video !