#!/bin/zsh
# Compare a folder with a possible copy of it. Read-only.
# Usage: zsh confronta_copie.sh [--contenuto] ORIGINALE COPIA
# By default it compares names and sizes; --contenuto also compares every byte.
emulate -L zsh

check_content=0
if [[ "${1:-}" == "--contenuto" ]]; then
  check_content=1
  shift
fi
if (( $# != 2 )) || [[ ! -d "$1" || ! -d "$2" ]]; then
  print -u2 -- "Uso: zsh confronta_copie.sh [--contenuto] ORIGINALE COPIA"
  exit 2
fi

original="${1:A}"
copy="${2:A}"
work=$(mktemp -d)

list_files() {
  (cd "$1" && find . -type f ! -name '.DS_Store' ! -name '._*' -exec stat -f '%z %N' {} + 2>/dev/null | sort)
}

list_files "$original" > "$work/original.txt"
list_files "$copy" > "$work/copy.txt"
original_count=$(wc -l < "$work/original.txt" | tr -d ' ')
copy_count=$(wc -l < "$work/copy.txt" | tr -d ' ')
missing=$(comm -23 "$work/original.txt" "$work/copy.txt" | wc -l | tr -d ' ')

print -r -- "Originale: $original_count file | Copia: $copy_count file | Mancanti o diversi nella copia: $missing"
if (( missing > 0 )); then
  comm -23 "$work/original.txt" "$work/copy.txt" | head -n 5
  rm -rf "$work"
  print -r -- "ESITO: la copia non e' completa"
  exit 1
fi

if (( check_content == 0 )); then
  rm -rf "$work"
  print -r -- "ESITO: stessi nomi e stesse dimensioni (contenuto non confrontato)"
  exit 0
fi

different=0
while IFS= read -r line; do
  relative="${line#* }"
  cmp -s -- "$original/$relative" "$copy/$relative" || different=$(( different + 1 ))
done < "$work/original.txt"
rm -rf "$work"

if (( different > 0 )); then
  print -r -- "ESITO: $different file con contenuto diverso"
  exit 1
fi
print -r -- "ESITO: contenuto identico, byte per byte"
