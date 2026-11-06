#!/usr/bin/env bash
# agentack (agentic stack) — skill + alt ajanları ~/.claude altına kurar.
# Kullanım:
#   ./install.sh            kur / güncelle
#   ./install.sh --uninstall kaldır
# Var olan aynı adlı dosyalar ~/.claude/backups/agentack-<zaman>/ altına yedeklenir.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/backups/agentack-$STAMP"
AGENTS=$(cd "$SRC/agents" && ls *.md)

backup() {
  local target="$1"
  if [ -e "$target" ]; then
    mkdir -p "$BACKUP/$(dirname "${target#$DEST/}")"
    cp -a "$target" "$BACKUP/${target#$DEST/}"
  fi
}

remove() {
  local target="$1"
  if [ -e "$target" ]; then
    backup "$target"
    rm -rf "$target"
    echo "  kaldırıldı: ${target#$DEST/}"
  fi
}

if [ "${1:-}" = "--uninstall" ]; then
  echo "Kaldırılıyor: $DEST"
  remove "$DEST/skills/agentack"
  for a in $AGENTS; do remove "$DEST/agents/$a"; done
  if [ -d "$BACKUP" ]; then echo "Yedek: $BACKUP"; fi
  exit 0
fi

echo "agentack kuruluyor: $DEST"
mkdir -p "$DEST/skills" "$DEST/agents"

# Eski adla yapılmış kurulumu temizle
remove "$DEST/skills/fullstack-workflow"

backup "$DEST/skills/agentack"
rm -rf "$DEST/skills/agentack"
cp -a "$SRC/skills/agentack" "$DEST/skills/"
echo "  kuruldu: skills/agentack"

for a in $AGENTS; do
  backup "$DEST/agents/$a"
  cp "$SRC/agents/$a" "$DEST/agents/$a"
done
echo "  kuruldu: agents/ ($(echo $AGENTS | wc -w) ajan)"

if [ -d "$SRC/.git" ]; then
  echo "  sürüm: $(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo bilinmiyor)"
fi

echo
echo "Tamam. Claude Code'u yeniden başlat; /agentack ile çağır, /agents ile ajanları kontrol et."
if [ -d "$BACKUP" ]; then echo "Eski dosyalar: $BACKUP"; fi
