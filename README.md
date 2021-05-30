# FFmpeg patch/extension for embedding waveform data in an HLS playlist

## Synopsis

This is an experimental patch for ffmpeg/libavformat 4.4 that adds some additional options to allow embedding of waveform visualisation data points in an HLS playlist with a custom `EXT-X-PEAKDATA` header attached to every segment.

## Why?

1) As a learning exercise in order to better understand the ffmpeg stack
2) For testing whether it is feasible to use server-side generated audio visualizations in web applications (possibly in conjuction with [hls.js](https://github.com/video-dev/hls.js/)

## How?

After applying the patch, you can try out something like (for VOD):

```
./ffmpeg -i /tmp/test.flac -f hls -hls_audio_peaks true -hls_playlist_type vod /tmp/stream.m3u8
```

For live HLS, the following may be used instead:

```
./ffmpeg -i "https://stream.nightride.fm/darksynth.m4a" -f hls -hls_audio_peaks true -hls_time 4 -hls_flags delete_segments /tmp/stream.m3u8
```

## What?

The following options are added to the HLS muxer:

- `hls_audio_peaks false|true (defaults to false) => toggles waveform embedding in the HLS playlist`
- `hls_audio_peaks_window <n> (defaults to n=1000) => window size for peak calculation`
- `hls_audio_peaks_rate <n> (defaults to n=8000) => sample rate rate for peak calculation`

## How does it look like?

Like this. Each segment gets an `EXT-X-PEAKDATA` containing a CSV row of data points that may be used for visualisation purposes. The unit of measurement of dBFS.

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:2
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-96.7,-69.2,-69.3,-69.2,-69.4,-69.3,-69.3,-69.4,-69.4,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.4
stream0.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-69.3,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.4,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.7
stream1.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.8,-27.8,-27.6,-27.5,-27.5,-27.5,-27.5,-27.6,-8.7,-27.9,-27.6,-27.5,-27.5,-27.5,-27.5,-28.2
stream2.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-27.5,-8.6,-27.6,-27.5,-27.6,-27.7,-27.6,-27.6,-27.6,-9.0,-27.7,-27.5,-27.6,-27.6,-27.6,-27.6,-27.4
stream3.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.9,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.6,-8.8,-27.8,-27.6,-2.2,-2.2,-6.6,-12.5,-23.0,-27.7
stream4.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.9,-27.8,-27.5,-27.5,-27.5,-27.5,-27.6,-27.6,-8.6,-27.9,-27.5,-27.6,-27.5,-27.5,-27.6,-28.4
stream5.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-16.6,-9.7,-27.6,-27.5,-27.6,-27.6,-27.6,-27.7,-16.6,-9.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-27.5
stream6.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.8,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.5,-8.7,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.7
stream7.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-27.6,-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.6,-27.7,-8.9,-27.8,-27.5,-27.5,-27.6,-27.6,-27.7,-27.9
stream8.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.9,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.7,-8.8,-27.7,-1.5,-25.1,-3.3,-1.6,-4.9,-10.3,-24.6
stream9.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.8,-27.8,-27.6,-27.6,-27.5,-27.5,-27.5,-27.5,-8.6,-27.9,-27.6,-27.6,-27.5,-27.5,-27.5,-28.1
stream10.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-27.7,-8.9,-27.6,-27.5,-27.6,-27.6,-27.6,-27.8,-27.9,-8.9,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-27.6
stream11.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.8,-27.7,-27.6,-27.7,-27.7,-27.6,-27.5,-27.6,-9.0,-27.8,-27.6,-27.6,-27.6,-27.6,-27.5,-27.5,-27.4
stream12.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.6,-27.8,-27.6,-27.5,-27.5,-27.5,-27.5,-27.6,-8.6,-27.9,-27.6,-27.5,-27.5,-27.5,-27.6,-28.5
stream13.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-16.6,-9.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.8,-16.3,-9.6,-14.5,-1.7,-4.5,-10.4,-0.6,-3.8,-6.2
stream14.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-6.7,-23.8,-26.7,-27.6,-27.6,-27.5,-27.5,-27.5,-8.7,-27.9,-27.7,-27.6,-27.6,-27.5,-27.5,-27.7
stream15.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-27.6,-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.7,-27.7,-8.9,-27.8,-27.5,-27.5,-27.5,-27.6,-27.6,-28.2
stream16.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.8,-27.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-8.9,-27.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-27.1
stream17.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.6,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.6,-8.9,-27.9,-27.6,-27.6,-27.6,-27.5,-27.6,-28.1
stream18.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-11.5,-12.4,-27.6,-27.5,-27.5,-27.6,-27.6,-27.8,-11.2,-12.4,-0.3,-5.2,-5.8,-1.5,-5.9,-10.4,-20.9
stream19.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.9,-27.7,-27.5,-27.6,-27.6,-27.6,-27.6,-27.5,-8.6,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.5,-27.2
stream20.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.6,-27.8,-27.6,-27.6,-27.5,-27.5,-27.6,-27.9,-8.9,-27.9,-27.6,-27.6,-27.5,-27.5,-27.6,-28.4
stream21.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.8,-27.7,-27.5,-27.5,-27.5,-27.6,-27.6,-27.7,-8.8,-27.8,-27.5,-27.5,-27.5,-27.6,-27.6,-27.7,-27.6
stream22.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.6,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.6,-8.9,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.4
stream23.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-9.1,-21.5,-27.6,-27.6,-27.5,-27.5,-27.5,-27.6,-8.9,-21.8,-0.8,-2.6,-10.1,-0.8,-5.5,-9.0,-13.0
stream24.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.9,-25.5,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-8.6,-27.7,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-27.2
stream25.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-8.6,-27.8,-27.6,-27.7,-27.6,-27.6,-27.6,-27.8,-8.9,-27.8,-27.6,-27.6,-27.6,-27.6,-27.6,-27.8
stream26.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.8,-27.8,-27.6,-27.5,-27.5,-27.5,-27.6,-27.7,-8.9,-27.9,-27.6,-27.5,-27.5,-27.6,-27.5,-27.6,-28.0
stream27.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.6,-27.7,-8.9,-27.7,-27.5,-27.5,-27.6,-27.6,-27.7,-27.9,-4.8
stream28.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-27.7,-27.6,-27.6,-27.7,-27.6,-27.6,-27.6,-8.8,-27.8,-3.7,-7.5,-4.2,-2.3,-4.1,-9.1,-10.5
stream29.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:-8.5,-24.0,-27.5,-27.5,-27.5,-27.5,-27.6,-27.7,-8.6,-29.4,-68.8,-69.2,-69.4,-69.3,-69.4,-69.4,-69.2
stream30.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:-32.3,-27.5,-27.5,-27.5,-27.6,-27.6,-27.8,-12.2,-11.6,-27.5,-27.5,-27.5,-27.6,-27.6,-33.2,-69.3
stream31.ts
#EXTINF:1.792000,
#EXT-X-PEAKDATA:-69.3,-69.4,-69.3,-69.3,-69.3,-69.4,-69.3,-69.2,-69.3,-69.4,-69.3,-69.2,-69.3,-69.3,-69.3
stream32.ts
#EXT-X-ENDLIST
```

Live HLS playlists will include only the segments in the HLS window and the associated peak data:

```
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:4
#EXT-X-MEDIA-SEQUENCE:3
#EXTINF:4.017044,
#EXT-X-PEAKDATA:-16.4,-15.3,-14.5,-14.7,-14.8,-14.6,-15.5,-15.0,-14.5,-14.5,-14.7,-14.9,-13.4,-13.1,-13.7,-13.5,-13.8,-13.7,-13.6,-14.0,-14.4,-14.2,-14.0,-14.5,-14.4,-15.0,-14.9,-15.6,-15.0,-15.0,-15.4,-15.1,-15.5
stream3.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:-14.5,-14.8,-15.5,-15.9,-14.9,-14.6,-15.1,-16.3,-15.5,-15.3,-14.8,-14.8,-14.4,-14.3,-14.2,-14.2,-13.8,-14.0,-14.2,-14.2,-14.5,-14.8,-13.9,-13.3,-13.0,-13.6,-13.4,-13.6,-14.1,-13.8,-13.8,-13.2
stream4.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:-13.3,-13.8,-13.2,-13.7,-13.8,-13.4,-13.0,-13.4,-13.3,-13.8,-13.3,-13.6,-15.5,-14.7,-15.0,-14.4,-14.2,-14.3,-13.2,-13.7,-14.4,-13.8,-13.7,-13.4,-20.9,-16.0,-16.3,-23.6,-15.7,-15.0,-15.2,-15.4
stream5.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:-14.9,-18.5,-14.0,-13.0,-11.2,-11.5,-10.6,-8.5,-16.1,-11.7,-15.1,-17.4,-7.0,-14.8,-12.6,-13.1,-13.9,-8.3,-10.6,-13.6,-11.1,-13.8,-10.9,-8.3,-14.1,-11.0,-14.5,-16.9,-7.2,-13.7,-12.4,-13.2
stream6.ts
#EXTINF:4.017056,
#EXT-X-PEAKDATA:-15.7,-9.1,-10.2,-15.6,-11.4,-14.6,-11.1,-8.2,-15.6,-11.8,-14.7,-13.9,-7.3,-13.8,-13.2,-12.5,-14.7,-8.7,-10.3,-15.0,-11.4,-15.1,-10.8,-7.9,-11.4,-14.7,-15.3,-17.5,-7.2,-14.0,-13.0,-11.8,-17.2
stream7.ts
```

# Plot

For verification/demo purposes, we convert the peak output from the VOD example into a single-column, plottable CSV:

```
grep '^#EXT-X-PEAKDATA:' /tmp/stream.m3u8 | cut -d: -f2 | tr -d '\n' | paste -s | tr , '\n' > /tmp/test.csv
```

![VOD pxample plot](plot-vod.png)

# Disclaimer

This is experimental code and no guarantee, warranty or support is provided whatsoever.
