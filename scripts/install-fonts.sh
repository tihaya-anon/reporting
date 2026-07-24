#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_FONT_DIR="$REPO_ROOT/assets/fonts"
FONT_DIR="${FONT_DIR:-$DEFAULT_FONT_DIR}"
MODE="assets"
TMP_DIR=""

cleanup() {
  if [[ -n "${TMP_DIR:-}" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

usage() {
  cat <<'USAGE'
Usage: scripts/install-fonts.sh [--dir PATH] [--system] [--force]

Installs these fonts by default into assets/fonts:
  - Noto Sans CJK SC
  - Noto Sans
  - Noto Sans Math
  - Maple Mono NF

Options:
  --dir PATH    Install font files into PATH instead of assets/fonts.
  --system      Also install Debian/Ubuntu Noto packages with apt.
  --force       Re-download files even if they already exist.
  -h, --help    Show this help.

Environment:
  FONT_DIR=PATH  Same as --dir PATH.
  FORCE=1        Same as --force.
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dir | --font-dir)
        if [[ $# -lt 2 ]]; then
          echo "$1 requires a path." >&2
          exit 2
        fi
        FONT_DIR="$2"
        shift 2
        ;;
      --system | system)
        MODE="system"
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      user | assets)
        MODE="assets"
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done
}

download() {
  local url="$1"
  local out="$2"

  if [[ "${FORCE:-0}" != "1" && -s "$out" ]]; then
    echo "Already installed: $out"
    return
  fi

  curl -fL --retry 3 --connect-timeout 20 "$url" -o "$out.part"
  mv "$out.part" "$out"
}

install_noto_with_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found; use the default user install mode instead." >&2
    exit 1
  fi

  sudo apt-get update
  sudo apt-get install -y fonts-noto fonts-noto-cjk
}

install_font_assets() {
  need_cmd curl
  need_cmd unzip
  need_cmd fc-cache

  TMP_DIR="$(mktemp -d)"
  trap cleanup EXIT

  mkdir -p \
    "$FONT_DIR/noto-sans" \
    "$FONT_DIR/noto-sans-cjk-sc" \
    "$FONT_DIR/noto-sans-math" \
    "$FONT_DIR/maple-mono-nf"

  echo "Installing Noto Sans to $FONT_DIR/noto-sans"
  download \
    "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf" \
    "$FONT_DIR/noto-sans/NotoSans-Regular.ttf"
  download \
    "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Bold.ttf" \
    "$FONT_DIR/noto-sans/NotoSans-Bold.ttf"
  download \
    "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Italic.ttf" \
    "$FONT_DIR/noto-sans/NotoSans-Italic.ttf"
  download \
    "https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-BoldItalic.ttf" \
    "$FONT_DIR/noto-sans/NotoSans-BoldItalic.ttf"

  echo "Installing Noto Sans CJK SC to $FONT_DIR/noto-sans-cjk-sc"
  for weight in Black Bold DemiLight Light Medium Regular Thin; do
    download \
      "https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-${weight}.otf" \
      "$FONT_DIR/noto-sans-cjk-sc/NotoSansCJKsc-${weight}.otf"
  done

  echo "Installing Noto Sans Math to $FONT_DIR/noto-sans-math"
  download \
    "https://notofonts.github.io/math/fonts/NotoSansMath/full/otf/NotoSansMath-Regular.otf" \
    "$FONT_DIR/noto-sans-math/NotoSansMath-Regular.otf"

  echo "Installing Maple Mono NF to $FONT_DIR/maple-mono-nf"
  if [[ "${FORCE:-0}" == "1" ]] || ! find "$FONT_DIR/maple-mono-nf" -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.ttc" \) -print -quit | grep -q .; then
    download \
      "https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF.zip" \
      "$TMP_DIR/MapleMono-NF.zip"
    unzip -oq "$TMP_DIR/MapleMono-NF.zip" -d "$TMP_DIR/maple"
    find "$TMP_DIR/maple" -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.ttc" \) \
      -exec cp -f {} "$FONT_DIR/maple-mono-nf/" \;
  else
    echo "Already installed: $FONT_DIR/maple-mono-nf"
  fi

  fc-cache -fv "$FONT_DIR"
}

verify_fonts() {
  need_cmd fc-scan

  echo
  echo "Installed font files:"
  find "$FONT_DIR" -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.ttc" \) | sort
  echo
  echo "Scanned font families:"
  fc-scan --format "%{family}\n" "$FONT_DIR" | sort -u
}

parse_args "$@"

case "$MODE" in
  assets)
    install_font_assets
    ;;
  system)
    install_noto_with_apt
    echo "Installing requested font files to $FONT_DIR."
    install_font_assets
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

verify_fonts
