#!/usr/bin/env bash
# install.sh — spielt dieses Setup nach ~/.claude ein.
#   ./install.sh            alles (Dateien, Tools, Plugins)
#   ./install.sh --files    nur Dateien kopieren
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "==> Backup: $DEST/backups/setup-$STAMP"
mkdir -p "$DEST/backups/setup-$STAMP"
for f in CLAUDE.md settings.json hooks scripts agents commands skills; do
  [[ -e "$DEST/$f" ]] && cp -R "$DEST/$f" "$DEST/backups/setup-$STAMP/"
done

echo "==> Dateien nach $DEST"
# Kein --delete: lokale Extras (z. B. skills/synced) bleiben unangetastet.
rsync -a --exclude '.DS_Store' --exclude '__pycache__' "$HERE/claude/" "$DEST/"
chmod +x "$DEST/skills/video-verstehen/scripts/analyze.sh"

[[ "${1:-}" == "--files" ]] && { echo "Fertig (nur Dateien)."; exit 0; }

echo "==> Tools (Homebrew)"
brew install ffmpeg yt-dlp whisper-cpp typescript-language-server

MODEL="$HOME/.local/share/whisper/ggml-large-v3-turbo-q5_0.bin"
if [[ ! -f "$MODEL" ]]; then
  echo "==> Whisper-Modell (~550 MB)"
  mkdir -p "$(dirname "$MODEL")"
  curl -fSL -o "$MODEL" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin
fi

echo "==> Plugins"
while read -r kind a b; do
  case "$kind" in
    marketplace) claude plugin marketplace add "$b" || true ;;
    plugin)      claude plugin install "$a" --scope user || true ;;
  esac
done < <(grep -v '^\s*#' "$HERE/plugins.txt" | grep -v '^\s*$')

cat <<EOF

Fertig. Noch von Hand:
  - MCP-Server aus mcp.example.json in ~/.claude.json übernehmen und <PLATZHALTER> ersetzen
    (Tokens gehören nie in dieses Repo).
  - Claude Code neu starten.
EOF
