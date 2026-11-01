#!/bin/zsh
# Copy a file or folder and compare it with the original.
# The original is never touched, and an existing destination is never overwritten.
# Usage: zsh copia_verificata.sh ORIGINALE DESTINAZIONE
# Exit status: 0 and "OK" only when the copy is complete and identical.
emulate -L zsh

if (( $# != 2 )); then
  print -u2 -- "Uso: zsh copia_verificata.sh ORIGINALE DESTINAZIONE"
  exit 2
fi

source_path="${1:A}"
parent="${2:h}"
target_name="${2:t}"

fail() {
  print -r -- "ERRORE $source_path: $1"
  exit 1
}

[[ -e "$source_path" ]] || fail "l'originale non esiste"
mkdir -p "$parent" || fail "impossibile creare la cartella di destinazione"
target_path="${parent:A}/$target_name"
[[ "$target_path" == "$source_path"/* || "$target_path" == "$source_path" ]] && fail "la destinazione sta dentro l'originale"
# ditto would merge into an existing folder and overwrite same-named files with no way back.
[[ -e "$target_path" || -L "$target_path" ]] && fail "la destinazione esiste gia': scegli un altro nome, niente viene sovrascritto"

needed_kb=$(du -sk "$source_path" 2>/dev/null | cut -f1)
free_kb=$(df -k "$parent" | tail -1 | awk '{print $4}')
(( ${needed_kb:-0} < ${free_kb:-0} )) || fail "spazio insufficiente sul disco di destinazione"

device=$(df "$parent" | tail -1 | awk '{print $1}')
format=$(diskutil info "$device" 2>/dev/null | sed -n 's/.*File System Personality: *//p')
case "$format" in
  *APFS*|*"Mac OS Extended"*|*HFS*) ;;
  "") print -r -- "ATTENZIONE: formato del disco non riconosciuto, permessi e metadati possono andare persi" ;;
  *) print -r -- "ATTENZIONE: disco in formato $format, permessi e metadati possono andare persi" ;;
esac

ditto "$source_path" "$target_path" || fail "copia interrotta"
sync

if [[ ! -d "$source_path" ]]; then
  cmp -s -- "$source_path" "$target_path" || fail "il file copiato e' diverso"
  print -r -- "OK $source_path: 1 file identico"
  exit 0
fi

count_files() { find "$1" -type f ! -name '.DS_Store' ! -name '._*' -print0 | tr -dc '\0' | wc -c | tr -d ' '; }

checked=0
different=0
while IFS= read -r -d '' file; do
  relative="${file#$source_path/}"
  checked=$(( checked + 1 ))
  if ! cmp -s -- "$file" "$target_path/$relative"; then
    different=$(( different + 1 ))
    print -r -- "diverso o mancante: $relative"
  fi
done < <(find "$source_path" -type f ! -name '.DS_Store' ! -name '._*' -print0)

links=0
while IFS= read -r -d '' link; do
  relative="${link#$source_path/}"
  links=$(( links + 1 ))
  if [[ "$(readlink "$link")" != "$(readlink "$target_path/$relative")" ]]; then
    different=$(( different + 1 ))
    print -r -- "collegamento diverso o mancante: $relative"
  fi
done < <(find "$source_path" -type l -print0)

(( different == 0 )) || fail "$different elementi su $(( checked + links )) non corrispondono"

# A disk that ignores upper and lower case can merge two files into one: every
# comparison above would pass, so the number of files must match as well.
copied=$(count_files "$target_path")
(( copied == checked )) || fail "$checked file nell'originale, $copied nella copia"

print -r -- "OK $source_path: $checked file identici, $links collegamenti identici"
