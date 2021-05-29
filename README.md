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

Like this. Each segment gets an `EXT-X-PEAKDATA` containing a CSV row of data points that may be used for visualisation purposes.

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:2
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:2.048000,
#EXT-X-PEAKDATA:0.3,8.0,8.0,8.0,7.9,7.9,7.9,7.8,7.9,7.9,7.9,7.8,7.9,8.0,7.9,7.8,7.8
stream0.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:7.9,7.9,7.9,7.8,7.9,7.9,7.9,7.8,7.9,7.9,7.9,7.8,7.9,8.0,7.9,7.8,7.6
stream1.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8404.0,942.0,966.6,972.3,976.4,975.8,974.9,966.4,8524.4,933.5,964.6,972.5,975.5,979.8,973.5,904.7
stream2.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:972.5,8569.8,961.1,972.4,966.4,960.0,960.7,967.6,963.0,8267.3,955.2,972.8,964.9,961.3,962.3,965.4,987.1
stream3.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8274.4,946.8,962.0,961.1,966.3,973.1,976.9,968.9,8437.2,939.6,962.1,18010.5,18010.4,10884.0,5524.6,1636.1,951.0
stream4.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8310.3,946.9,972.1,977.5,976.4,974.5,966.3,960.9,8563.9,934.6,972.4,966.4,975.5,977.6,966.7,875.9
stream5.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:3436.6,7582.7,961.1,971.6,964.5,961.8,962.0,950.4,3431.5,7586.0,975.6,971.4,962.9,960.0,962.0,964.3,982.2
stream6.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8433.4,943.2,960.6,962.2,967.7,974.8,979.8,975.1,8558.0,939.0,961.8,961.9,967.7,974.6,975.7,957.7
stream7.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:962.9,8570.6,962.2,978.3,977.0,969.5,965.0,960.8,952.8,8272.3,942.4,976.3,975.4,971.0,963.0,959.7,931.4
stream8.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8272.9,957.2,969.5,964.4,961.4,962.8,969.5,957.8,8437.7,958.4,19593.1,1286.6,15814.7,19222.6,13158.9,7118.0,1364.5
stream9.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8439.0,941.4,962.0,966.6,972.2,977.5,977.5,972.5,8568.1,931.1,961.4,966.4,973.2,976.9,978.4,916.3
stream10.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:952.9,8272.7,963.7,977.8,970.0,965.4,962.7,947.3,935.1,8274.2,979.1,975.3,970.4,963.0,961.9,963.4,965.3
stream11.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8435.2,949.6,965.5,959.5,959.7,967.3,972.7,966.7,8264.8,945.0,965.0,961.3,961.2,967.2,973.7,974.5,984.3
stream12.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8568.3,946.8,967.0,973.4,978.1,976.3,971.5,964.2,8567.3,929.4,965.7,973.5,977.5,977.6,967.9,875.4
stream13.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:3436.1,7584.0,961.6,970.3,966.1,961.8,962.3,948.8,3561.1,7709.5,4372.4,19125.9,13811.6,7000.0,21610.4,15011.1,11322.4
stream14.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:10748.9,1501.3,1067.8,962.1,967.7,973.0,978.8,975.0,8557.1,938.4,959.2,961.2,966.5,975.1,977.4,958.1
stream15.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:962.7,8567.7,961.9,978.1,977.9,969.4,963.4,959.9,951.8,8273.4,942.2,978.5,975.0,973.6,968.9,961.3,902.6
stream16.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8433.6,955.3,977.1,970.0,962.9,959.3,963.9,968.2,8314.9,953.3,974.1,970.6,964.3,960.0,963.4,966.7,1024.5
stream17.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8564.9,940.5,960.8,962.2,968.5,973.4,978.9,965.6,8271.6,937.0,961.0,962.9,966.8,975.6,965.4,911.7
stream18.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:6181.4,5573.7,961.0,976.5,974.7,969.3,962.9,948.9,6403.7,5581.2,22381.8,12675.9,11948.0,19579.8,11766.4,6978.4,2094.7
stream19.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8347.9,955.7,971.5,964.6,961.8,962.1,969.3,972.9,8569.9,949.6,969.8,964.4,961.9,964.0,969.8,976.4,1007.8
stream20.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8573.0,941.1,962.4,967.7,973.1,979.5,969.1,937.3,8271.8,929.5,962.1,964.9,974.1,976.4,969.3,879.5
stream21.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8437.7,954.8,977.2,976.2,971.8,967.0,962.2,960.2,8439.2,943.6,976.4,978.5,973.9,970.1,962.6,960.0,969.1
stream22.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8569.5,950.5,969.0,963.1,960.8,963.5,969.9,964.3,8273.1,955.2,970.0,962.4,960.6,963.8,961.5,986.6
stream23.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8094.7,1949.7,965.5,970.8,976.8,977.8,974.6,962.5,8321.3,1876.2,21016.6,17078.0,7220.4,21132.3,12319.6,8219.3,5204.1
stream24.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8315.0,1229.4,978.0,974.6,968.2,963.8,961.3,962.9,8568.6,951.3,978.5,974.6,969.0,963.0,961.7,964.5,1009.7
stream25.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:8570.7,944.0,962.3,958.8,963.7,970.0,965.6,944.7,8273.9,948.3,963.2,960.4,962.6,969.1,964.8,948.2
stream26.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8435.1,945.6,970.5,977.6,976.7,973.4,967.0,954.6,8268.8,935.1,970.5,974.9,979.0,962.8,971.6,964.9,919.2
stream27.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8565.5,961.6,976.1,973.4,967.3,963.3,961.6,953.8,8271.6,953.9,979.4,974.5,969.0,962.1,958.6,931.2,13293.4
stream28.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:954.9,968.5,962.9,960.0,962.5,970.3,968.1,8439.3,944.9,15177.1,9791.9,14298.9,17709.9,14386.0,8126.0,6895.2
stream29.ts
#EXTINF:2.048000,
#EXT-X-PEAKDATA:8687.3,1464.5,972.5,977.8,976.4,972.9,966.1,958.3,8566.2,788.0,8.5,8.0,7.9,7.9,7.8,7.9,8.0
stream30.ts
#EXTINF:1.920000,
#EXT-X-PEAKDATA:560.6,977.7,977.4,974.7,965.6,961.8,942.9,5672.4,6095.7,978.3,977.7,972.5,965.9,961.9,508.3,7.9
stream31.ts
#EXTINF:1.792000,
#EXT-X-PEAKDATA:8.0,7.8,7.9,7.9,7.9,7.9,7.9,8.0,7.9,7.9,7.9,8.0,7.9,7.9,7.9
stream32.ts
#EXT-X-ENDLIST
```

Live HLS playlists will include only the segments in the HLS window and the associated peak data:

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:4
#EXT-X-MEDIA-SEQUENCE:3
#EXTINF:4.017044,
#EXT-X-PEAKDATA:1241.1,739.7,1305.5,1537.5,1343.1,652.4,1076.5,1711.9,1840.2,1233.5,702.3,797.6,1265.7,665.4,974.6,766.8,608.8,616.9,1441.6,1264.3,847.7,1006.6,1537.5,1662.4,804.8,1034.0,1540.8,1671.8,1536.2,745.9,991.3,1154.5,1286.4
stream3.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:805.2,1036.8,981.3,714.2,581.3,1494.3,1279.7,834.9,917.5,1129.0,1347.3,650.7,922.9,1347.5,1652.6,1646.7,628.2,1006.3,1506.9,935.9,1096.3,1073.0,797.5,622.7,1209.5,1240.3,857.2,947.4,2366.0,2382.5,1506.8,2204.9
stream4.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:4342.9,3881.5,4474.8,3494.4,2781.5,2637.7,2266.3,2119.5,2394.2,5040.3,3977.6,2262.5,2166.2,1807.3,915.0,2036.2,2120.2,1766.1,2812.1,5446.8,3512.0,2656.3,1695.5,1256.4,1676.7,1987.7,1215.4,2535.0,4435.8,5056.6,2255.4,1486.6
stream5.ts
#EXTINF:3.993833,
#EXT-X-PEAKDATA:2248.7,980.3,1668.6,2002.1,1373.3,1167.5,5439.1,4361.0,2691.4,2145.5,1335.6,1097.0,2252.8,1647.2,2132.7,3668.4,5340.9,2753.3,1515.4,2135.1,1174.1,1678.2,2328.2,1876.6,1441.9,4960.8,4481.8,2849.8,1898.1,1139.0,883.8,2064.6
stream6.ts
#EXTINF:4.017056,
#EXT-X-PEAKDATA:1576.9,2148.5,2508.5,5612.2,3740.6,1724.3,2041.9,1277.9,1563.9,2687.1,2914.5,1736.0,4236.2,5620.4,4809.0,5701.6,4805.3,2625.1,3428.7,2653.4,2520.2,2354.6,5226.9,4230.1,2006.5,1923.4,1504.5,837.5,2216.6,2283.4,1549.9,3397.0,5884.5
stream7.ts
```

# Plot

For verification/demo purposes, we convert the peak output from the VOD example to single-column a plotable CSV:

```
grep '^#EXT-X-PEAKDATA:' /tmp/stream.m3u8 | cut -d: -f2 | tr -d '\n' | paste -s | tr , '\n' > /tmp/test.csv
```

![VOD pxample plot](plot-vod.png)

# Disclaimer

This is experimental code and no guarantee, warranty or support is provided whatsoever.
