# FFmpeg patch/extension for embedding audio loudness data in an HLS playlist

## Synopsis

This is an experimental patch for ffmpeg/libavformat 4.4 that adds some additional options to allow embedding of loudness data in an HLS playlist with a custom `EXT-X-LOUDNESS` header attached to every segment.

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

- `hls_audio_peaks false|true (defaults to false) => toggles loudness embedding in the HLS playlist`
- `hls_audio_peaks_window <n> (defaults to n=1000) => window size for loudness calculation`
- `hls_audio_peaks_rate <n> (defaults to n=8000) => sample rate for loudness calculation`

## How does it look like?

Like this. Each segment gets an `EXT-X-LOUDNESS` containing a CSV row of data points that may be used for visualisation purposes. The unit of measurement is dBFS.

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:2
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-93.3,-69.2,-69.3,-69.2,-69.4,-69.3,-69.3,-69.4,-69.4,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.4
stream0.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-69.3,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.4,-69.3,-69.4,-69.4,-69.4,-69.3,-69.3,-69.4,-69.7
stream1.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.8,-27.6,-27.5,-27.5,-27.5,-27.5,-27.6,-8.7,-27.9,-27.6,-27.5,-27.5,-27.5,-27.5,-28.2
stream2.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-27.5,-8.6,-27.6,-27.5,-27.6,-27.7,-27.6,-27.6,-27.6,-9.0,-27.7,-27.5,-27.6,-27.6,-27.6,-27.6,-27.4
stream3.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.9,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.6,-8.8,-27.8,-27.6,-2.2,-2.2,-6.6,-12.5,-23.0,-27.7
stream4.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.9,-27.8,-27.5,-27.5,-27.5,-27.5,-27.6,-27.6,-8.6,-27.9,-27.5,-27.6,-27.5,-27.5,-27.6,-28.4
stream5.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-16.6,-9.7,-27.6,-27.5,-27.6,-27.6,-27.6,-27.7,-16.6,-9.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-27.5
stream6.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.5,-8.7,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.7
stream7.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-27.6,-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.6,-27.7,-8.9,-27.8,-27.5,-27.5,-27.6,-27.6,-27.7,-27.9
stream8.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.9,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.7,-8.8,-27.7,-1.5,-25.1,-3.3,-1.6,-4.9,-10.3,-24.6
stream9.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.8,-27.6,-27.6,-27.5,-27.5,-27.5,-27.5,-8.6,-27.9,-27.6,-27.6,-27.5,-27.5,-27.5,-28.1
stream10.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-27.7,-8.9,-27.6,-27.5,-27.6,-27.6,-27.6,-27.8,-27.9,-8.9,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-27.6
stream11.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.7,-27.6,-27.7,-27.7,-27.6,-27.5,-27.6,-9.0,-27.8,-27.6,-27.6,-27.6,-27.6,-27.5,-27.5,-27.4
stream12.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.8,-27.6,-27.5,-27.5,-27.5,-27.5,-27.6,-8.6,-27.9,-27.6,-27.5,-27.5,-27.5,-27.6,-28.5
stream13.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-16.6,-9.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.8,-16.3,-9.6,-14.5,-1.7,-4.5,-10.4,-0.6,-3.8,-6.2
stream14.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-6.7,-23.8,-26.7,-27.6,-27.6,-27.5,-27.5,-27.5,-8.7,-27.9,-27.7,-27.6,-27.6,-27.5,-27.5,-27.7
stream15.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-27.6,-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.7,-27.7,-8.9,-27.8,-27.5,-27.5,-27.5,-27.6,-27.6,-28.2
stream16.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-8.9,-27.7,-27.5,-27.6,-27.6,-27.7,-27.6,-27.6,-27.1
stream17.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.8,-27.6,-27.6,-27.6,-27.5,-27.5,-27.6,-8.9,-27.9,-27.6,-27.6,-27.6,-27.5,-27.6,-28.1
stream18.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-11.5,-12.4,-27.6,-27.5,-27.5,-27.6,-27.6,-27.8,-11.2,-12.4,-0.3,-5.2,-5.8,-1.5,-5.9,-10.4,-20.9
stream19.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.9,-27.7,-27.5,-27.6,-27.6,-27.6,-27.6,-27.5,-8.6,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.5,-27.2
stream20.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.8,-27.6,-27.6,-27.5,-27.5,-27.6,-27.9,-8.9,-27.9,-27.6,-27.6,-27.5,-27.5,-27.6,-28.4
stream21.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.7,-27.5,-27.5,-27.5,-27.6,-27.6,-27.7,-8.8,-27.8,-27.5,-27.5,-27.5,-27.6,-27.6,-27.7,-27.6
stream22.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.6,-8.9,-27.7,-27.6,-27.6,-27.6,-27.6,-27.6,-27.4
stream23.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-9.1,-21.5,-27.6,-27.6,-27.5,-27.5,-27.5,-27.6,-8.9,-21.8,-0.8,-2.6,-10.1,-0.8,-5.5,-9.0,-13.0
stream24.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.9,-25.5,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-8.6,-27.7,-27.5,-27.5,-27.6,-27.6,-27.6,-27.6,-27.2
stream25.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.8,-27.6,-27.7,-27.6,-27.6,-27.6,-27.8,-8.9,-27.8,-27.6,-27.6,-27.6,-27.6,-27.6,-27.8
stream26.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.8,-27.8,-27.6,-27.5,-27.5,-27.5,-27.6,-27.7,-8.9,-27.9,-27.6,-27.5,-27.5,-27.6,-27.5,-27.6,-28.0
stream27.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.6,-27.6,-27.5,-27.5,-27.6,-27.6,-27.6,-27.7,-8.9,-27.7,-27.5,-27.5,-27.6,-27.6,-27.7,-27.9,-4.8
stream28.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-27.7,-27.6,-27.6,-27.7,-27.6,-27.6,-27.6,-8.8,-27.8,-3.7,-7.5,-4.2,-2.3,-4.1,-9.1,-10.5
stream29.ts
#EXTINF:2.048000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-8.5,-24.0,-27.5,-27.5,-27.5,-27.5,-27.6,-27.7,-8.6,-29.4,-68.8,-69.2,-69.4,-69.3,-69.4,-69.4,-69.2
stream30.ts
#EXTINF:1.920000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-32.3,-27.5,-27.5,-27.5,-27.6,-27.6,-27.8,-12.2,-11.6,-27.5,-27.5,-27.5,-27.6,-27.6,-33.2,-69.3
stream31.ts
#EXTINF:1.792000,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-69.3,-69.4,-69.3,-69.3,-69.3,-69.4,-69.3,-69.2,-69.3,-69.4,-69.3,-69.2,-69.3,-69.3,-69.3
stream32.ts
#EXT-X-ENDLIST
```

Live HLS playlists will include only the segments in the HLS window and the associated peak data:

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:4
#EXT-X-MEDIA-SEQUENCE:3
#EXTINF:3.996733,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-14.6,-11.4,-11.0,-10.6,-14.1,-10.4,-10.2,-12.6,-12.4,-11.6,-11.4,-14.5,-11.6,-11.3,-14.4,-11.9,-10.8,-10.7,-12.5,-14.4,-11.1,-10.3,-10.6,-12.9,-10.8,-11.3,-14.2,-11.8,-11.5,-12.2,-14.2,-10.8
stream3.ts
#EXTINF:3.996744,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-13.0,-16.3,-11.9,-10.3,-10.4,-14.1,-13.6,-11.2,-10.1,-11.6,-12.3,-11.0,-11.8,-13.7,-10.9,-11.2,-12.9,-11.5,-10.3,-14.0,-16.2,-11.3,-10.9,-11.6,-16.7,-13.9,-13.4,-18.4,-19.3,-19.2,-18.9,-20.5
stream4.ts
#EXTINF:3.996733,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-21.0,-19.9,-19.6,-19.3,-21.7,-21.4,-20.3,-19.3,-19.8,-21.3,-11.8,-13.4,-14.6,-18.9,-20.2,-19.5,-19.0,-19.1,-20.6,-20.8,-20.2,-20.3,-19.8,-20.7,-20.0,-20.1,-19.4,-20.5,-14.9,-13.1,-12.8,-15.5
stream5.ts
#EXTINF:3.996733,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-20.8,-21.4,-19.8,-19.8,-19.8,-21.6,-20.6,-19.3,-19.3,-20.3,-20.7,-19.3,-18.9,-19.0,-20.4,-14.3,-13.0,-13.9,-16.5,-20.9,-20.2,-19.4,-19.1,-20.3,-20.8,-20.1,-19.7,-19.4,-20.8,-21.4,-19.5,-18.8
stream6.ts
#EXTINF:3.996733,
#EXT-X-LOUDNESS:UNIT=dBFS,SPP=0.1250,PEAKS=-12.3,-14.5,-11.3,-11.9,-11.3,-12.6,-15.3,-19.7,-19.6,-13.5,-14.0,-17.8,-20.2,-20.0,-11.2,-14.9,-18.6,-19.6,-16.0,-13.2,-15.6,-20.1,-20.1,-13.2,-13.9,-16.4,-20.0,-19.4,-11.3,-13.4,-17.9,-19.2
stream7.ts
```

# Plot

For verification/demo purposes, we convert the peak output from the VOD example into a single-column, plottable CSV:

```
sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' /tmp/stream.m3u8 | paste -sd, | tr ',' '\n' >/tmp/test.csv
```

![VOD pxample plot](plot-vod-dBFS.png)

# Tests

A [BATS](https://github.com/bats-core/bats-core) testsuite that checks the output levels against a number of predefined audio waveforms ist available under `test/`. Note that the environment variable `FFMPEG` must be set to the path of an `ffmpeg` binary built with this patch before running the tests.

# Disclaimer

This is experimental code and no guarantee, warranty or support is provided whatsoever.
