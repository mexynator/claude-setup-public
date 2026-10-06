#!/usr/bin/env bash
# analyze.sh <url|videodatei> [max_frames]
# Lädt ein Video (Instagram, YouTube, TikTok, …) oder nimmt eine lokale Datei,
# transkribiert lokal mit whisper.cpp und zieht Standbilder für eingeblendeten Text.
# Ausgabe: Ordner mit description.txt, transcript.txt, frames/*.jpg
set -euo pipefail

SRC="${1:?Usage: analyze.sh <url|file> [max_frames]}"
MAX_FRAMES="${2:-16}"
MODEL="${WHISPER_MODEL:-$HOME/.local/share/whisper/ggml-large-v3-turbo-q5_0.bin}"
OUT="$(mktemp -d "${TMPDIR:-/tmp}/video-verstehen.XXXXXX")"
mkdir -p "$OUT/frames"

if [[ -f "$SRC" ]]; then
  VIDEO="$SRC"
else
  # --no-playlist: ein Link = ein Video. Beschreibung/Caption landet in info.json.
  yt-dlp -q --no-warnings --no-playlist -f "mp4/best" --write-info-json \
    -o "$OUT/video.%(ext)s" "$SRC"
  VIDEO="$(ls "$OUT"/video.* | grep -v '\.json$' | head -1)"
  python3 - "$OUT" <<'PY'
import json, sys, glob
out = sys.argv[1]
f = glob.glob(out + "/*.info.json")
if f:
    d = json.load(open(f[0]))
    keys = ("title", "uploader", "upload_date", "duration", "description")
    with open(out + "/description.txt", "w") as fh:
        for k in keys:
            fh.write(f"{k}: {d.get(k, '')}\n")
PY
fi

# Audio -> 16 kHz mono (whisper.cpp-Format), dann Transkript mit Spracherkennung.
if ffmpeg -loglevel error -y -i "$VIDEO" -vn -ac 1 -ar 16000 "$OUT/audio.wav" 2>/dev/null; then
  whisper-cli -m "$MODEL" -l auto -nt -otxt -of "$OUT/transcript" "$OUT/audio.wav" >/dev/null 2>&1 || echo "(Transkription fehlgeschlagen)" > "$OUT/transcript.txt"
else
  echo "(kein Audio)" > "$OUT/transcript.txt"
fi

# Gleichmäßig verteilte Standbilder, höchstens MAX_FRAMES.
DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO" | cut -d. -f1)"
DUR="${DUR:-1}"
INTERVAL=$(( DUR / MAX_FRAMES )); (( INTERVAL < 1 )) && INTERVAL=1
ffmpeg -loglevel error -y -i "$VIDEO" -vf "fps=1/${INTERVAL},scale=720:-2" -frames:v "$MAX_FRAMES" "$OUT/frames/%02d.jpg"

echo "OUT=$OUT"
echo "DURATION_S=$DUR FRAMES=$(ls "$OUT/frames" | wc -l | tr -d ' ') INTERVAL_S=$INTERVAL"
