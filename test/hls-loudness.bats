#!/usr/bin/env bats

setup() {
    WORKSPACE=$(mktemp -d --suffix=-batstest)
}

teardown() {
    if test "${WORKSPACE:+x}" = x
    then
        rm -rf -- "${WORKSPACE}"
    fi
}

assert_all_le() {
    awk "-vARG=$1" '{ if ($1 > ARG) { print($1 " is greater than " ARG " !") } }'
} >&2

assert_average_between() {
    awk "-vLO=$1" "-vHI=$2" '{ sum += $1; n++ } END { if (!(sum / n >= LO && sum / n <= HI)) { print((sum / n) " out of range: [" LO ";" HI "]!"); exit(1); } }'
} >&2

@test "silent file has loudness <= -80 dBFS" {
    "${FFMPEG}" -i files/15-seconds-of-silence.mp3 -f hls -hls_audio_peaks true -hls_playlist_type vod -vn "${WORKSPACE}/silent.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/silent.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/silent.csv"
    assert_all_le -80 < "${WORKSPACE}/silent.csv"
}

@test "sine tone with ~ -3dBFS produces expected loudness levels (~ -3..0 dBFS on average)" {
    "${FFMPEG}" -i files/sine-3dbfs.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -vn "${WORKSPACE}/sine-3dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-3dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-3dbfs.csv"
    assert_average_between -3.5 0 < "${WORKSPACE}/sine-3dbfs.csv"
}

@test "sine tone with ~ -20dBFS produces expected loudness levels (~ -20dBFS on average)" {
    "${FFMPEG}" -i files/sine-20dbfs.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -vn "${WORKSPACE}/sine-20dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-20dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-20dbfs.csv"
    assert_average_between -20.5 -20 < "${WORKSPACE}/sine-20dbfs.csv"
}

@test "sine tone with ~ -20dBFS (44.1kHz) produces expected loudness levels (~ -20dBFS on average)" {
    "${FFMPEG}" -i files/sine-20dbfs-44-1k.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -vn "${WORKSPACE}/sine-20dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-20dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-20dbfs.csv"
    assert_average_between -21.25 -20 < "${WORKSPACE}/sine-20dbfs.csv"
}

@test "tv test tone with ~ -20dBFS (44.1kHz) produces expected loudness levels (~ -20dBFS on average)" {
    "${FFMPEG}" -i files/160589_2340400-lq.mp3 -ss 10 -t 30 -f hls -hls_audio_peaks true -hls_playlist_type vod -vn "${WORKSPACE}/tv.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/tv.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/tv.csv"
    assert_average_between -20.5 -20 < "${WORKSPACE}/tv.csv"
}

@test "EN 50332-1 program simulation noise produces loudness levels around ~ -13dBFS" {
    "${FFMPEG}" -i files/en50332-1.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -vn "${WORKSPACE}/en50332-1.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/en50332-1.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/en50332-1.csv"
    assert_average_between -13.9 -13 < "${WORKSPACE}/en50332-1.csv"
}

@test "silent file has loudness <= -80 dBFS [MP3]" {
    "${FFMPEG}" -i files/15-seconds-of-silence.mp3 -f hls -hls_audio_peaks true -hls_playlist_type vod -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/silent.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/silent.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/silent.csv"
    assert_all_le -80 < "${WORKSPACE}/silent.csv"
}

@test "sine tone with ~ -3dBFS produces expected loudness levels (~ -3..0 dBFS on average) [MP3]" {
    "${FFMPEG}" -i files/sine-3dbfs.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/sine-3dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-3dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-3dbfs.csv"
    assert_average_between -3.5 0 < "${WORKSPACE}/sine-3dbfs.csv"
}

@test "sine tone with ~ -20dBFS produces expected loudness levels (~ -20dBFS on average) [MP3]" {
    "${FFMPEG}" -i files/sine-20dbfs.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/sine-20dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-20dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-20dbfs.csv"
    assert_average_between -20.5 -20 < "${WORKSPACE}/sine-20dbfs.csv"
}

@test "sine tone with ~ -20dBFS (44.1kHz) produces expected loudness levels (~ -20dBFS on average) [MP3]" {
    "${FFMPEG}" -i files/sine-20dbfs-44-1k.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -hls_audio_peaks_window 2000 -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/sine-20dbfs.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/sine-20dbfs.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/sine-20dbfs.csv"
    assert_average_between -21.25 -20 < "${WORKSPACE}/sine-20dbfs.csv"
}

@test "tv test tone with ~ -20dBFS (44.1kHz) produces expected loudness levels (~ -20dBFS on average) [MP3]" {
    "${FFMPEG}" -i files/160589_2340400-lq.mp3 -ss 10 -t 30 -f hls -hls_audio_peaks true -hls_playlist_type vod -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/tv.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/tv.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/tv.csv"
    assert_average_between -20.5 -20 < "${WORKSPACE}/tv.csv"
}

@test "EN 50332-1 program simulation noise produces loudness levels around ~ -13dBFS [MP3]" {
    "${FFMPEG}" -i files/en50332-1.wav -f hls -hls_audio_peaks true -hls_playlist_type vod -acodec libmp3lame -q:a 0 -vn "${WORKSPACE}/en50332-1.m3u8"
    sed -n 's/^#EXT-X-LOUDNESS:.*,PEAKS=\(.*\)$/\1/p' "${WORKSPACE}/en50332-1.m3u8" | paste -sd, | tr ',' '\n' > "${WORKSPACE}/en50332-1.csv"
    assert_average_between -13.9 -13 < "${WORKSPACE}/en50332-1.csv"
}
